# DAE Texture Setup - Quick Reference

**Date:** 2025-09-03  
**Godot Version:** 4.3+

## 🚀 Quick Start

### 1. Load DAE Model
```gdscript
var dae_scene = load("res://model.dae")
var instance = dae_scene.instantiate()
```

### 2. Create Material
```gdscript
var material = StandardMaterial3D.new()
var texture = load("res://texture.png")
material.albedo_texture = texture
```

### 3. Apply Material
```gdscript
# Method 1: Material Override
mesh_instance.material_override = material

# Method 2: Surface Override
mesh_instance.set_surface_override_material(0, material)
```

## 🎨 Essential Material Properties

| Property | Description | Values |
|----------|-------------|---------|
| `albedo_texture` | Base color texture | Texture2D |
| `normal_texture` | Surface detail map | Texture2D |
| `roughness_texture` | Surface roughness | Texture2D |
| `metallic` | Metalness | 0.0 (non-metal) to 1.0 (metal) |
| `roughness` | Surface roughness | 0.0 (smooth) to 1.0 (rough) |
| `albedo_color` | Base color tint | Color |

## 🔧 Common Material Types

### Wood Material
```gdscript
func create_wood_material(texture_path: String) -> StandardMaterial3D:
    var material = StandardMaterial3D.new()
    material.albedo_texture = load(texture_path)
    material.metallic = 0.0
    material.roughness = 0.9
    material.albedo_color = Color(0.6, 0.4, 0.2, 1.0)
    return material
```

### Stone Material
```gdscript
func create_stone_material(texture_path: String) -> StandardMaterial3D:
    var material = StandardMaterial3D.new()
    material.albedo_texture = load(texture_path)
    material.metallic = 0.1
    material.roughness = 0.8
    material.albedo_color = Color(0.4, 0.4, 0.4, 1.0)
    return material
```

## 📁 Texture Organization

```
Assets/Terrain/Shared/textures/
├── wood/
│   ├── tree_bark.png
│   ├── tree_bark_normal.png
│   └── tree_bark_roughness.png
├── stone/
│   ├── volcanic_rock.png
│   └── volcanic_rock_normal.png
└── debris/
    ├── log_texture.png
    └── stump_texture.png
```

## ⚡ Performance Tips

- **Reuse materials** across multiple instances
- **Compress textures** for better performance
- **Use appropriate resolutions** (256x256 for small objects)
- **Batch similar materials** together

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Texture not visible | Check file path and material assignment |
| Black model | Verify albedo_texture is set |
| No surface detail | Enable normal_texture |
| Performance issues | Compress textures, reuse materials |

## 📱 Input Testing

```gdscript
func _input(event):
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_T: apply_texture()
            KEY_M: show_material_info()
            KEY_C: clear_materials()
```

## 🔗 Related Files

- `docs/2025-09-03_dae-texture-setup-guide.md` - Full documentation
- `docs/2025-09-03_tambora-debris-example.gd` - Practical example
- `Assets/Terrain/Tambora/psx_assets.tres` - Updated asset pack

---

**Need more details?** See the full documentation guide!
