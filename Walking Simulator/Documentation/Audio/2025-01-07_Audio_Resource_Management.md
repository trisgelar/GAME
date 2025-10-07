# Audio Resource Management (.tres)
**Date:** 2025-01-07  
**Project:** Indonesian Cultural Heritage Exhibition  
**Version:** 1.0  

## 🎵 **Audio Resource System Overview**

### **Why Use .tres Files?**
- ✅ **Error Reduction**: Prevents missing file errors
- ✅ **Performance**: Faster loading and caching
- ✅ **Organization**: Centralized audio management
- ✅ **Flexibility**: Easy volume/pitch adjustments
- ✅ **Version Control**: Better Git integration
- ✅ **Editor Integration**: Visual resource management

### **Resource Structure**
```
Resources/Audio/
├── Menu/              # Menu audio resources
├── Player/            # Player audio resources
├── UI/                # UI audio resources
├── Ambient/           # Ambient audio resources
└── Effects/           # Effects audio resources
```

## 🔧 **AudioResource.gd Class**

### **Class Definition**
```gdscript
class_name AudioResource
extends Resource

@export var audio_stream: AudioStream
@export var volume_db: float = 0.0
@export var pitch_scale: float = 1.0
@export var loop: bool = false
@export var category: String = "general"
@export var description: String = ""

func get_audio_stream() -> AudioStream:
    return audio_stream

func get_volume_db() -> float:
    return volume_db

func get_pitch_scale() -> float:
    return pitch_scale

func is_looping() -> bool:
    return loop

func get_category() -> String:
    return category

func get_description() -> String:
    return description
```

### **Resource Properties**
- **audio_stream**: The actual audio file reference
- **volume_db**: Volume adjustment (-80dB to 0dB)
- **pitch_scale**: Pitch modification (0.1 to 4.0)
- **loop**: Whether audio should loop
- **category**: Audio category for organization
- **description**: Human-readable description

## 📁 **Resource File Templates**

### **Menu Audio Resources**

#### **UIHover.tres**
```xml
[gd_resource type="AudioResource" script_class="AudioResource" load_steps=2 format=3 uid="uid://b1h2j3k4l5m6n7"]

[ext_resource type="Script" path="res://Resources/Audio/AudioResource.gd" id="1_audio_resource"]

[resource]
script = ExtResource("1_audio_resource")
audio_stream = null
volume_db = -5.0
pitch_scale = 1.0
loop = false
category = "menu"
description = "UI hover sound for button interactions"
```

#### **UIClick.tres**
```xml
[gd_resource type="AudioResource" script_class="AudioResource" load_steps=2 format=3 uid="uid://c2i3j4k5l6m7n8"]

[ext_resource type="Script" path="res://Resources/Audio/AudioResource.gd" id="1_audio_resource"]

[resource]
script = ExtResource("1_audio_resource")
audio_stream = null
volume_db = -3.0
pitch_scale = 1.0
loop = false
category = "menu"
description = "UI click sound for button presses"
```

#### **StartGame.tres**
```xml
[gd_resource type="AudioResource" script_class="AudioResource" load_steps=2 format=3 uid="uid://d3j4k5l6m7n8o9"]

[ext_resource type="Script" path="res://Resources/Audio/AudioResource.gd" id="1_audio_resource"]

[resource]
script = ExtResource("1_audio_resource")
audio_stream = null
volume_db = -4.0
pitch_scale = 1.0
loop = false
category = "menu"
description = "Epic startup sound for game launch"
```

### **Player Audio Resources**

#### **FootstepGrass1.tres**
```xml
[gd_resource type="AudioResource" script_class="AudioResource" load_steps=2 format=3 uid="uid://e4k5l6m7n8o9p0"]

[ext_resource type="Script" path="res://Resources/Audio/AudioResource.gd" id="1_audio_resource"]

[resource]
script = ExtResource("1_audio_resource")
audio_stream = null
volume_db = -8.0
pitch_scale = 1.0
loop = false
category = "footstep"
description = "Footstep sound on grass surface - variation 1"
```

#### **Jump.tres**
```xml
[gd_resource type="AudioResource" script_class="AudioResource" load_steps=2 format=3 uid="uid://f5l6m7n8o9p0q1"]

[ext_resource type="Script" path="res://Resources/Audio/AudioResource.gd" id="1_audio_resource"]

[resource]
script = ExtResource("1_audio_resource")
audio_stream = null
volume_db = -6.0
pitch_scale = 1.0
loop = false
category = "player_action"
description = "Jump sound effect for player movement"
```

### **UI Audio Resources**

#### **Success.tres**
```xml
[gd_resource type="AudioResource" script_class="AudioResource" load_steps=2 format=3 uid="uid://g6m7n8o9p0q1r2"]

[ext_resource type="Script" path="res://Resources/Audio/AudioResource.gd" id="1_audio_resource"]

[resource]
script = ExtResource("1_audio_resource")
audio_stream = null
volume_db = -3.0
pitch_scale = 1.0
loop = false
category = "ui"
description = "Success sound for item collection and achievements"
```

#### **InventoryOpen.tres**
```xml
[gd_resource type="AudioResource" script_class="AudioResource" load_steps=2 format=3 uid="uid://h7n8o9p0q1r2s3"]

[ext_resource type="Script" path="res://Resources/Audio/AudioResource.gd" id="1_audio_resource"]

[resource]
script = ExtResource("1_audio_resource")
audio_stream = null
volume_db = -5.0
pitch_scale = 1.0
loop = false
category = "ui"
description = "Inventory opening sound"
```

### **Ambient Audio Resources**

#### **MarketAmbience.tres**
```xml
[gd_resource type="AudioResource" script_class="AudioResource" load_steps=2 format=3 uid="uid://i8o9p0q1r2s3t4"]

[ext_resource type="Script" path="res://Resources/Audio/AudioResource.gd" id="1_audio_resource"]

[resource]
script = ExtResource("1_audio_resource")
audio_stream = null
volume_db = -12.0
pitch_scale = 1.0
loop = true
category = "ambient"
description = "Traditional market ambience for Indonesia Barat region"
```

## 🔧 **Resource Loading System**

### **Audio Resource Manager**
```gdscript
class_name AudioResourceManager
extends Node

var audio_resources: Dictionary = {}

func _ready():
    load_all_audio_resources()

func load_all_audio_resources():
    var resource_dirs = [
        "res://Resources/Audio/Menu/",
        "res://Resources/Audio/Player/",
        "res://Resources/Audio/UI/",
        "res://Resources/Audio/Ambient/",
        "res://Resources/Audio/Effects/"
    ]
    
    for dir_path in resource_dirs:
        load_resources_from_directory(dir_path)

func load_resources_from_directory(dir_path: String):
    var dir = DirAccess.open(dir_path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if file_name.ends_with(".tres"):
                var resource_path = dir_path + file_name
                var audio_resource = load(resource_path) as AudioResource
                if audio_resource:
                    var resource_name = file_name.get_basename()
                    audio_resources[resource_name] = audio_resource
                    GameLogger.debug("Loaded audio resource: " + resource_name)
            file_name = dir.get_next()

func get_audio_resource(resource_name: String) -> AudioResource:
    return audio_resources.get(resource_name, null)

func play_audio_resource(resource_name: String, player: AudioStreamPlayer):
    var audio_resource = get_audio_resource(resource_name)
    if audio_resource:
        player.stream = audio_resource.get_audio_stream()
        player.volume_db = audio_resource.get_volume_db()
        player.pitch_scale = audio_resource.get_pitch_scale()
        player.play()
        GameLogger.debug("Playing audio resource: " + resource_name)
    else:
        GameLogger.warning("Audio resource not found: " + resource_name)
```

### **Enhanced Audio Manager Integration**
```gdscript
# In CulturalAudioManager.gd
var audio_resource_manager: AudioResourceManager

func _ready():
    setup_audio_players()
    connect_signals()
    setup_audio_resource_manager()
    GameLogger.info("🎵 Enhanced CulturalAudioManager initialized with comprehensive audio categories")

func setup_audio_resource_manager():
    audio_resource_manager = AudioResourceManager.new()
    add_child(audio_resource_manager)
    GameLogger.info("Audio resource manager initialized")

func play_menu_audio_from_resource(audio_id: String):
    var resource_name = audio_id.capitalize()  # "button_click" -> "ButtonClick"
    audio_resource_manager.play_audio_resource(resource_name, menu_player)
```

## 📋 **Resource Creation Workflow**

### **Step 1: Create Audio Files**
1. Record or find audio files
2. Convert to .ogg format
3. Place in `Assets/Audio/` directories
4. Test audio quality and volume

### **Step 2: Create Resource Files**
1. Create .tres file in appropriate `Resources/Audio/` directory
2. Set unique UID for each resource
3. Configure volume_db, pitch_scale, and loop settings
4. Add descriptive category and description

### **Step 3: Link Audio Streams**
1. Open .tres file in Godot editor
2. Drag .ogg file to audio_stream property
3. Save resource file
4. Test resource loading

### **Step 4: Integration Testing**
1. Test resource loading in game
2. Verify volume and pitch settings
3. Check for missing resources
4. Optimize performance

## 🎯 **Resource Naming Convention**

### **File Naming**
- **Resource Files**: PascalCase (e.g., `UIHover.tres`)
- **Audio Files**: snake_case (e.g., `ui_hover.ogg`)
- **Categories**: lowercase (e.g., "menu", "footstep", "ui")

### **UID Generation**
- Use unique UIDs for each resource
- Format: `uid://[random_string]`
- Generate using Godot's built-in UID system

### **Category Organization**
- **menu**: Menu and navigation audio
- **footstep**: Player movement sounds
- **player_action**: Jump, land, run sounds
- **ui**: Interface feedback sounds
- **ambient**: Background environmental audio
- **effects**: Cultural and interaction sounds

## 🔧 **Resource Optimization**

### **Volume Level Guidelines**
- **Loud**: -2dB to -4dB (important notifications)
- **Medium**: -5dB to -8dB (UI, footsteps)
- **Quiet**: -10dB to -15dB (ambient, background)

### **Pitch Scale Settings**
- **Normal**: 1.0 (default)
- **Higher**: 1.1-1.3 (lighter, faster feel)
- **Lower**: 0.7-0.9 (heavier, slower feel)

### **Loop Configuration**
- **SFX**: loop = false
- **Ambient**: loop = true
- **Music**: loop = true
- **UI**: loop = false

## 🐛 **Troubleshooting**

### **Common Issues**
1. **Missing Audio Stream**: Check file path and format
2. **Volume Too Loud/Quiet**: Adjust volume_db property
3. **Resource Not Loading**: Verify UID and file structure
4. **Performance Issues**: Check file sizes and compression

### **Debug Tools**
```gdscript
func debug_audio_resources():
    for resource_name in audio_resources:
        var resource = audio_resources[resource_name]
        GameLogger.info("Resource: " + resource_name + 
                       " | Volume: " + str(resource.get_volume_db()) + 
                       " | Category: " + resource.get_category())
```

## 📊 **Resource Statistics**

### **Total Resources by Category**
- **Menu**: 6 resources
- **Player**: 19 resources (15 footsteps + 4 actions)
- **UI**: 7 resources
- **Ambient**: 3 resources
- **Effects**: 4 resources
- **Total**: 39 audio resources

### **File Size Guidelines**
- **Resource Files**: < 1KB each
- **Audio Files**: < 2MB each
- **Total Project Audio**: < 50MB

## 🔮 **Future Enhancements**

### **Advanced Resource Features**
- **Dynamic Volume**: Context-aware volume adjustment
- **Audio Variants**: Multiple versions of same sound
- **Resource Pools**: Efficient memory management
- **Streaming Resources**: Large file handling

### **Resource Management Tools**
- **Audio Resource Editor**: Custom editor plugin
- **Batch Processing**: Automated resource creation
- **Resource Validation**: Automatic error checking
- **Performance Monitoring**: Resource usage tracking
