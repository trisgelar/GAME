# Refined Game Design: Three Indonesian Regions Exhibition
**Date:** December 19, 2024  
**Topic:** Three-Region Indonesian Cultural Game Design  
**Type:** Game Design Refinement & Exhibition Planning

## User Query
The user refined the game concept to focus on three specific Indonesian regions for an international seminar exhibition:

1. **Indonesia Barat (West)** - Sunda/Jawa cuisine focus in "pasar" (market) environment
2. **Indonesia Tengah (Central)** - Mount Tambora eruption historical experience
3. **Indonesia Timur (East)** - Papua ethnic exploration with artifact collection

## Game Design Overview

### Exhibition Purpose
- **Target:** International seminar participants
- **Format:** Interactive cultural exhibition
- **Duration:** Short, focused experiences (5-15 minutes per region)
- **Access:** Main menu allowing choice of region to explore

## Three Regional Experiences

### 1. Indonesia Barat (West Indonesia)
**Theme:** "Seru dan Unik ala Kota Nusantara" - Traditional Market Cuisine

#### Environment: Pasar (Traditional Market)
- **Location:** Traditional market facade and interior
- **Focus:** Indonesian cuisine and street food culture
- **Reference Book:** "Seru dan Unik ala Kota Nusantara (Jakarta, Serang, Bandung, Bogor, Garut dan Cirebon)"

#### Interactive Elements
- **Food Stalls:** Soto, lotek, baso, sate vendors
- **Cooking Demonstrations:** Traditional food preparation
- **Cultural Learning:** History of Indonesian street food
- **Audio:** Market sounds, vendor calls, traditional music

#### Gameplay Features
- Walk through market environment
- Interact with food vendors
- Learn about different regional cuisines
- Experience authentic market atmosphere

### 2. Indonesia Tengah (Central Indonesia)
**Theme:** "Tambora Mengguncang Dunia" - Mount Tambora Historical Experience

#### Environment: Mount Tambora
- **Location:** Mountain trail from base to summit
- **Focus:** Historical eruption of 1815 and its global impact
- **Reference:** Historical accounts of the eruption

#### Interactive Elements
- **Mountain Trail:** Progressive ascent through different elevations
- **Historical Markers:** Information about the 1815 eruption
- **Environmental Changes:** Visual representation of pre/post eruption
- **Educational Content:** Global climate impact, historical significance

#### Gameplay Features
- Climb from base to peak of Mount Tambora
- Learn about the 1815 eruption's global impact
- Experience different mountain environments
- Historical timeline integration

### 3. Indonesia Timur (East Indonesia)
**Theme:** "Ekspedisi Tanah Papua" - Papua Cultural Artifact Collection

#### Environment: Papua Highlands
- **Location:** Megalithic sites and traditional villages
- **Focus:** Papua ethnic culture and archaeological exploration
- **Reference Book:** "Ekspedisi Tanah Papua Laporan Jurnalistik Kompas"

#### Interactive Elements
- **Megalithic Sites:** Bukit Megalitik Tutari
- **Artifact Collection:** Batu dootomo, kapak perunggu, other artifacts
- **Traditional Villages:** Papua ethnic settlements
- **Cultural Learning:** Papua traditions and customs

#### Gameplay Features
- Explore megalithic sites
- Collect cultural artifacts
- Learn about Papua ethnic groups
- Experience traditional village life

## Technical Implementation Plan

### Main Menu System
```gdscript
# MainMenuController.gd
extends Control

@export var indonesia_barat_scene: PackedScene
@export var indonesia_tengah_scene: PackedScene
@export var indonesia_timur_scene: PackedScene

func _on_indonesia_barat_pressed():
    get_tree().change_scene_to_packed(indonesia_barat_scene)

func _on_indonesia_tengah_pressed():
    get_tree().change_scene_to_packed(indonesia_tengah_scene)

func _on_indonesia_timur_pressed():
    get_tree().change_scene_to_packed(indonesia_timur_scene)
```

### Scene Structure
```
Scenes/
├── MainMenu/
│   ├── MainMenu.tscn
│   └── MainMenuController.gd
├── IndonesiaBarat/
│   ├── PasarScene.tscn
│   ├── FoodStall.gd
│   └── MarketController.gd
├── IndonesiaTengah/
│   ├── TamboraScene.tscn
│   ├── MountainTrail.gd
│   └── HistoricalMarker.gd
└── IndonesiaTimur/
    ├── PapuaScene.tscn
    ├── ArtifactCollector.gd
    └── MegalithicSite.gd
```

### Exhibition Features

#### 1. Quick Access System
- **Main Menu:** Clear region selection
- **Short Sessions:** 5-15 minutes per experience
- **Easy Navigation:** Simple controls for exhibition use

#### 2. Educational Content
- **Cultural Information:** Rich content about each region
- **Historical Context:** Educational value for international audience
- **Interactive Learning:** Hands-on cultural exploration

#### 3. Visual Appeal
- **PS2-Style Graphics:** Retro aesthetic for broad appeal
- **Cultural Authenticity:** Accurate representation of Indonesian regions
- **Professional Presentation:** Suitable for international exhibition

## Development Priority

### Phase 1: Main Menu System
1. Create main menu interface
2. Implement scene switching
3. Add region selection UI
4. Test navigation flow

### Phase 2: Indonesia Barat (Pasar)
1. Design market environment
2. Create food stall interactions
3. Add culinary content
4. Implement market atmosphere

### Phase 3: Indonesia Tengah (Tambora)
1. Design mountain environment
2. Create trail progression system
3. Add historical content
4. Implement elevation changes

### Phase 4: Indonesia Timur (Papua)
1. Design megalithic sites
2. Create artifact collection system
3. Add cultural content
4. Implement exploration mechanics

## Exhibition Considerations

### Technical Requirements
- **Hardware:** Standard PC setup for exhibition
- **Controls:** Simple keyboard/mouse or gamepad
- **Duration:** Short, focused experiences
- **Accessibility:** Easy to understand for international audience

### Content Localization
- **Language:** English for international audience
- **Cultural Context:** Clear explanations of Indonesian culture
- **Historical Accuracy:** Proper representation of events and traditions

### User Experience
- **Intuitive Controls:** Easy to pick up and play
- **Clear Objectives:** Obvious goals for each region
- **Engaging Content:** Interesting for academic audience
- **Professional Presentation:** Suitable for seminar exhibition

## Next Implementation Steps

### Immediate Actions
1. **Create Main Menu Scene**
   - Design UI for region selection
   - Implement scene switching
   - Add exhibition branding

2. **Plan Asset Organization**
   - Organize PS2-style assets by region
   - Plan cultural content integration
   - Design environment layouts

3. **Research Content Integration**
   - Extract key information from reference books
   - Plan interactive elements
   - Design educational content flow

### Technical Development
1. **Enhance Player Controller**
   - Add exhibition-specific features
   - Implement region-specific mechanics
   - Create cultural interaction systems

2. **Design UI Systems**
   - Cultural information display
   - Progress tracking
   - Educational content presentation

## Conclusion
This refined design creates a focused, exhibition-ready experience showcasing three distinct Indonesian regions. The main menu system allows seminar participants to choose their cultural exploration path, while each region offers unique educational content and interactive experiences.

The combination of culinary culture (West), historical significance (Central), and archaeological exploration (East) provides a comprehensive view of Indonesia's cultural diversity, perfect for an international academic audience.

---
*Documentation created on December 19, 2024*
