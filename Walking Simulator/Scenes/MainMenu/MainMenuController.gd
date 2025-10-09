class_name MainMenuController
extends Control

# Exhibition title and branding
@export var exhibition_title: String = "Indonesian Cultural Heritage Exhibition"
@export var seminar_info: String = "International Seminar on Indonesian Cultural Diversity"

# Scene references for the three regions
@export var indonesia_barat_scene: PackedScene
@export var indonesia_tengah_scene: PackedScene
@export var indonesia_timur_scene: PackedScene

# 3D Map system
@export var indonesia_3d_map_scene: PackedScene
@export var indonesia_3d_map_final_scene: PackedScene

# Configuration system
@export var indonesia_3d_map_config: Indonesia3DMapConfig

# UI elements - Main Menu
@onready var main_menu_container: VBoxContainer = $MainMenuContainer
@onready var title_label: Label = $MainMenuContainer/TitleLabel
@onready var subtitle_label: Label = $MainMenuContainer/SubtitleLabel
@onready var start_game_button: Button = $MainMenuContainer/MainButtons/StartGameButton
@onready var explore_3d_map_button: Button = $MainMenuContainer/MainButtons/Explore3DMapButton
@onready var topeng_nusantara_button: Button = $MainMenuContainer/MainButtons/TopengNusantaraButton
@onready var load_game_button: Button = $MainMenuContainer/MainButtons/LoadGameButton
@onready var how_to_play_button: Button = $MainMenuContainer/MainButtons/HowToPlayButton
@onready var about_us_button: Button = $MainMenuContainer/MainButtons/AboutUsButton
@onready var credits_button: Button = $MainMenuContainer/MainButtons/CreditsButton
@onready var exit_button: Button = $MainMenuContainer/MainButtons/ExitButton
@onready var instructions_label: Label = $MainMenuContainer/InstructionsLabel

# UI elements - Start Game Submenu
@onready var start_game_submenu: Control = $StartGameSubmenu
@onready var indonesia_barat_button: Button = $StartGameSubmenu/SubmenuContainer/MapContainer/RegionButtons/IndonesiaBaratButton
@onready var indonesia_tengah_button: Button = $StartGameSubmenu/SubmenuContainer/MapContainer/RegionButtons/IndonesiaTengahButton
@onready var indonesia_timur_button: Button = $StartGameSubmenu/SubmenuContainer/MapContainer/RegionButtons/IndonesiaTimurButton
@onready var back_button: Button = $StartGameSubmenu/SubmenuContainer/BackButton
@onready var indonesia_map: TextureRect = $StartGameSubmenu/SubmenuContainer/MapContainer/IndonesiaMap

# UI elements - Other Panels
@onready var how_to_play_panel: Control = $HowToPlayPanel
@onready var about_us_panel: Control = $AboutUsPanel
@onready var credits_panel: Control = $CreditsPanel

# Audio
@onready var button_sound: AudioStreamPlayer = $ButtonSound
var audio_manager: CulturalAudioManagerEnhanced

# Menu Navigation System
var current_menu_level: String = "main"  # "main", "start_game", "how_to_play", "about_us", "credits"
var current_button_index: int = 0
var buttons: Array[Button] = []
var submenu_buttons: Array[Button] = []
var navigation_enabled: bool = true
var last_navigation_time: float = 0.0
var navigation_cooldown: float = 0.2  # Prevent rapid navigation

# Zoom effect variables
var original_map_scale: Vector2 = Vector2.ONE
var zoom_duration: float = 1.0
var is_zooming: bool = false

func _ready():
	# Set up the main menu
	GameLogger.info("🚀 MainMenuController _ready() called")
	setup_menu()
	connect_signals()
	setup_audio_manager()
	setup_button_hover_audio()
	setup_menu_navigation()
	start_background_music()
	GameLogger.info("✅ MainMenuController initialization completed")
	
	# Always show main menu (removed auto-opening of 2D region selection)
	# Since we're using 3D map directly, no need to show 2D region selection
	
	# Set focus to explore map button since start game is hidden
	explore_3d_map_button.grab_focus()
	# Ensure main menu is visible and submenus are hidden
	show_main_menu()
	
	# Store original map scale
	original_map_scale = indonesia_map.scale

func setup_menu():
	# Set exhibition title and info
	title_label.text = exhibition_title
	subtitle_label.text = seminar_info
	
	# Hide start game button - using 3D map directly
	start_game_button.visible = false
	explore_3d_map_button.text = "Explore Indonesia Map"
	load_game_button.text = "Load Game"
	how_to_play_button.text = "How to Play"
	about_us_button.text = "About Us"
	credits_button.text = "Credits"
	
	# Set region button texts
	indonesia_barat_button.text = "Indonesia Barat\nTraditional Market"
	indonesia_tengah_button.text = "Indonesia Tengah\nMount Tambora"
	indonesia_timur_button.text = "Indonesia Timur\nPapua Highlands"
	
	# Set instructions
	instructions_label.text = "Explore Indonesian cultural heritage through interactive experiences"

func setup_menu_navigation():
	"""Setup keyboard/joystick navigation for menu system"""
	# Main menu buttons (excluding hidden start_game_button)
	buttons = [
		explore_3d_map_button,
		topeng_nusantara_button,
		load_game_button,
		how_to_play_button,
		about_us_button,
		credits_button,
		exit_button
	]
	
	# Submenu buttons (region selection)
	submenu_buttons = [
		indonesia_barat_button,
		indonesia_tengah_button,
		indonesia_timur_button,
		back_button
	]
	
	# Set initial focus
	current_button_index = 0
	update_button_focus()
	
	GameLogger.info("🎮 Menu navigation system initialized with " + str(buttons.size()) + " main buttons")

func _input(event):
	"""Handle keyboard and joystick input for menu navigation"""
	if not navigation_enabled:
		return
	
	# Handle keyboard input
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP:
				navigate_up()
				get_viewport().set_input_as_handled()
			KEY_DOWN:
				navigate_down()
				get_viewport().set_input_as_handled()
			KEY_LEFT:
				navigate_left()
				get_viewport().set_input_as_handled()
			KEY_RIGHT:
				navigate_right()
				get_viewport().set_input_as_handled()
			KEY_ENTER, KEY_SPACE:
				activate_current_button()
				get_viewport().set_input_as_handled()
			KEY_ESCAPE:
				handle_escape()
				get_viewport().set_input_as_handled()
	
	# Handle joystick input
	elif event is InputEventJoypadButton and event.pressed:
		match event.button_index:
			JOY_BUTTON_A:  # A button (Xbox style)
				activate_current_button()
				get_viewport().set_input_as_handled()
			JOY_BUTTON_B:  # B button (Xbox style)
				handle_escape()
				get_viewport().set_input_as_handled()
	
	elif event is InputEventJoypadMotion:
		# Handle analog stick movement
		if abs(event.axis_value) > 0.5:  # Dead zone
			match event.axis:
				JOY_AXIS_LEFT_Y:
					if event.axis_value < -0.5:  # Up
						navigate_up()
						get_viewport().set_input_as_handled()
					elif event.axis_value > 0.5:  # Down
						navigate_down()
						get_viewport().set_input_as_handled()
				JOY_AXIS_LEFT_X:
					if event.axis_value < -0.5:  # Left
						navigate_left()
						get_viewport().set_input_as_handled()
					elif event.axis_value > 0.5:  # Right
						navigate_right()
						get_viewport().set_input_as_handled()

func update_button_focus():
	"""Update visual focus on current button"""
	var current_buttons = get_current_button_array()
	if current_buttons.size() == 0:
		return
	
	# Clear focus from all buttons
	for button in current_buttons:
		if button and is_instance_valid(button):
			button.release_focus()
	
	# Set focus to current button
	if current_button_index >= 0 and current_button_index < current_buttons.size():
		var target_button = current_buttons[current_button_index]
		if target_button and is_instance_valid(target_button):
			target_button.grab_focus()
			# Play hover sound
			play_button_sound()

func get_current_button_array() -> Array[Button]:
	"""Get the current button array based on menu level"""
	match current_menu_level:
		"main":
			return buttons
		"start_game":
			return submenu_buttons
		_:
			return []

func navigate_up():
	"""Navigate to previous button"""
	var current_time = Time.get_time_dict_from_system()["unix"]
	if current_time - last_navigation_time < navigation_cooldown:
		return
	
	var current_buttons = get_current_button_array()
	if current_buttons.size() == 0:
		return
	
	current_button_index = (current_button_index - 1 + current_buttons.size()) % current_buttons.size()
	update_button_focus()
	last_navigation_time = current_time

func navigate_down():
	"""Navigate to next button"""
	var current_time = Time.get_time_dict_from_system()["unix"]
	if current_time - last_navigation_time < navigation_cooldown:
		return
	
	var current_buttons = get_current_button_array()
	if current_buttons.size() == 0:
		return
	
	current_button_index = (current_button_index + 1) % current_buttons.size()
	update_button_focus()
	last_navigation_time = current_time

func navigate_left():
	"""Navigate left (for grid layouts)"""
	# For now, same as up since we have vertical layout
	navigate_up()

func navigate_right():
	"""Navigate right (for grid layouts)"""
	# For now, same as down since we have vertical layout
	navigate_down()

func activate_current_button():
	"""Activate the currently focused button"""
	var current_buttons = get_current_button_array()
	if current_buttons.size() == 0:
		return
	
	if current_button_index >= 0 and current_button_index < current_buttons.size():
		var target_button = current_buttons[current_button_index]
		if target_button and is_instance_valid(target_button):
			target_button.emit_signal("pressed")

func handle_escape():
	"""Handle escape/back button"""
	match current_menu_level:
		"main":
			# Show exit dialog
			_on_exit_game_pressed()
		"start_game":
			# Return to main menu
			_on_back_to_main_pressed()
		"how_to_play", "about_us", "credits":
			# Return to main menu
			_on_back_to_main_pressed()

func connect_signals():
	# Main menu buttons
	# Start game button hidden - using 3D map directly
	# if not start_game_button.pressed.is_connected(_on_start_game_pressed):
	#	start_game_button.pressed.connect(_on_start_game_pressed)
	if not explore_3d_map_button.pressed.is_connected(_on_explore_3d_map_pressed):
		explore_3d_map_button.pressed.connect(_on_explore_3d_map_pressed)
	if not load_game_button.pressed.is_connected(_on_load_game_pressed):
		load_game_button.pressed.connect(_on_load_game_pressed)
	if not how_to_play_button.pressed.is_connected(_on_how_to_play_pressed):
		how_to_play_button.pressed.connect(_on_how_to_play_pressed)
	if not about_us_button.pressed.is_connected(_on_about_us_pressed):
		about_us_button.pressed.connect(_on_about_us_pressed)
	if not credits_button.pressed.is_connected(_on_credits_pressed):
		credits_button.pressed.connect(_on_credits_pressed)
	if not exit_button.pressed.is_connected(_on_exit_game_pressed):
		exit_button.pressed.connect(_on_exit_game_pressed)
		GameLogger.info("✅ Connected Exit Game button signal")
	else:
		GameLogger.info("ℹ️ Exit Game button signal already connected")
	
	# Region buttons
	if not indonesia_barat_button.pressed.is_connected(_on_indonesia_barat_pressed):
		indonesia_barat_button.pressed.connect(_on_indonesia_barat_pressed)
	if not indonesia_tengah_button.pressed.is_connected(_on_indonesia_tengah_pressed):
		indonesia_tengah_button.pressed.connect(_on_indonesia_tengah_pressed)
	if not indonesia_timur_button.pressed.is_connected(_on_indonesia_timur_pressed):
		indonesia_timur_button.pressed.connect(_on_indonesia_timur_pressed)
	
	# Back buttons
	if not back_button.pressed.is_connected(_on_back_to_main_pressed):
		back_button.pressed.connect(_on_back_to_main_pressed)

# Main Menu Navigation
# Start game functionality removed - using 3D map directly
# func _on_start_game_pressed():
#	play_button_sound()
#	show_start_game_submenu()

func _on_explore_3d_map_pressed():
	play_button_sound()
	# Stop background music before starting game
	stop_background_music()
	# Longer delay to ensure ambient audio is fully stopped
	await get_tree().create_timer(0.3).timeout
	# No additional audio needed since start_game.ogg was already playing as background
	show_3d_map_final()

func _on_load_game_pressed():
	play_button_sound()
	show_load_game_dialog()

func _on_how_to_play_pressed():
	play_button_sound()
	show_how_to_play_panel()

func _on_about_us_pressed():
	play_button_sound()
	show_about_us_panel()

func _on_credits_pressed():
	play_button_sound()
	show_credits_panel()

func _on_exit_game_pressed():
	play_button_sound()
	GameLogger.info("🔘 Exit Game button pressed - showing unified confirmation dialog")
	UnifiedExitDialog.show_main_menu_exit_dialog()

func _on_ethnicity_detection_pressed():
	play_button_sound()
	# Stop background music when leaving main menu
	stop_background_music()
	GameLogger.info("🔍 Ethnicity Detection button pressed - navigating to ethnicity detection")
	get_tree().change_scene_to_file("res://Scenes/EthnicityDetection/EthnicityDetectionScene.tscn")

func _on_topeng_nusantara_pressed():
	play_button_sound()
	# Stop background music when leaving main menu
	stop_background_music()
	GameLogger.info("🎭 Topeng Nusantara button pressed - navigating to mask selection")
	get_tree().change_scene_to_file("res://Scenes/TopengNusantara/TopengSelectionScene.tscn")

func show_load_game_dialog():
	# Check if save data exists
	if has_node("/root/GameSceneManager"):
		var scene_manager = get_node("/root/GameSceneManager")
		if scene_manager and scene_manager.has_save_data():
			# Show load confirmation with save info
			show_load_confirmation()
		else:
			# Show no save data message
			show_no_save_data_message()
	else:
		show_no_save_data_message()

func show_load_confirmation():
	# Disable navigation when dialog is shown
	navigation_enabled = false
	
	var scene_manager = get_node("/root/GameSceneManager")
	var last_region = scene_manager.get_last_region()
	var last_save_time = scene_manager.get_last_save_time()
	
	GameLogger.info("🔧 Creating load game confirmation dialog...")
	var popup = ConfirmationDialog.new()
	popup.dialog_text = "Load last checkpoint?\n\nRegion: " + last_region + "\nSaved: " + last_save_time
	popup.title = "Load Game"
	
	# ConfirmationDialog automatically has OK (Yes) and Cancel (No) buttons
	popup.get_ok_button().text = "Yes"
	popup.get_cancel_button().text = "No"
	
	# Apply button theme
	var button_theme = load("res://Resources/Themes/MenuButtonTheme.tres")
	if button_theme:
		popup.get_ok_button().theme = button_theme
		popup.get_cancel_button().theme = button_theme
		GameLogger.info("🎨 Applied MenuButtonTheme to load dialog buttons")
	
	# Ensure mouse is visible for dialog interaction
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	popup.confirmed.connect(_on_load_confirmed)
	popup.canceled.connect(_on_load_canceled)
	popup.tree_exited.connect(_on_dialog_closed)
	
	add_child(popup)
	popup.popup_centered()
	GameLogger.info("✅ Load game dialog shown")

func show_no_save_data_message():
	var popup = AcceptDialog.new()
	popup.dialog_text = "No save data found.\nStart a new game to create a checkpoint."
	popup.title = "No Save Data"
	popup.add_button("OK", true, "ok")
	
	# Apply button theme
	var button_theme = load("res://Resources/Themes/MenuButtonTheme.tres")
	if button_theme:
		popup.get_ok_button().theme = button_theme
		popup.get_button(1).theme = button_theme  # Custom "OK" button
		GameLogger.info("🎨 Applied MenuButtonTheme to no save dialog buttons")
	
	popup.confirmed.connect(_on_no_save_confirmed)
	popup.custom_action.connect(_on_no_save_confirmed)
	
	add_child(popup)
	popup.popup_centered()

func _on_load_confirmed():
	# User chose Yes - load the checkpoint
	GameLogger.info("✅ User chose YES on load dialog - loading checkpoint")
	load_last_checkpoint()

func _on_load_canceled():
	# User chose No - close dialog and stay in main menu
	GameLogger.info("✅ User chose NO on load dialog - staying in main menu")
	# Dialog automatically closes, no action needed

func _on_no_save_confirmed(_action: String):
	# Ensure the dialog is freed before proceeding
	var dialog = get_parent()
	if dialog is AcceptDialog:
		dialog.queue_free()
	# Return to main menu
	show_main_menu()

func load_last_checkpoint():
	var scene_manager = get_node("/root/GameSceneManager")
	if scene_manager.load_last_checkpoint():
		GameLogger.info("Checkpoint loaded successfully")
	else:
		GameLogger.error("Failed to load checkpoint")
		# Show error message
		var popup = AcceptDialog.new()
		popup.dialog_text = "Failed to load checkpoint.\nPlease try starting a new game."
		popup.title = "Load Error"
		popup.add_button("OK", true, "ok")
		
		popup.confirmed.connect(_on_load_error_confirmed)
		popup.custom_action.connect(_on_load_error_confirmed)
		
		add_child(popup)
		popup.popup_centered()

func _on_load_error_confirmed(_action: String):
	# Ensure the dialog is freed before proceeding
	var dialog = get_parent()
	if dialog is AcceptDialog:
		dialog.queue_free()
	# Return to main menu
	show_main_menu()

func _on_back_to_main_pressed():
	play_button_sound()
	# Play menu close sound
	if audio_manager:
		audio_manager.play_menu_audio("menu_close")
	else:
		GlobalSignals.on_play_menu_audio.emit("menu_close")
	show_main_menu()

# Panel Visibility Management
func show_main_menu():
	main_menu_container.visible = true
	start_game_submenu.visible = false
	how_to_play_panel.visible = false
	about_us_panel.visible = false
	credits_panel.visible = false
	
	# Update navigation state
	current_menu_level = "main"
	current_button_index = 0
	update_button_focus()
	
	# Set focus back to explore map button
	explore_3d_map_button.grab_focus()

func show_start_game_submenu():
	main_menu_container.visible = false
	start_game_submenu.visible = true
	how_to_play_panel.visible = false
	about_us_panel.visible = false
	credits_panel.visible = false
	
	# Update navigation state
	current_menu_level = "start_game"
	current_button_index = 0
	update_button_focus()
	
	indonesia_barat_button.grab_focus()
	
	# Reset map scale when showing submenu
	indonesia_map.scale = original_map_scale
	is_zooming = false

func show_load_game_panel():
	main_menu_container.visible = false
	start_game_submenu.visible = false
	how_to_play_panel.visible = false
	about_us_panel.visible = false
	credits_panel.visible = false

func show_how_to_play_panel():
	main_menu_container.visible = false
	start_game_submenu.visible = false
	how_to_play_panel.visible = true
	about_us_panel.visible = false
	credits_panel.visible = false
	
	# Update navigation state
	current_menu_level = "how_to_play"
	
	# Play panel open sound
	if audio_manager:
		audio_manager.play_menu_audio("menu_open")
	else:
		GlobalSignals.on_play_menu_audio.emit("menu_open")

func show_about_us_panel():
	main_menu_container.visible = false
	start_game_submenu.visible = false
	how_to_play_panel.visible = false
	about_us_panel.visible = true
	credits_panel.visible = false
	
	# Update navigation state
	current_menu_level = "about_us"
	
	# Play panel open sound
	if audio_manager:
		audio_manager.play_menu_audio("menu_open")
	else:
		GlobalSignals.on_play_menu_audio.emit("menu_open")

func show_credits_panel():
	main_menu_container.visible = false
	start_game_submenu.visible = false
	how_to_play_panel.visible = false
	about_us_panel.visible = false
	credits_panel.visible = true
	
	# Update navigation state
	current_menu_level = "credits"
	
	# Play panel open sound
	if audio_manager:
		audio_manager.play_menu_audio("menu_open")
	else:
		GlobalSignals.on_play_menu_audio.emit("menu_open")

func show_3d_map():
	"""Show the original 3D Indonesia map (for learning/reference)"""
	GameLogger.info("Loading original 3D Indonesia Map...")
	
	# Load the original 3D map scene
	if indonesia_3d_map_scene:
		get_tree().change_scene_to_packed(indonesia_3d_map_scene)
	else:
		# Fallback to direct scene loading
		var scene_path = "res://Scenes/MainMenu/Indonesia3DMap.tscn"
		if ResourceLoader.exists(scene_path):
			var global_node := get_node_or_null("/root/Global")
			if global_node:
				global_node.change_scene_with_loading(scene_path)
			else:
				get_tree().change_scene_to_file(scene_path)
		else:
			GameLogger.error("3D Map scene not found: " + scene_path)

func show_3d_map_final():
	"""Show the final working 3D Indonesia map with saved coordinates"""
	GameLogger.info("Loading final 3D Indonesia Map...")
	
	# Load the final 3D map scene
	if indonesia_3d_map_final_scene:
		get_tree().change_scene_to_packed(indonesia_3d_map_final_scene)
	else:
		# Fallback to direct scene loading
		var scene_path = "res://Scenes/MainMenu/Indonesia3DMapFinal.tscn"
		if ResourceLoader.exists(scene_path):
			get_tree().change_scene_to_file(scene_path)
		else:
			GameLogger.error("Final 3D Map scene not found: " + scene_path)
			show_error_message("3D Map not available yet!")

# Region Selection with Zoom Effect
func _on_indonesia_barat_pressed():
	if is_zooming:
		return
	play_button_sound()
	# Stop background music when leaving main menu
	stop_background_music()
	# Longer delay to ensure ambient audio is fully stopped
	await get_tree().create_timer(0.3).timeout
	# Play region selection audio
	if audio_manager:
		audio_manager.play_menu_audio("region_select")
	else:
		GlobalSignals.on_play_menu_audio.emit("region_select")
	zoom_to_region("Indonesia Barat", get_scene_from_config("Indonesia Barat"))

func _on_indonesia_tengah_pressed():
	if is_zooming:
		return
	play_button_sound()
	# Stop background music when leaving main menu
	stop_background_music()
	# Longer delay to ensure ambient audio is fully stopped
	await get_tree().create_timer(0.3).timeout
	# Play region selection audio
	if audio_manager:
		audio_manager.play_menu_audio("region_select")
	else:
		GlobalSignals.on_play_menu_audio.emit("region_select")
	zoom_to_region("Indonesia Tengah", get_scene_from_config("Indonesia Tengah"))

func _on_indonesia_timur_pressed():
	if is_zooming:
		return
	play_button_sound()
	# Stop background music when leaving main menu
	stop_background_music()
	# Longer delay to ensure ambient audio is fully stopped
	await get_tree().create_timer(0.3).timeout
	# Play region selection audio
	if audio_manager:
		audio_manager.play_menu_audio("region_select")
	else:
		GlobalSignals.on_play_menu_audio.emit("region_select")
	zoom_to_region("Indonesia Timur", get_scene_from_config("Indonesia Timur"))

func get_scene_from_config(region_name: String) -> PackedScene:
	"""Get scene from Indonesia3DMapConfig based on region name"""
	if not indonesia_3d_map_config:
		GameLogger.warning("Indonesia3DMapConfig not assigned, using fallback scenes")
		return get_fallback_scene(region_name)

	var region_key = ""
	match region_name:
		"Indonesia Barat": region_key = "indonesia_barat"
		"Indonesia Tengah": region_key = "indonesia_tengah"
		"Indonesia Timur": region_key = "indonesia_timur"
		_:
			GameLogger.warning("Unknown region name: " + region_name)
			return get_fallback_scene(region_name)

	if region_key in indonesia_3d_map_config.region_coordinates:
		var region_data = indonesia_3d_map_config.region_coordinates[region_key]
		if "scene_path" in region_data:
			var scene_path = region_data.scene_path
			if ResourceLoader.exists(scene_path):
				GameLogger.info("Loading scene from config: " + scene_path)
				return load(scene_path)
			else:
				GameLogger.error("Scene file not found: " + scene_path)

	GameLogger.warning("Scene not found in config for region: " + region_name)
	return get_fallback_scene(region_name)

func get_fallback_scene(region_name: String) -> PackedScene:
	"""Fallback scenes if config is not available"""
	match region_name:
		"Indonesia Barat": 
			if ResourceLoader.exists("res://Scenes/IndonesiaBarat/PasarScene.tscn"):
				return load("res://Scenes/IndonesiaBarat/PasarScene.tscn")
		"Indonesia Tengah": 
			if ResourceLoader.exists("res://Scenes/IndonesiaTengah/Tambora/TamboraRoot.tscn"):
				return load("res://Scenes/IndonesiaTengah/Tambora/TamboraRoot.tscn")
		"Indonesia Timur": 
			if ResourceLoader.exists("res://Scenes/IndonesiaTimur/PapuaScene_Manual.tscn"):
				return load("res://Scenes/IndonesiaTimur/PapuaScene_Manual.tscn")
	
	GameLogger.error("Fallback scene not found for region: " + region_name)
	return null

func zoom_to_region(region_name: String, scene: PackedScene):
	is_zooming = true
	
	# Create zoom effect
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Zoom in effect
	tween.tween_property(indonesia_map, "scale", Vector2(2.0, 2.0), zoom_duration * 0.6)
	tween.tween_property(indonesia_map, "modulate", Color(1.2, 1.2, 1.0), zoom_duration * 0.6)
	
	# Wait a moment at zoom level
	await get_tree().create_timer(zoom_duration * 0.4).timeout
	
	# Show loading message
	show_loading_message("Loading " + region_name + "...")
	
	# Wait for loading message
	await get_tree().create_timer(1.0).timeout
	
	# Change scene
	change_scene(scene, region_name)

func change_scene(scene: PackedScene, region_name: String):
	if scene:
		# Store current region for reference
		Global.current_region = region_name
		Global.start_region_session(region_name)
		get_tree().change_scene_to_packed(scene)
	else:
		# Fallback to config-based scene loading
		var scene_path = get_scene_path_from_config(region_name)
		
		if scene_path:
			Global.current_region = region_name
			Global.start_region_session(region_name)
			get_tree().change_scene_to_file(scene_path)
		else:
			GameLogger.warning("Scene not assigned for " + region_name)
			show_error_message("Scene not available yet. Coming soon!")

func get_scene_path_from_config(region_name: String) -> String:
	"""Get scene path from Indonesia3DMapConfig based on region name"""
	if not indonesia_3d_map_config:
		GameLogger.warning("Indonesia3DMapConfig not assigned, using fallback paths")
		return get_fallback_scene_path(region_name)
	
	# Map region names to config keys
	var region_key = ""
	match region_name:
		"Indonesia Barat":
			region_key = "indonesia_barat"
		"Indonesia Tengah":
			region_key = "indonesia_tengah"
		"Indonesia Timur":
			region_key = "indonesia_timur"
		_:
			GameLogger.warning("Unknown region name: " + region_name)
			return get_fallback_scene_path(region_name)
	
	# Get scene path from config
	if region_key in indonesia_3d_map_config.region_coordinates:
		var region_data = indonesia_3d_map_config.region_coordinates[region_key]
		if "scene_path" in region_data:
			GameLogger.info("Using scene path from config: " + region_data.scene_path)
			return region_data.scene_path
	
	GameLogger.warning("Scene path not found in config for region: " + region_name)
	return get_fallback_scene_path(region_name)

func get_fallback_scene_path(region_name: String) -> String:
	"""Fallback scene paths if config is not available"""
	match region_name:
		"Indonesia Barat":
			return "res://Scenes/IndonesiaBarat/PasarScene.tscn"
		"Indonesia Tengah":
			return "res://Scenes/IndonesiaTengah/Tambora/TamboraRoot.tscn"
		"Indonesia Timur":
			return "res://Scenes/IndonesiaTimur/PapuaScene_Manual.tscn"
		_:
			return ""

func play_button_sound():
	# Play button sound using both systems for compatibility
	if button_sound and button_sound.stream:
		button_sound.play()
	
	# Also use the enhanced audio manager if available
	if audio_manager:
		audio_manager.play_menu_audio("button_click")
	else:
		# Fallback to GlobalSignals if audio manager not available
		GlobalSignals.on_play_menu_audio.emit("button_click")

func setup_audio_manager():
	"""Setup audio manager reference"""
	# Try to get audio manager from Global
	if Global.audio_manager:
		audio_manager = Global.audio_manager
		GameLogger.info("🎵 Audio manager connected to MainMenuController")
	else:
		GameLogger.warning("⚠️ Audio manager not found in Global, using fallback signals")

func setup_button_hover_audio():
	"""Setup hover audio for all buttons"""
	var buttons = [
		start_game_button,
		explore_3d_map_button,
		topeng_nusantara_button,
		load_game_button,
		how_to_play_button,
		about_us_button,
		credits_button
	]
	
	for button in buttons:
		if button:
			button.mouse_entered.connect(_on_button_hover)
			GameLogger.debug("🔊 Hover audio connected to: " + button.name)
	
	GameLogger.info("🎵 Button hover audio setup completed")

func _on_button_hover():
	"""Play hover sound when mouse enters button"""
	if audio_manager:
		audio_manager.play_menu_audio("button_hover")
	else:
		# Fallback to direct audio
		GlobalSignals.on_play_menu_audio.emit("button_hover")

func start_background_music():
	"""Start background music for main menu"""
	if audio_manager:
		# Play start_game.ogg as background music for main menu
		audio_manager.play_ambient_audio("start_game")
		GameLogger.info("🎵 Main menu background music started (start_game.ogg)")
	else:
		# Fallback to GlobalSignals
		GlobalSignals.on_play_ambient_audio.emit("start_game")

func stop_background_music():
	"""Stop background music when leaving main menu"""
	if audio_manager:
		# Stop all audio to prevent any overlap
		audio_manager.stop_all_audio()
		GameLogger.info("🎵 Background ambient music stopped")
	else:
		# Fallback - stop all audio
		GlobalSignals.on_stop_all_audio.emit()

func show_loading_message(message: String):
	# Create a simple loading overlay
	var loading_overlay = ColorRect.new()
	loading_overlay.color = Color(0, 0, 0, 0.8)
	loading_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var loading_label = Label.new()
	loading_label.text = message
	loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	loading_label.add_theme_font_size_override("font_size", 24)
	loading_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	loading_overlay.add_child(loading_label)
	add_child(loading_overlay)
	
	# Remove overlay after scene change
	await get_tree().process_frame
	loading_overlay.queue_free()

func show_error_message(message: String):
	# Create error message popup
	var popup = AcceptDialog.new()
	popup.dialog_text = message
	popup.title = "Information"
	add_child(popup)
	popup.popup_centered()

# Keyboard shortcuts for quick access
func _input(event):
	if event.is_action_pressed("ui_accept"):
		# Enter key - activate focused button
		var focused = get_viewport().gui_get_focus_owner()
		if focused and focused is Button:
			focused.pressed.emit()
	
	elif event.is_action_pressed("ui_cancel"):
		# Escape key - navigate to 3D map from region selection, or back to main menu from other panels
		if start_game_submenu.visible:
			# From region selection, go to 3D map
			GameLogger.info("ESC pressed from region selection - navigating to 3D map")
			show_3d_map_final()
		elif how_to_play_panel.visible or about_us_panel.visible or credits_panel.visible:
			# From other panels, go back to main menu
			_on_back_to_main_pressed()
