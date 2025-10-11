class_name DialogueResource
extends Resource

## Dialogue Resource - Main container for NPC dialogues
## This resource holds all dialogue data for a specific NPC or dialogue type

@export var dialogue_id: String = ""
@export var npc_name: String = ""
@export var dialogue_type: String = "general"  # general, quest, vendor, historian, guide
@export var cultural_region: String = ""
@export var dialogue_nodes: Array[DialogueNode] = []

# Helper function to find dialogue by ID
func get_dialogue_by_id(id: String) -> DialogueNode:
	for node in dialogue_nodes:
		if node.node_id == id:
			return node
	return null

# Helper function to get starting dialogue
func get_start_dialogue() -> DialogueNode:
	if dialogue_nodes.size() > 0:
		return dialogue_nodes[0]
	return null

# Convert to old format for compatibility
func to_legacy_format() -> Array[Dictionary]:
	var legacy_data = []
	
	for node in dialogue_nodes:
		var dialogue_dict = {
			"id": node.node_id,
			"message": node.message,
			"options": []
		}
		
		# Add new audio support fields
		if node.dialogue_type == "long":
			dialogue_dict["dialogue_type"] = "long"
			dialogue_dict["audio_file"] = node.audio_file
			dialogue_dict["audio_duration"] = node.audio_duration
		else:
			dialogue_dict["dialogue_type"] = "short"
		
		for option in node.dialogue_options:
			if option.is_available:
				var option_dict = {
					"text": option.option_text,
					"next_dialogue": option.next_dialogue_id,
					"consequence": option.consequence
				}
				
				if option.required_item != "":
					option_dict["required_item"] = option.required_item
				
				dialogue_dict.options.append(option_dict)
		
		legacy_data.append(dialogue_dict)
	
	return legacy_data
