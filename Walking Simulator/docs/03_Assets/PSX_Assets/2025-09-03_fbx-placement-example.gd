# FBX Asset Placement Example Script
# Date: 2025-09-03
# Usage: Copy this script and adapt it for your FBX asset placement needs

extends Node3D

# Asset placement system for FBX models with atlas textures
class_name FBXAssetPlacer

# Configuration
var asset_placer: Node3D
var fbx_asset_pack: Resource
var atlas_material: StandardMaterial3D

# Placement settings
var placement_density = {
	"trees": 0.8,      # 80% chance to place in each spot
	"vegetation": 0.6,  # 60% chance to place in each spot
	"mushrooms": 0.4,   # 40% chance to place in each spot
	"stones": 0.3       # 30% chance to place in each spot
}

var scale_ranges = {
	"trees": Vector2(0.8, 1.3),
	"vegetation": Vector2(0.6, 1.2),
	"mushrooms": Vector2(0.4, 0.8),
	"stones": Vector2(0.7, 1.1)
}

func _ready():
	GameLogger.info("🌿 FBX Asset Placer Initializing...")
	setup_fbx_system()

func setup_fbx_system():
	"""Setup FBX asset system with atlas textures"""
	
	# Load FBX asset pack
	fbx_asset_pack = load("res://Assets/Terrain/Papua/psx_assets_fbx.tres")
	if not fbx_asset_pack:
		GameLogger.error("❌ Failed to load FBX asset pack")
		return
	
	# Create asset placer node
	asset_placer = Node3D.new()
	asset_placer.name = "FBXAssetPlacer"
	add_child(asset_placer)
	
	# Store asset pack reference
	asset_placer.set_meta("asset_pack", fbx_asset_pack)
	
	# Setup atlas material
	setup_atlas_material()
	
	GameLogger.info("✅ FBX asset system ready")

func setup_atlas_material():
	"""Setup the atlas material for FBX models"""
	
	# Create new material
	atlas_material = StandardMaterial3D.new()
	
	# Load atlas texture
	var atlas_texture = load("res://Assets/PSX/PSX Forest/Textures/Forest_Pack_Atlas_1.tga")
	if atlas_texture:
		atlas_material.albedo_texture = atlas_texture
		GameLogger.info("✅ Loaded atlas texture: Forest_Pack_Atlas_1.tga")
	else:
		GameLogger.warning("⚠️ Could not load atlas texture")
	
	# Configure material properties
	atlas_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	atlas_material.alpha_scissor_threshold = 0.3
	atlas_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	atlas_material.metallic = 0.0
	atlas_material.roughness = 0.7
	
	# Save material for reuse
	var material_path = "res://Assets/Terrain/Shared/materials/forest_atlas_material.tres"
	var dir = DirAccess.open("res://Assets/Terrain/Shared/materials/")
	if not dir:
		dir.make_dir_recursive("res://Assets/Terrain/Shared/materials/")
	
	var save_result = ResourceSaver.save(atlas_material, material_path)
	if save_result == OK:
		GameLogger.info("✅ Saved atlas material: " + material_path)
	else:
		GameLogger.error("❌ Failed to save atlas material")

func place_fbx_assets_random(center: Vector3, radius: float, asset_type: String, count: int = 20):
	"""Place FBX assets randomly in a circular area"""
	
	if not asset_placer or not fbx_asset_pack:
		GameLogger.error("❌ Asset system not initialized")
		return
	
	var assets = []
	
	# Get appropriate asset list
	match asset_type:
		"trees":
			assets = fbx_asset_pack.trees
		"vegetation":
			assets = fbx_asset_pack.vegetation
		"mushrooms":
			assets = fbx_asset_pack.mushrooms
		"stones":
			assets = fbx_asset_pack.stones
		_:
			GameLogger.warning("⚠️ Unknown asset type: " + asset_type)
			return
	
	if assets.size() == 0:
		GameLogger.warning("⚠️ No %s assets available" % asset_type)
		return
	
	GameLogger.info("🎯 Placing %d %s assets in radius %.1f" % [count, asset_type, radius])
	
	var placed_count = 0
	var attempts = 0
	var max_attempts = count * 3  # Prevent infinite loops
	
	# Place assets randomly
	while placed_count < count and attempts < max_attempts:
		attempts += 1
		
		var angle = randf() * TAU
		var distance = randf() * radius
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		pos.y = center.y + randf_range(-1, 2)
		
		# Check density probability
		var density = placement_density.get(asset_type, 0.5)
		if randf() > density:
			continue
		
		# Randomly select asset
		var asset_path = assets[randi() % assets.size()]
		
		# Check if position is too close to existing assets
		if is_position_occupied(pos, 2.0):
			continue
		
		# Instantiate TSCN
		var asset_scene = load(asset_path)
		if asset_scene:
			var instance = asset_scene.instantiate()
			instance.position = pos
			instance.rotation.y = randf() * TAU
			
			# Apply scale based on asset type
			var scale_range = scale_ranges.get(asset_type, Vector2(0.7, 1.1))
			instance.scale = Vector3.ONE * randf_range(scale_range.x, scale_range.y)
			
			# Apply atlas material
			apply_atlas_material_to_instance(instance)
			
			instance.name = "%s_%s_%d" % [asset_type, asset_path.get_file().replace(".tscn", ""), placed_count]
			
			asset_placer.add_child(instance)
			placed_count += 1
	
	GameLogger.info("✅ Placed %d/%d %s assets (%d attempts)" % [placed_count, count, asset_type, attempts])

func apply_atlas_material_to_instance(instance: Node3D):
	"""Apply atlas material to all mesh instances in the scene"""
	
	if not atlas_material:
		return
	
	var stack: Array[Node] = [instance]
	
	while stack.size() > 0:
		var node = stack.pop_back()
		
		# Apply material to MeshInstance3D
		if node is MeshInstance3D:
			var mesh_instance = node as MeshInstance3D
			mesh_instance.material_override = atlas_material
		
		# Add children to stack
		for child in node.get_children():
			stack.append(child)

func is_position_occupied(pos: Vector3, min_distance: float) -> bool:
	"""Check if a position is too close to existing assets"""
	
	if not asset_placer:
		return false
	
	for child in asset_placer.get_children():
		if child is Node3D:
			var distance = pos.distance_to(child.global_position)
			if distance < min_distance:
				return true
	
	return false

func create_forest_zone(center: Vector3, radius: float, zone_type: String):
	"""Create a specific type of forest zone with FBX assets"""
	
	GameLogger.info("🌲 Creating %s forest zone at %s (radius: %.1f)" % [zone_type, center, radius])
	
	match zone_type:
		"dense":
			place_fbx_assets_random(center, radius, "trees", 40)
			place_fbx_assets_random(center, radius, "vegetation", 60)
		"riverine":
			place_fbx_assets_random(center, radius, "vegetation", 50)
			place_fbx_assets_random(center, radius, "mushrooms", 20)
		"highland":
			place_fbx_assets_random(center, radius, "trees", 30)
			place_fbx_assets_random(center, radius, "stones", 25)
		"clearing":
			place_fbx_assets_random(center, radius, "vegetation", 30)
			place_fbx_assets_random(center, radius, "mushrooms", 15)
		_:
			GameLogger.warning("⚠️ Unknown zone type: " + zone_type)
	
	GameLogger.info("✅ Created %s forest zone" % zone_type)

func create_complete_forest_scene():
	"""Create a complete forest scene with multiple zones"""
	
	GameLogger.info("🌴 Creating complete forest scene with FBX assets...")
	
	# Create different forest zones
	create_forest_zone(Vector3(0, 5, 0), 80, "dense")
	create_forest_zone(Vector3(200, 2, 0), 60, "riverine")
	create_forest_zone(Vector3(0, 40, -200), 70, "highland")
	create_forest_zone(Vector3(-200, 10, 0), 50, "clearing")
	
	GameLogger.info("✅ Complete forest scene created!")

func clear_all_assets():
	"""Clear all placed FBX assets"""
	
	if not asset_placer:
		return
	
	var count = asset_placer.get_child_count()
	
	for child in asset_placer.get_children():
		child.queue_free()
	
	GameLogger.info("🧹 Cleared %d FBX assets" % count)

func get_asset_statistics() -> Dictionary:
	"""Get statistics about placed assets"""
	
	if not asset_placer:
		return {}
	
	var stats = {
		"total": 0,
		"by_type": {},
		"by_model": {}
	}
	
	for child in asset_placer.get_children():
		if child is Node3D:
			stats.total += 1
			
			# Count by type
			var asset_type = "unknown"
			for type in ["trees", "vegetation", "mushrooms", "stones"]:
				if type in child.name.to_lower():
					asset_type = type
					break
			
			stats.by_type[asset_type] = stats.by_type.get(asset_type, 0) + 1
			
			# Count by model
			var model_name = child.name.split("_")[1] if "_" in child.name else "unknown"
			stats.by_model[model_name] = stats.by_model.get(model_name, 0) + 1
	
	return stats

func debug_atlas_usage():
	"""Debug atlas texture and asset usage"""
	
	GameLogger.info("🔍 FBX Atlas Debug Information:")
	GameLogger.info("   Atlas Material: %s" % ("✅ Loaded" if atlas_material else "❌ Not loaded"))
	GameLogger.info("   Asset Pack: %s" % (fbx_asset_pack.region_name if fbx_asset_pack else "❌ Not loaded"))
	
	if fbx_asset_pack:
		for category in ["trees", "vegetation", "mushrooms", "stones"]:
			var assets = fbx_asset_pack.get(category)
			GameLogger.info("   %s: %d assets" % [category, assets.size()])
	
	var stats = get_asset_statistics()
	GameLogger.info("   Placed Assets: %d total" % stats.get("total", 0))
	
	for type_name in stats.get("by_type", {}):
		var count = stats.by_type[type_name]
		GameLogger.info("     %s: %d" % [type_name, count])

# Input handling for testing
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				create_forest_zone(Vector3(0, 5, 0), 50, "dense")
			KEY_2:
				create_forest_zone(Vector3(100, 5, 0), 40, "riverine")
			KEY_3:
				create_forest_zone(Vector3(-100, 5, 0), 45, "highland")
			KEY_4:
				create_forest_zone(Vector3(0, 5, 100), 35, "clearing")
			KEY_5:
				create_complete_forest_scene()
			KEY_C:
				clear_all_assets()
			KEY_D:
				debug_atlas_usage()
			KEY_S:
				var stats = get_asset_statistics()
				GameLogger.info("📊 Asset Statistics: %s" % str(stats))
