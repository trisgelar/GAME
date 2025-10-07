# Map Design Expansion & NPC Interaction System

**Date**: 2025-08-27  
**Version**: 1.0  
**Status**: In Progress  

## Overview

This document outlines the map expansion design and NPC interaction system improvements for the Indonesian Cultural Heritage Exhibition game. The current small maps (60x60 units) are causing NPC interaction conflicts and limiting gameplay potential.

## Current Problems Identified

### 1. Map Size Issues
- **Papua Scene**: 60x60 units (too small for 4 NPCs)
- **Tambora Scene**: 60x60 units (too small for 3 NPCs)  
- **Pasar Scene**: 50x50 units (too small for 4 NPCs)

### 2. NPC Layout Problems
- **NPCs too close together**: All NPCs within 8-14m of each other
- **Player spawn too close**: Even at 12m, player is near multiple NPCs
- **No room for movement**: NPCs can't move without overlapping
- **Interaction conflicts**: Multiple NPCs detected simultaneously

### 3. Interaction System Issues
- **Continuous prompts**: `[E] Talk to [NPC]` appears from game start
- **No dynamic switching**: Prompt doesn't change when moving between NPCs
- **Small interaction range**: 3m is too restrictive for larger maps

## Proposed Solution: Map Expansion Design

### 1. Papua Scene (Forest/Jungle Environment)

**Map Size**: 200x200 units (3.3x larger than current)

**NPC Layout**:
```
CulturalGuide: (0, 1, 0)     - Central village area
Archaeologist: (50, 1, 30)   - Ancient ruins site
TribalElder: (-40, 1, 20)    - Traditional village  
Artisan: (30, 1, -50)        - Crafting workshop
```

**Player Spawn**: `(0, 0.9, 80)` - 80m from center, far from all NPCs

**Features**:
- Dense jungle areas
- Ancient ruins
- Traditional villages
- Crafting workshops
- Sacred sites
- Water features (rivers, ponds)

### 2. Tambora Scene (Mountain Environment)

**Map Size**: 300x300 units (5x larger than current)

**NPC Layout**:
```
Historian: (0, 1, 0)         - Base camp
Geologist: (80, 1, 60)       - Research station
LocalGuide: (-60, 1, 40)     - Village guide
```

**Player Spawn**: `(0, 0.9, 120)` - Base camp area

**Features**:
- Mountain slopes
- Research stations
- Base camps
- Historical markers
- Geological formations
- Hiking trails

### 3. Pasar Scene (Market Environment)

**Map Size**: 150x150 units (3x larger than current)

**NPC Layout**:
```
MarketGuide: (0, 1, 0)       - Market center
FoodVendor: (30, 1, 20)      - Food section
CraftVendor: (-25, 1, 15)    - Craft section
Historian: (20, 1, -30)      - Cultural center
```

**Player Spawn**: `(0, 0.9, 60)` - Market entrance

**Features**:
- Market stalls
- Food courts
- Craft areas
- Cultural centers
- Plaza areas

## Interaction System Improvements

### 1. Interaction Ranges
- **Base Interaction Range**: 5-8 meters (increased from 3m)
- **Visual Detection Range**: 15-20 meters (for NPC awareness)
- **Movement Range**: 20-50 meters (for NPC patrolling)

### 2. Player Experience
- **No Prompt at Start**: Player spawns 60-120m from nearest NPC
- **Clear Approach**: Player must actively move towards NPCs
- **Natural Discovery**: NPCs are found through exploration
- **No Overlap**: Each NPC has their own distinct area

### 3. NPC Behavior Design
- **Idle States**: NPCs have natural idle behaviors
- **Patrol Routes**: NPCs move within their designated areas
- **Interaction Zones**: Clear areas where interaction is possible
- **Visual Indicators**: Subtle cues when NPCs are approachable

## Implementation Strategy

### Phase 1: Map Expansion (Current)
- [x] Increase map sizes in all three scenes
- [x] Reposition NPCs with proper spacing
- [x] Move player spawn points far from NPCs
- [x] Increase interaction ranges
- [ ] Test basic interaction with new distances

### Phase 2: Terrain Implementation (Future)
- [ ] Add terrain systems for Papua and Tambora
- [ ] Create elevation changes and natural barriers
- [ ] Add environmental features (trees, rocks, water)
- [ ] Implement pathfinding for NPCs

### Phase 3: NPC Movement (Future)
- [ ] Add NPC patrol systems
- [ ] Implement idle behaviors
- [ ] Create interaction zones
- [ ] Add visual indicators for NPC awareness

## Technical Specifications

### Map Dimensions
| Scene | Current Size | New Size | Expansion Factor |
|-------|-------------|----------|------------------|
| Papua | 60x60 | 200x200 | 3.3x |
| Tambora | 60x60 | 300x300 | 5x |
| Pasar | 50x50 | 150x150 | 3x |

### NPC Spacing
| Scene | NPC Count | Min Distance | Max Distance |
|-------|-----------|--------------|--------------|
| Papua | 4 | 40m | 50m |
| Tambora | 3 | 60m | 80m |
| Pasar | 4 | 25m | 35m |

### Interaction Parameters
| Parameter | Current | New |
|-----------|---------|-----|
| Interaction Range | 3m | 5m |
| Player Spawn Distance | 12m | 60-120m |
| NPC Movement Range | N/A | 20-50m |
| Visual Detection | N/A | 15-20m |

## Benefits of New Design

### 1. Improved Gameplay
- **Exploration**: Players must actively explore to find NPCs
- **Discovery**: Natural progression through the environment
- **Immersion**: Larger, more realistic environments
- **Engagement**: Clear goals and objectives

### 2. Technical Improvements
- **No Interaction Conflicts**: NPCs are properly spaced
- **Better Performance**: Reduced collision detection overhead
- **Scalability**: Easy to add more features and NPCs
- **Maintainability**: Cleaner, more organized code

### 3. User Experience
- **No Confusion**: Clear interaction prompts
- **Intuitive Navigation**: Natural movement patterns
- **Visual Clarity**: Distinct areas for each NPC
- **Smooth Transitions**: Proper state management

## Future Enhancements

### 1. Environmental Features
- **Terrain Systems**: Height maps, slopes, elevation
- **Vegetation**: Trees, bushes, grass for Papua
- **Rock Formations**: Geological features for Tambora
- **Water Features**: Rivers, ponds, waterfalls

### 2. NPC Behaviors
- **Daily Routines**: NPCs follow realistic schedules
- **Weather Responses**: NPCs react to environmental changes
- **Player Awareness**: NPCs notice and react to player presence
- **Cultural Activities**: NPCs perform region-specific activities

### 3. Interactive Elements
- **Cultural Artifacts**: Scattered throughout the environment
- **Information Points**: Historical markers and educational content
- **Mini-Games**: Cultural activities and challenges
- **Achievement System**: Rewards for exploration and learning

## Testing Plan

### 1. Interaction Testing
- [ ] Verify no prompts appear at game start
- [ ] Test NPC detection when approaching each NPC
- [ ] Confirm prompt text changes correctly
- [ ] Verify prompts disappear when leaving NPC range

### 2. Navigation Testing
- [ ] Test player movement across expanded maps
- [ ] Verify NPC spacing prevents overlap
- [ ] Test interaction ranges are appropriate
- [ ] Confirm player spawn positions are optimal

### 3. Performance Testing
- [ ] Monitor frame rates with larger maps
- [ ] Test collision detection performance
- [ ] Verify memory usage with expanded environments
- [ ] Test loading times for larger scenes

## Conclusion

The map expansion design addresses the core issues with the current NPC interaction system while providing a foundation for future enhancements. The larger maps will create more immersive environments that better represent the cultural richness of Indonesia's different regions.

The implementation prioritizes immediate fixes for interaction conflicts while establishing a scalable architecture for future features like terrain systems, NPC movement, and environmental storytelling.

---

**Next Steps**:
1. Complete Phase 1 implementation
2. Test interaction system with new layouts
3. Begin Phase 2 terrain implementation
4. Plan Phase 3 NPC movement systems
