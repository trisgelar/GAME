extends Control

@onready var status_label = $MainContainer/StatusContainer/StatusLabel
@onready var progress_bar = $MainContainer/StatusContainer/ProgressBar
@onready var result_container = $MainContainer/ResultContainer
@onready var ethnicity_label = $MainContainer/ResultContainer/EthnicityLabel
@onready var description_label = $MainContainer/ResultContainer/DescriptionLabel
@onready var redirect_label = $MainContainer/ResultContainer/RedirectLabel
@onready var start_button = $MainContainer/ButtonContainer/StartDetectionButton
@onready var back_button = $MainContainer/ButtonContainer/BackButton
@onready var skip_to_map_button = $MainContainer/ButtonContainer/SkipToMapButton
@onready var loading_overlay = $LoadingOverlay
@onready var face_frame = $MainContainer/CameraContainer/WebcamContainer/WebcamFeed/DetectionOverlay/FaceFrame
@onready var webcam_feed = $MainContainer/CameraContainer/WebcamContainer/WebcamFeed
@onready var camera_status_label = $MainContainer/CameraContainer/WebcamContainer/WebcamFeed/CameraStatusLabel
@onready var loading_spinner = $LoadingOverlay/LoadingContainer/LoadingSpinner
# Label FPS dan Confidence
@onready var fps_label = $MainContainer/CameraContainer/WebcamContainer/FPSLabel
@onready var confidence_label = $MainContainer/ResultContainer/ConfidenceLabel

# Navigation System
var buttons: Array[Button] = []
var current_button_index: int = 0
var navigation_enabled: bool = true
var last_navigation_time: float = 0.0
var navigation_cooldown: float = 0.2

# Webcam Manager - akan di-load secara manual
var webcam_manager: Node

var detection_timer: Timer
var redirect_timer: Timer
var detection_progress: float = 0.0
var is_detecting: bool = false
var detected_ethnicity_result: String = ""
var spinner_rotation: float = 0.0
var webcam_frames_received: int = 0
var last_frame_time: float = 0.0
var current_fps: float = 0.0

# Simulasi data etnis
var ethnicity_data = {
	"Jawa": {
		"description": "[b]Etnis Jawa[/b]\nSuku Jawa adalah kelompok etnik terbesar di Indonesia yang berasal dari Jawa Tengah dan Jawa Timur. Dikenal dengan budaya yang kaya, termasuk batik, wayang, dan gamelan.",
		"scene": "res://Scenes/IndonesiaBarat/PasarScene.tscn"
	},
	"Batak": {
		"description": "[b]Etnis Batak[/b]\nSuku Batak berasal dari Sumatera Utara dengan tradisi musik gondang dan tarian tortor. Memiliki sistem kekerabatan patrilineal yang kuat.",
		"scene": "res://Scenes/IndonesiaBarat/PasarScene.tscn"
	},
	"Sasak": {
		"description": "[b]Etnis Sasak[/b]\nSuku Sasak adalah penduduk asli Pulau Lombok dengan tradisi tenun songket dan upacara peresean (pertarungan rotan).",
		"scene": "res://Scenes/IndonesiaTengah/TamboraScene.tscn"
	},
	"Papua": {
		"description": "[b]Etnis Papua[/b]\nSuku Papua memiliki keberagaman budaya yang luar biasa dengan tradisi ukiran, tarian yospan, dan upacara bakar batu.",
		"scene": "res://Scenes/IndonesiaTimur/PapuaScene.tscn"
	}
}

func _ready():
	print("=== EthnicityDetectionController._ready() ===")
	setup_webcam_manager()
	setup_timers()
	setup_loading_spinner()
	setup_navigation()
	reset_ui()

func setup_webcam_manager():
	"""Setup MLWebcamManager untuk real ML detection"""
	print("=== Setting up MLWebcamManager ===")
	
	# Verifikasi node tersedia
	if not webcam_feed:
		print("ERROR: webcam_feed node not found!")
		return
	
	if not camera_status_label:
		print("ERROR: camera_status_label node not found!")
		return
	
	# Setup placeholder image dulu
	setup_webcam_placeholder()
	
	# ✅ Load MLWebcamManager (has automatic ML detection)
	var webcam_script = load("res://Scenes/EthnicityDetection/WebcamClient/MLWebcamManager.gd")
	if webcam_script == null:
		print("❌ Error: Could not load MLWebcamManager.gd")
		camera_status_label.text = "❌ Script tidak ditemukan"
		camera_status_label.modulate = Color(1, 0, 0, 0.9)
		return
	
	print("Creating MLWebcamManager instance...")
	webcam_manager = webcam_script.new()
	add_child(webcam_manager)
	
	# Connect signals dengan error handling
	print("Connecting signals...")
	if webcam_manager.has_signal("frame_received"):
		webcam_manager.frame_received.connect(_on_webcam_frame_received)
		print("✅ frame_received signal connected")
	else:
		print("❌ frame_received signal not found")
	
	if webcam_manager.has_signal("connection_changed"):
		webcam_manager.connection_changed.connect(_on_webcam_connection_changed)
		print("✅ connection_changed signal connected")
	else:
		print("❌ connection_changed signal not found")
	
	if webcam_manager.has_signal("error_message"):
		webcam_manager.error_message.connect(_on_webcam_error)
		print("✅ error_message signal connected")
	else:
		print("❌ error_message signal not found")
	
	if webcam_manager.has_signal("detection_result_received"):
		webcam_manager.detection_result_received.connect(_on_detection_result_received)
		print("✅ detection_result_received signal connected")
	else:
		print("❌ detection_result_received signal not found")
		
	# Update status
	camera_status_label.text = "🔗 Menghubungkan ke ML server (port 8888)..."
	camera_status_label.modulate = Color(1, 1, 0, 0.8)
	
	# ✅ DUAL WEBCAM: Connect immediately (camera always ready)
	print("🔄 Connecting to ML server (dedicated camera)...")
	webcam_manager.connect_to_webcam_server()
	print("MLWebcamManager setup complete")

func setup_webcam_placeholder():
	"""Buat placeholder image untuk webcam"""
	var placeholder_image = Image.create(640, 480, false, Image.FORMAT_RGBA8)
	placeholder_image.fill(Color(0.2, 0.2, 0.3, 1.0))
	
	# Buat border
	for x in range(640):
		for y in range(10):
			placeholder_image.set_pixel(x, y, Color(0.4, 0.4, 0.5, 1.0))
			placeholder_image.set_pixel(x, 479-y, Color(0.4, 0.4, 0.5, 1.0))
	
	for y in range(480):
		for x in range(10):
			placeholder_image.set_pixel(x, y, Color(0.4, 0.4, 0.5, 1.0))
			placeholder_image.set_pixel(639-x, y, Color(0.4, 0.4, 0.5, 1.0))
	
	var placeholder_texture = ImageTexture.new()
	placeholder_texture.set_image(placeholder_image)
	webcam_feed.texture = placeholder_texture

func _on_webcam_frame_received(texture: ImageTexture):
	"""Optimized frame handler"""
	if not webcam_feed:
		return
	
	webcam_feed.texture = texture
	webcam_frames_received += 1

	# Hitung FPS real time dari interval antar frame webcam
	var now = Time.get_ticks_msec() / 1000.0
	if last_frame_time > 0.0:
		var dt = now - last_frame_time
		if dt > 0.0:
			current_fps = 1.0 / dt
	last_frame_time = now
	if fps_label:
		fps_label.text = "FPS: %.1f" % current_fps

	# Less frequent UI updates
	if webcam_frames_received == 1:
		camera_status_label.text = "🎥 Webcam aktif - siap untuk deteksi!"
		camera_status_label.modulate = Color(0, 1, 0, 0.8)
		print("✅ First frame received - camera is working!")
		
		# Hide status after 3 seconds
		await get_tree().create_timer(3.0).timeout
		if camera_status_label:
			camera_status_label.visible = false
	# Remove frequent frame counter updates for better performance

func _on_webcam_connection_changed(connected: bool):
	"""Callback ketika status koneksi webcam berubah"""
	if connected:
		camera_status_label.text = "🎥 UDP webcam terhubung - menunggu kamera..."
		camera_status_label.modulate = Color(1, 1, 0, 0.9)
		print("🎉 UDP webcam server connected successfully")
		
		# Wait a bit more for camera to be fully ready
		await get_tree().create_timer(1.0).timeout
		camera_status_label.text = "🎥 Kamera siap - tunggu frame pertama..."
		camera_status_label.modulate = Color(0, 1, 0, 0.9)
	else:
		camera_status_label.text = "❌ UDP koneksi terputus"
		camera_status_label.modulate = Color(1, 0, 0, 0.9)
		print("⛓️‍💥 UDP webcam server disconnected")

func _on_webcam_error(message: String):
	"""Callback ketika terjadi error webcam"""
	camera_status_label.text = "❌ Error: " + message
	camera_status_label.modulate = Color(1, 0, 0, 0.9)
	camera_status_label.visible = true
	print("Webcam Error: " + message)

func _on_detection_result_received(ethnicity: String, confidence: float, model: String):
	"""Callback ketika menerima hasil deteksi dari ML server"""
	print("🧠 Received ML detection result: " + ethnicity + " (" + str(confidence) + "%)")
	
	# Stop the simulation timer and use real ML result
	if detection_timer:
		detection_timer.stop()
	
	# Set the detected ethnicity result
	detected_ethnicity_result = ethnicity
	
	# Complete detection with real ML result
	detection_complete_with_ml_result(ethnicity, confidence, model)

func detection_complete_with_ml_result(ethnicity: String, confidence: float, model: String):
	"""Complete detection using real ML result instead of simulation"""
	is_detecting = false
	
	# Update UI with real ML result
	face_frame.border_color = Color(0, 1, 0, 0.8)
	status_label.text = "Deteksi berhasil!"
	ethnicity_label.text = "Etnis Terdeteksi: " + ethnicity
	description_label.text = ethnicity_data[ethnicity]["description"]
	
	result_container.visible = true
	start_button.visible = false

	# Tampilkan tombol skip ke map
	if skip_to_map_button:
		skip_to_map_button.visible = true
	
	# Update confidence with real ML result
	if confidence_label:
		confidence_label.text = "Confidence: %.1f%% (ML Model: %s)" % [confidence * 100, model]
	
	# Mulai countdown redirect (30 detik)
	redirect_timer.start()
	redirect_label.text = "Mengarahkan ke region budaya yang sesuai dalam 30 detik..."
	
	# Animate countdown
	create_countdown_animation()

func setup_loading_spinner():
	# Buat spinner loading sederhana
	var spinner_image = Image.create(50, 50, false, Image.FORMAT_RGBA8)
	spinner_image.fill(Color(0, 0, 0, 0))
	
	# Gambar circle dengan gap untuk spinner
	var center = Vector2(25, 25)
	var radius = 20
	
	for angle in range(0, 270, 10):  # 270 derajat untuk gap
		var rad = deg_to_rad(angle)
		var x = int(center.x + cos(rad) * radius)
		var y = int(center.y + sin(rad) * radius)
		
		# Gambar beberapa pixel untuk thickness
		for dx in range(-2, 3):
			for dy in range(-2, 3):
				if x + dx >= 0 and x + dx < 50 and y + dy >= 0 and y + dy < 50:
					spinner_image.set_pixel(x + dx, y + dy, Color(1, 1, 1, 0.8))
	
	var spinner_texture = ImageTexture.new()
	spinner_texture.set_image(spinner_image)
	loading_spinner.texture = spinner_texture

func _process(delta):
	# Animate loading spinner
	if loading_overlay.visible:
		spinner_rotation += delta * 360  # 1 rotation per second
		if spinner_rotation >= 360:
			spinner_rotation -= 360
		loading_spinner.rotation_degrees = spinner_rotation
	# FPS diupdate langsung di _on_webcam_frame_received agar akurat

func setup_timers():
	# Timer untuk simulasi deteksi (lebih cepat)
	detection_timer = Timer.new()
	detection_timer.wait_time = 0.05  # Lebih cepat
	detection_timer.timeout.connect(_on_detection_progress)
	add_child(detection_timer)
	
	# Timer untuk redirect
	redirect_timer = Timer.new()
	redirect_timer.wait_time = 30.0
	redirect_timer.timeout.connect(_on_redirect_to_scene)
	redirect_timer.one_shot = true
	add_child(redirect_timer)

func reset_ui():
	progress_bar.value = 0
	detection_progress = 0.0
	is_detecting = false
	result_container.visible = false
	status_label.text = "Mencari wajah..."
	start_button.text = "Mulai Deteksi"
	face_frame.border_color = Color(0, 1, 0, 0)
	if skip_to_map_button:
		skip_to_map_button.visible = false
	if fps_label:
		fps_label.text = "FPS: 0.0"
	if confidence_label:
		confidence_label.text = "Confidence: 0%"

func _on_start_detection_pressed():
	if not is_detecting:
		start_detection()
	else:
		stop_detection()

func start_detection():
	is_detecting = true
	start_button.text = "Hentikan Deteksi"
	result_container.visible = false
	detection_progress = 0.0
	progress_bar.value = 0
	status_label.text = "Mendeteksi wajah..."
	face_frame.border_color = Color(1, 1, 0, 0.8)
	
	# Send DETECTION_REQUEST command to ML server
	if webcam_manager and webcam_manager.has_method("send_detection_request"):
		print("🔍 Sending DETECTION_REQUEST to ML server...")
		webcam_manager.send_detection_request()
	else:
		print("⚠️ Webcam manager not available for detection request")
	
	detection_timer.start()

func stop_detection():
	is_detecting = false
	start_button.text = "Mulai Deteksi"
	detection_timer.stop()
	reset_ui()

func _on_detection_progress():
	if not is_detecting:
		return
	
	# Progress lebih cepat
	detection_progress += randf_range(2.0, 4.0)
	progress_bar.value = min(detection_progress, 100.0)
	
	if detection_progress >= 100.0:
		detection_complete()

func detection_complete():
	detection_timer.stop()
	is_detecting = false
	
	# Simulasi hasil deteksi (random)
	var ethnicity_names = ethnicity_data.keys()
	detected_ethnicity_result = ethnicity_names[randi() % ethnicity_names.size()]
	
	# Update UI dengan hasil
	face_frame.border_color = Color(0, 1, 0, 0.8)
	status_label.text = "Deteksi berhasil!"
	ethnicity_label.text = "Etnis Terdeteksi: " + detected_ethnicity_result
	description_label.text = ethnicity_data[detected_ethnicity_result]["description"]
	
	result_container.visible = true
	start_button.visible = false

	# Tampilkan tombol skip ke map
	if skip_to_map_button:
		skip_to_map_button.visible = true
	
	# Update navigation to include skip button
	update_navigation_buttons()
	
	# Simulasi confidence random antara 80-99%
	var confidence = randi() % 20 + 80
	if confidence_label:
		confidence_label.text = "Confidence: %d%%" % confidence
	
	# Mulai countdown redirect (30 detik)
	redirect_timer.start()
	redirect_label.text = "Mengarahkan ke region budaya yang sesuai dalam 30 detik..."
	
	# Animate countdown
	create_countdown_animation()

func _on_skip_to_map_pressed():
	# Langsung redirect ke scene map sesuai hasil deteksi
	if detected_ethnicity_result != "":
		loading_overlay.visible = true
		spinner_rotation = 0.0
		var target_scene = ethnicity_data[detected_ethnicity_result]["scene"]
		cleanup_resources()
		get_tree().change_scene_to_file(target_scene)

func create_countdown_animation():
	var countdown_timer = Timer.new()
	countdown_timer.wait_time = 1.0
	add_child(countdown_timer)
	
	var countdown_data = [30]  # Mulai dari 30 detik
	countdown_timer.timeout.connect(func():
		countdown_data[0] -= 1
		if countdown_data[0] > 0:
			redirect_label.text = "Mengarahkan ke region budaya yang sesuai dalam " + str(countdown_data[0]) + " detik..."
		else:
			redirect_label.text = "Memuat pengalaman budaya..."
			countdown_timer.queue_free()
	)
	countdown_timer.start()

func _on_redirect_to_scene():
	# Tampilkan loading overlay dengan animasi
	loading_overlay.visible = true
	spinner_rotation = 0.0
	
	# Gunakan hasil deteksi yang sudah disimpan
	var target_scene = ethnicity_data[detected_ethnicity_result]["scene"]
	
	# Loading animation yang lebih smooth
	var loading_steps = [
		"Memuat aset budaya...",
		"Menyiapkan pengalaman virtual...",
		"Menginisialisasi environment...",
		"Hampir selesai..."
	]
	
	for i in range(loading_steps.size()):
		$LoadingOverlay/LoadingContainer/LoadingLabel.text = loading_steps[i]
		await get_tree().create_timer(0.5).timeout
	
	# Pindah ke scene
	cleanup_resources()
	get_tree().change_scene_to_file(target_scene)

func _on_back_pressed():
	cleanup_resources()
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")

func cleanup_resources():
	"""Bersihkan resources sebelum keluar"""
	print("=== Cleaning up resources ===")
	
	if webcam_manager:
		print("Disconnecting webcam manager...")
		if webcam_manager.has_method("disconnect_from_server"):
			webcam_manager.disconnect_from_server()
		if is_inside_tree():
			webcam_manager.queue_free()
		webcam_manager = null
	
	if detection_timer:
		detection_timer.stop()
	
	if redirect_timer:
		redirect_timer.stop()
	
	print("Cleanup complete")

func setup_navigation():
	"""Setup keyboard/joystick navigation for buttons"""
	buttons = [start_button, back_button]
	current_button_index = 0
	update_button_focus()
	
	# Set initial focus
	start_button.grab_focus()
	print("🎮 EthnicityDetection navigation setup completed")

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
	"""Navigate left (for horizontal layouts)"""
	navigate_up()

func navigate_right():
	"""Navigate right (for horizontal layouts)"""
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
	_on_back_pressed()

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

func update_navigation_buttons():
	"""Update which buttons are available for navigation"""
	buttons.clear()
	
	# Always include start and back buttons
	buttons.append(start_button)
	buttons.append(back_button)
	
	# Add skip button if it's visible
	if skip_to_map_button and skip_to_map_button.visible:
		buttons.append(skip_to_map_button)
	
	# Ensure current index is valid
	if current_button_index >= buttons.size():
		current_button_index = 0
	
	update_button_focus()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		cleanup_resources()
