# SOLID Implementation Guide for Walking Simulator

## Overview
This guide provides practical examples of how to implement and use the new SOLID architecture and design patterns in our Walking Simulator project.

## Quick Start: Using the New Architecture

### 1. Setting Up the Refactored Player Controller

```gdscript
# In your main scene, replace the old PlayerController with the new one
extends CharacterBody3D

# The new controller automatically sets up all components
@onready var player_controller = CulturalPlayerControllerRefactored.new()
add_child(player_controller)

# Configure player parameters
player_controller.set_movement_parameters({
	"max_speed": 5.0,
	"acceleration": 25.0,
	"jump_force": 6.0
})

player_controller.set_camera_parameters({
	"look_sensitivity": 0.03,
	"smooth_rotation": true
})
```

### 2. Using the Event Bus System

```gdscript
# Subscribe to events
func _ready():
	var event_bus = EventBus.get_instance()
	event_bus.subscribe(self, _on_artifact_collected, [EventBus.EventType.ARTIFACT_COLLECTED])

# Handle events
func _on_artifact_collected(event: EventBus.Event):
	var artifact_name = event.data.artifact_name
	var region = event.data.region
	print("Collected: ", artifact_name, " from ", region)

# Emit events
func collect_artifact(artifact_name: String, region: String):
	var event_bus = EventBus.get_instance()
	event_bus.emit_artifact_collected(artifact_name, region)
```

### 3. Using the Command Pattern for Cultural Actions

```gdscript
# Create and execute commands
func _on_artifact_interaction(artifact_name: String, region: String):
	var command_manager = CulturalCommandManager.new()
	var command = CollectArtifactCommand.create(artifact_name, region)
	command_manager.execute_command(command)

# Undo/Redo functionality
func _input(event):
	if event.is_action_pressed("undo"):
		command_manager.undo_command()
	elif event.is_action_pressed("redo"):
		command_manager.redo_command()
```

### 4. Using the Factory Pattern for Cultural Items

```gdscript
# Create items using the factory
func create_cultural_items():
	# Create an artifact
	var artifact_config = {
		"type": "artifact",
		"display_name": "Ancient Ceramic Bowl",
		"description": "A beautifully crafted ceramic bowl from ancient times.",
		"region": "Indonesia Barat",
		"cultural_significance": "This bowl represents traditional pottery techniques."
	}
	
	var artifact = CulturalItemFactory.create_item_from_config(artifact_config)
	
	# Create a recipe
	var recipe_config = {
		"type": "recipe",
		"display_name": "Traditional Soto Recipe",
		"description": "A traditional Indonesian soup recipe.",
		"region": "Indonesia Tengah",
		"ingredients": ["chicken", "vegetables", "spices"],
		"instructions": "Boil chicken with spices, add vegetables..."
	}
	
	var recipe = CulturalItemFactory.create_item_from_config(recipe_config)
```

## Architecture Benefits

### 1. Single Responsibility Principle (SRP)

**Before (Monolithic PlayerController)**:
```gdscript
# Old approach - everything in one class
class_name PlayerController
extends CharacterBody3D

func _physics_process(delta):
	# Handle input
	# Handle movement
	# Handle camera
	# Handle interactions
	# Handle UI
	# Handle debug logging
	# ... 200+ lines of mixed concerns
```

**After (Separated Concerns)**:
```gdscript
# New approach - each class has one responsibility
class_name CulturalPlayerControllerRefactored
extends CharacterBody3D

@onready var input_manager: InputManager        # Handles input only
@onready var movement_controller: MovementController  # Handles movement only
@onready var camera_controller: CameraController      # Handles camera only
@onready var interaction_controller: InteractionController  # Handles interactions only
```

### 2. Open/Closed Principle (OCP)

**Adding New Item Types**:
```gdscript
# Extend the factory without modifying existing code
func _register_custom_creators():
	# Register a new item type
	CulturalItemFactory.register_creator(
		CulturalItemFactory.ItemType.CUSTOM_TYPE,
		func(data: Dictionary) -> CulturalItem:
			var item = CulturalItem.new()
			# Custom creation logic
			return item
	)
```

### 3. Dependency Inversion Principle (DIP)

**Before (Direct Dependencies)**:
```gdscript
# Tight coupling
class_name OldInventory
extends Control

func add_item(item: CulturalItem):
	# Direct dependency on UI elements
	$SlotContainer.get_child(0).set_item(item)
	$ProgressLabel.text = "Updated"
```

**After (Interface-Based)**:
```gdscript
# Loose coupling through events
class_name NewInventory
extends Control

func _ready():
	EventBus.get_instance().subscribe(self, _on_item_added, [EventBus.EventType.UI_UPDATE])

func _on_item_added(event: EventBus.Event):
	# Handle item addition through events
	update_display(event.data)
```

## Practical Examples

### 1. Creating a New Cultural Region

```gdscript
# Create region-specific items using the factory
func setup_java_region():
	var java_items = [
		{
			"type": "artifact",
			"display_name": "Wayang Puppet",
			"description": "Traditional shadow puppet from Java.",
			"region": "Java",
			"cultural_significance": "Represents traditional Javanese performing arts."
		},
		{
			"type": "recipe",
			"display_name": "Gudeg Recipe",
			"description": "Traditional Javanese jackfruit stew.",
			"region": "Java",
			"ingredients": ["jackfruit", "coconut milk", "spices"],
			"instructions": "Cook jackfruit with coconut milk and spices..."
		}
	]
	
	for item_config in java_items:
		var item = CulturalItemFactory.create_item_from_config(item_config)
		spawn_item_in_world(item)
```

### 2. Implementing Undo/Redo for Cultural Interactions

```gdscript
# Create a custom command for NPC interactions
class_name NPCInteractionCommand
extends CulturalActionCommand

var npc_name: String
var dialogue_id: String
var previous_state: Dictionary

func execute() -> bool:
	# Execute NPC interaction
	EventBus.get_instance().emit_npc_interaction(npc_name, region)
	previous_state = save_current_state()
	return true

func undo() -> bool:
	# Restore previous state
	restore_state(previous_state)
	return true

# Usage
func _on_npc_interaction(npc_name: String, dialogue_id: String):
	var command = NPCInteractionCommand.new(npc_name, dialogue_id, current_region)
	command_manager.execute_command(command)
```

### 3. Event-Driven Audio System

```gdscript
# Audio system that responds to events
class_name CulturalAudioManager
extends Node

func _ready():
	var event_bus = EventBus.get_instance()
	event_bus.subscribe(self, _on_region_changed, [EventBus.EventType.SESSION_UPDATE])
	event_bus.subscribe(self, _on_artifact_collected, [EventBus.EventType.ARTIFACT_COLLECTED])

func _on_region_changed(event: EventBus.Event):
	if event.data.update_type == "region_changed":
		var region = event.data.region
		play_region_ambient_audio(region)

func _on_artifact_collected(event: EventBus.Event):
	play_collection_sound()
```

### 4. Configuration-Driven Item Creation

```gdscript
# Load items from JSON configuration
func load_items_from_config(config_path: String):
	var file = FileAccess.open(config_path, FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	
	if error == OK:
		var data = json.data
		for region in data:
			var items = data[region]
			for item_config in items:
				item_config["region"] = region
				var item = CulturalItemFactory.create_item_from_config(item_config)
				if item:
					spawn_item_in_world(item)
```

## Testing the New Architecture

### 1. Unit Testing Components

```gdscript
# Test the InputManager
func test_input_manager():
	var input_manager = InputManager.new()
	
	# Simulate input
	input_manager.move_input = Vector2(1, 0)
	assert(input_manager.get_move_input() == Vector2(1, 0))
	
	# Test input changes
	var input_received = false
	input_manager.move_input_updated.connect(func(direction): input_received = true)
	input_manager.move_input = Vector2(0, 1)
	assert(input_received)
```

### 2. Integration Testing

```gdscript
# Test the complete player system
func test_player_system():
	var player = CulturalPlayerControllerRefactored.new()
	
	# Test movement
	player.set_movement_parameters({"max_speed": 5.0})
	assert(player.get_movement_controller().max_speed == 5.0)
	
	# Test camera
	player.set_camera_parameters({"look_sensitivity": 0.03})
	assert(player.get_camera_controller().look_sensitivity == 0.03)
```

## Migration Guide

### 1. Updating Existing Code

**Step 1: Replace PlayerController**
```gdscript
# Old
extends CharacterBody3D
# ... 200+ lines of mixed code

# New
extends CulturalPlayerControllerRefactored
# Components are automatically set up
```

**Step 2: Update Signal Connections**
```gdscript
# Old
GlobalSignals.on_collect_artifact.connect(_on_artifact_collected)

# New
EventBus.get_instance().subscribe(self, _on_artifact_collected, [EventBus.EventType.ARTIFACT_COLLECTED])
```

**Step 3: Update Item Creation**
```gdscript
# Old
var item = CulturalItem.new()
item.display_name = "Artifact"
# ... manual setup

# New
var item = CulturalItemFactory.create_item_from_config({
	"type": "artifact",
	"display_name": "Artifact"
})
```

### 2. Adding New Features

**Adding a New Command Type**:
```gdscript
class_name CustomCommand
extends CulturalActionCommand

func execute() -> bool:
	# Implementation
	return true

func undo() -> bool:
	# Implementation
	return true
```

**Adding a New Event Type**:
```gdscript
# In EventBus.gd
enum EventType {
	# ... existing types
	CUSTOM_EVENT
}

# Add emission method
func emit_custom_event(data: Dictionary):
	emit_event(EventType.CUSTOM_EVENT, data, 1, "custom_system")
```

## Performance Considerations

### 1. Event Bus Optimization
- Use event filtering to reduce unnecessary processing
- Implement event batching for high-frequency events
- Monitor event queue size and adjust max_queue_size

### 2. Command History Management
- Limit command history size to prevent memory issues
- Implement command compression for long sessions
- Save/load command history for session persistence

### 3. Factory Pattern Efficiency
- Cache frequently used item configurations
- Use object pooling for frequently created items
- Implement lazy loading for complex item creation

## Best Practices

### 1. Error Handling
```gdscript
# Always check for null returns
var item = CulturalItemFactory.create_item_from_config(config)
if not item:
	push_error("Failed to create item from config: ", config)
	return
```

### 2. Event Naming
```gdscript
# Use descriptive event names
EventBus.get_instance().emit_event(EventBus.EventType.ARTIFACT_COLLECTED, {
	"artifact_name": "Ancient Bowl",
	"region": "Java",
	"collection_method": "interaction"
})
```

### 3. Command Design
```gdscript
# Make commands reversible
func undo() -> bool:
	# Always restore the exact previous state
	# Include all necessary data in command
	return true
```

## Conclusion

This new architecture provides:
- **Better maintainability** through separated concerns
- **Easier testing** with isolated components
- **Improved extensibility** through patterns like Factory and Command
- **Decoupled communication** through the Event Bus
- **Undo/Redo functionality** for better user experience

The phased implementation approach ensures you can gradually migrate existing code while maintaining functionality.
