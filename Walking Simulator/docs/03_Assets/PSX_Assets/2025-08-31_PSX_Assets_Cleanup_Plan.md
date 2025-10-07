# PSX Assets Cleanup Plan (Conservative Approach)

**Date**: 2025-08-31  
**Purpose**: Remove ONLY problematic FBX models while preserving all GLB assets

## Background

After extensive testing and debugging, we discovered that:
1. **FBX models** were problematic (causing texture and UV mapping issues)
2. **GLB models** work perfectly with proper textures and UV mapping
3. **OBJ models** are not being used in our project
4. **Conservative approach**: Keep all GLB models including variants for future flexibility

## Assets Analysis

### ✅ **Assets We're Keeping (ALL GLB MODELS)**

#### Core GLB Models (Production Ready)
- **Trees**: `pine_tree_n_1.glb`, `pine_tree_n_2.glb`, `pine_tree_n_3.glb`
- **Tree Variants**: `pine_tree_n_1_1.glb`, `pine_tree_n_1_2.glb`, `pine_tree_n_1_3.glb`, `pine_tree_n_1_4.glb`, etc.
- **Other Trees**: `tree_1.glb`, `tree_5.glb`, `tree_6.glb`, `tree_7.glb`, `tree_8.glb`, `tree_9.glb`
- **Vegetation**: `grass_1.glb`, `grass_2.glb`, `grass_3.glb`, `grass_4.glb`, `fern_1.glb`, `fern_2.glb`, `fern_3.glb`
- **Stones**: `stone_1.glb`, `stone_2.glb`, `stone_3.glb`, `stone_4.glb`, `stone_5.glb`
- **Mushrooms**: `mushroom_n_1.glb`, `mushroom_n_2.glb`, `mushroom_n_3.glb`, `mushroom_n_4.glb`
- **Mushroom Variants**: `mushroom_n_1_0.glb`, `mushroom_n_1_1.glb`, `mushroom_n_1_2.glb`, etc.
- **Debris**: `tree_log_1.glb`, `tree_stump_1.glb`

#### DAE Models (Alternative Format)
- **Debris**: `tree_log_1.dae`, `tree_stump_1.dae`

#### Textures
- All textures in `Assets/PSX/PSX Nature/textures/` folder
- Embedded textures in GLB models

### ❌ **Assets We Can Safely Remove (ONLY PROBLEMATIC FORMATS)**

#### Problematic FBX Models
- All files in `Assets/PSX/PSX Nature/Models/FBX/`
- These caused texture issues and "sticker-like" appearance
- **Reason**: Replaced with working GLB models

#### Unused OBJ Models
- All files in `Assets/PSX/PSX Nature/Models/OBJ/`
- **Reason**: Not referenced in any asset packs

## Cleanup Script

The cleanup is performed using `cleanup_unused_assets.bat` which:

1. **Removes all FBX models** and their import files (problematic)
2. **Removes all OBJ models** and their import files (unused)
3. **Removes empty directories** (FBX and OBJ folders)
4. **Preserves ALL GLB models** including variants and tree_1.glb to tree_9.glb

## Expected Results

### Before Cleanup
- **FBX Models**: ~50 files (problematic)
- **OBJ Models**: ~20 files (unused)
- **GLB Models**: ~80 files (including variants)
- **Total**: ~150+ files

### After Cleanup
- **FBX Models**: 0 files (removed)
- **OBJ Models**: 0 files (removed)
- **GLB Models**: ~80 files (all preserved)
- **DAE Models**: 2 files (debris)
- **Textures**: All preserved
- **Total**: ~82 files

### Space Savings
- **Estimated reduction**: ~70 files (FBX + OBJ)
- **Performance improvement**: Faster asset loading (no problematic FBX)
- **Maintenance improvement**: Cleaner structure, all GLB models available

## Asset Pack Configuration

After cleanup, our asset packs will reference:

### Papua Asset Pack
```gdscript
trees = [
    "res://Assets/PSX/PSX Nature/Models/GLB/pine_tree_n_1.glb",
    "res://Assets/PSX/PSX Nature/Models/GLB/pine_tree_n_2.glb",
    "res://Assets/PSX/PSX Nature/Models/GLB/pine_tree_n_3.glb"
]
# ... other categories
```

### Tambora Asset Pack
```gdscript
trees = [
    "res://Assets/PSX/PSX Nature/Models/GLB/pine_tree_n_1.glb",
    "res://Assets/PSX/PSX Nature/Models/GLB/pine_tree_n_2.glb",
    "res://Assets/PSX/PSX Nature/Models/GLB/pine_tree_n_3.glb"
]
# ... other categories
```

## Verification

After cleanup, verify that:
1. ✅ All asset pack tests pass
2. ✅ Format comparison test works
3. ✅ Tree isolated test works
4. ✅ No missing asset errors in Godot
5. ✅ Significantly reduced file count

## Future Considerations

1. **Backup**: Keep a backup of the original assets before cleanup
2. **Version Control**: Commit the cleanup changes to git
3. **Documentation**: Update any documentation that references removed assets
4. **Testing**: Run all tests to ensure nothing is broken

---

**Note**: This cleanup is safe because we've thoroughly tested the GLB models and confirmed they work perfectly with our texture assignment and UV mapping systems.
