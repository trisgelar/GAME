# Audio File Preparation & Asset List
**Date:** 2025-01-07  
**Project:** Indonesian Cultural Heritage Exhibition  
**Version:** 1.0  

## 🎵 **Complete Audio Asset Requirements**

### **📁 Directory Structure**
```
Assets/Audio/
├── Menu/              # 6 files
├── Player/
│   ├── Footsteps/     # 15 files
│   └── Actions/       # 4 files
├── UI/                # 7 files
├── Ambient/           # 3 files
├── Effects/           # 4 files
└── Dialog/            # Future NPC dialogue

Resources/Audio/
├── Menu/              # 6 .tres files
├── Player/            # 19 .tres files
├── UI/                # 7 .tres files
├── Ambient/           # 3 .tres files
└── Effects/           # 4 .tres files
```

## 🎮 **Menu Audio (6 files)**

| # | Filename | Duration | Volume | Description | Search Terms |
|---|----------|----------|--------|-------------|--------------|
| 1 | `ui_hover.ogg` | 0.5-1.0s | -5dB | Subtle UI hover sound | "ui hover", "button hover", "interface hover" |
| 2 | `ui_click.ogg` | 0.3-0.7s | -3dB | Satisfying click sound | "ui click", "button click", "interface click" |
| 3 | `menu_open.ogg` | 0.8-1.2s | -6dB | Menu opening sound | "menu open", "panel open", "interface open" |
| 4 | `menu_close.ogg` | 0.6-1.0s | -6dB | Menu closing sound | "menu close", "panel close", "interface close" |
| 5 | `start_game.ogg` | 2.0-3.0s | -4dB | Epic startup sound | "game start", "startup sound", "epic intro" |
| 6 | `region_select.ogg` | 1.0-1.5s | -5dB | Region selection sound | "region select", "area select", "location select" |

**Resource Files:**
- `UIHover.tres`, `UIClick.tres`, `MenuOpen.tres`, `MenuClose.tres`, `StartGame.tres`, `RegionSelect.tres`

## 🦶 **Footstep Audio (15 files)**

### **Grass Surface (3 files)**
| # | Filename | Duration | Volume | Description |
|---|----------|----------|--------|-------------|
| 1 | `footstep_grass_1.ogg` | 0.3-0.5s | -8dB | Soft grass step |
| 2 | `footstep_grass_2.ogg` | 0.3-0.5s | -8dB | Soft grass step (variation) |
| 3 | `footstep_grass_3.ogg` | 0.3-0.5s | -8dB | Soft grass step (variation) |

### **Stone Surface (3 files)**
| # | Filename | Duration | Volume | Description |
|---|----------|----------|--------|-------------|
| 4 | `footstep_stone_1.ogg` | 0.4-0.6s | -10dB | Hard stone step |
| 5 | `footstep_stone_2.ogg` | 0.4-0.6s | -10dB | Hard stone step (variation) |
| 6 | `footstep_stone_3.ogg` | 0.4-0.6s | -10dB | Hard stone step (variation) |

### **Wood Surface (3 files)**
| # | Filename | Duration | Volume | Description |
|---|----------|----------|--------|-------------|
| 7 | `footstep_wood_1.ogg` | 0.3-0.5s | -9dB | Wooden surface step |
| 8 | `footstep_wood_2.ogg` | 0.3-0.5s | -9dB | Wooden surface step (variation) |
| 9 | `footstep_wood_3.ogg` | 0.3-0.5s | -9dB | Wooden surface step (variation) |

### **Dirt Surface (3 files)**
| # | Filename | Duration | Volume | Description |
|---|----------|----------|--------|-------------|
| 10 | `footstep_dirt_1.ogg` | 0.3-0.5s | -8dB | Dirt/earth step |
| 11 | `footstep_dirt_2.ogg` | 0.3-0.5s | -8dB | Dirt/earth step (variation) |
| 12 | `footstep_dirt_3.ogg` | 0.3-0.5s | -8dB | Dirt/earth step (variation) |

### **Water Surface (3 files)**
| # | Filename | Duration | Volume | Description |
|---|----------|----------|--------|-------------|
| 13 | `footstep_water_1.ogg` | 0.4-0.6s | -7dB | Water splash step |
| 14 | `footstep_water_2.ogg` | 0.4-0.6s | -7dB | Water splash step (variation) |
| 15 | `footstep_water_3.ogg` | 0.4-0.6s | -7dB | Water splash step (variation) |

**Search Terms:** "footstep [surface]", "walk [surface]", "step [surface]"

## 🎮 **Player Action Audio (4 files)**

| # | Filename | Duration | Volume | Description | Search Terms |
|---|----------|----------|--------|-------------|--------------|
| 1 | `jump.ogg` | 0.5-0.8s | -6dB | Jump sound effect | "jump sound", "player jump", "character jump" |
| 2 | `land.ogg` | 0.3-0.6s | -8dB | Landing impact sound | "land sound", "player land", "character land" |
| 3 | `run_start.ogg` | 0.4-0.7s | -7dB | Start running sound | "run start", "sprint start", "running begin" |
| 4 | `run_stop.ogg` | 0.3-0.5s | -8dB | Stop running sound | "run stop", "sprint stop", "running end" |

**Resource Files:**
- `Jump.tres`, `Land.tres`, `RunStart.tres`, `RunStop.tres`

## 🖥️ **UI Audio (7 files)**

| # | Filename | Duration | Volume | Description | Search Terms |
|---|----------|----------|--------|-------------|--------------|
| 1 | `inventory_open.ogg` | 0.5-0.8s | -5dB | Inventory opening | "inventory open", "bag open", "container open" |
| 2 | `inventory_close.ogg` | 0.4-0.7s | -5dB | Inventory closing | "inventory close", "bag close", "container close" |
| 3 | `item_hover.ogg` | 0.2-0.4s | -6dB | Item hover sound | "item hover", "object hover", "hover sound" |
| 4 | `item_select.ogg` | 0.3-0.5s | -4dB | Item selection | "item select", "object select", "select sound" |
| 5 | `notification.ogg` | 0.8-1.2s | -3dB | Notification sound | "notification", "alert", "message sound" |
| 6 | `error.ogg` | 0.5-0.8s | -4dB | Error sound | "error sound", "wrong", "mistake sound" |
| 7 | `success.ogg` | 0.6-1.0s | -3dB | Success sound | "success sound", "correct", "achievement" |

**Resource Files:**
- `InventoryOpen.tres`, `InventoryClose.tres`, `ItemHover.tres`, `ItemSelect.tres`, `Notification.tres`, `Error.tres`, `Success.tres`

## 🌍 **Ambient Audio (3 files)**

| # | Filename | Duration | Volume | Description | Search Terms |
|---|----------|----------|--------|-------------|--------------|
| 1 | `market_ambience.ogg` | 30-60s loop | -12dB | Traditional market sounds | "market ambience", "bazaar sounds", "crowd market" |
| 2 | `mountain_wind.ogg` | 30-60s loop | -15dB | Mountain wind and nature | "mountain wind", "nature sounds", "wind ambience" |
| 3 | `jungle_sounds.ogg` | 30-60s loop | -12dB | Jungle ambience | "jungle sounds", "forest ambience", "tropical nature" |

**Resource Files:**
- `MarketAmbience.tres`, `MountainWind.tres`, `JungleSounds.tres`

## 🎯 **Cultural Effects Audio (4 files)**

| # | Filename | Duration | Volume | Description | Search Terms |
|---|----------|----------|--------|-------------|--------------|
| 1 | `collection_chime.ogg` | 1.0-1.5s | -4dB | Item collection sound | "collection sound", "pickup chime", "item collect" |
| 2 | `cultural_narration.ogg` | 2.0-5.0s | -2dB | Cultural information | "narration", "cultural info", "educational audio" |
| 3 | `npc_hello.ogg` | 1.0-2.0s | -3dB | NPC greeting | "npc hello", "character greeting", "villager hello" |
| 4 | `transition_sound.ogg` | 1.5-2.5s | -5dB | Region transition | "transition sound", "area change", "scene transition" |

**Resource Files:**
- `CollectionChime.tres`, `CulturalNarration.tres`, `NPCHello.tres`, `TransitionSound.tres`

## 📊 **Audio Statistics Summary**

### **File Count by Category**
- **Menu Audio**: 6 files
- **Footstep Audio**: 15 files
- **Player Action Audio**: 4 files
- **UI Audio**: 7 files
- **Ambient Audio**: 3 files
- **Cultural Effects Audio**: 4 files
- **Total**: 39 audio files

### **Duration Ranges**
- **Short Sounds**: 0.2-0.5s (UI feedback, footsteps)
- **Medium Sounds**: 0.5-2.0s (actions, notifications)
- **Long Sounds**: 2.0-5.0s (narration, transitions)
- **Loop Sounds**: 30-60s (ambient audio)

### **Volume Levels**
- **Loud**: -2dB to -4dB (important notifications)
- **Medium**: -5dB to -8dB (UI, footsteps)
- **Quiet**: -10dB to -15dB (ambient, background)

## 🎯 **Priority Order for Audio Creation**

### **High Priority (Essential)**
1. Menu audio (6 files) - Core UI experience
2. Footstep audio (15 files) - Player movement feedback
3. UI success/error (2 files) - Critical feedback

### **Medium Priority (Important)**
4. Player action audio (4 files) - Movement variety
5. UI inventory audio (2 files) - System feedback
6. Ambient audio (3 files) - Environmental immersion

### **Low Priority (Enhancement)**
7. Cultural effects (4 files) - Cultural authenticity
8. UI hover/select (2 files) - Polish and refinement

## 🔧 **Technical Requirements**

### **File Format**
- **Primary**: .ogg (Ogg Vorbis) for best compression
- **Fallback**: .wav for uncompressed quality
- **Avoid**: .mp3 (patent issues), .m4a (Apple-specific)

### **Audio Quality**
- **Sample Rate**: 44.1kHz for music, 22kHz for SFX
- **Bit Depth**: 16-bit minimum, 24-bit preferred
- **Channels**: Mono for SFX, Stereo for music/ambient

### **File Size Guidelines**
- **Short SFX**: < 100KB
- **Medium SFX**: < 500KB
- **Long Audio**: < 2MB
- **Ambient Loops**: < 5MB

## 📝 **Implementation Checklist**

### **Phase 1: Core Audio**
- [ ] Create all 39 audio files
- [ ] Convert to .ogg format
- [ ] Test volume levels
- [ ] Create .tres resource files

### **Phase 2: Integration**
- [ ] Add files to Assets/Audio/ directories
- [ ] Create Resources/Audio/ .tres files
- [ ] Test audio loading in game
- [ ] Verify signal connections

### **Phase 3: Polish**
- [ ] Fine-tune volume levels
- [ ] Test audio mixing
- [ ] Implement audio settings UI
- [ ] Performance optimization

## 🎵 **Audio Sources & Licensing**

### **Recommended Sources**
- **Freesound.org**: Creative Commons audio
- **Zapsplat.com**: Professional game audio
- **Adobe Audition**: Audio editing software
- **Audacity**: Free audio editing

### **Licensing Considerations**
- **Commercial Use**: Ensure proper licensing
- **Attribution**: Credit audio creators
- **Royalty-Free**: Preferred for commercial projects
- **Original Content**: Create custom audio when possible

## 🔮 **Future Audio Expansion**

### **Additional Categories**
- **Weather Audio**: Rain, wind, storms
- **Animal Sounds**: Birds, insects, wildlife
- **Cultural Music**: Traditional Indonesian instruments
- **Voice Acting**: NPC dialogue in multiple languages

### **Advanced Features**
- **Dynamic Audio**: Context-aware volume mixing
- **3D Spatial Audio**: Positional sound effects
- **Audio Compression**: Advanced file optimization
- **Streaming Audio**: Large file management
