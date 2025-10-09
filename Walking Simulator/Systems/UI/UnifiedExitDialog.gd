class_name UnifiedExitDialog
extends ConfirmationDialog

## Unified OOP-style exit confirmation dialog system
## Provides consistent exit behavior across all scenes with context-aware navigation

enum ExitContext {
	REGION_TO_3D_MAP,    # From region scenes (Pasar, Tambora, Papua) to 3D Indonesia map
	MAP_3D_TO_MAIN_MENU, # From 3D Indonesia map to main menu
	MAIN_MENU_TO_QUIT,   # From main menu to quit game
	PROTOTYPE_TO_QUIT    # From prototype/test scenes to quit game
}

# Exit configuration
var exit_context: ExitContext
var source_scene_name: String = ""
var target_scene_path: String = ""

# Callbacks for different exit types
var exit_callback: Callable

# Mouse mode management
var previous_mouse_mode: Input.MouseMode

# Static tracking to prevent multiple dialogs
static var active_dialog_instance: UnifiedExitDialog = null

# Navigation System
var buttons: Array[Button] = []
var current_button_index: int = 0
var navigation_enabled: bool = true
var last_navigation_time: float = 0.0
var navigation_cooldown: float = 0.2

func _init():
	# Set up the dialog appearance
	title = "Confirm Exit"
	get_ok_button().text = "Yes"
	get_cancel_button().text = "No"
	
	# Apply button theme
	var button_theme = load("res://Resources/Themes/MenuButtonTheme.tres")
	if button_theme:
		get_ok_button().theme = button_theme
		get_cancel_button().theme = button_theme
		GameLogger.info("🎨 Applied MenuButtonTheme to exit dialog buttons")
	
	# Connect signals
	confirmed.connect(_on_confirmed)
	canceled.connect(_on_canceled)
	
	# Setup navigation after a frame to ensure buttons are ready
	call_deferred("setup_navigation")
	
	GameLogger.info("🔧 UnifiedExitDialog initialized")

## Setup dialog for specific exit context
func setup_exit_dialog(context: ExitContext, source_name: String = "", target_path: String = "", callback: Callable = Callable()):
	exit_context = context
	source_scene_name = source_name
	target_scene_path = target_path
	exit_callback = callback
	
	# Set dialog text based on context
	match context:
		ExitContext.REGION_TO_3D_MAP:
			dialog_text = "Return to Indonesia 3D Map?\nYour progress will be saved."
			title = "Return to Map"
		ExitContext.MAP_3D_TO_MAIN_MENU:
			dialog_text = "Return to Main Menu?\nYour progress will be saved."
			title = "Return to Menu"
		ExitContext.MAIN_MENU_TO_QUIT:
			dialog_text = "Are you sure you want to exit the game?"
			title = "Exit Game"
		ExitContext.PROTOTYPE_TO_QUIT:
			dialog_text = "Exit prototype test?\nReturning to desktop."
			title = "Exit Test"
	
	GameLogger.info("🔧 Exit dialog configured for context: " + str(context))
	GameLogger.info("   Source: " + source_name)
	GameLogger.info("   Target: " + target_path)

## Show the dialog centered on screen
func show_dialog():
	# Prevent multiple dialogs
	if active_dialog_instance and is_instance_valid(active_dialog_instance):
		GameLogger.debug("UnifiedExitDialog already active - ignoring new request")
		return
	
	# Add to current scene tree safely
	var scene_tree = Engine.get_main_loop() as SceneTree
	if not scene_tree:
		GameLogger.error("❌ Could not get SceneTree for dialog")
		return
		
	var current_scene = scene_tree.current_scene
	if current_scene:
		# Store current mouse mode and ensure mouse is visible for dialog interaction
		previous_mouse_mode = Input.get_mouse_mode()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		GameLogger.info("🖱️ Mouse mode set to VISIBLE for dialog interaction (was: " + str(previous_mouse_mode) + ")")
		
		current_scene.add_child(self)
		active_dialog_instance = self
		popup_centered()
		GameLogger.info("✅ Exit dialog shown for context: " + str(exit_context))
	else:
		GameLogger.error("❌ No current scene found for dialog")

func _on_confirmed():
	"""Handle Yes button - execute the exit action"""
	GameLogger.info("✅ User chose YES - executing exit action")
	
	match exit_context:
		ExitContext.REGION_TO_3D_MAP:
			_exit_to_3d_map()
		ExitContext.MAP_3D_TO_MAIN_MENU:
			_exit_to_main_menu()
		ExitContext.MAIN_MENU_TO_QUIT:
			_exit_to_desktop()
		ExitContext.PROTOTYPE_TO_QUIT:
			_exit_to_desktop()
	
	# Clean up dialog
	active_dialog_instance = null
	queue_free()

func _on_canceled():
	"""Handle No button - stay in current scene"""
	GameLogger.info("✅ User chose NO - staying in current scene")
	
	# Restore previous mouse mode when staying in scene
	Input.set_mouse_mode(previous_mouse_mode)
	GameLogger.info("🖱️ Mouse mode restored to: " + str(previous_mouse_mode))
	
	# Re-enable navigation if we're in main menu
	re_enable_main_menu_navigation()
	
	# Execute callback if provided (for custom cancel behavior)
	if exit_callback.is_valid():
		exit_callback.call()
	
	# Clean up dialog
	active_dialog_instance = null
	queue_free()

## Exit action implementations
func _exit_to_3d_map():
	"""Navigate to 3D Indonesia map"""
	GameLogger.info("🗺️ Navigating to 3D Indonesia map...")
	
	var indonesia_3d_map_path = "res://Scenes/MainMenu/Indonesia3DMapFinal.tscn"
	if ResourceLoader.exists(indonesia_3d_map_path):
		get_tree().change_scene_to_file(indonesia_3d_map_path)
	else:
		GameLogger.error("❌ 3D Indonesia map scene not found: " + indonesia_3d_map_path)
		# Fallback to main menu
		_exit_to_main_menu()

func _exit_to_main_menu():
	"""Navigate to main menu"""
	GameLogger.info("🏠 Navigating to main menu...")
	
	var main_menu_path = "res://Scenes/MainMenu/MainMenu.tscn"
	if ResourceLoader.exists(main_menu_path):
		get_tree().change_scene_to_file(main_menu_path)
	else:
		GameLogger.error("❌ Main menu scene not found: " + main_menu_path)

func _exit_to_desktop():
	"""Quit the game"""
	GameLogger.info("🚪 Quitting game...")
	get_tree().quit()

func re_enable_main_menu_navigation():
	"""Re-enable navigation in main menu if we're in the main menu scene"""
	var scene_tree = Engine.get_main_loop() as SceneTree
	if not scene_tree:
		return
		
	var current_scene = scene_tree.current_scene
	if current_scene and current_scene.has_method("_on_dialog_closed"):
		# This is the main menu controller, re-enable navigation
		current_scene._on_dialog_closed()
		GameLogger.info("🎮 Re-enabled main menu navigation")

## Static helper functions for easy usage
static func show_region_exit_dialog(region_name: String):
	"""Show exit dialog for region scenes"""
	var dialog = UnifiedExitDialog.new()
	dialog.setup_exit_dialog(ExitContext.REGION_TO_3D_MAP, region_name)
	dialog.show_dialog()

static func show_3d_map_exit_dialog():
	"""Show exit dialog for 3D map"""
	var dialog = UnifiedExitDialog.new()
	dialog.setup_exit_dialog(ExitContext.MAP_3D_TO_MAIN_MENU, "3D Indonesia Map")
	dialog.show_dialog()

static func show_main_menu_exit_dialog():
	"""Show exit dialog for main menu"""
	var dialog = UnifiedExitDialog.new()
	dialog.setup_exit_dialog(ExitContext.MAIN_MENU_TO_QUIT, "Main Menu")
	dialog.show_dialog()

static func show_prototype_exit_dialog(prototype_name: String):
	"""Show exit dialog for prototype/test scenes"""
	var dialog = UnifiedExitDialog.new()
	dialog.setup_exit_dialog(ExitContext.PROTOTYPE_TO_QUIT, prototype_name)
	dialog.show_dialog()

## Auto-detect context and show appropriate dialog
static func show_context_aware_exit_dialog():
	"""Automatically detect current scene context and show appropriate exit dialog"""
	var scene_tree = Engine.get_main_loop() as SceneTree
	if not scene_tree:
		GameLogger.error("❌ Could not get SceneTree")
		return
		
	var current_scene = scene_tree.current_scene
	if not current_scene:
		GameLogger.error("❌ No current scene found")
		return
	
	var scene_name = current_scene.scene_file_path.get_file().get_basename()
	
	# Determine context based on scene name
	if scene_name in ["PasarScene", "TamboraScene", "PapuaScene", "PapuaScene_Terrain3D"]:
		show_region_exit_dialog(scene_name)
	elif scene_name == "Indonesia3DMapFinal":
		show_3d_map_exit_dialog()
	elif scene_name == "MainMenu":
		show_main_menu_exit_dialog()
	elif scene_name.begins_with("test_") or scene_name.begins_with("Test") or scene_name.contains("Prototype"):
		show_prototype_exit_dialog(scene_name)
	else:
		# Default to prototype behavior for unknown scenes
		show_prototype_exit_dialog(scene_name)

func setup_navigation():
	"""Setup keyboard/joystick navigation for dialog buttons"""
	buttons.clear()
	buttons.append(get_cancel_button())  # "No" button first
	buttons.append(get_ok_button())      # "Yes" button second
	current_button_index = 0
	update_button_focus()
	
	# Set initial focus to "No" button (safer default)
	get_cancel_button().grab_focus()
	GameLogger.info("🎮 UnifiedExitDialog navigation setup completed")

func _input(event):
	"""Handle keyboard and joystick input for dialog navigation"""
	# Check if viewport is still valid
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
				JOY_AXIS_LEFT_X:
					if event.axis_value < -0.5:  # Left
						navigate_left()
						viewport.set_input_as_handled()
					elif event.axis_value > 0.5:  # Right
						navigate_right()
						viewport.set_input_as_handled()

func navigate_left():
	"""Navigate to previous button (No -> Yes -> No)"""
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_navigation_time < navigation_cooldown:
		return
	
	if buttons.size() == 0:
		return
	
	current_button_index = (current_button_index - 1 + buttons.size()) % buttons.size()
	update_button_focus()
	last_navigation_time = current_time

func navigate_right():
	"""Navigate to next button (No -> Yes -> No)"""
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_navigation_time < navigation_cooldown:
		return
	
	if buttons.size() == 0:
		return
	
	current_button_index = (current_button_index + 1) % buttons.size()
	update_button_focus()
	last_navigation_time = current_time

func activate_current_button():
	"""Activate the currently focused button"""
	if buttons.size() == 0:
		return
	
	if current_button_index >= 0 and current_button_index < buttons.size():
		var target_button = buttons[current_button_index]
		if target_button and is_instance_valid(target_button):
			target_button.emit_signal("pressed")

func handle_escape():
	"""Handle escape/back button (same as No)"""
	get_cancel_button().emit_signal("pressed")

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
