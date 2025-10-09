# UI Components Variants Guide

**Date**: October 9, 2025  
**Purpose**: Comprehensive guide for ColorRect vs TextureRect usage, stretch modes, and UI component variants

## Overview

This guide covers the different types of UI components available in Godot, their use cases, configuration options, and best practices for creating consistent and professional user interfaces.

## 🎯 UI Component Types

### ColorRect - Solid Color Backgrounds
**Best for**: Simple backgrounds, UI panels, color overlays

### TextureRect - Image Display
**Best for**: Complex backgrounds, decorative elements, image content

## 📦 ColorRect Variants

### 1. Solid Background Color
```tres
[node name="Background" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
color = Color(0.14902, 0.152941, 0.12549, 1)
```

**Use Cases**:
- Simple scene backgrounds
- UI panel backgrounds
- Loading screens
- Color overlays

**Color Format**: `Color(Red, Green, Blue, Alpha)`
- Values range from 0.0 to 1.0
- Alpha: 0.0 = transparent, 1.0 = opaque

### 2. Semi-Transparent Overlay
```tres
[node name="Overlay" type="ColorRect" parent="."]
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
color = Color(0, 0, 0, 0.7)  # 70% opacity black
```

**Use Cases**:
- Modal dialogs
- Loading screens
- Dimming background content
- Focus indicators

### 3. Gradient Effect (Using Multiple ColorRects)
```tres
[node name="GradientTop" type="ColorRect" parent="."]
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 0.5
color = Color(0.2, 0.3, 0.5, 1)  # Top color

[node name="GradientBottom" type="ColorRect" parent="."]
anchors_preset = 15
anchor_top = 0.5
anchor_right = 1.0
anchor_bottom = 1.0
color = Color(0.1, 0.2, 0.4, 1)  # Bottom color
```

**Use Cases**:
- Atmospheric backgrounds
- Modern UI designs
- Depth and dimension

## 🖼️ TextureRect Variants

### 1. Centered Image (No Stretching)
```tres
[node name="CenteredImage" type="TextureRect" parent="."]
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -512.0
offset_top = -512.0
offset_right = 512.0
offset_bottom = 512.0
texture = ExtResource("image_resource")
stretch_mode = 5
```

**Use Cases**:
- Logos and branding
- Decorative elements
- High-quality images
- Icons and symbols

### 2. Full Screen Background
```tres
[node name="FullScreenBG" type="TextureRect" parent="."]
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
texture = ExtResource("background_image")
stretch_mode = 1
```

**Use Cases**:
- Scene backgrounds
- Immersive environments
- Game backgrounds

### 3. Aspect Ratio Maintained
```tres
[node name="AspectMaintained" type="TextureRect" parent="."]
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
texture = ExtResource("photo_image")
stretch_mode = 4
```

**Use Cases**:
- Photos and artwork
- Maintaining image integrity
- Professional presentations

### 4. Tiled Pattern
```tres
[node name="TiledPattern" type="TextureRect" parent="."]
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
texture = ExtResource("pattern_texture")
stretch_mode = 3
```

**Use Cases**:
- Textures and patterns
- Seamless backgrounds
- Efficient memory usage

## 🎛️ Stretch Mode Reference

### Stretch Mode 0: Stretch
```tres
stretch_mode = 0
```
- **Behavior**: Stretches to fill exact dimensions
- **Aspect Ratio**: May be distorted
- **Use Case**: UI elements, exact fit requirements

### Stretch Mode 1: Stretch (Same as 0)
```tres
stretch_mode = 1
```
- **Behavior**: Stretches to fill exact dimensions
- **Aspect Ratio**: May be distorted
- **Use Case**: UI backgrounds, panels

### Stretch Mode 2: Tile
```tres
stretch_mode = 2
```
- **Behavior**: Repeats image to fill area
- **Aspect Ratio**: Maintained
- **Use Case**: Seamless patterns, textures

### Stretch Mode 3: Tile (Same as 2)
```tres
stretch_mode = 3
```
- **Behavior**: Repeats image to fill area
- **Aspect Ratio**: Maintained
- **Use Case**: Pattern backgrounds

### Stretch Mode 4: Keep Aspect
```tres
stretch_mode = 4
```
- **Behavior**: Scales to fit, maintains aspect ratio
- **Aspect Ratio**: Always maintained
- **Use Case**: Photos, artwork

### Stretch Mode 5: Keep Aspect Centered
```tres
stretch_mode = 5
```
- **Behavior**: Scales to fit, centers image
- **Aspect Ratio**: Always maintained
- **Use Case**: Professional backgrounds, logos

### Stretch Mode 6: Keep Aspect Centered (No Scale)
```tres
stretch_mode = 6
```
- **Behavior**: Original size, centered
- **Aspect Ratio**: Always maintained
- **Use Case**: Icons, precise positioning

## 🎨 Expand Mode Options

### Expand Mode 0: Fit Width Proportions
```tres
expand_mode = 0
```
- Scales based on width, maintains proportions

### Expand Mode 1: Keep
```tres
expand_mode = 1
```
- Maintains original texture size

### Expand Mode 2: Fit Height Proportions
```tres
expand_mode = 2
```
- Scales based on height, maintains proportions

## 🔧 Advanced Configuration

### Flip Options
```tres
flip_h = true    # Horizontal flip
flip_v = true    # Vertical flip
```

### Modulate (Color Tinting)
```tres
modulate = Color(1, 0.8, 0.8, 1)    # Red tint
modulate = Color(0.8, 0.8, 1, 1)    # Blue tint
modulate = Color(1, 1, 1, 0.7)      # Semi-transparent
modulate = Color(1.5, 1.5, 1.5, 1)  # Brighten
modulate = Color(0.5, 0.5, 0.5, 1)  # Darken
```

### Filter Mode
```tres
filter = true   # Smooth scaling (default)
filter = false  # Pixelated scaling
```

## 📐 Anchor Preset Reference

### Preset 0: Top Left
```tres
anchors_preset = 0
anchor_left = 0.0
anchor_top = 0.0
```

### Preset 1: Top Center
```tres
anchors_preset = 1
anchor_left = 0.5
anchor_top = 0.0
```

### Preset 2: Top Right
```tres
anchors_preset = 2
anchor_left = 1.0
anchor_top = 0.0
```

### Preset 3: Center Left
```tres
anchors_preset = 3
anchor_left = 0.0
anchor_top = 0.5
```

### Preset 4: Center
```tres
anchors_preset = 4
anchor_left = 0.5
anchor_top = 0.5
```

### Preset 5: Center Right
```tres
anchors_preset = 5
anchor_left = 1.0
anchor_top = 0.5
```

### Preset 6: Bottom Left
```tres
anchors_preset = 6
anchor_left = 0.0
anchor_top = 1.0
```

### Preset 7: Bottom Center
```tres
anchors_preset = 7
anchor_left = 0.5
anchor_top = 1.0
```

### Preset 8: Bottom Right
```tres
anchors_preset = 8
anchor_left = 1.0
anchor_top = 1.0
```

### Preset 15: Full Rect
```tres
anchors_preset = 15
anchor_left = 0.0
anchor_top = 0.0
anchor_right = 1.0
anchor_bottom = 1.0
```

## 🎯 Use Case Recommendations

### Main Menu Backgrounds
**Recommended**: TextureRect with Stretch Mode 5
- Professional appearance
- Maintains image quality
- Works on all screen sizes

### UI Panel Backgrounds
**Recommended**: ColorRect or TextureRect with Stretch Mode 1
- Consistent sizing
- Good performance
- Clean appearance

### Decorative Elements
**Recommended**: TextureRect with Stretch Mode 6
- Maintains original size
- Crisp appearance
- Perfect positioning

### Loading Screens
**Recommended**: ColorRect with semi-transparent overlay
- Simple and effective
- Good performance
- Easy to customize

### Game Backgrounds
**Recommended**: TextureRect with Stretch Mode 4 or 5
- Immersive experience
- Maintains aspect ratio
- Professional quality

## 🔄 Component Combinations

### Layered Background System
```tres
# Layer 1: Base color
[node name="BaseBackground" type="ColorRect" parent="."]
anchors_preset = 15
color = Color(0.1, 0.1, 0.1, 1)

# Layer 2: Background image
[node name="BackgroundImage" type="TextureRect" parent="."]
anchors_preset = 8
stretch_mode = 5
texture = ExtResource("bg_image")

# Layer 3: Overlay (optional)
[node name="Overlay" type="ColorRect" parent="."]
anchors_preset = 15
color = Color(0, 0, 0, 0.2)
```

### Responsive UI Panel
```tres
[node name="UIPanel" type="ColorRect" parent="."]
anchors_preset = 15
anchor_left = 0.1
anchor_top = 0.1
anchor_right = 0.9
anchor_bottom = 0.9
color = Color(0.2, 0.2, 0.2, 0.9)

[node name="PanelBorder" type="ColorRect" parent="UIPanel"]
anchors_preset = 15
offset_left = -2.0
offset_top = -2.0
offset_right = 2.0
offset_bottom = 2.0
color = Color(0.5, 0.5, 0.5, 1)
```

## 📊 Performance Considerations

### ColorRect Performance
- **Best**: Very fast rendering
- **Memory**: Minimal memory usage
- **Use Case**: Simple backgrounds, UI elements

### TextureRect Performance
- **Good**: Moderate rendering cost
- **Memory**: Depends on texture size
- **Use Case**: Complex backgrounds, images

### Optimization Tips
1. **Use ColorRect** for simple backgrounds
2. **Compress textures** for smaller file sizes
3. **Use appropriate stretch modes** to avoid unnecessary scaling
4. **Consider texture atlases** for multiple small images
5. **Use modulate** instead of multiple texture variants

## 🎨 Design Patterns

### Modern Flat Design
```tres
# Clean background
[node name="Background" type="ColorRect" parent="."]
color = Color(0.95, 0.95, 0.95, 1)

# Accent panel
[node name="AccentPanel" type="ColorRect" parent="."]
anchors_preset = 1
anchor_top = 0.2
color = Color(0.2, 0.6, 1.0, 1)
```

### Dark Theme
```tres
# Dark background
[node name="Background" type="ColorRect" parent="."]
color = Color(0.1, 0.1, 0.1, 1)

# Dark panel
[node name="Panel" type="ColorRect" parent="."]
anchors_preset = 15
anchor_left = 0.1
anchor_top = 0.1
anchor_right = 0.9
anchor_bottom = 0.9
color = Color(0.2, 0.2, 0.2, 1)
```

### Cultural Theme
```tres
# Warm background
[node name="Background" type="ColorRect" parent="."]
color = Color(0.8, 0.7, 0.5, 1)

# Decorative border
[node name="Border" type="TextureRect" parent="."]
anchors_preset = 15
stretch_mode = 3
texture = ExtResource("cultural_pattern")
```

## 📋 Best Practices Checklist

### When Using ColorRect
- ✅ Use for simple, solid color backgrounds
- ✅ Choose appropriate colors for your theme
- ✅ Consider semi-transparency for overlays
- ✅ Use consistent color schemes across scenes

### When Using TextureRect
- ✅ Choose appropriate stretch mode for your use case
- ✅ Optimize image sizes for performance
- ✅ Use anchor presets for responsive positioning
- ✅ Consider modulate for color variations

### General Guidelines
- ✅ Maintain consistent styling across scenes
- ✅ Test on different screen resolutions
- ✅ Consider accessibility and contrast
- ✅ Document any custom configurations
- ✅ Use descriptive node names

## 🐛 Common Issues and Solutions

### Image Not Displaying
**Problem**: TextureRect shows nothing
**Solution**: Check texture resource path and external resources

### Wrong Aspect Ratio
**Problem**: Image looks stretched
**Solution**: Use stretch_mode 4 or 5 instead of 1

### Poor Performance
**Problem**: Scene loads slowly
**Solution**: Use ColorRect for simple backgrounds, compress textures

### Inconsistent Positioning
**Problem**: UI elements don't align properly
**Solution**: Use consistent anchor presets and offset values

## 📚 Related Documentation

- **Button Theme Guide**: `2025-10-09_button-theme-customization-guide.md`
- **Background Implementation**: `2025-10-09_background-implementation-guide.md`
- **Scene Structure**: See individual scene documentation

---

**Status**: ✅ Complete and Production Ready  
**Last Updated**: October 9, 2025  
**Maintained By**: Game Development Team
