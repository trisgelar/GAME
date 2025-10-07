# Papua Camera Views Plan

**Date:** 2025-09-18  
**Status:** Planning Phase  
**Scope:** Camera view system for PapuaScene_Terrain3D.tscn  

## 🎯 **Objective**

Create multiple camera views to better showcase and navigate the hexagonal path system in the Papua Terrain3D scene, providing different perspectives for exploration and development.

## 📷 **Planned Camera Views**

### **1. 🚶 Player View (Default)**
- **Position**: Behind and above player (current default)
- **Purpose**: Normal gameplay and exploration
- **Distance**: 6-8 units from player
- **Height**: 2-3 units above player
- **Angle**: Slightly downward (~15°)
- **Benefits**: 
  - Natural movement and exploration
  - Good for terrain interaction
  - Familiar third-person perspective

### **2. 🔭 Far Side View**
- **Position**: High and far from the scene center
- **Purpose**: Overview of entire terrain and path system
- **Distance**: 50-80 units from scene center
- **Height**: 30-50 units above terrain
- **Angle**: Downward (~45°)
- **Benefits**:
  - See complete hexagonal path layout
  - Understand terrain topology
  - Perfect for planning and overview

### **3. 🌳 Canopy View**
- **Position**: Above tree level, following player
- **Purpose**: Mid-level view showing forest and paths
- **Distance**: 10-15 units from player
- **Height**: 15-25 units above terrain (tree canopy level)
- **Angle**: Moderate downward (~30°)
- **Benefits**:
  - See forest canopy and clearings
  - Track path visibility through trees
  - Good balance of detail and overview

### **4. 🗺️ Top-Down Strategic View**
- **Position**: Directly above scene center
- **Purpose**: Strategic overview like a map
- **Distance**: Directly overhead
- **Height**: 60-100 units above terrain
- **Angle**: Straight down (90°)
- **Benefits**:
  - Perfect hexagonal path visualization
  - Clear artifact placement view
  - Ideal for system development and debugging

### **5. 🎮 Debug Free Camera**
- **Position**: Player-controlled free movement
- **Purpose**: Development and debugging
- **Controls**: WASD for movement, mouse for rotation
- **Speed**: Variable (slow/fast modes)
- **Benefits**:
  - Inspect any angle or position
  - Debug terrain and asset placement
  - Flexible development tool

### **6. 🌅 Cinematic View**
- **Position**: Dynamic movement around scene
- **Purpose**: Showcase and presentation
- **Movement**: Smooth orbital or scripted path
- **Speed**: Slow, smooth transitions
- **Benefits**:
  - Beautiful scene presentation
  - Show off terrain and assets
  - Demo mode for showcasing work

## 🎮 **Control Scheme Plan**

### **View Switching (Number Keys):**
- **Key 1**: Player View (default)
- **Key 2**: Far Side View
- **Key 3**: Canopy View  
- **Key 4**: Top-Down Strategic View
- **Key 0**: Debug Free Camera
- **Key 9**: Cinematic View (auto-orbit)

### **Camera Controls:**
- **Mouse**: Look around (all views except top-down)
- **Scroll Wheel**: Zoom in/out
- **SHIFT + Scroll**: Adjust height
- **CTRL + WASD**: Fine position adjustment (debug mode)

## 🏗️ **Technical Implementation Plan**

### **Camera System Architecture:**
```gdscript
# Systems/Camera/CameraModeManager.gd
class_name CameraModeManager
extends Node3D

enum CameraMode {
    PLAYER_VIEW,
    FAR_SIDE_VIEW,
    CANOPY_VIEW,
    TOP_DOWN_VIEW,
    DEBUG_FREE_CAMERA,
    CINEMATIC_VIEW
}

var current_mode: CameraMode = CameraMode.PLAYER_VIEW
var camera: Camera3D
var player: Node3D
var scene_center: Vector3
```

### **View Configuration:**
```gdscript
# Camera view configurations
var view_configs = {
    CameraMode.PLAYER_VIEW: {
        "distance": 7.0,
        "height": 2.5,
        "angle": 15.0,
        "follow_player": true,
        "smooth_factor": 5.0
    },
    CameraMode.FAR_SIDE_VIEW: {
        "distance": 60.0,
        "height": 40.0,
        "angle": 45.0,
        "follow_player": false,
        "smooth_factor": 2.0
    },
    CameraMode.CANOPY_VIEW: {
        "distance": 12.0,
        "height": 20.0,
        "angle": 30.0,
        "follow_player": true,
        "smooth_factor": 3.0
    },
    # ... etc
}
```

## 🌍 **Scene Integration**

### **Papua Terrain3D Specific Considerations:**

#### **Scene Center Calculation:**
- Calculate center based on terrain bounds
- Consider hexagonal path system center
- Account for major landmarks and assets

#### **Terrain Height Adaptation:**
- All views should adapt to terrain height
- Use `get_terrain_height_at_position()` for ground reference
- Maintain relative heights above terrain

#### **Forest Canopy Consideration:**
- Canopy view should be above tree height
- Account for PSX asset heights
- Ensure paths are visible through forest

### **Integration with Existing Systems:**
```gdscript
# Integration with Terrain3D system
func _ready():
    # Get terrain controller reference
    terrain_controller = get_node("../TerrainController")
    
    # Calculate scene bounds from terrain
    calculate_scene_bounds()
    
    # Setup initial camera position
    set_camera_mode(CameraMode.PLAYER_VIEW)
```

## 🔧 **Development Phases**

### **Phase 1: Basic View System**
1. Create `CameraModeManager.gd`
2. Implement basic view switching
3. Add Player, Far Side, and Top-Down views
4. Test with existing hexagonal path system

### **Phase 2: Enhanced Views**
1. Add Canopy and Cinematic views
2. Implement smooth transitions between views
3. Add zoom and height controls
4. Integrate with terrain height system

### **Phase 3: Debug and Polish**
1. Add Debug Free Camera
2. Fine-tune all view positions and angles
3. Add UI indicators for current view
4. Optimize performance

### **Phase 4: Integration**
1. Integrate with existing input system
2. Add view switching to UI
3. Document usage and controls
4. Test with improved hexagonal paths

## 🎨 **Visual Design Considerations**

### **UI Indicators:**
- Small camera icon showing current view mode
- Smooth view transition animations
- On-screen controls hint overlay

### **Camera Transitions:**
- Smooth interpolation between views (1-2 seconds)
- Easing curves for natural movement
- Maintain orientation when switching

### **Performance:**
- LOD system for distant views
- Culling for far side view
- Efficient update rates for each view mode

## 📋 **Success Criteria**

### **Functional Requirements:**
- ✅ Smooth switching between all 6 view modes
- ✅ Proper terrain height adaptation
- ✅ Intuitive controls for each view
- ✅ No performance impact on gameplay

### **Quality Requirements:**
- ✅ Beautiful presentation of hexagonal paths
- ✅ Clear visibility of all terrain features
- ✅ Smooth, professional camera movements
- ✅ Useful for both gameplay and development

## 🔄 **Integration with Hexagonal Path System**

### **Path Visibility Optimization:**
- Far Side View: Show complete hexagonal pattern
- Canopy View: Show paths through forest clearings
- Top-Down View: Perfect geometric visualization
- Player View: Ground-level path following

### **Development Benefits:**
- Easy debugging of path placement
- Visual verification of artifact positioning
- Clear view of collision areas
- Better understanding of terrain integration

---

**This plan provides a comprehensive camera system that will greatly enhance both the development and presentation of your hexagonal path system in the Papua Terrain3D scene.**

Do you agree with this camera view plan? Should I proceed with implementing the CameraModeManager system?
