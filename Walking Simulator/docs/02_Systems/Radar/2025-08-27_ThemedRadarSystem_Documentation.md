# Themed Radar System Documentation

## Overview

The Themed Radar System is an enhanced version of the radar system inspired by desert and underwater map designs. It features a progression-based interface with circular nodes, environmental elements, and star ratings, creating a more immersive and visually appealing navigation experience.

## Table of Contents

1. [Design Inspiration](#design-inspiration)
2. [Key Features](#key-features)
3. [System Architecture](#system-architecture)
4. [Progression System](#progression-system)
5. [Environmental Elements](#environmental-elements)
6. [Implementation Details](#implementation-details)
7. [Usage Guide](#usage-guide)
8. [Customization](#customization)

## Design Inspiration

### Desert Map Theme
- **Circular Nodes**: Inspired by level selection maps with numbered progression points
- **Star Ratings**: Visual feedback system showing completion status (1-3 stars)
- **Environmental Decorations**: Rocks, cacti, and desert terrain elements
- **Color Palette**: Warm desert tones (browns, oranges, sandy colors)

### Underwater Map Theme
- **Aquatic Elements**: Seaweed, bubbles, and underwater rock formations
- **Color Palette**: Cool blue tones with green plant life
- **Fluid Design**: Smooth, organic shapes and flowing paths

## Key Features

### 🎯 Progression-Based POIs
- **Circular Node Design**: POIs appear as numbered circular nodes
- **Completion Status**: Visual indicators for completed vs. locked locations
- **Star Rating System**: 1-3 star ratings for completed locations
- **Sequential Progression**: Clear path from Level 1 to Level 3

### 🌍 Environmental Elements
- **Scene-Specific Decorations**: Different environmental elements per region
- **Background Atmosphere**: Adds depth and theme to the radar display
- **Non-Intrusive Design**: Environmental elements don't interfere with navigation

### 🎨 Visual Enhancements
- **Desert Color Palette**: Warm, earthy tones for desert regions
- **Underwater Color Palette**: Cool, aquatic tones for underwater regions
- **Enhanced Borders**: Themed borders matching the environment
- **Improved Path Visualization**: Thicker, more visible path lines

## System Architecture

### Core Components

```
Systems/UI/
├── ThemedRadarSystem.gd      # Main themed radar controller
├── ThemedRadarSystem.tscn    # Themed radar scene file
├── MapPinIcon.gd            # Custom icon system (reused)
└── PathLine.gd              # Path rendering (reused)

Tests/
└── test_themed_radar.tscn   # Themed radar test scene
```

### File Structure

The themed radar system builds upon the existing radar infrastructure:

- **ThemedRadarSystem.gd**: Enhanced radar controller with progression features
- **ThemedRadarSystem.tscn**: Scene file with environmental container
- **Environmental Elements**: Scene-specific decorative elements
- **Progression System**: Level-based POI organization

## Progression System

### POI Structure

Each POI now includes progression information:

```gdscript
{
    "name": "Location Name",
    "position": Vector3(x, y, z),
    "icon_type": MapPinIcon.IconType.CULTURE,
    "description": "Location description - Level X",
    "completed": true,        # Completion status
    "stars": 3               # Star rating (0-3)
}
```

### Visual Indicators

#### Completed POIs
- **Circular Background**: Dark gray circular node
- **Number Label**: White number indicating level (1, 2, 3)
- **Star Rating**: Yellow stars above the node (★)
- **Tooltip**: Detailed description with level information

#### Locked POIs
- **Circular Background**: Dark gray circular node
- **Lock Icon**: White padlock symbol (🔒)
- **Tooltip**: "Locked" status information

### Star Rating System

- **3 Stars (★★★)**: Perfect completion
- **2 Stars (★★☆)**: Good completion
- **1 Star (★☆☆)**: Basic completion
- **0 Stars**: Not completed

## Environmental Elements

### Scene-Specific Elements

#### TamboraScene (Desert Theme)
```gdscript
environmental_elements = [
    {"type": "rock", "position": Vector3(60, 0, 60), "size": Vector2(8, 8)},
    {"type": "rock", "position": Vector3(-40, 0, 30), "size": Vector2(6, 6)},
    {"type": "rock", "position": Vector3(30, 0, -50), "size": Vector2(10, 10)}
]
```

#### PapuaScene (Underwater Theme)
```gdscript
environmental_elements = [
    {"type": "seaweed", "position": Vector3(50, 0, 40), "size": Vector2(6, 12)},
    {"type": "bubble", "position": Vector3(-30, 0, 20), "size": Vector2(4, 4)},
    {"type": "rock", "position": Vector3(15, 0, -40), "size": Vector2(8, 8)}
]
```

#### PasarScene (Market Theme)
```gdscript
environmental_elements = [
    {"type": "stall", "position": Vector3(30, 0, 25), "size": Vector2(10, 8)},
    {"type": "stall", "position": Vector3(-25, 0, 20), "size": Vector2(8, 10)},
    {"type": "decoration", "position": Vector3(5, 0, -30), "size": Vector2(6, 6)}
]
```

### Element Types

| Type | Color | Usage | Description |
|------|-------|-------|-------------|
| rock | Brown (0.6, 0.4, 0.2, 0.8) | Desert/Underwater | Natural rock formations |
| seaweed | Green (0.2, 0.8, 0.2, 0.6) | Underwater | Aquatic plant life |
| bubble | White (1, 1, 1, 0.4) | Underwater | Air bubbles |
| stall | Tan (0.8, 0.6, 0.4, 0.7) | Market | Market stalls |
| decoration | Gold (0.9, 0.7, 0.5, 0.6) | Market | Decorative elements |

## Implementation Details

### Configuration Variables

```gdscript
@export var radar_size: float = 250.0              # Larger radar for more detail
@export var radar_scale: float = 0.08              # More zoom for detailed view
@export var background_color: Color = Color(0.95, 0.85, 0.7, 0.9)  # Light desert sand
@export var border_color: Color = Color(0.6, 0.4, 0.2, 0.8)        # Dark brown border
@export var path_color: Color = Color(0.8, 0.6, 0.4, 0.8)          # Desert sand color
```

### Progression POI Creation

```gdscript
func create_progression_poi_icon(poi: Dictionary) -> Control:
    var icon = Control.new()
    icon.name = "poi_" + poi.name
    icon.custom_minimum_size = Vector2(32, 32)
    icon.size = Vector2(32, 32)
    icon.tooltip_text = poi.description
    
    # Create circular background
    var background = ColorRect.new()
    background.color = Color.DARK_GRAY
    icon.add_child(background)
    
    if poi.completed:
        # Add number label
        var number_label = Label.new()
        number_label.text = str(poi_list.find(poi) + 1)
        number_label.add_theme_color_override("font_color", Color.WHITE)
        icon.add_child(number_label)
        
        # Add stars above
        if poi.stars > 0:
            var star_container = Control.new()
            for i in range(poi.stars):
                var star = Label.new()
                star.text = "★"
                star.add_theme_color_override("font_color", Color.YELLOW)
                star_container.add_child(star)
            icon.add_child(star_container)
    else:
        # Add lock icon
        var lock_label = Label.new()
        lock_label.text = "🔒"
        icon.add_child(lock_label)
    
    return icon
```

### Environmental Element Creation

```gdscript
func create_environmental_icon(element: Dictionary) -> Control:
    var icon = Control.new()
    icon.name = "env_" + element.type
    icon.custom_minimum_size = element.size
    icon.size = element.size
    
    var element_rect = ColorRect.new()
    element_rect.custom_minimum_size = element.size
    element_rect.size = element.size
    
    match element.type:
        "rock":
            element_rect.color = Color(0.6, 0.4, 0.2, 0.8)
        "seaweed":
            element_rect.color = Color(0.2, 0.8, 0.2, 0.6)
        "bubble":
            element_rect.color = Color(1, 1, 1, 0.4)
        "stall":
            element_rect.color = Color(0.8, 0.6, 0.4, 0.7)
        "decoration":
            element_rect.color = Color(0.9, 0.7, 0.5, 0.6)
    
    icon.add_child(element_rect)
    return icon
```

## Usage Guide

### For Players

1. **Accessing the Themed Radar**:
   - Navigate to any regional scene (Pasar, Tambora, Papua)
   - Press **R key** to toggle themed radar on/off

2. **Understanding the Display**:
   - **Circular Nodes**: Points of interest with progression levels
   - **Numbers**: Level indicators (1, 2, 3)
   - **Stars**: Completion ratings (★)
   - **Locks**: Unlocked locations (🔒)
   - **Environmental Elements**: Themed decorations (rocks, seaweed, etc.)

3. **Progression Navigation**:
   - Start with Level 1 locations (numbered "1")
   - Complete objectives to unlock Level 2
   - Achieve higher star ratings for better completion
   - Follow the winding path between locations

### For Developers

#### Adding New Environmental Elements

1. **Define element in scene setup**:
```gdscript
func setup_new_scene_environment():
    environmental_elements = [
        {
            "type": "new_element",
            "position": Vector3(x, y, z),
            "size": Vector2(width, height)
        }
    ]
```

2. **Add element type handling**:
```gdscript
func create_environmental_icon(element: Dictionary) -> Control:
    # ... existing code ...
    match element.type:
        # ... existing cases ...
        "new_element":
            element_rect.color = Color(0.5, 0.5, 0.5, 0.7)  # Custom color
```

#### Modifying Progression System

1. **Add new POI with progression**:
```gdscript
poi_list = [
    {
        "name": "New Location",
        "position": Vector3(x, y, z),
        "icon_type": MapPinIcon.IconType.CULTURE,
        "description": "New location - Level 4",
        "completed": false,
        "stars": 0
    }
]
```

2. **Update completion status**:
```gdscript
# Mark POI as completed
poi.completed = true
poi.stars = 3  # Perfect completion
update_radar_display()
```

## Customization

### Color Themes

#### Desert Theme
```gdscript
@export var background_color: Color = Color(0.95, 0.85, 0.7, 0.9)  # Light sand
@export var border_color: Color = Color(0.6, 0.4, 0.2, 0.8)        # Dark brown
@export var path_color: Color = Color(0.8, 0.6, 0.4, 0.8)          # Sand path
```

#### Underwater Theme
```gdscript
@export var background_color: Color = Color(0.7, 0.9, 1.0, 0.9)    # Light blue
@export var border_color: Color = Color(0.2, 0.4, 0.8, 0.8)        # Dark blue
@export var path_color: Color = Color(0.4, 0.6, 0.9, 0.8)          # Blue path
```

### Size Adjustments

```gdscript
@export var radar_size: float = 300.0              # Larger radar
@export var radar_scale: float = 0.05              # More zoom
```

### Star Rating Customization

```gdscript
# Custom star symbols
star.text = "⭐"  # Full star
star.text = "☆"   # Empty star
star.text = "★"   # Filled star
```

## Comparison with Original Radar

| Feature | Original Radar | Themed Radar |
|---------|----------------|--------------|
| **POI Design** | Teardrop pins | Circular nodes |
| **Progression** | None | Level-based with stars |
| **Environmental** | None | Scene-specific elements |
| **Visual Style** | Basic icons | Map-inspired design |
| **Color Theme** | Standard colors | Desert/underwater themes |
| **User Experience** | Functional | Immersive and engaging |

## Future Enhancements

### Planned Features

1. **Dynamic Themes**: Automatic theme switching based on scene
2. **Animated Elements**: Floating bubbles, swaying seaweed
3. **Sound Effects**: Environmental audio cues
4. **Mini-map Mode**: Smaller, always-visible themed radar
5. **Custom Star Animations**: Animated star ratings

### Extension Points

- **New Environmental Types**: Easy addition of new element types
- **Theme System**: Flexible theme switching mechanism
- **Progression Tracking**: Save/load progression data
- **Achievement System**: Integration with game achievements

---

## Conclusion

The Themed Radar System provides a visually engaging and immersive navigation experience that enhances the player's connection to the game world. Its progression-based design and environmental elements create a more dynamic and appealing interface while maintaining all the functional benefits of the original radar system.

The system is designed to be easily extensible, allowing for new themes, environmental elements, and progression features to be added as the game evolves.
