# Resource Organization Plan
*Created: 2025-09-18*

## Current Situation Analysis

### Scattered .tres Files Found:
- **Systems/Camera/Configs/**: 2 camera config files ✅ (already organized)
- **Systems/Items/ItemData/**: 14 item data files ✅ (already organized)
- **Assets/Themes/**: 1 theme file (mixed with other assets)
- **Assets/Models/**: 2 material files (mixed with models)
- **docs/**: 1 sample asset file (wrong location)
- **addons/**: 2 addon resource files (should stay in addons)

### Current Issues:
1. Theme resources mixed with other assets
2. Material resources scattered in model folders
3. Documentation resources in wrong location
4. No central resource registry
5. Terrain data files in scene-specific folders

## Recommended Organization Structure

```
Resources/                          # 🆕 Central resource directory
├── Audio/                          # 🎵 Audio resources
│   ├── Ambience/
│   │   ├── ForestAmbience.tres
│   │   ├── OceanAmbience.tres
│   │   └── VolcanoAmbience.tres
│   ├── Music/
│   │   ├── MainMenuTheme.tres
│   │   └── GameplayTheme.tres
│   └── Effects/
│       ├── UIClickSound.tres
│       └── FootstepSounds.tres
├── Camera/                         # 📷 Camera configurations
│   ├── Scenes/
│   │   ├── PapuaCameraConfig.tres
│   │   ├── TamboraCameraConfig.tres
│   │   ├── MainMenuCameraConfig.tres
│   │   └── DefaultCameraConfig.tres
│   └── Presets/
│       ├── CinematicCamera.tres
│       └── DebugCamera.tres
├── Items/                          # 🎒 Game items and collectibles
│   ├── Cultural/
│   │   ├── TribalOrnament.tres
│   │   ├── TraditionalMask.tres
│   │   ├── SacredStone.tres
│   │   └── HistoricalDocument.tres
│   ├── Geological/
│   │   ├── TamboraRockSample.tres
│   │   ├── BatuDootomo.tres
│   │   └── EruptionTimeline.tres
│   ├── Recipes/
│   │   ├── SotoRecipe.tres
│   │   ├── SateRecipe.tres
│   │   ├── LotekRecipe.tres
│   │   └── BasoRecipe.tres
│   └── Tools/
│       ├── AncientTool.tres
│       └── KapakPerunggu.tres
├── Materials/                      # 🎨 Material resources
│   ├── Terrain/
│   │   ├── PapuaTerrainMaterial.tres
│   │   ├── TamboraTerrainMaterial.tres
│   │   └── TerrainMaterial.tres
│   ├── Objects/
│   │   ├── PedestalMaterial.tres
│   │   └── RockMaterial.tres
│   └── UI/
│       └── ButtonMaterials.tres
├── Themes/                         # 🎨 UI themes and styles
│   ├── CulturalGameTheme.tres
│   ├── MainMenuTheme.tres
│   └── DebugTheme.tres
├── Terrain/                        # 🏔️ Terrain data
│   ├── Papua/
│   │   ├── terrain3d_00_00.res
│   │   ├── terrain3d_00-01.res
│   │   ├── terrain3d-01_00.res
│   │   └── terrain3d-01-01.res
│   ├── Tambora/
│   │   └── (future terrain files)
│   └── Shared/
│       └── (shared terrain assets)
├── Scenes/                         # 🎬 Scene-specific resources
│   ├── MainMenu/
│   │   └── MenuBackground.tres
│   ├── Papua/
│   │   └── PapuaEnvironment.tres
│   └── Tambora/
│       └── TamboraEnvironment.tres
├── NPCs/                           # 👥 NPC configurations
│   ├── CulturalGuide.tres
│   ├── Archaeologist.tres
│   ├── TribalElder.tres
│   └── Artisan.tres
├── Input/                          # 🎮 Input configurations
│   ├── DefaultInputMap.tres
│   ├── AccessibilityInputMap.tres
│   └── DebugInputMap.tres
└── Settings/                       # ⚙️ Game settings
    ├── GraphicsSettings.tres
    ├── AudioSettings.tres
    └── GameplaySettings.tres
```

## Migration Plan

### Phase 1: Create Directory Structure
1. Create `Resources/` directory with all subdirectories
2. Create organization documentation
3. Set up resource registry system

### Phase 2: Move Existing Resources
1. Move theme files from `Assets/Themes/` to `Resources/Themes/`
2. Move material files to `Resources/Materials/`
3. Move terrain data to `Resources/Terrain/`
4. Move item data files to organized categories
5. Move camera configs to scene-specific folders

### Phase 3: Update References
1. Update all scene files with new resource paths
2. Update scripts that load resources
3. Update documentation with new paths

### Phase 4: Clean Up
1. Remove empty directories
2. Update .gitignore if needed
3. Create resource loading utilities

## Benefits

1. **📍 Easy to Find**: All resources in one place with logical categories
2. **🔄 Reusable**: Clear separation allows easy resource sharing
3. **📚 Maintainable**: Organized structure makes updates simple
4. **🎯 Scalable**: Easy to add new resource types
5. **👥 Team-Friendly**: Clear conventions for team collaboration

## Resource Loading Utilities

Create helper scripts for common resource loading patterns:

```gdscript
# ResourceManager.gd
class_name ResourceManager

const CAMERA_CONFIGS = "res://Resources/Camera/Scenes/"
const ITEM_DATA = "res://Resources/Items/"
const THEMES = "res://Resources/Themes/"
const MATERIALS = "res://Resources/Materials/"

static func load_camera_config(scene_name: String) -> CameraSceneConfig:
    return load(CAMERA_CONFIGS + scene_name + "CameraConfig.tres")

static func load_item_data(item_name: String) -> ItemData:
    return load(ITEM_DATA + "Cultural/" + item_name + ".tres")
```

## Naming Conventions

### File Naming:
- **PascalCase** for resource files: `PapuaCameraConfig.tres`
- **Descriptive names**: Include purpose and context
- **Consistent suffixes**: `Config.tres`, `Material.tres`, `Data.tres`

### Directory Naming:
- **PascalCase** for directories: `Resources/Camera/Scenes/`
- **Plural nouns** for collections: `Items/`, `Materials/`
- **Clear hierarchy**: General → Specific

## Implementation Priority

1. **High Priority**: Camera configs, themes, materials (actively used)
2. **Medium Priority**: Item data, terrain resources (stable)
3. **Low Priority**: Future resources, utilities (when needed)
