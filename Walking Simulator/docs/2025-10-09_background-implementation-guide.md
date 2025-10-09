# Background Implementation Guide

**Date**: October 9, 2025  
**Purpose**: Complete guide for adding and configuring background images in Godot scenes

## Overview

This guide documents the successful implementation of background images in scenes, covering TextureRect usage, positioning, stretching options, and best practices for maintaining visual quality.

## 🎯 What We Achieved

### ✅ **Background Image Implementation**
- Successfully added 1024x1024 background image to MainMenu
- Implemented centered positioning without stretching
- Maintained original image quality and aspect ratio

### ✅ **Flexible Configuration**
- Multiple stretch modes for different use cases
- Easy positioning with anchor presets
- Support for any image size and resolution

### ✅ **Scene Integration**
- Seamless integration with existing UI elements
- Proper layering with background and foreground elements
- Consistent implementation across multiple scenes

## 🛠️ Implementation Process

### Step 1: Add Image Resource

Add the background image as an external resource in the scene file:

```tres
[gd_scene load_steps=4 format=3 uid="..."]
[ext_resource type="Texture2D" path="res://Assets/UI/Gemini_Generated_Image_f0ty58f0ty58f0ty.png" id="7_background_image"]
```

### Step 2: Create BackgroundImage Node

Replace ColorRect with TextureRect for image display:

```tres
[node name="BackgroundImage" type="TextureRect" parent="."]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -512.0
offset_top = -512.0
offset_right = 512.0
offset_bottom = 512.0
grow_horizontal = 2
grow_vertical = 2
texture = ExtResource("7_background_image")
stretch_mode = 5
```

## 📐 Positioning Methods

### Center Positioning (Recommended)
Perfect for images that should maintain their original size:

```tres
anchors_preset = 8          # Center anchor preset
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -512.0        # Half of image width (negative)
offset_top = -512.0         # Half of image height (negative)
offset_right = 512.0        # Half of image width (positive)
offset_bottom = 512.0       # Half of image height (positive)
```

### Full Screen Coverage
For images that should fill the entire screen:

```tres
anchors_preset = 15         # Full rect preset
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
```

### Custom Positioning
For specific placement requirements:

```tres
anchors_preset = 0          # Custom positioning
offset_left = 100.0         # Pixels from left edge
offset_top = 50.0           # Pixels from top edge
offset_right = 1124.0       # Right edge position (100 + 1024)
offset_bottom = 1074.0      # Bottom edge position (50 + 1024)
```

## 🖼️ Stretch Mode Options

### Stretch Mode 3: Tile
**Best for**: Patterns, textures, small images
```tres
stretch_mode = 3
```
- Repeats image to fill the area
- Maintains original image size
- Good for seamless patterns

### Stretch Mode 4: Keep Aspect
**Best for**: Photos, maintaining aspect ratio
```tres
stretch_mode = 4
```
- Scales image to fit area
- Maintains aspect ratio
- May leave empty space

### Stretch Mode 5: Keep Aspect Centered
**Best for**: Our use case - centered images
```tres
stretch_mode = 5
```
- Scales image to fit area
- Maintains aspect ratio
- Centers the image
- May crop parts of the image

### Stretch Mode 6: Keep Aspect Centered (No Scale)
**Best for**: Exact size display
```tres
stretch_mode = 6
```
- Displays image at original size
- Maintains aspect ratio
- Centers the image
- No scaling applied

### Stretch Mode 1: Stretch
**Best for**: UI elements, exact fit
```tres
stretch_mode = 1
```
- Stretches to fill entire area
- May distort the image
- Good for UI backgrounds

## 🎨 Background Image Variants

### 1. Centered Image (Our Implementation)
```tres
[node name="BackgroundImage" type="TextureRect" parent="."]
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -512.0
offset_top = -512.0
offset_right = 512.0
offset_bottom = 512.0
stretch_mode = 5
texture = ExtResource("background_image")
```

### 2. Full Screen Background
```tres
[node name="BackgroundImage" type="TextureRect" parent="."]
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
stretch_mode = 1
texture = ExtResource("background_image")
```

### 3. Tiled Pattern Background
```tres
[node name="BackgroundImage" type="TextureRect" parent="."]
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
stretch_mode = 3
texture = ExtResource("pattern_image")
```

### 4. Aspect Ratio Maintained Background
```tres
[node name="BackgroundImage" type="TextureRect" parent="."]
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
stretch_mode = 4
texture = ExtResource("background_image")
```

## 🎯 Use Cases and Recommendations

### Main Menu Backgrounds
**Recommended**: Stretch Mode 5 (Keep Aspect Centered)
- Maintains image quality
- Works with any screen resolution
- Professional appearance

### UI Panel Backgrounds
**Recommended**: Stretch Mode 1 (Stretch)
- Fills exact panel size
- Good for UI elements
- Consistent appearance

### Decorative Elements
**Recommended**: Stretch Mode 6 (Keep Aspect Centered, No Scale)
- Maintains original size
- Perfect for logos, icons
- Crisp appearance

### Pattern Backgrounds
**Recommended**: Stretch Mode 3 (Tile)
- Repeats seamlessly
- Good for textures
- Efficient memory usage

## 🔧 Advanced Configuration

### Flip Options
Add horizontal or vertical flipping:
```tres
flip_h = true    # Flip horizontally
flip_v = true    # Flip vertically
```

### Modulate (Color Tinting)
Apply color tinting to the image:
```tres
modulate = Color(1, 0.8, 0.8, 1)  # Red tint
modulate = Color(0.8, 0.8, 1, 1)  # Blue tint
modulate = Color(1, 1, 1, 0.7)    # Semi-transparent
```

### Expand Mode
Control how the texture expands:
```tres
expand_mode = 1  # Keep (maintain original size)
expand_mode = 0  # Fit Width Proportions
expand_mode = 2  # Fit Height Proportions
```

## 📊 Image Size Guidelines

### Recommended Sizes
- **Main Menu**: 1024x1024 (square, centered)
- **Full Screen**: 1920x1080 (16:9 ratio)
- **UI Panels**: Match panel dimensions
- **Patterns**: 256x256 or 512x512 (tileable)

### Aspect Ratios
- **Square**: 1:1 (1024x1024) - Good for centered images
- **Widescreen**: 16:9 (1920x1080) - Good for full screen
- **Portrait**: 9:16 (1080x1920) - Good for mobile
- **Ultrawide**: 21:9 (2560x1080) - Good for ultrawide monitors

## 🎨 Color vs Texture Backgrounds

### ColorRect (Solid Colors)
```tres
[node name="Background" type="ColorRect" parent="."]
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
color = Color(0.14902, 0.152941, 0.12549, 1)
```

**Best for**:
- Solid color backgrounds
- Simple UI elements
- Performance-critical scenarios

### TextureRect (Images)
```tres
[node name="BackgroundImage" type="TextureRect" parent="."]
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
texture = ExtResource("background_image")
```

**Best for**:
- Complex backgrounds
- Decorative elements
- Brand imagery
- Photographic content

## 🔄 Scene Integration Best Practices

### Layering Order
1. **Background ColorRect** (bottom layer)
2. **Background Image** (middle layer)
3. **UI Elements** (top layer)

### Performance Considerations
- Use appropriate image sizes
- Compress images for smaller file sizes
- Consider using atlases for multiple small images
- Use ColorRect for simple backgrounds when possible

### Responsive Design
- Test on different screen resolutions
- Use anchor presets for responsive positioning
- Consider multiple background variants for different aspect ratios

## 📋 Implementation Checklist

When adding background to a scene:

1. ✅ **Prepare Image**: Ensure image is properly sized and optimized
2. ✅ **Add Resource**: Include image in scene's external resources
3. ✅ **Create Node**: Add TextureRect node with appropriate settings
4. ✅ **Set Anchors**: Choose correct anchor preset for positioning
5. ✅ **Configure Stretch**: Select appropriate stretch mode
6. ✅ **Test Sizing**: Verify appearance on different screen sizes
7. ✅ **Layer Properly**: Ensure correct z-order with other elements

## 🐛 Troubleshooting

### Image Not Displaying
**Problem**: Background image doesn't appear
**Solutions**:
1. Check image path is correct
2. Verify image is added to external resources
3. Ensure TextureRect node is properly configured
4. Check if image is behind other UI elements

### Image Stretched/Distorted
**Problem**: Background image looks wrong
**Solutions**:
1. Change stretch_mode to 5 (Keep Aspect Centered)
2. Adjust anchor settings for proper positioning
3. Check image dimensions vs display area

### Performance Issues
**Problem**: Scene loads slowly with background
**Solutions**:
1. Compress the background image
2. Use smaller image resolution
3. Consider using ColorRect for simple backgrounds

### Wrong Positioning
**Problem**: Background image in wrong location
**Solutions**:
1. Adjust offset values for precise positioning
2. Use different anchor presets
3. Check grow_horizontal and grow_vertical settings

## 📊 Implementation Statistics

### Files Modified
- **MainMenu.tscn**: Background image added
- **EthnicityDetection.tscn**: Background image configured
- **TopengNusantara scenes**: Background images configured

### Images Used
- **Main Menu**: Gemini_Generated_Image_f0ty58f0ty58f0ty.png (1024x1024)
- **Format**: PNG with transparency support
- **Size**: Optimized for performance

### Benefits Achieved
- ✅ **Visual Appeal**: Professional background imagery
- ✅ **Consistency**: Unified visual style across scenes
- ✅ **Flexibility**: Easy to change and customize
- ✅ **Performance**: Optimized image usage

## 🔮 Future Enhancements

### Possible Improvements
1. **Animated Backgrounds**: Add subtle animations to background images
2. **Dynamic Backgrounds**: Change backgrounds based on game state
3. **Parallax Effects**: Multiple background layers with parallax scrolling
4. **Video Backgrounds**: Support for video backgrounds
5. **Procedural Backgrounds**: Generate backgrounds dynamically

### Advanced Features
1. **Background Gallery**: Multiple background options per scene
2. **User Customization**: Allow players to choose backgrounds
3. **Seasonal Themes**: Backgrounds that change with time/events
4. **Accessibility**: High-contrast background options

## 📚 Related Documentation

- **Button Theme Guide**: `2025-10-09_button-theme-customization-guide.md`
- **UI Components Guide**: `2025-10-09_ui-components-variants-guide.md`
- **Scene Structure**: See individual scene documentation

---

**Status**: ✅ Complete and Production Ready  
**Last Updated**: October 9, 2025  
**Maintained By**: Game Development Team
