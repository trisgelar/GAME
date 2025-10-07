# Graph System Troubleshooting Guide
**Date:** 2025-09-20  
**System:** Terrain3D Graph System  
**Status:** ✅ Active Support Document  

## 🚨 Quick Diagnosis

### Is Your Wheel Graph Working?
**Expected Result**: Pentagon wheel with dirt-textured paths, NPCs and artifacts positioned at vertices

**Quick Test**: 
1. Load Papua scene
2. Press KEY_5
3. Press KEY_2 (canopy view)
4. Look for brown dirt paths forming wheel spokes and outer ring

## 🔧 Common Issues and Solutions

### 1. ❌ "No Pentagon vertices found"

#### Symptoms
- Log shows: `❌ REPOSITIONING: No Pentagon vertices found`
- No wheel graph visible in scene
- NPCs/artifacts don't move

#### Causes & Solutions

**Cause A: GraphFactory Creation Failed**
```bash
# Check logs for:
"💥 DIRECT PENTAGON: Failed to create Pentagon graph"
```
**Solution**: Verify GraphFactory.gd exists and is accessible
```gdscript
# In Terrain3DController.gd, verify path:
var GraphFactory = preload("res://Systems/Terrain3D/GraphSystem/GraphFactory.gd")
```

**Cause B: Graph Generation Failed**
```bash
# Check logs for:
"💥 DIRECT PENTAGON: Graph generation failed"
```
**Solution**: Check WheelGraph implementation and vertex calculation
```gdscript
# Verify in WheelGraph.gd:
func _calculate_vertices(center: Vector3, radius: float, vertex_count: int) -> Array[Vector3]
```

**Cause C: Pentagon Graph Object Invalid**
```bash
# Check logs for:
"🚨 DIRECT PENTAGON: Graph created successfully: RefCounted"
```
**Solution**: Ensure pentagon_graph has valid vertices property
```gdscript
if pentagon_graph and pentagon_graph.vertices:
    vertex_positions = pentagon_graph.vertices.duplicate()
```

### 2. ❌ "Found 0 artifacts to reposition"

#### Symptoms
- NPCs move correctly
- Artifacts remain in original positions
- Log shows: `🎯 REPOSITIONING: Found 0 artifacts to reposition`

#### Causes & Solutions

**Cause A: Artifact Detection Too Restrictive**
**Solution**: Enhanced detection methods implemented ✅
```gdscript
# Multiple detection methods now active:
- Script path checking (WorldCulturalItem.gd)
- Group membership (artifacts, items)
- Name pattern matching (KapakPerunggu, etc.)
- Property checking (item_name, cultural_region)
```

**Cause B: Artifacts Not in Scene**
**Solution**: Verify artifacts exist in scene tree
1. Open Papua scene in editor
2. Look for: KapakPerunggu, TraditionalMask, AncientTool, SacredStone
3. Check they have proper scripts attached

**Cause C: Recursive Search Not Finding Objects**
**Solution**: Check scene hierarchy structure
```gdscript
# Ensure artifacts are children of scene root or accessible nodes
# Function searches entire scene tree recursively
```

### 3. ❌ Wheel Positioned at Mountains/Edges

#### Symptoms
- Wheel paths extend to terrain boundaries
- Vertices positioned at extreme coordinates
- Poor visual layout

#### Cause & Solution ✅ FIXED
**Original Problem**: Pentagon centered on player position
```gdscript
# OLD CODE (problematic):
var player_pos = get_player_position()
var terrain_aligned_pos = Vector3(player_pos.x, terrain_height + 0.5, player_pos.z)
```

**Fixed Implementation**:
```gdscript
# NEW CODE (working):
var region_center = Vector3(0, 0, 0)  # Center of Papua region
var terrain_aligned_pos = Vector3(region_center.x, terrain_height + 0.5, region_center.z)
```

### 4. ❌ Paths Appear as Red Blocks Instead of Textured Roads

#### Symptoms
- Paths visible but appear as solid red rectangles
- No dirt texture applied
- Unrealistic appearance

#### Cause & Solution ✅ FIXED
**Original Problem**: Only color applied, no texture
```gdscript
# OLD CODE (problematic):
pentagon_graph.graph_config.path_color = Color.RED
```

**Fixed Implementation**:
```gdscript
# NEW CODE (working):
var road_material = StandardMaterial3D.new()
var dirt_texture = preload("res://Assets/PSX/PSX Textures/Color/dirt_3.png")
road_material.albedo_texture = dirt_texture
road_material.roughness = 0.9
road_material.metallic = 0.0
road_material.uv1_scale = Vector3(2.0, 1.0, 2.0)
pentagon_graph.graph_config.path_material = road_material
```

### 5. ❌ Wheel Graph Not Showing Spokes (Only Outer Ring)

#### Symptoms
- Pentagon outer ring visible
- No spokes connecting center to vertices
- Doesn't match wheel diagram reference

#### Diagnosis Steps
1. **Check Edge Count**:
```bash
# Look for logs showing edge creation:
"🔗 Created spoke edge: Spoke_0"
"🔗 Created spoke edge: Spoke_1"
```

2. **Verify Wheel Structure**:
```gdscript
# Expected: 10 edges total (5 spokes + 5 ring edges)
# Check WheelGraph._calculate_edges() output
```

3. **Check Visualization**:
```bash
# Look for edge children in scene:
"Edges has 10 children:"
"- Edge_0_1 (Node3D) at (position), visible: true"
```

#### Solutions
**Solution A: Add Debug Function**
```gdscript
func _debug_wheel_structure(pentagon_graph):
    print("🔍 WHEEL DEBUG: Analyzing wheel structure...")
    if pentagon_graph and pentagon_graph.vertices:
        print("🔍 Vertices: %d" % pentagon_graph.vertices.size())
        for i in range(pentagon_graph.vertices.size()):
            print("🔍   Vertex %d: %s" % [i, pentagon_graph.vertices[i]])
    
    if pentagon_graph and pentagon_graph.edges:
        print("🔍 Edges: %d" % pentagon_graph.edges.size())
        var spoke_count = 0
        var ring_count = 0
        for edge in pentagon_graph.edges:
            if edge.edge_type == "spoke":
                spoke_count += 1
            elif edge.edge_type == "ring":
                ring_count += 1
        print("🔍 Spokes: %d, Ring: %d" % [spoke_count, ring_count])
```

**Solution B: Verify Edge Creation**
```gdscript
# In WheelGraph._calculate_edges():
# Ensure both spoke and ring edges are created
var center_index = 0
for i in range(1, vertices.size()):
    var spoke_edge = GraphEdge.new(center_index, i, 1.0, "spoke")
    wheel_edges.append(spoke_edge)
```

### 6. ❌ NPCs/Artifacts Move to Wrong Positions

#### Symptoms
- Objects move but to unexpected locations
- Positions don't match pentagon vertices
- Objects overlap or appear underground

#### Diagnosis
```bash
# Check vertex position logs:
"🎯   Vertex 0: (68.2315, 0.1, 73.70269)"
"🎯   Vertex 1: (118.2315, -4.286873, 73.70269)"

# Check movement logs:
"🎯 REPOSITIONING: Moved NPC CulturalGuide from (old) to (new)"
```

#### Solutions
**Solution A: Verify Terrain Height Alignment**
```gdscript
# Ensure vertices have proper Y coordinates
var terrain_height = get_terrain_height_at_position(region_center)
# Vertices should be at terrain_height + offset
```

**Solution B: Check Vertex Distribution**
```gdscript
# Pentagon vertices should be evenly distributed in circle
# Angle step: 2π / 5 = 72 degrees between vertices
```

## 🔍 Diagnostic Tools

### Essential Log Messages to Monitor

#### Success Indicators ✅
```bash
"🎉 DIRECT PENTAGON: Pentagon wheel graph generated and placed in scene!"
"🎯 REPOSITIONING: Found 4 NPCs to reposition"
"🎯 REPOSITIONING: Found X artifacts to reposition"
"🎉 REPOSITIONING: Completed! NPCs and artifacts moved to Pentagon vertices"
```

#### Warning Indicators ⚠️
```bash
"🚨 DIRECT PENTAGON: Using wheel radius: 25.0 for clear wheel structure"
"🚨 DIRECT PENTAGON: Modified config - width: 5.0, height: 1.0, road texture applied"
```

#### Error Indicators ❌
```bash
"💥 DIRECT PENTAGON: Failed to create Pentagon graph"
"💥 DIRECT PENTAGON: Graph generation failed"
"❌ REPOSITIONING: No Pentagon vertices found"
```

### Debug Commands
- **KEY_5**: Generate/regenerate wheel graph
- **KEY_2**: Switch to canopy view for overview
- **KEY_M**: Toggle mouse mode for navigation

### Scene Inspection Checklist
1. ✅ Terrain3DController exists in scene
2. ✅ GraphFactory.gd accessible
3. ✅ PSX texture files present
4. ✅ NPCs have proper scripts (CulturalNPC.gd)
5. ✅ Artifacts have proper properties (item_name, cultural_region)

## 📊 Performance Troubleshooting

### Slow Generation
**Symptoms**: Long delay after pressing KEY_5
**Solutions**:
- Reduce wheel radius (currently 25.0)
- Optimize recursive search depth
- Check for infinite loops in scene traversal

### Memory Issues
**Symptoms**: Game crashes during generation
**Solutions**:
- Clear previous wheel graphs before generating new ones
- Verify texture loading doesn't cause memory spikes
- Monitor node count in scene tree

## 🚀 Advanced Debugging

### Custom Debug Function
Add this to Terrain3DController.gd for detailed analysis:
```gdscript
func _debug_complete_system():
    print("=== COMPLETE SYSTEM DEBUG ===")
    
    # Scene analysis
    var scene_root = get_tree().current_scene
    print("Scene root: %s" % scene_root.name)
    print("Scene children: %d" % scene_root.get_child_count())
    
    # NPC analysis
    var npcs = []
    _find_npcs_recursive(scene_root, npcs)
    print("NPCs found: %d" % npcs.size())
    
    # Artifact analysis
    var artifacts = []
    _find_artifacts_recursive(scene_root, artifacts)
    print("Artifacts found: %d" % artifacts.size())
    
    # Graph system status
    print("GraphFactory available: %s" % (preload("res://Systems/Terrain3D/GraphSystem/GraphFactory.gd") != null))
    print("Terrain height at center: %f" % get_terrain_height_at_position(Vector3.ZERO))
    
    print("=== END DEBUG ===")
```

## 📝 Prevention Strategies

### Best Practices
1. **Always test** in clean scene state
2. **Monitor logs** for early warning signs
3. **Verify assets** before generation
4. **Use consistent naming** for cultural objects
5. **Regular backup** of working configurations

### Pre-Generation Checklist
- [ ] Papua scene loaded correctly
- [ ] Terrain3D system active
- [ ] All NPCs and artifacts present
- [ ] PSX textures imported
- [ ] No previous wheel graphs in scene
- [ ] Player positioned reasonably in scene

---
**Last Updated**: 2025-09-20  
**Maintainer**: Development Team  
**Status**: ✅ Active Support Document
