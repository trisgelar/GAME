class_name NPCIdleState
extends NPCState

# Idle state for NPCs - default behavior when not interacting
# Implements Single Responsibility Principle - handles only idle behavior

var idle_timer: float = 0.0
var idle_duration: float = 5.0
var look_around_timer: float = 0.0
var look_around_duration: float = 3.0

func enter():
	GameLogger.debug(npc.npc_name + " entered idle state")
	npc.interaction_prompt = "Press E to talk to " + npc.npc_name
	idle_timer = 0.0
	look_around_timer = 0.0

func update(delta: float):
	# Check if player is nearby
	if check_player_proximity():
		# Player is close, face them
		face_player()
		
		# Check if player wants to interact
		if Input.is_action_just_pressed("interact"):
			print("🎯 NPC INTERACTION: ", npc.npc_name, " detected interact key press!")
			print("🎯 NPC INTERACTION: Player distance: ", npc.position.distance_to(npc.player.position))
			
			# Check if there's already an active dialogue with another NPC
			if npc.active_dialogue_npc != null and npc.active_dialogue_npc != npc:
				print("🎯 NPC INTERACTION: ", npc.npc_name, " blocked - another NPC (", npc.active_dialogue_npc.npc_name, ") has active dialogue")
				return
			
			# Only the closest NPC should respond
			var all_npcs = npc.get_tree().get_nodes_in_group("npc")
			var closest_npc = null
			var closest_distance = 999.0
			
			for other_npc in all_npcs:
				if other_npc != npc and other_npc.has_method("get") and other_npc.get("player"):
					var distance = other_npc.position.distance_to(other_npc.player.position)
					if distance < closest_distance:
						closest_distance = distance
						closest_npc = other_npc
			
			var my_distance = npc.position.distance_to(npc.player.position)
			if closest_npc and my_distance > closest_distance:
				print("🎯 NPC INTERACTION: ", npc.npc_name, " blocked - ", closest_npc.npc_name, " is closer (", closest_distance, " vs ", my_distance, ")")
				return
			
			print("🎯 NPC INTERACTION: ", npc.npc_name, " proceeding with interaction")
			change_to_interacting()
			return
	else:
		# Player is not nearby, do idle behaviors
		perform_idle_behavior(delta)

func perform_idle_behavior(delta: float):
	idle_timer += delta
	look_around_timer += delta
	
	# Look around occasionally
	if look_around_timer >= look_around_duration:
		look_around_timer = 0.0
		perform_look_around()
	
	# Consider walking to a new position
	if idle_timer >= idle_duration:
		idle_timer = 0.0
		if should_start_walking():
			change_to_walking()

func perform_look_around():
	# Simple look around behavior
	var random_rotation = randf_range(-45, 45)
	npc.rotate_y(deg_to_rad(random_rotation))

func should_start_walking() -> bool:
	# 30% chance to start walking
	return randf() < 0.3

func exit():
	GameLogger.debug(npc.npc_name + " exited idle state")

func get_state_name() -> String:
	return "IdleState"
