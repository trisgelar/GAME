# Asset Quick Reference Guide
**Date:** 2025-08-26  
**Project:** Indonesian Cultural Heritage Exhibition - Walking Simulator  
**Status:** Quick Reference

## 🚀 Quick Start Checklist

### **Before Importing Assets:**
- [ ] Models are FBX format
- [ ] Textures are 256x256 PNG
- [ ] Models have 500-2000 triangles
- [ ] Assets are organized in folders

### **Godot Import Settings:**

#### **FBX Files:**
```
Import: ✓ Enabled
Generate Tangents: ✗ Disabled
Smoothing: ✗ Disabled
Optimize Mesh: ✓ Enabled
```

#### **PNG Files:**
```
Import: ✓ Enabled
Filter: Nearest (for pixel art)
Mipmaps: ✓ Generate
Repeat: ✗ Disabled
```

## 📁 Folder Structure

```
Assets/
├── Models/
│   ├── Tambora/     # Mountain assets
│   └── Papua/       # Forest assets
├── Textures/
│   ├── Tambora/     # Volcanic textures
│   └── Papua/       # Jungle textures
└── Materials/
    ├── Tambora/     # Material resources
    └── Papua/       # Material resources
```

## 🎨 PSX/PS2 Style Rules

### **Visual Style:**
- **Low-poly models** (500-2000 triangles)
- **256x256 textures** maximum
- **Sharp edges** (no smooth shading)
- **Pixelated textures** (nearest neighbor filtering)
- **Limited color palette** (16-64 colors)

### **Performance Targets:**
- **Models:** 500-2000 triangles each
- **Textures:** 256x256 pixels maximum
- **Scene objects:** 50-100 per scene
- **Draw calls:** Under 100 per scene
- **Memory:** Under 100MB total

## 🔧 Common Commands

### **Create Material:**
```gdscript
# Right-click → New Resource → StandardMaterial3D
# Save as: Assets/Materials/[Scene]/[Name].tres
```

### **Apply Material:**
```gdscript
# Select MeshInstance3D → Inspector → Material Override
# Choose your .tres material file
```

### **Add to Scene:**
```gdscript
# Drag .fbx file from FileSystem to Scene Tree
# Position using Transform in Inspector
```

### **Add Collision:**
```gdscript
# Select model → Add Child Node → StaticBody3D
# Add CollisionShape3D as child
# Set collision layer = 1
```

## 🗺️ Radar Integration

### **Add POI to Radar:**
```gdscript
# In RadarSystem.gd, add to poi_list:
{
    "name": "Your POI Name",
    "position": Vector3(x, y, z),  # Match model position
    "icon": "icon_type",
    "description": "Description for tooltip"
}
```

### **Add Path Point:**
```gdscript
# In RadarSystem.gd, add to path_points:
path_points.append(Vector3(x, y, z))
```

### **Icon Types:**
- `"volcano"` - Geological features
- `"research"` - Scientific facilities  
- `"history"` - Historical sites
- `"culture"` - Cultural buildings
- `"nature"` - Natural features
- `"artifact"` - Collectible items

## 📊 Performance Monitoring

### **Check Performance:**
```gdscript
# In Debug → Performance Monitor:
- FPS: Should stay above 30
- Draw Calls: Should be under 100
- Memory: Should be under 100MB
```

### **Common Issues:**
- **Low FPS:** Too many objects or high-poly models
- **High Memory:** Large textures or too many materials
- **High Draw Calls:** Too many separate objects

## 🎯 Asset Lists

### **Tambora Assets Needed:**
```
Models:
├── volcano_peak.fbx
├── volcanic_rocks.fbx
├── lava_flows.fbx
├── dead_trees.fbx
├── observation_post.fbx
└── historical_marker.fbx

Textures:
├── volcanic_rock_256.png
├── ash_soil_256.png
├── lava_flow_256.png
├── dead_vegetation_256.png
├── building_wall_256.png
└── metal_roof_256.png
```

### **Papua Assets Needed:**
```
Models:
├── jungle_trees.fbx
├── dense_vegetation.fbx
├── traditional_hut.fbx
├── longhouse.fbx
├── totem_poles.fbx
└── ceremonial_grounds.fbx

Textures:
├── jungle_ground_256.png
├── tree_bark_256.png
├── leaf_texture_256.png
├── bamboo_wall_256.png
├── thatch_roof_256.png
└── wood_carving_256.png
```

## 🔍 Troubleshooting

### **Model Not Showing:**
- Check if material is applied
- Verify model is in scene tree
- Check if model has mesh
- Ensure model is not hidden

### **Texture Not Loading:**
- Check import settings (Filter: Nearest)
- Verify texture path in material
- Check if texture file exists
- Force reimport if needed

### **Radar Not Showing POI:**
- Check POI position matches model
- Verify POI is added to poi_list
- Check radar is visible
- Test with debug logs

### **Performance Issues:**
- Reduce model complexity
- Use texture atlasing
- Implement LOD system
- Optimize scene structure

## 📞 Quick Commands

### **Force Reimport:**
```
Select file → Right-click → Reimport
```

### **Check Model Info:**
```
Select MeshInstance3D → Inspector → Mesh → View Mesh
```

### **Check Texture Info:**
```
Select Texture → Inspector → Size
```

### **Test Radar:**
```
Press R key to toggle radar
Check debug logs for radar info
```

## 🎮 Testing Checklist

### **Visual Testing:**
- [ ] Models display correctly
- [ ] Textures are pixelated (PSX style)
- [ ] Materials are applied properly
- [ ] Lighting looks appropriate

### **Performance Testing:**
- [ ] FPS stays above 30
- [ ] Memory usage under 100MB
- [ ] Draw calls under 100
- [ ] No lag when moving

### **Radar Testing:**
- [ ] POIs show on radar
- [ ] Icons are correct color
- [ ] Tooltips display properly
- [ ] Paths draw correctly

### **Interaction Testing:**
- [ ] Collision works properly
- [ ] NPCs can be talked to
- [ ] Artifacts can be collected
- [ ] Movement is smooth

---

**Remember:** Always test after adding new assets and keep the PSX/PS2 aesthetic consistent!
