class_name DialogueOption
extends Resource

## Dialogue Option - Player choice in dialogue
## Represents a single choice the player can make

@export var option_text: String = ""
@export var next_dialogue_id: String = ""
@export var consequence: String = ""  # share_knowledge, end_conversation, complete_quest, etc.
@export var required_item: String = ""  # For quest-related options
@export var is_available: bool = true  # For conditional options
@export var condition_description: String = ""  # Human-readable condition
