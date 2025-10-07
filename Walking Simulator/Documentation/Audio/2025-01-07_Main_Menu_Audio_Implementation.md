# Main Menu Audio Implementation Guide

## Overview

The main menu now features a comprehensive audio system that provides immersive feedback for all user interactions. This implementation uses the enhanced `CulturalAudioManagerEnhanced` with fallback support.

## Audio Features Implemented

### 🎵 **Button Interactions**

#### **Button Click Audio**
- **Trigger**: All button presses
- **Audio**: `ui_click.ogg`
- **Implementation**: `play_button_sound()` function
- **Fallback**: Direct AudioStreamPlayer + GlobalSignals

#### **Button Hover Audio**
- **Trigger**: Mouse enters button area
- **Audio**: `ui_hover.ogg`
- **Implementation**: `_on_button_hover()` function
- **Connected to**: All main menu buttons automatically

### 🎭 **Menu Navigation Audio**

#### **Panel Opening**
- **Trigger**: Opening How to Play, About Us, Credits panels
- **Audio**: `menu_open.ogg`
- **Implementation**: Added to `show_*_panel()` functions

#### **Panel Closing**
- **Trigger**: Back button pressed, returning to main menu
- **Audio**: `menu_close.ogg`
- **Implementation**: Added to `_on_back_to_main_pressed()`

### 🗺️ **Region Selection Audio**

#### **Region Selection**
- **Trigger**: Clicking Indonesia Barat, Tengah, or Timur
- **Audio**: `region_select.ogg`
- **Implementation**: Added to region button functions
- **Special**: Plays before zoom animation

#### **Game Start**
- **Trigger**: Clicking "Explore 3D Map"
- **Audio**: `start_game.ogg`
- **Implementation**: Added to `_on_explore_3d_map_pressed()`

### 🎶 **Background Music**

#### **Ambient Background**
- **Audio**: `market_ambience.ogg`
- **Implementation**: `start_background_music()` function
- **Start**: Automatically when main menu loads
- **Stop**: When leaving main menu (via `stop_background_music()`)

## Implementation Details

### **Audio Manager Integration**

```gdscript
# Enhanced audio manager with fallback
var audio_manager: CulturalAudioManagerEnhanced

func setup_audio_manager():
    if Global.audio_manager:
        audio_manager = Global.audio_manager
    else:
        # Fallback to GlobalSignals
        GlobalSignals.on_play_menu_audio.emit("button_click")
```

### **Button Hover Setup**

```gdscript
func setup_button_hover_audio():
    var buttons = [
        start_game_button,
        explore_3d_map_button,
        topeng_nusantara_button,
        load_game_button,
        how_to_play_button,
        about_us_button,
        credits_button
    ]
    
    for button in buttons:
        if button:
            button.mouse_entered.connect(_on_button_hover)
```

### **Audio Playback Functions**

```gdscript
func play_button_sound():
    # Primary: Enhanced audio manager
    if audio_manager:
        audio_manager.play_menu_audio("button_click")
    else:
        # Fallback: GlobalSignals
        GlobalSignals.on_play_menu_audio.emit("button_click")

func _on_button_hover():
    if audio_manager:
        audio_manager.play_menu_audio("button_hover")
    else:
        GlobalSignals.on_play_menu_audio.emit("button_hover")
```

## Audio Files Used

### **Menu Audio Files**
```
Assets/Audio/Menu/
├── ui_click.ogg          # Button click sounds
├── ui_hover.ogg          # Button hover sounds
├── menu_open.ogg         # Panel opening sounds
├── menu_close.ogg        # Panel closing sounds
├── region_select.ogg     # Region selection sounds
└── start_game.ogg        # Game start sounds
```

### **Ambient Audio Files**
```
Assets/Audio/Ambient/
└── market_ambience.ogg   # Background ambient music
```

## Audio Flow

### **Main Menu Load Sequence**
1. **Setup**: `setup_audio_manager()` - Connect to audio manager
2. **Hover Setup**: `setup_button_hover_audio()` - Connect hover events
3. **Background**: `start_background_music()` - Start ambient music
4. **Ready**: Main menu is ready with full audio support

### **User Interaction Flow**
1. **Hover**: Mouse enters button → `ui_hover.ogg` plays
2. **Click**: Button pressed → `ui_click.ogg` plays
3. **Action**: Specific audio based on action:
   - Panel open → `menu_open.ogg`
   - Region select → `region_select.ogg`
   - Game start → `start_game.ogg`
   - Back button → `menu_close.ogg`

## Configuration Integration

### **AudioConfig.tres Settings**
The main menu audio uses the following configuration settings:

```gdscript
# Volume levels
menu_volume: float = 0.6
master_volume: float = 0.8

# Audio file mappings
menu_audio: Dictionary = {
    "button_hover": "res://Assets/Audio/Menu/ui_hover.ogg",
    "button_click": "res://Assets/Audio/Menu/ui_click.ogg",
    "menu_open": "res://Assets/Audio/Menu/menu_open.ogg",
    "menu_close": "res://Assets/Audio/Menu/menu_close.ogg",
    "region_select": "res://Assets/Audio/Menu/region_select.ogg",
    "start_game": "res://Assets/Audio/Menu/start_game.ogg"
}

ambient_audio: Dictionary = {
    "market_ambience": "res://Assets/Audio/Ambient/market_ambience.ogg"
}
```

## Fallback System

### **Primary System**
- Uses `CulturalAudioManagerEnhanced`
- Loads configuration from `AudioConfig.tres`
- Provides volume control and file validation

### **Fallback System**
- Uses `GlobalSignals` for audio events
- Direct `AudioStreamPlayer` for button sounds
- Ensures audio always works even if config fails

## Performance Considerations

### **Audio Loading**
- Audio files are loaded on demand
- No preloading of all audio files
- Efficient memory usage

### **Event Handling**
- Hover events connected once at startup
- No runtime event connection/disconnection
- Minimal performance overhead

### **Background Music**
- Single ambient track for main menu
- Loops seamlessly
- Stops when leaving main menu

## Testing and Debugging

### **Audio Status Check**
```gdscript
# Check if audio manager is working
if audio_manager:
    var status = audio_manager.get_configuration_status()
    print("Audio config loaded: ", status.config_loaded)
    print("Using config system: ", status.use_config_system)
```

### **Manual Audio Testing**
```gdscript
# Test specific audio
audio_manager.play_menu_audio("button_click")
audio_manager.play_menu_audio("button_hover")
audio_manager.play_ambient_audio("market_ambience")
```

### **Debug Logging**
The implementation includes comprehensive logging:
- Audio manager connection status
- Button hover setup completion
- Background music start/stop
- Fallback system usage

## Customization Options

### **Volume Control**
```gdscript
# Adjust menu audio volume
audio_manager.set_menu_volume(0.8)
audio_manager.set_master_volume(0.9)
```

### **Audio File Replacement**
1. Replace audio files in `Assets/Audio/Menu/`
2. Update `AudioConfig.tres` if needed
3. Audio system automatically uses new files

### **Adding New Audio**
1. Add new audio file to `Assets/Audio/Menu/`
2. Update `AudioConfig.tres` with new mapping
3. Add new audio call in appropriate function

## Integration with Other Scenes

### **Scene Transition Audio**
When transitioning from main menu to other scenes:
- Background music stops automatically
- Audio manager persists across scenes
- New scene can start its own audio

### **Return to Main Menu**
When returning to main menu:
- Background music restarts
- All audio systems reinitialize
- Hover effects reconnect

## Best Practices

### **Audio Design**
- Keep button sounds short and crisp
- Use consistent volume levels
- Provide audio feedback for all interactions

### **Performance**
- Connect hover events once at startup
- Use efficient audio file formats (OGG)
- Stop background music when not needed

### **Accessibility**
- Audio provides feedback for visual interactions
- Can be disabled via volume controls
- Works with screen readers and other assistive technologies

## Troubleshooting

### **No Audio Playing**
1. Check if `audio_manager` is connected
2. Verify audio files exist in `Assets/Audio/Menu/`
3. Check volume levels in `AudioConfig.tres`
4. Test fallback system with `GlobalSignals`

### **Hover Audio Not Working**
1. Verify `setup_button_hover_audio()` was called
2. Check if buttons have `mouse_entered` signal connected
3. Test with `_on_button_hover()` function directly

### **Background Music Issues**
1. Check if `market_ambience.ogg` exists
2. Verify ambient audio is enabled in config
3. Test with `start_background_music()` function

This implementation provides a rich, immersive audio experience for the main menu while maintaining reliability through its fallback systems.
