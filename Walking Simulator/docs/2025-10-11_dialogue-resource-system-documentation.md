# Dialogue Resource System Documentation

**Created:** 2025-10-11  
**Purpose:** Complete documentation of the resource-based dialogue system with audio support

---

## 📋 **Table of Contents**

1. [System Overview](#system-overview)
2. [Resource Classes](#resource-classes)
3. [Audio Support](#audio-support)
4. [File Structure](#file-structure)
5. [Implementation Guide](#implementation-guide)
6. [Usage Examples](#usage-examples)
7. [API Reference](#api-reference)
8. [Troubleshooting](#troubleshooting)

---

## 🎯 **System Overview**

### **What is the Dialogue Resource System?**

The Dialogue Resource System is a Godot-based solution that replaces hard-coded dialogues with visual, resource-based dialogue management. It supports both short text communications and long audio stories, making it perfect for educational and immersive game experiences.

### **Key Features:**

✅ **Visual Editor** - Edit dialogues in Godot Inspector  
✅ **Audio Support** - Long stories with voice narration  
✅ **Resource-Based** - Separate `.tres` files for each NPC  
✅ **Backward Compatible** - Works with existing CulturalNPC system  
✅ **Type Safety** - Built-in validation and error checking  
✅ **Scalable** - Easy to add new NPCs and dialogues  

### **Benefits Over Hard-Coded System:**

| Aspect | Old System | New System |
|--------|------------|------------|
| **Editing** | Code only (2232 lines) | Visual Inspector |
| **Audio** | Not supported | Full audio integration |
| **Maintenance** | Difficult | Easy |
| **Collaboration** | Code conflicts | Designers can edit |
| **Reusability** | None | High |
| **Localization** | Hard | Easy |

---

## 🏗️ **Resource Classes**

### **1. DialogueResource.gd**

**Purpose:** Main container for all dialogue data for a specific NPC.

```gdscript
class_name DialogueResource
extends Resource

@export var dialogue_id: String = ""
@export var npc_name: String = ""
@export var dialogue_type: String = "general"
@export var cultural_region: String = ""
@export var dialogue_nodes: Array[DialogueNode] = []
```

**Key Methods:**
- `get_dialogue_by_id(id: String)` - Find specific dialogue
- `get_start_dialogue()` - Get initial dialogue
- `to_legacy_format()` - Convert to old system format

### **2. DialogueNode.gd**

**Purpose:** Individual dialogue entry with message and options.

```gdscript
class_name DialogueNode
extends Resource

@export var node_id: String = ""
@export var message: String = ""
@export var speaker: String = "NPC"
@export var dialogue_options: Array[DialogueOption] = []
@export var conditions: Array[String] = []
@export var consequences: Array[String] = []
@export var dialogue_type: String = "short"  # "short" or "long"
@export var audio_file: String = ""
@export var audio_duration: float = 0.0
```

**Key Methods:**
- `get_option(index: int)` - Get dialogue option by index
- `get_available_options()` - Get only available options

### **3. DialogueOption.gd**

**Purpose:** Player choice in dialogue.

```gdscript
class_name DialogueOption
extends Resource

@export var option_text: String = ""
@export var next_dialogue_id: String = ""
@export var consequence: String = ""
@export var required_item: String = ""
@export var is_available: bool = true
@export var condition_description: String = ""
```

---

## 🎵 **Audio Support**

### **Dialogue Types:**

#### **Short Dialogues** (`dialogue_type: "short"`)
- **Purpose:** Quick text communications
- **Audio:** None required
- **Use Case:** Greetings, simple questions, quick responses
- **Example:** "Hello! How can I help you?"

#### **Long Stories** (`dialogue_type: "long"`)
- **Purpose:** Rich storytelling with audio narration
- **Audio:** Required audio file
- **Use Case:** Historical stories, detailed explanations, immersive content
- **Example:** "Let me tell you about the 1815 eruption..." (with 45-second audio)

### **Audio File Requirements:**

| Property | Specification | Notes |
|----------|---------------|-------|
| **Format** | `.wav`, `.mp3`, `.ogg` | Godot supported formats |
| **Quality** | 44.1kHz, 16-bit minimum | Good quality for speech |
| **Duration** | 30-60 seconds recommended | Match `audio_duration` field |
| **Naming** | Exact filenames as specified | Critical for resource loading |
| **Location** | `Assets/Audio/Dialog/` | Fixed directory structure |

### **Audio Integration Flow:**

```
1. Player selects dialogue option
2. System checks dialogue_type
3. If "long": Load audio file + display text
4. If "short": Display text only
5. Audio plays automatically (if available)
6. UI shows progress/controls
```

---

## 📁 **File Structure**

### **Complete Directory Structure:**

```
Walking Simulator/
├── Systems/NPCs/Dialogue/
│   ├── DialogueResource.gd
│   ├── DialogueNode.gd
│   └── DialogueOption.gd
├── Resources/Dialogues/
│   └── Tambora/
│       ├── DrHeinrichDialogue.tres
│       ├── DrSariDialogue.tres
│       ├── PakBudiDialogue.tres
│       ├── IbuMayaDialogue.tres
│       ├── DrAhmadDialogue.tres
│       └── PakKarsaDialogue.tres
├── Assets/Audio/Dialog/
│   ├── dr_heinrich_expedition_story.wav
│   ├── dr_heinrich_local_warnings.wav
│   ├── dr_heinrich_summit_discoveries.wav
│   ├── dr_sari_current_monitoring.wav
│   ├── dr_sari_vei7_significance.wav
│   ├── pak_budi_eruption_story.wav
│   ├── pak_budi_kingdom_destruction.wav
│   ├── ibu_maya_spiritual_beliefs.wav
│   ├── ibu_maya_protection_rituals.wav
│   ├── dr_ahmad_year_without_summer.wav
│   ├── dr_ahmad_global_climate_effects.wav
│   ├── dr_ahmad_cultural_impact.wav
│   ├── pak_karsa_climbing_routes.wav
│   └── pak_karsa_safety_protocols.wav
└── Systems/NPCs/CulturalNPC.gd (modified)
```

### **Resource File Naming Convention:**

```
[CharacterName]Dialogue.tres

Examples:
- DrHeinrichDialogue.tres
- DrSariDialogue.tres
- PakBudiDialogue.tres
```

### **Audio File Naming Convention:**

```
[character_name]_[dialogue_topic].wav

Examples:
- dr_heinrich_expedition_story.wav
- pak_budi_eruption_story.wav
- ibu_maya_spiritual_beliefs.wav
```

---

## 🛠️ **Implementation Guide**

### **Step 1: Setup Resource Classes**

1. **Create dialogue directory:**
   ```
   mkdir Systems/NPCs/Dialogue/
   ```

2. **Add resource scripts:**
   - `DialogueResource.gd`
   - `DialogueNode.gd`
   - `DialogueOption.gd`

3. **Modify CulturalNPC.gd:**
   - Add `dialogue_resource` export property
   - Add `load_dialogue_from_resource()` method
   - Update `_ready()` method

### **Step 2: Create Dialogue Resources**

1. **In Godot Editor:**
   - Right-click in FileSystem → **New Resource**
   - Choose **DialogueResource**
   - Save with descriptive name

2. **Configure basic properties:**
   ```
   dialogue_id: "character_scene"
   npc_name: "Display Name"
   dialogue_type: "guide/historian/vendor"
   cultural_region: "Indonesia Tengah/Timur/Barat"
   ```

3. **Add dialogue nodes:**
   - Set **dialogue_nodes** array size
   - Configure each node with message and options

### **Step 3: Setup Audio Files**

1. **Create audio directory:**
   ```
   mkdir Assets/Audio/Dialog/
   ```

2. **Add audio files:**
   - Use exact filenames as specified
   - Ensure proper format and quality
   - Match durations with `audio_duration` field

3. **Configure audio in dialogue nodes:**
   ```
   dialogue_type: "long"
   audio_file: "res://Assets/Audio/Dialog/filename.wav"
   audio_duration: 45.0
   ```

### **Step 4: Assign Resources to NPCs**

1. **Select NPC in scene**
2. **In Inspector, find `dialogue_resource` property**
3. **Load respective `.tres` file**
4. **Test dialogue system**

---

## 💡 **Usage Examples**

### **Example 1: Creating a Short Dialogue**

```gdscript
# In DialogueResource.tres
dialogue_nodes = [{
    "node_id": "greeting",
    "message": "Hello! How can I help you?",
    "speaker": "NPC",
    "dialogue_type": "short",
    "dialogue_options": [
        {
            "option_text": "Tell me about the volcano",
            "next_dialogue_id": "volcano_info",
            "consequence": "share_knowledge"
        },
        {
            "option_text": "Goodbye",
            "consequence": "end_conversation"
        }
    ]
}]
```

### **Example 2: Creating a Long Story with Audio**

```gdscript
# In DialogueResource.tres
dialogue_nodes = [{
    "node_id": "volcano_info",
    "message": "Let me tell you about the 1815 eruption...",
    "speaker": "Dr. Heinrich",
    "dialogue_type": "long",
    "audio_file": "res://Assets/Audio/Dialog/dr_heinrich_expedition_story.wav",
    "audio_duration": 45.0,
    "dialogue_options": [
        {
            "option_text": "That's fascinating!",
            "consequence": "end_conversation"
        }
    ]
}]
```

### **Example 3: Loading Dialogue in CulturalNPC**

```gdscript
# In CulturalNPC.gd
func _ready():
    # ... existing code ...
    
    # Load dialogue from resource or use default
    if dialogue_resource:
        load_dialogue_from_resource()
    elif dialogue_data.is_empty():
        setup_default_dialogue()

func load_dialogue_from_resource():
    if not dialogue_resource:
        return
    
    dialogue_data.clear()
    dialogue_data = dialogue_resource.to_legacy_format()
    update_quest_dialogue_options()
```

---

## 📚 **API Reference**

### **DialogueResource Methods:**

#### `get_dialogue_by_id(id: String) -> DialogueNode`
**Description:** Find dialogue node by ID  
**Parameters:** `id` - Dialogue node identifier  
**Returns:** DialogueNode or null if not found  
**Example:**
```gdscript
var dialogue = resource.get_dialogue_by_id("greeting")
```

#### `get_start_dialogue() -> DialogueNode`
**Description:** Get the first dialogue node  
**Returns:** First DialogueNode or null if empty  
**Example:**
```gdscript
var start = resource.get_start_dialogue()
```

#### `to_legacy_format() -> Array[Dictionary]`
**Description:** Convert to old system format for compatibility  
**Returns:** Array of dictionaries in old format  
**Example:**
```gdscript
var legacy_data = resource.to_legacy_format()
```

### **DialogueNode Methods:**

#### `get_option(index: int) -> DialogueOption`
**Description:** Get dialogue option by index  
**Parameters:** `index` - Option index (0-based)  
**Returns:** DialogueOption or null if invalid  
**Example:**
```gdscript
var option = node.get_option(0)
```

#### `get_available_options() -> Array[DialogueOption]`
**Description:** Get only available dialogue options  
**Returns:** Array of available DialogueOptions  
**Example:**
```gdscript
var available = node.get_available_options()
```

### **CulturalNPC Integration:**

#### `load_dialogue_from_resource()`
**Description:** Load dialogue data from assigned resource  
**Usage:** Called automatically in `_ready()` if resource is assigned  
**Example:**
```gdscript
# Assigned in Inspector, called automatically
```

---

## 🔧 **Troubleshooting**

### **Common Issues and Solutions:**

#### **Issue 1: Audio Not Playing**
**Symptoms:** Long dialogues show text but no audio  
**Causes:**
- Audio file not found
- Incorrect file path
- Unsupported audio format

**Solutions:**
1. Check file exists in `Assets/Audio/Dialog/`
2. Verify path in `audio_file` field
3. Ensure audio format is supported (.wav, .mp3, .ogg)
4. Check console for loading errors

#### **Issue 2: Dialogue Not Loading**
**Symptoms:** NPC shows default dialogue instead of resource  
**Causes:**
- Resource not assigned
- Resource file corrupted
- Incorrect resource type

**Solutions:**
1. Verify `dialogue_resource` is assigned in Inspector
2. Check resource file exists and is saved
3. Ensure resource type is `DialogueResource`
4. Restart Godot if needed

#### **Issue 3: Dialogue Options Not Working**
**Symptoms:** Options don't lead to next dialogue  
**Causes:**
- Incorrect `next_dialogue_id`
- Missing dialogue node
- Typo in node ID

**Solutions:**
1. Verify `next_dialogue_id` matches existing `node_id`
2. Check all referenced dialogues exist
3. Ensure no typos in IDs

#### **Issue 4: Resource Not Saving**
**Symptoms:** Changes to dialogue resource don't persist  
**Causes:**
- Resource not saved
- File permissions issue
- Godot editor issue

**Solutions:**
1. Press Ctrl+S to save resource
2. Check file permissions
3. Restart Godot editor
4. Recreate resource if corrupted

### **Debug Checklist:**

- [ ] Resource file exists and is saved
- [ ] Audio files exist in correct directory
- [ ] File paths are correct (use `res://` prefix)
- [ ] Dialogue IDs match between options and nodes
- [ ] NPC has `dialogue_resource` assigned
- [ ] Console shows no loading errors
- [ ] Audio format is supported
- [ ] Resource type is `DialogueResource`

### **Performance Considerations:**

1. **Audio Loading:** Audio files are loaded on-demand
2. **Memory Usage:** Resources are cached by Godot
3. **File Size:** Keep audio files reasonable size (< 5MB each)
4. **Format:** Use compressed formats (.ogg) for smaller files

---

## 🎯 **Best Practices**

### **Dialogue Design:**

1. **Keep short dialogues brief** (1-2 sentences)
2. **Make long stories engaging** (30-60 seconds audio)
3. **Use clear dialogue IDs** (descriptive, consistent)
4. **Provide meaningful options** (3-4 choices maximum)
5. **Test all dialogue paths** (ensure no dead ends)

### **Audio Production:**

1. **Use consistent voice actors** for each character
2. **Maintain audio quality** (44.1kHz, 16-bit minimum)
3. **Keep files reasonably sized** (< 5MB each)
4. **Test audio playback** on target devices
5. **Provide text alternatives** for accessibility

### **Resource Management:**

1. **Use descriptive filenames** (character_scene.tres)
2. **Organize by scene/region** (Tambora/, Papua/, Pasar/)
3. **Version control resources** (separate from code)
4. **Backup dialogue files** regularly
5. **Document dialogue changes** for team

### **Code Integration:**

1. **Always check resource exists** before loading
2. **Handle missing audio gracefully** (fallback to text)
3. **Validate dialogue IDs** to prevent broken links
4. **Use consistent naming conventions**
5. **Test with and without audio files**

---

## 📈 **Future Enhancements**

### **Planned Features:**

1. **Visual Dialogue Editor** - Custom plugin for easier editing
2. **Localization Support** - Multiple language resources
3. **Conditional Dialogues** - Based on player progress/items
4. **Dialogue Analytics** - Track player choices and engagement
5. **Voice Synthesis** - Generate audio from text (optional)

### **Extension Points:**

1. **Custom Dialogue Types** - Beyond short/long
2. **Advanced Audio Features** - Background music, sound effects
3. **Dialogue Branching** - Complex conversation trees
4. **Integration with Quest System** - Dialogue-driven quests
5. **Accessibility Features** - Subtitles, text-to-speech

---

## 📋 **Summary**

The Dialogue Resource System provides a powerful, flexible solution for managing NPC dialogues in Godot. With support for both text and audio, it enables rich, immersive storytelling while maintaining ease of use for designers and developers.

### **Key Benefits:**
- **Visual editing** in Godot Inspector
- **Audio integration** for immersive experiences
- **Resource-based** architecture for scalability
- **Backward compatibility** with existing systems
- **Type safety** and validation

### **Perfect For:**
- Educational games with historical content
- Immersive storytelling experiences
- Multi-language projects
- Team collaboration on dialogue content
- Projects requiring rich NPC interactions

---

**Document Status:** ✅ Complete  
**Last Updated:** 2025-10-11  
**Author:** ISSAT Game Development Team  
**Version:** 1.0

---

*This documentation covers the complete Dialogue Resource System implementation. For specific implementation steps, refer to the Implementation Guide. For troubleshooting, see the Troubleshooting section above.*
