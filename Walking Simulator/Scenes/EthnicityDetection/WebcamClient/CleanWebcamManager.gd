extends Node

signal frame_received(texture: ImageTexture)
signal connection_changed(connected: bool)
signal error_message(message: String)

var udp_client: PacketPeerUDP
var is_connected: bool = false
var server_host: String = "127.0.0.1"
var server_port: int = 8888  # ML server port

# Frame assembly (based on working Topeng implementation)
var frame_buffers: Dictionary = {}
var last_completed_sequence: int = 0
var frame_timeout: float = 0.5

# Performance monitoring
var frame_count: int = 0
var packets_received: int = 0
var frames_completed: int = 0
var frames_dropped: int = 0

# Processing optimization
var max_packets_per_frame: int = 10

func _ready():
	udp_client = PacketPeerUDP.new()
	print("🎮 Clean Webcam Manager ready (Camera 0, Port 8888)")

func connect_to_webcam_server():
	if is_connected:
		return
		
	print("🔄 Connecting to ML server (Camera 0)...")
	
	var error = udp_client.connect_to_host(server_host, server_port)
	if error != OK:
		_emit_error("UDP setup failed: " + str(error))
		return
	
	# Send REGISTER command (same protocol as Topeng)
	var register_message = "REGISTER".to_utf8_buffer()
	var send_result = udp_client.put_packet(register_message)
	
	if send_result != OK:
		_emit_error("Failed to send REGISTER")
		return
	
	print("📤 Sent REGISTER to server at %s:%d..." % [server_host, server_port])
	# Note: PacketPeerUDP doesn't have is_connected_to_host() method
	set_process(true)
	
	# Wait for REGISTERED response
	print("⏳ Waiting for REGISTERED response from server...")
	await get_tree().create_timer(2.0).timeout
	
	print("🔍 DEBUG: After 2s timeout, is_connected = %s" % is_connected)
	
	if is_connected:
		print("✅ Connected to ML server successfully")
		connection_changed.emit(true)
		set_process(true)
		_reset_stats()
	else:
		print("❌ No REGISTERED response received from server")
		_emit_error("Connection timeout - no REGISTERED response")
		udp_client.close()

func disconnect_from_server():
	if not is_connected:
		return
		
	print("🔌 Disconnecting from ML server...")
	
	# Send UNREGISTER command
	var unregister_message = "UNREGISTER".to_utf8_buffer()
	udp_client.put_packet(unregister_message)
	
	udp_client.close()
	is_connected = false
	connection_changed.emit(false)
	set_process(false)
	
	print("✅ Disconnected from ML server")

func _process(_delta):
	if not udp_client:
		return
		
	var packets_processed = 0
	var packets_available = udp_client.get_available_packet_count()
	
	# Process packets (limit to prevent frame drops)
	while packets_available > 0 and packets_processed < max_packets_per_frame:
		var packet = udp_client.get_packet()
		if packet.size() > 0:
			_handle_packet(packet)
			packets_processed += 1
			packets_received += 1
		
		packets_available = udp_client.get_available_packet_count()
	
	# Clean up old incomplete frames
	_cleanup_old_frames()

func _handle_packet(packet: PackedByteArray):
	if packet.size() == 0:
		return
	
	# Debug: Log all received packets
	print("🔍 DEBUG: Received packet size: %d bytes" % packet.size())
	
	# Check for REGISTERED response
	var message = packet.get_string_from_utf8()
	if message == "REGISTERED":
		print("✅ Received REGISTERED from server")
		is_connected = true
		connection_changed.emit(true)
		_reset_stats()
		return
	
	# Handle frame packets (same format as Topeng)
	if packet.size() < 12:  # Minimum header size
		print("⚠️ Packet too small for frame header: %d bytes" % packet.size())
		return
	
	# Parse frame packet header (ML server format: sequence, total_packets, packet_index)
	# The ML server uses big-endian format (!III), but Godot decode_u32 is little-endian
	# We need to manually parse the bytes in big-endian order
	
	var header_bytes = packet.slice(0, 12)
	
	# Parse big-endian 32-bit integers manually
	var sequence = (header_bytes[0] << 24) | (header_bytes[1] << 16) | (header_bytes[2] << 8) | header_bytes[3]
	var total_packets = (header_bytes[4] << 24) | (header_bytes[5] << 16) | (header_bytes[6] << 8) | header_bytes[7]
	var packet_index = (header_bytes[8] << 24) | (header_bytes[9] << 16) | (header_bytes[10] << 8) | header_bytes[11]
	
	# Debug: Log header values
	print("🔍 DEBUG: Header - seq:%d, total:%d, idx:%d" % [sequence, total_packets, packet_index])
	
	# Validate header values
	if total_packets == 0 or total_packets > 1000:
		print("⚠️ Invalid total_packets value: %d" % total_packets)
		return
	
	# Extract frame data (skip 12-byte header)
	var frame_data = packet.slice(12)
	
	# Store packet in buffer
	if sequence not in frame_buffers:
		frame_buffers[sequence] = {}
	
	frame_buffers[sequence][packet_index] = frame_data
	
	# Check if frame is complete
	if frame_buffers[sequence].size() == total_packets:
		_compile_frame(sequence, total_packets)

func _compile_frame(sequence: int, total_packets: int):
	var frame_data = PackedByteArray()
	
	# Concatenate all packets in order
	for i in range(total_packets):
		if i in frame_buffers[sequence]:
			frame_data.append_array(frame_buffers[sequence][i])
		else:
			print("❌ Missing packet %d for frame %d" % [i, sequence])
			frames_dropped += 1
			return
	
	# Convert to image
	var image = Image.new()
	var error = image.load_jpg_from_buffer(frame_data)
	
	if error != OK:
		# Try PNG if JPG fails
		error = image.load_png_from_buffer(frame_data)
	
	if error == OK:
		var texture = ImageTexture.new()
		texture.set_image(image)
		frame_received.emit(texture)
		frames_completed += 1
		frame_count += 1
		
		# Only print every 30 frames to reduce spam
		if frame_count % 30 == 0:
			print("📹 Frame %d received (%dx%d)" % [frame_count, image.get_width(), image.get_height()])
	else:
		print("❌ Failed to load frame image: " + str(error))
		frames_dropped += 1
	
	# Clean up frame buffer
	frame_buffers.erase(sequence)
	last_completed_sequence = sequence

func _cleanup_old_frames():
	var current_time = Time.get_unix_time_from_system()
	
	# Remove frames older than timeout
	var sequences_to_remove = []
	for sequence in frame_buffers:
		# Simple cleanup - remove incomplete frames that are too old
		if sequence < last_completed_sequence - 5:
			sequences_to_remove.append(sequence)
	
	for sequence in sequences_to_remove:
		frame_buffers.erase(sequence)
		frames_dropped += 1

func _reset_stats():
	frame_count = 0
	packets_received = 0
	frames_completed = 0
	frames_dropped = 0
	frame_buffers.clear()
	last_completed_sequence = 0

func _emit_error(message: String):
	print("❌ CleanWebcamManager Error: " + message)
	error_message.emit(message)

func get_stats() -> Dictionary:
	return {
		"connected": is_connected,
		"frames_completed": frames_completed,
		"frames_dropped": frames_dropped,
		"packets_received": packets_received,
		"frame_count": frame_count
	}
