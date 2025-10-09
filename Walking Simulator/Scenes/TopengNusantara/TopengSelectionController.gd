extends Control

@onready var pilih_button = $MainContainer/ButtonContainer/PilihButton
@onready var back_button = $MainContainer/ButtonContainer/BackButton

# Mask buttons
@onready var face1_button = $MainContainer/MaskContainer/GridContainer/Face1Container/Face1Button
@onready var face2_button = $MainContainer/MaskContainer/GridContainer/Face2Container/Face2Button
@onready var face3_button = $MainContainer/MaskContainer/GridContainer/Face3Container/Face3Button
@onready var face4_button = $MainContainer/MaskContainer/GridContainer/Face4Container/Face4Button
@onready var face5_button = $MainContainer/MaskContainer/GridContainer/Face5Container/Face5Button
@onready var face6_button = $MainContainer/MaskContainer/GridContainer/Face6Container/Face6Button
@onready var face7_button = $MainContainer/MaskContainer/GridContainer/Face7Container/Face7Button
@onready var custom_button = $MainContainer/MaskContainer/GridContainer/CustomContainer/CustomButton

var selected_mask_id: int = -1
var is_custom_selected: bool = false
var mask_buttons: Array[Button] = []

# Navigation System
var buttons: Array[Button] = []
var current_button_index: int = 0
var navigation_enabled: bool = true
var last_navigation_time: float = 0.0
var navigation_cooldown: float = 0.2

func _ready():
	print("=== TopengSelectionController._ready() ===")
	
	# Store all mask buttons in array for easier management
	mask_buttons = [face1_button, face2_button, face3_button, face4_button, face5_button, face6_button, face7_button, custom_button]
	
	# Verify all buttons are properly loaded
	for i in range(mask_buttons.size()):
		if mask_buttons[i] == null:
			print("ERROR: Button %d is null!" % (i + 1))
		else:
			print("Button %d loaded successfully" % (i + 1))
	
	# Setup navigation
	setup_navigation()
	
	# Initially disable the Pilih button until something is selected
	pilih_button.disabled = true
	print("Pilih button initially disabled: %s" % pilih_button.disabled)
	
	# Set custom button appearance
	custom_button.text = "+"
	
	print("Topeng Selection scene initialized")

func _on_face_button_pressed(face_id: int):
	"""Handle preset face button press"""
	print("Face %d button pressed" % face_id)
	
	selected_mask_id = face_id
	is_custom_selected = false
	
	# Update button appearances
	update_button_selection()
	
	# Enable the Pilih button
	pilih_button.disabled = false
	print("Pilih button enabled - disabled status: %s" % pilih_button.disabled)

func _on_custom_button_pressed():
	"""Handle custom button press"""
	print("Custom button pressed")
	
	selected_mask_id = -1
	is_custom_selected = true
	
	# Update button appearances
	update_button_selection()
	
	# Enable the Pilih button
	pilih_button.disabled = false
	print("Pilih button enabled for custom - disabled status: %s" % pilih_button.disabled)

func update_button_selection():
	"""Update visual appearance of buttons to show selection"""
	# Reset all buttons to normal appearance
	for button in mask_buttons:
		button.modulate = Color.WHITE
	
	# Highlight selected button
	if is_custom_selected:
		custom_button.modulate = Color.GREEN
		print("Custom button highlighted")
	elif selected_mask_id > 0 and selected_mask_id <= 7:
		mask_buttons[selected_mask_id - 1].modulate = Color.GREEN
		print("Face %d button highlighted" % selected_mask_id)

func _on_pilih_button_pressed():
	"""Handle Pilih button press"""
	print("=== Pilih button pressed ===")
	print("is_custom_selected: %s" % is_custom_selected)
	print("selected_mask_id: %d" % selected_mask_id)
	
	if is_custom_selected:
		print("Going to customization scene")
		# Pass data that this came from custom selection
		Global.selected_mask_type = "custom"
		Global.selected_mask_id = -1
		get_tree().change_scene_to_file("res://Scenes/TopengNusantara/TopengCustomizationScene.tscn")
	elif selected_mask_id > 0:
		print("Going to webcam scene with mask ID: %d" % selected_mask_id)
		# Pass data that this is a preset mask
		Global.selected_mask_type = "preset"
		Global.selected_mask_id = selected_mask_id
		get_tree().change_scene_to_file("res://Scenes/TopengNusantara/TopengWebcamScene.tscn")
	else:
		print("No mask selected - this should not happen")

func _on_back_button_pressed():
	"""Return to main menu"""
	print("Back button pressed - returning to main menu")
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")

func setup_navigation():
	"""Setup keyboard/joystick navigation for buttons"""
	# Include all mask buttons and bottom buttons
	buttons.clear()
	buttons.append_array(mask_buttons)
	buttons.append(pilih_button)
	buttons.append(back_button)
	current_button_index = 0
	update_button_focus()
	
	# Set initial focus
	face1_button.grab_focus()
	print("🎮 TopengSelection navigation setup completed with " + str(buttons.size()) + " buttons")

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
	
	# Special grid navigation logic for mask buttons
	var current_button = buttons[current_button_index]
	if current_button in mask_buttons:
		# If we're in the grid, navigate up in the grid
		var grid_index = mask_buttons.find(current_button)
		if grid_index >= 4:  # Bottom row (Face 5-7, Custom)
			current_button_index = mask_buttons.find(mask_buttons[grid_index - 4])
		else:
			# If we're in top row, go to bottom buttons
			current_button_index = buttons.find(pilih_button)
	else:
		# If we're in bottom buttons, go to last row of grid
		current_button_index = buttons.find(face5_button)  # First button of bottom row
	
	update_button_focus()
	last_navigation_time = current_time

func navigate_down():
	"""Navigate to next button"""
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_navigation_time < navigation_cooldown:
		return
	
	if buttons.size() == 0:
		return
	
	# Special grid navigation logic for mask buttons
	var current_button = buttons[current_button_index]
	if current_button in mask_buttons:
		# If we're in the grid, navigate down in the grid
		var grid_index = mask_buttons.find(current_button)
		if grid_index < 4:  # Top row (Face 1-4)
			current_button_index = mask_buttons.find(mask_buttons[grid_index + 4])
		else:
			# If we're in bottom row, go to bottom buttons
			current_button_index = buttons.find(pilih_button)
	else:
		# If we're in bottom buttons, go to first row of grid
		current_button_index = buttons.find(face1_button)
	
	update_button_focus()
	last_navigation_time = current_time

func navigate_left():
	"""Navigate left in grid or to previous button"""
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_navigation_time < navigation_cooldown:
		return
	
	if buttons.size() == 0:
		return
	
	var current_button = buttons[current_button_index]
	if current_button in mask_buttons:
		# Grid navigation - move left within the same row
		var grid_index = mask_buttons.find(current_button)
		if grid_index % 4 > 0:  # Not in first column
			current_button_index = mask_buttons.find(mask_buttons[grid_index - 1])
		else:
			# Wrap to last column of same row
			var row_start = (grid_index / 4) * 4
			current_button_index = mask_buttons.find(mask_buttons[row_start + 3])
	else:
		# Bottom buttons - move left
		if current_button == back_button:
			current_button_index = buttons.find(pilih_button)
		else:
			current_button_index = buttons.find(back_button)
	
	update_button_focus()
	last_navigation_time = current_time

func navigate_right():
	"""Navigate right in grid or to next button"""
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_navigation_time < navigation_cooldown:
		return
	
	if buttons.size() == 0:
		return
	
	var current_button = buttons[current_button_index]
	if current_button in mask_buttons:
		# Grid navigation - move right within the same row
		var grid_index = mask_buttons.find(current_button)
		if grid_index % 4 < 3:  # Not in last column
			current_button_index = mask_buttons.find(mask_buttons[grid_index + 1])
		else:
			# Wrap to first column of same row
			var row_start = (grid_index / 4) * 4
			current_button_index = mask_buttons.find(mask_buttons[row_start])
	else:
		# Bottom buttons - move right
		if current_button == pilih_button:
			current_button_index = buttons.find(back_button)
		else:
			current_button_index = buttons.find(pilih_button)
	
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
	"""Handle escape/back button"""
	_on_back_button_pressed()

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
