# Manual Asset Placement and Programmatic Terrain Generation Guide

*Date: 2025-01-03*  
*Author: Assistant*  
*Version: 1.0*

## Overview

This document provides comprehensive guidance for manually placing nature assets using .tscn scene files and programmatically generating terrain for different regions (Tambora volcano, Papua forests). The guide covers both immediate manual placement techniques and foundational knowledge for future procedural placement systems.

## Table of Contents

1. [Manual Asset Placement](#manual-asset-placement)
2. [Creating Asset Scene Files (.tscn)](#creating-asset-scene-files-tscn)
3. [Programmatic Terrain Generation](#programmatic-terrain-generation)
4. [Integration Examples](#integration-examples)
5. [Best Practices](#best-practices)

## Manual Asset Placement

### Understanding the Asset Structure

The project uses a well-organized asset hierarchy:

```
Assets/
├── PSX/
│   ├── PSX Nature/
│   │   └── Models/GLB/          # GLB format nature assets
│   └── PSX Textures/            # Texture resources
├── Terrain/
│   ├── Shared/psx_models/       # Organized by category
│   │   ├── trees/
│   │   ├── vegetation/
│   │   ├── stones/
│   │   ├── mushrooms/
│   │   └── debris/
│   ├── Tambora/                 # Region-specific assets
│   └── Papua/                   # Region-specific assets
```

### Creating Asset Scene Files (.tscn)

#### Step 1: Create a New Scene

1. **Open Godot Editor**
2. **Scene Menu** → **New Scene**
3. **Add 3D Node** → Choose `Node3D` as root
4. **Rename** the root node to describe your asset (e.g., `PineTree_Variant1`)

#### Step 2: Add the 3D Model

1. **Add Child** → `MeshInstance3D`
2. **Inspector** → **Mesh** property → **Load** 
3. **Navigate** to your GLB file (e.g., `Assets/PSX/PSX Nature/Models/GLB/pine_tree_n_1.glb`)
4. **Select** the mesh resource from the imported GLB

#### Step 3: Add Collision (Optional)

For assets that need physics interaction:

1. **Right-click** MeshInstance3D → **Create Trimesh Collision Sibling**
2. **Or** add `StaticBody3D` → `CollisionShape3D` for custom collision

#### Step 4: Configure Materials

1. **MeshInstance3D** → **Material Override**
2. **Load** or create appropriate materials
3. **Ensure** textures are properly assigned

#### Step 5: Add Variants and LOD (Optional)

For performance optimization:

```gdscript
# Add LOD groups for distance-based rendering
extends Node3D

@export var lod_distances: Array[float] = [50.0, 100.0, 200.0]
@export var lod_meshes: Array[Mesh] = []

func _ready():
    setup_lod_system()

func setup_lod_system():
    # Implementation for LOD switching
    pass
```

#### Step 6: Save the Scene

1. **Scene Menu** → **Save Scene**
2. **Navigate** to appropriate folder (e.g., `Assets/Terrain/Shared/psx_models/trees/`)
3. **Name** following convention: `[AssetType]_[Variant]_[Size].tscn`
   - Example: `PineTree_Winter_Large.tscn`

### Manual Placement Workflow

#### Method 1: Direct Scene Instantiation

1. **Open** your main terrain scene
2. **Scene Menu** → **Instance Child Scene**
3. **Navigate** to your created .tscn file
4. **Position**, **rotate**, and **scale** as needed
5. **Duplicate** (`Ctrl+D`) for multiple instances

#### Method 2: Using Script-Assisted Placement

Create a placement helper script:

```gdscript
# PlacementHelper.gd
@tool
extends EditorScript

const TREE_SCENES = [
    "res://Assets/Terrain/Shared/psx_models/trees/PineTree_Small.tscn",
    "res://Assets/Terrain/Shared/psx_models/trees/PineTree_Medium.tscn",
    "res://Assets/Terrain/Shared/psx_models/trees/PineTree_Large.tscn"
]

func _run():
    var selection = EditorInterface.get_selection()
    var selected_nodes = selection.get_selected_nodes()
    
    if selected_nodes.size() > 0:
        var parent = selected_nodes[0]
        place_random_trees(parent, 20)

func place_random_trees(parent: Node3D, count: int):
    for i in range(count):
        var tree_scene = load(TREE_SCENES.pick_random())
        var tree_instance = tree_scene.instantiate()
        
        # Random positioning
        tree_instance.position = Vector3(
            randf_range(-50, 50),
            0,
            randf_range(-50, 50)
        )
        
        # Random rotation
        tree_instance.rotation.y = randf_range(0, TAU)
        
        # Random scale variation
        var scale_factor = randf_range(0.8, 1.2)
        tree_instance.scale = Vector3.ONE * scale_factor
        
        parent.add_child(tree_instance)
        tree_instance.owner = EditorInterface.get_edited_scene_root()
```

## Programmatic Terrain Generation

### Terrain3D Integration

Based on the existing codebase structure, implement terrain generation for specific regions:

#### Base Terrain Generator Class

```gdscript
# TerrainGenerator.gd
class_name TerrainGenerator
extends Node3D

@export var terrain_3d: Terrain3D
@export var noise_settings: NoiseSettings
@export var region_config: RegionConfig

signal terrain_generated(region_name: String)

func generate_region_terrain(region_name: String, heightmap_size: Vector2i = Vector2i(512, 512)):
    match region_name:
        "tambora":
            generate_tambora_terrain(heightmap_size)
        "papua":
            generate_papua_terrain(heightmap_size)
        _:
            generate_base_terrain(heightmap_size)

func generate_tambora_terrain(size: Vector2i):
    # Volcanic terrain with steep slopes and crater
    var noise = FastNoiseLite.new()
    noise.noise_type = FastNoiseLite.TYPE_PERLIN
    noise.frequency = 0.01
    noise.fractal_octaves = 6
    
    var heightmap = create_heightmap(size, noise)
    apply_volcanic_features(heightmap)
    apply_to_terrain3d(heightmap)
    
    terrain_generated.emit("tambora")

func generate_papua_terrain(size: Vector2i):
    # Dense forest terrain with rivers and hills
    var noise = FastNoiseLite.new()
    noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
    noise.frequency = 0.005
    noise.fractal_octaves = 4
    
    var heightmap = create_heightmap(size, noise)
    apply_forest_features(heightmap)
    carve_rivers(heightmap)
    apply_to_terrain3d(heightmap)
    
    terrain_generated.emit("papua")
```

#### Tambora Volcano Terrain

```gdscript
# TamboraTerrainGenerator.gd
extends TerrainGenerator

func apply_volcanic_features(heightmap: Image):
    var size = heightmap.get_size()
    var center = Vector2(size.x / 2, size.y / 2)
    var crater_radius = min(size.x, size.y) * 0.2
    
    heightmap.lock()
    
    for x in range(size.x):
        for y in range(size.y):
            var pos = Vector2(x, y)
            var distance_to_center = pos.distance_to(center)
            
            # Create volcanic cone
            var cone_height = 1.0 - (distance_to_center / (size.x * 0.4))
            cone_height = clamp(cone_height, 0.0, 1.0)
            cone_height = pow(cone_height, 0.7)  # Adjust slope
            
            # Create crater
            if distance_to_center < crater_radius:
                var crater_depth = 1.0 - (distance_to_center / crater_radius)
                crater_depth = pow(crater_depth, 2.0) * 0.3
                cone_height -= crater_depth
            
            var current_color = heightmap.get_pixel(x, y)
            var new_height = current_color.r + cone_height * 0.5
            new_height = clamp(new_height, 0.0, 1.0)
            
            heightmap.set_pixel(x, y, Color(new_height, new_height, new_height, 1.0))
    
    heightmap.unlock()
```

#### Papua Forest Terrain

```gdscript
# PapuaTerrainGenerator.gd
extends TerrainGenerator

func apply_forest_features(heightmap: Image):
    # Create rolling hills suitable for dense forest
    var size = heightmap.get_size()
    var hill_noise = FastNoiseLite.new()
    hill_noise.noise_type = FastNoiseLite.TYPE_CELLULAR
    hill_noise.frequency = 0.02
    
    heightmap.lock()
    
    for x in range(size.x):
        for y in range(size.y):
            var hill_value = hill_noise.get_noise_2d(x, y) * 0.3
            var current_color = heightmap.get_pixel(x, y)
            var new_height = current_color.r + hill_value
            new_height = clamp(new_height, 0.0, 1.0)
            
            heightmap.set_pixel(x, y, Color(new_height, new_height, new_height, 1.0))
    
    heightmap.unlock()

func carve_rivers(heightmap: Image):
    # Create meandering river paths
    var size = heightmap.get_size()
    var river_paths = generate_river_paths(size)
    
    heightmap.lock()
    
    for path in river_paths:
        for point in path:
            var river_width = 10
            for dx in range(-river_width, river_width + 1):
                for dy in range(-river_width, river_width + 1):
                    var x = point.x + dx
                    var y = point.y + dy
                    
                    if x >= 0 and x < size.x and y >= 0 and y < size.y:
                        var distance = sqrt(dx * dx + dy * dy)
                        if distance <= river_width:
                            var depth_factor = 1.0 - (distance / river_width)
                            var current_color = heightmap.get_pixel(x, y)
                            var new_height = current_color.r - depth_factor * 0.1
                            new_height = max(new_height, 0.0)
                            
                            heightmap.set_pixel(x, y, Color(new_height, new_height, new_height, 1.0))
    
    heightmap.unlock()
```

### Integration with Terrain3D

```gdscript
# Terrain3DIntegration.gd
extends Node

func setup_terrain_for_region(region_name: String):
    var terrain_3d = get_terrain3d_instance()
    var storage = terrain_3d.get_storage()
    
    # Configure terrain materials based on region
    match region_name:
        "tambora":
            setup_volcanic_materials(storage)
        "papua":
            setup_forest_materials(storage)

func setup_volcanic_materials(storage: Terrain3DStorage):
    var texture_list = storage.get_texture_list()
    
    # Add volcanic textures
    texture_list.add_texture("res://Assets/Terrain/Textures/volcanic_rock.png")
    texture_list.add_texture("res://Assets/Terrain/Textures/ash.png")
    texture_list.add_texture("res://Assets/Terrain/Textures/lava_rock.png")

func setup_forest_materials(storage: Terrain3DStorage):
    var texture_list = storage.get_texture_list()
    
    # Add forest textures
    texture_list.add_texture("res://Assets/Terrain/Textures/forest_floor.png")
    texture_list.add_texture("res://Assets/Terrain/Textures/moss.png")
    texture_list.add_texture("res://Assets/Terrain/Textures/dirt_path.png")
```

## Integration Examples

### Example: Complete Scene Setup

```gdscript
# RegionSceneSetup.gd
extends Node3D

@export var region_name: String = "tambora"
@export var terrain_generator: TerrainGenerator
@export var asset_placer: AssetPlacer

func _ready():
    setup_region()

func setup_region():
    # Generate terrain
    terrain_generator.terrain_generated.connect(_on_terrain_generated)
    terrain_generator.generate_region_terrain(region_name)

func _on_terrain_generated(region: String):
    # Place assets after terrain is ready
    asset_placer.place_region_assets(region)
```

### Example: Asset Placement Controller

```gdscript
# AssetPlacer.gd
class_name AssetPlacer
extends Node3D

const ASSET_CONFIGS = {
    "tambora": {
        "trees": ["res://Assets/Terrain/Shared/psx_models/trees/dead_tree.tscn"],
        "rocks": ["res://Assets/Terrain/Shared/psx_models/stones/volcanic_rock.tscn"],
        "density": 0.3
    },
    "papua": {
        "trees": [
            "res://Assets/Terrain/Shared/psx_models/trees/tropical_tree_large.tscn",
            "res://Assets/Terrain/Shared/psx_models/trees/palm_tree.tscn"
        ],
        "vegetation": ["res://Assets/Terrain/Shared/psx_models/vegetation/fern.tscn"],
        "density": 0.8
    }
}

func place_region_assets(region_name: String):
    var config = ASSET_CONFIGS.get(region_name, {})
    var terrain_3d = get_terrain3d_instance()
    
    place_assets_by_type(config.get("trees", []), "tree", config.density)
    place_assets_by_type(config.get("rocks", []), "rock", config.density * 0.5)
    place_assets_by_type(config.get("vegetation", []), "vegetation", config.density * 1.5)

func place_assets_by_type(asset_paths: Array, type: String, density: float):
    # Implementation for placing assets based on terrain height and slope
    pass
```

## Best Practices

### Asset Organization

1. **Naming Convention**: Use descriptive names with variant information
   - `[Category]_[Type]_[Variant]_[Size].tscn`
   - Example: `Tree_Pine_Winter_Large.tscn`

2. **Folder Structure**: Group by category and region
   ```
   Assets/Terrain/Shared/psx_models/
   ├── trees/
   │   ├── pine/
   │   ├── tropical/
   │   └── dead/
   ├── vegetation/
   │   ├── grass/
   │   ├── ferns/
   │   └── flowers/
   └── stones/
   ```

3. **LOD Management**: Include multiple detail levels for performance
4. **Material Consistency**: Use shared materials where possible
5. **Collision Shapes**: Only add collision where necessary for gameplay

### Performance Considerations

1. **Instancing**: Use `MultiMeshInstance3D` for repeated assets
2. **Culling**: Implement view frustum and distance culling
3. **Batching**: Group similar assets together
4. **Texture Atlasing**: Combine small textures into atlases
5. **Memory Management**: Unload distant regions

### Version Control

1. **Asset Versioning**: Track changes to asset configurations
2. **Documentation**: Update this guide when adding new asset types
3. **Testing**: Validate asset placement on different terrains

## Conclusion

This guide provides the foundation for both manual asset placement and programmatic terrain generation. Start with manual placement for immediate needs, then gradually implement procedural systems as the project develops. The modular approach ensures that both methods can coexist and complement each other.

For questions or additional features, refer to the project's core systems documentation or consult with the development team.
