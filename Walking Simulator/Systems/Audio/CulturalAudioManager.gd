class_name CulturalAudioManager
extends Node

# Audio Configuration
@export var audio_config: Resource  # AudioConfig
var config_loaded: bool = false

# Audio players - Enhanced with more categories
@onready var ambient_player: AudioStreamPlayer = $AmbientPlayer
@onready var effect_player: AudioStreamPlayer = $EffectPlayer
@onready var voice_player: AudioStreamPlayer = $VoicePlayer
@onready var menu_player: AudioStreamPlayer = $MenuPlayer
@onready var footstep_player: AudioStreamPlayer = $FootstepPlayer
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var ui_player: AudioStreamPlayer = $UIPlayer

# Audio settings - Enhanced with more categories
@export var master_volume: float = 1.0
@export var ambient_volume: float = 0.3
@export var effect_volume: float = 0.7
@export var voice_volume: float = 0.8
@export var menu_volume: float = 0.6
@export var footstep_volume: float = 0.5
@export var music_volume: float = 0.4
@export var ui_volume: float = 0.8

# Region-specific audio data
var region_ambient_sounds: Dictionary = {
	"Indonesia Barat": {
		"ambient": "market_ambience.ogg",
		"description": "Traditional market sounds with vendor calls and crowd noise"
	},
	"Indonesia Tengah": {
		"ambient": "mountain_wind.ogg", 
		"description": "Mountain wind and natural sounds"
	},
	"Indonesia Timur": {
		"ambient": "jungle_sounds.ogg",
		"description": "Jungle ambience with birds and nature sounds"
	}
}

# Comprehensive audio effects database
var cultural_audio_effects: Dictionary = {
	"artifact_collection": "collection_chime.ogg",
	"artifact_description": "cultural_narration.ogg",
	"npc_greeting": "npc_hello.ogg",
	"region_transition": "transition_sound.ogg"
}

# Menu audio effects
var menu_audio_effects: Dictionary = {
	"button_hover": "ui_hover.ogg",
	"button_click": "ui_click.ogg",
	"menu_open": "menu_open.ogg",
	"menu_close": "menu_close.ogg",
	"start_game": "start_game.ogg",
	"region_select": "region_select.ogg"
}

# Footstep audio system
var footstep_audio: Dictionary = {
	"grass": ["footstep_grass_1.ogg", "footstep_grass_2.ogg", "footstep_grass_3.ogg"],
	"stone": ["footstep_stone_1.ogg", "footstep_stone_2.ogg", "footstep_stone_3.ogg"],
	"wood": ["footstep_wood_1.ogg", "footstep_wood_2.ogg", "footstep_wood_3.ogg"],
	"dirt": ["footstep_dirt_1.ogg", "footstep_dirt_2.ogg", "footstep_dirt_3.ogg"],
	"water": ["footstep_water_1.ogg", "footstep_water_2.ogg", "footstep_water_3.ogg"]
}

# Player action audio
var player_audio: Dictionary = {
	"jump": "jump.ogg",
	"land": "land.ogg",
	"run_start": "run_start.ogg",
	"run_stop": "run_stop.ogg"
}

# UI audio effects
var ui_audio_effects: Dictionary = {
	"inventory_open": "inventory_open.ogg",
	"inventory_close": "inventory_close.ogg",
	"item_hover": "item_hover.ogg",
	"item_select": "item_select.ogg",
	"notification": "notification.ogg",
	"error": "error.ogg",
	"success": "success.ogg"
}

# Current audio state
var current_region: String = ""
var is_ambient_playing: bool = false
var current_surface_type: String = "grass"  # For footstep audio
var footstep_timer: float = 0.0
var footstep_interval: float = 0.5  # Time between footsteps
var is_running: bool = false

func _ready():
	load_audio_configuration()
	setup_audio_players()
	connect_signals()
	GameLogger.info("🎵 Enhanced CulturalAudioManager initialized with comprehensive audio categories")

func load_audio_configuration():
	"""Load audio configuration from resource file"""
	if not audio_config:
		# Try to load default configuration
		if ResourceLoader.exists("res://Resources/Audio/AudioConfig.tres"):
			audio_config = load("res://Resources/Audio/AudioConfig.tres")
			GameLogger.info("📁 Loaded default audio configuration")
		else:
			# Create new configuration - use basic Resource for now
			audio_config = Resource.new()
			GameLogger.warning("⚠️ No audio configuration found, using defaults")
	
	if audio_config:
		# Apply configuration settings (with safety checks)
		if audio_config.has_method("get") or audio_config.get_script():
			master_volume = audio_config.get("master_volume", master_volume)
			ambient_volume = audio_config.get("ambient_volume", ambient_volume)
			effect_volume = audio_config.get("effects_volume", effect_volume)
			voice_volume = audio_config.get("voice_volume", voice_volume)
			menu_volume = audio_config.get("menu_volume", menu_volume)
			footstep_volume = audio_config.get("footsteps_volume", footstep_volume)
			music_volume = audio_config.get("music_volume", music_volume)
			ui_volume = audio_config.get("ui_volume", ui_volume)
			
			config_loaded = true
			GameLogger.info("✅ Audio configuration applied successfully")
			
			# Validate audio files if method exists
			if audio_config.has_method("validate_audio_files"):
				var missing_files = audio_config.validate_audio_files()
				if missing_files.size() > 0:
					GameLogger.warning("⚠️ Missing audio files detected:")
					for file in missing_files:
						GameLogger.warning("   - " + file)
		else:
			GameLogger.warning("⚠️ Audio configuration loaded but no valid properties found")
	else:
		GameLogger.error("❌ Failed to load audio configuration")

func setup_audio_players():
	# Set up all audio players with proper volumes
	ambient_player.volume_db = linear_to_db(ambient_volume)
	effect_player.volume_db = linear_to_db(effect_volume)
	voice_player.volume_db = linear_to_db(voice_volume)
	menu_player.volume_db = linear_to_db(menu_volume)
	footstep_player.volume_db = linear_to_db(footstep_volume)
	music_player.volume_db = linear_to_db(music_volume)
	ui_player.volume_db = linear_to_db(ui_volume)
	
	# Set up audio buses for proper mixing
	ambient_player.bus = "Ambient"
	effect_player.bus = "SFX"
	voice_player.bus = "Voice"
	menu_player.bus = "Music"
	footstep_player.bus = "SFX"
	music_player.bus = "Music"
	ui_player.bus = "UI"

func connect_signals():
	# Existing signals
	GlobalSignals.on_region_audio_change.connect(_on_region_audio_change)
	GlobalSignals.on_play_cultural_audio.connect(_on_play_cultural_audio)
	
	# New audio signals
	GlobalSignals.on_play_menu_audio.connect(_on_play_menu_audio)
	GlobalSignals.on_play_footstep_audio.connect(_on_play_footstep_audio)
	GlobalSignals.on_play_ui_audio.connect(_on_play_ui_audio)
	GlobalSignals.on_play_player_audio.connect(_on_play_player_audio)
	GlobalSignals.on_set_surface_type.connect(_on_set_surface_type)
	GlobalSignals.on_set_running_state.connect(_on_set_running_state)

func _on_region_audio_change(region: String, audio_type: String):
	match audio_type:
		"ambient":
			play_region_ambience(region)
		"transition":
			play_region_transition(region)

func _on_play_cultural_audio(audio_id: String, region: String):
	play_cultural_audio(audio_id, region)

func play_region_ambience(region: String):
	if current_region == region and is_ambient_playing:
		return
	
	current_region = region
	
	# Stop current ambient audio
	if ambient_player.playing:
		ambient_player.stop()
	
	# Load and play new ambient audio
	var ambient_data = region_ambient_sounds.get(region, {})
	var ambient_file = ambient_data.get("ambient", "")
	
	if ambient_file:
		var audio_path = "res://Assets/Audio/Ambient/" + ambient_file
		if ResourceLoader.exists(audio_path):
			var audio_stream = load(audio_path)
			ambient_player.stream = audio_stream
			ambient_player.play()
			is_ambient_playing = true
			
			GameLogger.info("Playing ambient audio for " + region + ": " + ambient_data.get("description", ""))
		else:
			GameLogger.warning("Ambient audio file not found: " + audio_path)
	else:
		GameLogger.warning("No ambient audio defined for region: " + region)

func play_cultural_audio(audio_id: String, region: String):
	var audio_file = cultural_audio_effects.get(audio_id, "")
	
	if audio_file:
		var audio_path = "res://Assets/Audio/Effects/" + audio_file
		if ResourceLoader.exists(audio_path):
			var audio_stream = load(audio_path)
			effect_player.stream = audio_stream
			effect_player.play()
			
			GameLogger.info("Playing cultural audio: " + audio_id + " for region: " + region)
		else:
			GameLogger.warning("Cultural audio file not found: " + audio_path)
	else:
		GameLogger.warning("No cultural audio defined for ID: " + audio_id)

func play_region_transition(region: String):
	# Play transition sound when changing regions
	play_cultural_audio("region_transition", region)
	
	# Fade out current ambient
	if ambient_player.playing:
		fade_out_ambient()
	
	# Wait a moment then start new ambient
	await get_tree().create_timer(1.0).timeout
	play_region_ambience(region)

func fade_out_ambient():
	# Simple fade out effect
	var tween = create_tween()
	tween.tween_property(ambient_player, "volume_db", -80.0, 1.0)
	await tween.finished
	ambient_player.stop()
	ambient_player.volume_db = linear_to_db(ambient_volume)

func play_voice_audio(audio_stream: AudioStream):
	if audio_stream:
		voice_player.stream = audio_stream
		voice_player.play()

func stop_all_audio():
	ambient_player.stop()
	effect_player.stop()
	voice_player.stop()
	is_ambient_playing = false

func set_master_volume(volume: float):
	master_volume = volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume))

func set_ambient_volume(volume: float):
	ambient_volume = volume
	ambient_player.volume_db = linear_to_db(volume)

func set_effect_volume(volume: float):
	effect_volume = volume
	effect_player.volume_db = linear_to_db(volume)

func set_voice_volume(volume: float):
	voice_volume = volume
	voice_player.volume_db = linear_to_db(volume)

# Utility functions for audio management
func pause_ambient():
	if ambient_player.playing:
		ambient_player.stream_paused = true

func resume_ambient():
	if ambient_player.stream_paused:
		ambient_player.stream_paused = false

func get_current_region() -> String:
	return current_region

func is_audio_playing() -> bool:
	return ambient_player.playing or effect_player.playing or voice_player.playing or menu_player.playing or footstep_player.playing or music_player.playing or ui_player.playing

# ===== NEW AUDIO FUNCTIONS =====

# Menu Audio System
func _on_play_menu_audio(audio_id: String):
	play_menu_audio(audio_id)

func play_menu_audio(audio_id: String):
	var audio_file = menu_audio_effects.get(audio_id, "")
	
	if audio_file:
		var audio_path = "res://Assets/Audio/Menu/" + audio_file
		if ResourceLoader.exists(audio_path):
			var audio_stream = load(audio_path)
			menu_player.stream = audio_stream
			menu_player.play()
			GameLogger.debug("Playing menu audio: " + audio_id)
		else:
			GameLogger.warning("Menu audio file not found: " + audio_path)
	else:
		GameLogger.warning("No menu audio defined for ID: " + audio_id)

# Footstep Audio System
func _on_play_footstep_audio():
	play_footstep_audio()

func _on_set_surface_type(surface_type: String):
	current_surface_type = surface_type
	GameLogger.debug("Surface type changed to: " + surface_type)

func _on_set_running_state(running: bool):
	is_running = running
	footstep_interval = 0.3 if running else 0.5  # Faster footsteps when running
	GameLogger.debug("Running state changed to: " + str(running))

func play_footstep_audio():
	var footstep_files = footstep_audio.get(current_surface_type, footstep_audio["grass"])
	if footstep_files.size() > 0:
		# Randomly select a footstep sound for variety
		var random_index = randi() % footstep_files.size()
		var audio_file = footstep_files[random_index]
		var audio_path = "res://Assets/Audio/Player/Footsteps/" + audio_file
		
		if ResourceLoader.exists(audio_path):
			var audio_stream = load(audio_path)
			footstep_player.stream = audio_stream
			footstep_player.play()
			GameLogger.debug("Playing footstep: " + audio_file + " on " + current_surface_type)
		else:
			GameLogger.warning("Footstep audio file not found: " + audio_path)

# Player Action Audio
func _on_play_player_audio(action: String):
	play_player_audio(action)

func play_player_audio(action: String):
	var audio_file = player_audio.get(action, "")
	
	if audio_file:
		var audio_path = "res://Assets/Audio/Player/Actions/" + audio_file
		if ResourceLoader.exists(audio_path):
			var audio_stream = load(audio_path)
			effect_player.stream = audio_stream
			effect_player.play()
			GameLogger.debug("Playing player action: " + action)
		else:
			GameLogger.warning("Player audio file not found: " + audio_path)
	else:
		GameLogger.warning("No player audio defined for action: " + action)

# UI Audio System
func _on_play_ui_audio(audio_id: String):
	play_ui_audio(audio_id)

func play_ui_audio(audio_id: String):
	var audio_file = ui_audio_effects.get(audio_id, "")
	
	if audio_file:
		var audio_path = "res://Assets/Audio/UI/" + audio_file
		if ResourceLoader.exists(audio_path):
			var audio_stream = load(audio_path)
			ui_player.stream = audio_stream
			ui_player.play()
			GameLogger.debug("Playing UI audio: " + audio_id)
		else:
			GameLogger.warning("UI audio file not found: " + audio_path)
	else:
		GameLogger.warning("No UI audio defined for ID: " + audio_id)

# Enhanced Volume Controls
func set_menu_volume(volume: float):
	menu_volume = volume
	menu_player.volume_db = linear_to_db(volume)

func set_footstep_volume(volume: float):
	footstep_volume = volume
	footstep_player.volume_db = linear_to_db(volume)

func set_music_volume(volume: float):
	music_volume = volume
	music_player.volume_db = linear_to_db(volume)

func set_ui_volume(volume: float):
	ui_volume = volume
	ui_player.volume_db = linear_to_db(volume)

# Enhanced Stop Functions
func stop_menu_audio():
	menu_player.stop()

func stop_footstep_audio():
	footstep_player.stop()

func stop_music_audio():
	music_player.stop()

func stop_ui_audio():
	ui_player.stop()

# Duplicate function removed - already exists above
	is_ambient_playing = false
