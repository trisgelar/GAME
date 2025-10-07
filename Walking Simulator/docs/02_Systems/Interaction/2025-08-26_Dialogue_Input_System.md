# Dialogue Input System - 2025-08-26

## Problem
The user could interact with NPCs using the E key, but couldn't choose dialogue options because:
- Mouse movement was used for camera control
- No keyboard input actions were defined for dialogue choices
- The dialogue system only supported mouse clicks on buttons

## Solution
Added comprehensive keyboard input system for dialogue interactions.

## New Input Actions

### **Dialogue Choice Keys**
- **1 Key**: Select dialogue option 1
- **2 Key**: Select dialogue option 2  
- **3 Key**: Select dialogue option 3
- **4 Key**: Select dialogue option 4

### **Dialogue Navigation Keys**
- **Enter Key**: Continue dialogue or select first option
- **Escape Key**: Cancel/close dialogue

## Implementation Details

### **1. Input Actions Added (project.godot)**
```gdscript
dialogue_choice_1 = Key 1
dialogue_choice_2 = Key 2
dialogue_choice_3 = Key 3
dialogue_choice_4 = Key 4
dialogue_continue = Enter
dialogue_cancel = Escape
```

### **2. Keyboard Input Handling (NPCDialogueUI.gd)**
```gdscript
func _input(event):
    # Handle dialogue choice keys (1, 2, 3, 4)
    if Input.is_action_just_pressed("dialogue_choice_1"):
        select_dialogue_option(0)
    elif Input.is_action_just_pressed("dialogue_choice_2"):
        select_dialogue_option(1)
    # ... etc
```

### **3. Visual Indicators**
- **Button Labels**: Show "[1] Option text", "[2] Option text", etc.
- **Controls Display**: Yellow text showing available keyboard shortcuts
- **Option Numbers**: Clear numbering for each dialogue choice

## How to Use

### **Starting Dialogue**
1. **Walk to NPC** - Enter interaction range
2. **Press E** - Start conversation
3. **Dialogue panel appears** with keyboard controls shown

### **Making Choices**
1. **Press 1-4** - Select specific dialogue option
2. **Press Enter** - Continue or select first option
3. **Press Escape** - Cancel/close dialogue

### **Visual Feedback**
- **Button labels** show keyboard shortcuts: "[1] Tell me about history"
- **Controls indicator** shows: "Controls: [1-4] Choose option, [Enter] Continue, [Esc] Cancel"
- **Highlighted options** when keyboard is used

## Benefits

### **✅ Accessibility**
- **No mouse required** for dialogue choices
- **Keyboard-only navigation** possible
- **Clear visual indicators** for controls

### **✅ User Experience**
- **Consistent controls** across all dialogue
- **Fast selection** with number keys
- **Intuitive navigation** with Enter/Escape

### **✅ Compatibility**
- **Works with mouse** - buttons still clickable
- **Works with keyboard** - full keyboard support
- **No conflicts** with camera controls

## Testing Instructions

### **1. Test Basic Interaction**
1. **Walk to NPC** in Pasar scene
2. **Press E** to start dialogue
3. **Verify** dialogue panel appears with controls

### **2. Test Keyboard Choices**
1. **Press 1-4** to select options
2. **Press Enter** to continue
3. **Press Escape** to cancel

### **3. Test Visual Indicators**
1. **Check** button labels show "[1]", "[2]", etc.
2. **Check** controls indicator is visible
3. **Verify** keyboard shortcuts work

## Technical Notes

### **Input Priority**
- **Dialogue input** only active when dialogue panel is visible
- **Camera controls** remain active when dialogue is hidden
- **No conflicts** between systems

### **Event Handling**
- **Input events** processed in `_input()` function
- **Option selection** calls same functions as mouse clicks
- **Consistent behavior** regardless of input method

### **State Management**
- **Dialogue options** stored in `dialogue_options` array
- **Option indexing** matches keyboard numbers (1-4)
- **Proper cleanup** when dialogue ends
