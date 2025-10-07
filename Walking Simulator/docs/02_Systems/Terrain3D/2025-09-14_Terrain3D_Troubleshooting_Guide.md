# Terrain3D Troubleshooting Guide
**Date:** 2025-09-14  
**Topic:** Common Issues and Solutions for Terrain3D Asset Placement  
**Difficulty:** All Levels  

## 🎯 Overview

This document provides a comprehensive troubleshooting guide for common issues encountered when working with Terrain3D asset placement. It includes diagnostic steps, solutions, and prevention strategies.

## 🚨 Common Issues and Solutions

### 1. **Assets Floating Above Terrain**

**Symptoms:**
- Assets appear to hover above the terrain surface
- Assets are placed at Y=0 or incorrect heights
- Height sampling returns 0.0 or NaN values

**Root Causes:**
- Coordinate system mismatch between world and terrain-local coordinates
- Scene translation not accounted for in height sampling
- Terrain3D data not properly loaded or initialized
- Height sampling function using wrong coordinate system

**Diagnostic Steps:**
```gdscript
func debug_floating_assets():
    """Debug floating asset issues"""
    print("=== FLOATING ASSETS DEBUG ===")
    
    # Check terrain3d node
    if not terrain3d:
        print("❌ Terrain3D node not found!")
        return
    
    # Check terrain data
    var terrain_data = terrain3d.get_data()
    if not terrain_data:
        print("❌ Terrain3D data not loaded!")
        return
    
    # Test height sampling at known positions
    var test_positions = [
        Vector3(0, 0, 0),
        Vector3(50, 0, 50),
        Vector3(-50, 0, -50)
    ]
    
    for pos in test_positions:
        var height = terrain3d.get_height(pos)
        print("Position %s: Height = %.2f" % [pos, height])
        
        # Try alternative coordinate systems
        var alt_height = terrain_data.get_height(pos)
        print("  Alternative: Height = %.2f" % alt_height)
    
    # Check scene transformation
    var scene_transform = get_global_transform()
    print("Scene Transform: %s" % scene_transform)
    
    # Check terrain bounds
    var bounds = terrain3d.get_bounds()
    print("Terrain Bounds: %s" % bounds)
```

**Solutions:**
```gdscript
# Solution 1: Use proper coordinate conversion
func get_terrain_height_fixed(world_pos: Vector3) -> float:
    """Fixed height sampling with coordinate conversion"""
    if not terrain3d:
        return get_fallback_height(world_pos)
    
    # Convert world position to terrain-local position
    var terrain_local_pos = terrain3d.to_local(world_pos)
    var height = terrain3d.get_height(terrain_local_pos)
    
    if not is_nan(height) and height != 0.0:
        return height
    
    # Try alternative coordinate systems
    var alt_positions = [
        Vector3(world_pos.x, 0, world_pos.z),
        Vector3(world_pos.x, 0, 0),
        Vector3(0, 0, world_pos.z)
    ]
    
    for alt_pos in alt_positions:
        height = terrain3d.get_height(alt_pos)
        if not is_nan(height) and height != 0.0:
            return height
    
    return get_fallback_height(world_pos)

# Solution 2: Ensure terrain data is loaded
func ensure_terrain_data_loaded():
    """Ensure terrain data is properly loaded"""
    if not terrain3d:
        return false
    
    # Wait for terrain to be ready
    await terrain3d.terrain_updated
    
    # Reload terrain data
    terrain3d.reload()
    
    # Verify data is loaded
    var terrain_data = terrain3d.get_data()
    return terrain_data != null
```

### 2. **Terrain3D Node Not Found**

**Symptoms:**
- Error: "Terrain3D node not found"
- Asset placement functions fail silently
- Height sampling returns fallback values

**Root Causes:**
- Incorrect node path to Terrain3D
- Terrain3D node not properly instantiated
- Scene structure changed after code was written
- Terrain3D node not added to scene tree

**Diagnostic Steps:**
```gdscript
func debug_terrain3d_node():
    """Debug Terrain3D node issues"""
    print("=== TERRAIN3D NODE DEBUG ===")
    
    # Try multiple possible paths
    var possible_paths = [
        "Terrain3D",
        "Terrain3DManager/Terrain3D",
        "../Terrain3D",
        "Terrain3DManager/Terrain3DManager/Terrain3D"
    ]
    
    for path in possible_paths:
        var node = get_node_or_null(path)
        if node:
            print("✅ Found Terrain3D at path: %s" % path)
            print("   Type: %s" % node.get_class())
            print("   Valid: %s" % is_instance_valid(node))
            return node
        else:
            print("❌ Not found at path: %s" % path)
    
    # Search for Terrain3D in scene tree
    var terrain3d_nodes = find_children_by_type("Terrain3D")
    print("Found %d Terrain3D nodes in scene" % terrain3d_nodes.size())
    
    for node in terrain3d_nodes:
        print("  - %s" % node.get_path())
    
    return null

func find_children_by_type(type_name: String) -> Array:
    """Find all children of a specific type"""
    var result: Array = []
    _find_children_by_type_recursive(self, type_name, result)
    return result

func _find_children_by_type_recursive(node: Node, type_name: String, result: Array):
    """Recursively find children by type"""
    if node.get_class() == type_name:
        result.append(node)
    
    for child in node.get_children():
        _find_children_by_type_recursive(child, type_name, result)
```

**Solutions:**
```gdscript
# Solution 1: Robust Terrain3D node finding
func setup_terrain3d_robust():
    """Robustly setup Terrain3D node reference"""
    var possible_paths = [
        "Terrain3D",
        "Terrain3DManager/Terrain3D",
        "../Terrain3D",
        "Terrain3DManager/Terrain3DManager/Terrain3D"
    ]
    
    for path in possible_paths:
        var node = get_node_or_null(path)
        if node and node.get_class() == "Terrain3D":
            terrain3d = node
            print("✅ Terrain3D found at: %s" % path)
            return true
    
    # Fallback: search entire scene tree
    var terrain3d_nodes = find_children_by_type("Terrain3D")
    if terrain3d_nodes.size() > 0:
        terrain3d = terrain3d_nodes[0]
        print("✅ Terrain3D found via search: %s" % terrain3d.get_path())
        return true
    
    print("❌ Terrain3D node not found!")
    return false

# Solution 2: Wait for Terrain3D to be ready
func wait_for_terrain3d():
    """Wait for Terrain3D to be properly initialized"""
    if not terrain3d:
        return false
    
    # Wait for terrain to be updated
    await terrain3d.terrain_updated
    
    # Additional wait for data to be loaded
    await get_tree().process_frame
    await get_tree().process_frame
    
    return true
```

### 3. **Asset Loading Failures**

**Symptoms:**
- Error: "Failed to load asset"
- Error: "Asset file not found"
- Assets appear as missing/invisible
- Null reference errors when accessing assets

**Root Causes:**
- Incorrect asset file paths
- Asset files not included in project
- Asset files corrupted or in wrong format
- ResourceLoader not properly configured

**Diagnostic Steps:**
```gdscript
func debug_asset_loading():
    """Debug asset loading issues"""
    print("=== ASSET LOADING DEBUG ===")
    
    var test_paths = [
        "res://Assets/Terrain/tree.tscn",
        "res://Assets/Terrain/rock.tscn",
        "res://Assets/Terrain/vegetation.tscn"
    ]
    
    for path in test_paths:
        print("Testing path: %s" % path)
        
        # Check if file exists
        if not ResourceLoader.exists(path):
            print("  ❌ File does not exist")
            continue
        
        # Try to load the resource
        var resource = load(path)
        if not resource:
            print("  ❌ Failed to load resource")
            continue
        
        # Check resource type
        print("  ✅ Loaded successfully")
        print("  Type: %s" % resource.get_class())
        
        # Try to instantiate
        if resource.has_method("instantiate"):
            var instance = resource.instantiate()
            if instance:
                print("  ✅ Instantiation successful")
                instance.queue_free()
            else:
                print("  ❌ Instantiation failed")
        else:
            print("  ❌ Resource does not support instantiation")
```

**Solutions:**
```gdscript
# Solution 1: Safe asset loading
func safe_load_asset(asset_path: String) -> Node3D:
    """Safely load and instantiate an asset"""
    if not asset_path or asset_path == "":
        push_error("Asset path is empty")
        return null
    
    if not ResourceLoader.exists(asset_path):
        push_error("Asset file not found: " + asset_path)
        return null
    
    var asset_scene = load(asset_path)
    if not asset_scene:
        push_error("Failed to load asset: " + asset_path)
        return null
    
    if not asset_scene.has_method("instantiate"):
        push_error("Asset does not support instantiation: " + asset_path)
        return null
    
    var asset_instance = asset_scene.instantiate()
    if not asset_instance:
        push_error("Failed to instantiate asset: " + asset_path)
        return null
    
    return asset_instance

# Solution 2: Asset path validation
func validate_asset_paths(asset_paths: Array[String]) -> Array[String]:
    """Validate and filter asset paths"""
    var valid_paths: Array[String] = []
    
    for path in asset_paths:
        if ResourceLoader.exists(path):
            valid_paths.append(path)
        else:
            push_warning("Asset path not found: " + path)
    
    return valid_paths
```

### 4. **Performance Issues**

**Symptoms:**
- Low FPS when placing many assets
- Frame drops during asset placement
- Memory usage increasing over time
- Assets not being culled properly

**Root Causes:**
- Too many assets placed without LOD
- No spatial partitioning
- Assets not being properly managed
- Memory leaks from asset references

**Diagnostic Steps:**
```gdscript
func debug_performance():
    """Debug performance issues"""
    print("=== PERFORMANCE DEBUG ===")
    
    # Check FPS
    var fps = Engine.get_fps()
    print("FPS: %.1f" % fps)
    
    # Check asset count
    var asset_count = placed_assets.size()
    print("Asset Count: %d" % asset_count)
    
    # Check memory usage
    var memory_usage = OS.get_static_memory_usage()
    print("Memory Usage: %.2f MB" % (memory_usage / 1024.0 / 1024.0))
    
    # Check frame time
    var frame_time = Engine.get_process_delta_time()
    print("Frame Time: %.3f ms" % (frame_time * 1000.0))
    
    # Check for performance warnings
    if fps < 30:
        print("⚠️ WARNING: Low FPS detected!")
    
    if asset_count > 1000:
        print("⚠️ WARNING: High asset count!")
    
    if frame_time > 0.033:  # 30 FPS threshold
        print("⚠️ WARNING: High frame time!")
```

**Solutions:**
```gdscript
# Solution 1: Implement LOD system
func setup_lod_system():
    """Setup LOD system for performance"""
    for asset in placed_assets:
        var lod = AssetLOD.new()
        lod.asset = asset
        lod.lod_distances = [50.0, 100.0, 200.0]
        lod.lod_scales = [Vector3.ONE, Vector3(0.8, 0.8, 0.8), Vector3(0.6, 0.6, 0.6)]
        asset.set_meta("lod", lod)

# Solution 2: Implement spatial partitioning
func setup_spatial_partitioning():
    """Setup spatial partitioning for performance"""
    spatial_grid = SpatialGrid.new()
    spatial_grid.cell_size = 100.0
    
    for asset in placed_assets:
        spatial_grid.add_asset(asset)

# Solution 3: Asset cleanup
func cleanup_assets():
    """Clean up assets to prevent memory leaks"""
    var assets_to_remove: Array[Node3D] = []
    
    for asset in placed_assets:
        if not is_instance_valid(asset):
            assets_to_remove.append(asset)
    
    for asset in assets_to_remove:
        placed_assets.erase(asset)
    
    print("Cleaned up %d invalid assets" % assets_to_remove.size())
```

### 5. **Path Collision Issues**

**Symptoms:**
- Assets placed on paths
- Path avoidance not working
- Collision detection returning false positives
- Assets overlapping with path geometry

**Root Causes:**
- Path collision data not properly generated
- Collision detection using wrong coordinate system
- Path avoidance algorithm not implemented
- Path data not loaded or accessible

**Diagnostic Steps:**
```gdscript
func debug_path_collision():
    """Debug path collision issues"""
    print("=== PATH COLLISION DEBUG ===")
    
    # Check if path system exists
    var path_system = get_node_or_null("PathSystem")
    if not path_system:
        print("❌ Path system not found")
        return
    
    # Test collision detection at various positions
    var test_positions = [
        Vector3(0, 0, 0),
        Vector3(10, 0, 10),
        Vector3(-10, 0, -10)
    ]
    
    for pos in test_positions:
        var is_on_path = is_position_on_path(pos)
        print("Position %s: On path = %s" % [pos, is_on_path])
        
        # Visualize path areas if possible
        if is_on_path:
            print("  ⚠️ Position is on path!")

# Solution: Implement proper path avoidance
func is_position_on_path(position: Vector3) -> bool:
    """Check if position is on a path"""
    var path_system = get_node_or_null("PathSystem")
    if not path_system:
        return false
    
    # Use path system's collision detection
    return path_system.is_position_on_path(position)
```

## 🔧 Advanced Troubleshooting

### 1. **Scene State Issues**

**Symptoms:**
- Assets not appearing after scene reload
- Terrain3D data not persisting
- Scene state not properly saved/loaded

**Solutions:**
```gdscript
func save_scene_state():
    """Save current scene state"""
    var state = {
        "placed_assets": [],
        "terrain_config": terrain_config,
        "asset_placer_transform": asset_placer.global_transform
    }
    
    for asset in placed_assets:
        if is_instance_valid(asset):
            state.placed_assets.append({
                "path": asset.scene_file_path,
                "position": asset.global_position,
                "rotation": asset.global_rotation,
                "scale": asset.global_scale
            })
    
    var save_file = FileAccess.open("user://scene_state.save", FileAccess.WRITE)
    if save_file:
        save_file.store_string(JSON.stringify(state))
        save_file.close()

func load_scene_state():
    """Load saved scene state"""
    var save_file = FileAccess.open("user://scene_state.save", FileAccess.READ)
    if not save_file:
        return
    
    var json_string = save_file.get_as_text()
    save_file.close()
    
    var json = JSON.new()
    var parse_result = json.parse(json_string)
    if parse_result != OK:
        push_error("Failed to parse scene state")
        return
    
    var state = json.data
    restore_assets_from_state(state.placed_assets)
```

### 2. **Multi-Threading Issues**

**Symptoms:**
- Assets appearing in wrong positions
- Race conditions during asset placement
- Thread safety violations

**Solutions:**
```gdscript
# Use call_deferred for thread-safe operations
func place_asset_thread_safe(asset_path: String, position: Vector3):
    """Place asset in a thread-safe manner"""
    var asset = safe_load_asset(asset_path)
    if not asset:
        return
    
    # Defer the scene tree operations
    call_deferred("_add_asset_to_scene", asset, position)

func _add_asset_to_scene(asset: Node3D, position: Vector3):
    """Add asset to scene tree (called deferred)"""
    asset.global_position = position
    asset_placer.add_child(asset)
    placed_assets.append(asset)
```

## 📊 Diagnostic Tools

### 1. **Performance Profiler**

```gdscript
class PerformanceProfiler:
    var frame_times: Array[float] = []
    var max_samples: int = 60  # 1 second at 60 FPS
    
    func record_frame_time(delta: float):
        """Record frame time for profiling"""
        frame_times.append(delta)
        if frame_times.size() > max_samples:
            frame_times.pop_front()
    
    func get_average_frame_time() -> float:
        """Get average frame time"""
        if frame_times.size() == 0:
            return 0.0
        
        var sum = 0.0
        for time in frame_times:
            sum += time
        
        return sum / frame_times.size()
    
    func get_fps() -> float:
        """Get current FPS"""
        var avg_frame_time = get_average_frame_time()
        if avg_frame_time == 0.0:
            return 0.0
        
        return 1.0 / avg_frame_time
```

### 2. **Asset Inspector**

```gdscript
func inspect_asset(asset: Node3D):
    """Inspect asset properties for debugging"""
    print("=== ASSET INSPECTION ===")
    print("Asset: %s" % asset.name)
    print("Position: %s" % asset.global_position)
    print("Rotation: %s" % asset.global_rotation)
    print("Scale: %s" % asset.global_scale)
    print("Visible: %s" % asset.visible)
    print("In Scene Tree: %s" % asset.is_inside_tree())
    print("Parent: %s" % asset.get_parent())
    print("Children: %d" % asset.get_child_count())
    
    # Check for LOD
    var lod = asset.get_meta("lod")
    if lod:
        print("LOD Level: %d" % lod.current_lod)
    
    # Check for spatial grid
    var grid_key = asset.get_meta("grid_key")
    if grid_key:
        print("Grid Key: %s" % grid_key)
```

## 🎯 Prevention Strategies

### 1. **Code Organization**

```gdscript
# Organize code into logical sections:
# 1. System initialization
# 2. Asset placement functions
# 3. Error handling
# 4. Performance optimization
# 5. Debugging utilities

# Use consistent naming conventions
# Document all functions
# Add error checking everywhere
# Use type hints for better debugging
```

### 2. **Testing Framework**

```gdscript
func run_automated_tests():
    """Run automated tests for asset placement"""
    print("=== RUNNING AUTOMATED TESTS ===")
    
    # Test 1: Basic asset placement
    test_basic_placement()
    
    # Test 2: Height sampling
    test_height_sampling()
    
    # Test 3: Path avoidance
    test_path_avoidance()
    
    # Test 4: Performance
    test_performance()
    
    print("=== TESTS COMPLETE ===")

func test_basic_placement():
    """Test basic asset placement functionality"""
    var test_pos = Vector3(0, 0, 0)
    var asset = place_simple_asset("res://Assets/Terrain/test_tree.tscn", test_pos)
    
    if asset:
        print("✅ Basic placement test passed")
    else:
        print("❌ Basic placement test failed")
```

## 📝 Conclusion

This troubleshooting guide covers the most common issues encountered when working with Terrain3D asset placement. Key takeaways:

1. **Always Debug First**: Use diagnostic tools to identify the root cause
2. **Implement Robust Error Handling**: Check for null references and invalid states
3. **Use Consistent Coordinate Systems**: Avoid coordinate system mismatches
4. **Monitor Performance**: Implement LOD and spatial partitioning early
5. **Test Thoroughly**: Use automated tests to catch issues early

Remember that most issues stem from:
- Coordinate system mismatches
- Missing or incorrect node references
- Asset loading problems
- Performance bottlenecks
- Thread safety violations

By following the diagnostic steps and solutions provided, you can quickly identify and resolve most Terrain3D asset placement issues.

---
**Previous Document:** [Terrain3D Asset Placement Practical Guide](./2025-09-14_Terrain3D_Asset_Placement_Practical_Guide.md)  
**Documentation Status:** ✅ Complete  
**Last Updated:** 2025-09-14
