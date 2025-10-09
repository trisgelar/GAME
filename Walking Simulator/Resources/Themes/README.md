# Theme Resources

This folder contains configurable theme resources for UI elements in the game.

## Menu Button Theme

### Files:
- **MenuButtonTheme.tres** - Main button theme (apply this to buttons)
- **MenuButtonStyleNormal.tres** - Normal button state style
- **MenuButtonStyleHover.tres** - Hover button state style
- **MenuButtonStylePressed.tres** - Pressed button state style
- **MenuButtonStyleDisabled.tres** - Disabled button state style
- **CulturalGameTheme.tres** - Main game theme

### Usage:

To apply the button theme to a button, add it as a theme property:

```gdscript
# In GDScript:
$Button.theme = preload("res://Resources/Themes/MenuButtonTheme.tres")
```

Or in the scene file (.tscn):
```
[node name="MyButton" type="Button"]
theme = ExtResource("path_to_MenuButtonTheme")
```

### Customization:

To customize button appearance, edit the individual style files:
1. Change the texture/image used for each state
2. Adjust texture margins (9-slice scaling)
3. Modify content margins (text padding)
4. Change font colors in MenuButtonTheme.tres

For detailed instructions, see: `/docs/2025-10-09_menu-button-theme-guide.md`

## Current Usage:

The MenuButtonTheme is currently applied to all buttons in:
- `Scenes/MainMenu/MainMenu.tscn`

