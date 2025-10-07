# Asset Integration Guide - PSX/PS2 Style
**Date:** 2025-08-26  
**Project:** Indonesian Cultural Heritage Exhibition - Walking Simulator  
**Author:** AI Assistant  
**Status:** Complete Implementation Guide

## Overview

This guide provides step-by-step instructions for integrating PSX/PS2 style assets into your walking simulator, specifically for expanding the Tambora (mountain) and Papua (forest) scenes. The guide ensures seamless integration with the existing radar system and maintains consistent asset management.

## 🎨 PSX/PS2 Style Guidelines

### **Visual Style Characteristics:**
- **Low-poly models** (500-2000 triangles per object)
- **256x256 textures** (maximum resolution)
- **Limited color palette** (16-64 colors per texture)
- **Sharp edges** (no smooth shading)
- **Pixelated textures** (no anti-aliasing)
- **Simple lighting** (flat or basic directional lighting)
- **Dithering effects** (for color transitions)

### **Performance Targets:**
- **Models:** 500-2000 triangles each
- **Textures:** 256x256 pixels maximum
- **Scene complexity:** 50-100 objects per scene
- **Draw calls:** Under 100 per scene
- **Memory usage:** Under 100MB total

## 📁 Asset Organization Structure

```
Assets/
├── Models/
│   ├── Tambora/
│   │   ├── Mountain/
│   │   │   ├── volcano_peak.fbx
│   │   │   ├── volcanic_rocks.fbx
│   │   │   ├── lava_flows.fbx
│   │   │   └── ash_deposits.fbx
│   │   ├── Vegetation/
│   │   │   ├── dead_trees.fbx
│   │   │   ├── sparse_grass.fbx
│   │   │   └── volcanic_plants.fbx
│   │   └── Structures/
│   │       ├── observation_post.fbx
│   │       ├── research_station.fbx
│   │       └── historical_marker.fbx
│   └── Papua/
│       ├── Forest/
│       │   ├── jungle_trees.fbx
│       │   ├── dense_vegetation.fbx
│       │   ├── vines.fbx
│       │   └── fallen_logs.fbx
│       ├── Buildings/
│       │   ├── traditional_hut.fbx
│       │   ├── longhouse.fbx
│       │   ├── spirit_house.fbx
│       │   └── storage_house.fbx
│       └── Cultural/
│           ├── totem_poles.fbx
│           ├── ceremonial_grounds.fbx
│           └── artifact_displays.fbx
├── Textures/
│   ├── Tambora/
│   │   ├── volcanic_rock_256.png
│   │   ├── ash_soil_256.png
│   │   ├── lava_flow_256.png
│   │   └── dead_vegetation_256.png
│   └── Papua/
│       ├── jungle_ground_256.png
│       ├── tree_bark_256.png
│       ├── leaf_texture_256.png
│       ├── bamboo_wall_256.png
│       └── thatch_roof_256.png
└── Materials/
    ├── Tambora/
    │   ├── VolcanicRock.tres
    │   ├── AshSoil.tres
    │   ├── LavaFlow.tres
    │   └── DeadVegetation.tres
    └── Papua/
        ├── JungleGround.tres
        ├── TreeBark.tres
        ├── LeafTexture.tres
        ├── BambooWall.tres
        └── ThatchRoof.tres
```

## 🔧 Step-by-Step Asset Integration Process

### **Step 1: Asset Preparation**

#### **1.1 Model Preparation (FBX Files)**
```bash
# Recommended FBX export settings
- Format: FBX 2013
- Units: Meters
- Scale: 1.0
- Smoothing: None (for PSX style)
- Triangulate: Yes
- Generate Normals: Yes
- Generate Tangents: No
- Embed Textures: No
```

#### **1.2 Texture Preparation (PNG Files)**
```bash
# Texture specifications
- Resolution: 256x256 pixels maximum
- Format: PNG with transparency
- Color depth: 8-bit (256 colors)
- Compression: None (for pixel art clarity)
- Filtering: Nearest neighbor (no anti-aliasing)
```

### **Step 2: Godot Import Settings**

#### **2.1 FBX Import Settings**
```gdscript
# In Godot Editor: File -> Import
# Select your .fbx file and configure:

[import]
- Import: true
- Generate Tangents: false
- Smoothing: false
- Optimize Mesh: true
- Force Reimport: true

[import_mesh]
- Generate LODs: false
- Create Shadow Meshes: true
- Lightmap UV: false
- Optimize Mesh: true
```

#### **2.2 PNG Import Settings**
```gdscript
# In Godot Editor: File -> Import
# Select your .png file and configure:

[import]
- Import: true
- Filter: Nearest (for pixel art)
- Mipmaps: Generate
- Repeat: Disabled
- Force Reimport: true

[compress]
- Mode: Lossless
- Quality: 1.0
```

### **Step 3: Material Creation**

#### **3.1 Create Material Resource**
```gdscript
# Right-click in FileSystem -> New Resource -> StandardMaterial3D
# Save as: Assets/Materials/Tambora/VolcanicRock.tres

# Material settings for PSX style:
- Albedo: Your texture
- Albedo Color: Tint color (optional)
- Roughness: 0.8 (matte finish)
- Metallic: 0.1 (non-metallic)
- Normal: Disabled (for flat look)
- AO: Disabled
- Emission: Disabled
```

#### **3.2 Material Configuration Example**
```gdscript
# Example: VolcanicRock.tres
[gd_resource type="StandardMaterial3D" load_steps=2 format=3]

[ext_resource type="Texture2D" path="res://Assets/Textures/Tambora/volcanic_rock_256.png" id="1_volcanic"]

[resource]
albedo_texture = ExtResource("1_volcanic")
albedo_color = Color(0.4, 0.3, 0.2, 1)
roughness = 0.8
metallic = 0.1
normal_enabled = false
ao_enabled = false
emission_enabled = false
```

### **Step 4: Scene Integration**

#### **4.1 Adding Models to Scenes**
```gdscript
# In your scene file (.tscn):
[node name="TamboraAssets" type="Node3D" parent="Environment"]

[node name="VolcanoPeak" type="Node3D" parent="Environment/TamboraAssets"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 10, -20)

[node name="MeshInstance3D" type="MeshInstance3D" parent="Environment/TamboraAssets/VolcanoPeak"]
mesh = ExtResource("volcano_peak_mesh")
surface_material_override/0 = ExtResource("VolcanicRock_material")
```

#### **4.2 Collision Setup**
```gdscript
# Add collision for interactable objects:
[node name="CollisionShape3D" type="CollisionShape3D" parent="Environment/TamboraAssets/VolcanoPeak"]
shape = ExtResource("volcano_collision_shape")

[node name="StaticBody3D" type="StaticBody3D" parent="Environment/TamboraAssets/VolcanoPeak"]
collision_layer = 1
```

### **Step 5: Radar Integration**

#### **5.1 POI Registration**
```gdscript
# In your scene script, register new POIs:
func setup_tambora_pois():
    poi_list = [
        {
            "name": "Volcano Peak",
            "position": Vector3(0, 0, -20),  # Match model position
            "icon": "volcano",
            "description": "Mount Tambora summit - 1815 eruption site"
        },
        {
            "name": "Research Station",
            "position": Vector3(-15, 0, -10),
            "icon": "research",
            "description": "Geological research facility"
        },
        {
            "name": "Historical Marker",
            "position": Vector3(10, 0, -15),
            "icon": "history",
            "description": "1815 eruption memorial site"
        }
    ]
```

#### **5.2 Path Updates**
```gdscript
# Update path points to include new locations:
func setup_tambora_paths():
    path_points = [
        Vector3(-50, 0, -50),  # Start point
        Vector3(-30, 0, -30),  # Path to volcano
        Vector3(0, 0, 0),      # Center area
        Vector3(0, 0, -20),    # Volcano peak
        Vector3(-15, 0, -10),  # Research station
        Vector3(10, 0, -15),   # Historical marker
        Vector3(30, 0, 30),    # Summit path
    ]
```

## 🗺️ Tambora Scene Expansion

### **Tambora Environment Elements:**

#### **Mountain Features:**
- **Volcano Peak:** Central mountain with crater
- **Lava Flows:** Dried lava channels
- **Volcanic Rocks:** Scattered boulders
- **Ash Deposits:** Gray soil areas
- **Fumaroles:** Steam vents (optional)

#### **Vegetation:**
- **Dead Trees:** Charred remains
- **Sparse Grass:** Limited vegetation
- **Volcanic Plants:** Hardy species
- **Moss:** On rocks and surfaces

#### **Structures:**
- **Observation Post:** Research facility
- **Historical Markers:** 1815 eruption sites
- **Path Markers:** Navigation aids
- **Safety Shelters:** Emergency stations

### **Tambora Asset List:**
```
Models Needed:
├── volcano_peak.fbx (main mountain)
├── volcanic_rocks.fbx (scattered boulders)
├── lava_flows.fbx (dried channels)
├── dead_trees.fbx (charred vegetation)
├── observation_post.fbx (research building)
└── historical_marker.fbx (memorial sites)

Textures Needed:
├── volcanic_rock_256.png (mountain surface)
├── ash_soil_256.png (ground texture)
├── lava_flow_256.png (lava channels)
├── dead_vegetation_256.png (plants)
├── building_wall_256.png (structures)
└── metal_roof_256.png (building roofs)
```

## 🌴 Papua Scene Expansion

### **Papua Environment Elements:**

#### **Forest Features:**
- **Jungle Trees:** Tall canopy trees
- **Dense Vegetation:** Undergrowth
- **Vines:** Hanging vegetation
- **Fallen Logs:** Natural obstacles
- **Clearings:** Open areas

#### **Buildings:**
- **Traditional Huts:** Round houses
- **Longhouses:** Community buildings
- **Spirit Houses:** Sacred structures
- **Storage Houses:** Food storage
- **Meeting Areas:** Community spaces

#### **Cultural Elements:**
- **Totem Poles:** Carved wooden poles
- **Ceremonial Grounds:** Ritual areas
- **Artifact Displays:** Cultural items
- **Cooking Areas:** Traditional kitchens
- **Gardens:** Food cultivation

### **Papua Asset List:**
```
Models Needed:
├── jungle_trees.fbx (tall trees)
├── dense_vegetation.fbx (undergrowth)
├── traditional_hut.fbx (round houses)
├── longhouse.fbx (community building)
├── totem_poles.fbx (carved poles)
└── ceremonial_grounds.fbx (ritual area)

Textures Needed:
├── jungle_ground_256.png (forest floor)
├── tree_bark_256.png (tree trunks)
├── leaf_texture_256.png (foliage)
├── bamboo_wall_256.png (building walls)
├── thatch_roof_256.png (roof material)
└── wood_carving_256.png (decorative)
```

## 🎯 Radar Integration Guidelines

### **POI Categories for Radar:**

#### **Tambora POIs:**
```gdscript
# Geological POIs
- "Volcano Peak" (main attraction)
- "Lava Flows" (geological feature)
- "Fumaroles" (steam vents)
- "Ash Deposits" (historical evidence)

# Research POIs
- "Observation Post" (research facility)
- "Research Station" (scientific building)
- "Weather Station" (monitoring)

# Historical POIs
- "1815 Memorial" (eruption site)
- "Historical Marker" (information point)
- "Eruption Timeline" (educational)
```

#### **Papua POIs:**
```gdscript
# Cultural POIs
- "Traditional Village" (main settlement)
- "Longhouse" (community center)
- "Spirit House" (sacred building)
- "Ceremonial Grounds" (ritual area)

# Natural POIs
- "Ancient Forest" (old growth trees)
- "Sacred Grove" (spiritual area)
- "Water Source" (river/spring)
- "Garden Area" (cultivation)

# Artifact POIs
- "Totem Poles" (cultural artifacts)
- "Craft Workshop" (traditional crafts)
- "Artifact Display" (museum area)
- "Storytelling Area" (oral tradition)
```

### **Radar Icon System:**
```gdscript
# Icon types for different POIs:
- "volcano" - Geological features
- "research" - Scientific facilities
- "history" - Historical sites
- "culture" - Cultural buildings
- "nature" - Natural features
- "artifact" - Collectible items
- "npc" - Interactive characters
- "path" - Navigation routes
```

## 🔧 Technical Implementation

### **Asset Loading Script:**
```gdscript
# Create: Assets/AssetLoader.gd
class_name AssetLoader
extends Node

# Asset management for PSX style
var loaded_models: Dictionary = {}
var loaded_materials: Dictionary = {}

func load_tambora_assets():
    # Load Tambora-specific assets
    var models = [
        "volcano_peak",
        "volcanic_rocks", 
        "lava_flows",
        "observation_post"
    ]
    
    for model_name in models:
        var model_path = "res://Assets/Models/Tambora/" + model_name + ".fbx"
        if ResourceLoader.exists(model_path):
            loaded_models[model_name] = load(model_path)
            GameLogger.info("Loaded Tambora model: " + model_name)

func load_papua_assets():
    # Load Papua-specific assets
    var models = [
        "jungle_trees",
        "traditional_hut",
        "longhouse",
        "totem_poles"
    ]
    
    for model_name in models:
        var model_path = "res://Assets/Models/Papua/" + model_name + ".fbx"
        if ResourceLoader.exists(model_path):
            loaded_models[model_name] = load(model_path)
            GameLogger.info("Loaded Papua model: " + model_name)
```

### **Scene Integration Script:**
```gdscript
# Create: Scenes/AssetIntegration.gd
class_name AssetIntegration
extends Node

@onready var asset_loader: AssetLoader

func integrate_tambora_assets():
    # Add volcano peak
    var volcano_peak = create_model_instance("volcano_peak")
    volcano_peak.position = Vector3(0, 10, -20)
    add_child(volcano_peak)
    
    # Add volcanic rocks
    for i in range(10):
        var rock = create_model_instance("volcanic_rocks")
        rock.position = Vector3(randf_range(-30, 30), 0, randf_range(-40, 0))
        rock.rotation.y = randf_range(0, PI * 2)
        add_child(rock)

func integrate_papua_assets():
    # Add jungle trees
    for i in range(20):
        var tree = create_model_instance("jungle_trees")
        tree.position = Vector3(randf_range(-40, 40), 0, randf_range(-40, 40))
        tree.rotation.y = randf_range(0, PI * 2)
        add_child(tree)
    
    # Add traditional huts
    var hut_positions = [
        Vector3(-15, 0, -15),
        Vector3(15, 0, -15),
        Vector3(0, 0, 15)
    ]
    
    for pos in hut_positions:
        var hut = create_model_instance("traditional_hut")
        hut.position = pos
        add_child(hut)

func create_model_instance(model_name: String) -> Node3D:
    if asset_loader.loaded_models.has(model_name):
        var model_scene = asset_loader.loaded_models[model_name]
        return model_scene.instantiate()
    else:
        GameLogger.warning("Model not found: " + model_name)
        return Node3D.new()
```

## 📊 Performance Optimization

### **LOD System (Level of Detail):**
```gdscript
# For distant objects, use simpler models
func setup_lod_system():
    var lod_distances = {
        "high": 50.0,    # Full detail
        "medium": 100.0, # Reduced detail
        "low": 200.0     # Minimal detail
    }
    
    for object in get_children():
        if object is Node3D:
            setup_lod_for_object(object, lod_distances)

func setup_lod_for_object(obj: Node3D, distances: Dictionary):
    # Create LOD variants
    var high_lod = obj.duplicate()
    var medium_lod = create_simplified_version(obj)
    var low_lod = create_minimal_version(obj)
    
    # Set up LOD switching based on distance
    obj.set_meta("lod_high", high_lod)
    obj.set_meta("lod_medium", medium_lod)
    obj.set_meta("lod_low", low_lod)
```

### **Texture Atlasing:**
```gdscript
# Combine multiple textures into one atlas
# Reduces draw calls and memory usage
func create_texture_atlas():
    var atlas_size = 1024
    var texture_atlas = ImageTexture.new()
    
    # Combine Tambora textures
    var tambora_textures = [
        "volcanic_rock_256.png",
        "ash_soil_256.png", 
        "lava_flow_256.png"
    ]
    
    # Combine Papua textures
    var papua_textures = [
        "jungle_ground_256.png",
        "tree_bark_256.png",
        "bamboo_wall_256.png"
    ]
```

## 🧪 Testing and Validation

### **Performance Testing:**
```gdscript
# Test script for performance validation
func test_performance():
    var start_time = Time.get_ticks_msec()
    
    # Load all assets
    asset_loader.load_tambora_assets()
    asset_loader.load_papua_assets()
    
    var load_time = Time.get_ticks_msec() - start_time
    GameLogger.info("Asset loading time: " + str(load_time) + "ms")
    
    # Check memory usage
    var memory_usage = OS.get_static_memory_usage()
    GameLogger.info("Memory usage: " + str(memory_usage / 1024 / 1024) + "MB")
```

### **Visual Testing:**
```gdscript
# Test script for visual validation
func test_visual_quality():
    # Check texture resolution
    for texture in loaded_textures:
        var size = texture.get_size()
        if size.x > 256 or size.y > 256:
            GameLogger.warning("Texture too large: " + texture.resource_path)
    
    # Check model complexity
    for model in loaded_models:
        var mesh = model.get_mesh()
        if mesh:
            var surface_count = mesh.get_surface_count()
            if surface_count > 1:
                GameLogger.warning("Model has multiple surfaces: " + model.resource_path)
```

## 📋 Implementation Checklist

### **Asset Preparation:**
- [ ] Convert models to FBX format
- [ ] Optimize models to 500-2000 triangles
- [ ] Resize textures to 256x256 pixels
- [ ] Apply PSX/PS2 style filtering
- [ ] Organize assets in proper folders

### **Godot Integration:**
- [ ] Import FBX files with correct settings
- [ ] Import PNG textures with nearest neighbor filtering
- [ ] Create material resources (.tres files)
- [ ] Apply materials to models
- [ ] Set up collision shapes

### **Scene Integration:**
- [ ] Add models to scene files
- [ ] Position models correctly
- [ ] Set up collision detection
- [ ] Add to appropriate groups (npc, artifact, etc.)
- [ ] Test model visibility and interaction

### **Radar Integration:**
- [ ] Update POI lists with new locations
- [ ] Add new path points
- [ ] Test radar icon display
- [ ] Verify tooltip information
- [ ] Check distance calculations

### **Performance Testing:**
- [ ] Test frame rate with new assets
- [ ] Check memory usage
- [ ] Validate draw call count
- [ ] Test LOD system (if implemented)
- [ ] Optimize if needed

## 🎯 Next Steps

1. **Prepare your assets** according to the specifications
2. **Import them into Godot** using the provided settings
3. **Create materials** for each texture
4. **Integrate into scenes** following the structure
5. **Update radar system** with new POIs
6. **Test performance** and optimize if needed
7. **Document any custom assets** for future reference

This guide ensures your PSX/PS2 style assets integrate seamlessly with the existing radar system while maintaining the authentic retro aesthetic and optimal performance for your walking simulator.

---

**Remember:** Keep the PSX/PS2 aesthetic consistent across all assets, and always test performance after adding new content to ensure smooth gameplay.
