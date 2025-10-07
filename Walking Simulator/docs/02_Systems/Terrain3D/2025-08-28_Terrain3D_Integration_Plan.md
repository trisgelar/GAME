# Terrain3D Integration Plan

**Date:** 2025-08-28  
**Goal:** Integrate terrain_3d addon for Papua and Tambora scenes with PSX-style assets  
**Approach:** SOLID principles, maintainable, not over-engineered, authentic PSX aesthetics  

## Analysis of Examples

### Jungle Demo Setup Analysis
**Structure:**
- `scenes/Jungle.tscn` - Main scene with environment setup
- `scenes/JungleFoliage.tscn` - Separate foliage scene (6.1MB)
- `scenes/vegetation.tscn` - Vegetation system
- `addons/terrain_3d/` - Terrain3D addon
- `terrain3d_data/` - Terrain data directory
- `terrainassets.tres` - Terrain assets resource
- `terrainmaterial.tres` - Terrain material resource

**Key Components:**
- Terrain3D node with material and assets
- Separate foliage system using Scatter addon
- Environment lighting and fog setup
- Audio system integration

### Terrain3D Demo Analysis
**Structure:**
- `demo/Demo.tscn` - Main demo scene
- `demo/src/DemoScene.gd` - Simple scene controller
- `demo/src/Player.gd` - Player controller with terrain interaction
- `demo/data/` - Terrain data directory
- `demo/components/` - Modular scene components

**Key Components:**
- Terrain3D node with collision and navigation
- Modular component system
- Player with terrain-aware movement
- Runtime navigation baking

### PSX Assets Analysis
**Available Models:**
- **Trees**: `tree_1.fbx` to `tree_9.fbx`, `pine_tree_n_1.fbx` to `pine_tree_n_3.fbx` (multiple variants)
- **Stones**: `stone_1.fbx` to `stone_5.fbx`
- **Vegetation**: `grass_1.fbx` to `grass_4.fbx`, `fern_1.fbx` to `fern_3.fbx`
- **Mushrooms**: `mushroom_n_1.fbx` to `mushroom_n_4.fbx` (multiple variants)
- **Debris**: `tree_log_1.fbx`, `tree_stump_1.fbx`, `wheat_1.fbx`

**Available Textures:**
- **Ground Textures**: `dirt_1.png` to `dirt_7.png`, `grass_tx_1.png`
- **Rock Textures**: `rock_1.png` to `rock_5.png`
- **Concrete**: `concrete_1.png` to `concrete_7.png`, `concrete_tx_1.png` to `concrete_tx_7.png`
- **Metal**: `metal_floor_1.png` to `metal_floor_5.png`, `metal_wall_1.png` to `metal_wall_5.png`

## Integration Strategy

### 1. Project Structure (Following SOLID Principles)

```
Assets/
├── Terrain/
│   ├── Papua/
│   │   ├── heightmaps/
│   │   ├── textures/
│   │   │   ├── ground/ (dirt, grass textures)
│   │   │   └── rocks/ (rock textures)
│   │   ├── materials/
│   │   ├── assets.tres
│   │   └── psx_assets.tres
│   ├── Tambora/
│   │   ├── heightmaps/
│   │   ├── textures/
│   │   │   ├── ground/ (dirt, rock textures)
│   │   │   └── volcanic/ (concrete, metal textures)
│   │   ├── materials/
│   │   ├── assets.tres
│   │   └── psx_assets.tres
│   └── Shared/
│       ├── textures/
│       ├── materials/
│       └── psx_models/
│           ├── trees/
│           ├── stones/
│           ├── vegetation/
│           └── debris/
Systems/
├── Terrain/
│   ├── TerrainManager.gd
│   ├── TerrainMaterialFactory.gd
│   ├── TerrainAssetFactory.gd
│   ├── TerrainNavigationBaker.gd
│   └── PSXAssetManager.gd
└── Core/
    └── (existing systems)
Scenes/
├── IndonesiaTimur/
│   ├── PapuaScene.tscn
│   ├── PapuaTerrain.tscn
│   └── PapuaPSXAssets.tscn
├── IndonesiaTengah/
│   ├── TamboraScene.tscn
│   ├── TamboraTerrain.tscn
│   └── TamboraPSXAssets.tscn
└── (existing scenes)
```

### 2. SOLID Architecture Design

#### Single Responsibility Principle
- **TerrainManager**: Manages terrain lifecycle and data
- **TerrainMaterialFactory**: Creates terrain materials
- **TerrainAssetFactory**: Manages terrain assets
- **TerrainNavigationBaker**: Handles navigation mesh generation
- **PSXAssetManager**: Manages PSX-style asset placement and variation

#### Open/Closed Principle
- Base terrain classes that can be extended for specific regions
- Factory pattern for creating different terrain types
- Configurable material and asset systems
- PSX asset placement rules that can be extended

#### Liskov Substitution Principle
- Common terrain interface that works for all regions
- Interchangeable terrain implementations
- PSX asset systems that work with any terrain type

#### Interface Segregation Principle
- Separate interfaces for terrain data, materials, navigation, and PSX assets
- Minimal dependencies between systems

#### Dependency Inversion Principle
- Terrain systems depend on abstractions, not concrete implementations
- Dependency injection for terrain configuration
- PSX asset systems depend on terrain interfaces

### 3. Implementation Plan

#### Phase 1: Foundation Setup
1. **Add Terrain3D Addon**
   - Copy `addons/terrain_3d/` from examples
   - Update `project.godot` to enable the addon
   - Test basic functionality

2. **Create Base Terrain System**
   ```gdscript
   # Systems/Terrain/TerrainManager.gd
   class_name TerrainManager
   extends Node
   
   # Manages terrain lifecycle and data
   ```

3. **Create PSX Asset Manager**
   ```gdscript
   # Systems/Terrain/PSXAssetManager.gd
   class_name PSXAssetManager
   extends Node
   
   # Manages PSX-style asset placement and variation
   ```

4. **Create Terrain Factories**
   ```gdscript
   # Systems/Terrain/TerrainMaterialFactory.gd
   class_name TerrainMaterialFactory
   
   # Creates terrain materials for different regions
   ```

#### Phase 2: PSX Asset Integration
1. **Organize PSX Assets**
   - Create asset packs for different regions
   - Set up texture atlases for performance
   - Configure LOD settings for PSX models

2. **Create PSX Asset Packs**
   ```gdscript
   # Assets/Terrain/Papua/psx_assets.tres
   # Papua-specific PSX asset configuration
   
   # Assets/Terrain/Tambora/psx_assets.tres
   # Tambora-specific PSX asset configuration
   ```

3. **PSX Asset Placement Rules**
   - **Papua**: Jungle trees, ferns, mushrooms, grass patches
   - **Tambora**: Pine trees, stones, sparse vegetation, volcanic rocks

#### Phase 3: Papua Integration
1. **Create Papua Terrain Assets**
   - Height maps for jungle terrain
   - PSX textures: `dirt_1.png` to `dirt_7.png`, `grass_tx_1.png`
   - Terrain material with PSX-style blending

2. **Create Papua PSX Asset Scene**
   ```gdscript
   # Scenes/IndonesiaTimur/PapuaPSXAssets.tscn
   # PSX-style jungle vegetation and debris
   ```

3. **Papua PSX Asset Configuration**
   - **Trees**: `tree_1.fbx` to `tree_9.fbx` (randomized placement)
   - **Vegetation**: `grass_1.fbx` to `grass_4.fbx`, `fern_1.fbx` to `fern_3.fbx`
   - **Mushrooms**: `mushroom_n_1.fbx` to `mushroom_n_4.fbx` (clusters)
   - **Debris**: `tree_log_1.fbx`, `tree_stump_1.fbx` (scattered)

#### Phase 4: Tambora Integration
1. **Create Tambora Terrain Assets**
   - Height maps for mountain terrain
   - PSX textures: `rock_1.png` to `rock_5.png`, `concrete_1.png` to `concrete_7.png`
   - Terrain material with elevation-based PSX blending

2. **Create Tambora PSX Asset Scene**
   - Mountain-specific PSX setup
   - Volcanic crater formations with PSX rocks
   - High-altitude sparse vegetation

3. **Tambora PSX Asset Configuration**
   - **Trees**: `pine_tree_n_1.fbx` to `pine_tree_n_3.fbx` (elevation-based)
   - **Stones**: `stone_1.fbx` to `stone_5.fbx` (volcanic formations)
   - **Sparse Vegetation**: `grass_1.fbx` to `grass_4.fbx` (high altitude)
   - **Debris**: `tree_stump_1.fbx` (dead trees)

#### Phase 5: Navigation Integration
1. **Terrain Navigation Baker**
   ```gdscript
   # Systems/Terrain/TerrainNavigationBaker.gd
   # Handles runtime navigation mesh generation
   ```

2. **Player Integration**
   - Update player controller for terrain-aware movement
   - Maintain existing interaction systems
   - PSX-style collision detection

### 4. Code Structure Examples

#### PSX Asset Manager
```gdscript
class_name PSXAssetManager
extends Node

signal psx_assets_loaded(region: String)
signal psx_assets_unloaded()

var current_psx_assets: Array[Node3D]
var psx_asset_config: Dictionary

func load_psx_assets(region: String) -> Array[Node3D]:
    # Load PSX assets for specific region
    match region:
        "Papua":
            return _load_papua_psx_assets()
        "Tambora":
            return _load_tambora_psx_assets()
    return []

func _load_papua_psx_assets() -> Array[Node3D]:
    # Load jungle PSX assets
    var assets: Array[Node3D] = []
    
    # Add trees with randomization
    for i in range(20):
        var tree_variant = randi() % 9 + 1
        var tree = load("res://Assets/PSX/PSX Nature/Models/FBX/tree_" + str(tree_variant) + ".fbx")
        var tree_instance = tree.instantiate()
        tree_instance.position = Vector3(randf_range(-50, 50), 0, randf_range(-50, 50))
        assets.append(tree_instance)
    
    # Add vegetation
    for i in range(30):
        var grass_variant = randi() % 4 + 1
        var grass = load("res://Assets/PSX/PSX Nature/Models/FBX/grass_" + str(grass_variant) + ".fbx")
        var grass_instance = grass.instantiate()
        grass_instance.position = Vector3(randf_range(-50, 50), 0, randf_range(-50, 50))
        assets.append(grass_instance)
    
    return assets

func _load_tambora_psx_assets() -> Array[Node3D]:
    # Load mountain PSX assets
    var assets: Array[Node3D] = []
    
    # Add pine trees (elevation-based)
    for i in range(15):
        var pine_variant = randi() % 3 + 1
        var pine = load("res://Assets/PSX/PSX Nature/Models/FBX/pine_tree_n_" + str(pine_variant) + ".fbx")
        var pine_instance = pine.instantiate()
        pine_instance.position = Vector3(randf_range(-50, 50), randf_range(10, 30), randf_range(-50, 50))
        assets.append(pine_instance)
    
    # Add stones
    for i in range(25):
        var stone_variant = randi() % 5 + 1
        var stone = load("res://Assets/PSX/PSX Nature/Models/FBX/stone_" + str(stone_variant) + ".fbx")
        var stone_instance = stone.instantiate()
        stone_instance.position = Vector3(randf_range(-50, 50), 0, randf_range(-50, 50))
        assets.append(stone_instance)
    
    return assets
```

#### Terrain Material Factory with PSX Textures
```gdscript
class_name TerrainMaterialFactory

static func create_papua_material() -> Terrain3DMaterial:
    var material = Terrain3DMaterial.new()
    
    # Use PSX textures for Papua
    var dirt_texture = load("res://Assets/PSX/PSX Textures/Color/dirt_1.png")
    var grass_texture = load("res://Assets/PSX/PSX Textures/Color/grass_tx_1.png")
    
    # Configure PSX-style material parameters
    material.set_shader_parameter("base_texture", dirt_texture)
    material.set_shader_parameter("overlay_texture", grass_texture)
    material.set_shader_parameter("blend_sharpness", 0.8)  # PSX-style sharp blending
    
    return material

static func create_tambora_material() -> Terrain3DMaterial:
    var material = Terrain3DMaterial.new()
    
    # Use PSX textures for Tambora
    var rock_texture = load("res://Assets/PSX/PSX Textures/Color/rock_1.png")
    var concrete_texture = load("res://Assets/PSX/PSX Textures/Color/concrete_1.png")
    
    # Configure PSX-style material parameters
    material.set_shader_parameter("base_texture", rock_texture)
    material.set_shader_parameter("overlay_texture", concrete_texture)
    material.set_shader_parameter("blend_sharpness", 0.9)  # Sharp PSX-style blending
    
    return material
```

#### Region Scene Controller Integration
```gdscript
# Scenes/RegionSceneController.gd (updated)
extends Node3D

@onready var terrain_manager: TerrainManager = $TerrainManager
@onready var psx_asset_manager: PSXAssetManager = $PSXAssetManager

func _ready():
    # Load appropriate terrain for this region
    var terrain = terrain_manager.load_terrain(region_name)
    
    # Load PSX assets for this region
    var psx_assets = psx_asset_manager.load_psx_assets(region_name)
    
    # Add PSX assets to the scene
    for asset in psx_assets:
        add_child(asset)
```

### 5. PSX-Style Performance Considerations

#### Asset Optimization
- **Texture Compression**: Use PSX-style texture compression (low resolution, limited colors)
- **Model LOD**: PSX models are already low-poly, perfect for terrain scattering
- **Instance Rendering**: Use MultiMeshInstance3D for repeated PSX assets

#### PSX Aesthetic Features
- **Low Resolution**: Maintain PSX-style low-res textures
- **Limited Color Palette**: Use PSX color limitations for authenticity
- **Sharp Edges**: PSX-style sharp texture blending
- **Retro Lighting**: Simple lighting that matches PSX era

#### Scene Separation Strategy
- **Main Scene**: Player, NPCs, UI, interactions
- **Terrain Scene**: Terrain3D with PSX textures
- **PSX Assets Scene**: Scattered PSX models and vegetation
- **Benefits**: Better performance, authentic PSX aesthetic

### 6. Integration with Existing Systems

#### Player Controller
- Maintain existing movement system
- Add terrain height detection
- Keep interaction system intact
- PSX-style collision feedback

#### NPC System
- NPCs work on terrain surface
- Maintain interaction ranges
- Update pathfinding for terrain
- PSX-style NPC models (if available)

#### Audio System
- Terrain-aware audio (footsteps, ambient)
- Region-specific soundscapes
- PSX-style audio effects

#### UI System
- No changes needed
- Maintain existing radar and dialogue systems
- PSX-style UI elements (if desired)

### 7. PSX Asset Placement Rules

#### Papua (Jungle) Rules
- **Tree Density**: 20-30 trees per 100x100 area
- **Vegetation**: Dense grass and fern patches
- **Mushrooms**: Clusters near tree bases
- **Debris**: Scattered logs and stumps
- **Height Variation**: Trees at different heights for natural look

#### Tambora (Mountain) Rules
- **Tree Density**: 10-15 pine trees per 100x100 area
- **Stone Density**: 20-30 stones per 100x100 area
- **Vegetation**: Sparse grass patches
- **Elevation**: Trees and stones follow terrain height
- **Volcanic Features**: Stone clusters in crater areas

### 8. Testing Strategy

#### Unit Tests
- Test terrain loading/unloading
- Test PSX asset placement
- Test material creation
- Test navigation baking

#### Integration Tests
- Test player movement on PSX terrain
- Test NPC interactions on terrain
- Test scene transitions
- Test PSX asset performance

#### Performance Tests
- Monitor memory usage with PSX assets
- Test loading times
- Verify frame rates
- Test PSX asset LOD system

### 9. Documentation

#### Technical Documentation
- Terrain system architecture
- PSX asset integration guidelines
- Performance optimization tips
- PSX aesthetic guidelines

#### User Documentation
- How to create new terrain regions
- How to configure PSX assets
- How to add new PSX models
- How to maintain PSX aesthetic

## Next Steps

1. **Review and Approve Plan**
2. **Set up Terrain3D addon**
3. **Create PSX asset management system**
4. **Implement Papua terrain with PSX assets**
5. **Test and iterate**
6. **Implement Tambora terrain with PSX assets**
7. **Final testing and optimization**

## Success Criteria

- ✅ Terrain loads correctly for both regions
- ✅ PSX assets are properly placed and varied
- ✅ Player movement works smoothly on terrain
- ✅ NPCs and interactions function properly
- ✅ Performance meets requirements
- ✅ Code follows SOLID principles
- ✅ System is maintainable and extensible
- ✅ Authentic PSX aesthetic achieved
