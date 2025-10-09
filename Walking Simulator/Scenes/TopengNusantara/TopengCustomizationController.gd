extends Control

@onready var pilih_button = $MainContainer/CustomizationContainer/ButtonContainer/PilihButton
@onready var back_button = $MainContainer/CustomizationContainer/ButtonContainer/BackButton
@onready var preview_text = $MainContainer/PreviewContainer/PreviewPanel/PreviewDisplay/PreviewText

# Base buttons
@onready var base_none_button = $MainContainer/CustomizationContainer/BaseContainer/BaseOptionsContainer/BaseNoneButton
@onready var base1_button = $MainContainer/CustomizationContainer/BaseContainer/BaseOptionsContainer/Base1Button
@onready var base2_button = $MainContainer/CustomizationContainer/BaseContainer/BaseOptionsContainer/Base2Button
@onready var base3_button = $MainContainer/CustomizationContainer/BaseContainer/BaseOptionsContainer/Base3Button

# Mata buttons
@onready var mata_none_button = $MainContainer/CustomizationContainer/MataContainer/MataOptionsContainer/MataNoneButton
@onready var mata1_button = $MainContainer/CustomizationContainer/MataContainer/MataOptionsContainer/Mata1Button
@onready var mata2_button = $MainContainer/CustomizationContainer/MataContainer/MataOptionsContainer/Mata2Button
@onready var mata3_button = $MainContainer/CustomizationContainer/MataContainer/MataOptionsContainer/Mata3Button

# Mulut buttons
@onready var mulut_none_button = $MainContainer/CustomizationContainer/MulutContainer/MulutOptionsContainer/MulutNoneButton
@onready var mulut1_button = $MainContainer/CustomizationContainer/MulutContainer/MulutOptionsContainer/Mulut1Button
@onready var mulut2_button = $MainContainer/CustomizationContainer/MulutContainer/MulutOptionsContainer/Mulut2Button
@onready var mulut3_button = $MainContainer/CustomizationContainer/MulutContainer/MulutOptionsContainer/Mulut3Button

var selected_base: int = -1
var selected_mata: int = -1
var selected_mulut: int = -1

var base_buttons: Array[Button] = []
var mata_buttons: Array[Button] = []
var mulut_buttons: Array[Button] = []

# Navigation System
var buttons: Array[Button] = []
var current_button_index: int = 0
var navigation_enabled: bool = true
var last_navigation_time: float = 0.0
var navigation_cooldown: float = 0.2

func _ready():
	print("=== TopengCustomizationController._ready() ===")
	
	# Store buttons in arrays for easier management (index 0 = None, 1-3 = options)
	base_buttons = [base_none_button, base1_button, base2_button, base3_button]
	mata_buttons = [mata_none_button, mata1_button, mata2_button, mata3_button]
	mulut_buttons = [mulut_none_button, mulut1_button, mulut2_button, mulut3_button]
	
	# Setup navigation
	setup_navigation()
	
	# Initially disable the Pilih button
	pilih_button.disabled = true
	
	# Update preview
	update_preview()
	
	print("Topeng Customization scene initialized")

func _on_base_button_pressed(base_id: int):
	"""Handle base selection"""
	print("Base %d selected" % base_id)
	selected_base = base_id
	
	# Update button appearances for base
	update_base_selection()
	
	# Check if we can enable Pilih button
	check_completion()
	
	# Update preview
	update_preview()

func _on_mata_button_pressed(mata_id: int):
	"""Handle mata selection"""
	print("Mata %d selected" % mata_id)
	selected_mata = mata_id
	
	# Update button appearances for mata
	update_mata_selection()
	
	# Check if we can enable Pilih button
	check_completion()
	
	# Update preview
	update_preview()

func _on_mulut_button_pressed(mulut_id: int):
	"""Handle mulut selection"""
	print("Mulut %d selected" % mulut_id)
	selected_mulut = mulut_id
	
	# Update button appearances for mulut
	update_mulut_selection()
	
	# Check if we can enable Pilih button
	check_completion()
	
	# Update preview
	update_preview()

func update_base_selection():
	"""Update visual appearance of base buttons"""
	for button in base_buttons:
		button.modulate = Color.WHITE
	
	if selected_base >= 0 and selected_base < base_buttons.size():
		base_buttons[selected_base].modulate = Color.GREEN

func update_mata_selection():
	"""Update visual appearance of mata buttons"""
	for button in mata_buttons:
		button.modulate = Color.WHITE
	
	if selected_mata >= 0 and selected_mata < mata_buttons.size():
		mata_buttons[selected_mata].modulate = Color.GREEN

func update_mulut_selection():
	"""Update visual appearance of mulut buttons"""
	for button in mulut_buttons:
		button.modulate = Color.WHITE
	
	if selected_mulut >= 0 and selected_mulut < mulut_buttons.size():
		mulut_buttons[selected_mulut].modulate = Color.GREEN

func check_completion():
	"""Check if all components are selected and enable/disable Pilih button"""
	# Now allow completion with None (0) selections as well
	if selected_base >= 0 and selected_mata >= 0 and selected_mulut >= 0:
		pilih_button.disabled = false
	else:
		pilih_button.disabled = true

func update_preview():
	"""Update the preview text with current selections"""
	var preview_parts = []
	
	if selected_base >= 0:
		if selected_base == 0:
			preview_parts.append("Base: None (Tidak digunakan)")
		else:
			preview_parts.append("Base: " + str(selected_base))
	else:
		preview_parts.append("Base: Belum dipilih")
	
	if selected_mata >= 0:
		if selected_mata == 0:
			preview_parts.append("Mata: None (Tidak digunakan)")
		else:
			preview_parts.append("Mata: " + str(selected_mata))
	else:
		preview_parts.append("Mata: Belum dipilih")
	
	if selected_mulut >= 0:
		if selected_mulut == 0:
			preview_parts.append("Mulut: None (Tidak digunakan)")
		else:
			preview_parts.append("Mulut: " + str(selected_mulut))
	else:
		preview_parts.append("Mulut: Belum dipilih")
	
	preview_text.text = "Pratinjau Topeng Custom\n\n" + "\n".join(preview_parts)
	
	if selected_base >= 0 and selected_mata >= 0 and selected_mulut >= 0:
		preview_text.text += "\n\n✅ Siap digunakan!"

func _on_pilih_button_pressed():
	"""Handle Pilih button - save custom mask and go to webcam scene"""
	if selected_base >= 0 and selected_mata >= 0 and selected_mulut >= 0:
		print("Custom mask created: Base=%d, Mata=%d, Mulut=%d" % [selected_base, selected_mata, selected_mulut])
		
		# Save custom mask data to global
		Global.selected_mask_type = "custom"
		Global.selected_mask_id = -1
		Global.custom_mask_components = {
			"base": selected_base,
			"mata": selected_mata,
			"mulut": selected_mulut
		}
		
		# Go to webcam scene
		get_tree().change_scene_to_file("res://Scenes/TopengNusantara/TopengWebcamScene.tscn")
	else:
		print("Not all components selected")

func _on_back_button_pressed():
	"""Return to mask selection"""
	print("Back button pressed - returning to mask selection")
	get_tree().change_scene_to_file("res://Scenes/TopengNusantara/TopengSelectionScene.tscn")

func setup_navigation():
	"""Setup keyboard/joystick navigation for buttons"""
	# Include all customization buttons and bottom buttons
	buttons.clear()
	buttons.append_array(base_buttons)
	buttons.append_array(mata_buttons)
	buttons.append_array(mulut_buttons)
	buttons.append(pilih_button)
	buttons.append(back_button)
	current_button_index = 0
	update_button_focus()
	
	# Set initial focus
	base_none_button.grab_focus()
	print("🎮 TopengCustomization navigation setup completed with " + str(buttons.size()) + " buttons")

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
	
	var current_button = buttons[current_button_index]
	
	# Special navigation logic for customization layout
	if current_button in base_buttons:
		# If we're in base buttons, go to bottom buttons
		current_button_index = buttons.find(pilih_button)
	elif current_button in mata_buttons:
		# If we're in mata buttons, go to base buttons
		current_button_index = buttons.find(base_none_button)
	elif current_button in mulut_buttons:
		# If we're in mulut buttons, go to mata buttons
		current_button_index = buttons.find(mata_none_button)
	elif current_button == pilih_button or current_button == back_button:
		# If we're in bottom buttons, go to mulut buttons
		current_button_index = buttons.find(mulut_none_button)
	else:
		# Fallback: cycle through buttons
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
	
	var current_button = buttons[current_button_index]
	
	# Special navigation logic for customization layout
	if current_button in base_buttons:
		# If we're in base buttons, go to mata buttons
		current_button_index = buttons.find(mata_none_button)
	elif current_button in mata_buttons:
		# If we're in mata buttons, go to mulut buttons
		current_button_index = buttons.find(mulut_none_button)
	elif current_button in mulut_buttons:
		# If we're in mulut buttons, go to bottom buttons
		current_button_index = buttons.find(pilih_button)
	elif current_button == pilih_button or current_button == back_button:
		# If we're in bottom buttons, go to base buttons
		current_button_index = buttons.find(base_none_button)
	else:
		# Fallback: cycle through buttons
		current_button_index = (current_button_index + 1) % buttons.size()
	
	update_button_focus()
	last_navigation_time = current_time

func navigate_left():
	"""Navigate left in current group"""
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_navigation_time < navigation_cooldown:
		return
	
	if buttons.size() == 0:
		return
	
	var current_button = buttons[current_button_index]
	
	# Special navigation logic for customization layout
	if current_button in base_buttons:
		# Move left within base buttons
		var group_index = base_buttons.find(current_button)
		if group_index > 0:
			current_button_index = buttons.find(base_buttons[group_index - 1])
		else:
			current_button_index = buttons.find(base_buttons[-1])  # Wrap to last
	elif current_button in mata_buttons:
		# Move left within mata buttons
		var group_index = mata_buttons.find(current_button)
		if group_index > 0:
			current_button_index = buttons.find(mata_buttons[group_index - 1])
		else:
			current_button_index = buttons.find(mata_buttons[-1])  # Wrap to last
	elif current_button in mulut_buttons:
		# Move left within mulut buttons
		var group_index = mulut_buttons.find(current_button)
		if group_index > 0:
			current_button_index = buttons.find(mulut_buttons[group_index - 1])
		else:
			current_button_index = buttons.find(mulut_buttons[-1])  # Wrap to last
	elif current_button == pilih_button:
		# Move to back button
		current_button_index = buttons.find(back_button)
	elif current_button == back_button:
		# Move to pilih button
		current_button_index = buttons.find(pilih_button)
	
	update_button_focus()
	last_navigation_time = current_time

func navigate_right():
	"""Navigate right in current group"""
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_navigation_time < navigation_cooldown:
		return
	
	if buttons.size() == 0:
		return
	
	var current_button = buttons[current_button_index]
	
	# Special navigation logic for customization layout
	if current_button in base_buttons:
		# Move right within base buttons
		var group_index = base_buttons.find(current_button)
		if group_index < base_buttons.size() - 1:
			current_button_index = buttons.find(base_buttons[group_index + 1])
		else:
			current_button_index = buttons.find(base_buttons[0])  # Wrap to first
	elif current_button in mata_buttons:
		# Move right within mata buttons
		var group_index = mata_buttons.find(current_button)
		if group_index < mata_buttons.size() - 1:
			current_button_index = buttons.find(mata_buttons[group_index + 1])
		else:
			current_button_index = buttons.find(mata_buttons[0])  # Wrap to first
	elif current_button in mulut_buttons:
		# Move right within mulut buttons
		var group_index = mulut_buttons.find(current_button)
		if group_index < mulut_buttons.size() - 1:
			current_button_index = buttons.find(mulut_buttons[group_index + 1])
		else:
			current_button_index = buttons.find(mulut_buttons[0])  # Wrap to first
	elif current_button == back_button:
		# Move to pilih button
		current_button_index = buttons.find(pilih_button)
	elif current_button == pilih_button:
		# Move to back button
		current_button_index = buttons.find(back_button)
	
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