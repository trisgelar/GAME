### Bamboo Biome Optimization Workflow (Godot 4.3)

This guide documents the working solution we now use to turn large bamboo GLB sources into compact, game‑ready “biome” assets for Papua and Tambora.

### Goals
- Compress large GLB files into small/medium GLB biomes
- Keep manual placement simple (GLB remains the format)
- Maintain PSX look with aggressive texture downscaling

### Where to run
- Scene: `Tools/bamboo_optimizer_test.tscn`
- Script: `Tools/bamboo_optimizer.gd`

### Core Buttons (recommended path)
1. Cleanup → removes old variants and stale .import files
2. Full Optimization → runs extraction + texture optimization + GLB export
3. If needed, use orientation tools:
   - Fix Orientation / Natural Vertical
   - Rotate 90° / 270° / Reset to Horizontal
   - Cleanup Rotations (keeps preferred variant)

### Extreme PSX Settings (enabled)
- Max texture size: 64 px (longest side)
- Albedo: JPEG quality ~0.4 if no alpha
- Alpha/normal/ORM: normal/ORM removed; alpha kept as PNG
- Resulting images are saved for reference under:
  `Assets/Terrain/Shared/psx_models/vegetation/bamboo/optimized/textures_small/`
  (GLB embeds the textures; external copies are for inspection only.)

### Output
- GLB biomes: `Assets/Terrain/Shared/psx_models/vegetation/bamboo/optimized/*.glb`
- Typical sizes observed:
  - Small biomes: ~1–6 MB
  - Large biomes (8/9): tens of MB if many submeshes

Why sizes vary: after aggressive texture compression, geometry (mesh count, surfaces, node overhead) dominates. We keep GLB for easy integration; .gltf with external textures would be smaller on disk but less convenient.

### Best Practices
- Use a limited subset of small/medium biomes per region.
- Prefer the models that render well and keep FPS stable.
- If a biome is still heavy, try these options:
  - Reduce number of child meshes in source file
  - Use Rotate/Reset tools to standardize orientation before exporting
  - Consider a manual “trim” pass to delete tiny leaf meshes that don’t read on screen

### Troubleshooting
- Empty or tiny GLB: ensure the source contains MeshInstance3D nodes
- Upside down / horizontal: use Natural Vertical, Rotate 90°/270°, then Cleanup Rotations
- Texture size didn’t change: re‑run Full Optimization; logs should show “Resizing … to 64×N”

### Logs
- All steps are logged to `logs/game_log_YYYY-MM-DDTHH-MM-SS.log`
- Look for entries:
  - “EXTREME PSX MODE …”
  - “Resizing texture from … to 64×… (JPEG/PNG)”
  - “GLB export completed successfully!”

### Next Steps
- We extracted reusable export/texture logic into `addons/gltf_exporter` utilities so the same pipeline can be reused for other object types beyond bamboo.


