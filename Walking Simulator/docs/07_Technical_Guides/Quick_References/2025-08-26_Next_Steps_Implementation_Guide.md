# Next Steps Implementation Guide - SOLID Architecture & Movement Fixes

## Overview
This guide provides step-by-step instructions for implementing the enhanced SOLID architecture and fixing movement issues in the Walking Simulator project.

## Phase 1: Fix Movement Issues

### Step 1: Replace PlayerController with Fixed Version

**Current Issue**: The original PlayerController has mixed concerns and movement issues.

**Solution**: Use the new `CulturalPlayerControllerFixed` that implements SOLID principles.

```gdscript
# In your main scene, replace the old PlayerController script with:
extends CulturalPlayerControllerFixed

# Enable debug mode to monitor movement
@export var debug_mode: bool = true
```

### Step 2: Update Input Actions

Ensure all input actions are properly configured in Project Settings:

1. **Open Project Settings** → **Input Map**
2. **Add/Verify these actions**:
   - `move_forward` (W key)
   - `move_back` (S key)
   - `move_left` (A key)
   - `move_right` (D key)
   - `jump` (Space key)
   - `sprint` (Shift key)
   - `interact` (E key)
   - `inventory` (I key)
   - `ui_cancel` (Escape key)
   - `debug_toggle` (F1 key)

### Step 3: Test Movement System

1. **Run the game** with debug mode enabled
2. **Check console output** for movement debug information
3. **Verify components** are properly initialized
4. **Test all movement inputs** (WASD, Space, Shift)

## Phase 2: Implement Enhanced NPC System

### Step 1: Create NPC Instances

Create NPCs using the new state-based system:

```gdscript
# Example: Creating a Guide NPC
var guide_npc = CulturalNPC.new()
guide_npc.npc_name = "Pak Budi"
guide_npc.cultural_region = "Indonesia Barat"
guide_npc.npc_type = "Guide"
guide_npc.interaction_range = 3.0

# Add dialogue data
guide_npc.dialogue_data = [
	{
		"id": "greeting",
		"message": "Selamat datang! Welcome to our cultural exhibition.",
		"options": [
			{
				"text": "Tell me about this region",
				"next_dialogue": "region_info",
				"consequence": "share_knowledge"
			},
			{
				"text": "Goodbye",
				"consequence": "end_conversation"
			}
		]
	},
	{
		"id": "region_info",
		"message": "Indonesia Barat is known for its traditional markets and street food culture.",
		"options": [
			{
				"text": "Thank you",
				"consequence": "end_conversation"
			}
		]
	}
]

# Add to scene
add_child(guide_npc)
```

### Step 2: Test NPC State Machine

1. **Verify NPC states** are working correctly:
   - Idle state (default behavior)
   - Interacting state (when player approaches)
   - Walking state (random movement)
   - Talking state (dialogue)

2. **Check console output** for state transitions:
   ```
   Pak Budi entered idle state
   Pak Budi entered interacting state
   Pak Budi: Selamat datang! Welcome to our cultural exhibition.
   ```

### Step 3: Add NPC Models

```gdscript
# Load and assign NPC model
	var npc_model = preload("res://Assets/Models/NPC/GuideModel.tscn")
guide_npc.npc_model = npc_model
```

## Phase 3: Implement Event Bus System

### Step 1: Set Up Event Bus

Add the EventBus to your main scene:

```gdscript
# In your main scene
func _ready():
	# Add EventBus singleton
	var event_bus = EventBus.get_instance()
	add_child(event_bus)
	
	# Subscribe to events
	event_bus.subscribe(self, _on_artifact_collected, [EventBus.EventType.ARTIFACT_COLLECTED])
	event_bus.subscribe(self, _on_npc_interaction, [EventBus.EventType.NPC_INTERACTION])
	event_bus.subscribe(self, _on_ui_update, [EventBus.EventType.UI_UPDATE])

func _on_artifact_collected(event: EventBus.Event):
	print("Artifact collected: ", event.data.artifact_name)

func _on_npc_interaction(event: EventBus.Event):
	print("NPC interaction: ", event.data.npc_name)

func _on_ui_update(event: EventBus.Event):
	if event.data.update_type == "dialogue_update":
		show_dialogue_ui(event.data.message, event.data.options)
```

### Step 2: Replace GlobalSignals

Update existing code to use EventBus instead of GlobalSignals:

```gdscript
# Old way (GlobalSignals)
GlobalSignals.on_collect_artifact.emit("Ancient Bowl", "Indonesia Barat")

# New way (EventBus)
EventBus.get_instance().emit_artifact_collected("Ancient Bowl", "Indonesia Barat")
```

## Phase 4: Implement Command Pattern

### Step 1: Set Up Command Manager

```gdscript
# In your main scene
var command_manager: CulturalCommandManager

func _ready():
	# Initialize command manager
	command_manager = CulturalCommandManager.new()
	add_child(command_manager)
	
	# Connect to command events
	command_manager.command_executed.connect(_on_command_executed)
	command_manager.command_undone.connect(_on_command_undone)

func _on_command_executed(command: CulturalActionCommand):
	print("Command executed: ", command.get_description())

func _on_command_undone(command: CulturalActionCommand):
	print("Command undone: ", command.get_description())
```

### Step 2: Add Undo/Redo Input Actions

1. **Add input actions**:
   - `undo` (Ctrl+Z)
   - `redo` (Ctrl+Y)

2. **Test undo/redo functionality**:
   - Collect an artifact
   - Press Ctrl+Z to undo
   - Press Ctrl+Y to redo

## Phase 5: Implement Factory Pattern

### Step 1: Create Cultural Items Using Factory

```gdscript
# Create items using the factory
func create_cultural_items():
	# Artifact
	var artifact_config = {
		"type": "artifact",
		"display_name": "Ancient Ceramic Bowl",
		"description": "A beautifully crafted ceramic bowl from ancient times.",
		"region": "Indonesia Barat",
		"cultural_significance": "This bowl represents traditional pottery techniques."
	}
	
	var artifact = CulturalItemFactory.create_item_from_config(artifact_config)
	
	# Recipe
	var recipe_config = {
		"type": "recipe",
		"display_name": "Traditional Soto Recipe",
		"description": "A traditional Indonesian soup recipe.",
		"region": "Indonesia Tengah",
		"ingredients": ["chicken", "vegetables", "spices"],
		"instructions": "Boil chicken with spices, add vegetables..."
	}
	
	var recipe = CulturalItemFactory.create_item_from_config(recipe_config)
	
	return [artifact, recipe]
```

### Step 2: Load Items from Configuration

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

## Phase 6: Testing and Validation

### Step 1: Unit Testing

Create test scripts for each component:

```gdscript
# Test InputManager
func test_input_manager():
	var input_manager = InputManager.new()
	
	# Test movement input
	input_manager.move_input = Vector2(1, 0)
	assert(input_manager.get_move_input() == Vector2(1, 0))
	
	# Test input signals
	var input_received = false
	input_manager.move_input_updated.connect(func(direction): input_received = true)
	input_manager.move_input = Vector2(0, 1)
	assert(input_received)
```

### Step 2: Integration Testing

```gdscript
# Test complete player system
func test_player_system():
	var player = CulturalPlayerControllerFixed.new()
	
	# Test movement parameters
	player.set_movement_parameters({"max_speed": 5.0})
	assert(player.get_movement_controller().max_speed == 5.0)
	
	# Test camera parameters
	player.set_camera_parameters({"look_sensitivity": 0.03})
	assert(player.get_camera_controller().look_sensitivity == 0.03)
```

### Step 3: Performance Testing

```gdscript
# Monitor performance
func _process(delta):
	# Monitor event bus performance
	var event_bus = EventBus.get_instance()
	var stats = event_bus.get_statistics()
	
	if stats.events_processed > 1000:
		print("High event processing detected: ", stats.events_processed)
```

## Phase 7: Migration Checklist

### ✅ Completed Tasks
- [ ] Created SOLID architecture components
- [ ] Implemented State Pattern for NPCs
- [ ] Created EventBus system
- [ ] Implemented Command Pattern
- [ ] Created Factory Pattern for items
- [ ] Fixed PlayerController movement issues

### 🔄 In Progress Tasks
- [ ] Replace old PlayerController with fixed version
- [ ] Update existing NPCs to use state machine
- [ ] Migrate from GlobalSignals to EventBus
- [ ] Test all movement inputs
- [ ] Validate NPC interactions

### 📋 Next Tasks
- [ ] Create comprehensive test suite
- [ ] Add more NPC types and behaviors
- [ ] Implement save/load system
- [ ] Add performance optimizations
- [ ] Create documentation for new systems

## Troubleshooting

### Movement Issues
**Problem**: Player not moving
**Solution**: 
1. Check input actions are configured
2. Enable debug mode to see input signals
3. Verify MovementController is properly initialized

### NPC Issues
**Problem**: NPCs not responding
**Solution**:
1. Check state machine initialization
2. Verify player reference is set
3. Check interaction range settings

### Event Bus Issues
**Problem**: Events not being received
**Solution**:
1. Ensure EventBus is added to scene tree
2. Check event subscription syntax
3. Verify event types match

## Performance Considerations

### Event Bus Optimization
- Monitor event queue size
- Use event filtering to reduce processing
- Implement event batching for high-frequency events

### State Machine Optimization
- Limit state transitions
- Use object pooling for frequently created states
- Implement state caching

### Factory Pattern Optimization
- Cache frequently used configurations
- Use lazy loading for complex items
- Implement configuration validation

## Conclusion

This implementation provides:
- **Fixed movement system** with proper separation of concerns
- **Enhanced NPC system** with state-based behaviors
- **Event-driven architecture** for decoupled communication
- **Command pattern** for undo/redo functionality
- **Factory pattern** for flexible item creation
- **Comprehensive testing** framework

The SOLID principles ensure the code is maintainable, extensible, and testable while providing a solid foundation for future enhancements.
