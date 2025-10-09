class_name CulturalPlayerControllerFixed
extends CharacterBody3D

# Player state
var current_region: String = ""
var is_interacting: bool = false
@export var debug_mode: bool = true

# Input Settings Resource (easier to manage - untuk yang "pelupa"!)
@export var input_settings: InputSettings

# Movement parameters (loaded from resource if available)
var max_speed: float = 4.0
var acceleration: float = 20.0
var braking: float = 20.0
var air_acceleration: float = 4.0
var jump_force: float = 5.0
var gravity_modifier: float = 1.5
var max_run_speed: float = 6.0

# Camera parameters (loaded from resource if available)
var look_sensitivity: float = 0.02
var joystick_camera_sensitivity: float = 200.0
var min_pitch: float = -1.5
var max_pitch: float = 1.5
var invert_joystick_y: bool = false
var invert_joystick_x: bool = false

# Movement state
var player_velocity: Vector3 = Vector3.ZERO
var is_running: bool = false
var is_on_ground: bool = true

# Footstep audio system
var footstep_timer: float = 0.0
var footstep_interval: float = 0.5  # Time between footsteps
var current_surface_type: String = "grass"  # Default surface type
var last_position: Vector3 = Vector3.ZERO
var movement_threshold: float = 0.1  # Minimum movement to trigger footstep

# Input state
var move_input: Vector2 = Vector2.ZERO
var camera_input: Vector2 = Vector2.ZERO
var jump_pressed: bool = false
var sprint_pressed: bool = false

# Command Manager
var command_manager: CulturalCommandManager

# References
@onready var camera: Camera3D = $Camera3D
@onready var interaction_controller: Node = $InteractionController
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_modifier

func _ready():
	_setup_initial_state()
	_connect_signals()
	_setup_command_manager()

func _setup_initial_state():
	# Load settings from resource if available
	_load_input_settings()
	
	# Set initial mouse mode
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Set initial region
	current_region = "Indonesia Timur"  # Updated for Papua scene
	
	if debug_mode:
		print("Player initialized - Region: ", current_region)
		print("Mouse mode: ", Input.get_mouse_mode())
		print("Player position: ", position)
		print("Input settings loaded - Joystick sensitivity: ", joystick_camera_sensitivity)

func _load_input_settings():
	"""Load all parameters from InputSettings resource"""
	if input_settings:
		# Load all settings from resource
		max_speed = input_settings.walk_speed
		max_run_speed = input_settings.run_speed
		jump_force = input_settings.jump_force
		acceleration = input_settings.acceleration
		braking = input_settings.braking
		air_acceleration = input_settings.air_acceleration
		gravity_modifier = input_settings.gravity_modifier
		look_sensitivity = input_settings.mouse_sensitivity
		joystick_camera_sensitivity = input_settings.joystick_camera_sensitivity
		min_pitch = input_settings.min_pitch
		max_pitch = input_settings.max_pitch
		invert_joystick_y = input_settings.invert_joystick_y
		invert_joystick_x = input_settings.invert_joystick_x
		
		if debug_mode:
			print("✅ Input settings loaded from resource")
	else:
		if debug_mode:
			print("⚠️ No InputSettings resource assigned - using default values")

func _connect_signals():
	# Connect interaction signals if available
	if interaction_controller and interaction_controller.has_signal("interaction_started"):
		interaction_controller.interaction_started.connect(_on_interaction_started)
	if interaction_controller and interaction_controller.has_signal("interaction_ended"):
		interaction_controller.interaction_ended.connect(_on_interaction_ended)

func _setup_command_manager():
	# Initialize command manager
	command_manager = CulturalCommandManager.new()
	add_child(command_manager)
	
	# Connect command manager signals
	command_manager.command_executed.connect(_on_command_executed)
	command_manager.command_undone.connect(_on_command_undone)
	command_manager.command_redone.connect(_on_command_redone)
	
	if debug_mode:
		print("Command Manager initialized")

func _input(event):
	_handle_input(event)

func _physics_process(delta):
	_handle_movement(delta)
	_handle_camera(delta)
	_handle_footstep_audio(delta)

func _handle_input(event):
	# Mouse look
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera_input = event.relative
		if debug_mode:
			GameLogger.debug("Camera input: " + str(camera_input))
	
	# Mouse mode toggle - DISABLED in region scenes to allow ESC for exit dialog
	if Input.is_action_just_pressed("ui_cancel"):
		# Check if we're in a region scene - if so, don't handle ESC here
		var current_scene = get_tree().current_scene
		if current_scene and current_scene.has_method("get_region_name"):
			# We're in a region scene, let the RegionSceneController handle ESC
			if debug_mode:
				GameLogger.debug("ESC pressed in region scene - letting RegionSceneController handle it")
			return  # Don't consume the input
		
		# Only handle mouse mode toggle in non-region scenes
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			if debug_mode:
				GameLogger.debug("Mouse captured")
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if debug_mode:
				GameLogger.debug("Mouse visible")
	
	# Movement input debug
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_W or event.keycode == KEY_S or event.keycode == KEY_A or event.keycode == KEY_D:
			if debug_mode:
				GameLogger.debug("Movement key pressed: " + str(event.keycode))
	
	# Undo/Redo commands
	if Input.is_action_just_pressed("undo"):
		_handle_undo()
	
	if Input.is_action_just_pressed("redo"):
		_handle_redo()

func _handle_undo():
	if command_manager and command_manager.can_undo():
		command_manager.undo_command()
		if debug_mode:
			GameLogger.debug("Undo executed")

func _handle_redo():
	if command_manager and command_manager.can_redo():
		command_manager.redo_command()
		if debug_mode:
			GameLogger.debug("Redo executed")

func _handle_movement(delta):
	# Get input
	move_input = Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		move_input.y -= 1
	if Input.is_action_pressed("move_back"):
		move_input.y += 1
	if Input.is_action_pressed("move_left"):
		move_input.x -= 1
	if Input.is_action_pressed("move_right"):
		move_input.x += 1
	
	# Jump input
	jump_pressed = Input.is_action_pressed("jump")
	
	# Sprint input
	sprint_pressed = Input.is_action_pressed("sprint")
	
	# Update ground state with landing detection
	var was_on_ground = is_on_ground
	is_on_ground = is_on_floor() or position.y <= 1.1
	
	# Check for landing (was in air, now on ground)
	if not was_on_ground and is_on_ground:
		_on_land()  # Trigger landing audio
	
	# Apply gravity
	if not is_on_ground:
		player_velocity.y -= gravity * delta
	
	# Handle jumping
	if jump_pressed and is_on_ground:
		player_velocity.y = jump_force
		_on_jump()  # Trigger jump audio
		if debug_mode:
			GameLogger.debug("Player jumped")
	
	# Handle horizontal movement
	if move_input != Vector2.ZERO:
		# Normalize input
		move_input = move_input.normalized()
		
		# Determine speed
		var current_speed = max_speed
		if sprint_pressed:
			current_speed = max_run_speed
			is_running = true
		else:
			is_running = false
		
		# Calculate movement direction based on camera
		var camera_forward = -camera.global_transform.basis.z
		var camera_right = camera.global_transform.basis.x
		
		# Remove Y component
		camera_forward.y = 0
		camera_right.y = 0
		camera_forward = camera_forward.normalized()
		camera_right = camera_right.normalized()
		
		# Calculate movement direction
		var move_direction = Vector3.ZERO
		move_direction += camera_forward * -move_input.y
		move_direction += camera_right * move_input.x
		
		# Apply acceleration
		var target_velocity = move_direction * current_speed
		var acceleration_rate = acceleration if is_on_ground else air_acceleration
		
		player_velocity.x = lerp(player_velocity.x, target_velocity.x, acceleration_rate * delta)
		player_velocity.z = lerp(player_velocity.z, target_velocity.z, acceleration_rate * delta)
		
		if debug_mode and move_input != Vector2.ZERO:
			GameLogger.debug("Move input: " + str(move_input) + " Speed: " + str(current_speed) + " Target velocity: " + str(target_velocity) + " Current velocity: " + str(player_velocity))
	else:
		# Apply braking
		var braking_rate = braking if is_on_ground else air_acceleration
		player_velocity.x = lerp(player_velocity.x, 0.0, braking_rate * delta)
		player_velocity.z = lerp(player_velocity.z, 0.0, braking_rate * delta)
		is_running = false
	
	# Apply movement manually to avoid glitchy movement from move_and_slide()
	# This gives us full control over the physics and prevents unwanted movement
	var movement = player_velocity * delta
	
	# Apply all movement (including Y for jumping)
	position.x += movement.x
	position.y += movement.y
	position.z += movement.z
	
	if debug_mode and (move_input != Vector2.ZERO or jump_pressed):
		GameLogger.debug("Manual movement applied - Position: " + str(position) + " Movement: " + str(movement) + " Velocity: " + str(player_velocity))
	
	# Ground collision
	if position.y < 1.0:
		position.y = 1.0
		player_velocity.y = 0

	move_and_slide()

func _handle_camera(delta):
	# Add joystick camera input from right analog stick
	var joystick_camera_input = Vector2.ZERO
	joystick_camera_input.x = Input.get_action_strength("camera_right") - Input.get_action_strength("camera_left")
	joystick_camera_input.y = Input.get_action_strength("camera_down") - Input.get_action_strength("camera_up")
	
	# Apply inversion if enabled (dari InputSettings resource)
	if invert_joystick_x:
		joystick_camera_input.x = -joystick_camera_input.x
	if invert_joystick_y:
		joystick_camera_input.y = -joystick_camera_input.y
	
	# Scale joystick input using sensitivity from resource
	# Joystick needs to be multiplied by delta for smooth frame-independent movement
	joystick_camera_input *= joystick_camera_sensitivity * delta
	
	# Combine mouse and joystick input
	var combined_camera_input = camera_input + joystick_camera_input
	
	if combined_camera_input != Vector2.ZERO:
		# Apply camera rotation
		rotate_y(-combined_camera_input.x * look_sensitivity)
		camera.rotate_x(-combined_camera_input.y * look_sensitivity)
		
		# Clamp pitch
		camera.rotation.x = clamp(camera.rotation.x, min_pitch, max_pitch)
		
		if debug_mode and combined_camera_input.length() > 0.01:
			print("Camera input - Mouse: ", camera_input, " Joystick: ", joystick_camera_input)
		
		# Reset mouse input only (joystick is read each frame)
		camera_input = Vector2.ZERO

func _on_interaction_started(interactable: Node):
	is_interacting = true
	if debug_mode:
		print("Started interaction with: ", interactable.name)

func _on_interaction_ended(interactable: Node):
	is_interacting = false
	if debug_mode:
		print("Ended interaction with: ", interactable.name)

# Command Manager callbacks
func _on_command_executed(command: CulturalActionCommand):
	if debug_mode:
		print("Command executed: ", command.get_description())

func _on_command_undone(command: CulturalActionCommand):
	if debug_mode:
		print("Command undone: ", command.get_description())

func _on_command_redone(command: CulturalActionCommand):
	if debug_mode:
		print("Command redone: ", command.get_description())

# Public interface
func get_current_region() -> String:
	return current_region

func set_current_region(region: String):
	current_region = region
	if EventBus:
		EventBus.emit_event(EventBus.EventType.SESSION_UPDATE, {
			"update_type": "region_changed",
			"region": region
		}, 3, "player_system")

func is_player_interacting() -> bool:
	return is_interacting

func get_player_position() -> Vector3:
	return global_position

func get_player_velocity() -> Vector3:
	return player_velocity

func is_player_running() -> bool:
	return is_running

func is_player_on_ground() -> bool:
	return is_on_ground

func get_camera() -> Camera3D:
	return camera

func get_interaction_controller() -> Node:
	return interaction_controller

# ===== FOOTSTEP AUDIO SYSTEM =====

func _handle_footstep_audio(delta):
	"""Handle footstep audio based on player movement"""
	if not is_on_ground:
		return
	
	# Update footstep timer
	footstep_timer += delta
	
	# Check if player is moving
	var current_position = global_position
	var movement_distance = current_position.distance_to(last_position)
	
	if movement_distance > movement_threshold:
		# Player is moving, check if it's time for a footstep
		if footstep_timer >= footstep_interval:
			# Trigger footstep audio
			GlobalSignals.on_play_footstep_audio.emit()
			
			# Update running state for audio manager
			GlobalSignals.on_set_running_state.emit(is_running)
			
			# Reset timer
			footstep_timer = 0.0
			
			# Update last position
			last_position = current_position
			
			if debug_mode:
				GameLogger.debug("Footstep triggered - Surface: " + current_surface_type + ", Running: " + str(is_running))
	else:
		# Player is not moving, reset timer
		footstep_timer = 0.0

func set_surface_type(surface_type: String):
	"""Set the current surface type for footstep audio"""
	current_surface_type = surface_type
	GlobalSignals.on_set_surface_type.emit(surface_type)
	
	if debug_mode:
		GameLogger.debug("Surface type changed to: " + surface_type)

func _on_jump():
	"""Handle jump audio"""
	GlobalSignals.on_play_player_audio.emit("jump")
	
	if debug_mode:
		GameLogger.debug("Jump audio triggered")

func _on_land():
	"""Handle landing audio"""
	GlobalSignals.on_play_player_audio.emit("land")
	
	if debug_mode:
		GameLogger.debug("Landing audio triggered")

func get_command_manager() -> CulturalCommandManager:
	return command_manager
