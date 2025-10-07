# Atlas Texture Quick Reference Card
**Date:** 2025-09-03  
**Project:** Walking Simulator - PSX Forest

## 🎨 Quick Atlas Setup

### 1. Load Atlas Texture
```gdscript
var atlas = load("res://Assets/PSX/PSX Forest/Textures/Forest_Pack_Atlas_1.tga")
```

### 2. Create Material
```gdscript
var material = StandardMaterial3D.new()
material.albedo_texture = atlas
```

### 3. Configure for Plants
```gdscript
material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
material.alpha_scissor_threshold = 0.3
material.cull_mode = BaseMaterial3D.CULL_DISABLED
```

### 4. Apply to MeshInstance3D
```gdscript
mesh_instance.material_override = material
```

## 🔧 Common Settings

| Property | Value | Purpose |
|----------|-------|---------|
| `transparency` | `ALPHA_SCISSOR` | Alpha cutout for plants |
| `alpha_scissor_threshold` | `0.3` | Cutoff point for transparency |
| `cull_mode` | `CULL_DISABLED` | Double-sided plants |
| `metallic` | `0.0` | Non-metallic surface |
| `roughness` | `0.7` | Slightly rough surface |

## 📁 File Paths

- **Atlas Texture:** `Assets/PSX/PSX Forest/Textures/Forest_Pack_Atlas_1.tga`
- **Base Color:** `Assets/PSX/PSX Forest/Textures/Forest_Pack_BaseColor.png`
- **Material Output:** `Assets/Terrain/Shared/materials/forest_atlas_material.tres`

## ⚠️ Troubleshooting

| Problem | Solution |
|---------|----------|
| Black texture | Check UV mapping in FBX |
| Jagged edges | Adjust `alpha_scissor_threshold` (0.1-0.5) |
| No transparency | Enable `TRANSPARENCY_ALPHA_SCISSOR` |
| Single-sided plants | Set `cull_mode = CULL_DISABLED` |

## 🎯 UV Mapping Check

Each FBX model must have UV coordinates mapped to the correct region of the atlas:
- **Trees:** Usually top-left region
- **Grass:** Middle regions
- **Ferns:** Bottom regions
- **Mushrooms:** Right-side regions

## 📱 Testing Keys

| Key | Action |
|-----|--------|
| `1` | Create dense forest zone |
| `2` | Create riverine zone |
| `3` | Create highland zone |
| `4` | Create clearing zone |
| `5` | Create complete forest |
| `C` | Clear all assets |
| `D` | Debug atlas usage |
| `S` | Show statistics |
