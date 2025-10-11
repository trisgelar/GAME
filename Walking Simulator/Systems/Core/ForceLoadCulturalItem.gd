extends Node

# Force load CulturalItem class to ensure it's available for resources
# This script ensures CulturalItem is loaded before any resources try to use it

func _ready():
	# Force load the CulturalItem script
	var cultural_item_script = preload("res://Systems/Items/CulturalItem.gd")
	GameLogger.info("ForceLoadCulturalItem: CulturalItem class loaded successfully")
	
	# Verify the class is available
	if cultural_item_script:
		GameLogger.info("ForceLoadCulturalItem: CulturalItem script verified")
	else:
		GameLogger.warning("ForceLoadCulturalItem: Failed to load CulturalItem script")
