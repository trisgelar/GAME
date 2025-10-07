# AudioConfig Integration Guide

## Overview

The AudioConfig system is now fully integrated with the `CulturalAudioManagerEnhanced`. This system provides a robust, configuration-driven approach to audio management with fallback support.

## System Architecture

### Components

1. **AudioConfig.gd** - Configuration resource class
2. **AudioConfig.tres** - Configuration file with all settings
3. **CulturalAudioManagerEnhanced.gd** - Enhanced audio manager with config integration
4. **GenerateAudioResources.gd** - Utility for creating .tres audio resources

### Integration Flow

```
AudioConfig.tres → CulturalAudioManagerEnhanced → Audio Players
     ↓                        ↓
Configuration Settings → Volume & Path Management
```

## Features

### ✅ **Automatic Configuration Loading**
- Loads `AudioConfig.tres` on startup
- Falls back to hardcoded values if config not available
- Validates audio files and reports missing ones

### ✅ **Dynamic Audio Path Management**
- Uses configuration file paths when available
- Falls back to hardcoded paths for reliability
- Supports all audio categories (Ambient, Menu, Player, UI, Effects)

### ✅ **Volume Control Integration**
- Configuration-driven volume settings
- Runtime volume adjustment with persistence
- Master volume affects all categories

### ✅ **File Validation**
- Checks for missing audio files on startup
- Reports missing files in console
- Graceful handling of missing resources

## Usage

### Basic Usage

The enhanced audio manager automatically loads and applies configuration:

```gdscript
# In your scene or Global.gd
var audio_manager: CulturalAudioManagerEnhanced

func _ready():
    # Configuration is loaded automatically
    # No additional setup required
```

### Audio Playback

```gdscript
# Play audio using configuration paths
GlobalSignals.on_play_menu_audio.emit("ui_click")
GlobalSignals.on_play_ambient_audio.emit("jungle_sounds")
GlobalSignals.on_play_footstep_audio.emit()
```

### Volume Control

```gdscript
# Adjust volumes (automatically saved to config)
audio_manager.set_master_volume(0.8)
audio_manager.set_ambient_volume(0.6)
audio_manager.set_menu_volume(0.7)

# Save configuration
audio_manager.save_configuration()
```

### Configuration Management

```gdscript
# Reload configuration from file
audio_manager.reload_configuration()

# Get configuration status
var status = audio_manager.get_configuration_status()
print("Config loaded: ", status.config_loaded)
print("Using config system: ", status.use_config_system)
```

## Configuration File Structure

### AudioConfig.tres Properties

```gdscript
# Volume Settings
master_volume: float = 0.8
ambient_volume: float = 0.6
music_volume: float = 0.7
effects_volume: float = 0.8
voice_volume: float = 0.8
footsteps_volume: float = 0.5
menu_volume: float = 0.6
ui_volume: float = 0.8

# Audio File Mappings
ambient_audio: Dictionary = {
    "jungle_sounds": "res://Assets/Audio/Ambient/jungle_sounds.ogg",
    "market_ambience": "res://Assets/Audio/Ambient/market_ambience.ogg",
    "mountain_wind": "res://Assets/Audio/Ambient/mountain_wind.ogg"
}

menu_audio: Dictionary = {
    "menu_close": "res://Assets/Audio/Menu/menu_close.ogg",
    "menu_open": "res://Assets/Audio/Menu/menu_open.ogg",
    "region_select": "res://Assets/Audio/Menu/region_select.ogg",
    "start_game": "res://Assets/Audio/Menu/start_game.ogg",
    "ui_click": "res://Assets/Audio/Menu/ui_click.ogg",
    "ui_hover": "res://Assets/Audio/Menu/ui_hover.ogg"
}

footstep_audio: Dictionary = {
    "dirt": [
        "res://Assets/Audio/Player/Footsteps/footstep_dirt_1.ogg",
        "res://Assets/Audio/Player/Footsteps/footstep_dirt_2.ogg",
        "res://Assets/Audio/Player/Footsteps/footstep_dirt_3.ogg"
    ],
    "grass": [
        "res://Assets/Audio/Player/Footsteps/footstep_grass_1.ogg",
        "res://Assets/Audio/Player/Footsteps/footstep_grass_2.ogg",
        "res://Assets/Audio/Player/Footsteps/footstep_grass_3.ogg"
    ]
    # ... more surface types
}

# Advanced Settings
enable_3d_audio: bool = true
enable_reverb: bool = true
audio_quality: int = 1
enable_subtitles: bool = false
enable_cultural_commentary: bool = true
preferred_language: String = "indonesian"
regional_accent: String = "standard"
```

## Fallback System

The enhanced manager includes a robust fallback system:

### When Configuration is Available
- Uses `AudioConfig.tres` for all settings
- Applies configuration-driven volume levels
- Uses configuration file paths
- Validates audio files and reports issues

### When Configuration is Not Available
- Falls back to hardcoded audio paths
- Uses default volume settings
- Continues to function normally
- Logs warnings about missing configuration

## Testing the System

### Run the Test Script

1. Open `Scenes/TestAudioConfig.tscn` in Godot
2. Run the scene
3. Check console output for test results

### Manual Testing

```gdscript
# Test configuration loading
var manager = CulturalAudioManagerEnhanced.new()
var status = manager.get_configuration_status()
print("Configuration status: ", status)

# Test audio playback
GlobalSignals.on_play_menu_audio.emit("ui_click")
GlobalSignals.on_play_ambient_audio.emit("jungle_sounds")
```

## Adding New Audio Files

### Method 1: Update Configuration File

1. Add audio file to `Assets/Audio/`
2. Edit `Resources/Audio/AudioConfig.tres` in Godot editor
3. Add new entry to appropriate category dictionary
4. Save the configuration file

### Method 2: Use Generation Script

1. Add audio file to `Assets/Audio/`
2. Run `GenerateAudioResources.gd` script
3. Update `AudioConfig.tres` with new file path
4. Test the new audio

## Troubleshooting

### Configuration Not Loading

**Symptoms**: Audio manager uses fallback system
**Solutions**:
- Check if `AudioConfig.tres` exists in `Resources/Audio/`
- Verify file is not corrupted
- Check console for error messages

### Missing Audio Files

**Symptoms**: Warning messages about missing files
**Solutions**:
- Check file paths in `AudioConfig.tres`
- Verify audio files exist in `Assets/Audio/`
- Run file validation: `audio_config.validate_audio_files()`

### Volume Issues

**Symptoms**: Audio too loud/quiet or not responding to changes
**Solutions**:
- Check volume settings in `AudioConfig.tres`
- Verify master volume is not set to 0
- Test volume controls: `audio_manager.set_master_volume(0.8)`

### Parse Errors

**Symptoms**: Godot shows parse errors for audio classes
**Solutions**:
- Restart Godot editor
- Check for syntax errors in `AudioConfig.gd`
- Verify all dependencies are properly loaded

## Performance Considerations

### Configuration Loading
- Configuration is loaded once at startup
- No performance impact during gameplay
- File validation only runs on startup

### Audio Playback
- Uses same performance as simple system
- No additional overhead for configuration lookup
- Fallback system ensures reliability

### Memory Usage
- Configuration data is minimal
- Audio files are loaded on demand
- No significant memory overhead

## Future Enhancements

### Planned Features
- Runtime configuration editing
- User preference saving to `user://`
- Profile-based audio settings
- Advanced audio mixing controls

### Integration Opportunities
- Settings UI integration
- Save system integration
- Accessibility options
- Cultural customization

## Migration from Simple System

If you're migrating from `CulturalAudioManagerSimple`:

1. **No Code Changes Required**: The enhanced system is a drop-in replacement
2. **Automatic Fallback**: If configuration fails, it uses the same hardcoded paths
3. **Gradual Migration**: You can add configuration features incrementally

### Migration Steps

1. Replace `CulturalAudioManagerSimple` with `CulturalAudioManagerEnhanced`
2. Update scene references to use the enhanced version
3. Test that audio still works (fallback system)
4. Add `AudioConfig.tres` for full configuration support
5. Customize configuration as needed

## Best Practices

### Configuration Management
- Always backup `AudioConfig.tres` before major changes
- Test configuration changes in development first
- Use version control for configuration files

### Audio File Organization
- Keep consistent naming conventions
- Use descriptive file names
- Organize files by category in `Assets/Audio/`

### Performance
- Use appropriate audio quality settings
- Consider file sizes for mobile platforms
- Test audio performance on target devices

### Development
- Use the test script to verify system health
- Check console logs for configuration issues
- Validate audio files regularly

This integration provides a robust, flexible audio system that can grow with your project while maintaining reliability through its fallback mechanisms.
