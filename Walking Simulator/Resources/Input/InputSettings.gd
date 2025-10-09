class_name InputSettings
extends Resource

## 🎮 Input Settings Resource
## Stores all configurable input parameters for keyboard, mouse, and gamepad/joystick

# === MOUSE SETTINGS ===
@export_group("Mouse")
@export_range(0.001, 0.1, 0.001) var mouse_sensitivity: float = 0.02
@export var invert_mouse_y: bool = false

# === JOYSTICK/GAMEPAD SETTINGS ===
@export_group("Joystick/Gamepad")
@export_range(50.0, 500.0, 10.0) var joystick_camera_sensitivity: float = 200.0
@export_range(0.0, 0.5, 0.05) var joystick_deadzone: float = 0.15
@export var invert_joystick_y: bool = false
@export var invert_joystick_x: bool = false

# === CAMERA SETTINGS ===
@export_group("Camera")
@export_range(-3.0, 0.0, 0.1) var min_pitch: float = -1.5
@export_range(0.0, 3.0, 0.1) var max_pitch: float = 1.5
@export var camera_smoothing: float = 0.0  # 0 = no smoothing, higher = smoother

# === MOVEMENT SETTINGS ===
@export_group("Movement")
@export_range(1.0, 10.0, 0.5) var walk_speed: float = 4.0
@export_range(2.0, 20.0, 0.5) var run_speed: float = 6.0
@export_range(1.0, 20.0, 0.5) var jump_force: float = 5.0

# === ADVANCED SETTINGS ===
@export_group("Advanced")
@export_range(5.0, 50.0, 1.0) var acceleration: float = 20.0
@export_range(5.0, 50.0, 1.0) var braking: float = 20.0
@export_range(1.0, 10.0, 0.5) var air_acceleration: float = 4.0
@export_range(0.5, 3.0, 0.1) var gravity_modifier: float = 1.5

## Get a copy of these settings
func duplicate_settings() -> InputSettings:
	var new_settings = InputSettings.new()
	new_settings.mouse_sensitivity = mouse_sensitivity
	new_settings.invert_mouse_y = invert_mouse_y
	new_settings.joystick_camera_sensitivity = joystick_camera_sensitivity
	new_settings.joystick_deadzone = joystick_deadzone
	new_settings.invert_joystick_y = invert_joystick_y
	new_settings.invert_joystick_x = invert_joystick_x
	new_settings.min_pitch = min_pitch
	new_settings.max_pitch = max_pitch
	new_settings.camera_smoothing = camera_smoothing
	new_settings.walk_speed = walk_speed
	new_settings.run_speed = run_speed
	new_settings.jump_force = jump_force
	new_settings.acceleration = acceleration
	new_settings.braking = braking
	new_settings.air_acceleration = air_acceleration
	new_settings.gravity_modifier = gravity_modifier
	return new_settings

## Apply settings from another InputSettings resource
func apply_from(other: InputSettings) -> void:
	if not other:
		return
	mouse_sensitivity = other.mouse_sensitivity
	invert_mouse_y = other.invert_mouse_y
	joystick_camera_sensitivity = other.joystick_camera_sensitivity
	joystick_deadzone = other.joystick_deadzone
	invert_joystick_y = other.invert_joystick_y
	invert_joystick_x = other.invert_joystick_x
	min_pitch = other.min_pitch
	max_pitch = other.max_pitch
	camera_smoothing = other.camera_smoothing
	walk_speed = other.walk_speed
	run_speed = other.run_speed
	jump_force = other.jump_force
	acceleration = other.acceleration
	braking = other.braking
	air_acceleration = other.air_acceleration
	gravity_modifier = other.gravity_modifier

