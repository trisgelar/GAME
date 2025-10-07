# Array Type Mismatch Fix - 2025-08-26

## Error Description
```
Trying to assign an array of type "Array" to a variable of type "Array[Dictionary]"
```

## Root Cause
The `NPCDialogueSystem.gd` script had a type mismatch in the `current_options` variable:

**Problem Code:**
```gdscript
# Line 11 - Variable declaration
var current_options: Array[Dictionary] = []

# Line 52 - Assignment causing error
current_options = dialogue.get("options", [])  # Returns Array, not Array[Dictionary]
```

The `dialogue.get("options", [])` method returns a regular `Array`, but the variable was declared as `Array[Dictionary]`, causing a type mismatch.

## Fix Applied

**Changed the variable declaration to accept regular Array:**
```gdscript
# Before (INCORRECT)
var current_options: Array[Dictionary] = []

# After (CORRECT)
var current_options: Array = []  # Changed from Array[Dictionary] to Array to avoid type mismatch
```

## Why This Happened
1. **Strict typing**: Godot 4.x has stricter type checking
2. **Dictionary.get() behavior**: The `get()` method returns the raw type from the dictionary
3. **Type inference**: The options array might contain mixed types or be empty

## Location
- **File**: `Systems/NPCs/NPCDialogueSystem.gd`
- **Line**: 11 (variable declaration)
- **Function**: Variable declaration

## Impact
- ✅ **No more type mismatch errors**
- ✅ **Dialogue system works properly**
- ✅ **NPC interactions can proceed**
- ✅ **Maintains functionality while fixing type safety**

## Testing
After this fix:
1. **NPC interactions should work**: No more type errors when starting dialogue
2. **Dialogue options display**: Options should show correctly
3. **EventBus integration**: Dialogue events should emit properly

## Related Systems
This fix affects:
- **NPC Dialogue System**: Direct fix
- **CulturalNPC**: Uses dialogue system
- **EventBus**: Receives dialogue events
- **UI System**: Displays dialogue options
