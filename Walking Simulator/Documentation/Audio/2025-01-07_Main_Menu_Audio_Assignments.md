# Main Menu Audio Assignments

## Overview
This document lists all audio assignments for the main menu scene, including background music, button sounds, and navigation audio.

## Audio Files Available
Located in: `Assets/Audio/Menu/`

| Audio File | Description | Usage |
|------------|-------------|-------|
| `ui_click.ogg` | Button click sound | All button clicks |
| `ui_hover.ogg` | Button hover sound | Mouse hover over buttons |
| `menu_open.ogg` | Panel open sound | Opening info panels |
| `menu_close.ogg` | Panel close sound | Closing panels, back to main |
| `region_select.ogg` | Region selection sound | Selecting Indonesia regions |
| `start_game.ogg` | Game start sound | Starting 3D map exploration |

## Background Music
Located in: `Assets/Audio/Menu/` and `Assets/Audio/Ambient/`

| Audio File | Description | Usage |
|------------|-------------|-------|
| `start_game.ogg` | Game start music | Main menu background music |
| `market_ambience.ogg` | Market background ambience | Pasar scene ambient |
| `jungle_sounds.ogg` | Jungle ambient sounds | Papua scene ambient |
| `mountain_wind.ogg` | Mountain wind sounds | Tambora scene ambient |

## Audio Assignments by Scene/Action

### 🏠 **Main Menu (Initial Load)**
**Function**: `_ready()` → `start_background_music()`
- **Background Music**: `start_game.ogg` (continuous loop)
- **Trigger**: Automatically when main menu loads
- **Audio Manager Call**: `audio_manager.play_ambient_audio("start_game")`

### 🎮 **Button Interactions**

#### **All Buttons (Hover)**
**Function**: `_on_button_hover()`
- **Audio**: `ui_hover.ogg`
- **Trigger**: Mouse enters any button
- **Audio Manager Call**: `audio_manager.play_menu_audio("button_hover")`

#### **All Buttons (Click)**
**Function**: `play_button_sound()`
- **Audio**: `ui_click.ogg`
- **Trigger**: Any button is clicked
- **Audio Manager Call**: `audio_manager.play_menu_audio("button_click")`

### 🗺️ **3D Map Navigation**

#### **Explore 3D Map Button**
**Function**: `_on_explore_3d_map_pressed()`
1. **Button Click**: `ui_click.ogg`
2. **Stop Background**: All audio stops (including `start_game.ogg`)
3. **Delay**: 0.3 seconds
4. **Navigate**: To 3D map scene (no additional audio needed)
- **Note**: `start_game.ogg` was already playing as background music

### 🌏 **Region Selection**

#### **Indonesia Barat Button**
**Function**: `_on_indonesia_barat_pressed()`
1. **Button Click**: `ui_click.ogg`
2. **Stop Background**: All audio stops
3. **Delay**: 0.3 seconds
4. **Region Select**: `region_select.ogg`
5. **Navigate**: To Indonesia Barat region
- **Audio Manager Call**: `audio_manager.play_menu_audio("region_select")`

#### **Indonesia Tengah Button**
**Function**: `_on_indonesia_tengah_pressed()`
1. **Button Click**: `ui_click.ogg`
2. **Stop Background**: All audio stops
3. **Delay**: 0.3 seconds
4. **Region Select**: `region_select.ogg`
5. **Navigate**: To Indonesia Tengah region
- **Audio Manager Call**: `audio_manager.play_menu_audio("region_select")`

#### **Indonesia Timur Button**
**Function**: `_on_indonesia_timur_pressed()`
1. **Button Click**: `ui_click.ogg`
2. **Stop Background**: All audio stops
3. **Delay**: 0.3 seconds
4. **Region Select**: `region_select.ogg`
5. **Navigate**: To Indonesia Timur region
- **Audio Manager Call**: `audio_manager.play_menu_audio("region_select")`

### 🎭 **Other Navigation**

#### **Ethnicity Detection Button**
**Function**: `_on_ethnicity_detection_pressed()`
1. **Button Click**: `ui_click.ogg`
2. **Stop Background**: All audio stops
3. **Navigate**: To ethnicity detection scene

#### **Topeng Nusantara Button**
**Function**: `_on_topeng_nusantara_pressed()`
1. **Button Click**: `ui_click.ogg`
2. **Stop Background**: All audio stops
3. **Navigate**: To topeng nusantara scene

### 📋 **Info Panels**

#### **How to Play Panel**
**Function**: `show_how_to_play_panel()`
1. **Panel Open**: `menu_open.ogg`
2. **Audio Manager Call**: `audio_manager.play_menu_audio("menu_open")`

#### **About Us Panel**
**Function**: `show_about_us_panel()`
1. **Panel Open**: `menu_open.ogg`
2. **Audio Manager Call**: `audio_manager.play_menu_audio("menu_open")`

#### **Credits Panel**
**Function**: `show_credits_panel()`
1. **Panel Open**: `menu_open.ogg`
2. **Audio Manager Call**: `audio_manager.play_menu_audio("menu_open")`

#### **Back to Main Menu**
**Function**: `_on_back_to_main_pressed()`
1. **Button Click**: `ui_click.ogg`
2. **Panel Close**: `menu_close.ogg`
3. **Audio Manager Call**: `audio_manager.play_menu_audio("menu_close")`

### 🔄 **Other Functions**

#### **Load Game Button**
**Function**: `_on_load_game_pressed()`
1. **Button Click**: `ui_click.ogg`
2. **Action**: Shows load game dialog (no navigation)

#### **Exit Game Button**
**Function**: `_on_exit_game_pressed()`
1. **Button Click**: `ui_click.ogg`
2. **Action**: Shows exit confirmation dialog

## Audio Flow Summary

### **Main Menu Experience:**
1. **Load**: `start_game.ogg` starts playing (background)
2. **Hover**: `ui_hover.ogg` plays (no overlap)
3. **Click**: `ui_click.ogg` plays (no overlap)
4. **Panel Open**: `menu_open.ogg` plays (no overlap)
5. **Panel Close**: `menu_close.ogg` plays (no overlap)

### **Navigation Experience:**
1. **Click Navigation Button**: `ui_click.ogg`
2. **Stop All Audio**: Background music stops completely
3. **Wait 0.3s**: Ensures clean audio transition
4. **Play Navigation Sound**: 
   - 3D Map → No additional audio (start_game.ogg was background)
   - Region Selection → `region_select.ogg`
5. **Navigate**: To target scene

### **Region Entry (After Navigation):**
When entering a region scene, `RegionSceneController._ready()` calls:
- `Global.start_region_session(region_name)`
- `audio_manager.play_region_ambience(region_name)`
- **Indonesia Barat (Pasar Scene)** → `market_ambience.ogg`
- **Indonesia Tengah (Tambora Scene)** → `mountain_wind.ogg`
- **Indonesia Timur (Papua Scene)** → `jungle_sounds.ogg`

## Audio Manager Integration

### **Primary Audio Manager**
- **Class**: `CulturalAudioManagerEnhanced`
- **Location**: `Systems/Audio/CulturalAudioManagerEnhanced.gd`
- **Scene**: `Systems/Audio/CulturalAudioManager.tscn`

### **Fallback System**
If audio manager is not available, uses `GlobalSignals`:
- `GlobalSignals.on_play_menu_audio.emit(audio_id)`
- `GlobalSignals.on_play_ambient_audio.emit(audio_id)`
- `GlobalSignals.on_stop_all_audio.emit()`

### **Audio Categories**
- **Menu Audio**: Button clicks, hovers, panel sounds
- **Ambient Audio**: Background music, region ambience
- **UI Audio**: Success sounds, notifications

## Troubleshooting

### **Common Issues:**
1. **No Audio**: Check if `Global.audio_manager` is initialized
2. **Overlapping Audio**: Check if `stop_background_music()` is called before navigation
3. **Missing Files**: Verify audio files exist in `Assets/Audio/Menu/`
4. **Wrong Audio**: Check audio file names match the assignments above

### **Debug Commands:**
```gdscript
# Check audio manager status
if Global.audio_manager:
    Global.audio_manager.debug_audio_status()

# Test specific audio
Global.audio_manager.play_menu_audio("button_click")
```

## File Structure
```
Assets/Audio/
├── Menu/
│   ├── ui_click.ogg          # Button clicks
│   ├── ui_hover.ogg          # Button hovers
│   ├── menu_open.ogg         # Panel opens
│   ├── menu_close.ogg        # Panel closes
│   ├── region_select.ogg     # Region selection
│   └── start_game.ogg        # Game start
└── Ambient/
    └── market_ambience.ogg   # Main menu background
```

This documentation provides a complete reference for all audio assignments in the main menu system.
