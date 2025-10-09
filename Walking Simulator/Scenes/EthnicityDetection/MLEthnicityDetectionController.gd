extends Control

@onready var status_label = $MainContainer/StatusContainer/StatusLabel
@onready var progress_bar = $MainContainer/StatusContainer/ProgressBar
@onready var result_container = $MainContainer/ResultContainer
@onready var ethnicity_label = $MainContainer/ResultContainer/EthnicityLabel
@onready var description_label = $MainContainer/ResultContainer/DescriptionLabel
@onready var redirect_label = $MainContainer/ResultContainer/RedirectLabel
@onready var start_button = $MainContainer/ButtonContainer/StartDetectionButton
@onready var loading_overlay = $LoadingOverlay
@onready var face_frame = $MainContainer/CameraContainer/WebcamContainer/WebcamFeed/DetectionOverlay/FaceFrame
@onready var webcam_feed = $MainContainer/CameraContainer/WebcamContainer/WebcamFeed
@onready var camera_status_label = $MainContainer/CameraContainer/WebcamContainer/WebcamFeed/CameraStatusLabel
@onready var loading_spinner = $LoadingOverlay/LoadingContainer/LoadingSpinner
@onready var fps_label = $MainContainer/CameraContainer/WebcamContainer/FPSLabel
@onready var confidence_label = $MainContainer/ResultContainer/ConfidenceLabel
@onready var skip_to_map_button = $MainContainer/ButtonContainer/SkipToMapButton

# ML Model Selection UI (optional - may not exist in scene)
@onready var model_selection_container = get_node_or_null("MainContainer/ModelSelectionContainer")
@onready var model_dropdown = get_node_or_null("MainContainer/ModelSelectionContainer/ModelDropdown")
@onready var model_info_label = get_node_or_null("MainContainer/ModelSelectionContainer/ModelInfoLabel")

# ML Webcam Manager
var ml_webcam_manager: Node  # For video streaming (WebcamManagerUDP)
var ml_detection_manager: Node  # For ML detection (MLWebcamManager)

var detection_timer: Timer
var redirect_timer: Timer
var fallback_timer: SceneTreeTimer
var detection_progress: float = 0.0
var is_detecting: bool = false
var detected_ethnicity_result: String = ""
var detected_confidence: float = 0.0
var current_ml_model: String = "glcm_lbp_hog_hsv"
var spinner_rotation: float = 0.0
var webcam_frames_received: int = 0
var last_frame_time: float = 0.0
var current_fps: float = 0.0

# ML Detection state
var ml_detection_active: bool = false
var last_ml_result: Dictionary = {}
var detection_attempts: int = 0
var max_detection_attempts: int = 3  # Reduced from 10 to prevent spam
var simulation_fallback_enabled: bool = false  # Prevent continuous simulation

# Available ML models
var available_models = {
	"glcm_lbp_hog_hsv": "GLCM + LBP + HOG + HSV (Best)",
	"glcm_lbp_hog": "GLCM + LBP + HOG",
	"glcm_hog": "GLCM + HOG",
	"hog": "HOG Only",
	"glcm": "GLCM Only", 
	"lbp": "LBP Only",
	"hsv": "HSV Only"
}

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
		"scene": "res://Scenes/IndonesiaTimur/PapuaScene_Manual.tscn"
	}
}

func _ready():
	print("=== ML EthnicityDetectionController._ready() ===")
	print("Setting up ML-enhanced ethnicity detection...")
	
	setup_ml_webcam_manager()
	setup_model_selection()
	setup_timers()
	reset_ui()
	setup_loading_spinner()

	# Inisialisasi label FPS dan confidence
	if fps_label:
		fps_label.text = "FPS: 0.0"
	if confidence_label:
		confidence_label.text = "Confidence: 0%"

func setup_ml_webcam_manager():
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
	
	# Use Clean Webcam Manager (based on Topeng but for ML server)
	var webcam_script = load("res://Scenes/EthnicityDetection/WebcamClient/CleanWebcamManager.gd")
	if webcam_script == null:
		print("❌ Error: Could not load CleanWebcamManager.gd")
		camera_status_label.text = "❌ Clean Webcam Script tidak ditemukan"
		camera_status_label.modulate = Color(1, 0, 0, 0.9)
		return
	
	print("Creating CleanWebcamManager instance (Camera 0, ML Server)...")
	ml_webcam_manager = webcam_script.new()
	add_child(ml_webcam_manager)
	
	# Load MLWebcamManager separately for detection only
	var ml_script = load("res://Scenes/EthnicityDetection/WebcamClient/MLWebcamManager.gd")
	if ml_script:
		print("Creating MLWebcamManager instance for detection...")
		var ml_manager = ml_script.new()
		ml_manager.name = "MLDetectionManager"
		add_child(ml_manager)
		ml_detection_manager = ml_manager
	
	# Connect WebcamManagerUDP signals (for video streaming)
	print("Connecting WebcamManagerUDP signals...")
	if ml_webcam_manager.has_signal("frame_received"):
		ml_webcam_manager.frame_received.connect(_on_webcam_frame_received)
		print("✅ frame_received signal connected")
	
	if ml_webcam_manager.has_signal("connection_changed"):
		ml_webcam_manager.connection_changed.connect(_on_webcam_connection_changed)
		print("✅ connection_changed signal connected")
	
	if ml_webcam_manager.has_signal("error_message"):
		ml_webcam_manager.error_message.connect(_on_webcam_error)
		print("✅ error_message signal connected")
	
	# Connect MLWebcamManager signals (for detection only)
	if ml_detection_manager and ml_detection_manager.has_signal("detection_result_received"):
		ml_detection_manager.detection_result_received.connect(_on_ml_detection_result)
		print("✅ detection_result_received signal connected")
		
	# Update status
	camera_status_label.text = "🔗 Menghubungkan ke ML server (Camera 0) untuk video..."
	camera_status_label.modulate = Color(1, 1, 0, 0.8)
	
	# Coba koneksi ke ML webcam server
	print("Attempting ML connection to webcam server...")
	ml_webcam_manager.connect_to_webcam_server()
	
	# Also connect the ML detection manager
	if ml_detection_manager:
		print("Connecting ML detection manager to server...")
		ml_detection_manager.connect_to_webcam_server()
	
	print("MLWebcamManager setup complete")

func setup_model_selection():
	"""Setup ML model selection UI"""
	if not model_dropdown:
		print("⚠️ Model dropdown not found, skipping model selection setup")
		return
	
	# Populate dropdown with available models
	model_dropdown.clear()
	for model_id in available_models.keys():
		model_dropdown.add_item(available_models[model_id], model_id)
	
	# Set default model
	model_dropdown.selected = 0
	current_ml_model = model_dropdown.get_item_id(0)
	
	# Connect signal
	model_dropdown.item_selected.connect(_on_model_selected)
	
	# Update info label
	if model_info_label:
		model_info_label.text = "Model: " + available_models[current_ml_model]
	
	print("✅ Model selection setup complete")

func _on_model_selected(index: int):
	"""Handle model selection change"""
	var model_id = model_dropdown.get_item_id(index)
	current_ml_model = model_id
	
	if model_info_label:
		model_info_label.text = "Model: " + available_models[model_id]
	
	# Send model selection to ML server
	if ml_webcam_manager and ml_webcam_manager.get_connection_status():
		ml_webcam_manager.select_model(model_id)
		print("🧠 Model changed to: " + model_id)

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
		camera_status_label.text = "🎥 ML Webcam aktif"
		camera_status_label.modulate = Color(0, 1, 0, 0.8)
		
		# Hide status after 2 seconds
		await get_tree().create_timer(2.0).timeout
		if camera_status_label:
			camera_status_label.visible = false

func _on_webcam_connection_changed(connected: bool):
	"""Callback ketika status koneksi webcam berubah"""
	if connected:
		camera_status_label.text = "🎥 ML webcam terhubung"
		camera_status_label.modulate = Color(0, 1, 0, 0.9)
		print("🎉 ML webcam server connected successfully")
	else:
		camera_status_label.text = "❌ ML koneksi terputus"
		camera_status_label.modulate = Color(1, 0, 0, 0.9)
		print("⛓️‍💥 ML webcam server disconnected")

func _on_webcam_error(message: String):
	"""Callback ketika terjadi error webcam"""
	camera_status_label.text = "❌ Error: " + message
	camera_status_label.modulate = Color(1, 0, 0, 0.9)
	camera_status_label.visible = true
	print("ML Webcam Error: " + message)

func _on_ml_detection_result(ethnicity: String, confidence: float, model: String):
	"""Handle ML detection result"""
	# Reduce spam - only print every 5th result or when actively detecting
	if detection_attempts % 5 == 0 or is_detecting:
		print("🧠 ML Detection: %s (%.2f%%) using %s" % [ethnicity, confidence * 100, model])
	
	last_ml_result = {
		"ethnicity": ethnicity,
		"confidence": confidence,
		"model": model,
		"timestamp": Time.get_ticks_msec() / 1000.0
	}
	
	# Update confidence label with model name
	if confidence_label:
		confidence_label.text = "Confidence: %.1f%% (ML Model: %s)" % [confidence * 100, model]
	
	# If we're actively detecting and got a good result, complete detection
	if is_detecting and confidence > 0.6:  # Minimum 60% confidence
		detection_complete_ml(ethnicity, confidence)
	elif is_detecting:
		detection_attempts += 1
		if detection_attempts >= max_detection_attempts and not simulation_fallback_enabled:
			# Fallback to simulation if ML fails (only once)
			simulation_fallback_enabled = true
			detection_complete_simulation()

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

func setup_timers():
	# Timer untuk simulasi deteksi (fallback)
	detection_timer = Timer.new()
	detection_timer.wait_time = 0.05
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
	detection_attempts = 0
	simulation_fallback_enabled = false  # Reset simulation fallback flag
	result_container.visible = false
	status_label.text = "Mencari wajah..."
	start_button.text = "Mulai Deteksi ML"
	face_frame.border_color = Color(0, 1, 0, 0)
	if skip_to_map_button:
		skip_to_map_button.visible = false
	if fps_label:
		fps_label.text = "FPS: 0.0"
	if confidence_label:
		confidence_label.text = "Confidence: 0%"

func _on_start_detection_pressed():
	if not is_detecting:
		start_ml_detection()
	else:
		stop_detection()

func start_ml_detection():
	is_detecting = true
	start_button.text = "Hentikan Deteksi"
	result_container.visible = false
	detection_progress = 0.0
	detection_attempts = 0
	progress_bar.value = 0
	status_label.text = "🧠 Mendeteksi dengan ML..."
	face_frame.border_color = Color(1, 1, 0, 0.8)
	
	# Send detection request to ML server only when button is clicked
	if ml_detection_manager and ml_detection_manager.has_method("send_detection_request"):
		print("🔍 Sending manual detection request to ML server...")
		ml_detection_manager.send_detection_request()
	else:
		print("⚠️ ML detection manager not available for detection request")
	
	# Start fallback timer in case ML fails
	detection_timer.start()
	
	print("🧠 Starting ML ethnicity detection...")

func stop_detection():
	is_detecting = false
	start_button.text = "Mulai Deteksi ML"
	detection_timer.stop()
	reset_ui()

func _on_detection_progress():
	"""Fallback detection progress (simulation)"""
	if not is_detecting:
		return
	
	# Progress lebih cepat
	detection_progress += randf_range(2.0, 4.0)
	progress_bar.value = min(detection_progress, 100.0)
	
	# If ML hasn't provided result and we've been trying too long, use simulation (only once)
	# Wait longer for ML results - only fallback after 100% progress is reached
	if detection_progress >= 100.0 and detection_attempts >= max_detection_attempts and not simulation_fallback_enabled:
		simulation_fallback_enabled = true  # Prevent multiple simulation fallbacks
		# Start a delay timer to give ML server time to respond
		fallback_timer = get_tree().create_timer(3.0)
		fallback_timer.timeout.connect(_on_fallback_timeout)

func _on_fallback_timeout():
	"""Called when fallback timer expires - use simulation if still detecting"""
	if is_detecting:
		print("⏰ Fallback timeout reached, using simulation detection")
		detection_complete_simulation()

func detection_complete_ml(ethnicity: String, confidence: float):
	"""Complete detection with ML result"""
	detection_timer.stop()
	is_detecting = false
	
	# Cancel any pending fallback timer since we got a real ML result
	if simulation_fallback_enabled:
		simulation_fallback_enabled = false
	
	detected_ethnicity_result = ethnicity
	detected_confidence = confidence
	
	# Update UI dengan hasil ML
	face_frame.border_color = Color(0, 1, 0, 0.8)
	status_label.text = "🧠 Deteksi ML berhasil!"
	ethnicity_label.text = "Etnis Terdeteksi: " + ethnicity
	description_label.text = ethnicity_data[ethnicity]["description"]
	
	result_container.visible = true
	start_button.visible = false

	# Tampilkan tombol skip ke map
	if skip_to_map_button:
		skip_to_map_button.visible = true
	
	# Update confidence label with model name
	if confidence_label:
		confidence_label.text = "Confidence: %.1f%% (ML Model: %s)" % [confidence * 100, current_ml_model]
	
	# Mulai countdown redirect (30 detik)
	redirect_timer.start()
	redirect_label.text = "Mengarahkan ke region budaya yang sesuai dalam 30 detik..."
	
	# Animate countdown
	create_countdown_animation()
	
	print("✅ ML Detection completed: %s (%.2f%%)" % [ethnicity, confidence * 100])

func detection_complete_simulation():
	"""Fallback to simulation-based detection"""
	detection_timer.stop()
	is_detecting = false
	
	# Simulasi hasil deteksi (random)
	var ethnicity_names = ethnicity_data.keys()
	detected_ethnicity_result = ethnicity_names[randi() % ethnicity_names.size()]
	detected_confidence = randf_range(0.6, 0.9)  # Random confidence 60-90%
	
	# Update UI dengan hasil simulasi
	face_frame.border_color = Color(0, 1, 0, 0.8)
	status_label.text = "⚠️ Deteksi simulasi (ML gagal)"
	ethnicity_label.text = "Etnis Terdeteksi: " + detected_ethnicity_result
	description_label.text = ethnicity_data[detected_ethnicity_result]["description"]
	
	result_container.visible = true
	start_button.visible = false

	# Tampilkan tombol skip ke map
	if skip_to_map_button:
		skip_to_map_button.visible = true
	
	# Update confidence label with simulation indicator
	if confidence_label:
		confidence_label.text = "Confidence: %.1f%% (ML Model: simulation)" % (detected_confidence * 100)
	
	# Mulai countdown redirect (30 detik)
	redirect_timer.start()
	redirect_label.text = "Mengarahkan ke region budaya yang sesuai dalam 30 detik..."
	
	# Animate countdown
	create_countdown_animation()
	
	print("⚠️ Fallback to simulation: %s (%.2f%%)" % [detected_ethnicity_result, detected_confidence * 100])

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
	print("=== Cleaning up ML resources ===")
	
	if ml_webcam_manager:
		print("Disconnecting ML webcam manager...")
		if ml_webcam_manager.has_method("disconnect_from_server"):
			ml_webcam_manager.disconnect_from_server()
		if is_inside_tree():
			ml_webcam_manager.queue_free()
		ml_webcam_manager = null
	
	if detection_timer:
		detection_timer.stop()
	
	if redirect_timer:
		redirect_timer.stop()
	
	print("ML cleanup complete")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		cleanup_resources()
