class_name CulturalAudioManagerEnhanced
extends Node

# Minimal working version of CulturalAudioManagerEnhanced with config support

# Audio players
@onready var ambient_player: AudioStreamPlayer = $AmbientPlayer
@onready var menu_player: AudioStreamPlayer = $MenuPlayer
@onready var footstep_player: AudioStreamPlayer = $FootstepPlayer
@onready var effect_player: AudioStreamPlayer = $EffectPlayer

# Optional AudioConfig resource (Resources/Audio/AudioConfig.tres)
@export var audio_config: Resource

# Audio settings
@export var master_volume: float = 1.0
@export var ambient_volume: float = 0.3
@export var menu_volume: float = 0.6
@export var effects_volume: float = 0.8
@export var footsteps_volume: float = 0.8

# Fallback audio data
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
	]
}

var fallback_player_audio: Dictionary = {
	"jump": "res://Assets/Audio/Player/Actions/jump.ogg",
	"land": "res://Assets/Audio/Player/Actions/land.ogg"
}

func _ready():
	_load_audio_configuration()
	_setup_audio_players()
	GameLogger.info("🎵 CulturalAudioManagerEnhanced initialized (config-aware)")

func _cfg_get(name: String, fallback):
	if audio_config and name in audio_config:
		return audio_config.get(name)
	return fallback

func _load_audio_configuration():
	# Try to auto-load the shared AudioConfig resource
	if audio_config == null and ResourceLoader.exists("res://Resources/Audio/AudioConfig.tres"):
		audio_config = load("res://Resources/Audio/AudioConfig.tres")
		GameLogger.info("📁 Loaded AudioConfig.tres")
	# Apply if available
	master_volume = float(_cfg_get("master_volume", master_volume))
	ambient_volume = float(_cfg_get("ambient_volume", ambient_volume))
	menu_volume = float(_cfg_get("menu_volume", menu_volume))
	effects_volume = float(_cfg_get("effects_volume", effects_volume))
	footsteps_volume = float(_cfg_get("footsteps_volume", footsteps_volume))

func _setup_audio_players():
	if ambient_player:
		ambient_player.volume_db = linear_to_db(ambient_volume * master_volume)
	if menu_player:
		menu_player.volume_db = linear_to_db(menu_volume * master_volume)
	if effect_player:
		effect_player.volume_db = linear_to_db(effects_volume * master_volume)
	if footstep_player:
		footstep_player.volume_db = linear_to_db(footsteps_volume * master_volume)

func play_ambient_audio(audio_id: String):
	var audio_path = get_audio_path("ambient", audio_id)
	if audio_path and ResourceLoader.exists(audio_path):
		ambient_player.stream = load(audio_path)
		ambient_player.play()
		GameLogger.debug("🎵 Playing ambient audio: " + audio_id)

func play_menu_audio(audio_id: String):
	var audio_path = get_audio_path("menu", audio_id)
	if audio_path and ResourceLoader.exists(audio_path):
		menu_player.stream = load(audio_path)
		menu_player.play()
		GameLogger.debug("🎵 Playing menu audio: " + audio_id)

func play_player_audio(action: String):
	var audio_path = get_audio_path("player_actions", action)
	if audio_path and ResourceLoader.exists(audio_path):
		effect_player.stream = load(audio_path)
		effect_player.play()
		GameLogger.debug("🎵 Playing player audio: " + action)

func play_footstep(surface_type: String = "grass"):
	var sounds = get_footstep_audio(surface_type)
	if sounds.size() > 0:
		var idx = randi() % sounds.size()
		var audio_path = sounds[idx]
		if ResourceLoader.exists(audio_path):
			footstep_player.stream = load(audio_path)
			footstep_player.play()
			GameLogger.debug("👣 Footstep: " + surface_type)

func play_region_ambience(region_name: String):
	GameLogger.info("🎵 Playing region ambience for: " + region_name)
	var region_audio_map = {
		"Indonesia Barat": "market_ambience",
		"Indonesia Tengah": "mountain_wind", 
		"Indonesia Timur": "jungle_sounds",
		"PasarScene": "market_ambience",
		"TamboraScene": "mountain_wind",
		"PapuaScene": "jungle_sounds"
	}
	var audio_id = region_audio_map.get(region_name, "market_ambience")
	play_ambient_audio(audio_id)

func play_cultural_audio(audio_type: String, region: String):
	GameLogger.info("🎵 Playing cultural audio: " + audio_type + " for region: " + region)
	var cultural_audio_map = {
		"artifact_collection": "success",
		"cultural_discovery": "discovery",
		"heritage_celebration": "celebration"
	}
	var audio_id = cultural_audio_map.get(audio_type, "success")
	play_menu_audio(audio_id)

func stop_ambient_audio():
	if ambient_player and ambient_player.playing:
		ambient_player.stop()
		GameLogger.info("🎵 Ambient audio stopped")

func stop_all_audio():
	stop_ambient_audio()
	if menu_player and menu_player.playing:
		menu_player.stop()
	GameLogger.info("🎵 All audio stopped")

func get_audio_path(category: String, audio_name: String) -> String:
	# Prefer AudioConfig if present
	if audio_config and audio_config.has_method("get_audio_path"):
		var p: String = str(audio_config.get_audio_path(category, audio_name))
		if p and p != "":
			return p
	match category:
		"ambient":
			return fallback_ambient_audio.get(audio_name, "")
		"menu":
			return fallback_menu_audio.get(audio_name, "")
		"player_actions":
			return fallback_player_audio.get(audio_name, "")
		_:
			return ""

func get_footstep_audio(surface_type: String) -> Array:
	if audio_config and audio_config.has_method("get_footstep_audio"):
		var arr: Array = audio_config.get_footstep_audio(surface_type)
		if arr.size() > 0:
			return arr
	return fallback_footstep_audio.get(surface_type, fallback_footstep_audio.get("grass", []))

func get_configuration_status():
	return {
		"master_volume": master_volume,
		"ambient_volume": ambient_volume,
		"menu_volume": menu_volume
	}
