# Multiple Dialog Conflict Fix

**Date:** 2025-09-18  
**Status:** Fixed  
**Issue:** Multiple exclusive dialog conflict  

## 🚨 **Problem**

The error occurred when ESC key was pressed in region scenes:

```
Attempting to make child window exclusive, but the parent window already has another exclusive child.
```

## 🔍 **Root Cause Analysis**

### **Conflicting Systems**
1. **RegionSceneController.gd** - handles ESC with `_input()` (high priority)
2. **GameSceneManager.gd** - handles ESC with `_unhandled_input()` (low priority)

### **Issue Details**
- Both systems were trying to create **exclusive dialogs** simultaneously
- `RegionSceneController` creates `UnifiedExitDialog` (exclusive)
- `GameSceneManager` creates `ConfirmationDialog` (exclusive) 
- Even though `get_viewport().set_input_as_handled()` was called, both dialogs were being created

### **Call Stack**
```
ESC Key Pressed
    ↓
RegionSceneController._input() 
    ↓ creates
UnifiedExitDialog (exclusive)
    ↓ but also triggers
GameSceneManager._unhandled_input()
    ↓ tries to create
ConfirmationDialog (exclusive) ← CONFLICT!
```

## ✅ **Solution**

### **1. Added Dialog Conflict Prevention in GameSceneManager**
```gdscript
func _unhandled_input(event):
    if escape_pressed and is_in_game_scene and not is_transitioning:
        # Check if there's already an active dialog to prevent conflicts
        if UnifiedExitDialog.active_dialog_instance and is_instance_valid(UnifiedExitDialog.active_dialog_instance):
            GameLogger.info("⚠️ GameSceneManager: UnifiedExitDialog already active - skipping GameSceneManager dialog")
            return
        
        # Check if there's already an active dialog in GameSceneManager
        if active_dialog and is_instance_valid(active_dialog):
            GameLogger.info("⚠️ GameSceneManager: GameSceneManager dialog already active - skipping")
            return
        
        # Only create dialog if no conflicts
        handle_escape_in_game_scene()
```

### **2. Added Dialog Conflict Prevention in RegionSceneController**
```gdscript
func _input(event):
    if event.is_action_pressed("ui_cancel"):
        # Check if there's already an active dialog to prevent conflicts
        if UnifiedExitDialog.active_dialog_instance and is_instance_valid(UnifiedExitDialog.active_dialog_instance):
            GameLogger.info("⚠️ RegionSceneController: UnifiedExitDialog already active - ignoring new request")
            get_viewport().set_input_as_handled()
            return
        
        # Only create dialog if no conflicts
        get_viewport().set_input_as_handled()
        _show_exit_confirmation()
```

## 🎯 **Key Improvements**

### **Conflict Detection**
- Both systems now check for existing dialogs before creating new ones
- Uses `UnifiedExitDialog.active_dialog_instance` for cross-system dialog tracking
- Uses `GameSceneManager.active_dialog` for internal dialog tracking

### **Priority System**
- **RegionSceneController** (high priority) - `_input()` method
- **GameSceneManager** (low priority) - `_unhandled_input()` method
- Proper input consumption with `get_viewport().set_input_as_handled()`

### **Defensive Programming**
- Added `is_instance_valid()` checks to prevent null reference errors
- Added comprehensive logging for debugging
- Graceful handling when dialogs already exist

## 🧪 **Testing**

### **Test Cases**
1. ✅ **Single ESC Press** - Only one dialog appears
2. ✅ **Rapid ESC Presses** - No duplicate dialogs
3. ✅ **Dialog Already Open** - Additional ESC presses ignored
4. ✅ **Cross-System Conflicts** - No exclusive dialog conflicts

### **Expected Behavior**
- ESC in region scenes → `UnifiedExitDialog` appears
- ESC in non-region scenes → `GameSceneManager` dialog appears  
- No duplicate or conflicting dialogs
- Proper input consumption prevents event bubbling

## 📊 **Impact**

### **Before Fix**
- ❌ Exclusive dialog conflicts
- ❌ Application crashes/errors
- ❌ Poor user experience

### **After Fix**  
- ✅ Single dialog per ESC press
- ✅ No exclusive dialog conflicts
- ✅ Smooth user experience
- ✅ Proper error handling

## 🔗 **Related Systems**

### **Files Modified**
- `Systems/Core/GameSceneManager.gd` - Added conflict prevention
- `Scenes/RegionSceneController.gd` - Added conflict prevention  

### **Files Referenced**
- `Systems/UI/UnifiedExitDialog.gd` - Static dialog tracking
- All region scene files (PapuaScene, TamboraScene, etc.)

## 🚀 **Future Improvements**

### **Centralized Dialog Management**
Consider implementing a centralized dialog manager to:
- Track all active dialogs system-wide
- Prevent conflicts automatically
- Manage dialog priorities
- Handle dialog queuing if needed

### **Input Event Improvements**
- Implement proper input event priority system
- Use signal-based communication between systems
- Add input event debugging tools

---

**This fix ensures that only one exclusive dialog can be active at a time, preventing the "parent window already has another exclusive child" error.**
