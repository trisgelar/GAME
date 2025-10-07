# Radar System Documentation

## Overview

The Enhanced Radar System is a comprehensive navigation and information display system for the Indonesian Cultural Heritage Exhibition game. It provides real-time location tracking, point-of-interest identification, and interactive navigation features.

## Table of Contents

1. [System Architecture](#system-architecture)
2. [Components](#components)
3. [Icon System](#icon-system)
4. [Implementation Details](#implementation-details)
5. [Usage Guide](#usage-guide)
6. [Troubleshooting](#troubleshooting)
7. [Technical Specifications](#technical-specifications)

## System Architecture

### Core Components

The radar system consists of three main script files:

- **`SimpleRadarSystem.gd`** - Main radar controller and logic
- **`MapPinIcon.gd`** - Custom icon rendering system
- **`PathLine.gd`** - Path visualization component

### File Structure

```
Systems/UI/
├── SimpleRadarSystem.gd      # Main radar controller
├── SimpleRadarSystem.tscn    # Radar scene file
├── MapPinIcon.gd            # Custom icon system
└── PathLine.gd              # Path rendering

Tests/
├── test_radar.tscn          # Basic radar test
└── test_simple_radar.tscn   # Enhanced radar test
```

## Components

### 1. SimpleRadarSystem.gd

**Purpose**: Main radar controller that manages all radar functionality.

**Key Features**:
- Real-time player position tracking
- Dynamic POI (Points of Interest) management
- NPC and artifact detection
- Path visualization
- Input handling (R key toggle)
- Scene-specific configuration

**Configuration Variables**:
```gdscript
@export var radar_size: float = 200.0
@export var radar_scale: float = 0.1
@export var player_icon_color: Color = Color.WHITE
@export var poi_icon_color: Color = Color.YELLOW
@export var npc_icon_color: Color = Color.BLUE
@export var artifact_icon_color: Color = Color.GREEN
@export var path_color: Color = Color.GRAY
```

### 2. MapPinIcon.gd

**Purpose**: Custom icon rendering system using Godot's 2D drawing capabilities.

**Icon Types**:
- **FOOD** - Plate with dots (🍕)
- **CRAFT** - Paintbrush symbol (🎨)
- **CULTURE** - Building with door/window (🏛️)
- **HISTORY** - Book with lines (📚)
- **VOLCANO** - Triangle (🌋)
- **GEOLOGY** - Diamond shape (⛰️)
- **ANCIENT** - Monument symbol (🗿)
- **ARTIFACT** - Diamond with center dot (💎)
- **VENDOR** - Shop with counter (🏪)
- **HISTORIAN** - Person with book (👨‍🏫)
- **GUIDE** - Compass symbol (🧭)
- **PLAYER** - Directional indicator (▶️)

### 3. PathLine.gd

**Purpose**: Simple line rendering for path visualization between POIs.

## Icon System

### Design Philosophy

The icon system is designed using basic geometric shapes inspired by traditional map pin icons:

- **Teardrop-shaped pins** with black outline and colored fill
- **Simple geometric symbols** for easy recognition at small sizes
- **High contrast** for good visibility
- **Consistent style** across all icon types

### Icon Sizing

- **POIs**: 24x24 pixels (largest for importance)
- **NPCs**: 20x20 pixels (medium for interaction)
- **Artifacts**: 16x16 pixels (smallest for collection items)
- **Legend icons**: 16x16 pixels (reference size)

### Color Coding

- **Player**: White (center focus)
- **POIs**: Yellow (points of interest)
- **NPCs**: Blue (interactive characters)
- **Artifacts**: Green (collectible items)
- **Paths**: Gray (navigation routes)

## Implementation Details

### Coordinate System

The radar uses a relative coordinate system:

```gdscript
func world_to_radar_position(world_pos: Vector3) -> Vector2:
    var relative_pos = world_pos - player.global_position
    var radar_pos = Vector2(relative_pos.x, -relative_pos.z) * radar_scale
    return radar_center + radar_pos
```

**Key Points**:
- Player is always at the center (0,0)
- X-axis maps to radar X (left/right)
- Z-axis maps to radar Y (forward/backward, inverted)
- Scale factor controls zoom level

### Object Detection

The system uses Godot's group system for object detection:

```gdscript
# Find objects by group
var players = get_tree().get_nodes_in_group("player")
var npc_list = get_tree().get_nodes_in_group("npc")
var artifact_list = get_tree().get_nodes_in_group("artifact")
```

### Scene-Specific Configuration

Each regional scene has custom POI configurations:

#### PasarScene
- Food Stalls (FOOD icon)
- Craft Market (CRAFT icon)
- Cultural Display (CULTURE icon)

#### TamboraScene
- Volcano Summit (VOLCANO icon)
- Historical Site (HISTORY icon)
- Geological Point (GEOLOGY icon)

#### PapuaScene
- Ancient Site (ANCIENT icon)
- Cultural Center (CULTURE icon)
- Artifact Location (ARTIFACT icon)

### Input Handling

The radar uses `_unhandled_input` for R key detection:

```gdscript
func _unhandled_input(event):
    if event.is_action_pressed("toggle_radar"):
        toggle_radar()
        get_viewport().set_input_as_handled()
```

## Usage Guide

### For Players

1. **Accessing the Radar**:
   - Navigate to any regional scene (Pasar, Tambora, Papua)
   - Press **R key** to toggle radar on/off

2. **Understanding the Display**:
   - **White teardrop**: Your position and facing direction
   - **Colored pins**: Points of interest, NPCs, and artifacts
   - **Gray lines**: Suggested navigation paths
   - **Legend**: Reference guide in top-left corner

3. **Navigation**:
   - Follow gray paths for guided exploration
   - Approach colored pins to interact with objects
   - Use the legend to identify different icon types

### For Developers

#### Adding New POIs

1. **Define POI in scene setup**:
```gdscript
func setup_new_scene_pois():
    poi_list = [
        {
            "name": "New Location",
            "position": Vector3(x, y, z),
            "icon_type": MapPinIcon.IconType.CULTURE,
            "description": "Description text"
        }
    ]
```

2. **Add to scene detection**:
```gdscript
match scene_name:
    "NewScene":
        setup_new_scene_pois()
```

#### Creating Custom Icons

1. **Add new icon type to MapPinIcon.gd**:
```gdscript
enum IconType {
    # ... existing types ...
    NEW_TYPE,        # 🆕
}
```

2. **Implement drawing function**:
```gdscript
func draw_new_type_symbol():
    # Custom drawing code
    draw_circle(Vector2(12, 12), 4, Color.WHITE)
```

3. **Add to icon selection**:
```gdscript
func draw_icon_symbol():
    match icon_type:
        # ... existing cases ...
        IconType.NEW_TYPE:
            draw_new_type_symbol()
```

#### Modifying Radar Appearance

1. **Change colors**:
```gdscript
@export var poi_icon_color: Color = Color.RED  # Change from YELLOW
```

2. **Adjust size**:
```gdscript
@export var radar_size: float = 300.0  # Change from 200.0
```

3. **Modify scale**:
```gdscript
@export var radar_scale: float = 0.05  # Change from 0.1 (more zoom)
```

## Troubleshooting

### Common Issues

#### Radar Not Showing
- **Cause**: Scene not in regional scenes list
- **Solution**: Add scene name to match statement in `find_world_objects()`

#### Icons Not Appearing
- **Cause**: Objects not in correct groups
- **Solution**: Ensure objects are added to "player", "npc", or "artifact" groups

#### Performance Issues
- **Cause**: Too many objects being updated
- **Solution**: Implement object culling or reduce update frequency

#### Input Not Working
- **Cause**: Input action not configured
- **Solution**: Ensure "toggle_radar" action is mapped to R key in project settings

### Debug Information

The system provides extensive logging:

```gdscript
GameLogger.info("SimpleRadarSystem: Player found at " + str(player.global_position))
GameLogger.debug("SimpleRadarSystem: Found " + str(npc_list.size()) + " NPCs")
GameLogger.info("SimpleRadarSystem: Radar system initialized successfully")
```

Check log files in `logs/` directory for detailed information.

## Technical Specifications

### Performance Characteristics

- **Update Frequency**: Every frame when visible
- **Memory Usage**: Minimal (uses 2D drawing)
- **CPU Usage**: Low (simple coordinate calculations)
- **GPU Usage**: Very low (basic 2D rendering)

### Compatibility

- **Godot Version**: 4.3+
- **Platforms**: All platforms supported by Godot
- **Dependencies**: None (self-contained system)

### File Dependencies

```
SimpleRadarSystem.gd
├── MapPinIcon.gd (preload)
├── PathLine.gd (preload)
└── GameLogger (global singleton)
```

### Scene Dependencies

```
SimpleRadarSystem.tscn
├── RadarBorder (ColorRect)
├── RadarCircle (ColorRect)
├── NorthIndicator (Label)
├── PlayerIcon (Control)
├── POIContainer (Control)
├── PathContainer (Control)
└── Legend (VBoxContainer)
```

## Future Enhancements

### Planned Features

1. **Zoom Levels**: Multiple zoom settings for different detail levels
2. **Custom Paths**: Player-defined navigation routes
3. **Filtering**: Toggle visibility of different object types
4. **Mini-map Mode**: Smaller, always-visible radar
5. **3D Radar**: Optional 3D radar view for complex environments

### Extension Points

The system is designed for easy extension:

- **New Icon Types**: Add to MapPinIcon.IconType enum
- **Custom Scenes**: Add to scene detection in find_world_objects()
- **Additional Features**: Extend SimpleRadarSystem.gd with new methods
- **UI Customization**: Modify SimpleRadarSystem.tscn for different layouts

---

## Conclusion

The Enhanced Radar System provides a robust, extensible navigation solution for the Indonesian Cultural Heritage Exhibition game. Its modular design allows for easy customization and extension while maintaining excellent performance and user experience.

For additional support or feature requests, refer to the project documentation or contact the development team.
