# Font Configuration Guide

**Date:** 2025-09-18  
**Status:** Configuration Guide  
**Purpose:** How to configure and use fonts in the Walking Simulator project  

## 📁 **Available Fonts**

Your project has three excellent font families:

### **1. Gentium Book Plus (Academic/Body Text)**
- **Purpose**: Body text, dialogue, academic content
- **License**: SIL Open Font License (free for commercial use)
- **Variants**:
  - `GentiumBookPlus-Regular.ttf` - Normal text
  - `GentiumBookPlus-Bold.ttf` - Bold text
  - `GentiumBookPlus-Italic.ttf` - Italic text
  - `GentiumBookPlus-BoldItalic.ttf` - Bold italic

### **2. Rooters (Display/Headers)**
- **Purpose**: Headers, titles, decorative text
- **Variants**:
  - `Rooters.ttf` / `Rooters.otf` - Regular
  - `Rooters Italic.ttf` / `Rooters Italic.otf` - Italic

### **3. Source Sans 3 (UI/Interface)**
- **Purpose**: UI elements, buttons, system text
- **Type**: Variable font with weight control
- **Variants**:
  - `SourceSans3-VariableFont_wght.ttf` - Variable weight
  - `SourceSans3-Italic-VariableFont_wght.ttf` - Variable italic
  - Static folder with specific weights (ExtraLight to Black)

## 🎨 **Font Configuration Methods**

### **Method 1: Create a Global Theme Resource**

Create a theme resource file for consistent styling across your project:

```gdscript
# Assets/Themes/GlobalTheme.tres
[gd_resource type="Theme" format=3]

[ext_resource type="FontFile" path="res://Assets/Fonts/GentiumBookPlus-Regular.ttf" id="1_body_font"]
[ext_resource type="FontFile" path="res://Assets/Fonts/Rooters.ttf" id="2_header_font"]
[ext_resource type="FontFile" path="res://Assets/Fonts/SourceSans3-VariableFont_wght.ttf" id="3_ui_font"]

[resource]
default_font = ExtResource("3_ui_font")
default_font_size = 16

# Button styles
Button/fonts/font = ExtResource("3_ui_font")
Button/font_sizes/font_size = 16
Button/colors/font_color = Color(0.9, 0.9, 0.9, 1)
Button/colors/font_pressed_color = Color(1, 1, 1, 1)

# Label styles
Label/fonts/font = ExtResource("1_body_font")
Label/font_sizes/font_size = 16
Label/colors/font_color = Color(0.9, 0.9, 0.9, 1)

# Header labels (for titles)
HeaderLabel/fonts/font = ExtResource("2_header_font")
HeaderLabel/font_sizes/font_size = 24
HeaderLabel/colors/font_color = Color(1, 0.9, 0.7, 1)

# Rich text labels (for dialogue)
RichTextLabel/fonts/normal_font = ExtResource("1_body_font")
RichTextLabel/font_sizes/normal_font_size = 16
RichTextLabel/colors/default_color = Color(0.9, 0.9, 0.9, 1)
```

### **Method 2: Direct Font Assignment in Scenes**

For individual UI elements:

```gdscript
# In your scene script
@onready var title_label: Label = $TitleLabel
@onready var body_label: Label = $BodyLabel
@onready var ui_button: Button = $UIButton

func _ready():
    # Load fonts
    var header_font = load("res://Assets/Fonts/Rooters.ttf")
    var body_font = load("res://Assets/Fonts/GentiumBookPlus-Regular.ttf")
    var ui_font = load("res://Assets/Fonts/SourceSans3-VariableFont_wght.ttf")
    
    # Apply fonts
    title_label.add_theme_font_override("font", header_font)
    title_label.add_theme_font_size_override("font_size", 24)
    
    body_label.add_theme_font_override("font", body_font)
    body_label.add_theme_font_size_override("font_size", 16)
    
    ui_button.add_theme_font_override("font", ui_font)
    ui_button.add_theme_font_size_override("font_size", 16)
```

### **Method 3: Create Font Resources**

Create individual font resources for easier management:

```gdscript
# Assets/Fonts/HeaderFont.tres
[gd_resource type="FontFile" format=3]

[resource]
data = preload("res://Assets/Fonts/Rooters.ttf")
cache/0/16/0/ascent = 12.0
cache/0/16/0/descent = 4.0
# ... other cache settings
```

## 🎯 **Recommended Font Usage**

### **Cultural Walking Simulator Context:**

| UI Element | Recommended Font | Size | Purpose |
|------------|------------------|------|---------|
| **Main Titles** | Rooters | 28-32px | Game title, region names |
| **Section Headers** | Rooters | 20-24px | Scene titles, menu sections |
| **Body Text** | Gentium Book Plus | 16-18px | Dialogue, descriptions |
| **UI Buttons** | Source Sans 3 | 14-16px | Interface elements |
| **Small UI Text** | Source Sans 3 | 12-14px | Status, hints, labels |
| **Cultural Content** | Gentium Book Plus | 16-20px | Educational content |

### **Example Implementation:**

```gdscript
# Systems/UI/CulturalThemeManager.gd
class_name CulturalThemeManager
extends Node

static var header_font: FontFile
static var body_font: FontFile  
static var ui_font: FontFile

static func _static_init():
    # Load fonts once at startup
    header_font = load("res://Assets/Fonts/Rooters.ttf")
    body_font = load("res://Assets/Fonts/GentiumBookPlus-Regular.ttf")
    ui_font = load("res://Assets/Fonts/SourceSans3-VariableFont_wght.ttf")

static func apply_header_style(label: Label, size: int = 24):
    label.add_theme_font_override("font", header_font)
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", Color(1, 0.9, 0.7))

static func apply_body_style(label: Label, size: int = 16):
    label.add_theme_font_override("font", body_font)
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))

static func apply_ui_style(control: Control, size: int = 16):
    control.add_theme_font_override("font", ui_font)
    control.add_theme_font_size_override("font_size", size)
```

## 🔧 **Font Import Settings**

Your fonts are already properly imported with good settings:

### **Current Import Settings:**
- **Antialiasing**: Enabled (smooth edges)
- **Hinting**: Enabled (better readability)
- **Subpixel Positioning**: Enabled (crisp text)
- **Compression**: Enabled (smaller file size)
- **System Fallback**: Enabled (fallback if font fails)

### **Recommended Settings for Different Uses:**

#### **For UI Text (Source Sans 3):**
```ini
antialiasing=1
hinting=1
subpixel_positioning=4
oversampling=0.0
msdf_pixel_range=8
msdf_size=48
```

#### **For Body Text (Gentium Book Plus):**
```ini
antialiasing=1
hinting=1
subpixel_positioning=4
oversampling=0.0
# Slightly higher quality for readability
msdf_pixel_range=10
msdf_size=64
```

#### **For Headers (Rooters):**
```ini
antialiasing=1
hinting=1
subpixel_positioning=4
oversampling=0.0
# Higher quality for large display text
msdf_pixel_range=12
msdf_size=72
```

## 🎮 **Implementation in Your Game**

### **For Dialogue System:**
```gdscript
# Systems/NPCs/CulturalNPC.gd
func setup_dialogue_fonts():
    var dialogue_ui = get_node("DialogueUI")
    var name_label = dialogue_ui.get_node("NameLabel")
    var text_label = dialogue_ui.get_node("TextLabel")
    
    # Use header font for NPC names
    CulturalThemeManager.apply_header_style(name_label, 20)
    
    # Use body font for dialogue text
    CulturalThemeManager.apply_body_style(text_label, 16)
```

### **For Region Info Panels:**
```gdscript
# Systems/UI/CulturalInfoPanel.gd
func setup_info_panel_fonts():
    var title = get_node("TitleLabel")
    var description = get_node("DescriptionLabel")
    var details = get_node("DetailsLabel")
    
    # Use header font for region titles
    CulturalThemeManager.apply_header_style(title, 28)
    
    # Use body font for descriptions
    CulturalThemeManager.apply_body_style(description, 18)
    
    # Use UI font for details
    CulturalThemeManager.apply_ui_style(details, 14)
```

### **For Main Menu:**
```gdscript
# Scenes/MainMenu/MainMenuController.gd
func setup_menu_fonts():
    var game_title = get_node("GameTitle")
    var menu_buttons = get_tree().get_nodes_in_group("menu_buttons")
    
    # Use header font for game title
    CulturalThemeManager.apply_header_style(game_title, 32)
    
    # Use UI font for menu buttons
    for button in menu_buttons:
        CulturalThemeManager.apply_ui_style(button, 18)
```

## 📊 **Font Performance Tips**

### **Optimization:**
- **Use MSDF fonts** for scalable text (already configured)
- **Preload common sizes** in import settings
- **Use font variations** instead of separate files when possible
- **Cache font resources** in static variables

### **Best Practices:**
- **Consistent sizing** across similar UI elements
- **Proper contrast** for readability
- **Cultural appropriateness** (Gentium supports many languages)
- **Performance testing** with your target devices

## 🌍 **Cultural Context**

### **Gentium Book Plus**
- **Designed for**: Academic and multilingual text
- **Perfect for**: Educational content about Indonesian culture
- **Supports**: Extended Latin, Greek, Cyrillic characters
- **Cultural fit**: Excellent for serious cultural content

### **Source Sans 3**
- **Designed for**: User interfaces and digital displays
- **Perfect for**: Game UI, buttons, system text
- **Benefits**: Highly readable, modern, clean

### **Rooters**
- **Style**: Display/decorative font
- **Perfect for**: Game titles, region names, headers
- **Cultural fit**: Can give a distinctive character to your game

Would you like me to create a theme resource file or a font manager system for your project?