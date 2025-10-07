# FBX Atlas Texture Usage Guide for Godot 4.3

**Date:** 2025-09-03  
**Version:** 1.0  
**Godot Version:** 4.3+  
**Author:** AI Assistant  
**Project:** Walking Simulator - PSX Forest Assets

## 📋 Table of Contents

1. [Overview](#overview)
2. [Understanding Atlas Textures](#understanding-atlas-textures)
3. [Asset Structure](#asset-structure)
4. [Creating Individual TSCN Files](#creating-individual-tscn-files)
5. [Material Setup](#material-setup)
6. [Random Placement System](#random-placement-system)
7. [Integration with Existing Systems](#integration-with-existing-systems)
8. [Troubleshooting](#troubleshooting)
9. [Examples](#examples)

## 🌟 Overview

This guide explains how to use FBX models with atlas textures in Godot 4.3, specifically for the PSX Forest assets. While GLB models are preferred for their embedded textures, FBX models with atlas textures offer:

- **Smaller file sizes** (shared textures)
- **Consistent visual style** across models
- **Easier texture management** (single atlas file)
- **Better performance** for large numbers of instances

## 🎨 Understanding Atlas Textures

### What is an Atlas Texture?
An atlas texture is a single image file containing multiple smaller textures arranged in a grid. Each model uses a specific region (UV coordinates) of this atlas.

### Your Forest Atlas Files:
- **`Forest_Pack_Atlas_1.tga`** - Main atlas with plant textures and alpha channels
- **`Forest_Pack_BaseColor.png`** - Base color texture for non-plant objects

### Atlas Layout (Typical):
```
┌─────────────────────────────────────┐
│  Plant1  │  Plant2  │  Plant3     │
│  (Alpha) │  (Alpha) │  (Alpha)    │
├─────────────────────────────────────┤
│  Plant4  │  Plant5  │  Plant6     │
│  (Alpha) │  (Alpha) │  (Alpha)    │
└─────────────────────────────────────┘
```

## 📁 Asset Structure

### Current FBX Models Location:
```
Assets/PSX/PSX Forest/Models/
├── trees/
│   ├── pine_tree_1.fbx
│   ├── pine_tree_2.fbx
│   └── pine_tree_3.fbx
├── vegetation/
│   ├── forest_grass_1.fbx
│   ├── forest_grass_2.fbx
│   ├── fern_1.fbx
│   ├── fern_2.fbx
│   └── fern_3.fbx
└── mushrooms/
    ├── white_mushrooms_1.fbx
    ├── white_mushrooms_2.fbx
    └── brown_mushrooms_1.fbx
```

### Target TSCN Structure:
```
Assets/Terrain/Shared/psx_models/
├── trees/
│   ├── pine_tree_1.tscn
│   ├── pine_tree_2.tscn
│   └── pine_tree_3.tscn
├── vegetation/
│   ├── forest_grass_1.tscn
│   ├── forest_grass_2.tscn
│   ├── fern_1.tscn
│   ├── fern_2.tscn
│   └── fern_3.tscn
└── mushrooms/
    ├── white_mushrooms_1.tscn
    ├── white_mushrooms_2.tscn
    └── brown_mushrooms_1.tscn
```

## 🎬 Creating Individual TSCN Files

### Step 1: Import FBX Model
1. **Drag FBX file** into Godot project
2. **Set import settings:**
   - **Import Tab:**
     - ✅ **Import Scene**
     - ✅ **Import Materials**
     - ✅ **Import Animations** (if any)
   - **Scene Tab:**
     - ✅ **Root Type:** Node3D
     - ✅ **Root Name:** [ModelName]
   - **Material Tab:**
     - ✅ **Import Materials**
     - ✅ **Material Override:** None

### Step 2: Create TSCN File
1. **Right-click** on imported FBX in FileSystem
2. **Select "New Scene"**
3. **Add imported model** as child
4. **Save as** `[model_name].tscn` in appropriate folder

### Step 3: Setup Material
1. **Select MeshInstance3D** in scene
2. **Create new material** or use existing
3. **Apply atlas texture** (see Material Setup section)
4. **Save material** as `.tres` file

### Example TSCN Structure:
```gdscript
[gd_scene load_steps=3 format=3]

[ext_resource type="PackedScene" uid="uid://..." path="res://Assets/PSX/PSX Forest/Models/trees/pine_tree_1.fbx" id="1_model"]
[ext_resource type="Material" uid="uid://..." path="res://Assets/Terrain/Shared/materials/forest_atlas_material.tres" id="2_material"]

[node name="PineTree1" type="Node3D"]

[node name="PineTree1Model" parent="." instance=ExtResource("1_model")]
material_override = ExtResource("2_material")
```

## 🎨 Material Setup

### Creating Atlas Material

#### 1. Base Material Properties:
```gdscript
# Create new StandardMaterial3D
var material = StandardMaterial3D.new()

# Basic settings
material.albedo_texture = atlas_texture
material.metallic = 0.0
material.roughness = 0.7
material.normal_enabled = false  # Unless you have normal maps
```

#### 2. Atlas Texture Setup:
```gdscript
# Load atlas texture
var atlas = preload("res://Assets/PSX/PSX Forest/Textures/Forest_Pack_Atlas_1.tga")

# Apply to material
material.albedo_texture = atlas
```

#### 3. Alpha Channel Setup (for plants):
```gdscript
# Enable alpha cutout for plants
material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
material.alpha_scissor_threshold = 0.3

# Disable backface culling for double-sided plants
material.cull_mode = BaseMaterial3D.CULL_DISABLED
```

#### 4. UV Mapping:
Each FBX model should have proper UV coordinates mapped to the atlas. The UV coordinates determine which part of the atlas each model uses.

### Material File Structure:
```gdscript
[gd_resource type="StandardMaterial3D" load_steps=2 format=3 uid="uid://..."]

[ext_resource type="Texture2D" uid="uid://..." path="res://Assets/PSX/PSX Forest/Textures/Forest_Pack_Atlas_1.tga" id="1_atlas"]

[resource]
albedo_texture = ExtResource("1_atlas")
transparency = 1
alpha_scissor_threshold = 0.3
cull_mode = 0
metallic = 0.0
roughness = 0.7
```

## 🎯 Random Placement System

### Creating FBX Asset Pack

#### 1. Update Asset Pack Resource:
```gdscript
# Assets/Terrain/Papua/psx_assets_fbx.tres
[gd_resource type="Resource" script_class="PSXAssetPack" load_steps=2 format=3 uid="uid://..."]

[ext_resource type="Script" path="res://Systems/Terrain/PSXAssetPack.gd" id="1_psx"]

[resource]
script = ExtResource("1_psx")
region_name = "Papua_FBX"
environment_type = "tropical_forest"
trees = [
    "res://Assets/Terrain/Shared/psx_models/trees/pine_tree_1.tscn",
    "res://Assets/Terrain/Shared/psx_models/trees/pine_tree_2.tscn",
    "res://Assets/Terrain/Shared/psx_models/trees/pine_tree_3.tscn"
]
vegetation = [
    "res://Assets/Terrain/Shared/psx_models/vegetation/forest_grass_1.tscn",
    "res://Assets/Terrain/Shared/psx_models/vegetation/forest_grass_2.tscn",
    "res://Assets/Terrain/Shared/psx_models/vegetation/fern_1.tscn",
    "res://Assets/Terrain/Shared/psx_models/vegetation/fern_2.tscn",
    "res://Assets/Terrain/Shared/psx_models/vegetation/fern_3.tscn"
]
mushrooms = [
    "res://Assets/Terrain/Shared/psx_models/mushrooms/white_mushrooms_1.tscn",
    "res://Assets/Terrain/Shared/psx_models/mushrooms/white_mushrooms_2.tscn",
    "res://Assets/Terrain/Shared/psx_models/mushrooms/brown_mushrooms_1.tscn"
]
stones = [
    "res://Assets/Terrain/Shared/psx_models/stones/rocks/stone_1.glb",
    "res://Assets/Terrain/Shared/psx_models/stones/rocks/stone_2.glb",
    "res://Assets/Terrain/Shared/psx_models/stones/rocks/stone_3.glb"
]
debris = []
```

#### 2. Random Placement Function:
```gdscript
func place_fbx_assets_random(center: Vector3, radius: float, asset_type: String):
    """Place FBX assets randomly in a circular area"""
    var asset_pack = asset_placer.get_meta("asset_pack")
    var assets = []
    
    # Get appropriate asset list
    match asset_type:
        "trees":
            assets = asset_pack.trees
        "vegetation":
            assets = asset_pack.vegetation
        "mushrooms":
            assets = asset_pack.mushrooms
        _:
            return
    
    if assets.size() == 0:
        GameLogger.warning("⚠️ No %s assets available" % asset_type)
        return
    
    # Place assets randomly
    for i in range(20):  # Adjust count as needed
        var angle = randf() * TAU
        var distance = randf() * radius
        var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
        pos.y = center.y + randf_range(-1, 2)
        
        # Randomly select asset
        var asset_path = assets[randi() % assets.size()]
        
        # Instantiate TSCN
        var asset_scene = load(asset_path)
        if asset_scene:
            var instance = asset_scene.instantiate()
            instance.position = pos
            instance.rotation.y = randf() * TAU
            instance.scale = Vector3.ONE * randf_range(0.8, 1.2)
            instance.name = "%s_%s_%d" % [asset_type, asset_path.get_file().replace(".tscn", ""), i]
            
            asset_placer.add_child(instance)
    
    GameLogger.info("✅ Placed %d %s assets" % [20, asset_type])
```

#### 3. Integration with Existing System:
```gdscript
func _on_test_fbx_placement():
    """Test FBX asset placement with atlas textures"""
    GameLogger.info("🌿 BUTTON CLICKED: Test FBX Asset Placement")
    
    # Place different types of FBX assets
    place_fbx_assets_random(Vector3(100, 5, 100), 60, "trees")
    place_fbx_assets_random(Vector3(-100, 8, 50), 40, "vegetation")
    place_fbx_assets_random(Vector3(50, 5, -100), 30, "mushrooms")
    
    update_results("✅ Placed FBX forest assets with atlas textures")
```

## 🔗 Integration with Existing Systems

### 1. Asset Pack Selection:
```gdscript
func setup_asset_pack(use_fbx: bool = false):
    """Setup asset pack based on preference"""
    var asset_pack_path = ""
    
    if use_fbx:
        asset_pack_path = "res://Assets/Terrain/Papua/psx_assets_fbx.tres"
        GameLogger.info("🌿 Using FBX assets with atlas textures")
    else:
        asset_pack_path = "res://Assets/Terrain/Papua/psx_assets.tres"
        GameLogger.info("🎋 Using GLB assets with embedded textures")
    
    var asset_pack = load(asset_pack_path)
    if asset_pack:
        asset_placer.set_meta("asset_pack", asset_pack)
        GameLogger.info("✅ Loaded asset pack: " + asset_pack.region_name)
```

### 2. Asset Filtering:
```gdscript
func _filter_assets_by_type(asset_list: Array, asset_type: String) -> Array:
    """Filter assets by type (TSCN for FBX, GLB for embedded)"""
    var filtered = []
    
    for asset_path in asset_list:
        if asset_type == "fbx" and asset_path.ends_with(".tscn"):
            filtered.append(asset_path)
        elif asset_type == "glb" and asset_path.ends_with(".glb"):
            filtered.append(asset_path)
    
    return filtered
```

### 3. Hybrid System:
```gdscript
func place_hybrid_assets(center: Vector3, radius: float):
    """Place both FBX and GLB assets for variety"""
    
    # Place FBX trees with atlas
    place_fbx_assets_random(center, radius * 0.7, "trees")
    
    # Place GLB stones and mushrooms
    place_glb_assets_random(center, radius * 0.3, "stones")
    place_glb_assets_random(center, radius * 0.2, "mushrooms")
```

## 🛠️ Troubleshooting

### Common Issues and Solutions:

#### 1. Atlas Texture Not Showing:
- **Problem:** Atlas texture appears black or incorrect
- **Solution:** Check UV coordinates in FBX model
- **Fix:** Ensure UV mapping covers correct atlas region

#### 2. Alpha Channel Issues:
- **Problem:** Plant edges appear jagged or transparent
- **Solution:** Adjust alpha scissor threshold
- **Fix:** Set `alpha_scissor_threshold` between 0.1 and 0.5

#### 3. Performance Issues:
- **Problem:** Many FBX instances cause lag
- **Solution:** Use LOD (Level of Detail) system
- **Fix:** Implement distance-based culling

#### 4. Material Override Not Working:
- **Problem:** Material changes don't apply
- **Solution:** Check material override settings
- **Fix:** Ensure material is applied to MeshInstance3D

### Debug Functions:
```gdscript
func debug_atlas_usage():
    """Debug atlas texture usage"""
    var asset_pack = asset_placer.get_meta("asset_pack")
    
    GameLogger.info("🔍 Atlas Texture Debug Info:")
    GameLogger.info("   Atlas File: Forest_Pack_Atlas_1.tga")
    GameLogger.info("   Base Color: Forest_Pack_BaseColor.png")
    
    for category in ["trees", "vegetation", "mushrooms"]:
        var assets = asset_pack.get(category)
        GameLogger.info("   %s: %d assets" % [category, assets.size()])
        
        for asset in assets:
            var scene = load(asset)
            if scene:
                var instance = scene.instantiate()
                var mesh_instances = _find_mesh_instances(instance)
                GameLogger.info("     %s: %d mesh instances" % [asset.get_file(), mesh_instances.size()])
                instance.queue_free()
```

## 📚 Examples

### Complete FBX Placement Example:
```gdscript
extends Node3D

var asset_placer: Node3D
var fbx_asset_pack: Resource

func _ready():
    setup_fbx_system()

func setup_fbx_system():
    """Setup FBX asset system with atlas textures"""
    
    # Load FBX asset pack
    fbx_asset_pack = load("res://Assets/Terrain/Papua/psx_assets_fbx.tres")
    
    # Create asset placer
    asset_placer = Node3D.new()
    asset_placer.name = "FBXAssetPlacer"
    add_child(asset_placer)
    
    # Store asset pack reference
    asset_placer.set_meta("asset_pack", fbx_asset_pack)
    
    GameLogger.info("✅ FBX asset system ready")

func create_forest_scene():
    """Create a complete forest scene with FBX assets"""
    
    # Create forest zones
    create_forest_zone(Vector3(0, 5, 0), 80, "dense")
    create_forest_zone(Vector3(200, 2, 0), 60, "riverine")
    create_forest_zone(Vector3(-200, 10, 0), 50, "clearing")
    
    GameLogger.info("✅ Forest scene created with FBX assets")

func create_forest_zone(center: Vector3, radius: float, zone_type: String):
    """Create a specific type of forest zone"""
    
    match zone_type:
        "dense":
            place_fbx_assets_random(center, radius, "trees", 40)
            place_fbx_assets_random(center, radius, "vegetation", 60)
        "riverine":
            place_fbx_assets_random(center, radius, "vegetation", 50)
            place_fbx_assets_random(center, radius, "mushrooms", 20)
        "clearing":
            place_fbx_assets_random(center, radius, "vegetation", 30)
            place_fbx_assets_random(center, radius, "mushrooms", 15)
```

## 📝 Summary

### Key Points:
1. **FBX + Atlas = Efficient**: Smaller files, shared textures
2. **TSCN Creation**: Each FBX needs individual TSCN file
3. **Material Setup**: Proper alpha channel and UV mapping
4. **Random Placement**: Same system as GLB, just different asset paths
5. **Hybrid Approach**: Use both FBX and GLB for variety

### Next Steps:
1. **Create TSCN files** for all FBX models
2. **Setup atlas materials** with proper alpha settings
3. **Update asset packs** to include FBX TSCN paths
4. **Implement placement functions** for FBX assets
5. **Test performance** and optimize as needed

### Benefits of This Approach:
- ✅ **Smaller file sizes** than GLB
- ✅ **Consistent visual style** across models
- ✅ **Easy texture management** (single atlas)
- ✅ **Better performance** for large numbers
- ✅ **Flexible placement** system
- ✅ **Integration** with existing GLB system

This system allows you to use both FBX (atlas) and GLB (embedded) assets seamlessly, giving you the best of both worlds for your PSX-style forest game.
