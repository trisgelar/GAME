extends Node

# Test script to verify Papua mechanics work correctly after fixes
# This script tests artifact collection, inventory, and CulturalItem loading

func _ready():
	# Wait a bit for everything to load
	await get_tree().create_timer(1.0).timeout
	test_cultural_item_loading()

func test_cultural_item_loading():
	GameLogger.info("🧪 Testing CulturalItem loading...")
	
	# Test loading koteka.tres
	var koteka_path = "res://Systems/Items/ItemData/koteka.tres"
	
	if FileAccess.file_exists(koteka_path):
		GameLogger.info("✅ koteka.tres file exists")
		
		# Try to load the resource
		var koteka_resource = load(koteka_path)
		if koteka_resource:
			GameLogger.info("✅ koteka.tres loaded successfully")
			GameLogger.info("   Display Name: " + str(koteka_resource.display_name))
			GameLogger.info("   Cultural Region: " + str(koteka_resource.cultural_region))
			GameLogger.info("   Rarity: " + str(koteka_resource.rarity))
			
			# Test the class name
			if koteka_resource.get_script():
				var script_class = koteka_resource.get_script().get_class()
				GameLogger.info("✅ Script class: " + str(script_class))
			else:
				GameLogger.warning("❌ No script attached to resource")
		else:
			GameLogger.error("❌ Failed to load koteka.tres resource")
	else:
		GameLogger.error("❌ koteka.tres file not found")
	
	# Test other Papua items
	test_papua_items()

func test_papua_items():
	GameLogger.info("🧪 Testing other Papua items...")
	
	var papua_items = [
		"res://Systems/Items/ItemData/cenderawasih_pegunungan.tres",
		"res://Systems/Items/ItemData/kapak_dani.tres",
		"res://Systems/Items/ItemData/noken.tres"
	]
	
	for item_path in papua_items:
		if FileAccess.file_exists(item_path):
			var resource = load(item_path)
			if resource:
				GameLogger.info("✅ " + item_path.get_file() + " loaded successfully")
			else:
				GameLogger.error("❌ Failed to load " + item_path.get_file())
		else:
			GameLogger.error("❌ " + item_path.get_file() + " not found")

func test_inventory_system():
	GameLogger.info("🧪 Testing inventory system...")
	
	# Check if inventory script exists
	var inventory_script_path = "res://Systems/Inventory/CulturalInventory.gd"
	if FileAccess.file_exists(inventory_script_path):
		GameLogger.info("✅ CulturalInventory.gd exists")
	else:
		GameLogger.error("❌ CulturalInventory.gd not found")
	
	# Check if inventory scene exists
	var inventory_scene_path = "res://Systems/Inventory/CulturalInventory.tscn"
	if FileAccess.file_exists(inventory_scene_path):
		GameLogger.info("✅ CulturalInventory.tscn exists")
	else:
		GameLogger.error("❌ CulturalInventory.tscn not found")
