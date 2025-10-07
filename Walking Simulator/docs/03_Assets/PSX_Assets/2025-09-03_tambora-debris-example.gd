# Tambora Debris Implementation Example
# This script demonstrates how to add textured debris to the Tambora volcanic scene

extends Node3D

# Debris material references
var wood_material: StandardMaterial3D
var stone_material: StandardMaterial3D

# Debris scene references
var log_scene: PackedScene
var stump_scene: PackedScene

# Material library for different debris types
var material_library: Dictionary = {}

func _ready():
    setup_debris_system()

func setup_debris_system():
    """Initialize the debris system with materials and models"""
    GameLogger.info("🌿 Setting up Tambora debris system...")
    
    # Create materials
    create_material_library()
    
    # Load debris models
    load_debris_models()
    
    # Place initial debris
    place_volcanic_debris()
    
    GameLogger.info("✅ Tambora debris system ready")

func create_material_library():
    """Create a library of materials for different debris types"""
    GameLogger.info("🎨 Creating debris material library...")
    
    # Wood materials for logs and stumps
    wood_material = create_wood_material("res://Assets/Terrain/Shared/textures/wood/tree_bark.png")
    material_library["wood"] = wood_material
    
    # Stone materials for volcanic debris
    stone_material = create_stone_material("res://Assets/Terrain/Shared/textures/stone/volcanic_rock.png")
    material_library["stone"] = stone_material
    
    # Fallback material if textures not found
    var fallback_material = create_fallback_material()
    material_library["fallback"] = fallback_material
    
    GameLogger.info("✅ Created %d materials" % material_library.size())

func create_wood_material(texture_path: String) -> StandardMaterial3D:
    """Create a specialized wood material for forest debris"""
    var material = StandardMaterial3D.new()
    
    # Try to load wood texture
    var texture = load(texture_path)
    if texture:
        material.albedo_texture = texture
        GameLogger.info("✅ Loaded wood texture: %s" % texture_path)
    else:
        # Create procedural wood material if texture not found
        material.albedo_color = Color(0.6, 0.4, 0.2, 1.0)  # Brown wood color
        GameLogger.warning("⚠️ Wood texture not found, using procedural color")
    
    # Wood-specific properties
    material.metallic = 0.0
    material.roughness = 0.9  # Wood is rough
    material.albedo_color = Color(0.6, 0.4, 0.2, 1.0)  # Brown wood tint
    
    # Enable subsurface scattering for wood (optional)
    material.subsurface_scattering_enabled = true
    material.subsurface_scattering_strength = 0.1
    
    return material

func create_stone_material(texture_path: String) -> StandardMaterial3D:
    """Create a specialized stone material for volcanic debris"""
    var material = StandardMaterial3D.new()
    
    # Try to load stone texture
    var texture = load(texture_path)
    if texture:
        material.albedo_texture = texture
        GameLogger.info("✅ Loaded stone texture: %s" % texture_path)
    else:
        # Create procedural stone material if texture not found
        material.albedo_color = Color(0.4, 0.4, 0.4, 1.0)  # Gray stone color
        GameLogger.warning("⚠️ Stone texture not found, using procedural color")
    
    # Stone-specific properties
    material.metallic = 0.1
    material.roughness = 0.8  # Stone is rough
    material.albedo_color = Color(0.4, 0.4, 0.4, 1.0)  # Gray stone tint
    
    return material

func create_fallback_material() -> StandardMaterial3D:
    """Create a fallback material when textures are not available"""
    var material = StandardMaterial3D.new()
    
    # Basic properties
    material.albedo_color = Color(0.5, 0.5, 0.5, 1.0)  # Neutral gray
    material.metallic = 0.0
    material.roughness = 0.7
    
    return material

func load_debris_models():
    """Load DAE debris models from the asset pack"""
    GameLogger.info("📦 Loading debris models...")
    
    # Load from asset pack
    var asset_pack = get_node_or_null("TamboraAssetPlacer")
    if asset_pack and asset_pack.has_meta("asset_pack"):
        var pack = asset_pack.get_meta("asset_pack")
        if pack.debris.size() > 0:
            GameLogger.info("✅ Found %d debris models in asset pack" % pack.debris.size())
            
            # Load each debris model
            for debris_path in pack.debris:
                var scene = load(debris_path)
                if scene:
                    GameLogger.info("✅ Loaded debris: %s" % debris_path)
                else:
                    GameLogger.warning("⚠️ Failed to load debris: %s" % debris_path)
        else:
            GameLogger.warning("⚠️ No debris models found in asset pack")
    else:
        GameLogger.error("❌ Asset pack not found")

func place_volcanic_debris():
    """Place debris around the volcanic Tambora scene"""
    GameLogger.info("🗿 Placing volcanic debris...")
    
    # Get asset pack
    var asset_pack = get_node_or_null("TamboraAssetPlacer")
    if not asset_pack or not asset_pack.has_meta("asset_pack"):
        GameLogger.error("❌ Asset pack not found for debris placement")
        return
    
    var pack = asset_pack.get_meta("asset_pack")
    if pack.debris.size() == 0:
        GameLogger.warning("⚠️ No debris models available")
        return
    
    # Place debris in volcanic zones
    place_debris_in_zone(Vector3(0, 0, 0), 50, pack.debris, "volcanic_center")
    place_debris_in_zone(Vector3(100, 0, 100), 30, pack.debris, "volcanic_rim")
    place_debris_in_zone(Vector3(-100, 0, -100), 25, pack.debris, "volcanic_slope")
    
    GameLogger.info("✅ Placed volcanic debris")

func place_debris_in_zone(center: Vector3, radius: float, debris_models: Array, zone_name: String):
    """Place debris in a specific zone with appropriate materials"""
    GameLogger.info("🗿 Placing debris in %s zone (radius: %d)" % [zone_name, radius])
    
    var debris_count = randi_range(5, 15)  # Random amount per zone
    
    for i in range(debris_count):
        # Random position within zone
        var angle = randf() * TAU
        var distance = randf() * radius
        var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
        
        # Random elevation variation
        pos.y = center.y + randf_range(-2, 2)
        
        # Random rotation
        var rotation = Vector3(0, randf() * TAU, 0)
        
        # Random scale
        var scale = Vector3.ONE * randf_range(0.8, 1.2)
        
        # Place debris
        place_single_debris(debris_models, pos, rotation, scale, zone_name)
    
    GameLogger.info("✅ Placed %d debris in %s zone" % [debris_count, zone_name])

func place_single_debris(debris_models: Array, position: Vector3, rotation: Vector3, scale: Vector3, zone_name: String):
    """Place a single piece of debris with appropriate material"""
    if debris_models.size() == 0:
        return
    
    # Randomly select debris model
    var debris_path = debris_models[randi() % debris_models.size()]
    var scene = load(debris_path)
    
    if not scene:
        GameLogger.warning("⚠️ Failed to load debris scene: %s" % debris_path)
        return
    
    # Instantiate debris
    var instance = scene.instantiate()
    instance.position = position
    instance.rotation = rotation
    instance.scale = scale
    
    # Apply appropriate material based on debris type
    apply_debris_material(instance, debris_path)
    
    # Name the instance
    instance.name = "%s_debris_%d" % [zone_name, get_child_count()]
    
    # Add to scene
    add_child(instance)
    
    GameLogger.debug("🗿 Placed debris: %s at %s" % [instance.name, position])

func apply_debris_material(debris_instance: Node3D, debris_path: String):
    """Apply appropriate material to debris based on its type"""
    var material: Material = null
    
    # Determine material type based on debris path
    if "logs" in debris_path or "stumps" in debris_path:
        material = material_library.get("wood", material_library.get("fallback"))
        GameLogger.debug("🌳 Applied wood material to %s" % debris_path)
    elif "stone" in debris_path or "rock" in debris_path:
        material = material_library.get("stone", material_library.get("fallback"))
        GameLogger.debug("🪨 Applied stone material to %s" % debris_path)
    else:
        material = material_library.get("fallback")
        GameLogger.debug("⚪ Applied fallback material to %s" % debris_path)
    
    # Apply material recursively to all mesh instances
    if material:
        apply_material_recursively(debris_instance, material)

func apply_material_recursively(node: Node3D, material: Material):
    """Apply material to all MeshInstance3D nodes recursively"""
    if node is MeshInstance3D:
        node.material_override = material
    
    # Apply to children
    for child in node.get_children():
        if child is Node3D:
            apply_material_recursively(child, material)

func create_custom_wood_texture():
    """Create a procedural wood texture if no texture file is available"""
    var image = Image.new()
    image.create(256, 256, false, Image.FORMAT_RGBA8)
    
    # Generate wood grain pattern
    for x in range(256):
        for y in range(256):
            var noise = OpenSimplexNoise.new()
            noise.seed = 42
            noise.octaves = 4
            noise.period = 50.0
            
            var noise_value = noise.get_noise_2d(x, y)
            var wood_grain = sin(x * 0.1 + noise_value * 0.5) * 0.3 + 0.7
            
            # Wood color with grain variation
            var color = Color(
                0.6 * wood_grain,  # Red channel
                0.4 * wood_grain,  # Green channel
                0.2 * wood_grain,  # Blue channel
                1.0                 # Alpha
            )
            
            image.set_pixel(x, y, color)
    
    # Create texture from image
    var texture = ImageTexture.create_from_image(image)
    return texture

func get_debris_statistics() -> Dictionary:
    """Get statistics about placed debris"""
    var stats = {
        "total_debris": 0,
        "wood_debris": 0,
        "stone_debris": 0,
        "zones": {}
    }
    
    for child in get_children():
        if "debris" in child.name.to_lower():
            stats.total_debris += 1
            
            if "wood" in child.name.to_lower() or "log" in child.name.to_lower() or "stump" in child.name.to_lower():
                stats.wood_debris += 1
            elif "stone" in child.name.to_lower() or "rock" in child.name.to_lower():
                stats.stone_debris += 1
            
            # Count by zone
            var zone_name = child.name.split("_")[0]
            if not stats.zones.has(zone_name):
                stats.zones[zone_name] = 0
            stats.zones[zone_name] += 1
    
    return stats

func clear_all_debris():
    """Remove all placed debris from the scene"""
    GameLogger.info("🧹 Clearing all debris...")
    
    var debris_to_remove: Array[Node] = []
    
    for child in get_children():
        if "debris" in child.name.to_lower():
            debris_to_remove.append(child)
    
    for debris in debris_to_remove:
        debris.queue_free()
    
    GameLogger.info("✅ Cleared %d debris objects" % debris_to_remove.size())

# Input handling for testing
func _input(event):
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_D:
                place_volcanic_debris()
            KEY_C:
                clear_all_debris()
            KEY_S:
                var stats = get_debris_statistics()
                GameLogger.info("📊 Debris Statistics: %s" % str(stats))
            KEY_M:
                GameLogger.info("🎨 Material Library: %s" % str(material_library.keys()))
