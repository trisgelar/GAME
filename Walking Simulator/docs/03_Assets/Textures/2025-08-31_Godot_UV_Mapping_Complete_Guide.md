# Godot UV Mapping Complete Guide for Beginners

## Table of Contents
1. [Introduction to UV Mapping](#introduction-to-uv-mapping)
2. [UV Mapping Types](#uv-mapping-types)
3. [Programmatic UV Mapping in GDScript](#programmatic-uv-mapping-in-gdscript)
4. [Tree-Specific UV Mapping System](#tree-specific-uv-mapping-system)
5. [Best Practices](#best-practices)
6. [Common Issues and Solutions](#common-issues-and-solutions)
7. [Examples with PSX Assets](#examples-with-psx-assets)

## Introduction to UV Mapping

UV mapping is the process of projecting a 2D texture onto a 3D model's surface. Think of it like wrapping a gift - you need to carefully map the flat wrapping paper (texture) around the 3D object (model).

### Key Concepts:
- **U and V coordinates**: 2D coordinates that map to the texture (like X and Y but for textures)
- **UV coordinates range**: 0.0 to 1.0 (representing the full texture)
- **Texture tiling**: Repeating the texture multiple times for more detail

## UV Mapping Types

### 1. Planar Mapping (Sticker-like)
**Best for**: Flat surfaces, leaves, grass, signs
**How it works**: Projects the texture from one direction (like a projector)

```gdscript
# Simple planar mapping
var u = (vertex.x - min_pos.x) / size.x
var v = (vertex.z - min_pos.z) / size.z
```

### 2. Cylindrical Mapping (Wrap-based)
**Best for**: Tree trunks, branches, pipes, columns
**How it works**: Wraps the texture around a cylinder

```gdscript
# Cylindrical mapping
var angle = atan2(vertex.x, vertex.z)
var u = (angle + PI) / (2.0 * PI)  # Map angle to U
var v = (vertex.y - min_pos.y) / size.y  # Map height to V
```

### 3. Spherical Mapping
**Best for**: Balls, heads, round objects
**How it works**: Projects the texture from the center outward

```gdscript
# Spherical mapping
var direction = (vertex - center).normalized()
var u = 0.5 + atan2(direction.x, direction.z) / (2.0 * PI)
var v = 0.5 - asin(direction.y) / PI
```

### 4. Triplanar Mapping
**Best for**: Complex geometry, terrain
**How it works**: Uses three planar projections and blends them

## Programmatic UV Mapping in GDScript

### Basic UV Mapping Function

```gdscript
func create_uv_mapping(mesh: Mesh, mapping_type: String = "auto") -> Mesh:
    var new_mesh = ArrayMesh.new()
    
    for surface_idx in range(mesh.get_surface_count()):
        var arrays = mesh.surface_get_arrays(surface_idx)
        var vertices = arrays[Mesh.ARRAY_VERTEX]
        var normals = arrays[Mesh.ARRAY_NORMAL] if arrays.size() > Mesh.ARRAY_NORMAL else []
        
        var uvs = PackedVector2Array()
        
        match mapping_type:
            "planar":
                uvs = create_planar_uvs(vertices)
            "cylindrical":
                uvs = create_cylindrical_uvs(vertices)
            "spherical":
                uvs = create_spherical_uvs(vertices)
            "triplanar":
                uvs = create_triplanar_uvs(vertices, normals)
            _:
                uvs = create_auto_uvs(vertices)
        
        arrays[Mesh.ARRAY_TEX_UV] = uvs
        new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    
    return new_mesh
```

### Geometry Type Detection

```gdscript
func detect_geometry_type(mesh: Mesh) -> String:
    var arrays = mesh.surface_get_arrays(0)
    var vertices = arrays[Mesh.ARRAY_VERTEX]
    
    # Calculate bounding box
    var min_pos = vertices[0]
    var max_pos = vertices[0]
    for vertex in vertices:
        min_pos = min_pos.min(vertex)
        max_pos = max_pos.max(vertex)
    
    var size = max_pos - min_pos
    var height = size.y
    var radius = (size.x + size.z) * 0.5
    
    # Detection logic
    if height > radius * 2.0:
        return "cylindrical"  # Tall and thin
    elif size.y < (size.x + size.z) * 0.1:
        return "planar"       # Very flat
    else:
        return "spherical"    # Round
```

## Tree-Specific UV Mapping System

### Overview
The tree-specific UV mapping system automatically detects different parts of tree models (trunks, branches, leaves, roots) and applies the most appropriate UV mapping for each part.

### Implementation

```gdscript
func create_tree_specific_uv_mapping(mesh: Mesh) -> Mesh:
    var new_mesh = ArrayMesh.new()
    
    for surface_idx in range(mesh.get_surface_count()):
        var arrays = mesh.surface_get_arrays(surface_idx)
        var vertices = arrays[Mesh.ARRAY_VERTEX]
        var normals = arrays[Mesh.ARRAY_NORMAL] if arrays.size() > Mesh.ARRAY_NORMAL else []
        
        # Analyze geometry
        var size = calculate_bounding_box(vertices)
        var height_ratio = size.y / max(size.x, size.z)
        var flatness_ratio = size.y / (size.x + size.z)
        
        var uvs = PackedVector2Array()
        
        # Smart part detection
        if flatness_ratio < 0.15 and size.x > 0.5 and size.z > 0.5:
            # Leaf detection
            uvs = create_improved_planar_uvs(vertices, "leaf")
        elif height_ratio > 2.0 and size.x > 0.3 and size.z > 0.3:
            # Trunk detection
            uvs = create_improved_cylindrical_uvs(vertices, "trunk")
        elif height_ratio > 1.0 and size.x > 0.2 and size.z > 0.2:
            # Branch detection
            uvs = create_improved_cylindrical_uvs(vertices, "branch")
        elif height_ratio < 0.5 and (size.x > 0.5 or size.z > 0.5):
            # Root/stump detection
            uvs = create_improved_planar_uvs(vertices, "root")
        else:
            # Complex geometry
            uvs = create_improved_triplanar_uvs(vertices, normals)
        
        arrays[Mesh.ARRAY_TEX_UV] = uvs
        new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    
    return new_mesh
```

### Part-Specific UV Mapping

#### Leaf UV Mapping
```gdscript
func create_improved_planar_uvs(vertices: PackedVector3Array, part_type: String = "leaf") -> PackedVector2Array:
    var uvs = PackedVector2Array()
    var size = calculate_bounding_box(vertices)
    
    for vertex in vertices:
        var u = (vertex.x - min_pos.x) / size.x
        var v = (vertex.z - min_pos.z) / size.z
        
        # Apply part-specific scaling
        match part_type:
            "leaf":
                u *= 3.0  # More detail for leaves
                v *= 3.0
            "root":
                u *= 1.5  # Less detail for roots
                v *= 1.5
            _:
                u *= 2.0  # Default scaling
                v *= 2.0
        
        u = clamp(u, 0.0, 1.0)
        v = clamp(v, 0.0, 1.0)
        uvs.append(Vector2(u, v))
    
    return uvs
```

#### Trunk UV Mapping
```gdscript
func create_improved_cylindrical_uvs(vertices: PackedVector3Array, part_type: String = "trunk") -> PackedVector2Array:
    var uvs = PackedVector2Array()
    var size = calculate_bounding_box(vertices)
    var center = calculate_center(vertices)
    
    for vertex in vertices:
        var relative_pos = vertex - center
        var angle = atan2(relative_pos.x, relative_pos.z)
        var u = (angle + PI) / (2.0 * PI)
        var v = (vertex.y - min_pos.y) / size.y
        
        # Apply part-specific scaling
        match part_type:
            "trunk":
                u *= 2.0  # Tile around trunk
                v *= 4.0  # More vertical detail
            "branch":
                u *= 1.5  # Moderate tiling
                v *= 2.0
            _:
                u *= 2.0  # Default scaling
                v *= 2.0
        
        u = clamp(u, 0.0, 1.0)
        v = clamp(v, 0.0, 1.0)
        uvs.append(Vector2(u, v))
    
    return uvs
```

### Usage in Asset Testing

```gdscript
# Apply tree-specific UV mapping
func apply_tree_uv_fix():
    if not asset_container:
        return
    
    var fixed_count = 0
    apply_tree_uv_fix_recursive(asset_container, fixed_count)
    update_status("Applied tree UV fix to " + str(fixed_count) + " tree assets")

func apply_tree_uv_fix_recursive(node: Node, fixed_count: int):
    if node is MeshInstance3D:
        var mesh = node.mesh
        if mesh and (node.name.begins_with("tree_") or 
                    node.get_parent() and node.get_parent().name.begins_with("tree_")):
            var new_mesh = create_tree_specific_uv_mapping(mesh)
            node.mesh = new_mesh
            fixed_count += 1
    
    for child in node.get_children():
        apply_tree_uv_fix_recursive(child, fixed_count)
```

## Best Practices

### 1. Texture Tiling
- **Leaves**: 3x3 tiling for detailed foliage
- **Trunks**: 2x4 tiling (2 around, 4 vertically)
- **Branches**: 1.5x2 tiling for moderate detail
- **Roots**: 1.5x1.5 tiling for subtle detail

### 2. UV Coordinate Validation
```gdscript
# Always clamp UV coordinates
u = clamp(u, 0.0, 1.0)
v = clamp(v, 0.0, 1.0)
```

### 3. Performance Considerations
- Cache bounding box calculations
- Use efficient geometry detection
- Minimize UV coordinate recalculations

### 4. Debugging UV Mapping
```gdscript
# Debug UV ranges
var min_uv = uvs[0]
var max_uv = uvs[0]
for uv in uvs:
    min_uv = min_uv.min(uv)
    max_uv = max_uv.max(uv)
print("UV range: ", min_uv, " to ", max_uv)
```

## Common Issues and Solutions

### 1. "Sticker-like" Textures
**Problem**: Textures appear flat and unrealistic
**Solution**: Use appropriate mapping type (cylindrical for trunks, planar for leaves)

### 2. Texture Stretching
**Problem**: Textures are distorted
**Solution**: Normalize UV coordinates based on actual geometry bounds

### 3. Seam Issues
**Problem**: Visible seams in cylindrical mapping
**Solution**: Ensure proper angle calculation and UV wrapping

### 4. Performance Issues
**Problem**: Slow UV mapping for complex models
**Solution**: Cache calculations and use efficient algorithms

## Examples with PSX Assets

### Complete UV Mapping Example

```gdscript
extends Node3D

func apply_uv_mapping_to_psx_assets():
    var asset_container = get_node("PSXAssetContainer")
    
    for child in asset_container.get_children():
        if child is MeshInstance3D:
            var mesh = child.mesh
            if mesh:
                # Detect if it's a tree asset
                if child.name.begins_with("tree_"):
                    var new_mesh = create_tree_specific_uv_mapping(mesh)
                    child.mesh = new_mesh
                    print("Applied tree-specific UV mapping to: ", child.name)
                else:
                    # Use auto-detection for other assets
                    var new_mesh = create_uv_mapping(mesh, "auto")
                    child.mesh = new_mesh
                    print("Applied auto UV mapping to: ", child.name)

func create_uv_mapping(mesh: Mesh, mapping_type: String = "auto") -> Mesh:
    if mapping_type == "auto":
        mapping_type = detect_geometry_type(mesh)
    
    var new_mesh = ArrayMesh.new()
    
    for surface_idx in range(mesh.get_surface_count()):
        var arrays = mesh.surface_get_arrays(surface_idx)
        var vertices = arrays[Mesh.ARRAY_VERTEX]
        var normals = arrays[Mesh.ARRAY_NORMAL] if arrays.size() > Mesh.ARRAY_NORMAL else []
        
        var uvs = PackedVector2Array()
        
        match mapping_type:
            "cylindrical":
                uvs = create_cylindrical_uvs(vertices)
            "spherical":
                uvs = create_spherical_uvs(vertices)
            "planar":
                uvs = create_planar_uvs(vertices)
            "triplanar":
                uvs = create_triplanar_uvs(vertices, normals)
            _:
                uvs = create_planar_uvs(vertices)
        
        arrays[Mesh.ARRAY_TEX_UV] = uvs
        new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    
    return new_mesh
```

### Testing UV Mapping Quality

```gdscript
func test_uv_mapping_quality():
    var asset_container = get_node("PSXAssetContainer")
    var total_assets = 0
    var assets_with_uv = 0
    
    for child in asset_container.get_children():
        if child is MeshInstance3D:
            total_assets += 1
            var mesh = child.mesh
            if mesh and mesh.surface_get_format(0) & Mesh.ARRAY_TEX_UV:
                assets_with_uv += 1
                print(child.name, " has UV mapping")
            else:
                print(child.name, " needs UV mapping")
    
    print("UV Mapping Quality: ", assets_with_uv, "/", total_assets, " assets have UV")
```

This comprehensive guide provides everything you need to implement effective UV mapping in Godot, with special attention to the tree-specific system that automatically handles different parts of tree models for realistic texture application.
