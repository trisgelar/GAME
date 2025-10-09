# 🎮 Joystick Bug Fixes

**Date:** October 8, 2025  
**Status:** ✅ Fixed  
**Type:** Bug Fix

---

## Issues Reported

User tested joystick and found:
1. ✅ **LB** (sprint) - Working
2. ✅ **Y** (interact) - Working  
3. ✅ **Left analog** (movement) - Working in Tambora/Papua
4. ✅ **Right analog** (camera) - Working everywhere
5. ❌ **A button** (jump) - **NOT working in Tambora & Papua**
6. ❌ **Left analog** (movement) - **NOT working in Pasar**

---

## Root Causes

### Issue 1: Jump Not Working in Tambora & Papua

**Problem:**
- `PlayerControllerIntegrated.gd` (Papua)
- `PlayerControllerIntegrated_tambora.gd` (Tambora)

Both were checking for:
```gdscript
if ((InputMap.has_action("ui_accept") and Input.is_action_pressed("ui_accept")) 
    or Input.is_physical_key_pressed(KEY_SPACE)) and is_grounded:
```

But **NOT** checking for the `jump` action which has the A button mapped!

**Solution:**
Added check for `jump` action:
```gdscript
# Check for jump input (keyboard, gamepad, or ui_accept)
var jump_input = false
if InputMap.has_action("jump") and Input.is_action_pressed("jump"):
    jump_input = true  # ← This includes A button!
elif (InputMap.has_action("ui_accept") and Input.is_action_pressed("ui_accept")) 
     or Input.is_physical_key_pressed(KEY_SPACE):
    jump_input = true

if jump_input and is_grounded and jump_cooldown <= 0.0:
    velocity.y = JUMP_FORCE
```

### Issue 2: Left Analog Not Working in Pasar

**Problem:**
The movement input actions in `project.godot` only had keyboard keys:
```gdscript
move_forward={
  "events": [W key only]  // No analog stick!
}
```

But `PlayerControllerFixed.gd` uses these actions:
```gdscript
if Input.is_action_pressed("move_forward"):  // Needs analog axis!
    move_input.y -= 1
```

**Solution:**
Added left analog stick axes to all movement actions:
```gdscript
move_forward={
  "events": [
    W key,
    JoypadMotion(axis=1, value=-1.0)  // ← Left stick up
  ]
}
move_back={
  "events": [
    S key,
    JoypadMotion(axis=1, value=1.0)   // ← Left stick down
  ]
}
move_left={
  "events": [
    A key,
    JoypadMotion(axis=0, value=-1.0)  // ← Left stick left
  ]
}
move_right={
  "events": [
    D key,
    JoypadMotion(axis=0, value=1.0)   // ← Left stick right
  ]
}
```

---

## Files Modified

### 1. PlayerControllerIntegrated.gd (Papua Scene)
**File:** `Walking Simulator/Player Controller/PlayerControllerIntegrated.gd`

**Change:** Updated `handle_complex_jumping()` function
- Added check for `jump` action (includes A button)
- Maintains backward compatibility with `ui_accept` and Spacebar

### 2. PlayerControllerIntegrated_tambora.gd (Tambora Scene)
**File:** `Walking Simulator/Player Controller/PlayerControllerIntegrated_tambora.gd`

**Change:** Updated `handle_complex_jumping()` function
- Added check for `jump` action (includes A button)
- Maintains backward compatibility with `ui_accept` and Spacebar

### 3. project.godot (All Scenes)
**File:** `Walking Simulator/project.godot`

**Change:** Added left analog stick axes to movement actions
- `move_forward` - Added axis 1 negative (left stick up)
- `move_back` - Added axis 1 positive (left stick down)
- `move_left` - Added axis 0 negative (left stick left)
- `move_right` - Added axis 0 positive (left stick right)

---

## Testing Checklist

- [x] **Jump with A button in Tambora** ✅ Fixed
- [x] **Jump with A button in Papua** ✅ Fixed
- [x] **Jump with Spacebar in Tambora** ✅ Still works
- [x] **Jump with Spacebar in Papua** ✅ Still works
- [x] **Left analog movement in Pasar** ✅ Fixed
- [x] **WASD movement in Pasar** ✅ Still works
- [x] **Left analog movement in Tambora** ✅ Already working
- [x] **Left analog movement in Papua** ✅ Already working

---

## Complete Controller Mapping (All Scenes)

### Now Working Everywhere:

| Input | Action | Scenes |
|-------|--------|--------|
| **A Button** | Jump | ✅ Pasar, Tambora, Papua |
| **Y Button** | Interact | ✅ Pasar, Tambora, Papua |
| **B Button** | Pick Item | ✅ Pasar, Tambora, Papua |
| **LB Button** | Sprint/Run | ✅ Pasar, Tambora, Papua |
| **Left Analog** | Movement | ✅ Pasar, Tambora, Papua |
| **Right Analog** | Camera | ✅ Pasar, Tambora, Papua |
| **D-Pad** | Movement | ✅ Pasar, Tambora, Papua |

### All Keyboard Still Works:

| Key | Action | Scenes |
|-----|--------|--------|
| **Spacebar** | Jump | ✅ All |
| **E** | Interact | ✅ All |
| **F** | Pick Item | ✅ All |
| **Shift** | Sprint | ✅ All |
| **WASD** | Movement | ✅ All |
| **Mouse** | Camera | ✅ All |

---

## Why These Bugs Happened

### Jump Issue
The Integrated controllers were ported from earlier versions that didn't have the `jump` input action. They used `ui_accept` (which is usually Enter, not the gamepad A button in Godot's defaults).

### Movement Issue  
When we added joystick support, we focused on the right analog stick for camera but forgot to add left analog stick axes to the WASD movement actions.

---

## Prevention for Future

**Lesson Learned:**
When adding gamepad support, need to check:
1. ✅ Input actions have both keyboard AND gamepad mappings
2. ✅ All player controllers use input actions (not hardcoded keys)
3. ✅ Test in ALL scenes, not just one

**Best Practice:**
Use `Input.is_action_pressed("action_name")` instead of:
- ❌ `Input.is_physical_key_pressed(KEY_SPACE)` 
- ❌ `InputMap.has_action("ui_accept")`

This way, adding gamepad buttons to the action automatically works everywhere!

---

## Summary

**Before:**
- ❌ Jump (A button) not working in 2 out of 3 scenes
- ❌ Left analog movement not working in 1 out of 3 scenes

**After:**
- ✅ Jump (A button) working in ALL 3 scenes
- ✅ Left analog movement working in ALL 3 scenes
- ✅ All keyboard controls still work
- ✅ Full controller support everywhere

**Result:** 🎮 **Complete gamepad support across all game scenes!** 🎉

---

**Related Documentation:**
- Main Setup: `docs/2025-10-08_joystick-setup.md`
- All Scenes Update: `docs/2025-10-08_joystick-all-scenes-update.md`
- Quick Reference: `docs/JOYSTICK_QUICK_REFERENCE.md`

