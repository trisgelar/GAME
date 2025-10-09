# 🎮 Xbox Joystick Setup Guide

**Date:** October 8, 2025  
**Status:** Active

## Overview
This guide covers the configuration of Xbox-like joystick controls for the Indonesian Cultural Heritage Exhibition game.

## Controller Layout

### Analog Sticks
- **Left Analog Stick**: Player movement (forward/back/left/right)
  - Already working seamlessly with default Godot mapping
- **Right Analog Stick**: Camera movement (like mouse look)
  - Configured for smooth camera control
  - Default sensitivity: 200.0 (adjustable in PlayerControllerFixed.gd)

### Buttons
- **A Button** (bottom): Jump / Menu Select
  - Maps to: Spacebar / Enter
  - Input actions: `jump`, `menu_select`
  - Use in menus to select/confirm

- **B Button** (right): Pick Item / Menu Back
  - Maps to: F key / Escape
  - Input actions: `pick_item`, `menu_back`
  - Use in menus to go back/cancel

- **Y Button** (top): Interact/Talk to NPC
  - Maps to: E key
  - Input action: `interact`

- **X Button** (left): Not mapped yet
  - Available for future use

### Shoulder Buttons
- **Left Bumper (LB)**: Sprint/Run
  - Maps to: Shift key
  - Input action: `sprint`
  - Alternative to keyboard Shift for easier gameplay

- **Right Bumper (RB)**: Not mapped yet
  - Available for future use

### D-Pad & Left Analog (In Menus)
- **D-Pad Up / Left Stick Up**: Menu navigation up
  - Input action: `menu_up`
- **D-Pad Down / Left Stick Down**: Menu navigation down
  - Input action: `menu_down`
- **D-Pad Left / Left Stick Left**: Menu navigation left
  - Input action: `menu_left`
- **D-Pad Right / Left Stick Right**: Menu navigation right
  - Input action: `menu_right`

## Technical Details

### Input Mappings (project.godot)

```gdscript
# Jump - A Button
jump={
  "events": [
    Keyboard: Space,
    Joypad Button: 0 (A button)
  ]
}

# Interact - Y Button
interact={
  "events": [
    Keyboard: E,
    Joypad Button: 3 (Y button)
  ]
}

# Pick Item - B Button
pick_item={
  "events": [
    Keyboard: F,
    Joypad Button: 1 (B button)
  ]
}

# Sprint - Left Bumper
sprint={
  "events": [
    Keyboard: Shift,
    Joypad Button: 9 (Left Bumper)
  ]
}

# Right Analog Stick - Camera Control
camera_right={
  "deadzone": 0.15,
  "axis": 2 (right stick X+)
}

camera_left={
  "deadzone": 0.15,
  "axis": 2 (right stick X-)
}

camera_down={
  "deadzone": 0.15,
  "axis": 3 (right stick Y+)
}

camera_up={
  "deadzone": 0.15,
  "axis": 3 (right stick Y-)
}
```

### Camera Movement Implementation

The right analog stick camera control is implemented in `PlayerControllerFixed.gd`:

```gdscript
func _handle_camera(delta):
    # Get joystick input from right analog stick
    var joystick_camera_input = Vector2.ZERO
    joystick_camera_input.x = Input.get_action_strength("camera_right") - Input.get_action_strength("camera_left")
    joystick_camera_input.y = Input.get_action_strength("camera_down") - Input.get_action_strength("camera_up")
    
    # Scale for smooth movement
    var joystick_sensitivity = 200.0
    joystick_camera_input *= joystick_sensitivity * delta
    
    # Combine with mouse input
    var combined_camera_input = camera_input + joystick_camera_input
```

## Adjusting Settings (Resource-Based - Easy for "Pelupa"!)

All input settings are now stored in a `.tres` resource file that you can edit directly in Godot's Inspector!

### Using the InputSettings Resource

1. **In Godot Editor**:
   - Open the Player scene: `Player Controller/Player.tscn`
   - Select the Player node
   - In Inspector, find "Input Settings" property
   - Assign the resource: `Resources/Input/default_input_settings.tres`

2. **To Adjust Settings**:
   - Click on the assigned resource in Inspector
   - All settings will appear with sliders and options
   - Change any value (joystick sensitivity, mouse sensitivity, speeds, etc.)
   - Click "Save" or Ctrl+S to save the resource
   - No need to edit code!

### Important Settings You Can Adjust:

#### Joystick Settings
- **Joystick Camera Sensitivity** (50-500): Right analog stick camera speed
  - Default: 200.0
  - Higher = faster, Lower = slower
- **Joystick Deadzone** (0.0-0.5): Prevents stick drift
  - Default: 0.15
- **Invert Joystick X/Y**: Flip camera direction if needed

#### Mouse Settings
- **Mouse Sensitivity** (0.001-0.1): Mouse look sensitivity
  - Default: 0.02
- **Invert Mouse Y**: Flip vertical mouse look

#### Movement Settings
- **Walk Speed** (1-10): Normal movement speed
  - Default: 4.0
- **Run Speed** (2-20): Sprint speed (when holding LB or Shift)
  - Default: 6.0
- **Jump Force** (1-20): How high the player jumps
  - Default: 5.0

#### Camera Settings
- **Min/Max Pitch**: How far you can look up/down
  - Default: -1.5 to 1.5 radians

### Old Method (Manual Editing - Not Recommended)

If you prefer to edit the `.tres` file directly:
1. Open `Walking Simulator/Resources/Input/default_input_settings.tres`
2. Modify the values
3. Save the file

## Testing the Controls

1. **Connect your Xbox-like controller** before starting the game
2. **Launch the game** from Godot or as a standalone build
3. **Test each control**:
   - Left stick: Move around
   - Right stick: Look around
   - A button: Jump
   - Y button: Interact with NPCs
   - B button: Pick up items
   - LB button: Sprint while moving

## Troubleshooting

### Controller Not Detected
- Ensure the controller is connected before launching the game
- Check Windows Game Controllers settings (joy.cpl)
- Try reconnecting the controller

### Camera Movement Too Fast/Slow
- Adjust `joystick_sensitivity` in `PlayerControllerFixed.gd`
- Default is 200.0, try values between 100.0 and 400.0

### Stick Drift Issues
- Increase the deadzone value in `project.godot`
- Try values between 0.15 and 0.30

### Button Not Responding
- Verify the button index matches your controller
- Some generic controllers may have different button mappings
- Use Godot's Input Map editor to test button indices

## Future Enhancements

Available for mapping:
- **X Button**: Could be used for inventory or quick actions
- **Right Bumper (RB)**: Could be used for camera reset or zoom
- **Triggers**: Could be used for contextual actions or weapon/tool use
- **Start Button**: Could open pause menu
- **Select/Back Button**: Could open map or inventory

## Scene Compatibility

All joystick controls now work in **ALL** game scenes:

✅ **Pasar Scene** (Indonesia Barat) - Uses `PlayerControllerFixed.gd`  
✅ **Tambora Scene** (Indonesia Tengah) - Uses `PlayerControllerIntegrated_tambora.gd`  
✅ **Papua Scene** (Indonesia Timur) - Uses `PlayerControllerIntegrated.gd`  

All three player controllers have been updated with:
- Right analog stick camera control
- InputSettings resource support
- Joystick button mappings
- Menu navigation support

## Files Created/Modified

### Created Files:
1. **`Walking Simulator/Resources/Input/InputSettings.gd`**
   - Resource script that defines all configurable input parameters
   - Contains mouse, joystick, camera, and movement settings
   - Easy to edit in Godot Inspector - no code needed!

2. **`Walking Simulator/Resources/Input/default_input_settings.tres`**
   - Default input settings resource
   - Can be edited in Godot Inspector or text editor
   - All your settings in one place!

### Modified Files:
1. **`Walking Simulator/project.godot`**
   - Added joystick button mappings for jump, interact, pick_item, sprint
   - Added right analog stick axis mappings for camera control
   - Added menu navigation inputs (menu_select, menu_up/down/left/right, menu_back)

2. **`Walking Simulator/Player Controller/PlayerControllerFixed.gd`** (Pasar Scene)
   - Added InputSettings resource support
   - Loads all parameters from resource (no more hardcoded values!)
   - Updated `_handle_camera()` function to support right analog stick input
   - Added axis inversion support
   - Combined mouse and joystick input for seamless camera control

3. **`Walking Simulator/Player Controller/PlayerControllerIntegrated.gd`** (Papua Scene)
   - Added InputSettings resource support  
   - Updated `handle_mouse_look()` to support right analog stick
   - Added joystick sensitivity and inversion settings
   - Combined mouse and joystick input seamlessly

4. **`Walking Simulator/Player Controller/PlayerControllerIntegrated_tambora.gd`** (Tambora Scene)
   - Added InputSettings resource support
   - Updated `handle_mouse_look()` to support right analog stick  
   - Added joystick sensitivity and inversion settings
   - Supports both animations and joystick controls

## Notes

- All keyboard controls remain functional - you can use both controller and keyboard simultaneously
- Mouse look also works alongside joystick camera control
- The left analog stick uses Godot's built-in input action system for movement

