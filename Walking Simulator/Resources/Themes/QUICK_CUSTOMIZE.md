# Quick Customization Guide - Button Backgrounds

## Want to change button images? Here's how:

### Step 1: Prepare your button images
You need 4 images for each button state:
- Normal state (when button is idle)
- Hover state (when mouse is over button)
- Pressed state (when button is clicked)
- Disabled state (when button is inactive)

### Step 2: Place your images
Put your images in: `Assets/UI/Exit/` (or any folder you prefer)

### Step 3: Edit the style files
Open these files in a text editor and change the image path:

**For Normal state:**
File: `MenuButtonStyleNormal.tres`
```
[ext_resource type="Texture2D" uid="..." path="res://Assets/UI/Exit/YOUR_IMAGE_NORMAL.png" id="1"]
```

**For Hover state:**
File: `MenuButtonStyleHover.tres`
```
[ext_resource type="Texture2D" uid="..." path="res://Assets/UI/Exit/YOUR_IMAGE_HOVER.png" id="1"]
```

**For Pressed state:**
File: `MenuButtonStylePressed.tres`
```
[ext_resource type="Texture2D" uid="..." path="res://Assets/UI/Exit/YOUR_IMAGE_PRESSED.png" id="1"]
```

**For Disabled state:**
File: `MenuButtonStyleDisabled.tres`
```
[ext_resource type="Texture2D" uid="..." path="res://Assets/UI/Exit/YOUR_IMAGE_DISABLED.png" id="1"]
```

### Step 4: Save and reload
- Save all the .tres files
- Open Godot
- The changes will apply automatically!

---

## Quick Changes

### Change button text color:
Open `MenuButtonTheme.tres` and find:
```
Button/colors/font_color = Color(1, 1, 1, 1)
```
Change the values (Red, Green, Blue, Alpha) from 0.0 to 1.0

### Make buttons bigger padding:
Open any style file and increase:
```
content_margin_left = 16.0    # Make bigger for more space
content_margin_top = 12.0
content_margin_right = 16.0
content_margin_bottom = 12.0
```

---

## Current Button Images

✅ Normal: `standardbut_n.png`
✅ Hover: `standardbut_h.png`
✅ Pressed: `standardbut_p.png`
✅ Disabled: `standardbut_d.png`

Location: `Walking Simulator/Assets/UI/Exit/`

---

For detailed instructions, see: `/docs/2025-10-09_menu-button-theme-guide.md`

