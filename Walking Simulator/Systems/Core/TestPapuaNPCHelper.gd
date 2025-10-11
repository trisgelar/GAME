extends Node

# Test script to verify PapuaNPCHelper functions work correctly

func _ready():
	# Wait a bit for everything to load
	await get_tree().create_timer(2.0).timeout
	test_papua_npc_helper()

func test_papua_npc_helper():
	GameLogger.info("🧪 Testing PapuaNPCHelper functions...")
	
	# Test 1: Debug dialogue state
	GameLogger.info("Test 1: Debug dialogue state")
	PapuaNPCHelper.debug_dialogue_state()
	
	# Test 2: List all NPCs
	GameLogger.info("Test 2: List all NPCs")
	PapuaNPCHelper.list_all_npcs()
	
	# Test 3: Check for stuck NPCs
	GameLogger.info("Test 3: Check for stuck NPCs")
	PapuaNPCHelper.check_stuck_npcs()
	
	# Test 4: Test Papua NPCs specifically
	GameLogger.info("Test 4: Test Papua NPCs")
	PapuaNPCHelper.test_papua_npcs()
	
	# Test 5: Reset all NPC states
	GameLogger.info("Test 5: Reset all NPC states")
	PapuaNPCHelper.reset_all_npc_states()
	
	GameLogger.info("✅ All PapuaNPCHelper tests completed")

func _input(event):
	# Test emergency functions with key presses
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				GameLogger.info("F1 pressed: Emergency clear all dialogues")
				PapuaNPCHelper.emergency_clear_all_dialogues()
			KEY_F2:
				GameLogger.info("F2 pressed: Debug dialogue state")
				PapuaNPCHelper.debug_dialogue_state()
			KEY_F3:
				GameLogger.info("F3 pressed: List all NPCs")
				PapuaNPCHelper.list_all_npcs()
			KEY_F4:
				GameLogger.info("F4 pressed: Check stuck NPCs")
				PapuaNPCHelper.check_stuck_npcs()
			KEY_F5:
				GameLogger.info("F5 pressed: Test Papua NPCs")
				PapuaNPCHelper.test_papua_npcs()
			KEY_F6:
				GameLogger.info("F6 pressed: Reset all NPC states")
				PapuaNPCHelper.reset_all_npc_states()
