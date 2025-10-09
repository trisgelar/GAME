# 🎮 Input Settings Resource Guide (Untuk yang "Pelupa"!)

**Date:** October 8, 2025  
**Status:** Active  
**Purpose:** Easy-to-edit input settings without touching code!

## Overview

All input and movement settings are now stored in a `.tres` resource file that you can edit directly in Godot's Inspector. No more hunting through code files to find where you set the joystick sensitivity!

## Quick Start Guide

### Step 1: Assign the Resource to Your Player

1. Open Godot Editor
2. Navigate to `Player Controller/Player.tscn`
3. Click on the **Player** node (the root node)
4. In the **Inspector** panel (right side), scroll down to find **"Input Settings"**
5. Click on the dropdown and select **"Load"**
6. Navigate to `Resources/Input/default_input_settings.tres`
7. Click **Open**

✅ Done! The player will now use the resource file for all settings.

### Step 2: Edit Settings in Inspector (The Easy Way!)

1. With the Player node still selected
2. In Inspector, click on the **InputSettings resource** (it should show a file icon)
3. The Inspector will expand to show ALL settings with sliders and options:

```
📁 InputSettings
  📁 Mouse
    🎯 Mouse Sensitivity: [slider 0.001 to 0.1] = 0.02
    ☑️ Invert Mouse Y: [checkbox] = false
  
  📁 Joystick/Gamepad
    🎯 Joystick Camera Sensitivity: [slider 50 to 500] = 200.0
    🎯 Joystick Deadzone: [slider 0.0 to 0.5] = 0.15
    ☑️ Invert Joystick Y: [checkbox] = false
    ☑️ Invert Joystick X: [checkbox] = false
  
  📁 Camera
    🎯 Min Pitch: [slider -3.0 to 0.0] = -1.5
    🎯 Max Pitch: [slider 0.0 to 3.0] = 1.5
    🎯 Camera Smoothing: [number] = 0.0
  
  📁 Movement
    🎯 Walk Speed: [slider 1.0 to 10.0] = 4.0
    🎯 Run Speed: [slider 2.0 to 20.0] = 6.0
    🎯 Jump Force: [slider 1.0 to 20.0] = 5.0
  
  📁 Advanced
    🎯 Acceleration: [slider 5.0 to 50.0] = 20.0
    🎯 Braking: [slider 5.0 to 50.0] = 20.0
    🎯 Air Acceleration: [slider 1.0 to 10.0] = 4.0
    🎯 Gravity Modifier: [slider 0.5 to 3.0] = 1.5
```

4. **Drag sliders** to adjust values
5. **Check/uncheck** boxes for boolean options
6. Press **Ctrl+S** or **File → Save** to save your changes
7. **Test immediately** in game!

## Common Adjustments

### "Camera terlalu cepat dengan joystick!"
- Lower **Joystick Camera Sensitivity**
- Try values: 100, 150, or 120

### "Camera terlalu lambat dengan joystick!"
- Raise **Joystick Camera Sensitivity**
- Try values: 250, 300, or 350

### "Joystick stick drift / bergerak sendiri!"
- Increase **Joystick Deadzone**
- Try: 0.20, 0.25, or 0.30

### "Player lari terlalu lambat/cepat!"
- Adjust **Walk Speed** (normal walking)
- Adjust **Run Speed** (when pressing LB/Shift)

### "Player loncat terlalu tinggi/rendah!"
- Adjust **Jump Force**
- Lower = shorter jump, Higher = higher jump

### "Kamera terbalik (inverted)!"
- Check **Invert Joystick Y** (for up/down)
- Check **Invert Joystick X** (for left/right)

## Creating Different Presets

You can create multiple setting files for different play styles:

1. **In Project panel**, navigate to `Resources/Input/`
2. **Right-click** on `default_input_settings.tres`
3. Select **"Duplicate"**
4. Rename it (e.g., `fast_input_settings.tres`, `slow_input_settings.tres`)
5. Open the new file and adjust settings
6. In Player scene, assign the new resource

### Suggested Presets:

#### Fast & Responsive
- Joystick Camera Sensitivity: 350
- Mouse Sensitivity: 0.03
- Walk Speed: 5.0
- Run Speed: 8.0

#### Slow & Precise
- Joystick Camera Sensitivity: 120
- Mouse Sensitivity: 0.015
- Walk Speed: 3.0
- Run Speed: 5.0

#### High Jumper
- Jump Force: 10.0
- Gravity Modifier: 1.2

## File Locations

```
Walking Simulator/
├── Resources/
│   └── Input/
│       ├── InputSettings.gd          ← The script (don't edit unless adding features)
│       └── default_input_settings.tres ← Edit THIS in Inspector!
├── Player Controller/
│   ├── Player.tscn                   ← Assign resource here
│   └── PlayerControllerFixed.gd      ← Automatically loads from resource
```

## Benefits of Resource-Based Settings

✅ **No code editing** - All changes in Inspector  
✅ **Visual sliders** - Easy to adjust values  
✅ **Multiple presets** - Create different play styles  
✅ **Easy to share** - Send `.tres` file to others  
✅ **No typos** - Sliders prevent invalid values  
✅ **Instant testing** - Change and test immediately  
✅ **"Pelupa-proof"** - All settings in one place, easy to find!

## Advanced: Editing .tres File Directly

If you prefer text editing (or need to script changes):

1. Open `Resources/Input/default_input_settings.tres` in text editor
2. Edit values:
   ```
   joystick_camera_sensitivity = 200.0  ← Change this number
   walk_speed = 4.0                     ← Or this
   ```
3. Save file
4. Godot will auto-reload the resource

## Troubleshooting

### "Settings tidak berubah!"
- Make sure you saved the resource (Ctrl+S)
- Check that the Player scene has the resource assigned
- Restart the game/scene

### "Inspector tidak menampilkan settings!"
- Click on the resource itself in Inspector (the file icon)
- Make sure the resource is assigned, not empty

### "Mau kembali ke default!"
- Delete your modified `.tres` file
- Use the original from git, or
- Create new InputSettings resource with default values

## Notes

- Changes to the `.tres` file are **immediate** - no need to recompile
- You can have **different settings per scene** by creating multiple resources
- The resource system is **type-safe** - invalid values are automatically clamped
- All settings have **sensible ranges** to prevent extreme values

