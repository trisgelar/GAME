class_name DialogueNode
extends Resource

## Dialogue Node - Individual dialogue entry
## Represents a single dialogue interaction with options

@export var node_id: String = ""
@export var message: String = ""
@export var speaker: String = "NPC"
@export var dialogue_options: Array[DialogueOption] = []
@export var conditions: Array[String] = []  # For conditional dialogue
@export var consequences: Array[String] = []  # Actions to trigger
@export var dialogue_type: String = "short"  # "short" for quick text, "long" for story with audio
@export var audio_file: String = ""  # Path to audio file for long stories
@export var audio_duration: float = 0.0  # Duration in seconds (for UI timing)

# Helper function to get option by index
func get_option(index: int) -> DialogueOption:
	if index >= 0 and index < dialogue_options.size():
		return dialogue_options[index]
	return null

# Helper function to get available options
func get_available_options() -> Array[DialogueOption]:
	var available = []
	for option in dialogue_options:
		if option.is_available:
			available.append(option)
	return available
