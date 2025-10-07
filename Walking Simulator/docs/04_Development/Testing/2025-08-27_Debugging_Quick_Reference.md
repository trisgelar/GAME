# Debugging Quick Reference

## Common Problems & Solutions

### 1. Signal Connection Issues

#### Problem: "Signal is already connected"
```gdscript
# ❌ Wrong
signal.connect(callback)

# ✅ Correct
if not signal.is_connected(callback):
    signal.connect(callback)
```

#### Problem: Signal not firing
```gdscript
# Check signal connection
print("Signal connected: ", signal.get_connections().size())

# Verify signal emission
signal.emit()  # Add debug emit
```

### 2. Collision Detection Problems

#### Problem: Raycast not hitting objects
```gdscript
# Check collision layers
print("Raycast mask: ", raycast.collision_mask)
print("Object layer: ", object.collision_layer)

# Fix: Set correct masks
raycast.collision_mask = 3  # Layers 1 and 2
object.collision_layer = 2  # Layer 2
```

#### Problem: Area3D not detecting
```gdscript
# Check area settings
area.collision_layer = 0  # Don't collide with anything
area.collision_mask = 1   # Detect layer 1 (player)
```

### 3. State Management Issues

#### Problem: State gets stuck
```gdscript
# Add state validation
func validate_state():
    if invalid_state_combination:
        GameLogger.warning("Invalid state detected")
        reset_state()

# Call in _process
func _process(_delta):
    validate_state()
```

#### Problem: Race conditions
```gdscript
# Use cooldowns
var last_action_time: float = 0.0
var action_cooldown: float = 0.1

func perform_action():
    var current_time = Time.get_unix_time_from_system()
    if current_time - last_action_time < action_cooldown:
        return  # Still in cooldown
    last_action_time = current_time
    # Perform action
```

### 4. Input Handling Problems

#### Problem: Input not responding
```gdscript
# Check input mapping
print("Input action pressed: ", Input.is_action_pressed("interact"))

# Verify key codes
func _input(event):
    if event is InputEventKey:
        print("Key pressed: ", event.keycode)
```

#### Problem: Double input triggers
```gdscript
# Use input buffering
var input_buffer: Array = []
var input_cooldown: float = 0.1

func handle_input():
    if Time.get_unix_time_from_system() - last_input_time < input_cooldown:
        return
    process_input_buffer()
```

### 5. Performance Issues

#### Problem: High CPU usage
```gdscript
# Profile with Godot profiler
# Look for:
# - Excessive _process calls
# - Unnecessary calculations
# - Memory leaks

# Use delta time for smooth movement
func _process(delta):
    position += velocity * delta
```

#### Problem: Memory leaks
```gdscript
# Clean up timers
func _exit_tree():
    if timer:
        timer.queue_free()

# Disconnect signals
func _exit_tree():
    if signal.is_connected(callback):
        signal.disconnect(callback)
```

## Debug Script Template

```gdscript
extends Node

var debug_enabled: bool = true
var target_object: Node = null

func _ready():
    if not debug_enabled:
        return
    setup_debug_ui()

func _process(_delta):
    if not debug_enabled:
        return
    update_debug_info()

func setup_debug_ui():
    # Create debug UI elements
    pass

func update_debug_info():
    if target_object:
        print("=== DEBUG INFO ===")
        print("Position: ", target_object.global_position)
        print("State: ", target_object.current_state)
        print("Can interact: ", target_object.can_interact)

func get_debug_info() -> Dictionary:
    return {
        "position": target_object.global_position if target_object else Vector3.ZERO,
        "state": target_object.current_state if target_object else "None",
        "can_interact": target_object.can_interact if target_object else false
    }
```

## Logging Best Practices

### Log Levels
```gdscript
# Use appropriate levels
GameLogger.debug("Technical details")     # For developers
GameLogger.info("General flow")          # For tracking
GameLogger.warning("Potential issues")   # For attention
GameLogger.error("Actual problems")      # For errors
```

### Structured Logging
```gdscript
func log_state_change(old_state: String, new_state: String):
    GameLogger.info("State changed: " + old_state + " -> " + new_state)
    GameLogger.debug("State change details: " + get_state_details())

func log_interaction(object: Node, action: String):
    GameLogger.info("Interaction: " + object.name + " - " + action)
    GameLogger.debug("Interaction details: " + get_interaction_details())
```

## Visual Debugging

### Color-coded States
```gdscript
func update_visual_state():
    var model = get_node("Model")
    if not model:
        return
    
    match current_state:
        "idle":
            model.material.albedo_color = Color.GREY
        "interacting":
            model.material.albedo_color = Color.RED
        "ready":
            model.material.albedo_color = Color.GREEN
```

### Debug UI
```gdscript
func create_debug_ui():
    var debug_panel = Panel.new()
    debug_panel.position = Vector2(10, 10)
    debug_panel.size = Vector2(300, 200)
    
    var debug_label = Label.new()
    debug_label.text = "Debug Info"
    debug_label.position = Vector2(10, 10)
    
    debug_panel.add_child(debug_label)
    add_child(debug_panel)
```

## Testing Checklist

### Before Debugging
- [ ] Reproduce the problem consistently
- [ ] Identify the scope of the issue
- [ ] Create isolated test case
- [ ] Set up debug logging
- [ ] Enable visual debugging

### During Debugging
- [ ] Monitor log output
- [ ] Check state changes
- [ ] Verify input handling
- [ ] Test edge cases
- [ ] Document findings

### After Debugging
- [ ] Implement fix
- [ ] Test in isolated environment
- [ ] Test in main project
- [ ] Update documentation
- [ ] Add regression tests

## Common Godot Issues

### Scene Loading
```gdscript
# Check if scene exists
if not FileAccess.file_exists(scene_path):
    GameLogger.error("Scene not found: " + scene_path)
    return

# Load scene safely
var scene = load(scene_path)
if not scene:
    GameLogger.error("Failed to load scene: " + scene_path)
    return
```

### Node References
```gdscript
# Safe node access
var node = get_node_or_null("NodeName")
if not node:
    GameLogger.warning("Node not found: NodeName")
    return

# Check if node is valid
if not is_instance_valid(node):
    GameLogger.warning("Node is not valid")
    return
```

### Resource Loading
```gdscript
# Load resource safely
var resource = load("res://path/to/resource.tres")
if not resource:
    GameLogger.error("Failed to load resource")
    return
```

## Performance Tips

### Optimization
```gdscript
# Use delta time
func _process(delta):
    position += velocity * delta

# Avoid expensive operations in _process
func _process(_delta):
    if should_update:
        update_expensive_operation()
        should_update = false

# Use object pooling for frequently created objects
var object_pool: Array = []

func get_object():
    if object_pool.is_empty():
        return create_new_object()
    return object_pool.pop_back()

func return_object(obj):
    object_pool.append(obj)
```

### Memory Management
```gdscript
# Clean up resources
func _exit_tree():
    for timer in get_tree().get_nodes_in_group("timers"):
        timer.queue_free()
    
    for signal in get_signal_list():
        if signal.is_connected(callback):
            signal.disconnect(callback)
```

## Quick Commands

### Console Commands
```gdscript
# Print object info
print("Object: ", object.name, " Position: ", object.global_position)

# Check signal connections
print("Signal connections: ", signal.get_connections().size())

# Monitor performance
print("FPS: ", Engine.get_frames_per_second())

# Check memory usage
print("Memory usage: ", OS.get_static_memory_usage())
```

### Debug Functions
```gdscript
func debug_print_tree(node: Node, depth: int = 0):
    var indent = "  ".repeat(depth)
    print(indent + node.name)
    for child in node.get_children():
        debug_print_tree(child, depth + 1)

func debug_print_signals(node: Node):
    print("Signals for " + node.name + ":")
    for signal_name in node.get_signal_list():
        print("  " + signal_name.name)
```
