extends Node

# Enhanced CulturalAudioManager with full AudioConfig integration
# This version can work with or without the AudioConfig system

# Audio Configuration
@export var audio_config: Resource  # Will be AudioConfig when available
var config_loaded: bool = false
var use_config_system: bool = true

# Audio players
@onready var ambient_player: AudioStreamPlayer = $AmbientPlayer
@onready var effect_player: AudioStreamPlayer = $EffectPlayer
@onready var voice_player: AudioStreamPlayer = $VoicePlayer
@onready var menu_player: AudioStreamPlayer = $MenuPlayer
@onready var footstep_player: AudioStreamPlayer = $FootstepPlayer
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var ui_player: AudioStreamPlayer = $UIPlayer

# Audio settings (fallback values)
@export var master_volume: float = 1.0
@export var ambient_volume: float = 0.3
@export var effect_volume: float = 0.7
@export var voice_volume: float = 0.8
@export var menu_volume: float = 0.6
@export var footstep_volume: float = 0.5
@export var music_volume: float = 0.4
@export var ui_volume: float = 0.8

# Fallback audio data (used when config system is not available)
var fallback_ambient_audio: Dictionary = {
	"jungle_sounds": "res://Assets/Audio/Ambient/jungle_sounds.ogg",
	"market_ambience": "res://Assets/Audio/Ambient/market_ambience.ogg",
	"mountain_wind": "res://Assets/Audio/Ambient/mountain_wind.ogg",
	"start_game": "res://Assets/Audio/Menu/start_game.ogg"
}

var fallback_menu_audio: Dictionary = {
	"button_hover": "res://Assets/Audio/Menu/ui_hover.ogg",
	"button_click": "res://Assets/Audio/Menu/ui_click.ogg",
	"menu_open": "res://Assets/Audio/Menu/menu_open.ogg",
	"menu_close": "res://Assets/Audio/Menu/menu_close.ogg",
	"region_select": "res://Assets/Audio/Menu/region_select.ogg",
	"start_game": "res://Assets/Audio/Menu/start_game.ogg"
}

var fallback_footstep_audio: Dictionary = {
	"grass": [
		"res://Assets/Audio/Player/Footsteps/footstep_grass_1.ogg",
		"res://Assets/Audio/Player/Footsteps/footstep_grass_2.ogg",
		"res://Assets/Audio/Player/Footsteps/footstep_grass_3.ogg"
	],
	"dirt": [
		"res://Assets/Audio/Player/Footsteps/footstep_dirt_1.ogg",
		"res://Assets/Audio/Player/Footsteps/footstep_dirt_2.ogg",
		"res://Assets/Audio/Player/Footsteps/footstep_dirt_3.ogg"
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

var fallback_player_audio: Dictionary = {
	"jump": "res://Assets/Audio/Player/Actions/jump.ogg",
	"land": "res://Assets/Audio/Player/Actions/land.ogg",
	"run_start": "res://Assets/Audio/Player/Actions/run_start.ogg",
	"run_stop": "res://Assets/Audio/Player/Actions/run_stop.ogg"
}

var fallback_ui_audio: Dictionary = {
	"inventory_open": "res://Assets/Audio/UI/inventory_open.ogg",
	"inventory_close": "res://Assets/Audio/UI/inventory_close.ogg",
	"item_hover": "res://Assets/Audio/UI/item_hover.ogg",
	"item_select": "res://Assets/Audio/UI/item_select.ogg",
	"success": "res://Assets/Audio/UI/success.ogg",
	"error": "res://Assets/Audio/UI/error.ogg",
	"notification": "res://Assets/Audio/UI/notification.ogg"
}

# State variables
var current_surface_type: String = "grass"
var footstep_timer: float = 0.0
var footstep_interval: float = 0.5
var is_running: bool = false

func _ready():
	load_audio_configuration()
	setup_audio_players()
	connect_signals()
	GameLogger.info("🎵 Enhanced CulturalAudioManager initialized with AudioConfig integration")

func load_audio_configuration():
	"""Load audio configuration from resource file"""
	GameLogger.info("🔧 Loading audio configuration...")
	
	# Try to load the AudioConfig class dynamically
	var audio_config_script = load("res://Systems/Core/AudioConfig.gd")
	if audio_config_script:
		GameLogger.info("✅ AudioConfig script found")
		
		# Try to load the configuration file
		if ResourceLoader.exists("res://Resources/Audio/AudioConfig.tres"):
			audio_config = load("res://Resources/Audio/AudioConfig.tres")
			GameLogger.info("📁 Loaded AudioConfig.tres")
			
			# Apply configuration settings
			apply_configuration_settings()
			config_loaded = true
			use_config_system = true
			GameLogger.info("✅ AudioConfig system active")
		else:
			GameLogger.warning("⚠️ AudioConfig.tres not found, creating default")
			create_default_configuration()
	else:
		GameLogger.warning("⚠️ AudioConfig script not found, using fallback system")
		use_config_system = false
		config_loaded = false

func create_default_configuration():
	"""Create a default configuration using the AudioConfig class"""
	var audio_config_script = load("res://Systems/Core/AudioConfig.gd")
	if audio_config_script:
		audio_config = audio_config_script.new()
		apply_configuration_settings()
		config_loaded = true
		use_config_system = true
		GameLogger.info("✅ Default AudioConfig created")
	else:
		GameLogger.warning("⚠️ Cannot create AudioConfig, using fallback")
		use_config_system = false

func apply_configuration_settings():
	"""Apply settings from the loaded configuration"""
	if not audio_config:
		return
		
	# Apply volume settings with safety checks
	master_volume = get_config_value("master_volume", master_volume)
	ambient_volume = get_config_value("ambient_volume", ambient_volume)
	effect_volume = get_config_value("effects_volume", effect_volume)
	voice_volume = get_config_value("voice_volume", voice_volume)
	menu_volume = get_config_value("menu_volume", menu_volume)
	footstep_volume = get_config_value("footsteps_volume", footstep_volume)
	music_volume = get_config_value("music_volume", music_volume)
	ui_volume = get_config_value("ui_volume", ui_volume)
	
	GameLogger.info("✅ Configuration settings applied")
	
	# Validate audio files if method exists
	if audio_config.has_method("validate_audio_files"):
		var missing_files = audio_config.validate_audio_files()
		if missing_files.size() > 0:
			GameLogger.warning("⚠️ Missing audio files detected:")
			for file in missing_files:
				GameLogger.warning("   - " + file)

func get_config_value(property_name: String, default_value) -> Variant:
	"""Safely get a value from the configuration"""
	if audio_config and audio_config.has_method("get"):
		if property_name in audio_config:
			return audio_config.get(property_name)
		else:
			return default_value
	elif audio_config and property_name in audio_config:
		return audio_config[property_name]
	else:
		return default_value

func setup_audio_players():
	"""Set up all audio players with proper volumes"""
	ambient_player.volume_db = linear_to_db(ambient_volume * master_volume)
	effect_player.volume_db = linear_to_db(effect_volume * master_volume)
	voice_player.volume_db = linear_to_db(voice_volume * master_volume)
	menu_player.volume_db = linear_to_db(menu_volume * master_volume)
	footstep_player.volume_db = linear_to_db(footstep_volume * master_volume)
	music_player.volume_db = linear_to_db(music_volume * master_volume)
	ui_player.volume_db = linear_to_db(ui_volume * master_volume)
	
	GameLogger.info("🔊 Audio players configured")

func connect_signals():
	"""Connect to global signals"""
	GlobalSignals.on_play_ambient_audio.connect(_on_play_ambient_audio)
	GlobalSignals.on_play_menu_audio.connect(_on_play_menu_audio)
	GlobalSignals.on_play_footstep_audio.connect(_on_play_footstep_audio)
	GlobalSignals.on_play_player_audio.connect(_on_play_player_audio)
	GlobalSignals.on_play_ui_audio.connect(_on_play_ui_audio)
	GlobalSignals.on_set_surface_type.connect(_on_set_surface_type)
	GlobalSignals.on_set_running_state.connect(_on_set_running_state)
	
	GameLogger.info("🔗 Audio signals connected")

# Signal handlers
func _on_play_ambient_audio(audio_id: String):
	play_ambient_audio(audio_id)

func _on_play_menu_audio(audio_id: String):
	play_menu_audio(audio_id)

func _on_play_footstep_audio():
	play_footstep_audio()

func _on_play_player_audio(action: String):
	play_player_audio(action)

func _on_play_ui_audio(audio_id: String):
	play_ui_audio(audio_id)

func _on_set_surface_type(surface_type: String):
	current_surface_type = surface_type

func _on_set_running_state(running: bool):
	is_running = running

# Audio playback functions
func play_ambient_audio(audio_id: String):
	var audio_path = get_audio_path("ambient", audio_id)
	if audio_path and ResourceLoader.exists(audio_path):
		ambient_player.stream = load(audio_path)
		ambient_player.play()
		GameLogger.debug("🎵 Playing ambient audio: " + audio_id)
	else:
		GameLogger.warning("⚠️ Ambient audio not found: " + audio_id)

func play_menu_audio(audio_id: String):
	var audio_path = get_audio_path("menu", audio_id)
	if audio_path and ResourceLoader.exists(audio_path):
		menu_player.stream = load(audio_path)
		menu_player.play()
		GameLogger.debug("🎵 Playing menu audio: " + audio_id)
	else:
		GameLogger.warning("⚠️ Menu audio not found: " + audio_id)

func play_footstep_audio():
	var surface_sounds = get_footstep_audio(current_surface_type)
	if surface_sounds.size() > 0:
		var random_index = randi() % surface_sounds.size()
		var audio_path = surface_sounds[random_index]
		if ResourceLoader.exists(audio_path):
			footstep_player.stream = load(audio_path)
			footstep_player.play()
			GameLogger.debug("👣 Playing footstep: " + current_surface_type + " (" + str(random_index + 1) + ")")
		else:
			GameLogger.warning("⚠️ Footstep audio file not found: " + audio_path)

func play_player_audio(action: String):
	var audio_path = get_audio_path("player_actions", action)
	if audio_path and ResourceLoader.exists(audio_path):
		effect_player.stream = load(audio_path)
		effect_player.play()
		GameLogger.debug("🎵 Playing player audio: " + action)
	else:
		GameLogger.warning("⚠️ Player audio not found: " + action)

func play_ui_audio(audio_id: String):
	var audio_path = get_audio_path("ui", audio_id)
	if audio_path and ResourceLoader.exists(audio_path):
		ui_player.stream = load(audio_path)
		ui_player.play()
		GameLogger.debug("🎵 Playing UI audio: " + audio_id)
	else:
		GameLogger.warning("⚠️ UI audio not found: " + audio_id)

func play_effect_audio(audio_id: String):
	var audio_path = get_audio_path("effects", audio_id)
	if audio_path and ResourceLoader.exists(audio_path):
		effect_player.stream = load(audio_path)
		effect_player.play()
		GameLogger.debug("🎵 Playing effect audio: " + audio_id)
	else:
		GameLogger.warning("⚠️ Effect audio not found: " + audio_id)

func play_voice_audio(audio_id: String):
	# Placeholder for voice audio
	GameLogger.debug("🎵 Voice audio requested: " + audio_id)

func play_region_ambience(region_name: String):
	"""Play region-specific ambient audio"""
	GameLogger.info("🎵 Playing region ambience for: " + region_name)
	
	# Map region names to ambient audio IDs
	var region_audio_map = {
		"Indonesia Barat": "market_ambience",
		"Indonesia Tengah": "mountain_wind", 
		"Indonesia Timur": "jungle_sounds",
		"PasarScene": "market_ambience",
		"TamboraScene": "mountain_wind",
		"PapuaScene": "jungle_sounds"
	}
	
	var audio_id = region_audio_map.get(region_name, "market_ambience")
	GameLogger.debug("🎵 Region " + region_name + " mapped to audio: " + audio_id)
	
	# Use the existing play_ambient_audio function
	play_ambient_audio(audio_id)

func play_cultural_audio(audio_type: String, region: String):
	"""Play cultural audio effects (like artifact collection)"""
	GameLogger.info("🎵 Playing cultural audio: " + audio_type + " for region: " + region)
	
	# Map cultural audio types to appropriate audio categories
	var cultural_audio_map = {
		"artifact_collection": "success",
		"cultural_discovery": "discovery",
		"heritage_celebration": "celebration"
	}
	
	var audio_id = cultural_audio_map.get(audio_type, "success")
	GameLogger.debug("🎵 Cultural audio " + audio_type + " mapped to: " + audio_id)
	
	# Use the existing play_ui_audio function for cultural effects
	play_ui_audio(audio_id)

# Configuration-aware audio path functions
func get_audio_path(category: String, audio_name: String) -> String:
	"""Get audio file path from configuration or fallback"""
	if use_config_system and audio_config and audio_config.has_method("get_audio_path"):
		var path = audio_config.get_audio_path(category, audio_name)
		if path:
			return path
	
	# Fallback to hardcoded paths
	match category:
		"ambient":
			return fallback_ambient_audio.get(audio_name, "")
		"menu":
			return fallback_menu_audio.get(audio_name, "")
		"player_actions":
			return fallback_player_audio.get(audio_name, "")
		"ui":
			return fallback_ui_audio.get(audio_name, "")
		_:
			return ""

func get_footstep_audio(surface_type: String) -> Array:
	"""Get footstep audio array from configuration or fallback"""
	if use_config_system and audio_config and audio_config.has_method("get_footstep_audio"):
		var sounds = audio_config.get_footstep_audio(surface_type)
		if sounds.size() > 0:
			return sounds
	
	# Fallback to hardcoded paths
	return fallback_footstep_audio.get(surface_type, fallback_footstep_audio["grass"])

# Volume control functions
func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)
	update_all_volumes()
	
	# Save to configuration if available
	if use_config_system and audio_config and audio_config.has_method("set_volume"):
		audio_config.set_volume("master", master_volume)

func set_ambient_volume(volume: float):
	ambient_volume = clamp(volume, 0.0, 1.0)
	ambient_player.volume_db = linear_to_db(ambient_volume * master_volume)
	
	if use_config_system and audio_config and audio_config.has_method("set_volume"):
		audio_config.set_volume("ambient", ambient_volume)

func set_menu_volume(volume: float):
	menu_volume = clamp(volume, 0.0, 1.0)
	menu_player.volume_db = linear_to_db(menu_volume * master_volume)
	
	if use_config_system and audio_config and audio_config.has_method("set_volume"):
		audio_config.set_volume("menu", menu_volume)

func set_footstep_volume(volume: float):
	footstep_volume = clamp(volume, 0.0, 1.0)
	footstep_player.volume_db = linear_to_db(footstep_volume * master_volume)
	
	if use_config_system and audio_config and audio_config.has_method("set_volume"):
		audio_config.set_volume("footsteps", footstep_volume)

func set_ui_volume(volume: float):
	ui_volume = clamp(volume, 0.0, 1.0)
	ui_player.volume_db = linear_to_db(ui_volume * master_volume)
	
	if use_config_system and audio_config and audio_config.has_method("set_volume"):
		audio_config.set_volume("ui", ui_volume)

func update_all_volumes():
	"""Update all audio player volumes"""
	ambient_player.volume_db = linear_to_db(ambient_volume * master_volume)
	effect_player.volume_db = linear_to_db(effect_volume * master_volume)
	voice_player.volume_db = linear_to_db(voice_volume * master_volume)
	menu_player.volume_db = linear_to_db(menu_volume * master_volume)
	footstep_player.volume_db = linear_to_db(footstep_volume * master_volume)
	music_player.volume_db = linear_to_db(music_volume * master_volume)
	ui_player.volume_db = linear_to_db(ui_volume * master_volume)

# Configuration management
func save_configuration():
	"""Save current configuration to file"""
	if use_config_system and audio_config and audio_config.has_method("save_config"):
		var success = audio_config.save_config()
		if success:
			GameLogger.info("✅ Audio configuration saved")
		else:
			GameLogger.error("❌ Failed to save audio configuration")
	else:
		GameLogger.warning("⚠️ Configuration system not available for saving")

func reload_configuration():
	"""Reload configuration from file"""
	load_audio_configuration()
	setup_audio_players()
	GameLogger.info("🔄 Audio configuration reloaded")

# Stop functions
func stop_ambient_audio():
	"""Stop ambient audio and ensure it's fully stopped"""
	if ambient_player and ambient_player.playing:
		ambient_player.stop()
		GameLogger.info("🎵 Ambient audio stopped")
	else:
		GameLogger.debug("🎵 Ambient audio was not playing")

func stop_all_audio():
	"""Stop all audio players to prevent overlap"""
	stop_ambient_audio()
	stop_menu_audio()
	stop_footstep_audio()
	stop_music_audio()
	stop_ui_audio()
	GameLogger.info("🎵 All audio stopped")

func debug_audio_status():
	"""Debug function to check what audio is currently playing"""
	GameLogger.info("🔍 Audio Status Debug:")
	GameLogger.info("   Ambient: " + str(ambient_player.playing if ambient_player else "No player"))
	GameLogger.info("   Menu: " + str(menu_player.playing if menu_player else "No player"))
	GameLogger.info("   Music: " + str(music_player.playing if music_player else "No player"))
	GameLogger.info("   UI: " + str(ui_player.playing if ui_player else "No player"))
	GameLogger.info("   Footstep: " + str(footstep_player.playing if footstep_player else "No player"))

func stop_menu_audio():
	menu_player.stop()

func stop_footstep_audio():
	footstep_player.stop()

func stop_ui_audio():
	ui_player.stop()

func stop_all_audio():
	ambient_player.stop()
	effect_player.stop()
	voice_player.stop()
	menu_player.stop()
	footstep_player.stop()
	music_player.stop()
	ui_player.stop()

# Debug functions
func get_configuration_status() -> Dictionary:
	"""Get current configuration status for debugging"""
	return {
		"config_loaded": config_loaded,
		"use_config_system": use_config_system,
		"audio_config_exists": audio_config != null,
		"master_volume": master_volume,
		"ambient_volume": ambient_volume,
		"menu_volume": menu_volume,
		"footstep_volume": footstep_volume,
		"ui_volume": ui_volume
	}
