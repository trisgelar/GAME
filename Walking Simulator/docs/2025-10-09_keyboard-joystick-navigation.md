# Keyboard and Joystick Navigation System

**Date**: 2025-10-09  
**Status**: ✅ Completed  
**Author**: Development Team

## 📋 Overview

This document describes the comprehensive keyboard and joystick navigation system implemented across all menu scenes in the Walking Simulator game. The system provides full controller support, allowing players to navigate and interact with all UI elements without needing a mouse.

---

## 🎮 Supported Input Methods

### Keyboard
- **Arrow Keys** (↑↓←→) - Navigate between buttons
- **Enter / Space** - Activate focused button
- **Escape** - Go back / Cancel

### Joystick (Xbox-style controller)
- **Left Analog Stick** - Navigate between buttons
- **A Button** - Activate focused button / Interact with regions
- **B Button** - Go back / Cancel

---

## 🏗️ Architecture

### Core Components

1. **Navigation Variables** - Track current state and button arrays
2. **Input Handler** (`_input()`) - Process keyboard and joystick events
3. **Navigation Functions** - Move focus between buttons
4. **Focus Management** - Visual feedback and state management
5. **Cooldown System** - Prevent rapid input spam

### Common Pattern

All navigation-enabled scenes follow this pattern:

```gdscript
# Navigation System Variables
var buttons: Array[Button] = []
var current_button_index: int = 0
var navigation_enabled: bool = true
var last_navigation_time: float = 0.0
var navigation_cooldown: float = 0.2

# Setup in _ready()
func _ready():
    setup_navigation()

# Input handling
func _input(event):
    # Handle keyboard and joystick input
    
# Navigation functions
func navigate_up()
func navigate_down()
func navigate_left()
func navigate_right()
func activate_current_button()
func update_button_focus()
```

---

## 🎯 Scene-by-Scene Implementation

### 1. Main Menu (`MainMenu.tscn` / `MainMenuController.gd`)

#### Navigation Levels

The main menu has multiple navigation contexts:

1. **Main Menu Level** - 8 primary buttons
2. **Start Game Submenu** - 4 region selection buttons
3. **How to Play Panel** - 1 back button
4. **About Us Panel** - 1 back button
5. **Credits Panel** - 1 back button

#### Button Arrays

```gdscript
var buttons: Array[Button] = []           # Main menu buttons
var submenu_buttons: Array[Button] = []   # Region selection buttons
var panel_buttons: Array[Button] = []     # Panel back buttons
var current_menu_level: String = "main"
```

#### Setup Navigation

```gdscript
func setup_menu_navigation():
    # Main menu buttons
    buttons = [
        explore_3d_map_button,
        ethnicit_detection_button,
        topeng_nusantara_button,
        load_game_button,
        how_to_play_button,
        about_us_button,
        credits_button,
        exit_button
    ]
    
    # Submenu buttons
    submenu_buttons = [
        indonesia_barat_button,
        indonesia_tengah_button,
        indonesia_timur_button,
        back_button
    ]
    
    current_button_index = 0
    update_button_focus()
```

#### Context-Aware Navigation

```gdscript
func get_current_button_array() -> Array[Button]:
    match current_menu_level:
        "main":
            return buttons
        "start_game":
            return submenu_buttons
        "how_to_play", "about_us", "credits":
            return panel_buttons
        _:
            return []
```

#### Controls

| Input | Action |
|-------|--------|
| ↑ / Left Stick ↑ | Previous button |
| ↓ / Left Stick ↓ | Next button |
| Enter / Space / A | Activate button |
| Escape / B | Go back / Exit |

---

### 2. Ethnicity Detection Scene (`EthnicityDetectionScene.tscn`)

#### Dynamic Button Management

The scene dynamically adds the "Skip to Map" button when detection is complete:

```gdscript
func setup_navigation():
    buttons = [start_button, back_button]
    current_button_index = 0
    update_button_focus()

func detection_complete():
    # ... detection logic ...
    if skip_to_map_button:
        skip_to_map_button.visible = true
    update_navigation_buttons()  # Add skip button to navigation

func update_navigation_buttons():
    buttons.clear()
    buttons.append(start_button)
    buttons.append(back_button)
    if skip_to_map_button and skip_to_map_button.visible:
        buttons.append(skip_to_map_button)
    update_button_focus()
```

#### Controls

| Input | Action |
|-------|--------|
| ↑↓ / Left Stick ↕️ | Navigate buttons |
| ←→ / Left Stick ↔️ | Navigate buttons |
| Enter / Space / A | Activate button |
| Escape / B | Go back |

---

### 3. Topeng Selection Scene (`TopengSelectionScene.tscn`)

#### Grid-Based Navigation

The scene uses a 4×2 grid layout for mask selection:

```
[Face1] [Face2] [Face3] [Face4]
[Face5] [Face6] [Face7] [Custom]
         [Pilih] [Kembali]
```

#### Smart Navigation Logic

```gdscript
func navigate_right():
    var current_time = Time.get_unix_time_from_system()
    if current_time - last_navigation_time < navigation_cooldown:
        return
    
    # If in mask selection area (first 8 buttons)
    if current_button_index < 8:
        var row = current_button_index / 4
        var col = current_button_index % 4
        col = (col + 1) % 4  # Wrap within row
        current_button_index = row * 4 + col
    # If in bottom buttons
    elif current_button_index >= 8:
        # Toggle between Pilih and Kembali
        if current_button_index == 8:
            current_button_index = 9
        else:
            current_button_index = 8
    
    update_button_focus()
    last_navigation_time = current_time
```

#### Controls

| Input | Action |
|-------|--------|
| ↑ / Left Stick ↑ | Move up in grid |
| ↓ / Left Stick ↓ | Move down in grid |
| ← / Left Stick ← | Move left (wraps) |
| → / Left Stick → | Move right (wraps) |
| Enter / Space / A | Select mask |
| Escape / B | Go back |

---

### 4. Topeng Customization Scene (`TopengCustomizationScene.tscn`)

#### Group-Based Navigation

The scene has three customization groups:

```
Base:  [None] [Base1] [Base2] [Base3]
Mata:  [None] [Mata1] [Mata2] [Mata3]
Mulut: [None] [Mulut1] [Mulut2] [Mulut3]
       [Pilih] [Kembali]
```

#### Vertical Group Navigation

```gdscript
func navigate_down():
    var current_time = Time.get_unix_time_from_system()
    if current_time - last_navigation_time < navigation_cooldown:
        return
    
    # Base group (0-3) → Mata group (4-7)
    if current_button_index >= 0 and current_button_index <= 3:
        current_button_index = 4 + (current_button_index % 4)
    # Mata group (4-7) → Mulut group (8-11)
    elif current_button_index >= 4 and current_button_index <= 7:
        current_button_index = 8 + (current_button_index % 4)
    # Mulut group (8-11) → Bottom buttons (12-13)
    elif current_button_index >= 8 and current_button_index <= 11:
        current_button_index = 12  # Go to Pilih
    # Bottom buttons → Base group
    elif current_button_index >= 12:
        current_button_index = 0
    
    update_button_focus()
    last_navigation_time = current_time
```

#### Controls

| Input | Action |
|-------|--------|
| ↑ / Left Stick ↑ | Move to previous group |
| ↓ / Left Stick ↓ | Move to next group |
| ← / Left Stick ← | Previous option in group |
| → / Left Stick → | Next option in group |
| Enter / Space / A | Select option |
| Escape / B | Go back |

---

### 5. Topeng Webcam Scene (`TopengWebcamScene.tscn`)

#### Simple Two-Button Navigation

```gdscript
func setup_navigation():
    buttons.clear()
    buttons.append(pilih_topeng_button)
    buttons.append(menu_utama_button)
    current_button_index = 0
    update_button_focus()
```

#### Controls

| Input | Action |
|-------|--------|
| ↑↓←→ / Left Stick | Toggle between buttons |
| Enter / Space / A | Activate button |
| Escape / B | Return to main menu |

---

### 6. Indonesia 3D Map Scene (`Indonesia3DMapFinal.tscn`)

#### Advanced Navigation System

This scene has both **button navigation** and **region interaction**:

##### Button Navigation

```gdscript
func setup_navigation():
    buttons.clear()
    buttons.append(back_to_menu_button)
    
    # Add region buttons if visible
    if cooking_game_button.visible:
        buttons.append(cooking_game_button)
    if explore_region_button.visible:
        buttons.append(explore_region_button)
```

##### Region Focus System

The scene uses **camera raycasting** to detect which region the camera is looking at:

```gdscript
# Region Focus Variables
var focused_region_id: String = ""
var region_focus_enabled: bool = true
var last_region_focus_time: float = 0.0
var region_focus_cooldown: float = 0.3

func _process(delta):
    _update_region_focus()

func _update_region_focus():
    # Cast ray from camera forward
    var space_state = get_world_3d().direct_space_state
    var camera_pos = map_camera.global_position
    var camera_forward = -map_camera.global_transform.basis.z
    var query = PhysicsRayQueryParameters3D.create(
        camera_pos, 
        camera_pos + camera_forward * 1000.0
    )
    
    var result = space_state.intersect_ray(query)
    if result:
        var collider = result.collider
        if collider and collider.get_parent():
            var parent_node = collider.get_parent()
            if parent_node.has_meta("region_id"):
                focused_region_id = parent_node.get_meta("region_id")
                # Update UI to show focused region
```

##### Region Interaction

```gdscript
func _interact_with_focused_region():
    if focused_region_id == "":
        return
    
    # Show region info
    _show_region_info(focused_region_id)
    
    # Auto-focus explore button
    if explore_region_button.visible:
        for i in range(buttons.size()):
            if buttons[i] == explore_region_button:
                current_button_index = i
                update_button_focus()
                break
```

#### Controls

| Input | Action |
|-------|--------|
| ↑↓ / Left Stick ↕️ | Navigate buttons |
| ← → / Left Stick ↔️ | Navigate buttons |
| A Button | Interact with focused region OR activate button |
| Enter / Space | Activate button |
| Escape / B | Back to main menu |
| Mouse | Click regions (still supported) |

---

### 7. Unified Exit Dialog (`UnifiedExitDialog.gd`)

#### Dialog Button Navigation

```gdscript
func setup_navigation():
    buttons.clear()
    buttons.append(get_cancel_button())  # "No" first (safe default)
    buttons.append(get_ok_button())      # "Yes" second
    current_button_index = 0
    update_button_focus()
    get_cancel_button().grab_focus()
```

#### Controls

| Input | Action |
|-------|--------|
| ←→ / Left Stick ↔️ | Toggle between No/Yes |
| Enter / Space / A | Activate focused button |
| Escape / B | Cancel (same as No) |

---

## 🔧 Implementation Details

### Input Handler Pattern

All scenes follow this robust input handling pattern:

```gdscript
func _input(event):
    # Viewport safety check (prevent errors during scene transitions)
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
            # ... other keys
    
    # Handle joystick buttons
    elif event is InputEventJoypadButton and event.pressed:
        var viewport = get_viewport()
        if not viewport:
            return
            
        match event.button_index:
            JOY_BUTTON_A:
                activate_current_button()
                viewport.set_input_as_handled()
            JOY_BUTTON_B:
                handle_escape()
                viewport.set_input_as_handled()
    
    # Handle analog stick
    elif event is InputEventJoypadMotion:
        var viewport = get_viewport()
        if not viewport:
            return
            
        if abs(event.axis_value) > 0.5:  # Dead zone
            match event.axis:
                JOY_AXIS_LEFT_Y:
                    if event.axis_value < -0.5:
                        navigate_up()
                        viewport.set_input_as_handled()
                    elif event.axis_value > 0.5:
                        navigate_down()
                        viewport.set_input_as_handled()
```

### Cooldown System

Prevents rapid navigation spam that could cause skipped buttons:

```gdscript
func navigate_down():
    var current_time = Time.get_unix_time_from_system()
    if current_time - last_navigation_time < navigation_cooldown:
        return  # Too soon, ignore input
    
    # ... navigation logic ...
    
    last_navigation_time = current_time
```

### Focus Management

Visual feedback system using Godot's focus system:

```gdscript
func update_button_focus():
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
```

### Button Activation

Programmatically trigger button press:

```gdscript
func activate_current_button():
    if buttons.size() == 0:
        return
    
    if current_button_index >= 0 and current_button_index < buttons.size():
        var target_button = buttons[current_button_index]
        if target_button and is_instance_valid(target_button):
            target_button.emit_signal("pressed")
```

---

## 🛡️ Error Prevention

### Viewport Null Safety

During scene transitions, `get_viewport()` can return null. All input handlers check for this:

```gdscript
func _input(event):
    if not get_viewport():
        return  # Scene is transitioning, ignore input
```

### Navigation State Management

Dialogs disable main menu navigation to prevent conflicts:

```gdscript
func _on_exit_game_pressed():
    navigation_enabled = false  # Disable main menu navigation
    # Show exit dialog
    
func _on_dialog_closed():
    navigation_enabled = true  # Re-enable navigation
```

### Valid Button Checks

All button operations check for validity:

```gdscript
if target_button and is_instance_valid(target_button):
    target_button.emit_signal("pressed")
```

---

## 🎯 Best Practices

### When Adding Navigation to New Scenes

1. **Copy the pattern** from an existing scene
2. **Add navigation variables** at the top of the script
3. **Create `setup_navigation()`** function
4. **Implement `_input()`** handler
5. **Add navigation helper functions**
6. **Test all input methods** (keyboard, joystick, mouse)

### Navigation Function Checklist

- [ ] `setup_navigation()` - Initialize button arrays
- [ ] `_input(event)` - Handle all input types
- [ ] `navigate_up()` - Move focus up
- [ ] `navigate_down()` - Move focus down
- [ ] `navigate_left()` - Move focus left (if applicable)
- [ ] `navigate_right()` - Move focus right (if applicable)
- [ ] `activate_current_button()` - Trigger button press
- [ ] `handle_escape()` - Back/cancel action
- [ ] `update_button_focus()` - Visual focus update

### Testing Checklist

- [ ] All buttons reachable via keyboard
- [ ] All buttons reachable via joystick
- [ ] Focus indicator visible on current button
- [ ] Navigation wraps correctly (if circular)
- [ ] Escape/B button works as expected
- [ ] No input errors during scene transitions
- [ ] Cooldown prevents button skipping
- [ ] Mouse input still works

---

## 📊 Statistics

| Metric | Value |
|--------|-------|
| Scenes with Navigation | 7 |
| Total Navigable Buttons | 50+ |
| Input Types Supported | 3 (Keyboard, Joystick, Mouse) |
| Navigation Patterns | 4 (Linear, Grid, Group, Hybrid) |
| Lines of Navigation Code | ~1500 |
| Average Implementation Time | 30 minutes per scene |

---

## 🐛 Common Issues and Solutions

### Issue: Buttons Get Skipped During Navigation

**Cause**: No cooldown system or cooldown too short

**Solution**:
```gdscript
var navigation_cooldown: float = 0.2  # Increase if needed
```

### Issue: Navigation Doesn't Work After Dialog

**Cause**: Navigation not re-enabled after dialog closes

**Solution**:
```gdscript
dialog.tree_exited.connect(_on_dialog_closed)

func _on_dialog_closed():
    navigation_enabled = true
```

### Issue: "Cannot call method on null value" Errors

**Cause**: Viewport is null during scene transition

**Solution**:
```gdscript
func _input(event):
    if not get_viewport():
        return
    # ... rest of input handling
```

### Issue: Focus Indicator Not Visible

**Cause**: Button theme doesn't define focus style

**Solution**:
```gdscript
# In MenuButtonTheme.tres
Button/styles/focus = ExtResource("MenuButtonStyleHover.tres")
```

---

## 🚀 Advanced Features

### Context-Aware Navigation

Main menu changes button arrays based on current context:

```gdscript
var current_menu_level: String = "main"

func get_current_button_array() -> Array[Button]:
    match current_menu_level:
        "main": return buttons
        "start_game": return submenu_buttons
        "how_to_play": return panel_buttons
```

### Dynamic Button Management

Ethnicity Detection adds buttons during runtime:

```gdscript
func update_navigation_buttons():
    buttons.clear()
    buttons.append(start_button)
    buttons.append(back_button)
    if skip_to_map_button.visible:
        buttons.append(skip_to_map_button)
```

### Region Focus Detection

Indonesia 3D Map uses physics raycasting to detect focused regions:

```gdscript
func _update_region_focus():
    var space_state = get_world_3d().direct_space_state
    var ray_query = PhysicsRayQueryParameters3D.create(...)
    var result = space_state.intersect_ray(ray_query)
    # Process result to update focused_region_id
```

---

## 📚 Related Documentation

- [Button Theme System](2025-10-09_button-theme-system.md)
- [UnifiedExitDialog Customization](2025-10-09_unified-exit-dialog-customization.md)
- [UI Components Variants Guide](2025-10-09_ui-components-variants-guide.md)

---

## ✨ Conclusion

The keyboard and joystick navigation system provides comprehensive controller support across all menu scenes. The consistent implementation pattern makes it easy to maintain and extend, while the robust error handling ensures a smooth player experience even during complex scene transitions.

Key achievements:
- ✅ Full controller support in all menus
- ✅ Consistent navigation patterns
- ✅ Robust error handling
- ✅ Advanced features (grid navigation, region focus)
- ✅ Mouse input still fully supported

