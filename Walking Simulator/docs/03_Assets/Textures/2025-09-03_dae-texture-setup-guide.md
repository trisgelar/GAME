# DAE Texture Setup Guide for Godot 4.3

**Date:** 2025-09-03  
**Version:** 1.0  
**Godot Version:** 4.3+  
**File Format:** DAE (COLLADA)

## 📋 Table of Contents

1. [Understanding DAE Files](#understanding-dae-files)
2. [Texture Setup Methods](#texture-setup-methods)
3. [Material Creation](#material-creation)
4. [Texture Mapping](#texture-mapping)
5. [Best Practices](#best-practices)
6. [Troubleshooting](#troubleshooting)
7. [Examples](#examples)

## 🎯 Understanding DAE Files

### What are DAE Files?
- **DAE** = Digital Asset Exchange (COLLADA format)
- XML-based 3D model format
- Supports textures, materials, animations, and more
- Widely compatible across 3D software

### DAE vs GLB in Godot
- **DAE**: More complex, supports advanced features
- **GLB**: Optimized, single file, better performance
- **Use DAE when**: You need advanced material properties or animations
- **Use GLB when**: You want optimal performance and simplicity

## 🎨 Texture Setup Methods

### Method 1: Direct Material Assignment (Recommended)
```gdscript
# Load DAE model
var dae_scene = load("res://path/to/model.dae")
var model_instance = dae_scene.instantiate()

# Create material with texture
var material = StandardMaterial3D.new()
var texture = load("res://path/to/texture.png")
material.albedo_texture = texture

# Apply to model
_apply_material_recursively(model_instance, material)
```

### Method 2: Material Override
```gdscript
# Apply material to specific mesh instances
func apply_material_to_dae(model: Node3D, material: Material):
    for child in model.get_children():
        if child is MeshInstance3D:
            child.material_override = material
        apply_material_to_dae(child, material)
```

### Method 3: Surface Material Override
```gdscript
# Apply different materials to different surfaces
func apply_surface_materials(model: Node3D, materials: Array):
    for child in model.get_children():
        if child is MeshInstance3D:
            var mesh = child.mesh
            if mesh is ArrayMesh:
                for i in range(mesh.get_surface_count()):
                    if i < materials.size():
                        child.set_surface_override_material(i, materials[i])
        apply_surface_materials(child, materials)
```

## 🧪 Material Creation

### Basic Material Setup
```gdscript
func create_basic_material(texture_path: String) -> StandardMaterial3D:
    var material = StandardMaterial3D.new()
    
    # Load texture
    var texture = load(texture_path)
    if texture:
        material.albedo_texture = texture
    
    # Basic properties
    material.metallic = 0.0
    material.roughness = 0.8
    material.albedo_color = Color.WHITE
    
    return material
```

### Advanced Material with Multiple Maps
```gdscript
func create_advanced_material(
    albedo_path: String,
    normal_path: String = "",
    roughness_path: String = "",
    ao_path: String = ""
) -> StandardMaterial3D:
    var material = StandardMaterial3D.new()
    
    # Albedo (Base Color)
    var albedo = load(albedo_path)
    if albedo:
        material.albedo_texture = albedo
    
    # Normal Map
    if normal_path != "":
        var normal = load(normal_path)
        if normal:
            material.normal_enabled = true
            material.normal_texture = normal
            material.normal_scale = 1.0
    
    # Roughness Map
    if roughness_path != "":
        var roughness = load(roughness_path)
        if roughness:
            material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
            material.roughness_texture = roughness
    
    # Ambient Occlusion
    if ao_path != "":
        var ao = load(ao_path)
        if ao:
            material.ao_enabled = true
            material.ao_texture = ao
            material.ao_light_affect = 0.5
    
    return material
```

### Forest Debris Material (Specialized)
```gdscript
func create_forest_debris_material(texture_path: String) -> StandardMaterial3D:
    var material = StandardMaterial3D.new()
    
    # Load wood texture
    var texture = load(texture_path)
    if texture:
        material.albedo_texture = texture
    
    # Wood-specific properties
    material.metallic = 0.0
    material.roughness = 0.9  # Wood is rough
    material.albedo_color = Color(0.6, 0.4, 0.2, 1.0)  # Brown wood tint
    
    # Enable subsurface scattering for wood
    material.subsurface_scattering_enabled = true
    material.subsurface_scattering_strength = 0.1
    
    # Optional: Add detail normal map
    # material.normal_enabled = true
    # material.normal_texture = load("res://textures/wood_normal.png")
    
    return material
```

## 🗺️ Texture Mapping

### UV Coordinate System
- **U**: Horizontal coordinate (0.0 to 1.0)
- **V**: Vertical coordinate (0.0 to 1.0)
- **Origin**: Top-left corner (0,0) to bottom-right (1,1)

### Texture Tiling
```gdscript
func create_tiled_material(texture_path: String, tile_count: Vector2) -> StandardMaterial3D:
    var material = StandardMaterial3D.new()
    var texture = load(texture_path)
    
    if texture:
        material.albedo_texture = texture
        # Set tiling
        material.uv1_triplanar = true
        material.uv1_world_triplanar = true
        material.uv1_triplanar_sharpness = 1.0
    
    return material
```

### Texture Rotation and Offset
```gdscript
func create_rotated_material(texture_path: String, rotation_degrees: float) -> StandardMaterial3D:
    var material = StandardMaterial3D.new()
    var texture = load(texture_path)
    
    if texture:
        material.albedo_texture = texture
        # Rotate texture
        material.uv1_scale = Vector2.ONE
        material.uv1_offset = Vector2.ZERO
        # Note: Direct rotation requires shader or texture manipulation
    
    return material
```

## ✅ Best Practices

### 1. Texture Organization
```
Assets/
├── Terrain/
│   ├── Shared/
│   │   ├── textures/
│   │   │   ├── wood/
│   │   │   │   ├── tree_bark.png
│   │   │   │   ├── tree_bark_normal.png
│   │   │   │   └── tree_bark_roughness.png
│   │   │   └── stone/
│   │   │       ├── rock_base.png
│   │   │       └── rock_normal.png
│   │   └── psx_models/
│   │       └── debris/
│   │           ├── logs/
│   │           └── stumps/
```

### 2. Texture Naming Convention
- `modelname_base.png` - Base color/albedo
- `modelname_normal.png` - Normal map
- `modelname_roughness.png` - Roughness map
- `modelname_ao.png` - Ambient occlusion
- `modelname_metallic.png` - Metallic map

### 3. Texture Resolution Guidelines
- **Small objects (debris)**: 256x256 or 512x512
- **Medium objects (trees)**: 512x512 or 1024x1024
- **Large objects (terrain)**: 1024x1024 or 2048x2048
- **PSX style**: 64x64 to 256x256 for retro aesthetic

### 4. Material Performance
```gdscript
# Good: Reuse materials
var wood_material = create_forest_debris_material("res://textures/wood.png")
for debris in debris_instances:
    apply_material_to_dae(debris, wood_material)

# Bad: Create new material for each instance
for debris in debris_instances:
    var material = create_forest_debris_material("res://textures/wood.png")
    apply_material_to_dae(debris, material)
```

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. Texture Not Visible
```gdscript
# Check if texture loaded
var texture = load("res://path/to/texture.png")
if texture == null:
    print("❌ Texture failed to load")
    return

# Check material assignment
if model_instance.material_override == null:
    print("⚠️ No material assigned")
```

#### 2. UV Mapping Issues
```gdscript
# Verify UV coordinates exist
func check_uv_mapping(mesh: ArrayMesh) -> bool:
    for i in range(mesh.get_surface_count()):
        var arrays = mesh.surface_get_arrays(i)
        if arrays.size() > ArrayMesh.ARRAY_TEX_UV:
            var uvs = arrays[ArrayMesh.ARRAY_TEX_UV]
            if uvs.size() > 0:
                return true
    return false
```

#### 3. Performance Issues
```gdscript
# Use texture compression
func optimize_texture(texture_path: String) -> CompressedTexture2D:
    var image = load(texture_path)
    if image is Image:
        image.compress(Image.COMPRESS_S3TC, Image.COMPRESS_SOURCE_GENERIC, 0.8)
        return ImageTexture.create_from_image(image)
    return null
```

## 📚 Examples

### Complete Debris Setup Example
```gdscript
extends Node3D

var debris_material: StandardMaterial3D

func _ready():
    setup_debris_system()

func setup_debris_system():
    # Create material once
    debris_material = create_forest_debris_material("res://Assets/Terrain/Shared/textures/wood/tree_bark.png")
    
    # Load debris models
    var log_scene = load("res://Assets/Terrain/Shared/psx_models/debris/logs/tree_log_1.dae")
    var stump_scene = load("res://Assets/Terrain/Shared/psx_models/debris/stumps/tree_stump_1.dae")
    
    # Place debris with material
    place_debris(log_scene, Vector3(10, 0, 10))
    place_debris(stump_scene, Vector3(-10, 0, -10))

func place_debris(scene: PackedScene, position: Vector3):
    var instance = scene.instantiate()
    instance.position = position
    
    # Apply material
    apply_material_to_dae(instance, debris_material)
    
    add_child(instance)

func create_forest_debris_material(texture_path: String) -> StandardMaterial3D:
    var material = StandardMaterial3D.new()
    
    var texture = load(texture_path)
    if texture:
        material.albedo_texture = texture
        material.metallic = 0.0
        material.roughness = 0.9
        material.albedo_color = Color(0.6, 0.4, 0.2, 1.0)
    
    return material

func apply_material_to_dae(node: Node3D, material: Material):
    if node is MeshInstance3D:
        node.material_override = material
    
    for child in node.get_children():
        apply_material_to_dae(child, material)
```

### Material Library System
```gdscript
class_name MaterialLibrary
extends Resource

@export var materials: Dictionary = {}

func get_material(type: String) -> Material:
    if materials.has(type):
        return materials[type]
    return null

func create_material_library():
    # Wood materials
    materials["wood_bark"] = create_wood_material("res://textures/wood_bark.png")
    materials["wood_log"] = create_wood_material("res://textures/wood_log.png")
    
    # Stone materials
    materials["stone_rock"] = create_stone_material("res://textures/stone_rock.png")
    materials["stone_gravel"] = create_stone_material("res://textures/stone_gravel.png")

func create_wood_material(texture_path: String) -> StandardMaterial3D:
    var material = StandardMaterial3D.new()
    var texture = load(texture_path)
    if texture:
        material.albedo_texture = texture
        material.metallic = 0.0
        material.roughness = 0.9
    return material

func create_stone_material(texture_path: String) -> StandardMaterial3D:
    var material = StandardMaterial3D.new()
    var texture = load(texture_path)
    if texture:
        material.albedo_texture = texture
        material.metallic = 0.1
        material.roughness = 0.8
    return material
```

## 🎯 Quick Reference

### Essential Commands
```gdscript
# Load DAE
var scene = load("res://model.dae")

# Create material
var material = StandardMaterial3D.new()

# Load texture
var texture = load("res://texture.png")

# Apply texture
material.albedo_texture = texture

# Apply material
mesh_instance.material_override = material
```

### Material Properties
- `albedo_texture` - Base color texture
- `normal_texture` - Normal map for surface detail
- `roughness_texture` - Surface roughness map
- `metallic` - Metallic value (0.0 = non-metal, 1.0 = metal)
- `roughness` - Surface roughness (0.0 = smooth, 1.0 = rough)

### Texture Formats
- **PNG**: Best for transparency, larger file size
- **JPG**: Smaller file size, no transparency
- **TGA**: High quality, larger file size
- **WebP**: Modern, good compression

## 📖 Additional Resources

- [Godot Material Documentation](https://docs.godotengine.org/en/stable/tutorials/3d/materials_and_shading.html)
- [Texture Import Settings](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html)
- [3D Model Import](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes.html)

---

**Note:** This guide assumes Godot 4.3+. For older versions, some features may not be available or may have different syntax.
