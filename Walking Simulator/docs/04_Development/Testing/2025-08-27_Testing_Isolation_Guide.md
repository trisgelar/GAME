# Isolated Testing Guide: Solving Persistent Problems

## Overview

This guide demonstrates how to systematically isolate and solve persistent problems in Godot projects by creating focused test cases. This approach is essential for debugging complex systems and ensuring robust code.

## Table of Contents

1. [Why Isolated Testing?](#why-isolated-testing)
2. [The Testing Process](#the-testing-process)
3. [Creating Test Scenes](#creating-test-scenes)
4. [Debugging Strategies](#debugging-strategies)
5. [Case Study: NPC Interaction Problem](#case-study-npc-interaction-problem)
6. [Best Practices](#best-practices)
7. [Troubleshooting Common Issues](#troubleshooting-common-issues)

## Why Isolated Testing?

### Benefits
- **Faster Debugging**: Focus on one problem at a time
- **Reliable Reproduction**: Consistent test environment
- **Clean Validation**: Verify fixes work in isolation
- **Better Code Quality**: Forces systematic thinking
- **Documentation**: Test cases serve as living documentation

### When to Use
- Complex interaction problems
- Performance issues
- UI/UX problems
- System integration issues
- Regression testing

## The Testing Process

### 1. Problem Identification
```markdown
Problem: NPC dialogue UI reappears instantly after moving mouse/WASD
Symptoms: 
- Dialogue appears without pressing E
- UI flickers when moving
- Reinteraction after 3 seconds without moving
```

### 2. Scope Definition
```markdown
Scope: Isolate NPC interaction system
Components to test:
- InteractionController
- CulturalNPC
- Dialogue UI
- Input handling
- State management
```

### 3. Test Environment Creation
```markdown
Test Scene: test_npc_interaction.tscn
Components:
- Simple player (blue cylinder)
- Simple NPC (grey cylinder)
- Ground plane
- Minimal scripts
```

## Creating Test Scenes

### File Structure
```
Tests/
├── test_npc_interaction.tscn          # Main test scene
├── test_npc_interaction_debug.gd      # Debug script
├── TestNPC.gd                         # Simplified NPC
├── README_test_npc_interaction.md     # Test documentation
└── test_*.tscn                        # Other test scenes
```

### Test Scene Setup

#### 1. Minimal Environment
```gdscript
# TestNPC.gd - Simplified version of CulturalNPC
extends CulturalInteractableObject

var npc_name: String = "TestGuide"
var dialogue_active: bool = false
var last_dialogue_time: float = 0.0
var dialogue_cooldown: float = 3.0

func _ready():
    add_to_group("npc")
    setup_interaction_area()
```

#### 2. Focused Components
```gdscript
# Only include essential functionality
func _interact():
    if dialogue_active:
        return
    
    dialogue_active = true
    display_dialogue_ui()
    setup_input_handling()
```

#### 3. Clear Visual Feedback
```gdscript
# Visual indicators for debugging
func show_interaction_available():
    var model = get_node("NPCModel")
    if model and model.has_method("set_material"):
        model.material.albedo_color = Color.GREEN
```

### Debug Script Integration

#### 1. Real-time Monitoring
```gdscript
# test_npc_interaction_debug.gd
func _process(_delta):
    var debug_info = interaction_controller.get_debug_info()
    print("Current interactable: ", debug_info.current_interactable)
    print("NPCs in range: ", debug_info.npcs_in_range)
    print("Dialogue active: ", npc.dialogue_active)
```

#### 2. State Tracking
```gdscript
func print_state_info():
    print("=== STATE INFO ===")
    print("Player position: ", player.global_position)
    print("NPC position: ", npc.global_position)
    print("Distance: ", player.global_position.distance_to(npc.global_position))
    print("Interaction range: ", npc.interaction_range)
```

## Debugging Strategies

### 1. Systematic Logging

#### Log Levels
```gdscript
# Use appropriate log levels
GameLogger.debug("Detailed technical info")    # For developers
GameLogger.info("General flow information")    # For tracking
GameLogger.warning("Potential issues")         # For attention
GameLogger.error("Actual problems")            # For errors
```

#### Structured Logging
```gdscript
func log_interaction_state():
    GameLogger.info("=== INTERACTION STATE ===")
    GameLogger.info("Player near NPC: " + str(is_near_npc))
    GameLogger.info("Can interact: " + str(can_interact))
    GameLogger.info("Dialogue active: " + str(dialogue_active))
    GameLogger.info("Cooldown remaining: " + str(get_cooldown_remaining()))
```

### 2. Visual Debugging

#### Color-coded States
```gdscript
func update_visual_state():
    var model = get_node("NPCModel")
    if dialogue_active:
        model.material.albedo_color = Color.RED
    elif can_interact:
        model.material.albedo_color = Color.GREEN
    else:
        model.material.albedo_color = Color.GREY
```

#### Debug UI
```gdscript
func create_debug_ui():
    var debug_label = Label.new()
    debug_label.text = "Debug Info"
    debug_label.position = Vector2(10, 10)
    add_child(debug_label)
```

### 3. Input Testing

#### Key Press Monitoring
```gdscript
func _input(event):
    if event is InputEventKey and event.pressed:
        GameLogger.debug("Key pressed: " + str(event.keycode))
        if event.keycode == KEY_E:
            GameLogger.info("E key pressed - attempting interaction")
```

#### Input State Tracking
```gdscript
var last_input_time: float = 0.0
var input_cooldown: float = 0.1

func handle_input():
    var current_time = Time.get_unix_time_from_system()
    if current_time - last_input_time < input_cooldown:
        return  # Prevent input spam
    last_input_time = current_time
```

## Case Study: NPC Interaction Problem

### Problem Analysis
```markdown
Original Problem:
- Dialogue UI reappears instantly after mouse/WASD movement
- Reinteraction occurs 3 seconds after saying goodbye
- No clear trigger for unwanted dialogue

Root Causes Identified:
1. Signal connection conflicts
2. Missing cooldown management
3. State machine race conditions
4. Input handling issues
```

### Solution Implementation

#### 1. Anti-Flicker System
```gdscript
# InteractionController.gd
var last_interaction_time: float = 0.0
var interaction_cooldown: float = 0.1

func _process(_delta):
    var current_time = Time.get_unix_time_from_system()
    if current_time - last_interaction_time < interaction_cooldown:
        return  # Prevent rapid interactions
```

#### 2. Robust State Management
```gdscript
var last_interacted_object: CulturalInteractableObject = null
var interaction_history: Array = []
var min_reinteraction_delay: float = 3.0

func record_interaction(obj: CulturalInteractableObject):
    var current_time = Time.get_unix_time_from_system()
    interaction_history.append({
        "object": obj,
        "time": current_time
    })
```

#### 3. Signal Connection Safety
```gdscript
func setup_npc_tracking():
    for npc in get_tree().get_nodes_in_group("npc"):
        var interaction_area = npc.get_node_or_null("InteractionArea")
        if interaction_area:
            # Check if signals are already connected
            if not interaction_area.body_entered.is_connected(_on_npc_area_entered):
                interaction_area.body_entered.connect(_on_npc_area_entered)
```

### Validation Process

#### 1. Test Case Creation
```markdown
Test Case: Basic NPC Interaction
Steps:
1. Move player near NPC (within 3m)
2. Press E to start dialogue
3. Choose option 1, 2, or 3
4. Wait for dialogue to end
5. Move mouse/WASD
6. Verify no unwanted dialogue appears
7. Wait 3 seconds
8. Press E again - should work normally
```

#### 2. Regression Testing
```markdown
Regression Tests:
- Multiple rapid E presses
- Moving during dialogue
- ESC key functionality
- Cooldown timing accuracy
- Signal connection stability
```

## Best Practices

### 1. Test Scene Design

#### Keep It Simple
```gdscript
# Test scenes should be minimal
- Only essential components
- Clear visual indicators
- Focused functionality
- Easy to understand
```

#### Consistent Structure
```gdscript
# Standard test scene layout
TestScene/
├── Player (blue cylinder)
├── TestObject (grey cylinder)
├── Ground (white plane)
├── DebugUI (optional)
└── TestScript (debugging)
```

### 2. Debug Script Standards

#### Essential Information
```gdscript
func get_debug_info() -> Dictionary:
    return {
        "player_position": player.global_position,
        "object_position": test_object.global_position,
        "distance": distance,
        "can_interact": can_interact,
        "state": current_state,
        "last_interaction": last_interaction_time
    }
```

#### Real-time Monitoring
```gdscript
func _process(_delta):
    if debug_enabled:
        print_debug_info()
        update_visual_debug()
```

### 3. Documentation Standards

#### Test Documentation Template
```markdown
# Test: [Test Name]

## Purpose
Brief description of what this test validates

## Setup
1. Required components
2. Scene configuration
3. Script assignments

## Test Steps
1. Step-by-step instructions
2. Expected results
3. Success criteria

## Troubleshooting
Common issues and solutions
```

### 4. Version Control

#### Test Scene Management
```bash
# Keep test scenes in separate branch
git checkout -b feature/npc-interaction-fix
git add Tests/test_npc_interaction.tscn
git add Tests/TestNPC.gd
git commit -m "Add isolated NPC interaction test"

# Merge only after validation
git checkout main
git merge feature/npc-interaction-fix
```

## Troubleshooting Common Issues

### 1. Signal Connection Errors

#### Problem
```
Signal 'gui_focus_changed' is already connected
```

#### Solution
```gdscript
# Always check connection status
if not signal.is_connected(callback):
    signal.connect(callback)
```

### 2. Collision Detection Issues

#### Problem
```
Raycast not detecting objects
```

#### Solution
```gdscript
# Check collision layers and masks
interaction_controller.collision_mask = 3  # Layers 1 and 2
npc.collision_layer = 2  # NPC layer
```

### 3. State Management Problems

#### Problem
```
State gets stuck or inconsistent
```

#### Solution
```gdscript
# Add state validation
func validate_state():
    if dialogue_active and not can_interact:
        GameLogger.warning("Invalid state detected")
        reset_state()
```

### 4. Input Handling Issues

#### Problem
```
Input not responding or double-triggering
```

#### Solution
```gdscript
# Use input buffering and cooldowns
var input_buffer: Array = []
var input_cooldown: float = 0.1

func handle_input():
    if Time.get_unix_time_from_system() - last_input_time < input_cooldown:
        return
    process_input_buffer()
```

## Conclusion

Isolated testing is a powerful approach for solving complex problems systematically. By creating focused test environments, you can:

1. **Identify root causes** more quickly
2. **Validate solutions** reliably
3. **Prevent regressions** with test cases
4. **Improve code quality** through systematic thinking
5. **Document solutions** for future reference

Remember: A well-designed test case is often more valuable than the fix itself, as it prevents the same problem from recurring and serves as documentation for the solution.

## Additional Resources

- [Godot Testing Documentation](https://docs.godotengine.org/en/stable/tutorials/testing/index.html)
- [Debugging Best Practices](https://docs.godotengine.org/en/stable/tutorials/debug/index.html)
- [Signal System Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#signals)
