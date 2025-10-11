extends Node

# Helper script that adds friend's NPC improvements without breaking existing code
# This provides emergency dialogue clearing and debugging tools for Papua NPCs

# Static function to force clear all dialogue states across all NPCs
static func emergency_clear_all_dialogues():
	"""Emergency function to clear all dialogue states across all NPCs"""
	GameLogger.warning("=== EMERGENCY CLEAR ALL DIALOGUES ===")
	
	# Clear the static active dialogue NPC from CulturalNPC
	if CulturalNPC.active_dialogue_npc != null:
		if is_instance_valid(CulturalNPC.active_dialogue_npc):
			GameLogger.info("Force closing dialogue from: " + CulturalNPC.active_dialogue_npc.npc_name)
			# Force close without checks
			var ui = CulturalNPC.active_dialogue_npc.get_node_or_null("DialogueUI")
			if ui:
				ui.queue_free()
				GameLogger.info("DialogueUI queued for removal")
		else:
			GameLogger.info("Active dialogue NPC was invalid, clearing reference")
		CulturalNPC.active_dialogue_npc = null
	else:
		GameLogger.debug("No active dialogue NPC to clear")
	
	# Also try to clear any stuck dialogue UI in the scene
	var scene_tree = Engine.get_main_loop()
	if scene_tree and scene_tree is SceneTree:
		var root = scene_tree.root
		var stuck_ui = root.get_node_or_null("DialogueUI")
		if stuck_ui:
			GameLogger.info("Found stuck DialogueUI in scene, removing...")
			stuck_ui.queue_free()
	
	GameLogger.info("All dialogue states cleared - ready for fresh start")

# Static function to debug current dialogue state
static func debug_dialogue_state():
	"""Debug function to print current dialogue state"""
	GameLogger.info("=== DIALOGUE STATE DEBUG ===")
	GameLogger.info("Active dialogue NPC: " + (CulturalNPC.active_dialogue_npc.npc_name if CulturalNPC.active_dialogue_npc != null and is_instance_valid(CulturalNPC.active_dialogue_npc) else "None"))
	GameLogger.info("=========================")

# Function to check if any NPCs are stuck in dialogue state
static func check_stuck_npcs():
	"""Check for NPCs that might be stuck in dialogue state"""
	GameLogger.info("=== CHECKING FOR STUCK NPCS ===")
	
	var scene_tree = Engine.get_main_loop()
	if not scene_tree or not scene_tree is SceneTree:
		GameLogger.warning("Cannot access scene tree")
		return
	
	var root = scene_tree.root
	var all_npcs = root.get_nodes_in_group("npc")
	
	var stuck_count = 0
	for npc in all_npcs:
		if npc.has_method("get") and npc.get("can_interact"):
			if not npc.can_interact and npc.get("dialogue_just_ended"):
				var time_since_end = Time.get_unix_time_from_system() - npc.dialogue_end_time
				if time_since_end > 5.0:  # Stuck for more than 5 seconds
					GameLogger.warning("Found stuck NPC: " + str(npc.npc_name) + " (stuck for " + str(time_since_end) + "s)")
					stuck_count += 1
	
	if stuck_count == 0:
		GameLogger.info("No stuck NPCs found")
	else:
		GameLogger.warning("Found " + str(stuck_count) + " stuck NPC(s)")
	
	GameLogger.info("================================")

# Function to reset all NPC interaction states
static func reset_all_npc_states():
	"""Reset all NPC interaction states to prevent stuck dialogues"""
	GameLogger.info("=== RESETTING ALL NPC STATES ===")
	
	var scene_tree = Engine.get_main_loop()
	if not scene_tree or not scene_tree is SceneTree:
		GameLogger.warning("Cannot access scene tree")
		return
	
	var root = scene_tree.root
	var all_npcs = root.get_nodes_in_group("npc")
	
	var reset_count = 0
	for npc in all_npcs:
		if npc.has_method("get"):
			# Reset interaction flags
			if npc.has_method("set"):
				if npc.get("can_interact") != null:
					npc.can_interact = true
				if npc.get("dialogue_just_ended") != null:
					npc.dialogue_just_ended = false
				if npc.get("dialogue_end_time") != null:
					npc.dialogue_end_time = 0.0
				reset_count += 1
	
	GameLogger.info("Reset " + str(reset_count) + " NPC interaction states")
	GameLogger.info("=================================")

# Function to list all NPCs in the current scene
static func list_all_npcs():
	"""List all NPCs currently in the scene"""
	GameLogger.info("=== LISTING ALL NPCS ===")
	
	var scene_tree = Engine.get_main_loop()
	if not scene_tree or not scene_tree is SceneTree:
		GameLogger.warning("Cannot access scene tree")
		return
	
	var root = scene_tree.root
	var all_npcs = root.get_nodes_in_group("npc")
	
	GameLogger.info("Found " + str(all_npcs.size()) + " NPC(s) in scene:")
	for i in range(all_npcs.size()):
		var npc = all_npcs[i]
		var npc_name = "Unknown"
		var npc_region = "Unknown"
		var can_interact = "Unknown"
		
		if npc.has_method("get"):
			npc_name = npc.get("npc_name", "Unknown")
			npc_region = npc.get("cultural_region", "Unknown")
			can_interact = str(npc.get("can_interact", "Unknown"))
		
		GameLogger.info("  " + str(i + 1) + ". " + npc_name + " (" + npc_region + ") - Can Interact: " + can_interact)
	
	GameLogger.info("========================")

# Function to safely start dialogue with any NPC
static func safe_start_dialogue(npc: CulturalNPC):
	"""Safely start dialogue with an NPC, clearing any stuck states first"""
	if not npc:
		GameLogger.warning("PapuaNPCHelper: Cannot start dialogue - NPC is null")
		return false
	
	# Clear any stuck states first
	emergency_clear_all_dialogues()
	
	# Reset the specific NPC
	if npc.has_method("set"):
		npc.can_interact = true
		npc.dialogue_just_ended = false
		npc.dialogue_end_time = 0.0
	
	# Start dialogue
	if npc.has_method("start_visual_dialogue"):
		GameLogger.info("PapuaNPCHelper: Starting dialogue with " + npc.npc_name)
		npc.start_visual_dialogue()
		return true
	else:
		GameLogger.warning("PapuaNPCHelper: NPC does not have start_visual_dialogue method")
		return false

# Function to test Papua NPC functionality
static func test_papua_npcs():
	"""Test function specifically for Papua NPCs"""
	GameLogger.info("=== TESTING PAPUA NPCS ===")
	
	var scene_tree = Engine.get_main_loop()
	if not scene_tree or not scene_tree is SceneTree:
		GameLogger.warning("Cannot access scene tree")
		return
	
	var root = scene_tree.root
	var all_npcs = root.get_nodes_in_group("npc")
	
	var papua_npcs = []
	for npc in all_npcs:
		if npc.has_method("get") and npc.get("cultural_region") == "Indonesia Timur":
			papua_npcs.append(npc)
	
	GameLogger.info("Found " + str(papua_npcs.size()) + " Papua NPC(s):")
	for npc in papua_npcs:
		var npc_name = npc.get("npc_name", "Unknown")
		var npc_type = npc.get("npc_type", "Unknown")
		var can_interact = npc.get("can_interact", false)
		GameLogger.info("  - " + npc_name + " (" + npc_type + ") - Can Interact: " + str(can_interact))
	
	GameLogger.info("===========================")

# Function to be called when scene changes to reset dialogue state
static func on_scene_change():
	"""Call this when changing scenes to reset dialogue state"""
	GameLogger.info("PapuaNPCHelper: Scene change detected, clearing dialogue states")
	emergency_clear_all_dialogues()
	reset_all_npc_states()
