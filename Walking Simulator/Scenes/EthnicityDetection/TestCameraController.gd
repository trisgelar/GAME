extends Control

# UI Nodes (matching EthnicityDetectionScene structure)
@onready var webcam_feed = $MainContainer/CameraContainer/WebcamContainer/WebcamFeed
@onready var camera_status_label = $MainContainer/CameraContainer/WebcamContainer/WebcamFeed/CameraStatusLabel
@onready var fps_label = $MainContainer/CameraContainer/WebcamContainer/FPSLabel
@onready var status_label = $MainContainer/StatusContainer/StatusLabel

# Clean Webcam Manager
var webcam_manager: Node

var frames_received: int = 0
var last_frame_time: float = 0.0
var current_fps: float = 0.0

func _ready():
	print("=== Test Camera Controller (Camera 0) ===")
	
	# Verify nodes
	if webcam_feed == null:
		print("❌ ERROR: webcam_feed node not found!")
		return
	
	if camera_status_label == null:
		print("❌ ERROR: camera_status_label node not found!")
		return
	
	# Setup placeholder
	setup_webcam_placeholder()
	
	# Load Clean Webcam Manager
	var webcam_script = load("res://Scenes/EthnicityDetection/WebcamClient/CleanWebcamManager.gd")
	if webcam_script == null:
		print("❌ ERROR: Could not load CleanWebcamManager.gd")
		camera_status_label.text = "❌ Script not found"
		camera_status_label.modulate = Color(1, 0, 0, 0.9)
		return
	
	print("Creating CleanWebcamManager instance...")
	webcam_manager = webcam_script.new()
	add_child(webcam_manager)
	
	# Connect signals
	if webcam_manager.has_signal("frame_received"):
		webcam_manager.frame_received.connect(_on_frame_received)
		print("✅ frame_received signal connected")
	
	if webcam_manager.has_signal("connection_changed"):
		webcam_manager.connection_changed.connect(_on_connection_changed)
		print("✅ connection_changed signal connected")
	
	if webcam_manager.has_signal("error_message"):
		webcam_manager.error_message.connect(_on_error)
		print("✅ error_message signal connected")
	
	# Update status
	camera_status_label.text = "🔗 Connecting to Camera 0 (ML Server)..."
	camera_status_label.modulate = Color(1, 1, 0, 0.8)
	
	# Start connection
	print("Attempting connection to ML server...")
	webcam_manager.connect_to_webcam_server()
	
	print("Test Camera Controller setup complete")

func setup_webcam_placeholder():
	"""Setup placeholder image while connecting"""
	var placeholder = Image.create(640, 480, false, Image.FORMAT_RGB8)
	placeholder.fill(Color(0.2, 0.2, 0.2))  # Dark gray
	
	var placeholder_texture = ImageTexture.new()
	placeholder_texture.set_image(placeholder)
	webcam_feed.texture = placeholder_texture

func _on_frame_received(texture: ImageTexture):
	"""Handle received video frame"""
	frames_received += 1
	webcam_feed.texture = texture
	
	# Calculate FPS
	var current_time = Time.get_unix_time_from_system()
	if last_frame_time > 0:
		var time_diff = current_time - last_frame_time
		if time_diff > 0:
			current_fps = 1.0 / time_diff
			if fps_label:
				fps_label.text = "FPS: %.1f" % current_fps
	
	last_frame_time = current_time
	
	# Update status every 30 frames
	if frames_received % 30 == 0:
		print("📹 Received frame %d (%.1f FPS)" % [frames_received, current_fps])
		if status_label:
			status_label.text = "Camera 0 working - %d frames received" % frames_received

func _on_connection_changed(connected: bool):
	"""Handle connection status change"""
	if connected:
		print("✅ Connected to ML server successfully")
		camera_status_label.text = "✅ Camera 0 connected"
		camera_status_label.modulate = Color(0, 1, 0, 0.9)
		if status_label:
			status_label.text = "Connected to ML server - Camera 0 active"
	else:
		print("❌ Disconnected from ML server")
		camera_status_label.text = "❌ Camera 0 disconnected"
		camera_status_label.modulate = Color(1, 0, 0, 0.9)
		if status_label:
			status_label.text = "Disconnected from ML server"

func _on_error(message: String):
	"""Handle error messages"""
	print("❌ Camera Error: " + message)
	camera_status_label.text = "❌ Error: " + message
	camera_status_label.modulate = Color(1, 0, 0, 0.9)
	if status_label:
		status_label.text = "Error: " + message

func _exit_tree():
	"""Clean up on exit"""
	if webcam_manager:
		print("🔌 Disconnecting from server...")
		webcam_manager.disconnect_from_server()
