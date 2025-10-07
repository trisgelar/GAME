# TamboraRoot Scene Audio Files

## Overview
This document lists all audio files used in the TamboraRoot scene, including ambient audio, player audio, and interaction sounds.

## Scene Information
- **Scene File**: `Scenes/IndonesiaTengah/Tambora/TamboraRoot.tscn`
- **Region**: Indonesia Tengah (Central Indonesia)
- **Region Name**: "Indonesia Tengah" (mapped from scene name "TamboraRoot")
- **Player Controller**: `PlayerControllerIntegrated_tambora.gd`

## Audio Files Used

### 🌋 **Ambient Audio (Background Music)**
**File**: `Assets/Audio/Ambient/mountain_wind.ogg`
- **Usage**: Background ambient audio for TamboraRoot scene
- **Trigger**: Automatically when entering the scene
- **Function**: `Global.start_region_session("Indonesia Tengah")` → `audio_manager.play_region_ambience("Indonesia Tengah")`
- **Description**: Mountain wind sounds appropriate for Mount Tambora region

### 🎮 **Player Audio (Footsteps & Actions)**
**Player Controller**: `PlayerControllerIntegrated_tambora.gd`

#### **Footstep Audio**
**Files**: Located in `Assets/Audio/Player/Footsteps/`
- **Surface Types**: grass, stone, dirt, wood
- **Trigger**: When player moves on different surfaces
- **Function**: `GlobalSignals.on_play_footstep_audio.emit()`
- **Example Files**:
  - `footstep_grass_1.ogg`, `footstep_grass_2.ogg`
  - `footstep_stone_1.ogg`, `footstep_stone_2.ogg`
  - `footstep_dirt_1.ogg`, `footstep_dirt_2.ogg`
  - `footstep_wood_1.ogg`, `footstep_wood_2.ogg`

#### **Player Action Audio**
**Files**: Located in `Assets/Audio/Player/Actions/`
- **Jump Sound**: `jump.ogg`
- **Land Sound**: `land.ogg`
- **Trigger**: When player jumps or lands
- **Function**: `GlobalSignals.on_play_player_audio.emit("jump")` / `GlobalSignals.on_play_player_audio.emit("land")`

### 🎯 **Interaction Audio**
**Files**: Located in `Assets/Audio/UI/`
- **Success Sound**: `success.ogg`
- **Trigger**: When collecting artifacts or cultural items
- **Function**: `GlobalSignals.on_play_ui_audio.emit("success")`
- **Description**: Confirmation sound for successful interactions

### 🎵 **Audio Manager Integration**
**Scene**: `Systems/Audio/CulturalAudioManager.tscn`
- **Script**: `CulturalAudioManagerEnhanced.gd`
- **Audio Players**:
  - `AmbientPlayer`: For background music (`mountain_wind.ogg`)
  - `MenuPlayer`: For UI sounds (`success.ogg`)
  - `FootstepPlayer`: For footstep sounds
  - `UIPlayer`: For interaction sounds

## Audio Flow in TamboraRoot

### **Scene Entry:**
1. **TamboraRoot.tscn** loads
2. **RegionSceneController._ready()** calls `Global.start_region_session("Indonesia Tengah")`
3. **Global.start_region_session()** calls `audio_manager.play_region_ambience("Indonesia Tengah")`
4. **Audio Manager** plays `mountain_wind.ogg` as background ambient

### **Player Movement:**
1. **Player moves** → `PlayerControllerIntegrated_tambora.gd` detects movement
2. **Footstep timer** triggers → `GlobalSignals.on_play_footstep_audio.emit()`
3. **Audio Manager** plays appropriate footstep sound based on surface type
4. **Surface detection** → `GlobalSignals.on_set_surface_type.emit(surface_type)`

### **Player Actions:**
1. **Jump** → `GlobalSignals.on_play_player_audio.emit("jump")` → `jump.ogg`
2. **Land** → `GlobalSignals.on_play_player_audio.emit("land")` → `land.ogg`

### **Interactions:**
1. **Collect artifact** → `GlobalSignals.on_play_ui_audio.emit("success")` → `success.ogg`
2. **NPC interaction** → `GlobalSignals.on_play_ui_audio.emit("success")` → `success.ogg`

## Audio Configuration

### **Volume Settings:**
- **Master Volume**: 1.0 (100%)
- **Ambient Volume**: 0.3 (30%) - Background music
- **Menu Volume**: 0.6 (60%) - UI sounds
- **Footstep Volume**: 0.5 (50%) - Player movement
- **UI Volume**: 0.8 (80%) - Interaction sounds

### **Audio Mapping:**
```gdscript
# Region to Audio Mapping
"Indonesia Tengah" → "mountain_wind.ogg"
"TamboraRoot" → "Indonesia Tengah" → "mountain_wind.ogg"

# Surface to Footstep Mapping
"grass" → footstep_grass_*.ogg
"stone" → footstep_stone_*.ogg
"dirt" → footstep_dirt_*.ogg
"wood" → footstep_wood_*.ogg
```

## File Structure
```
Assets/Audio/
├── Ambient/
│   └── mountain_wind.ogg          # TamboraRoot background
├── Player/
│   ├── Actions/
│   │   ├── jump.ogg               # Player jump sound
│   │   └── land.ogg               # Player landing sound
│   └── Footsteps/
│       ├── footstep_grass_1.ogg   # Grass surface
│       ├── footstep_grass_2.ogg
│       ├── footstep_stone_1.ogg   # Stone surface
│       ├── footstep_stone_2.ogg
│       ├── footstep_dirt_1.ogg    # Dirt surface
│       ├── footstep_dirt_2.ogg
│       ├── footstep_wood_1.ogg    # Wood surface
│       └── footstep_wood_2.ogg
└── UI/
    └── success.ogg                # Interaction success
```

## Troubleshooting

### **Common Issues:**
1. **No Background Music**: Check if `mountain_wind.ogg` exists in `Assets/Audio/Ambient/`
2. **No Footstep Sounds**: Check if footstep files exist in `Assets/Audio/Player/Footsteps/`
3. **No Interaction Sounds**: Check if `success.ogg` exists in `Assets/Audio/UI/`
4. **Audio Manager Not Found**: Check if `CulturalAudioManager.tscn` is loaded in scene

### **Debug Commands:**
```gdscript
# Check audio manager status
if Global.audio_manager:
    Global.audio_manager.debug_audio_status()

# Test specific audio
Global.audio_manager.play_ambient_audio("mountain_wind")
Global.audio_manager.play_ui_audio("success")
```

## Summary
The TamboraRoot scene uses a comprehensive audio system with:
- **1 Ambient Audio File**: `mountain_wind.ogg` for background
- **2 Player Action Files**: `jump.ogg`, `land.ogg`
- **8+ Footstep Files**: Various surface types
- **1 UI Audio File**: `success.ogg` for interactions

All audio is managed through the `CulturalAudioManagerEnhanced` system with proper volume controls and fallback mechanisms.
