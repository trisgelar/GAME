extends Node

# Test script to verify AudioConfig system integration
# Run this to test if the full AudioConfig system is working

func _ready():
	GameLogger.info("Testing AudioConfig system integration...")
	test_audio_config_loading()
	test_audio_manager_integration()

func test_audio_config_loading():
	GameLogger.info("Testing AudioConfig loading...")
	
	# Test 1: Check if AudioConfig script exists
	var audio_config_script = load("res://Systems/Core/AudioConfig.gd")
	if audio_config_script:
		GameLogger.info("AudioConfig script loaded successfully")
	else:
		GameLogger.error("AudioConfig script failed to load")
		return
	
	# Test 2: Check if AudioConfig.tres exists
	if ResourceLoader.exists("res://Resources/Audio/AudioConfig.tres"):
		GameLogger.info("AudioConfig.tres file exists")
		
		# Test 3: Try to load the configuration
		var config = load("res://Resources/Audio/AudioConfig.tres")
		if config:
			GameLogger.info("AudioConfig.tres loaded successfully")
			
			# Test 4: Check if it has expected properties
			var properties = ["master_volume", "ambient_volume", "menu_audio", "footstep_audio"]
			for prop in properties:
				if prop in config:
					GameLogger.info("Property '" + prop + "' found")
				else:
					GameLogger.warning("Property '" + prop + "' not found")
			
			# Test 5: Test configuration methods
			if config.has_method("get_audio_path"):
				var test_path = config.get_audio_path("menu", "ui_click")
				GameLogger.info("get_audio_path method works: " + str(test_path))
			else:
				GameLogger.warning("get_audio_path method not found")
				
			if config.has_method("validate_audio_files"):
				var missing_files = config.validate_audio_files()
				GameLogger.info("validate_audio_files method works, found " + str(missing_files.size()) + " missing files")
			else:
				GameLogger.warning("validate_audio_files method not found")
		else:
			GameLogger.error("Failed to load AudioConfig.tres")
	else:
		GameLogger.warning("AudioConfig.tres file not found")

func test_audio_manager_integration():
	GameLogger.info("Testing CulturalAudioManagerEnhanced integration...")
	
	# Test 1: Check if enhanced manager exists
	var enhanced_script = load("res://Systems/Audio/CulturalAudioManagerEnhanced.gd")
	if enhanced_script:
		GameLogger.info("CulturalAudioManagerEnhanced script loaded")
	else:
		GameLogger.error("CulturalAudioManagerEnhanced script failed to load")
		return
	
	# Test 2: Check if scene exists
	if ResourceLoader.exists("res://Systems/Audio/CulturalAudioManagerEnhanced.tscn"):
		GameLogger.info("CulturalAudioManagerEnhanced.tscn exists")
	else:
		GameLogger.warning("CulturalAudioManagerEnhanced.tscn not found")
	
	# Test 3: Try to create an instance
	var manager = enhanced_script.new()
	if manager:
		GameLogger.info("CulturalAudioManagerEnhanced instance created")
		
		# Test 4: Check configuration status
		if manager.has_method("get_configuration_status"):
			var status = manager.get_configuration_status()
			GameLogger.info("Configuration status: " + str(status))
		else:
			GameLogger.warning("get_configuration_status method not found")
		
		# Clean up
		manager.queue_free()
	else:
		GameLogger.error("Failed to create CulturalAudioManagerEnhanced instance")

func _on_test_complete():
	GameLogger.info("AudioConfig system test completed!")
	GameLogger.info("Check the output above for any issues.")
