# Audio Configuration System

## Overview

The audio configuration system provides a centralized, configurable way to manage all audio settings and file mappings in the game. This system replaces hardcoded audio paths with a flexible resource-based configuration.

## Key Components

### 1. AudioConfig.gd
**Location**: `res://Systems/Core/AudioConfig.gd`

A comprehensive resource class that manages:
- Volume settings for all audio categories
- File path mappings for all audio files
- Audio quality and performance settings
- Regional and cultural preferences
- Validation and management functions

### 2. AudioConfig.tres
**Location**: `res://Resources/Audio/AudioConfig.tres`

The main configuration file containing all audio settings and file mappings. This file can be edited in the Godot editor or programmatically.

### 3. GenerateAudioResources.gd
**Location**: `res://Systems/Core/GenerateAudioResources.gd`

A utility script that automatically generates missing `.tres` audio resource files based on the audio files in `Assets/Audio/`.

## Configuration Structure

### Volume Settings
```gdscript
master_volume: float = 0.8
ambient_volume: float = 0.6
music_volume: float = 0.7
effects_volume: float = 0.8
voice_volume: float = 0.8
footsteps_volume: float = 0.5
menu_volume: float = 0.6
ui_volume: float = 0.8
```

### Audio File Mappings
```gdscript
ambient_audio: Dictionary = {
    "jungle_sounds": "res://Assets/Audio/Ambient/jungle_sounds.ogg",
    "market_ambience": "res://Assets/Audio/Ambient/market_ambience.ogg",
    "mountain_wind": "res://Assets/Audio/Ambient/mountain_wind.ogg"
}

menu_audio: Dictionary = {
    "menu_close": "res://Assets/Audio/Menu/menu_close.ogg",
    "menu_open": "res://Assets/Audio/Menu/menu_open.ogg",
    # ... more menu sounds
}

footstep_audio: Dictionary = {
    "dirt": [
        "res://Assets/Audio/Player/Footsteps/footstep_dirt_1.ogg",
        "res://Assets/Audio/Player/Footsteps/footstep_dirt_2.ogg",
        "res://Assets/Audio/Player/Footsteps/footstep_dirt_3.ogg"
    ],
    "grass": [
        # ... grass footstep variations
    ]
    # ... more surface types
}
```

### Advanced Settings
```gdscript
enable_3d_audio: bool = true
enable_reverb: bool = true
audio_quality: int = 1  # 0=Low, 1=Medium, 2=High
enable_subtitles: bool = false
enable_cultural_commentary: bool = true
preferred_language: String = "indonesian"
regional_accent: String = "standard"
```

## Usage

### Loading Configuration
```gdscript
# In CulturalAudioManager.gd
func load_audio_configuration():
    if not audio_config:
        if ResourceLoader.exists("res://Resources/Audio/AudioConfig.tres"):
            audio_config = load("res://Resources/Audio/AudioConfig.tres") as AudioConfig
        else:
            audio_config = AudioConfig.new()
    
    # Apply settings
    master_volume = audio_config.master_volume
    ambient_volume = audio_config.ambient_volume
    # ... apply other settings
```

### Getting Audio Paths
```gdscript
# Get specific audio file path
var path = audio_config.get_audio_path("menu", "ui_click")
# Returns: "res://Assets/Audio/Menu/ui_click.ogg"

# Get footstep audio array
var footstep_sounds = audio_config.get_footstep_audio("grass")
# Returns: Array of 3 grass footstep sound paths
```

### Volume Management
```gdscript
# Get volume for category
var volume = audio_config.get_volume("ambient")
# Returns: 0.6

# Set volume for category
audio_config.set_volume("ambient", 0.8)
```

### Validation
```gdscript
# Check for missing audio files
var missing_files = audio_config.validate_audio_files()
if missing_files.size() > 0:
    print("Missing files: ", missing_files)
```

## File Organization

### Assets/Audio/ Structure
```
Assets/Audio/
├── Ambient/
│   ├── jungle_sounds.ogg
│   ├── market_ambience.ogg
│   └── mountain_wind.ogg
├── Menu/
│   ├── menu_close.ogg
│   ├── menu_open.ogg
│   └── ui_click.ogg
├── Player/
│   ├── Actions/
│   │   ├── jump.ogg
│   │   └── land.ogg
│   └── Footsteps/
│       ├── footstep_grass_1.ogg
│       ├── footstep_grass_2.ogg
│       └── footstep_grass_3.ogg
├── UI/
│   ├── inventory_open.ogg
│   └── success.ogg
└── Effects/
    ├── collection_chime.ogg
    └── npc_hello.ogg
```

### Resources/Audio/ Structure
```
Resources/Audio/
├── AudioConfig.tres          # Main configuration
├── Ambient/
│   ├── JungleSounds.tres
│   ├── MarketAmbience.tres
│   └── MountainWind.tres
├── Menu/
│   ├── MenuClose.tres
│   ├── MenuOpen.tres
│   └── UIClick.tres
├── Player/
│   ├── Actions/
│   │   ├── Jump.tres
│   │   └── Land.tres
│   └── Footsteps/
│       ├── FootstepGrass1.tres
│       ├── FootstepGrass2.tres
│       └── FootstepGrass3.tres
├── UI/
│   ├── InventoryOpen.tres
│   └── Success.tres
└── Effects/
    ├── CollectionChime.tres
    └── NPCHello.tres
```

## Generating Missing Resources

### Automatic Generation
1. Run the `GenerateAudioResources.gd` script
2. It will scan `Assets/Audio/` for audio files
3. Create corresponding `.tres` files in `Resources/Audio/`
4. Set appropriate volume levels and descriptions

### Manual Generation
```gdscript
# Create a single audio resource
var audio_resource = AudioResource.new()
audio_resource.audio_stream = load("res://Assets/Audio/Menu/ui_click.ogg")
audio_resource.volume_db = -3.0
audio_resource.loop = false
audio_resource.description = "UI click sound"

ResourceSaver.save(audio_resource, "res://Resources/Audio/Menu/UIClick.tres")
```

## Benefits

### 1. Centralized Configuration
- All audio settings in one place
- Easy to modify without code changes
- Consistent across the entire game

### 2. Flexible File Management
- Easy to change audio file paths
- Support for multiple audio formats
- Automatic validation of file existence

### 3. Performance Optimization
- Configurable audio quality settings
- Buffer size and streaming options
- Concurrent sound limits

### 4. Cultural Customization
- Language preferences
- Regional accent settings
- Cultural commentary options

### 5. Development Efficiency
- Automatic resource generation
- Validation tools
- Easy debugging and testing

## Integration with CulturalAudioManager

The `CulturalAudioManager` now automatically loads and applies the audio configuration:

```gdscript
func _ready():
    load_audio_configuration()  # Load AudioConfig.tres
    setup_audio_players()       # Apply volume settings
    connect_signals()           # Connect to global signals
```

## Future Enhancements

### 1. Runtime Configuration
- Save user preferences to `user://audio_config.tres`
- Load custom configurations
- Profile-based audio settings

### 2. Dynamic Loading
- Load audio files on demand
- Streaming for large files
- Memory management

### 3. Advanced Features
- Audio mixing and effects
- Spatial audio configuration
- Accessibility options

### 4. Cultural Features
- Region-specific audio sets
- Language switching
- Cultural context audio

## Troubleshooting

### Missing Audio Files
```gdscript
# Check for missing files
var missing = audio_config.validate_audio_files()
for file in missing:
    print("Missing: ", file)
```

### Configuration Not Loading
```gdscript
# Check if configuration exists
if ResourceLoader.exists("res://Resources/Audio/AudioConfig.tres"):
    print("Configuration file exists")
else:
    print("Configuration file missing")
```

### Volume Issues
```gdscript
# Check current volume settings
print("Master volume: ", audio_config.master_volume)
print("Ambient volume: ", audio_config.ambient_volume)
```

This configuration system provides a robust, flexible foundation for managing all audio aspects of the game while maintaining ease of use and development efficiency.
