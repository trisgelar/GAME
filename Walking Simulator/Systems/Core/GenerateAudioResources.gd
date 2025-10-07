extends Node

# Script to generate missing .tres audio resource files
# Run this script to create all missing AudioResource .tres files

func _ready():
	generate_missing_audio_resources()

func generate_missing_audio_resources():
	GameLogger.info("Generating missing audio resource files...")
	
	# Create directory structure
	create_audio_directories()
	
	# Generate ambient audio resources
	generate_ambient_resources()
	
	# Generate menu audio resources  
	generate_menu_resources()
	
	# Generate player action resources
	generate_player_action_resources()
	
	# Generate footstep resources
	generate_footstep_resources()
	
	# Generate UI audio resources
	generate_ui_resources()
	
	# Generate effects resources
	generate_effects_resources()
	
	GameLogger.info("Audio resource generation complete!")

func create_audio_directories():
	var base_path = "res://Resources/Audio/"
	var dirs = ["Ambient", "Menu", "Player", "Player/Actions", "Player/Footsteps", "UI", "Effects"]
	
	for dir in dirs:
		var full_path = base_path + dir
		if not DirAccess.dir_exists_absolute(full_path):
			DirAccess.open("res://").make_dir_recursive(full_path)
			GameLogger.info("Created directory: " + full_path)

func generate_ambient_resources():
	var ambient_files = [
		{"name": "JungleSounds", "path": "res://Assets/Audio/Ambient/jungle_sounds.ogg", "volume": -8.0},
		{"name": "MarketAmbience", "path": "res://Assets/Audio/Ambient/market_ambience.ogg", "volume": -6.0},
		{"name": "MountainWind", "path": "res://Assets/Audio/Ambient/mountain_wind.ogg", "volume": -10.0}
	]
	
	for file in ambient_files:
		create_audio_resource("Ambient/" + file.name + ".tres", file.path, file.volume, true, "Ambient sound: " + file.name)

func generate_menu_resources():
	var menu_files = [
		{"name": "MenuClose", "path": "res://Assets/Audio/Menu/menu_close.ogg", "volume": -5.0},
		{"name": "MenuOpen", "path": "res://Assets/Audio/Menu/menu_open.ogg", "volume": -5.0},
		{"name": "RegionSelect", "path": "res://Assets/Audio/Menu/region_select.ogg", "volume": -4.0},
		{"name": "StartGame", "path": "res://Assets/Audio/Menu/start_game.ogg", "volume": -3.0},
		{"name": "UIClick", "path": "res://Assets/Audio/Menu/ui_click.ogg", "volume": -3.0}
	]
	
	for file in menu_files:
		create_audio_resource("Menu/" + file.name + ".tres", file.path, file.volume, false, "Menu sound: " + file.name)

func generate_player_action_resources():
	var action_files = [
		{"name": "Jump", "path": "res://Assets/Audio/Player/Actions/jump.ogg", "volume": -4.0},
		{"name": "Land", "path": "res://Assets/Audio/Player/Actions/land.ogg", "volume": -6.0},
		{"name": "RunStart", "path": "res://Assets/Audio/Player/Actions/run_start.ogg", "volume": -5.0},
		{"name": "RunStop", "path": "res://Assets/Audio/Player/Actions/run_stop.ogg", "volume": -5.0}
	]
	
	for file in action_files:
		create_audio_resource("Player/Actions/" + file.name + ".tres", file.path, file.volume, false, "Player action: " + file.name)

func generate_footstep_resources():
	var surfaces = ["dirt", "grass", "stone", "water", "wood"]
	
	for surface in surfaces:
		for i in range(1, 4):  # 3 variations per surface
			var name = "Footstep" + surface.capitalize() + str(i)
			var path = "res://Assets/Audio/Player/Footsteps/footstep_" + surface + "_" + str(i) + ".ogg"
			var volume = -8.0 if surface == "water" else -6.0
			
			create_audio_resource("Player/Footsteps/" + name + ".tres", path, volume, false, "Footstep: " + surface + " " + str(i))

func generate_ui_resources():
	var ui_files = [
		{"name": "Error", "path": "res://Assets/Audio/UI/error.ogg", "volume": -2.0},
		{"name": "InventoryClose", "path": "res://Assets/Audio/UI/inventory_close.ogg", "volume": -4.0},
		{"name": "InventoryOpen", "path": "res://Assets/Audio/UI/inventory_open.ogg", "volume": -4.0},
		{"name": "ItemHover", "path": "res://Assets/Audio/UI/item_hover.ogg", "volume": -6.0},
		{"name": "ItemSelect", "path": "res://Assets/Audio/UI/item_select.ogg", "volume": -3.0},
		{"name": "Notification", "path": "res://Assets/Audio/UI/notification.ogg", "volume": -2.0}
	]
	
	for file in ui_files:
		create_audio_resource("UI/" + file.name + ".tres", file.path, file.volume, false, "UI sound: " + file.name)

func generate_effects_resources():
	var effect_files = [
		{"name": "CollectionChime", "path": "res://Assets/Audio/Effects/collection_chime.ogg", "volume": -3.0},
		{"name": "CulturalNarration", "path": "res://Assets/Audio/Effects/cultural_narration.ogg", "volume": -4.0},
		{"name": "NPCHello", "path": "res://Assets/Audio/Effects/npc_hello.ogg", "volume": -5.0},
		{"name": "TransitionSound", "path": "res://Assets/Audio/Effects/transition_sound.ogg", "volume": -6.0}
	]
	
	for file in effect_files:
		create_audio_resource("Effects/" + file.name + ".tres", file.path, file.volume, false, "Effect: " + file.name)

func create_audio_resource(resource_path: String, audio_path: String, volume_db: float, loop: bool, description: String):
	var full_path = "res://Resources/Audio/" + resource_path
	
	# Skip if file already exists
	if ResourceLoader.exists(full_path):
		GameLogger.info("Skipping existing: " + resource_path)
		return
	
	# Create AudioResource
	var audio_resource = AudioResource.new()
	audio_resource.volume_db = volume_db
	audio_resource.loop = loop
	audio_resource.description = description
	
	# Load audio stream if it exists
	if ResourceLoader.exists(audio_path):
		audio_resource.audio_stream = load(audio_path)
		GameLogger.info("Created: " + resource_path + " -> " + audio_path)
	else:
		GameLogger.warning("Audio file not found: " + audio_path + " (creating placeholder)")
	
	# Save the resource
	var result = ResourceSaver.save(audio_resource, full_path)
	if result != OK:
		GameLogger.error("Failed to save: " + resource_path + " (Error: " + str(result) + ")")
