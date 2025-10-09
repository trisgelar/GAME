# Menu Button Theme Configuration Guide

**Date**: October 9, 2025  
**Purpose**: Guide for customizing button backgrounds in the MainMenu using configurable .tres theme resources

## Overview

The MainMenu buttons now use a configurable theme system that allows you to easily customize button appearances across different states (normal, hover, pressed, disabled) by modifying .tres resource files.

## Theme Resources Location

All button theme resources are located in:
```
Walking Simulator/Resources/Themes/
```

### Theme Files Structure

1. **MenuButtonStyleNormal.tres** - Normal button state
2. **MenuButtonStyleHover.tres** - Hover/focus button state
3. **MenuButtonStylePressed.tres** - Pressed button state
4. **MenuButtonStyleDisabled.tres** - Disabled button state
5. **MenuButtonTheme.tres** - Main theme file that combines all styles

## Button State Images

Current button images are located in:
```
Walking Simulator/Assets/UI/Exit/
```

Available images:
- `standardbut_n.png` - Normal state
- `standardbut_h.png` - Hover state
- `standardbut_p.png` - Pressed state
- `standardbut_d.png` - Disabled state

## How to Customize Button Backgrounds

### Method 1: Change Button Images

To use different button background images:

1. Open one of the style files (e.g., `MenuButtonStyleNormal.tres`)
2. Locate the `[ext_resource]` line:
   ```
   [ext_resource type="Texture2D" uid="..." path="res://Assets/UI/Exit/standardbut_n.png" id="1"]
   ```
3. Change the `path` to point to your new image
4. Save the file

### Method 2: Adjust Texture Margins

Texture margins control how the button texture stretches (9-slice scaling):

1. Open a style file (e.g., `MenuButtonStyleNormal.tres`)
2. Modify these values:
   ```
   texture_margin_left = 8.0    # Left edge non-stretch area
   texture_margin_top = 8.0     # Top edge non-stretch area
   texture_margin_right = 8.0   # Right edge non-stretch area
   texture_margin_bottom = 8.0  # Bottom edge non-stretch area
   ```
3. Larger values = more area that won't stretch
4. Smaller values = less area that won't stretch

### Method 3: Adjust Content Margins

Content margins control the spacing between button edges and text:

1. Open a style file
2. Modify these values:
   ```
   content_margin_left = 16.0   # Space from left edge to text
   content_margin_top = 12.0    # Space from top edge to text
   content_margin_right = 16.0  # Space from right edge to text
   content_margin_bottom = 12.0 # Space from bottom edge to text
   ```
3. Increase for more padding, decrease for less padding

### Method 4: Customize Font Colors

To change button text colors:

1. Open `MenuButtonTheme.tres`
2. Modify the color values:
   ```
   Button/colors/font_color = Color(1, 1, 1, 1)              # Normal text color (white)
   Button/colors/font_hover_color = Color(1, 0.9, 0.7, 1)    # Hover text color (light yellow)
   Button/colors/font_pressed_color = Color(0.9, 0.85, 0.7, 1) # Pressed text color
   Button/colors/font_disabled_color = Color(0.5, 0.5, 0.5, 1) # Disabled text color (gray)
   ```
3. Color format: `Color(Red, Green, Blue, Alpha)` where values range from 0.0 to 1.0

## Applying Theme to New Buttons

To apply this theme to additional buttons in other scenes:

1. Open your scene file (.tscn)
2. Add the theme resource as an external resource:
   ```
   [ext_resource type="Theme" path="res://Resources/Themes/MenuButtonTheme.tres" id="X"]
   ```
3. Apply to your button:
   ```
   [node name="YourButton" type="Button" parent="..."]
   theme = ExtResource("X")
   text = "Button Text"
   ```

## Buttons Currently Using This Theme

The following buttons in MainMenu.tscn use this theme:

### Main Menu Buttons:
- Start Game
- Explore 3D Map
- Ethnic Detection
- Topeng Nusantara
- Load Game
- How to Play
- About Us
- Credits
- Exit Game

### Submenu Buttons:
- Indonesia Barat (region button)
- Indonesia Tengah (region button)
- Indonesia Timur (region button)
- Back to Main Menu (all panels)

## Creating Button Variants

To create different button styles for different purposes:

1. Duplicate the existing style files
2. Rename them (e.g., `MenuButtonStyleNormal_Alternate.tres`)
3. Modify the image paths or margins as needed
4. Create a new theme file that references your new styles
5. Apply the new theme to specific buttons

## Example: Creating a Danger Button Theme

```tres
[gd_resource type="Theme" load_steps=5 format=3]

[ext_resource type="StyleBox" path="res://Resources/Themes/MenuButtonStyleNormal.tres" id="1"]
[ext_resource type="StyleBox" path="res://Resources/Themes/MenuButtonStyleHover.tres" id="2"]
[ext_resource type="StyleBox" path="res://Resources/Themes/MenuButtonStylePressed.tres" id="3"]
[ext_resource type="StyleBox" path="res://Resources/Themes/MenuButtonStyleDisabled.tres" id="4"]

[resource]
Button/styles/normal = ExtResource("1")
Button/styles/hover = ExtResource("2")
Button/styles/pressed = ExtResource("3")
Button/styles/disabled = ExtResource("4")
Button/colors/font_color = Color(1, 0.3, 0.3, 1)        # Red text for danger
Button/colors/font_hover_color = Color(1, 0.5, 0.5, 1)  # Light red on hover
Button/colors/font_pressed_color = Color(0.8, 0.2, 0.2, 1)
```

## Tips

1. **Consistent Design**: Keep all button states visually consistent
2. **Contrast**: Ensure text is readable against button backgrounds
3. **Test All States**: Test hover, press, and disabled states
4. **Backup**: Keep backup copies of original theme files
5. **Version Control**: Commit theme changes with descriptive messages

## Troubleshooting

### Buttons appear stretched or distorted
- Adjust `texture_margin_*` values in the style files
- Ensure margins match the actual border size in your images

### Text is cut off or too close to edges
- Increase `content_margin_*` values in the style files

### Theme not applying
- Check that the theme resource path is correct
- Verify the theme is referenced in the scene's external resources
- Ensure `theme = ExtResource("X")` is set on the button node

### Colors not changing
- Modify colors in the main theme file, not individual style files
- Colors are defined as `Color(R, G, B, A)` with values 0.0-1.0

## Related Files

- MainMenu Scene: `Walking Simulator/Scenes/MainMenu/MainMenu.tscn`
- Button Images: `Walking Simulator/Assets/UI/Exit/`
- Theme Resources: `Walking Simulator/Resources/Themes/`

## Additional Resources

- Godot Theme Documentation: https://docs.godotengine.org/en/stable/classes/class_theme.html
- StyleBoxTexture Documentation: https://docs.godotengine.org/en/stable/classes/class_styleBoxtexture.html

