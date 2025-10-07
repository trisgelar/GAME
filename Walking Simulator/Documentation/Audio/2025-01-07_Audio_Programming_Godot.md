# Audio Programming in Godot
**Date:** 2025-01-07  
**Project:** Indonesian Cultural Heritage Exhibition  
**Version:** 1.0  

## 🎵 **Godot Audio System Implementation**

### **Core Audio Classes**

#### **CulturalAudioManager.gd**
```gdscript
class_name CulturalAudioManager
extends Node

# 7 Specialized Audio Players
@onready var ambient_player: AudioStreamPlayer = $AmbientPlayer
@onready var effect_player: AudioStreamPlayer = $EffectPlayer
@onready var voice_player: AudioStreamPlayer = $VoicePlayer
@onready var menu_player: AudioStreamPlayer = $MenuPlayer
@onready var footstep_player: AudioStreamPlayer = $FootstepPlayer
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var ui_player: AudioStreamPlayer = $UIPlayer
```

#### **AudioResource.gd**
```gdscript
class_name AudioResource
extends Resource

@export var audio_stream: AudioStream
@export var volume_db: float = 0.0
@export var pitch_scale: float = 1.0
@export var loop: bool = false
@export var category: String = "general"
@export var description: String = ""
```

### **Audio Bus Configuration**
```
Master
├── Ambient     # Background ambient sounds
├── SFX         # Sound effects and footsteps
├── Voice       # NPC dialogue and narration
├── Music       # Background music and menu audio
└── UI          # Interface feedback sounds
```

### **Signal-Based Audio System**

#### **GlobalSignals.gd Integration**
```gdscript
# Audio System Signals
signal on_region_audio_change(region: String, audio_type: String)
signal on_play_cultural_audio(audio_id: String, region: String)
signal on_play_menu_audio(audio_id: String)
signal on_play_footstep_audio()
signal on_play_ui_audio(audio_id: String)
signal on_play_player_audio(action: String)
signal on_set_surface_type(surface_type: String)
signal on_set_running_state(running: bool)
```

#### **Audio Event Handling**
```gdscript
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
```

### **Audio Loading and Management**

#### **Dynamic Audio Loading**
```gdscript
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
```

#### **Resource-Based Audio (.tres)**
```gdscript
# Loading .tres audio resources
func load_audio_resource(resource_path: String) -> AudioResource:
    if ResourceLoader.exists(resource_path):
        var audio_resource = load(resource_path) as AudioResource
        if audio_resource:
            return audio_resource
    return null

# Using audio resources
func play_audio_from_resource(audio_resource: AudioResource, player: AudioStreamPlayer):
    if audio_resource:
        player.stream = audio_resource.get_audio_stream()
        player.volume_db = audio_resource.get_volume_db()
        player.pitch_scale = audio_resource.get_pitch_scale()
        player.play()
```

### **Footstep Audio System**

#### **Player Controller Integration**
```gdscript
# Footstep audio variables
var footstep_timer: float = 0.0
var footstep_interval: float = 0.5
var current_surface_type: String = "grass"
var last_position: Vector3 = Vector3.ZERO
var movement_threshold: float = 0.1

func _handle_footstep_audio(delta):
    if not is_on_ground:
        return
    
    footstep_timer += delta
    var current_position = global_position
    var movement_distance = current_position.distance_to(last_position)
    
    if movement_distance > movement_threshold:
        if footstep_timer >= footstep_interval:
            GlobalSignals.on_play_footstep_audio.emit()
            GlobalSignals.on_set_running_state.emit(is_running)
            footstep_timer = 0.0
            last_position = current_position
```

#### **Surface Detection**
```gdscript
func set_surface_type(surface_type: String):
    current_surface_type = surface_type
    GlobalSignals.on_set_surface_type.emit(surface_type)
    GameLogger.debug("Surface type changed to: " + surface_type)
```

### **Volume Management**

#### **Individual Volume Controls**
```gdscript
func set_master_volume(volume: float):
    master_volume = volume
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume))

func set_ambient_volume(volume: float):
    ambient_volume = volume
    ambient_player.volume_db = linear_to_db(volume)

func set_footstep_volume(volume: float):
    footstep_volume = volume
    footstep_player.volume_db = linear_to_db(volume)
```

### **Audio Error Handling**

#### **Graceful Fallbacks**
```gdscript
func play_audio_with_fallback(audio_path: String, player: AudioStreamPlayer):
    if ResourceLoader.exists(audio_path):
        var audio_stream = load(audio_path)
        player.stream = audio_stream
        player.play()
        GameLogger.debug("Audio loaded successfully: " + audio_path)
    else:
        GameLogger.warning("Audio file not found: " + audio_path)
        # Play fallback sound or skip
```

### **Performance Optimization**

#### **Audio Caching**
```gdscript
var audio_cache: Dictionary = {}

func get_cached_audio(audio_path: String) -> AudioStream:
    if audio_path in audio_cache:
        return audio_cache[audio_path]
    
    if ResourceLoader.exists(audio_path):
        var audio_stream = load(audio_path)
        audio_cache[audio_path] = audio_stream
        return audio_stream
    
    return null
```

#### **Memory Management**
```gdscript
func cleanup_audio_cache():
    audio_cache.clear()
    GameLogger.info("Audio cache cleared")

func stop_all_audio():
    ambient_player.stop()
    effect_player.stop()
    voice_player.stop()
    menu_player.stop()
    footstep_player.stop()
    music_player.stop()
    ui_player.stop()
    is_ambient_playing = false
```

### **Audio Scene Setup**

#### **CulturalAudioManager.tscn Structure**
```xml
[gd_scene load_steps=2 format=3 uid="uid://c8is2r5ftgc84"]

[ext_resource type="Script" uid="uid://cxh2p748lh32e" path="res://Systems/Audio/CulturalAudioManager.gd" id="1_audio"]

[node name="CulturalAudioManager" type="Node"]
script = ExtResource("1_audio")

[node name="AmbientPlayer" type="AudioStreamPlayer" parent="."]
volume_db = -10.0

[node name="EffectPlayer" type="AudioStreamPlayer" parent="."]
volume_db = -5.0

[node name="VoicePlayer" type="AudioStreamPlayer" parent="."]
volume_db = -3.0

[node name="MenuPlayer" type="AudioStreamPlayer" parent="."]
volume_db = -8.0

[node name="FootstepPlayer" type="AudioStreamPlayer" parent="."]
volume_db = -12.0

[node name="MusicPlayer" type="AudioStreamPlayer" parent="."]
volume_db = -10.0

[node name="UIPlayer" type="AudioStreamPlayer" parent="."]
volume_db = -5.0
```

### **Best Practices**

#### **Audio File Management**
- Use `.ogg` format for best compression
- Keep files under 1MB when possible
- Use appropriate sample rates (44.1kHz for music, 22kHz for SFX)
- Implement proper loop points for ambient audio

#### **Performance Tips**
- Preload frequently used audio
- Use audio buses for proper mixing
- Implement audio pooling for repeated sounds
- Monitor memory usage with large audio files

#### **Debugging**
- Use GameLogger for audio event tracking
- Implement audio test functions
- Add volume level indicators
- Create audio debug panels
