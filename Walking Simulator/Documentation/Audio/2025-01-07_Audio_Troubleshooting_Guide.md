# Audio Troubleshooting Guide

## Problem: No Audio Playing in Main Menu

If you can't hear any audio in the main menu, follow this troubleshooting guide step by step.

## Quick Diagnostic Steps

### 1. **Run the Audio Diagnostic**
1. Open `Scenes/AudioDiagnostic.tscn` in Godot
2. Run the scene
3. Check the console output for diagnostic results

### 2. **Check System Audio**
- Ensure your system volume is up
- Check if other applications can play audio
- Verify your audio device is working

### 3. **Check Godot Audio Settings**
- Go to **Project → Project Settings → Audio**
- Verify **Audio → Buses → Master** is enabled
- Check that **Audio → Buses → Master → Volume** is not muted

## Common Issues and Solutions

### **Issue 1: Audio Manager Not Initialized**

**Symptoms**: No audio at all, no error messages
**Cause**: `Global.audio_manager` is null

**Solution**:
```gdscript
# Check in Global.gd _ready() function
func _ready():
    initialize_audio_manager()  # Make sure this is called
```

### **Issue 2: Audio Files Missing**

**Symptoms**: Error messages about missing files
**Cause**: Audio files don't exist in `Assets/Audio/`

**Solution**:
1. Check if these files exist:
   - `Assets/Audio/Menu/ui_click.ogg`
   - `Assets/Audio/Menu/ui_hover.ogg`
   - `Assets/Audio/Ambient/market_ambience.ogg`
2. If missing, run the audio conversion script:
   ```cmd
   cd "Walking Simulator\Assets\Audio"
   convert_audio.bat
   ```

### **Issue 3: ButtonSound Not Configured**

**Symptoms**: Button clicks have no sound
**Cause**: `ButtonSound` AudioStreamPlayer has no stream assigned

**Solution**:
1. Open `Scenes/MainMenu/MainMenu.tscn`
2. Select the `ButtonSound` node
3. In the Inspector, assign `ui_click.ogg` to the **Stream** property

### **Issue 4: Volume Levels Too Low**

**Symptoms**: Audio plays but is very quiet
**Cause**: Volume levels are set too low

**Solution**:
```gdscript
# In MainMenuController.gd, check volume levels
func setup_audio_manager():
    if audio_manager:
        # Test with higher volume
        audio_manager.set_master_volume(1.0)
        audio_manager.set_menu_volume(1.0)
```

### **Issue 5: Audio Bus Issues**

**Symptoms**: Audio system works but no sound output
**Cause**: Audio bus configuration problems

**Solution**:
1. Go to **Project → Project Settings → Audio**
2. Check **Audio → Buses → Master** settings
3. Ensure **Volume** is not set to -∞ dB
4. Try setting **Volume** to 0 dB (no attenuation)

## Manual Testing

### **Test 1: Direct AudioStreamPlayer Test**
```gdscript
# Add this to any script to test direct audio
func test_direct_audio():
    var player = AudioStreamPlayer.new()
    add_child(player)
    player.stream = load("res://Assets/Audio/Menu/ui_click.ogg")
    player.volume_db = 0.0  # Full volume
    player.play()
    print("Playing audio directly...")
```

### **Test 2: Audio Manager Test**
```gdscript
# Test the audio manager directly
func test_audio_manager():
    if Global.audio_manager:
        Global.audio_manager.play_menu_audio("button_click")
        print("Audio manager test - should hear click sound")
    else:
        print("Audio manager is null!")
```

### **Test 3: GlobalSignals Test**
```gdscript
# Test GlobalSignals
func test_global_signals():
    GlobalSignals.on_play_menu_audio.emit("button_click")
    print("GlobalSignals test - should hear click sound")
```

## Debug Console Commands

### **Check Audio Manager Status**
```gdscript
# Run in Godot console
print("Audio manager exists: ", Global.audio_manager != null)
if Global.audio_manager:
    var status = Global.audio_manager.get_configuration_status()
    print("Config status: ", status)
```

### **Check Audio Files**
```gdscript
# Check if audio files exist
var files = [
    "res://Assets/Audio/Menu/ui_click.ogg",
    "res://Assets/Audio/Menu/ui_hover.ogg",
    "res://Assets/Audio/Ambient/market_ambience.ogg"
]
for file in files:
    print(file, " exists: ", ResourceLoader.exists(file))
```

### **Test Volume Levels**
```gdscript
# Check current volume levels
if Global.audio_manager:
    print("Master volume: ", Global.audio_manager.master_volume)
    print("Menu volume: ", Global.audio_manager.menu_volume)
```

## Step-by-Step Fix Process

### **Step 1: Verify Audio Files**
1. Navigate to `Walking Simulator/Assets/Audio/Menu/`
2. Ensure these files exist:
   - `ui_click.ogg`
   - `ui_hover.ogg`
   - `menu_open.ogg`
   - `menu_close.ogg`
   - `region_select.ogg`
   - `start_game.ogg`
3. Navigate to `Walking Simulator/Assets/Audio/Ambient/`
4. Ensure `market_ambience.ogg` exists

### **Step 2: Check Scene Configuration**
1. Open `Scenes/MainMenu/MainMenu.tscn`
2. Select `ButtonSound` node
3. Verify **Stream** property has `ui_click.ogg` assigned
4. Check **Volume** property is not set to -∞ dB

### **Step 3: Verify Global Initialization**
1. Open `Global.gd`
2. Check that `initialize_audio_manager()` is called in `_ready()`
3. Verify the function loads `CulturalAudioManager.tscn`

### **Step 4: Test Audio Manager**
1. Run the main menu scene
2. Check console for "Audio manager initialized in Global" message
3. Check console for "Audio manager connected to MainMenuController" message

### **Step 5: Test Audio Playback**
1. Hover over buttons (should hear hover sound)
2. Click buttons (should hear click sound)
3. Open panels (should hear open sound)
4. Check for background ambient music

## Advanced Troubleshooting

### **Audio Bus Configuration**
If basic fixes don't work, check audio bus configuration:

1. **Project Settings → Audio → Buses**
2. **Master Bus Settings**:
   - Volume: 0 dB (no attenuation)
   - Mute: Unchecked
   - Solo: Unchecked
3. **Add Custom Buses** if needed:
   - Menu Bus
   - Ambient Bus
   - Effects Bus

### **Audio Device Issues**
If audio still doesn't work:

1. **Check Windows Audio**:
   - Right-click speaker icon → Open Sound settings
   - Verify correct output device is selected
   - Test with other applications

2. **Check Godot Audio Driver**:
   - **Project Settings → Audio → Driver**
   - Try different drivers (DirectSound, WASAPI, etc.)

### **Performance Issues**
If audio is choppy or delayed:

1. **Reduce Audio Quality**:
   ```gdscript
   # In AudioConfig.tres
   audio_quality = 0  # Low quality for better performance
   ```

2. **Check Audio Buffer Size**:
   ```gdscript
   # In AudioConfig.tres
   audio_buffer_size = 512  # Smaller buffer for lower latency
   ```

## Prevention

### **Best Practices**
1. **Always test audio** after making changes
2. **Use the diagnostic script** regularly
3. **Keep audio files organized** in proper folders
4. **Test on different systems** to ensure compatibility
5. **Use consistent volume levels** across all audio

### **Regular Maintenance**
1. **Run audio diagnostic** weekly
2. **Check for missing files** after updates
3. **Verify audio manager initialization** in Global.gd
4. **Test all audio interactions** in main menu

## Getting Help

If none of these solutions work:

1. **Run the diagnostic script** and share the output
2. **Check the console** for any error messages
3. **Verify your Godot version** (4.4.1 or compatible)
4. **Test with a simple audio scene** to isolate the issue

The audio system is designed to be robust with multiple fallback mechanisms, so most issues can be resolved by following this guide systematically.
