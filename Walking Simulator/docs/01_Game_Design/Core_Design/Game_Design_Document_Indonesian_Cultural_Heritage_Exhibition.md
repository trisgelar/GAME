# Game Design Document
## Indonesian Cultural Heritage Exhibition

**Version:** 1.1  
**Date:** August 26, 2025  
**Project:** Walking Simulator - Indonesian Cultural Heritage Exhibition  
**Platform:** PC (Godot 4.3)  
**Genre:** Educational Walking Simulator / Cultural Exhibition  

---

## 1. Executive Summary

### 1.1 Game Overview
Indonesian Cultural Heritage Exhibition is an educational walking simulator designed for international seminar exhibitions. The game allows participants to explore three distinct Indonesian regions, each representing different ethnic groups and cultural traditions. Players can walk through culturally authentic environments, collect artifacts, interact with NPCs, and learn about Indonesia's rich cultural heritage.

### 1.2 Target Audience
- **Primary:** International seminar participants and attendees
- **Secondary:** Students, researchers, and cultural enthusiasts
- **Age Range:** 13+ (educational content suitable for all ages)

### 1.3 Educational Goals
- Promote understanding of Indonesian cultural diversity
- Provide interactive learning about traditional customs and artifacts
- Create an engaging platform for cultural exchange
- Support academic research and cultural preservation

---

## 2. Game Design

### 2.1 Core Concept
A first-person walking simulator that transports players to three distinct Indonesian regions, each offering unique cultural experiences through exploration, artifact collection, and NPC interactions.

### 2.2 Gameplay Mechanics

#### 2.2.1 Movement System
- **First-person perspective** with mouse look and WASD movement
- **Walking speed** optimized for exploration and learning
- **Sprint functionality** for faster navigation
- **Jump capability** for accessing elevated areas

#### 2.2.2 Interaction System
- **Raycast-based interaction** for object detection
- **E key** for primary interactions (collecting artifacts, talking to NPCs)
- **I key** for inventory management
- **Right-click** for detailed item information

#### 2.2.3 Artifact Collection
- **Cultural artifacts** scattered throughout each region
- **Collection feedback** with audio and visual effects
- **Inventory system** with detailed cultural information
- **Progress tracking** by region and overall completion

### 2.3 Game Structure

#### 2.3.1 Main Menu
- **Primary buttons:** Start Game, Load Game, How to Play, About Us, Credits, Exit Game
- **Start Game submenu:** Interactive Indonesia map (SVG) with three selectable regions (Indonesia Barat/Jawa, Indonesia Tengah/Tambora, Indonesia Timur/Papua) including a short zoom animation before scene transition
- **Load Game:** Resume from last checkpoint (last region/scene played) with confirmation dialog showing last region and save timestamp
- **Exit Game:** Confirmation dialog with two options (Yes/No)
- **Escape behavior:** Pressing Escape in any game scene opens a confirmation dialog (Yes/No) to return to the main menu and auto-saves progress

#### 2.3.2 Three Cultural Regions

**Indonesia Barat (West Indonesia)**
- **Theme:** Traditional Market Culture
- **Focus:** Sunda and Javanese cuisine
- **Environment:** Pasar (traditional market) setting
- **Artifacts:** Traditional recipes (Soto, Lotek, Baso, Sate)
- **Cultural Elements:** Street food culture, market traditions

**Indonesia Tengah (Central Indonesia)**
- **Theme:** Mount Tambora Historical Experience
- **Focus:** Historical and geological significance
- **Environment:** Mountain landscape from base to peak
- **Artifacts:** Rock samples, historical documents, eruption timeline
- **Cultural Elements:** Historical impact, geological education

**Indonesia Timur (East Indonesia)**
- **Theme:** Papua Ethnic Exploration
- **Focus:** Ancient artifacts and tribal customs
- **Environment:** Megalithic sites and tribal areas
- **Artifacts:** Batu Dootomo, Kapak Perunggu, traditional masks
- **Cultural Elements:** Ancient traditions, tribal heritage

---

## 3. Technical Specifications

### 3.1 Engine and Platform
- **Game Engine:** Godot 4.3
- **Platform:** Windows PC
- **Graphics API:** Forward Plus
- **Input:** Keyboard and Mouse

### 3.2 System Requirements
- **Minimum:**
  - OS: Windows 10
  - CPU: Intel Core i3 or equivalent
  - RAM: 4 GB
  - GPU: Integrated graphics
  - Storage: 2 GB available space

- **Recommended:**
  - OS: Windows 10/11
  - CPU: Intel Core i5 or equivalent
  - RAM: 8 GB
  - GPU: Dedicated graphics card
  - Storage: 5 GB available space

### 3.3 Technical Architecture

#### 3.3.1 Core Systems
- **Global State Management** (`Global.gd`)
- **Event-Driven Communication** (`GlobalSignals.gd`)
- **Cultural Item System** (`CulturalItem.gd`)
- **Inventory Management** (`CulturalInventory.gd`)
- **NPC Interaction System** (`CulturalNPC.gd`)
- **Audio Management** (`CulturalAudioManager.gd`)
- **Scene Management** (`GameSceneManager.gd`) — centralized scene transitions, Escape handling, save/load integration
- **Logging** (`GameLogger.gd`) — file-based logging with level filtering
- **Debug Configuration** (`DebugConfig.gd`) — global log level and module toggles
- **Scene Debugging Tools** (`SceneDebugger.gd`) — optional scene inspection utilities

#### 3.3.2 Scene Structure
```
Scenes/
├── MainMenu/
│   ├── MainMenu.tscn
│   └── MainMenuController.gd
├── IndonesiaBarat/
│   └── PasarScene.tscn
├── IndonesiaTengah/
│   └── TamboraScene.tscn
└── IndonesiaTimur/
    └── PapuaScene.tscn
```

#### 3.3.3 Systems Organization
```
Systems/
├── Items/
│   ├── CulturalItem.gd
│   ├── WorldCulturalItem.gd
│   └── ItemData/
├── Inventory/
│   ├── CulturalInventory.gd
│   ├── InventorySlot.gd
│   └── Related .tscn files
├── Core/
│   ├── GameSceneManager.gd
│   ├── GameLogger.gd
│   └── DebugConfig.gd
├── NPCs/
│   └── CulturalNPC.gd
├── Audio/
│   ├── CulturalAudioManager.gd
│   └── Related .tscn files
└── UI/
    ├── CulturalInfoPanel.gd
    └── Related .tscn files
```

#### 3.3.4 Save/Load and Checkpoint System
- **Checkpoint Policy:** Auto-save when returning to main menu or exiting a game scene
- **Stored Data:** Last scene name, current region, basic progress snapshot, timestamp
- **Storage Location:** `user://game_save.dat` (JSON)
- **Resume Flow:** From main menu, choose Load Game to confirm and jump to the saved scene

#### 3.3.5 Debugging and Logging Configuration
- **Log Levels:** Error, Warning, Info, Debug (0–3) controlled by `DebugConfig.log_level`
- **Module Toggles:** `enable_scene_debugger`, `enable_npc_debug`, `enable_ui_debug`, `enable_input_debug`
- **Environment Overrides:** Optional env vars, e.g., `GAME_LOG_LEVEL=1`, `SCENE_DEBUGGER=1`

---

## 4. Art and Audio Design

### 4.1 Visual Style
- **Current:** Basic 3D shapes (CSG nodes) for prototyping
- **Target:** PS2-style models and textures
- **Color Palette:** Region-specific color schemes
- **Lighting:** Natural and atmospheric lighting

### 4.2 Audio Design
- **Ambient Audio:** Region-specific environmental sounds
- **Cultural Audio:** Traditional music and sound effects
- **Voice Audio:** Cultural narration and NPC dialogue
- **Audio Categories:**
  - Market ambience (Indonesia Barat)
  - Mountain wind (Indonesia Tengah)
  - Jungle sounds (Indonesia Timur)

### 4.3 Asset Requirements
- **3D Models:** Traditional market stalls, mountain terrain, megalithic structures
- **Textures:** PS2-style textures for all environmental elements
- **Audio Files:** Ambient sounds, cultural music, voice recordings
- **UI Elements:** Cultural-themed interface elements

---

## 5. User Interface Design

### 5.1 Main Menu Interface
- **Title:** "Indonesian Cultural Heritage Exhibition"
- **Region Selection:** Three prominent buttons for each region
- **Settings:** Exhibition mode configuration
- **Progress Display:** Overall completion status

### 5.2 In-Game Interface
- **HUD Elements:**
  - Interaction prompts
  - Region information
  - Session timer
  - Collection progress

### 5.3 Inventory System
- **Grid-based Layout:** 5x4 slot arrangement
- **Item Information:** Detailed cultural descriptions
- **Progress Tracking:** Region-specific completion
- **Visual Feedback:** Rarity-based color coding

### 5.4 Cultural Information Panel
- **Detailed Descriptions:** Historical and cultural context
- **Audio Integration:** Cultural narration
- **Educational Content:** Learning objectives and significance

---

## 6. Content Design

### 6.1 Cultural Artifacts

#### Indonesia Barat Artifacts
1. **Soto Recipe** (Common)
   - Cultural significance in Indonesian cuisine
   - Regional variations and history
2. **Lotek Recipe** (Common)
   - Traditional vegetable dish
   - Cultural importance in Sundanese cuisine
3. **Baso Recipe** (Common)
   - Street food culture representation
   - Historical development
4. **Sate Recipe** (Common)
   - National dish significance
   - Regional variations

#### Indonesia Tengah Artifacts
1. **Tambora Rock Sample** (Uncommon)
   - Geological significance
   - Historical context
2. **Historical Document** (Rare)
   - 1815 eruption records
   - Global impact documentation
3. **Eruption Timeline** (Uncommon)
   - Chronological events
   - Scientific significance
4. **Climate Impact** (Rare)
   - Global climate effects
   - Historical consequences

#### Indonesia Timur Artifacts
1. **Batu Dootomo** (Rare)
   - Sacred stone significance
   - Ancient spiritual beliefs
2. **Kapak Perunggu** (Rare)
   - Bronze age artifacts
   - Archaeological importance
3. **Traditional Mask** (Uncommon)
   - Tribal ceremonial use
   - Cultural symbolism
4. **Ancient Tool** (Common)
   - Historical craftsmanship
   - Traditional techniques
5. **Sacred Stone** (Legendary)
   - Spiritual significance
   - Cultural heritage
6. **Tribal Ornament** (Uncommon)
   - Traditional adornments
   - Cultural identity

### 6.2 NPC Characters

#### Indonesia Barat NPCs
- **Market Guide:** Provides information about traditional market culture
- **Food Vendor:** Shares knowledge about street food traditions
- **Cultural Expert:** Explains Sundanese and Javanese customs

#### Indonesia Tengah NPCs
- **Geological Guide:** Explains Mount Tambora's significance
- **Historical Expert:** Shares eruption history and impact
- **Research Scientist:** Provides scientific context

#### Indonesia Timur NPCs
- **Tribal Elder:** Shares ancient traditions and customs
- **Archaeological Guide:** Explains megalithic sites
- **Cultural Preservationist:** Discusses heritage conservation

### 6.3 Educational Content
- **Historical Context:** Accurate historical information
- **Cultural Significance:** Deep cultural meaning and importance
- **Geographic Information:** Regional context and location details
- **Interactive Learning:** Engaging educational experiences

---

## 7. Gameplay Flow

### 7.1 Session Structure
1. **Main Menu Selection:** Start Game (map) or Load Game (resume checkpoint)
2. **Environment Loading:** Seamless transition to selected region
3. **Exploration Phase:** Free exploration with artifact collection
4. **NPC Interaction:** Cultural learning through character dialogue
5. **Progress Tracking:** Continuous feedback on collection status
6. **Escape/Exit:** Confirm to return to the main menu (auto-save)
7. **Session Completion:** Summary of learning achievements

### 7.2 Learning Objectives
- **Cultural Awareness:** Understanding of Indonesian diversity
- **Historical Knowledge:** Learning about significant events
- **Geographic Understanding:** Regional differences and characteristics
- **Interactive Engagement:** Active participation in cultural learning

### 7.3 Exhibition Mode Features
- **Time Management:** Configurable session durations
- **Progress Tracking:** Detailed completion statistics
- **Educational Assessment:** Learning outcome measurement
- **Cultural Documentation:** Comprehensive cultural information

---

## 8. Development Roadmap

### 8.1 Phase 1: Core Systems (Completed)
- ✅ Basic walking simulator framework
- ✅ Main menu and scene management
- ✅ Global state management
- ✅ Event-driven communication system

### 8.2 Phase 2: Feature Implementation (Completed)
- ✅ Cultural item system
- ✅ Inventory management
- ✅ NPC interaction system
- ✅ Audio management system
- ✅ UI systems

### 8.3 Phase 3: Prototype Development (Completed)
- ✅ Basic 3D environment creation
- ✅ Artifact placement and collection
- ✅ NPC implementation
- ✅ Audio integration
- ✅ Playable prototype

### 8.4 Phase 4: Asset Integration (Future)
- **3D Model Replacement:** PS2-style models for all environments
- **Texture Implementation:** High-quality cultural textures
- **Audio Enhancement:** Professional cultural audio content
- **UI Polish:** Cultural-themed interface design

### 8.5 Phase 5: Content Enhancement (Future)
- **Educational Content:** Comprehensive cultural information
- **NPC Dialogue:** Rich cultural conversations
- **Audio Narration:** Professional voice recordings
- **Cultural Accuracy:** Expert review and validation

### 8.6 Phase 6: Testing and Polish (Future)
- **User Testing:** Exhibition participant feedback
- **Performance Optimization:** Smooth gameplay experience
- **Bug Fixes:** Quality assurance and stability
- **Final Polish:** Professional presentation quality

---

## 9. Educational Integration

### 9.1 Learning Outcomes
- **Cultural Competency:** Understanding of Indonesian cultural diversity
- **Historical Literacy:** Knowledge of significant historical events
- **Geographic Awareness:** Understanding of regional characteristics
- **Interactive Learning:** Engagement with cultural content

### 9.2 Assessment Methods
- **Artifact Collection:** Progress tracking and completion rates
- **Cultural Knowledge:** Information retention and understanding
- **Engagement Metrics:** Time spent in different regions
- **Learning Feedback:** Participant surveys and evaluations

### 9.3 Educational Standards
- **Cultural Accuracy:** Expert-reviewed content
- **Historical Authenticity:** Verified historical information
- **Geographic Precision:** Accurate regional representation
- **Educational Value:** Measurable learning outcomes

---

## 10. Technical Implementation

### 10.1 Code Architecture
- **Modular Design:** Separated systems for maintainability
- **Event-Driven:** Decoupled communication between systems
- **Resource-Based:** Efficient asset management
- **Scalable Structure:** Easy expansion and modification

### 10.2 Performance Considerations
- **Optimized Rendering:** Efficient 3D graphics
- **Audio Management:** Streamlined audio processing
- **Memory Management:** Efficient resource usage
- **Loading Optimization:** Fast scene transitions

### 10.3 Quality Assurance
- **Code Review:** Regular code quality checks
- **Testing Procedures:** Comprehensive testing protocols
- **Performance Monitoring:** Continuous performance assessment
- **User Feedback:** Regular user testing and feedback integration

---

## 11. Future Enhancements

### 11.1 Potential Features
- **Multiplayer Support:** Collaborative cultural exploration
- **Virtual Reality:** Immersive VR cultural experiences
- **Mobile Version:** Portable cultural learning platform
- **Additional Regions:** Expansion to more Indonesian regions

### 11.2 Content Expansion
- **More Artifacts:** Additional cultural items and information
- **Enhanced NPCs:** More detailed character interactions
- **Cultural Events:** Dynamic cultural celebrations and events
- **Seasonal Content:** Time-based cultural experiences

### 11.3 Technical Improvements
- **Advanced Graphics:** Enhanced visual quality and effects
- **Audio Enhancement:** Spatial audio and advanced sound design
- **AI Integration:** Intelligent NPC behavior and interactions
- **Analytics System:** Detailed learning analytics and reporting

---

## 12. Conclusion

The Indonesian Cultural Heritage Exhibition represents a significant step forward in educational gaming and cultural preservation. By combining interactive technology with authentic cultural content, the game provides a unique platform for learning about Indonesia's rich cultural heritage.

The modular architecture and comprehensive systems ensure that the game can be easily expanded and maintained, while the focus on educational value and cultural accuracy makes it a valuable tool for cultural education and preservation.

As the project moves forward, continued collaboration with cultural experts, educators, and the Indonesian community will ensure that the game remains an authentic and valuable representation of Indonesia's cultural diversity.

---

**Document Version:** 1.1  
**Last Updated:** August 26, 2025  
**Next Review:** September 2025  
**Project Status:** Prototype Complete - Enhanced Menu & Checkpoint System

---

### Appendix A: Recent Updates (2025-08-26)
- Implemented `GameSceneManager` for centralized scene transitions and Escape handling
- Added checkpoint-based Save/Load (auto-save on menu return/exit; Load Game menu entry)
- Redesigned main menu with SVG Indonesia map, zoom effect, and clearer navigation
- Simplified confirmation dialogs to two options (Yes/No); removed default OK button
- Introduced `DebugConfig` to control log verbosity and module-specific debug output
