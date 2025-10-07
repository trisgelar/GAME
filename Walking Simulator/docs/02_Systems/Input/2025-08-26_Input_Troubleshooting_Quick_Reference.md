# Input Troubleshooting Quick Reference

**Project:** Walking Simulator - Indonesian Cultural Heritage Exhibition  
**Last Updated:** August 25, 2025

## Common Input Issues and Solutions

### 1. Jump Not Working

**Symptoms:**
- Spacebar detected but no jump occurs
- Log shows "Not on floor - applying gravity" continuously
- Player keeps falling

**Quick Fix:**
```gdscript
// Replace this:
if Input.is_action_pressed("jump") and is_on_floor():

// With this:
var is_on_ground = position.y <= 1.1
if Input.is_action_pressed("jump") and is_on_ground:
```

**Root Cause:** Manual movement system requires manual ground detection

### 2. Mouse Camera Control Not Working

**Symptoms:**
- Mouse works in some scenes but not others
- Player movement works but camera doesn't rotate
- UI elements present in problematic scenes

**Quick Fix:**
```gdscript
// In UI Control nodes, set mouse filter:
func _ready():
    mouse_filter = Control.MOUSE_FILTER_IGNORE

// When UI becomes visible:
mouse_filter = Control.MOUSE_FILTER_STOP

// When UI becomes hidden:
mouse_filter = Control.MOUSE_FILTER_IGNORE
```

**Root Cause:** UI elements blocking mouse input propagation

### 3. Input Actions Not Responding

**Symptoms:**
- Keys work but input actions don't
- Inconsistent input behavior

**Quick Fix:**
```gdscript
// Check input map in project.godot
// Verify action names match code
// Test both action and direct key input:
if Input.is_action_pressed("action_name") or Input.is_key_pressed(KEY_CODE):
```

### 4. Scene Loading Errors (ConeShape3D, etc.)

**Symptoms:**
- "Cannot get class 'ConeShape3D'" error
- "Parse Error: Can't create sub resource of type: ConeShape3D"
- "Failed loading resource" for scene files

**Quick Fix:**
```gdscript
// Replace unsupported collision shapes:
// Before:
[sub_resource type="ConeShape3D" id="ConeShape3D_mountain"]

// After:
[sub_resource type="CylinderShape3D" id="CylinderShape3D_mountain"]

// Update references:
shape = SubResource("CylinderShape3D_mountain")
```

**Root Cause:** Unsupported or deprecated resource types in Godot version

## Debug Commands

### Enable Input Debugging
```gdscript
func _unhandled_input(event):
    if event is InputEventKey and event.pressed:
        print("Key pressed - Keycode: ", event.keycode)
    elif event is InputEventMouseMotion:
        print("Mouse motion: ", event.relative)
```

### Check Input Actions
```gdscript
print("move_forward: ", InputMap.has_action("move_forward"))
print("jump: ", InputMap.has_action("jump"))
```

### Test Mouse Filter
```gdscript
print("Mouse filter: ", mouse_filter)
print("Mouse mode: ", Input.get_mouse_mode())
```

## Mouse Filter Modes

| Mode | Behavior | Use Case |
|------|----------|----------|
| `MOUSE_FILTER_IGNORE` | Input passes through | UI hidden, allow game input |
| `MOUSE_FILTER_STOP` | Input captured, stops propagation | UI visible, capture input |
| `MOUSE_FILTER_PASS` | Input captured, allows propagation | Rare, special cases |

## Input Processing Order

1. **UI Elements** with `MOUSE_FILTER_STOP` capture input first
2. **Player Controller** `_unhandled_input()` receives uncaptured input
3. **Physics System** processes movement and collisions

## Testing Checklist

### Before Testing
- [ ] Clear input buffer: `Input.flush_buffered_events()`
- [ ] Set mouse mode: `Input.mouse_mode = Input.MOUSE_MODE_CAPTURED`
- [ ] Check all UI elements mouse filter settings

### During Testing
- [ ] Test movement (WASD)
- [ ] Test jumping (SPACE)
- [ ] Test camera control (Mouse)
- [ ] Test UI interactions
- [ ] Test scene transitions

### After Testing
- [ ] Verify input works in all scenes
- [ ] Check for input conflicts
- [ ] Document any new issues

## Common File Locations

### Input Configuration
- `project.godot` - Input action mappings
- `Player Controller/PlayerController.gd` - Player input handling
- `Systems/UI/*.gd` - UI input handling

### Scene Files
- `main.tscn` - Template scene (working reference)
- `Scenes/IndonesiaBarat/PasarScene.tscn` - Region scenes
- `Scenes/MainMenu/MainMenu.tscn` - Menu scene

## Quick Commands

### Compile and Test
```bash
# Windows
"D:\Portable\Programming\Godot_v4.3-stable_win64.exe\Godot_v4.3-stable_win64.exe" --headless --quit

# Run specific scene
"D:\Portable\Programming\Godot_v4.3-stable_win64.exe\Godot_v4.3-stable_win64.exe" "Scenes/IndonesiaBarat/PasarScene.tscn"
```

### Log Analysis
- Check `log/` directory for debug logs
- Look for input detection messages
- Verify action vs key input differences

## Prevention Tips

1. **Always test input in all scenes** - Don't assume it works everywhere
2. **Use consistent input handling** - Choose physics or manual, not both
3. **Set UI mouse filters appropriately** - IGNORE when hidden, STOP when visible
4. **Add debug logging** - Makes troubleshooting much easier
5. **Document input mappings** - Keep track of what keys/actions do what

---

**For detailed documentation, see:** `docs/2025-08-25_Jump_and_Camera_Input_Error_Resolution.md`
