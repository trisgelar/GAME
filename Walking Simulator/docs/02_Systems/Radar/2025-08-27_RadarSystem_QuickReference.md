# Radar System Quick Reference

## 🚀 Quick Start

### Basic Usage
```gdscript
# Toggle radar visibility
Press R key

# Radar appears in regional scenes only:
# - PasarScene
# - TamboraScene  
# - PapuaScene
```

### File Locations
```
Systems/UI/SimpleRadarSystem.gd    # Main controller
Systems/UI/MapPinIcon.gd           # Icon system
Systems/UI/PathLine.gd             # Path rendering
Tests/test_simple_radar.tscn      # Test scene
```

## 🎯 Icon Types

| Icon | Type | Usage | Size |
|------|------|-------|------|
| 🍕 | FOOD | Food stalls, restaurants | 24x24 |
| 🎨 | CRAFT | Craft markets, workshops | 24x24 |
| 🏛️ | CULTURE | Cultural centers, museums | 24x24 |
| 📚 | HISTORY | Historical sites, libraries | 24x24 |
| 🌋 | VOLCANO | Volcanoes, geological features | 24x24 |
| ⛰️ | GEOLOGY | Rock formations, natural features | 24x24 |
| 🗿 | ANCIENT | Ancient sites, monuments | 24x24 |
| 💎 | ARTIFACT | Collectible items | 16x16 |
| 🏪 | VENDOR | Shopkeepers, merchants | 20x20 |
| 👨‍🏫 | HISTORIAN | Knowledge NPCs | 20x20 |
| 🧭 | GUIDE | Guide NPCs | 20x20 |
| ▶️ | PLAYER | Player position | 12x12 |

## 🔧 Configuration

### Radar Settings
```gdscript
@export var radar_size: float = 200.0      # Radar diameter
@export var radar_scale: float = 0.1       # Zoom level (0.05 = zoomed in, 0.2 = zoomed out)
@export var player_icon_color: Color = Color.WHITE
@export var poi_icon_color: Color = Color.YELLOW
@export var npc_icon_color: Color = Color.BLUE
@export var artifact_icon_color: Color = Color.GREEN
@export var path_color: Color = Color.GRAY
```

### Adding New POI
```gdscript
# In SimpleRadarSystem.gd, add to scene setup:
poi_list = [
    {
        "name": "Location Name",
        "position": Vector3(x, y, z),
        "icon_type": MapPinIcon.IconType.CULTURE,
        "description": "Tooltip text"
    }
]
```

## 🐛 Common Issues

### Radar Not Showing
- ✅ Check if scene name is in `find_world_objects()` match statement
- ✅ Ensure "toggle_radar" action is mapped to R key in project settings
- ✅ Verify radar is instantiated in scene's UI CanvasLayer

### Icons Not Appearing
- ✅ Objects must be in correct groups: "player", "npc", "artifact"
- ✅ Check if objects are valid and in scene
- ✅ Verify icon types are correctly assigned

### Performance Issues
- ✅ Reduce update frequency in `_process()`
- ✅ Implement object culling for distant objects
- ✅ Limit number of visible icons

## 📝 Code Examples

### Adding Custom Icon
```gdscript
# 1. Add to MapPinIcon.gd enum
enum IconType {
    # ... existing types ...
    CUSTOM_TYPE,    # 🆕
}

# 2. Add drawing function
func draw_custom_symbol():
    draw_circle(Vector2(12, 12), 4, Color.WHITE)

# 3. Add to draw_icon_symbol()
func draw_icon_symbol():
    match icon_type:
        # ... existing cases ...
        IconType.CUSTOM_TYPE:
            draw_custom_symbol()
```

### Custom Scene Setup
```gdscript
# 1. Add scene detection
match scene_name:
    "YourScene":
        setup_your_scene_pois()

# 2. Create setup function
func setup_your_scene_pois():
    poi_list = [
        {
            "name": "Your POI",
            "position": Vector3(0, 0, 0),
            "icon_type": MapPinIcon.IconType.CULTURE,
            "description": "Your description"
        }
    ]
```

### Modifying Radar Position
```gdscript
# In SimpleRadarSystem.tscn, change anchors:
anchor_left = 0.0    # Left side
anchor_right = 0.0   # Left side
# or
anchor_left = 1.0    # Right side  
anchor_right = 1.0   # Right side
```

## 🔍 Debug Commands

### Logging
```gdscript
GameLogger.info("SimpleRadarSystem: Custom message")
GameLogger.debug("SimpleRadarSystem: Debug info")
GameLogger.warning("SimpleRadarSystem: Warning message")
```

### Testing
```gdscript
# Test radar in isolation
# Set project.godot main_scene to Tests/test_simple_radar.tscn

# Check log files
# Look in logs/ directory for detailed information
```

## 📊 Performance Tips

- **Object Culling**: Only update visible objects
- **Batch Updates**: Update all positions in single frame
- **Reduce Frequency**: Update every N frames instead of every frame
- **Icon Pooling**: Reuse icon objects instead of creating new ones

## 🎨 UI Customization

### Legend Position
```gdscript
# In SimpleRadarSystem.tscn, modify Legend node:
offset_left = 10.0   # Distance from left
offset_top = 10.0    # Distance from top
```

### Radar Border
```gdscript
# Change border color in setup_radar_border():
radar_border.color = Color(1, 0.5, 1, 0.8)  # Pink/purple
```

### Icon Sizes
```gdscript
# Modify in create_*_icon() functions:
icon.custom_minimum_size = Vector2(32, 32)  # Larger icons
icon.size = Vector2(32, 32)
```

---

## 📞 Support

- **Full Documentation**: `docs/RadarSystem_Documentation.md`
- **Test Files**: `Tests/test_simple_radar.tscn`
- **Log Files**: `logs/` directory
- **Source Code**: `Systems/UI/` directory
