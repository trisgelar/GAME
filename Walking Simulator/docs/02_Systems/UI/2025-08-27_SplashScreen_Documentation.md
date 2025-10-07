# Splash Screen Documentation

## Overview

The Splash Screen System provides a professional introduction to the Indonesian Cultural Heritage Exhibition game. It displays the "Made with Godot" splash screen with smooth fade animations and automatically transitions to the main menu.

## Table of Contents

1. [Features](#features)
2. [System Architecture](#system-architecture)
3. [Configuration](#configuration)
4. [Animation System](#animation-system)
5. [Usage Guide](#usage-guide)
6. [Customization](#customization)
7. [Testing](#testing)

## Features

### 🎬 Professional Presentation
- **Smooth Fade Animations**: Elegant fade-in and fade-out transitions
- **High-Quality Image**: Uses the official "Made with Godot" splash screen
- **Responsive Design**: Automatically scales to different screen resolutions
- **Skip Functionality**: Users can skip the splash screen with any key or mouse click

### ⏱️ Timing Control
- **Configurable Duration**: Adjustable display time (default: 3 seconds)
- **Customizable Fade Times**: Separate control over fade-in and fade-out durations
- **Smooth Transitions**: Seamless flow from splash to main menu

### 🎮 User Experience
- **Non-Blocking**: Users can skip at any time
- **Professional Feel**: Creates a polished game introduction
- **Automatic Transition**: Seamlessly moves to main menu when complete

## System Architecture

### Core Components

```
Scenes/SplashScreen/
├── SplashScreen.tscn              # Main splash screen scene
├── SplashScreenController.gd      # Controller script
└── Assets/Splash/
    └── Made With Godot Screen 1080p.png  # Splash screen image

Tests/
└── test_splash_screen.tscn        # Test scene
```

### File Structure

- **SplashScreen.tscn**: Main scene with UI layout and animations
- **SplashScreenController.gd**: Logic for timing, animations, and transitions
- **Splash Image**: High-resolution Godot splash screen (1080p)

## Configuration

### Project Settings

The splash screen is configured as the main scene in `project.godot`:

```ini
[application]
run/main_scene="res://Scenes/SplashScreen/SplashScreen.tscn"
```

### Controller Configuration

```gdscript
@export var splash_duration: float = 3.0      # Display time
@export var fade_in_duration: float = 1.0     # Fade in time
@export var fade_out_duration: float = 1.0    # Fade out time
@export var main_menu_scene: String = "res://Scenes/MainMenu/MainMenu.tscn"
```

### Scene Structure

```
SplashScreen (Control)
├── Background (ColorRect)         # Black background
├── SplashImage (TextureRect)      # Godot splash image
└── FadeAnimation (AnimationPlayer) # Animation controller
```

## Animation System

### Fade In Animation

```gdscript
func setup_animations():
    # Create fade in animation
    var fade_in_anim = Animation.new()
    var track_index = fade_in_anim.add_track(Animation.TYPE_VALUE)
    fade_in_anim.track_set_path(track_index, "SplashImage:modulate:a")
    fade_in_anim.length = fade_in_duration
    
    # Keyframes: 0.0 -> 1.0 (transparent to opaque)
    fade_in_anim.track_insert_key(track_index, 0.0, 0.0)
    fade_in_anim.track_insert_key(track_index, fade_in_duration, 1.0)
```

### Fade Out Animation

```gdscript
# Create fade out animation
var fade_out_anim = Animation.new()
track_index = fade_out_anim.add_track(Animation.TYPE_VALUE)
fade_out_anim.track_set_path(track_index, "SplashImage:modulate:a")
fade_out_anim.length = fade_out_duration

# Keyframes: 1.0 -> 0.0 (opaque to transparent)
fade_out_anim.track_insert_key(track_index, 0.0, 1.0)
fade_out_anim.track_insert_key(track_index, fade_out_duration, 0.0)
```

### Animation Sequence

1. **Fade In**: 1 second (0.0 → 1.0 alpha)
2. **Display**: 3 seconds (full opacity)
3. **Fade Out**: 1 second (1.0 → 0.0 alpha)
4. **Transition**: Automatic scene change to main menu

## Usage Guide

### For Players

1. **Game Launch**: Splash screen appears automatically when game starts
2. **Wait or Skip**: Either wait for the full sequence or press any key/click to skip
3. **Main Menu**: Automatically transitions to the main menu

### For Developers

#### Testing the Splash Screen

1. **Direct Test**: Set main scene to `Scenes/SplashScreen/SplashScreen.tscn`
2. **Test Scene**: Use `Tests/test_splash_screen.tscn` for isolated testing
3. **Debug Mode**: Check console logs for timing and transition information

#### Modifying Timing

```gdscript
# In SplashScreenController.gd
@export var splash_duration: float = 5.0      # Longer display
@export var fade_in_duration: float = 2.0     # Slower fade in
@export var fade_out_duration: float = 2.0    # Slower fade out
```

#### Changing Target Scene

```gdscript
@export var main_menu_scene: String = "res://Scenes/YourScene/YourScene.tscn"
```

## Customization

### Changing the Splash Image

1. **Replace Image**: Replace `Assets/Splash/Made With Godot Screen 1080p.png`
2. **Update Reference**: Update the texture reference in `SplashScreen.tscn`
3. **Adjust Size**: Modify the TextureRect size and position if needed

### Custom Animation Effects

```gdscript
# Add scale animation
var scale_anim = Animation.new()
var track_index = scale_anim.add_track(Animation.TYPE_VALUE)
scale_anim.track_set_path(track_index, "SplashImage:scale")
scale_anim.length = fade_in_duration

# Keyframes: 0.8 -> 1.0 (slight zoom effect)
scale_anim.track_insert_key(track_index, 0.0, Vector2(0.8, 0.8))
scale_anim.track_insert_key(track_index, fade_in_duration, Vector2(1.0, 1.0))
```

### Multiple Splash Screens

```gdscript
# Add multiple splash images
@export var splash_images: Array[Texture2D] = []
@export var splash_durations: Array[float] = []

func show_multiple_splashes():
    for i in range(splash_images.size()):
        splash_image.texture = splash_images[i]
        await get_tree().create_timer(splash_durations[i]).timeout
```

### Background Customization

```gdscript
# Change background color
@onready var background: ColorRect = $Background
background.color = Color(0.1, 0.1, 0.2, 1.0)  # Dark blue

# Add background image
var bg_image = TextureRect.new()
bg_image.texture = preload("res://Assets/Backgrounds/bg.png")
```

## Testing

### Test Scenes

- **Main Test**: `Tests/test_splash_screen.tscn`
- **Direct Test**: Set main scene to `Scenes/SplashScreen/SplashScreen.tscn`

### Test Commands

```bash
# Test splash screen directly
godot --path . --main-pack SplashScreen.tscn

# Test with specific scene
godot --path . --main-pack Tests/test_splash_screen.tscn
```

### Debug Information

The splash screen provides detailed logging:

```gdscript
GameLogger.info("SplashScreen: ===== SPLASH SCREEN STARTING =====")
GameLogger.info("SplashScreen: Animations setup complete")
GameLogger.info("SplashScreen: Starting splash sequence")
GameLogger.info("SplashScreen: Splash sequence completed")
GameLogger.info("SplashScreen: Fade out completed, transitioning to main menu")
GameLogger.info("SplashScreen: Successfully transitioned to main menu")
```

### Performance Considerations

- **Lightweight**: Minimal performance impact
- **Efficient Animations**: Uses Godot's built-in animation system
- **Memory Management**: Proper cleanup after transition
- **Smooth Transitions**: 60 FPS animation playback

## Integration with Game Flow

### Scene Hierarchy

```
Game Launch
    ↓
Splash Screen (3-5 seconds)
    ↓
Main Menu
    ↓
Game Scenes (Pasar, Tambora, Papua)
```

### Error Handling

```gdscript
func transition_to_main_menu():
    var result = get_tree().change_scene_to_file(main_menu_scene)
    
    if result != OK:
        GameLogger.error("SplashScreen: Failed to transition to main menu: " + str(result))
        # Fallback to main scene if main menu fails
        get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")
```

## Future Enhancements

### Planned Features

1. **Multiple Splash Screens**: Sequence of different splash images
2. **Loading Progress**: Show loading progress during splash
3. **Audio Integration**: Background music or sound effects
4. **Custom Animations**: More complex animation sequences
5. **Platform Detection**: Different splash screens for different platforms

### Extension Points

- **Animation System**: Easy addition of new animation effects
- **Timing Control**: Flexible timing configuration
- **Scene Management**: Integration with game scene manager
- **User Preferences**: Skip splash screen option in settings

---

## Conclusion

The Splash Screen System provides a professional and polished introduction to the Indonesian Cultural Heritage Exhibition game. Its smooth animations, configurable timing, and user-friendly skip functionality create an excellent first impression while maintaining good performance and user experience.

The system is designed to be easily customizable and extensible, allowing for future enhancements and integration with other game systems.
