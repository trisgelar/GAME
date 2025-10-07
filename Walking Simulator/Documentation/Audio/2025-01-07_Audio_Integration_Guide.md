# Audio Integration Guide
**Date:** 2025-01-07  
**Project:** Indonesian Cultural Heritage Exhibition  
**Version:** 1.0  

## 🎵 **Audio System Integration Overview**

### **Integration Points**
- ✅ **Main Menu**: Button sounds, region selection
- ✅ **Player Movement**: Footsteps, jumping, running
- ✅ **Inventory System**: Open/close, item collection
- ✅ **Region Transitions**: Ambient audio changes
- ✅ **Cultural Interactions**: Artifact collection, NPC dialogue

### **System Architecture**
```
GlobalSignals (Event Bus)
    ↓
CulturalAudioManager (Audio Controller)
    ↓
AudioStreamPlayers (7 Specialized Players)
    ↓
Audio Buses (Master, Ambient, SFX, Voice, Music, UI)
```

## 🔧 **Integration Implementation**

### **1. Main Menu Integration**

#### **MainMenuController.gd Integration**
```gdscript
# Audio manager reference
var audio_manager: CulturalAudioManager

func _ready():
    setup_menu()
    connect_signals()
    setup_audio_manager()  # New audio setup

func setup_audio_manager():
    """Setup audio manager reference"""
    if Global.audio_manager:
        audio_manager = Global.audio_manager
        GameLogger.info("🎵 Audio manager connected to MainMenuController")
    else:
        GameLogger.warning("⚠️ Audio manager not found in Global, using fallback signals")

func play_button_sound():
    # Play button sound using both systems for compatibility
    if button_sound and button_sound.stream:
        button_sound.play()
    
    # Also use the enhanced audio manager if available
    if audio_manager:
        audio_manager.play_menu_audio("button_click")
    else:
        # Fallback to GlobalSignals if audio manager not available
        GlobalSignals.on_play_menu_audio.emit("button_click")

func _on_explore_3d_map_pressed():
    play_button_sound()
    # Play special audio for starting the game
    if audio_manager:
        audio_manager.play_menu_audio("start_game")
    show_3d_map_final()

func _on_indonesia_barat_pressed():
    if is_zooming:
        return
    play_button_sound()
    # Play region selection audio
    if audio_manager:
        audio_manager.play_menu_audio("region_select")
    zoom_to_region("Indonesia Barat", get_scene_from_config("Indonesia Barat"))
```

### **2. Player Movement Integration**

#### **PlayerControllerFixed.gd Integration**
```gdscript
# Footstep audio system variables
var footstep_timer: float = 0.0
var footstep_interval: float = 0.5
var current_surface_type: String = "grass"
var last_position: Vector3 = Vector3.ZERO
var movement_threshold: float = 0.1

func _physics_process(delta):
    _handle_movement(delta)
    _handle_camera(delta)
    _handle_footstep_audio(delta)  # New footstep audio

func _handle_footstep_audio(delta):
    """Handle footstep audio based on player movement"""
    if not is_on_ground:
        return
    
    # Update footstep timer
    footstep_timer += delta
    
    # Check if player is moving
    var current_position = global_position
    var movement_distance = current_position.distance_to(last_position)
    
    if movement_distance > movement_threshold:
        # Player is moving, check if it's time for a footstep
        if footstep_timer >= footstep_interval:
            # Trigger footstep audio
            GlobalSignals.on_play_footstep_audio.emit()
            
            # Update running state for audio manager
            GlobalSignals.on_set_running_state.emit(is_running)
            
            # Reset timer
            footstep_timer = 0.0
            
            # Update last position
            last_position = current_position
            
            if debug_mode:
                GameLogger.debug("Footstep triggered - Surface: " + current_surface_type + ", Running: " + str(is_running))
    else:
        # Player is not moving, reset timer
        footstep_timer = 0.0

func _on_jump():
    """Handle jump audio"""
    GlobalSignals.on_play_player_audio.emit("jump")
    
    if debug_mode:
        GameLogger.debug("Jump audio triggered")

func _on_land():
    """Handle landing audio"""
    GlobalSignals.on_play_player_audio.emit("land")
    
    if debug_mode:
        GameLogger.debug("Landing audio triggered")
```

### **3. Inventory System Integration**

#### **CulturalInventory.gd Integration**
```gdscript
func toggle_window(open: bool):
    inventory_window.visible = open
    
    if open:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        mouse_filter = Control.MOUSE_FILTER_STOP
        update_display()
        # Play inventory open sound
        GlobalSignals.on_play_ui_audio.emit("inventory_open")
    else:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        mouse_filter = Control.MOUSE_FILTER_IGNORE
        # Play inventory close sound
        GlobalSignals.on_play_ui_audio.emit("inventory_close")

func add_cultural_artifact(artifact: CulturalItem, region: String):
    # ... existing code ...
    
    if not artifact.display_name in collected_artifacts[region]:
        collected_artifacts[region].append(artifact.display_name)
        collected_count += 1
        GameLogger.info("Added to collected artifacts: " + artifact.display_name + " (Total count: " + str(collected_count) + ")")
        
        # Play success audio for item collection
        GlobalSignals.on_play_ui_audio.emit("success")
    else:
        GameLogger.debug("Artifact already in collection: " + artifact.display_name)
```

### **4. Cultural Item Integration**

#### **WorldCulturalItem.gd Integration**
```gdscript
func collect_item():
    if is_collected:
        return
    
    is_collected = true
    can_interact = false
    
    GameLogger.info("=== COLLECTING ARTIFACT ===")
    GameLogger.info("Item name: " + item_name)
    GameLogger.info("Cultural region: " + cultural_region)
    
    # Load the cultural item resource
    var item_path = "res://Systems/Items/ItemData/" + item_name + ".tres"
    GameLogger.debug("Item path: " + item_path)
    GameLogger.debug("Resource exists: " + str(ResourceLoader.exists(item_path)))
    
    if ResourceLoader.exists(item_path):
        var _item = load(item_path)
        GameLogger.debug("Loaded item resource: " + str(_item))
        
        # Add to player inventory
        GameLogger.debug("Calling Global.collect_artifact...")
        Global.collect_artifact(cultural_region, item_name)
        
        # Emit collection signal
        GlobalSignals.on_collect_artifact.emit(item_name, cultural_region)
        
        # Play collection effects
        play_collection_effects()
        
        # Hide the item
        visible = false
        call_deferred("_disable_collision")
        
        # Show collection message
        show_collection_message(item_name)
    else:
        GameLogger.warning("Cultural item resource not found: " + item_path)

func play_collection_effects():
    # Play collection sound
    if collection_sound:
        var audio_player = AudioStreamPlayer3D.new()
        audio_player.stream = collection_sound
        audio_player.volume_db = -10.0
        add_child(audio_player)
        audio_player.play()
        
        # Remove audio player after playing
        await audio_player.finished
        audio_player.queue_free()
    
    # Play collection animation if available
    if collection_animation:
        var anim_instance = collection_animation.instantiate()
        add_child(anim_instance)
        await get_tree().create_timer(2.0).timeout
        anim_instance.queue_free()
```

## 🎯 **Signal Integration**

### **GlobalSignals.gd Audio Signals**
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

### **CulturalAudioManager.gd Signal Handling**
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

# Signal handlers
func _on_play_menu_audio(audio_id: String):
    play_menu_audio(audio_id)

func _on_play_footstep_audio():
    play_footstep_audio()

func _on_play_ui_audio(audio_id: String):
    play_ui_audio(audio_id)

func _on_play_player_audio(action: String):
    play_player_audio(action)

func _on_set_surface_type(surface_type: String):
    current_surface_type = surface_type
    GameLogger.debug("Surface type changed to: " + surface_type)

func _on_set_running_state(running: bool):
    is_running = running
    footstep_interval = 0.3 if running else 0.5
    GameLogger.debug("Running state changed to: " + str(running))
```

## 🔧 **Audio Scene Integration**

### **CulturalAudioManager.tscn Structure**
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

### **Global.gd Integration**
```gdscript
# System references
var cultural_inventory: CulturalInventory
var audio_manager: CulturalAudioManager  # Audio manager reference

func _ready():
    # Initialize audio manager
    if not audio_manager:
        var audio_manager_scene = preload("res://Systems/Audio/CulturalAudioManager.tscn")
        audio_manager = audio_manager_scene.instantiate()
        add_child(audio_manager)
        GameLogger.info("Audio manager initialized in Global")
```

## 🎮 **Game Scene Integration**

### **Main Scene Setup**
```gdscript
# In main game scenes (TamboraRoot.tscn, PapuaScene_Manual.tscn)
# Add CulturalAudioManager as child node
# Connect to Global.audio_manager reference

func _ready():
    # Setup audio manager reference
    if Global.audio_manager:
        GameLogger.info("Audio manager available in scene")
    else:
        GameLogger.warning("Audio manager not found in Global")
```

### **Region Scene Integration**
```gdscript
# In RegionSceneController.gd
func _ready():
    # Start region-specific ambient audio
    if Global.audio_manager:
        var region_name = get_region_name()
        GlobalSignals.on_region_audio_change.emit(region_name, "ambient")
        GameLogger.info("Started ambient audio for region: " + region_name)
```

## 🔧 **Testing and Debugging**

### **Audio System Testing**
```gdscript
# Test function for audio system
func test_audio_system():
    GameLogger.info("=== AUDIO SYSTEM TEST ===")
    
    # Test menu audio
    GlobalSignals.on_play_menu_audio.emit("button_click")
    await get_tree().create_timer(0.5).timeout
    
    # Test footstep audio
    GlobalSignals.on_play_footstep_audio.emit()
    await get_tree().create_timer(0.5).timeout
    
    # Test UI audio
    GlobalSignals.on_play_ui_audio.emit("success")
    await get_tree().create_timer(0.5).timeout
    
    # Test player audio
    GlobalSignals.on_play_player_audio.emit("jump")
    await get_tree().create_timer(0.5).timeout
    
    GameLogger.info("Audio system test completed")
```

### **Debug Audio Manager**
```gdscript
func debug_audio_manager():
    if Global.audio_manager:
        GameLogger.info("Audio Manager Status:")
        GameLogger.info("  Current Region: " + Global.audio_manager.get_current_region())
        GameLogger.info("  Ambient Playing: " + str(Global.audio_manager.is_ambient_playing))
        GameLogger.info("  Audio Playing: " + str(Global.audio_manager.is_audio_playing()))
    else:
        GameLogger.error("Audio manager not available")
```

## 📊 **Integration Checklist**

### **Phase 1: Core Integration**
- [ ] CulturalAudioManager scene added to main scenes
- [ ] GlobalSignals audio signals connected
- [ ] Player controller footstep system integrated
- [ ] Main menu audio integration complete

### **Phase 2: System Integration**
- [ ] Inventory system audio integration
- [ ] Cultural item collection audio
- [ ] Region transition audio
- [ ] NPC interaction audio (future)

### **Phase 3: Polish and Testing**
- [ ] Audio system testing complete
- [ ] Volume levels optimized
- [ ] Error handling verified
- [ ] Performance testing done

## 🎯 **Performance Considerations**

### **Audio Loading Optimization**
- Use .tres resources for better caching
- Implement audio preloading for critical sounds
- Monitor memory usage with large audio files
- Use appropriate compression settings

### **Signal Performance**
- Minimize signal emissions in tight loops
- Use debouncing for frequent events (footsteps)
- Cache audio resources to avoid repeated loading
- Implement audio pooling for repeated sounds

## 🔮 **Future Integration Plans**

### **Advanced Features**
- **3D Spatial Audio**: Positional sound for NPCs and objects
- **Dynamic Audio Mixing**: Context-aware volume adjustments
- **Audio Streaming**: Large file management
- **Multi-language Support**: Localized audio content

### **Integration Expansion**
- **Weather System**: Environmental audio effects
- **Time-based Audio**: Day/night audio variations
- **Player State Audio**: Health, energy, status sounds
- **Achievement Audio**: Progress and completion sounds
