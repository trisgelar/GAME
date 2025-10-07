class_name AudioConfig
extends Resource

# Audio Configuration Resource
# This resource manages all audio settings and file mappings

@export var master_volume: float = 0.8
@export var ambient_volume: float = 0.6
@export var music_volume: float = 0.7
@export var effects_volume: float = 0.8
@export var voice_volume: float = 0.8
@export var footsteps_volume: float = 0.5
@export var menu_volume: float = 0.6
@export var ui_volume: float = 0.8

# Audio file mappings - organized by category
@export var ambient_audio: Dictionary = {
	"jungle_sounds": "res://Assets/Audio/Ambient/jungle_sounds.ogg",
	"market_ambience": "res://Assets/Audio/Ambient/market_ambience.ogg", 
	"mountain_wind": "res://Assets/Audio/Ambient/mountain_wind.ogg"
}

@export var menu_audio: Dictionary = {
	"menu_close": "res://Assets/Audio/Menu/menu_close.ogg",
	"menu_open": "res://Assets/Audio/Menu/menu_open.ogg",
	"region_select": "res://Assets/Audio/Menu/region_select.ogg",
	"start_game": "res://Assets/Audio/Menu/start_game.ogg",
	"ui_click": "res://Assets/Audio/Menu/ui_click.ogg",
	"ui_hover": "res://Assets/Audio/Menu/ui_hover.ogg"
}

@export var player_actions: Dictionary = {
	"jump": "res://Assets/Audio/Player/Actions/jump.ogg",
	"land": "res://Assets/Audio/Player/Actions/land.ogg",
	"run_start": "res://Assets/Audio/Player/Actions/run_start.ogg",
	"run_stop": "res://Assets/Audio/Player/Actions/run_stop.ogg"
}

@export var footstep_audio: Dictionary = {
	"dirt": [
		"res://Assets/Audio/Player/Footsteps/footstep_dirt_1.ogg",
		"res://Assets/Audio/Player/Footsteps/footstep_dirt_2.ogg",
		"res://Assets/Audio/Player/Footsteps/footstep_dirt_3.ogg"
	],
	"grass": [
		"res://Assets/Audio/Player/Footsteps/footstep_grass_1.ogg",
		"res://Assets/Audio/Player/Footsteps/footstep_grass_2.ogg",
		"res://Assets/Audio/Player/Footsteps/footstep_grass_3.ogg"
	],
	"stone": [
		"res://Assets/Audio/Player/Footsteps/footstep_stone_1.ogg",
		"res://Assets/Audio/Player/Footsteps/footstep_stone_2.ogg",
		"res://Assets/Audio/Player/Footsteps/footstep_stone_3.ogg"
	],
	"water": [
		"res://Assets/Audio/Player/Footsteps/footstep_water_1.ogg",
		"res://Assets/Audio/Player/Footsteps/footstep_water_2.ogg",
		"res://Assets/Audio/Player/Footsteps/footstep_water_3.ogg"
	],
	"wood": [
		"res://Assets/Audio/Player/Footsteps/footstep_wood_1.ogg",
		"res://Assets/Audio/Player/Footsteps/footstep_wood_2.ogg",
		"res://Assets/Audio/Player/Footsteps/footstep_wood_3.ogg"
	]
}

@export var ui_audio: Dictionary = {
	"error": "res://Assets/Audio/UI/error.ogg",
	"inventory_close": "res://Assets/Audio/UI/inventory_close.ogg",
	"inventory_open": "res://Assets/Audio/UI/inventory_open.ogg",
	"item_hover": "res://Assets/Audio/UI/item_hover.ogg",
	"item_select": "res://Assets/Audio/UI/item_select.ogg",
	"notification": "res://Assets/Audio/UI/notification.ogg",
	"success": "res://Assets/Audio/UI/success.ogg"
}

@export var effects_audio: Dictionary = {
	"collection_chime": "res://Assets/Audio/Effects/collection_chime.ogg",
	"cultural_narration": "res://Assets/Audio/Effects/cultural_narration.ogg",
	"npc_hello": "res://Assets/Audio/Effects/npc_hello.ogg",
	"transition_sound": "res://Assets/Audio/Effects/transition_sound.ogg"
}

# Audio settings
@export var enable_3d_audio: bool = true
@export var enable_reverb: bool = true
@export var audio_quality: int = 1  # 0=Low, 1=Medium, 2=High
@export var enable_subtitles: bool = false
@export var enable_cultural_commentary: bool = true

# Regional audio preferences
@export var preferred_language: String = "indonesian"  # "indonesian" or "english"
@export var regional_accent: String = "standard"  # "standard", "javanese", "sundanese", etc.

# Performance settings
@export var audio_buffer_size: int = 1024
@export var enable_audio_streaming: bool = true
@export var max_concurrent_sounds: int = 32

# Get audio file path by category and name
func get_audio_path(category: String, name: String) -> String:
	match category:
		"ambient":
			return ambient_audio.get(name, "")
		"menu":
			return menu_audio.get(name, "")
		"player_actions":
			return player_actions.get(name, "")
		"ui":
			return ui_audio.get(name, "")
		"effects":
			return effects_audio.get(name, "")
		_:
			GameLogger.warning("Unknown audio category: " + category)
			return ""

# Get footstep audio array by surface type
func get_footstep_audio(surface_type: String) -> Array:
	return footstep_audio.get(surface_type, [])

# Get volume by category
func get_volume(category: String) -> float:
	match category:
		"master":
			return master_volume
		"ambient":
			return ambient_volume
		"music":
			return music_volume
		"effects":
			return effects_volume
		"voice":
			return voice_volume
		"footsteps":
			return footsteps_volume
		"menu":
			return menu_volume
		"ui":
			return ui_volume
		_:
			GameLogger.warning("Unknown volume category: " + category)
			return 1.0

# Set volume by category
func set_volume(category: String, volume: float) -> void:
	volume = clamp(volume, 0.0, 1.0)
	match category:
		"master":
			master_volume = volume
		"ambient":
			ambient_volume = volume
		"music":
			music_volume = volume
		"effects":
			effects_volume = volume
		"voice":
			voice_volume = volume
		"footsteps":
			footsteps_volume = volume
		"menu":
			menu_volume = volume
		"ui":
			ui_volume = volume
		_:
			GameLogger.warning("Unknown volume category: " + category)

# Validate all audio files exist
func validate_audio_files() -> Array:
	var missing_files = []
	
	# Check ambient audio
	for name in ambient_audio.keys():
		var path = ambient_audio[name]
		if not ResourceLoader.exists(path):
			missing_files.append("Ambient: " + name + " -> " + path)
	
	# Check menu audio
	for name in menu_audio.keys():
		var path = menu_audio[name]
		if not ResourceLoader.exists(path):
			missing_files.append("Menu: " + name + " -> " + path)
	
	# Check player actions
	for name in player_actions.keys():
		var path = player_actions[name]
		if not ResourceLoader.exists(path):
			missing_files.append("Player Actions: " + name + " -> " + path)
	
	# Check footstep audio
	for surface_type in footstep_audio.keys():
		var paths = footstep_audio[surface_type]
		for i in range(paths.size()):
			if not ResourceLoader.exists(paths[i]):
				missing_files.append("Footsteps " + surface_type + ": " + str(i+1) + " -> " + paths[i])
	
	# Check UI audio
	for name in ui_audio.keys():
		var path = ui_audio[name]
		if not ResourceLoader.exists(path):
			missing_files.append("UI: " + name + " -> " + path)
	
	# Check effects audio
	for name in effects_audio.keys():
		var path = effects_audio[name]
		if not ResourceLoader.exists(path):
			missing_files.append("Effects: " + name + " -> " + path)
	
	return missing_files

# Save configuration to file
func save_config(path: String = "user://audio_config.tres") -> bool:
	var result = ResourceSaver.save(self, path)
	if result == OK:
		GameLogger.info("Audio configuration saved to: " + path)
		return true
	else:
		GameLogger.error("Failed to save audio configuration: " + str(result))
		return false

# Load configuration from file
static func load_config(path: String = "user://audio_config.tres") -> AudioConfig:
	if ResourceLoader.exists(path):
		var config = ResourceLoader.load(path) as AudioConfig
		if config:
			GameLogger.info("Audio configuration loaded from: " + path)
			return config
		else:
			GameLogger.warning("Failed to load audio configuration, using default")
	else:
		GameLogger.info("No audio configuration found, using default")
	
	return AudioConfig.new()
