class_name CulturalAudioManagerSimple
extends Node

# Simple version of CulturalAudioManager without AudioConfig dependency
# This can be used while we resolve the class loading issues

# Audio players
@onready var ambient_player: AudioStreamPlayer = $AmbientPlayer
@onready var effect_player: AudioStreamPlayer = $EffectPlayer
@onready var voice_player: AudioStreamPlayer = $VoicePlayer
@onready var menu_player: AudioStreamPlayer = $MenuPlayer
@onready var footstep_player: AudioStreamPlayer = $FootstepPlayer
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var ui_player: AudioStreamPlayer = $UIPlayer

# Audio settings
@export var master_volume: float = 1.0
@export var ambient_volume: float = 0.3
@export var effect_volume: float = 0.7
@export var voice_volume: float = 0.8
@export var menu_volume: float = 0.6
@export var footstep_volume: float = 0.5
@export var music_volume: float = 0.4
@export var ui_volume: float = 0.8

# Audio data
var ambient_audio_effects: Dictionary = {
	"jungle_sounds": "res://Assets/Audio/Ambient/jungle_sounds.ogg",
	"market_ambience": "res://Assets/Audio/Ambient/market_ambience.ogg",
	"mountain_wind": "res://Assets/Audio/Ambient/mountain_wind.ogg"
}

var menu_audio_effects: Dictionary = {
	"button_hover": "res://Assets/Audio/Menu/ui_hover.ogg",
	"button_click": "res://Assets/Audio/Menu/ui_click.ogg",
	"menu_open": "res://Assets/Audio/Menu/menu_open.ogg",
	"menu_close": "res://Assets/Audio/Menu/menu_close.ogg",
	"region_select": "res://Assets/Audio/Menu/region_select.ogg",
	"start_game": "res://Assets/Audio/Menu/start_game.ogg"
}

var footstep_audio: Dictionary = {
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

var player_audio: Dictionary = {
	"jump": "res://Assets/Audio/Player/Actions/jump.ogg",
	"land": "res://Assets/Audio/Player/Actions/land.ogg",
	"run_start": "res://Assets/Audio/Player/Actions/run_start.ogg",
	"run_stop": "res://Assets/Audio/Player/Actions/run_stop.ogg"
}

var ui_audio_effects: Dictionary = {
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
	setup_audio_players()
	connect_signals()
	GameLogger.info("🎵 Simple CulturalAudioManager initialized")

func setup_audio_players():
	# Set up all audio players with proper volumes
	ambient_player.volume_db = linear_to_db(ambient_volume)
	effect_player.volume_db = linear_to_db(effect_volume)
	voice_player.volume_db = linear_to_db(voice_volume)
	menu_player.volume_db = linear_to_db(menu_volume)
	footstep_player.volume_db = linear_to_db(footstep_volume)
	music_player.volume_db = linear_to_db(music_volume)
	ui_player.volume_db = linear_to_db(ui_volume)
	
	GameLogger.info("🔊 Audio players configured")

func connect_signals():
	# Connect to global signals
	GlobalSignals.on_play_ambient_audio.connect(_on_play_ambient_audio)
	GlobalSignals.on_play_effect_audio.connect(_on_play_effect_audio)
	GlobalSignals.on_play_voice_audio.connect(_on_play_voice_audio)
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

func _on_play_effect_audio(audio_id: String):
	play_effect_audio(audio_id)

func _on_play_voice_audio(audio_id: String):
	play_voice_audio(audio_id)

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
	if audio_id in ambient_audio_effects:
		var audio_path = ambient_audio_effects[audio_id]
		if ResourceLoader.exists(audio_path):
			ambient_player.stream = load(audio_path)
			ambient_player.play()
			GameLogger.debug("🎵 Playing ambient audio: " + audio_id)
		else:
			GameLogger.warning("⚠️ Ambient audio file not found: " + audio_path)

func play_menu_audio(audio_id: String):
	if audio_id in menu_audio_effects:
		var audio_path = menu_audio_effects[audio_id]
		if ResourceLoader.exists(audio_path):
			menu_player.stream = load(audio_path)
			menu_player.play()
			GameLogger.debug("🎵 Playing menu audio: " + audio_id)
		else:
			GameLogger.warning("⚠️ Menu audio file not found: " + audio_path)

func play_footstep_audio():
	var surface_sounds = footstep_audio.get(current_surface_type, footstep_audio["grass"])
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
	if action in player_audio:
		var audio_path = player_audio[action]
		if ResourceLoader.exists(audio_path):
			effect_player.stream = load(audio_path)
			effect_player.play()
			GameLogger.debug("🎵 Playing player audio: " + action)
		else:
			GameLogger.warning("⚠️ Player audio file not found: " + audio_path)

func play_ui_audio(audio_id: String):
	if audio_id in ui_audio_effects:
		var audio_path = ui_audio_effects[audio_id]
		if ResourceLoader.exists(audio_path):
			ui_player.stream = load(audio_path)
			ui_player.play()
			GameLogger.debug("🎵 Playing UI audio: " + audio_id)
		else:
			GameLogger.warning("⚠️ UI audio file not found: " + audio_path)

func play_effect_audio(audio_id: String):
	# Placeholder for effect audio
	GameLogger.debug("🎵 Effect audio requested: " + audio_id)

func play_voice_audio(audio_id: String):
	# Placeholder for voice audio
	GameLogger.debug("🎵 Voice audio requested: " + audio_id)

# Volume control functions
func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)
	update_all_volumes()

func set_ambient_volume(volume: float):
	ambient_volume = clamp(volume, 0.0, 1.0)
	ambient_player.volume_db = linear_to_db(ambient_volume * master_volume)

func set_menu_volume(volume: float):
	menu_volume = clamp(volume, 0.0, 1.0)
	menu_player.volume_db = linear_to_db(menu_volume * master_volume)

func set_footstep_volume(volume: float):
	footstep_volume = clamp(volume, 0.0, 1.0)
	footstep_player.volume_db = linear_to_db(footstep_volume * master_volume)

func set_ui_volume(volume: float):
	ui_volume = clamp(volume, 0.0, 1.0)
	ui_player.volume_db = linear_to_db(ui_volume * master_volume)

func update_all_volumes():
	ambient_player.volume_db = linear_to_db(ambient_volume * master_volume)
	effect_player.volume_db = linear_to_db(effect_volume * master_volume)
	voice_player.volume_db = linear_to_db(voice_volume * master_volume)
	menu_player.volume_db = linear_to_db(menu_volume * master_volume)
	footstep_player.volume_db = linear_to_db(footstep_volume * master_volume)
	music_player.volume_db = linear_to_db(music_volume * master_volume)
	ui_player.volume_db = linear_to_db(ui_volume * master_volume)

# Stop functions
func stop_ambient_audio():
	ambient_player.stop()

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
