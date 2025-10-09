# TopengWebcamController.gd
extends Control

@onready var webcam_feed = $MainContainer/WebcamContainer/WebcamPanel/WebcamFeed
@onready var camera_status_label = $MainContainer/WebcamContainer/WebcamPanel/WebcamFeed/CameraStatusLabel
@onready var mask_display = $MainContainer/WebcamContainer/WebcamPanel/WebcamFeed/MaskOverlay/MaskDisplay
@onready var mask_info_label = $MainContainer/InfoContainer/MaskInfoLabel
@onready var status_label = $MainContainer/InfoContainer/StatusLabel
@onready var pilih_topeng_button = $MainContainer/ButtonContainer/PilihTopengButton
@onready var menu_utama_button = $MainContainer/ButtonContainer/MenuUtamaButton
# FPS label is optional - may not exist in all scenes
var fps_label: Label = null

# Navigation System
var buttons: Array[Button] = []
var current_button_index: int = 0
var navigation_enabled: bool = true
var last_navigation_time: float = 0.0
var navigation_cooldown: float = 0.2

# Webcam Manager - will be loaded manually
var webcam_manager: Node = null
var webcam_frames_received: int = 0
var frame_count := 0
var fps := 0.0
var last_time := 0.0

func _ready() -> void:
	print("=== TopengWebcamController._ready() ===")
	print("Scene tree ready, setting up webcam...")
	last_time = Time.get_ticks_msec()   # init untuk FPS

	# Verify node paths (debug)
	print("webcam_feed path exists: ", has_node("MainContainer/WebcamContainer/WebcamPanel/WebcamFeed"))
	print("camera_status_label path exists: ", has_node("MainContainer/WebcamContainer/WebcamPanel/WebcamFeed/CameraStatusLabel"))
	
	# Try to find FPS label (optional)
	if has_node("MainContainer/WebcamContainer/WebcamPanel/WebcamFeed/FPSLabel"):
		fps_label = $MainContainer/WebcamContainer/WebcamPanel/WebcamFeed/FPSLabel
	
	# Setup navigation
	setup_navigation()
	
	if fps_label:
		print("fps_label found and assigned")
	else:
		print("fps_label not found - will skip FPS display")
	
	setup_webcam_manager()
	setup_mask_display()
	display_mask_info()
	
	# If a mask was selected, send it to the server
	# (This handles cases where user came from selection but server wasn't ready yet)
	if Global.selected_mask_type == "custom":
		print("Custom mask detected in Global, will send to server after a short delay...")
		# Wait a moment for server connection to be established
		await get_tree().create_timer(1.0).timeout
		send_custom_mask_from_global()
	elif Global.selected_mask_type == "preset":
		print("Preset mask detected in Global, will send to server after a short delay...")
		# Wait a moment for server connection to be established
		await get_tree().create_timer(1.0).timeout
		send_preset_mask_from_global()
	else:
		print("No mask selected, setting default mask (bali.png)...")
		# Wait a moment for server connection to be established
		await get_tree().create_timer(1.0).timeout
		send_default_mask()

func setup_webcam_manager() -> void:
	"""Setup WebcamManagerUDP for real webcam"""
	print("=== Setting up WebcamManagerUDP ===")

	# Verify nodes are available
	if webcam_feed == null:
		print("❌ ERROR: webcam_feed node not found!")
		return

	if camera_status_label == null:
		print("❌ ERROR: camera_status_label node not found!")
		return

	# Setup placeholder image first
	setup_webcam_placeholder()

	# Load the webcam manager (use working path format)
	var webcam_script = load("res://Scenes/EthnicityDetection/WebcamClient/WebcamManagerUDP.gd")
	if webcam_script == null:
		print("❌ ERROR: Could not find WebcamManagerUDP.gd")
		camera_status_label.text = "❌ Script not found"
		camera_status_label.modulate = Color(1,0,0,0.9)
		return

	# Instantiate and add as child
	webcam_manager = webcam_script.new()
	if webcam_manager == null:
		print("❌ ERROR: Failed to instantiate WebcamManagerUDP")
		camera_status_label.text = "❌ Instantiation error"
		camera_status_label.modulate = Color(1,0,0,0.9)
		return

	add_child(webcam_manager)
	print("✅ Created WebcamManagerUDP instance and added to scene tree")
	
	# Set port to 8889 for Topeng server
	webcam_manager.server_port = 8889
	print("✅ Topeng server port set to: 8889")

	# Connect signals (use Callable for Godot 4)
	# frame_received(texture)
	if webcam_manager.has_signal("frame_received"):
		var err = webcam_manager.connect("frame_received", Callable(self, "_on_webcam_frame_received"))
		if err == OK:
			print("✅ Connected frame_received signal")
		else:
			print("⚠️ Could not connect frame_received signal (err=%s)" % str(err))
	else:
		print("⚠️ Webcam manager has no 'frame_received' signal")

	# connection_changed(connected: bool)
	if webcam_manager.has_signal("connection_changed"):
		var err2 = webcam_manager.connect("connection_changed", Callable(self, "_on_webcam_connection_changed"))
		if err2 == OK:
			print("✅ Connected connection_changed signal")
		else:
			print("⚠️ Could not connect connection_changed signal (err=%s)" % str(err2))
	else:
		print("⚠️ Webcam manager has no 'connection_changed' signal")

	# error_message(message: String)
	if webcam_manager.has_signal("error_message"):
		var err3 = webcam_manager.connect("error_message", Callable(self, "_on_webcam_error"))
		if err3 == OK:
			print("✅ Connected error_message signal")
		else:
			print("⚠️ Could not connect error_message signal (err=%s)" % str(err3))
	else:
		print("⚠️ Webcam manager has no 'error_message' signal")

	# Update status UI
	camera_status_label.text = "🔗 Menghubungkan ke Topeng Mask Server (port 8889)..."
	camera_status_label.modulate = Color(1, 1, 0, 0.9)

	# Try connecting to webcam server
	if webcam_manager.has_method("connect_to_webcam_server"):
		print("Attempting UDP connection to Topeng Mask Server (Port 8889)...")
		# Start connection process with delay
		_connect_with_delay()
	else:
		print("⚠️ WebcamManagerUDP instance does not have connect_to_webcam_server() method")
		camera_status_label.text = "❌ No connect method"
		camera_status_label.modulate = Color(1,0,0,0.9)


func _connect_with_delay() -> void:
	"""Connect to webcam server with delay to ensure camera is released"""
	print("⏳ Waiting 1.0 seconds for previous camera to be released...")
	# Wait longer to ensure previous camera is released
	await get_tree().create_timer(1.0).timeout
	print("🔄 Attempting to connect to Topeng server (port 8889)...")
	# Connect to Topeng server (port 8889)
	webcam_manager.connect_to_webcam_server()
	print("✅ Called connect_to_webcam_server()")

func setup_webcam_placeholder() -> void:
	var w := 640
	var h := 480
	var placeholder_image := Image.create(w, h, false, Image.FORMAT_RGBA8)
	placeholder_image.fill(Color(0.12, 0.14, 0.18, 1.0)) # dark background

	# Draw border rect
	for x in range(w):
		placeholder_image.set_pixel(x, 0, Color(0.3,0.34,0.4,1))
		placeholder_image.set_pixel(x, h-1, Color(0.3,0.34,0.4,1))
	for y in range(h):
		placeholder_image.set_pixel(0, y, Color(0.3,0.34,0.4,1))
		placeholder_image.set_pixel(w-1, y, Color(0.3,0.34,0.4,1))

	var placeholder_texture := ImageTexture.new()
	placeholder_texture.create_from_image(placeholder_image)
	webcam_feed.texture = placeholder_texture

func setup_mask_display() -> void:
	"""Setup the mask overlay display"""
	print("Setting up mask display...")

	# Create a placeholder mask texture (small)
	var mask_image = Image.create(200, 200, false, Image.FORMAT_RGBA8)
	mask_image.fill(Color(0, 0, 0, 0)) # fully transparent

	for x in range(200):
		for y in range(200):
			var d = Vector2(x - 100, y - 100).length()
			if d < 60:
				mask_image.set_pixel(x, y, Color(0.9, 0.7, 0.5, 0.25))

	# Use static constructor for cross-version compatibility
	var mask_texture := ImageTexture.create_from_image(mask_image)
	mask_display.texture = mask_texture

func display_mask_info() -> void:
	"""Display information about the selected mask"""
	var mask_info := ""
	# safe-get selected_mask_type/id using Global if available
	var selected_type: String = ""   # <-- tambahkan tipe String, default kosong
	var selected_id: int = -1        # <-- tambahkan tipe Int, default -1
	# assume Global autoload exists in this project (other scripts reference it)
	# use direct property access with null checks
	if typeof(Global) != TYPE_NIL:
		if "selected_mask_type" in Global:
			selected_type = Global.selected_mask_type
		if "selected_mask_id" in Global:
			selected_id = Global.selected_mask_id

	if selected_type == "preset":
		mask_info = "Topeng Preset #" + str(selected_id)
		status_label.text = "Status: Menampilkan topeng preset"
	elif selected_type == "custom":
		# safe-get components from Global (use "in" operator so missing property yields null)
		var components = null
		if typeof(Global) != TYPE_NIL:
			if "custom_mask_components" in Global:
				components = Global.custom_mask_components
		if components != null:
			# assume components has .base, .mata, .mulut (same structure as before)
			mask_info = "Topeng Custom (Base: %d, Mata: %d, Mulut: %d)" % [components.base, components.mata, components.mulut]
		else:
			mask_info = "Topeng Custom"
		status_label.text = "Status: Menampilkan topeng custom"
	else:
		mask_info = "Topeng: Tidak ada yang dipilih"
		status_label.text = "Status: Tidak ada topeng"

	mask_info_label.text = mask_info
	print("Displaying mask info: " + mask_info)

func _on_webcam_frame_received(texture: ImageTexture) -> void:
	if webcam_feed == null:
		return

	webcam_feed.texture = texture
	webcam_frames_received += 1

	# FPS tracking
	frame_count += 1
	var now = Time.get_ticks_msec()
	var elapsed = (now - last_time) / 1000.0
	if elapsed >= 1.0:
		fps = frame_count / elapsed
		if fps_label:
			fps_label.text = "FPS: %.2f" % fps
		frame_count = 0
		last_time = now

	# Update status label lebih jarang
	if (webcam_frames_received % 30) == 1:
		camera_status_label.text = "📹 Webcam aktif (%d frames)" % webcam_frames_received
		camera_status_label.modulate = Color(0, 1, 0, 0.9)

func _on_webcam_connection_changed(connected: bool) -> void:
	"""Handle webcam connection status changes"""
	print("Webcam connection changed: ", connected)
	if connected:
		camera_status_label.text = "✅ Webcam terhubung!"
		camera_status_label.modulate = Color(0, 1, 0, 0.9)
		status_label.text = "Status: Webcam siap dengan topeng"
	else:
		camera_status_label.text = "❌ Koneksi webcam terputus"
		camera_status_label.modulate = Color(1, 0, 0, 0.9)
		status_label.text = "Status: Menghubungkan ulang..."


func _on_webcam_error(message: String) -> void:
	"""Handle webcam errors"""
	print("Webcam error: ", message)
	camera_status_label.text = "❌ Error: " + message
	camera_status_label.modulate = Color(1, 0, 0, 0.9)
	status_label.text = "Status: " + message


func _on_pilih_topeng_button_pressed() -> void:
	"""Return to mask selection"""
	print("Pilih Topeng button pressed - returning to mask selection")
	cleanup_resources()
	get_tree().change_scene_to_file("res://Scenes/TopengNusantara/TopengSelectionScene.tscn")


func _on_menu_utama_button_pressed() -> void:
	"""Return to main menu"""
	print("Menu Utama button pressed - returning to main menu")
	cleanup_resources()
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")


func cleanup_resources() -> void:
	"""Clean up webcam resources"""
	print("Cleaning up webcam resources...")

	if webcam_manager != null:
		# Disconnect from server
		if webcam_manager.has_method("disconnect_from_server"):
			print("Calling webcam_manager.disconnect_from_server()")
			webcam_manager.disconnect_from_server()

		# free and nil the manager node
		webcam_manager.queue_free()
		webcam_manager = null
		print("Webcam manager cleaned up")


func _notification(what: int) -> void:
	"""Handle scene exit cleanup"""
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		cleanup_resources()


# ------------------ Custom Mask Helper ------------------
func send_custom_mask_from_global() -> void:
	"""
	Send custom mask configuration from Global to the server.
	This is called when the webcam scene loads and a custom mask is already selected.
	"""
	if Global.selected_mask_type != "custom":
		return
	
	var components = Global.custom_mask_components
	if components == null:
		print("⚠️ Custom mask type selected but no components found in Global")
		return
	
	var base_id = 0
	var mata_id = 0
	var mulut_id = 0
	if "base" in components:
		base_id = components.base
	if "mata" in components:
		mata_id = components.mata
	if "mulut" in components:
		mulut_id = components.mulut
	
	print("Sending custom mask from Global to server: Base=%d, Mata=%d, Mulut=%d" % [base_id, mata_id, mulut_id])
	
	# Use the Topeng Mask Server port (8889)
	var server_host: String = "127.0.0.1"
	var server_port: int = 8889  # ✅ CRITICAL: Use Topeng server port!
	
	var udp = PacketPeerUDP.new()
	var err = udp.connect_to_host(server_host, server_port)
	if err != OK:
		print("❌ Failed to connect UDP to %s:%d (error %d)" % [server_host, server_port, err])
		return
	
	# Format: "SET_CUSTOM_MASK base_id,mata_id,mulut_id"
	var message := "SET_CUSTOM_MASK %d,%d,%d" % [base_id, mata_id, mulut_id]
	var packet := message.to_utf8_buffer()
	var send_err = udp.put_packet(packet)
	if send_err != OK:
		print("❌ Failed to send SET_CUSTOM_MASK packet (error %d)" % send_err)
		udp.close()
		return
	
	print("📤 Sent custom mask to Topeng server:", message)
	
	# Wait briefly for acknowledgment (non-blocking)
	for i in range(30):  # Wait up to ~0.5 seconds
		await get_tree().process_frame
		if udp.get_available_packet_count() > 0:
			var response_packet = udp.get_packet()
			var resp := response_packet.get_string_from_utf8()
			if resp != "":
				print("📥 Server response:", resp)
				if resp.begins_with("SET_CUSTOM_MASK_RECEIVED") or resp.begins_with("CUSTOM_MASK_SET:"):
					print("✅ Server acknowledged custom mask")
					break
	
	udp.close()


func send_preset_mask_from_global() -> void:
	"""
	Send preset mask configuration from Global to the server.
	This is called when the webcam scene loads and a preset mask is already selected.
	"""
	if Global.selected_mask_type != "preset":
		return
	
	var mask_id = -1
	if "selected_mask_id" in Global:
		mask_id = Global.selected_mask_id
	if mask_id <= 0 or mask_id > 7:
		print("⚠️ Preset mask type selected but invalid mask_id: %d" % mask_id)
		return
	
	# Map mask_id to actual mask filename
	var mask_filenames = {
		1: "bali.png",
		2: "betawi.png", 
		3: "hudoq.png",
		4: "kelana.png",
		5: "panji2.png",
		6: "prabu.png",
		7: "sumatra.png"
	}
	
	var mask_filename = ""
	if mask_id in mask_filenames:
		mask_filename = mask_filenames[mask_id]
	if mask_filename == "":
		print("⚠️ No mask filename found for mask_id: %d" % mask_id)
		return
	
	print("Sending preset mask from Global to server: %s (ID: %d)" % [mask_filename, mask_id])
	
	# Use the Topeng Mask Server port (8889)
	var server_host: String = "127.0.0.1"
	var server_port: int = 8889  # ✅ CRITICAL: Use Topeng server port!
	
	var udp = PacketPeerUDP.new()
	var err = udp.connect_to_host(server_host, server_port)
	if err != OK:
		print("❌ Failed to connect UDP to %s:%d (error %d)" % [server_host, server_port, err])
		return
	
	# Format: "SET_MASK filename"
	var message := "SET_MASK %s" % mask_filename
	var packet := message.to_utf8_buffer()
	var send_err = udp.put_packet(packet)
	if send_err != OK:
		print("❌ Failed to send SET_MASK packet (error %d)" % send_err)
		udp.close()
		return
	
	print("📤 Sent preset mask to Topeng server:", message)
	
	# Wait briefly for acknowledgment (non-blocking)
	for i in range(30):  # Wait up to ~0.5 seconds
		await get_tree().process_frame
		if udp.get_available_packet_count() > 0:
			var response_packet = udp.get_packet()
			var resp := response_packet.get_string_from_utf8()
			if resp != "":
				print("📥 Server response:", resp)
				if resp.begins_with("SET_MASK_RECEIVED") or resp.begins_with("MASK_SET:"):
					print("✅ Server acknowledged preset mask")
					break
	
	udp.close()


func send_default_mask() -> void:
	"""
	Send default mask (bali.png) to the server.
	This is called when no mask is selected.
	"""
	print("Sending default mask (bali.png) to server...")
	
	# Use the Topeng Mask Server port (8889)
	var server_host: String = "127.0.0.1"
	var server_port: int = 8889  # ✅ CRITICAL: Use Topeng server port!
	
	var udp = PacketPeerUDP.new()
	var err = udp.connect_to_host(server_host, server_port)
	if err != OK:
		print("❌ Failed to connect UDP to %s:%d (error %d)" % [server_host, server_port, err])
		return
	
	# Format: "SET_MASK bali.png"
	var message := "SET_MASK bali.png"
	var packet := message.to_utf8_buffer()
	var send_err = udp.put_packet(packet)
	if send_err != OK:
		print("❌ Failed to send SET_MASK packet (error %d)" % send_err)
		udp.close()
		return
	
	print("📤 Sent default mask to Topeng server:", message)
	
	# Wait briefly for acknowledgment (non-blocking)
	for i in range(30):  # Wait up to ~0.5 seconds
		await get_tree().process_frame
		if udp.get_available_packet_count() > 0:
			var response_packet = udp.get_packet()
			var resp := response_packet.get_string_from_utf8()
			if resp != "":
				print("📥 Server response:", resp)
				if resp.begins_with("SET_MASK_RECEIVED") or resp.begins_with("MASK_SET:"):
					print("✅ Server acknowledged default mask")
					break
	
	udp.close()

func setup_navigation():
	"""Setup keyboard/joystick navigation for buttons"""
	buttons.clear()
	buttons.append(pilih_topeng_button)
	buttons.append(menu_utama_button)
	current_button_index = 0
	update_button_focus()
	
	# Set initial focus
	pilih_topeng_button.grab_focus()
	print("🎮 TopengWebcam navigation setup completed with " + str(buttons.size()) + " buttons")

func _input(event):
	"""Handle keyboard and joystick input for menu navigation"""
	# Check if viewport is still valid (prevent errors during scene transitions)
	if not get_viewport():
		return
	
	if not navigation_enabled:
		return
	
	# Handle keyboard input
	if event is InputEventKey and event.pressed:
		var viewport = get_viewport()
		if not viewport:
			return
			
		match event.keycode:
			KEY_UP:
				navigate_up()
				viewport.set_input_as_handled()
			KEY_DOWN:
				navigate_down()
				viewport.set_input_as_handled()
			KEY_LEFT:
				navigate_left()
				viewport.set_input_as_handled()
			KEY_RIGHT:
				navigate_right()
				viewport.set_input_as_handled()
			KEY_ENTER, KEY_SPACE:
				activate_current_button()
				viewport.set_input_as_handled()
			KEY_ESCAPE:
				handle_escape()
				viewport.set_input_as_handled()
	
	# Handle joystick input
	elif event is InputEventJoypadButton and event.pressed:
		var viewport = get_viewport()
		if not viewport:
			return
			
		match event.button_index:
			JOY_BUTTON_A:  # A button (Xbox style)
				activate_current_button()
				viewport.set_input_as_handled()
			JOY_BUTTON_B:  # B button (Xbox style)
				handle_escape()
				viewport.set_input_as_handled()
	
	elif event is InputEventJoypadMotion:
		# Handle analog stick movement
		var viewport = get_viewport()
		if not viewport:
			return
			
		if abs(event.axis_value) > 0.5:  # Dead zone
			match event.axis:
				JOY_AXIS_LEFT_Y:
					if event.axis_value < -0.5:  # Up
						navigate_up()
						viewport.set_input_as_handled()
					elif event.axis_value > 0.5:  # Down
						navigate_down()
						viewport.set_input_as_handled()
				JOY_AXIS_LEFT_X:
					if event.axis_value < -0.5:  # Left
						navigate_left()
						viewport.set_input_as_handled()
					elif event.axis_value > 0.5:  # Right
						navigate_right()
						viewport.set_input_as_handled()

func navigate_up():
	"""Navigate to previous button"""
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_navigation_time < navigation_cooldown:
		return
	
	if buttons.size() == 0:
		return
	
	current_button_index = (current_button_index - 1 + buttons.size()) % buttons.size()
	update_button_focus()
	last_navigation_time = current_time

func navigate_down():
	"""Navigate to next button"""
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_navigation_time < navigation_cooldown:
		return
	
	if buttons.size() == 0:
		return
	
	current_button_index = (current_button_index + 1) % buttons.size()
	update_button_focus()
	last_navigation_time = current_time

func navigate_left():
	"""Navigate left (same as up for horizontal layout)"""
	navigate_up()

func navigate_right():
	"""Navigate right (same as down for horizontal layout)"""
	navigate_down()

func activate_current_button():
	"""Activate the currently focused button"""
	if buttons.size() == 0:
		return
	
	if current_button_index >= 0 and current_button_index < buttons.size():
		var target_button = buttons[current_button_index]
		if target_button and is_instance_valid(target_button):
			target_button.emit_signal("pressed")

func handle_escape():
	"""Handle escape/back button"""
	menu_utama_button.emit_signal("pressed")

func update_button_focus():
	"""Update visual focus on current button"""
	if buttons.size() == 0:
		return
	
	# Clear focus from all buttons
	for button in buttons:
		if button and is_instance_valid(button):
			button.release_focus()
	
	# Set focus to current button
	if current_button_index >= 0 and current_button_index < buttons.size():
		var current_button = buttons[current_button_index]
		if current_button and is_instance_valid(current_button):
			current_button.grab_focus()
