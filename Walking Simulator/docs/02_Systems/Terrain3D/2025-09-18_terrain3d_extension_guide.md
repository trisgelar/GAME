# Terrain3D Extension Guide

**Date:** 2025-09-18  
**Status:** Completed  
**Scope:** How to Extend the Terrain3D System  

## 🎯 **Extension Scenarios**

This guide covers how to extend the Terrain3D system for new regions, features, and functionality while maintaining SOLID principles.

## 🌍 **Adding New Regions**

### **Scenario: Adding Tambora Region**

#### **Step 1: Create Concrete Controller**
```gdscript
# Systems/Terrain3D/Core/Terrain3DTamboraController.gd
extends Terrain3DBaseController
class_name Terrain3DTamboraController

func _get_terrain_type() -> String:
    return "TAMBORA"

func _get_asset_pack_path() -> String:
    return "res://Assets/Terrain/Tambora/psx_assets.tres"

# Tambora-specific implementations (if needed)
func _setup_tambora_specific_features():
    GameLogger.info("🌋 Setting up Tambora-specific features...")
    # Tambora-specific terrain features
    # e.g., volcanic terrain, ash effects, etc.
```

#### **Step 2: Update Factory**
```gdscript
# Systems/Terrain3D/Core/Terrain3DControllerFactory.gd
enum TerrainType { 
    PAPUA, 
    TAMBORA  # Add new terrain type
}

static func create_controller(terrain_type: TerrainType) -> Terrain3DBaseController:
    match terrain_type:
        TerrainType.PAPUA:
            return Terrain3DPapuaController.new()
        TerrainType.TAMBORA:
            return Terrain3DTamboraController.new()  # Add case
        _:
            push_error("Unknown terrain type: " + str(terrain_type))
            return null
```

#### **Step 3: Create Scene**
```gdscript
# Scenes/IndonesiaTimur/TamboraScene_Terrain3D.tscn
[ext_resource path="res://Systems/Terrain3D/Core/Terrain3DController.gd" id="1_terrain_controller"]

[node name="TamboraScene" type="Node3D"]
[node name="TerrainController" type="Node3D" parent="."]
script = ExtResource("1_terrain_controller")
terrain_type = 1  # TerrainType.TAMBORA

[node name="Player" type="CharacterBody3D" parent="."]
# Player setup...

[node name="Terrain3DManager" type="Node3D" parent="."]
[node name="Terrain3D" type="Terrain3D" parent="Terrain3DManager"]
# Terrain3D setup...
```

#### **Step 4: Generate UID Files**
```bash
# Godot will automatically generate UID files when you save
Systems/Terrain3D/Core/Terrain3DTamboraController.gd.uid
```

### **Scenario: Adding Multiple Regions**

#### **Factory Pattern for Multiple Regions**
```gdscript
# Systems/Terrain3D/Core/Terrain3DControllerFactory.gd
enum TerrainType { 
    PAPUA, 
    TAMBORA,
    BOROBUDUR,
    KOMODO,
    RAJA_AMPAT
}

static func create_controller(terrain_type: TerrainType) -> Terrain3DBaseController:
    match terrain_type:
        TerrainType.PAPUA:
            return Terrain3DPapuaController.new()
        TerrainType.TAMBORA:
            return Terrain3DTamboraController.new()
        TerrainType.BOROBUDUR:
            return Terrain3DBorobudurController.new()
        TerrainType.KOMODO:
            return Terrain3DKomodoController.new()
        TerrainType.RAJA_AMPAT:
            return Terrain3DRajaAmpatController.new()
        _:
            push_error("Unknown terrain type: " + str(terrain_type))
            return null
```

## 🔧 **Adding New Features**

### **Scenario: Adding Weather System**

#### **Step 1: Extend Base Controller**
```gdscript
# Systems/Terrain3D/Core/Terrain3DBaseController.gd
# Add weather system to base controller

var weather_system: Node3D

func _setup_weather_system():
    """Setup weather system - can be overridden by concrete classes"""
    GameLogger.info("🌤️ Setting up weather system...")
    weather_system = Node3D.new()
    weather_system.name = "WeatherSystem"
    add_child(weather_system)

func apply_weather_effects(weather_type: String):
    """Apply weather effects - default implementation"""
    GameLogger.info("🌤️ Applying weather effects: %s" % weather_type)
    # Default weather implementation
```

#### **Step 2: Implement in Concrete Classes**
```gdscript
# Systems/Terrain3D/Core/Terrain3DPapuaController.gd
func _setup_weather_system():
    """Papua-specific weather system"""
    super._setup_weather_system()  # Call base implementation
    GameLogger.info("🌴 Setting up tropical weather for Papua...")
    # Papua-specific weather features

func apply_weather_effects(weather_type: String):
    """Papua-specific weather effects"""
    match weather_type:
        "tropical_storm":
            _apply_tropical_storm_effects()
        "monsoon":
            _apply_monsoon_effects()
        _:
            super.apply_weather_effects(weather_type)  # Fallback to base

func _apply_tropical_storm_effects():
    GameLogger.info("⛈️ Applying tropical storm effects...")
    # Implementation specific to Papua
```

#### **Step 3: Add to Facade**
```gdscript
# Systems/Terrain3D/Core/Terrain3DController.gd
func apply_weather_effects(weather_type: String):
    """Apply weather effects - facade method"""
    if terrain_controller:
        terrain_controller.apply_weather_effects(weather_type)
    else:
        GameLogger.error("❌ No terrain controller available for weather effects")
```

### **Scenario: Adding Asset Placement System**

#### **Step 1: Create Asset Placement Interface**
```gdscript
# Systems/Terrain3D/Core/Terrain3DAssetPlacer.gd
class_name Terrain3DAssetPlacer
extends Node3D

signal asset_placed(asset: Node3D, position: Vector3)

func place_asset(asset_path: String, position: Vector3) -> Node3D:
    """Place an asset at the specified position"""
    var asset_scene = load(asset_path)
    if not asset_scene:
        GameLogger.error("❌ Failed to load asset: %s" % asset_path)
        return null
    
    var asset_instance = asset_scene.instantiate()
    add_child(asset_instance)
    asset_instance.global_position = position
    
    emit_signal("asset_placed", asset_instance, position)
    return asset_instance
```

#### **Step 2: Integrate with Base Controller**
```gdscript
# Systems/Terrain3D/Core/Terrain3DBaseController.gd
var asset_placer: Terrain3DAssetPlacer

func _setup_asset_placer():
    """Setup asset placement system"""
    asset_placer = Terrain3DAssetPlacer.new()
    asset_placer.name = "AssetPlacer"
    add_child(asset_placer)
    
    # Connect signals
    asset_placer.asset_placed.connect(_on_asset_placed)

func _on_asset_placed(asset: Node3D, position: Vector3):
    """Handle asset placement events"""
    GameLogger.info("📍 Asset placed: %s at %s" % [asset.name, position])
```

## 🎮 **Adding New Input Controls**

### **Scenario: Adding Terrain Editing Controls**

#### **Step 1: Add Input Handling**
```gdscript
# Systems/Terrain3D/Core/Terrain3DController.gd
func _input(event):
    if event is InputEventKey and event.pressed:
        match event.keycode:
            # Existing keys...
            KEY_G:
                # Generate custom terrain
                GameLogger.info("🎨 KEY_G pressed - Generating custom terrain...")
                generate_custom_terrain()
            KEY_V:
                # Toggle vegetation density
                GameLogger.info("🌿 KEY_V pressed - Toggling vegetation density...")
                toggle_vegetation_density()
```

#### **Step 2: Implement in Base Controller**
```gdscript
# Systems/Terrain3D/Core/Terrain3DBaseController.gd
func generate_custom_terrain():
    """Generate custom terrain - override in concrete classes"""
    GameLogger.info("🎨 [%s] Generating custom terrain..." % _get_terrain_type())
    # Default implementation - can be overridden

func toggle_vegetation_density():
    """Toggle vegetation density - override in concrete classes"""
    GameLogger.info("🌿 [%s] Toggling vegetation density..." % _get_terrain_type())
    # Default implementation - can be overridden
```

#### **Step 3: Implement in Concrete Classes**
```gdscript
# Systems/Terrain3D/Core/Terrain3DPapuaController.gd
func generate_custom_terrain():
    """Papua-specific custom terrain generation"""
    super.generate_custom_terrain()
    GameLogger.info("🌴 Generating Papua-specific custom terrain...")
    # Papua-specific implementation

func toggle_vegetation_density():
    """Papua-specific vegetation density toggle"""
    super.toggle_vegetation_density()
    GameLogger.info("🌴 Toggling Papua tropical vegetation density...")
    # Papua-specific implementation
```

## 🔬 **Adding Research Features**

### **Scenario: Adding Experimental Terrain Generation**

#### **Step 1: Add to Research Module**
```gdscript
# Systems/Terrain3D/Research/Terrain3DResearch.gd
func generate_procedural_mountains(terrain_controller: Node, count: int = 5):
    """Generate procedural mountains - RESEARCH FUNCTION"""
    GameLogger.info("🏔️ [RESEARCH] Generating %d procedural mountains..." % count)
    
    for i in range(count):
        var mountain = create_procedural_mountain(i)
        terrain_controller.add_child(mountain)
    
    GameLogger.info("✅ [RESEARCH] Generated %d procedural mountains" % count)

func create_procedural_mountain(index: int) -> Node3D:
    """Create a single procedural mountain - RESEARCH FUNCTION"""
    var mountain = MeshInstance3D.new()
    # Procedural mountain generation code...
    return mountain
```

#### **Step 2: Add Input for Research**
```gdscript
# Systems/Terrain3D/Research/Terrain3DResearch.gd
func _input(event):
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_M:
                # Generate procedural mountains
                var terrain_controller = get_node_or_null("../../TerrainController")
                if terrain_controller:
                    generate_procedural_mountains(terrain_controller)
```

## 🧪 **Testing Extensions**

### **Unit Testing New Features**
```gdscript
# Tests/Terrain3D/Terrain3DTamboraControllerTest.gd
extends GutTest

var tambora_controller: Terrain3DTamboraController

func before_each():
    tambora_controller = Terrain3DTamboraController.new()

func test_terrain_type():
    assert_eq(tambora_controller._get_terrain_type(), "TAMBORA")

func test_asset_pack_path():
    assert_true(tambora_controller._get_asset_pack_path().ends_with("tambora/psx_assets.tres"))

func test_weather_system():
    tambora_controller._setup_weather_system()
    assert_not_null(tambora_controller.weather_system)
```

### **Integration Testing**
```gdscript
# Tests/Terrain3D/Terrain3DSystemIntegrationTest.gd
extends GutTest

func test_factory_creates_correct_controller():
    var controller = Terrain3DControllerFactory.create_controller(Terrain3DControllerFactory.TerrainType.TAMBORA)
    assert_not_null(controller)
    assert_true(controller is Terrain3DTamboraController)
    assert_eq(controller._get_terrain_type(), "TAMBORA")
```

## 📋 **Extension Checklist**

### **Before Adding New Features**
- [ ] Identify which SOLID principle applies
- [ ] Determine if it belongs in Core, Tools, or Research
- [ ] Plan the interface and dependencies
- [ ] Consider backward compatibility

### **During Implementation**
- [ ] Follow naming conventions
- [ ] Add comprehensive logging
- [ ] Handle error cases
- [ ] Write unit tests
- [ ] Update documentation

### **After Implementation**
- [ ] Test all existing functionality
- [ ] Update scene references if needed
- [ ] Generate UID files
- [ ] Update factory if adding new types
- [ ] Document the new feature

## 🚨 **Common Pitfalls**

### **❌ Don't Do This**
```gdscript
# BAD: Putting region-specific code in base controller
func _setup_terrain_system():
    if _get_terrain_type() == "PAPUA":
        # Papua-specific code here - WRONG!
        setup_papua_forests()
```

### **✅ Do This Instead**
```gdscript
# GOOD: Override in concrete class
# Terrain3DPapuaController.gd
func _setup_terrain_system():
    super._setup_terrain_system()  # Call base implementation
    setup_papua_forests()  # Add Papua-specific code
```

### **❌ Don't Break SOLID Principles**
```gdscript
# BAD: Adding UI code to base controller
func _setup_terrain_system():
    var button = Button.new()  # UI code in business logic - WRONG!
    add_child(button)
```

### **✅ Keep Concerns Separated**
```gdscript
# GOOD: UI code in facade controller
# Terrain3DController.gd (Facade)
func _setup_ui_connections():
    var button = Button.new()  # UI code in facade - CORRECT!
    add_child(button)
```

## 📚 **Extension Examples**

### **Complete Tambora Implementation**
See the complete example in the next section for a full Tambora region implementation.

### **Weather System Extension**
See the weather system example for adding cross-cutting concerns.

### **Asset Placement System**
See the asset placement example for adding new subsystems.

---

**Next:** [Migration Checklist](2025-09-18_terrain3d_migration_checklist.md)
