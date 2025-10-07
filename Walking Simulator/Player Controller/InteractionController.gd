extends RayCast3D

@onready var interact_prompt_label : Label = get_node("InteractionPrompt")

# Interaction state
var current_interactable: CulturalInteractableObject = null
var is_near_interactable: bool = false

# Anti-flicker system
var last_interaction_time: float = 0.0
var interaction_cooldown: float = 0.1  # 100ms cooldown
var frame_count: int = 0

# State management to prevent reinteraction
var last_interacted_object: CulturalInteractableObject = null
var interaction_history: Dictionary = {}  # Track interaction times per object
var min_reinteraction_delay: float = 3.0  # Minimum 3 seconds between interactions with same object

# NPC interaction tracking
var npcs_in_range: Array[CulturalInteractableObject] = []
var nearest_npc: CulturalInteractableObject = null

func _ready():
	# Set up the prompt label styling
	setup_prompt_label()
	
	# Ensure prompt is hidden at startup
	if interact_prompt_label:
		interact_prompt_label.text = ""
		interact_prompt_label.visible = false
		GameLogger.info("Interaction prompt hidden at startup")
	
	GameLogger.info("InteractionController initialized")
	
	# Find all NPCs in the scene and connect to their signals
	# Use a longer delay to ensure NPCs are fully initialized
	call_deferred("setup_npc_tracking")
	# Also try again after a longer delay in case NPCs are created later
	get_tree().create_timer(1.0).timeout.connect(setup_npc_tracking)

func setup_npc_tracking():
	# Find all NPCs in the scene
	var npcs = get_tree().get_nodes_in_group("npc")
	GameLogger.info("Found " + str(npcs.size()) + " NPCs in 'npc' group")
	
	for npc in npcs:
		GameLogger.info("Processing NPC: " + npc.name)
		if npc is CulturalInteractableObject:
			# Connect to the NPC's interaction area signals
			var interaction_area = npc.get_node_or_null("InteractionArea")
			if interaction_area:
				# Check if signals are already connected to avoid duplicates
				if not interaction_area.body_entered.is_connected(_on_npc_area_entered):
					interaction_area.body_entered.connect(_on_npc_area_entered)
				if not interaction_area.body_exited.is_connected(_on_npc_area_exited):
					interaction_area.body_exited.connect(_on_npc_area_exited)
				GameLogger.info("Connected to NPC interaction area: " + npc.name)
			else:
				GameLogger.warning("NPC " + npc.name + " has no InteractionArea node")
		else:
			GameLogger.warning("Node " + npc.name + " is in 'npc' group but not a CulturalInteractableObject")

func _on_npc_area_entered(body: Node3D):
	# Find which NPC this area belongs to
	var interaction_area = body.get_parent()
	if not interaction_area or interaction_area.name != "InteractionArea":
		return
	
	var npc = interaction_area.get_parent()
	if not npc or not (npc is CulturalInteractableObject):
		return
	
	GameLogger.info("NPC area entered signal received for: " + npc.name)
	if not npcs_in_range.has(npc):
		npcs_in_range.append(npc)
		GameLogger.info("NPC added to range list: " + npc.name)
		update_nearest_npc()
	else:
		GameLogger.info("NPC already in range list: " + npc.name)

func _on_npc_area_exited(body: Node3D):
	# Find which NPC this area belongs to
	var interaction_area = body.get_parent()
	if not interaction_area or interaction_area.name != "InteractionArea":
		return
	
	var npc = interaction_area.get_parent()
	if not npc or not (npc is CulturalInteractableObject):
		return
	
	GameLogger.info("NPC area exited signal received for: " + npc.name)
	if npcs_in_range.has(npc):
		npcs_in_range.erase(npc)
		GameLogger.info("NPC removed from range list: " + npc.name)
		update_nearest_npc()
	else:
		GameLogger.info("NPC not in range list: " + npc.name)

func update_nearest_npc():
	var player = get_parent()
	if not player:
		return
	
	var nearest_distance = INF
	var previous_nearest = nearest_npc
	nearest_npc = null
	
	GameLogger.debug("Updating nearest NPC. NPCs in range: " + str(npcs_in_range.size()))
	
	for npc in npcs_in_range:
		if npc.can_interact:
			var distance = player.global_position.distance_to(npc.global_position)
			GameLogger.debug("NPC " + npc.name + " distance: " + str(distance) + "m")
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_npc = npc
	
	# DEBUG: Log the nearest NPC selection
	if nearest_npc:
		GameLogger.info("DEBUG: Selected nearest NPC: " + nearest_npc.name + " (distance: " + str(nearest_distance) + "m)")
	else:
		GameLogger.info("DEBUG: No NPCs in range")
		# Clear any NPC-related interactable
		if current_interactable and current_interactable is CulturalInteractableObject and previous_nearest:
			GameLogger.info("DEBUG: Clearing NPC interactable due to no NPCs in range")
			on_exit_interaction_range()
			current_interactable = null
			is_near_interactable = false
	
	# Update current interactable if we have a nearest NPC
	if nearest_npc and nearest_npc != current_interactable:
		if current_interactable:
			on_exit_interaction_range()
		current_interactable = nearest_npc
		is_near_interactable = true
		on_enter_interaction_range(nearest_npc)
		GameLogger.debug("Nearest NPC updated: " + nearest_npc.name)
	elif not nearest_npc and current_interactable is CulturalInteractableObject:
		# No NPCs in range, clear NPC interaction
		on_exit_interaction_range()
		current_interactable = null
		is_near_interactable = false
		GameLogger.debug("No NPCs in range, cleared interaction")

func setup_prompt_label():
	if interact_prompt_label:
		# Make the prompt more visible
		interact_prompt_label.add_theme_font_size_override("font_size", 24)
		interact_prompt_label.add_theme_color_override("font_color", Color.WHITE)
		interact_prompt_label.add_theme_color_override("font_shadow_color", Color.BLACK)
		interact_prompt_label.add_theme_constant_override("shadow_offset_x", 2)
		interact_prompt_label.add_theme_constant_override("shadow_offset_y", 2)
		interact_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		interact_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		# IMPORTANT: Hide the prompt initially - it should only show when near an NPC
		interact_prompt_label.text = ""
		interact_prompt_label.visible = false
		
		GameLogger.debug("Interaction prompt label styled and hidden initially")
	else:
		GameLogger.error("Interaction prompt label not found!")

func _process(_delta):
	frame_count += 1
	var current_time = Time.get_unix_time_from_system()
	
	# Check if we can process changes (anti-flicker)
	var can_process_changes = (current_time - last_interaction_time) >= interaction_cooldown
	
	# Clear previous interactable if we're not near anything
	var found_interactable = false
	var new_interactable = null
	
	# Fallback: Check for NPCs in range manually ONLY every 60 frames and if npcs_in_range is empty
	if npcs_in_range.is_empty() and frame_count % 60 == 0:
		GameLogger.debug("Running periodic fallback check for NPCs")
		check_for_npcs_in_range()
	
	# Priority 1: Check for raycast-based interactions (artifacts have priority over NPC)
	var object = get_collider()
	
	# Debug: Log collision detection (reduced spam)
	if object:
		GameLogger.debug("RayCast3D detected collision with: " + object.name + " (Type: " + object.get_class() + ")")
	
	# If raycast hits a StaticBody3D, check if its parent is a CulturalInteractableObject
	if object:
		GameLogger.debug("Checking object parent...")
		if object is CulturalInteractableObject:
			GameLogger.debug("Object is CulturalInteractableObject")
			new_interactable = object
			found_interactable = true
		elif object.get_parent() and object.get_parent() is CulturalInteractableObject:
			# StaticBody3D child of WorldCulturalItem
			GameLogger.debug("Parent is CulturalInteractableObject: " + object.get_parent().name)
			new_interactable = object.get_parent()
			found_interactable = true
		else:
			GameLogger.debug("No valid interactable found - Parent: " + str(object.get_parent()))
	
	# Priority 2: If no artifact in raycast, check for NPC interactions (Area3D based)
	if not found_interactable and nearest_npc and nearest_npc.can_interact:
		# Double check distance to nearest NPC to ensure it's actually in range
		var player = get_parent()
		if player:
			var distance_to_npc = player.global_position.distance_to(nearest_npc.global_position)
			var interaction_range = 3.0
			if nearest_npc.has_method("get_interaction_range"):
				interaction_range = nearest_npc.get_interaction_range()
			elif "interaction_range" in nearest_npc:
				interaction_range = nearest_npc.interaction_range
			
			if distance_to_npc <= interaction_range:
				new_interactable = nearest_npc
				found_interactable = true
				# Only log once when NPC becomes interactable to reduce spam
				if current_interactable != nearest_npc:
					GameLogger.debug("Using nearest NPC: " + nearest_npc.name + " (distance: " + str(distance_to_npc) + ")")
			else:
				# Only log when NPC becomes too far to reduce spam
				if current_interactable == nearest_npc:
					GameLogger.debug("NPC " + nearest_npc.name + " too far: " + str(distance_to_npc) + " > " + str(interaction_range))
				# NPC is too far, remove from list
				if npcs_in_range.has(nearest_npc):
					npcs_in_range.erase(nearest_npc)
					update_nearest_npc()
	
	# Handle interaction state changes
	if found_interactable and can_process_changes:
		if new_interactable != current_interactable:
			# Switching interactables - close any existing dialogues
			if current_interactable:
				GameLogger.info("DEBUG: Switching from " + current_interactable.name + " to " + new_interactable.name)
				on_exit_interaction_range()
				# If switching from NPC to another NPC, ensure dialog cleanup
				if current_interactable.has_method("close_npc_dialogue_ui"):
					current_interactable.close_npc_dialogue_ui()
			
			current_interactable = new_interactable
			is_near_interactable = true
			GameLogger.debug("Entering interaction range with: " + new_interactable.name + " (Time: " + str(current_time) + ")")
			on_enter_interaction_range(new_interactable)
			last_interaction_time = current_time
		
		# Handle interaction input
		if Input.is_action_just_pressed("interact"):
			GameLogger.info("Interaction key pressed with: " + new_interactable.name)
			on_interact_pressed(new_interactable)
			
	elif not found_interactable:
		# No interactables found, clear current interactable
		if current_interactable:
			GameLogger.debug("Exiting interaction range - no interactables found")
			on_exit_interaction_range()
			current_interactable = null
			is_near_interactable = false

func check_for_npcs_in_range():
	# Manual fallback to check for NPCs in range
	var player = get_parent()
	if not player:
		return
	
	var npcs = get_tree().get_nodes_in_group("npc")
	GameLogger.debug("Fallback: Found " + str(npcs.size()) + " NPCs in 'npc' group")
	
	# First, aggressively clean up NPCs that are too far
	var npcs_to_remove = []
	for npc in npcs_in_range:
		var distance = player.global_position.distance_to(npc.global_position)
		var interaction_range = 3.0
		if npc.has_method("get_interaction_range"):
			interaction_range = npc.get_interaction_range()
		elif "interaction_range" in npc:
			interaction_range = npc.interaction_range
		
		if distance > interaction_range * 1.2:  # Add 20% buffer for stability
			npcs_to_remove.append(npc)
	
	for npc in npcs_to_remove:
		npcs_in_range.erase(npc)
		GameLogger.info("Aggressive cleanup: Removed NPC " + npc.name + " from range list")
	
	if npcs_to_remove.size() > 0:
		update_nearest_npc()
	
	# Then check for new NPCs
	for npc in npcs:
		# Check for CulturalInteractableObject (main NPC type)
		if npc is CulturalInteractableObject or npc.has_method("_interact"):
			var distance = player.global_position.distance_to(npc.global_position)
			var interaction_range = 3.0  # Default range
			
			# Get interaction range from the NPC if available
			if npc.has_method("get_interaction_range"):
				interaction_range = npc.get_interaction_range()
			elif "interaction_range" in npc:
				interaction_range = npc.interaction_range
			
			GameLogger.debug("Fallback: NPC " + npc.name + " distance: " + str(distance) + "m, range: " + str(interaction_range) + "m")
			if distance <= interaction_range:
				# NPC is in range, add to list
				if not npcs_in_range.has(npc):
					npcs_in_range.append(npc)
					GameLogger.info("Fallback: NPC " + npc.name + " added to range list (distance: " + str(distance) + "m)")
					update_nearest_npc()
				else:
					GameLogger.debug("Fallback: NPC " + npc.name + " already in range list")
			else:
				# NPC is out of range, remove from list
				if npcs_in_range.has(npc):
					npcs_in_range.erase(npc)
					GameLogger.info("Fallback: NPC " + npc.name + " removed from range list (distance: " + str(distance) + "m)")
					update_nearest_npc()
		else:
			GameLogger.debug("Fallback: Node " + npc.name + " is in 'npc' group but not a recognized NPC type")
	
	# DEBUG: Log current state after fallback check (only when it changes)
	if npcs_in_range.size() > 0:
		var nearest_name: String = "None"
		if nearest_npc:
			nearest_name = nearest_npc.name
		GameLogger.debug("DEBUG: After fallback - NPCs in range: " + str(npcs_in_range.size()) + ", Nearest: " + nearest_name)
	else:
		GameLogger.debug("DEBUG: After fallback - No NPCs in range")

func on_enter_interaction_range(interactable: CulturalInteractableObject):
	# Only show interaction prompt if the interactable can actually interact
	if interactable.can_interact:
		if interact_prompt_label:
			var prompt_text = get_interaction_prompt_text(interactable)
			interact_prompt_label.text = prompt_text
			interact_prompt_label.visible = true
			
			# Add visual feedback
			interact_prompt_label.modulate = Color.YELLOW
			
			GameLogger.info("Near interactable: " + interactable.name + " - " + prompt_text)
		else:
			GameLogger.error("Interaction prompt label not available!")
	else:
		GameLogger.debug("Interactable " + interactable.name + " cannot interact, not showing prompt")

func on_exit_interaction_range():
	# Hide interaction prompt
	if interact_prompt_label:
		interact_prompt_label.text = ""
		interact_prompt_label.visible = false
		interact_prompt_label.modulate = Color.WHITE
		GameLogger.debug("Exited interaction range")

func on_interact_pressed(interactable: CulturalInteractableObject):
	# Visual feedback for interaction
	if interact_prompt_label:
		interact_prompt_label.modulate = Color.GREEN
		
		# Flash effect
		var tween = create_tween()
		tween.tween_property(interact_prompt_label, "modulate", Color.WHITE, 0.2)
	
	# Record interaction in history
	record_interaction(interactable)
	
	# Call the interactable's interaction method
	GameLogger.info("Calling _interact() on: " + interactable.name)
	interactable._interact()
	
	GameLogger.info("Interacted with: " + interactable.name)

func get_interaction_prompt_text(interactable: CulturalInteractableObject) -> String:
	# Generate appropriate prompt text based on interactable type
	if interactable is CulturalNPC:
		var npc = interactable as CulturalNPC
		var prompt_text = "[E] Talk to " + npc.npc_name
		GameLogger.info("DEBUG: Generating prompt for NPC: " + npc.name + " -> " + prompt_text)
		return prompt_text
	elif interactable.has_method("get_interaction_prompt"):
		return "[E] " + interactable.get_interaction_prompt()
	else:
		return "[E] " + (interactable.interaction_prompt if interactable.interaction_prompt else "Interact")

# Public methods for external access
func get_current_interactable() -> CulturalInteractableObject:
	return current_interactable

func is_player_near_interactable() -> bool:
	return is_near_interactable

func can_interact_with_object(interactable: CulturalInteractableObject, current_time: float) -> bool:
	# Special handling for NPCs - check their internal cooldown state
	if interactable is CulturalNPC:
		var npc = interactable as CulturalNPC
		# NPCs have their own cooldown system, so we don't apply our own cooldown
		# Just check if they can_interact
		return npc.can_interact
	
	# For other objects, check if enough time has passed since last interaction
	var time_since_last = get_time_since_last_interaction(interactable, current_time)
	return time_since_last >= min_reinteraction_delay

func get_time_since_last_interaction(interactable: CulturalInteractableObject, current_time: float) -> float:
	if interactable.name in interaction_history:
		return current_time - interaction_history[interactable.name]
	return min_reinteraction_delay + 1.0  # Allow interaction if never interacted before

func record_interaction(interactable: CulturalInteractableObject):
	var current_time = Time.get_unix_time_from_system()
	
	# Don't record NPC interactions in our history since they have their own cooldown
	if not (interactable is CulturalNPC):
		interaction_history[interactable.name] = current_time
		last_interacted_object = interactable
		GameLogger.debug("Recorded interaction with " + interactable.name + " at time " + str(current_time))
	else:
		GameLogger.debug("NPC interaction recorded (using NPC's own cooldown system): " + interactable.name)

func clear_interaction_history():
	interaction_history.clear()
	last_interacted_object = null
	GameLogger.debug("Interaction history cleared")

func reset_interaction_state():
	current_interactable = null
	is_near_interactable = false
	last_interaction_time = 0.0
	on_exit_interaction_range()
	GameLogger.debug("Interaction state reset")

func get_debug_info() -> Dictionary:
	var current_time = Time.get_unix_time_from_system()
	
	# Handle current interactable name
	var current_interactable_name: String = "None"
	if current_interactable:
		current_interactable_name = current_interactable.name
	
	# Handle nearest NPC name
	var nearest_npc_name: String = "None"
	if nearest_npc:
		nearest_npc_name = nearest_npc.name
	
	var debug_data = {
		"current_interactable": current_interactable_name,
		"is_near_interactable": is_near_interactable,
		"last_interaction_time": last_interaction_time,
		"current_time": current_time,
		"time_since_last_interaction": current_time - last_interaction_time,
		"interaction_cooldown": interaction_cooldown,
		"min_reinteraction_delay": min_reinteraction_delay,
		"interaction_history_size": interaction_history.size(),
		"npcs_in_range": npcs_in_range.size(),
		"nearest_npc": nearest_npc_name
	}
	
	if current_interactable and current_interactable is CulturalNPC:
		var npc = current_interactable as CulturalNPC
		debug_data["npc_can_interact"] = npc.can_interact
		debug_data["npc_dialogue_just_ended"] = npc.dialogue_just_ended
		debug_data["npc_dialogue_end_time"] = npc.dialogue_end_time
		debug_data["npc_dialogue_cooldown_duration"] = npc.dialogue_cooldown_duration
	
	return debug_data
