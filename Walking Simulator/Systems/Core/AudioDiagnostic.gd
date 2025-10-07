extends Node

# Audio Diagnostic Script
# Run this to diagnose audio issues in the main menu

func _ready():
	print("🔍 Starting Audio Diagnostic...")
	diagnose_audio_system()

func diagnose_audio_system():
	print("\n=== AUDIO SYSTEM DIAGNOSTIC ===")
	
	# 1. Check if Global.audio_manager exists
	print("\n1. Checking Global.audio_manager...")
	if Global.has_method("get") and "audio_manager" in Global:
		var audio_manager = Global.get("audio_manager")
		if audio_manager:
			print("✅ Global.audio_manager exists: ", audio_manager.get_class())
			diagnose_audio_manager(audio_manager)
		else:
			print("❌ Global.audio_manager is null")
	else:
		print("❌ Global.audio_manager not found")
	
	# 2. Check if audio files exist
	print("\n2. Checking audio files...")
	check_audio_files()
	
	# 3. Check GlobalSignals
	print("\n3. Checking GlobalSignals...")
	check_global_signals()
	
	# 4. Test direct audio playback
	print("\n4. Testing direct audio playback...")
	test_direct_audio()
	
	print("\n=== DIAGNOSTIC COMPLETE ===")

func diagnose_audio_manager(audio_manager):
	print("   Audio Manager Type: ", audio_manager.get_class())
	
	# Check if it has the expected methods
	var methods = ["play_menu_audio", "play_ambient_audio", "play_region_ambience", "play_cultural_audio", "get_configuration_status"]
	for method in methods:
		if audio_manager.has_method(method):
			print("   ✅ Has method: ", method)
		else:
			print("   ❌ Missing method: ", method)
	
	# Check configuration status
	if audio_manager.has_method("get_configuration_status"):
		var status = audio_manager.get_configuration_status()
		print("   Configuration Status: ", status)

func check_audio_files():
	var audio_files = [
		"res://Assets/Audio/Menu/ui_click.ogg",
		"res://Assets/Audio/Menu/ui_hover.ogg",
		"res://Assets/Audio/Menu/menu_open.ogg",
		"res://Assets/Audio/Menu/menu_close.ogg",
		"res://Assets/Audio/Menu/region_select.ogg",
		"res://Assets/Audio/Menu/start_game.ogg",
		"res://Assets/Audio/Ambient/market_ambience.ogg"
	]
	
	for file_path in audio_files:
		if ResourceLoader.exists(file_path):
			print("   ✅ Audio file exists: ", file_path)
		else:
			print("   ❌ Audio file missing: ", file_path)

func check_global_signals():
	if GlobalSignals:
		print("   ✅ GlobalSignals exists")
		
		# Check if signals exist
		var signals = ["on_play_menu_audio", "on_play_ambient_audio", "on_play_ui_audio"]
		for signal_name in signals:
			if GlobalSignals.has_signal(signal_name):
				print("   ✅ Signal exists: ", signal_name)
			else:
				print("   ❌ Signal missing: ", signal_name)
	else:
		print("   ❌ GlobalSignals not found")

func test_direct_audio():
	# Create a test AudioStreamPlayer
	var test_player = AudioStreamPlayer.new()
	add_child(test_player)
	
	# Test with ui_click.ogg
	var audio_path = "res://Assets/Audio/Menu/ui_click.ogg"
	if ResourceLoader.exists(audio_path):
		var audio_stream = load(audio_path)
		if audio_stream:
			test_player.stream = audio_stream
			test_player.volume_db = 0.0  # Full volume for testing
			test_player.play()
			print("   ✅ Direct audio test - playing ui_click.ogg")
			print("   🔊 Volume: ", test_player.volume_db, " dB")
			print("   🔊 Playing: ", test_player.playing)
			
			# Wait a moment then stop
			await get_tree().create_timer(1.0).timeout
			test_player.stop()
			print("   ✅ Direct audio test completed")
		else:
			print("   ❌ Failed to load audio stream: ", audio_path)
	else:
		print("   ❌ Audio file not found for direct test: ", audio_path)
	
	# Clean up
	test_player.queue_free()

func test_audio_manager_methods():
	print("\n5. Testing Audio Manager Methods...")
	
	if Global.has_method("get") and "audio_manager" in Global:
		var audio_manager = Global.get("audio_manager")
		if audio_manager:
			# Test menu audio
			if audio_manager.has_method("play_menu_audio"):
				print("   Testing play_menu_audio('button_click')...")
				audio_manager.play_menu_audio("button_click")
				await get_tree().create_timer(0.5).timeout
			
			# Test ambient audio
			if audio_manager.has_method("play_ambient_audio"):
				print("   Testing play_ambient_audio('market_ambience')...")
				audio_manager.play_ambient_audio("market_ambience")
				await get_tree().create_timer(1.0).timeout
				audio_manager.stop_ambient_audio()
			
			print("   ✅ Audio manager method tests completed")
		else:
			print("   ❌ Audio manager is null")
	else:
		print("   ❌ Audio manager not found in Global")
