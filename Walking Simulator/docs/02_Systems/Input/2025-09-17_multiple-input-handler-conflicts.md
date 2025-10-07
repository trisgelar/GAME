# Multiple Input Handler Conflicts Resolution

**Date:** September 17, 2025  
**Author:** AI Assistant  
**Status:** Completed  

## Overview

Resolved critical input handling conflicts in PapuaScene_Terrain3D where multiple `_input()` handlers were simultaneously processing the ESC key, causing duplicate dialogs and Godot engine errors.

## Problem Statement

### Error Symptoms:
```
GameSceneManager.gd:101 @ show_return_to_menu_confirmation(): 
Attempting to make child window exclusive, but the parent window already has another exclusive child
```

### Stack Trace Analysis:
```
<Stack Trace>
GameSceneManager.gd:101 @ show_return_to_menu_confirmation()
GameSceneManager.gd:72 @ handle_escape_in_game_scene()  
GameSceneManager.gd:58 @ _unhandled_input()
```

### Root Cause:
Multiple scripts were simultaneously handling the same ESC key press:
1. **RegionSceneController** (`_input()`)
2. **GameSceneManager** (`_unhandled_input()`) 
3. **PapuaScene_TerrainController** (`_input()`)
4. **PapuaScene_Terrain3D_Initializer** (`_input()`)

## Investigation Process

### 1. Input Handler Discovery
Used grep to find all input handlers in the problematic scene:

```bash
grep -r "_input|ui_cancel|KEY_ESCAPE" Scenes/IndonesiaTimur/
```

**Results**:
- `PapuaScene_TerrainController.gd:1859` - `func _input(event):`
- `PapuaScene_Terrain3D_Initializer.gd:86` - `func _input(event):`  
- `RegionSceneController.gd` - `func _input(event):`

### 2. Handler Purpose Analysis

#### RegionSceneController (`_input()`):
```gdscript
func _input(event):
    if event.is_action_pressed("ui_cancel"):
        # ESC key - show confirmation dialog before returning to 3D map
        _show_exit_confirmation()
```
**Purpose**: Handle ESC for exit confirmation ✅ (Needed)

#### PapuaScene_TerrainController (`_input()`):
```gdscript
func _input(event):
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_F: _on_generate_forest()
            KEY_P: _on_place_psx_assets()  
            KEY_C: # Other terrain controls
```
**Purpose**: Handle terrain development keys (F, P, C) ✅ (Not ESC - Safe)

#### PapuaScene_Terrain3D_Initializer (`_input()`):
```gdscript
func _input(event):
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_F: # Test forest generation
```
**Purpose**: Handle testing keys (F) ✅ (Not ESC - Safe)

#### GameSceneManager (`_unhandled_input()`):
```gdscript
func _unhandled_input(event):
    if event.is_action_pressed("ui_cancel"):
        handle_escape_in_game_scene()
```
**Purpose**: Global ESC fallback ⚠️ (Should be blocked by RegionSceneController)

### 3. Input Handling Order in Godot

Godot processes input in this order:
1. **`_input()`** - All nodes with `_input()` methods (scene tree order)
2. **`_gui_input()`** - GUI/Control nodes  
3. **`_unhandled_input()`** - Nodes with `_unhandled_input()` methods

**Problem**: Multiple `_input()` handlers were all receiving the same ESC key event.

## Solution Implementation

### 1. Aggressive Input Consumption

Enhanced `RegionSceneController._input()` to aggressively consume the ESC event:

```gdscript
func _input(event):
    """Handle input for region scenes"""
    if event.is_action_pressed("ui_cancel"):
        # ESC key - show confirmation dialog before returning to 3D map
        GameLogger.info("🔘 RegionSceneController: ESC key pressed in region scene")
        
        # Aggressively consume the input to prevent other systems from processing it
        get_viewport().set_input_as_handled()     # Mark for viewport
        get_tree().set_input_as_handled()         # Mark for scene tree  
        _show_exit_confirmation()
        return  # Exit function immediately after handling
```

### 2. Input Handling Priority Adjustment

Modified `GameSceneManager` to use `_unhandled_input()` instead of `_input()`:

**Before**:
```gdscript
func _input(event):  # High priority - conflicts with scene handlers
    if event.is_action_pressed("ui_cancel"):
        handle_escape_in_game_scene()
```

**After**:
```gdscript  
func _unhandled_input(event):  # Low priority - only if unhandled
    if event.is_action_pressed("ui_cancel"):
        if is_in_game_scene():
            # Let region scenes handle their own ESC
            return
        else:
            handle_escape_in_game_scene()
```

### 3. Scene-Specific Input Handling

Added logic to let region scenes handle their own ESC:

```gdscript
func _unhandled_input(event):
    if event.is_action_pressed("ui_cancel"):
        GameLogger.info("🎮 GameSceneManager: ESC key in _unhandled_input")
        
        # Check if we're in a region scene that should handle its own ESC
        var current_scene_name = get_current_scene_name()
        if current_scene_name in ["PasarScene", "TamboraScene", "PapuaScene", "PapuaScene_Terrain3D"]:
            GameLogger.info("🎮 In region scene - letting scene handle ESC")
            return  # Let the region scene handle it
        
        # Handle ESC for other scenes
        handle_escape_in_game_scene()
```

## Technical Details

### Input Event Consumption Methods

#### Godot 3.x (Deprecated):
```gdscript
event.set_handled()  # ❌ Not available in Godot 4.x
```

#### Godot 4.x (Current):
```gdscript
get_viewport().set_input_as_handled()  # Mark event as handled for viewport
get_tree().set_input_as_handled()      # Mark event as handled for scene tree
```

### Input Processing Flow

**Before Fix**:
```
ESC Key Press
├── RegionSceneController._input() → Creates dialog
├── GameSceneManager._input() → Creates ANOTHER dialog ❌
├── PapuaScene_TerrainController._input() → Ignores (no ESC handling)
└── PapuaScene_Terrain3D_Initializer._input() → Ignores (no ESC handling)

Result: Multiple dialogs → Godot error
```

**After Fix**:
```
ESC Key Press
├── RegionSceneController._input() → Creates dialog, marks as handled
├── GameSceneManager._unhandled_input() → Event already handled, skips
├── PapuaScene_TerrainController._input() → Event already handled, skips  
└── PapuaScene_Terrain3D_Initializer._input() → Event already handled, skips

Result: Single dialog ✅
```

## Debugging Techniques

### 1. Input Handler Discovery
```bash
# Find all input handlers in a directory
grep -r "_input\|ui_cancel\|KEY_ESCAPE" path/to/scenes/

# Find specific input actions  
grep -r "is_action_pressed.*ui_cancel" path/to/project/
```

### 2. Input Flow Logging
Added comprehensive logging to trace input processing:

```gdscript
# RegionSceneController
func _input(event):
    if event.is_action_pressed("ui_cancel"):
        GameLogger.info("🔘 RegionSceneController: ESC key pressed in region scene")
        
# GameSceneManager  
func _unhandled_input(event):
    if event.is_action_pressed("ui_cancel"):
        GameLogger.info("🎮 GameSceneManager: ESC key in _unhandled_input")
```

### 3. Dialog State Tracking
```gdscript
# UnifiedExitDialog
static var active_dialog_instance: UnifiedExitDialog = null

func show_dialog():
    if active_dialog_instance and is_instance_valid(active_dialog_instance):
        GameLogger.debug("UnifiedExitDialog already active - ignoring new request")
        return
```

## Error Analysis

### Godot Engine Error Details
```
Attempting to make child window exclusive, but the parent window already has another exclusive child
```

**Meaning**: 
- Godot's window system only allows one exclusive child (modal dialog) at a time
- Multiple dialog creation attempts cause this engine-level error
- The error occurs in Godot's internal window management code

### Stack Trace Interpretation
```
GameSceneManager.gd:101 @ show_return_to_menu_confirmation()  # Second dialog attempt
GameSceneManager.gd:72 @ handle_escape_in_game_scene()        # Called by unhandled input
GameSceneManager.gd:58 @ _unhandled_input()                   # Input handler
```

This shows the call chain that led to the duplicate dialog creation.

## Prevention Strategies

### 1. Input Handling Best Practices

**Scene-Specific Input**:
```gdscript
# Use _input() for high-priority, scene-specific input
func _input(event):
    if event.is_action_pressed("my_scene_action"):
        get_viewport().set_input_as_handled()  # Consume the event
        handle_scene_action()
        return
```

**Global Input Fallback**:
```gdscript
# Use _unhandled_input() for global, low-priority input
func _unhandled_input(event):
    if event.is_action_pressed("global_action"):
        handle_global_action()
```

### 2. Dialog Management

**Single Instance Pattern**:
```gdscript
static var active_dialog: MyDialog = null

func show_dialog():
    if active_dialog and is_instance_valid(active_dialog):
        return  # Prevent duplicates
    
    active_dialog = MyDialog.new()
    # ... setup dialog
```

### 3. Input Consumption

**Always consume handled input**:
```gdscript
func _input(event):
    if event.is_action_pressed("my_action"):
        # Handle the action
        handle_my_action()
        
        # Prevent other handlers from processing the same event
        get_viewport().set_input_as_handled()
        return
```

## Testing Results

### Before Fix:
- ❌ ESC in PapuaScene_Terrain3D: Godot engine error
- ❌ Multiple dialogs created simultaneously  
- ❌ Dialog conflicts causing UI freezes
- ❌ Inconsistent input handling behavior

### After Fix:
- ✅ ESC in PapuaScene_Terrain3D: Single dialog, no errors
- ✅ Proper input event consumption
- ✅ Clean dialog creation and management
- ✅ Predictable input handling flow

## Performance Impact

### Input Processing Overhead:
- **Before**: Multiple handlers processing same event (wasteful)
- **After**: Single handler processes event, others skip (efficient)

### Memory Usage:
- **Before**: Multiple dialog instances created (memory leak potential)
- **After**: Single dialog instance managed properly (clean)

## Future Considerations

### 1. Input System Architecture
Consider implementing a centralized input manager for complex scenes:

```gdscript
# InputManager.gd (hypothetical)
class_name InputManager

static func register_input_handler(priority: int, handler: Callable):
    # Register handlers with priority system
    
static func handle_input(event: InputEvent):
    # Process handlers in priority order
    # Stop processing when event is consumed
```

### 2. Scene Communication
For complex input coordination between systems:

```gdscript
# Use signals for input coordination
signal input_consumed(event_type: String)

func _input(event):
    if handle_my_input(event):
        input_consumed.emit("ui_cancel")
```

### 3. Debug Tools
Consider creating input debugging tools:

```gdscript
# InputDebugger.gd (hypothetical)  
func log_input_handlers():
    # List all nodes with _input() methods
    # Show input processing order
    # Highlight potential conflicts
```

This resolution demonstrates the importance of understanding Godot's input processing pipeline and implementing proper event consumption to prevent conflicts in complex scenes.
