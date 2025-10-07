extends Node

# Simple script to run audio resource generation
# Attach this to a scene and run it to generate all missing .tres files

func _ready():
	print("🚀 Starting audio resource generation...")
	generate_all_audio_resources()

func generate_all_audio_resources():
	# Create the generator
	var generator = preload("res://Systems/Core/GenerateAudioResources.gd").new()
	add_child(generator)
	
	# Wait a frame for the generator to complete
	await get_tree().process_frame
	
	print("✅ Audio resource generation completed!")
	print("📁 Check the Resources/Audio folder for generated .tres files")
	
	# Remove the generator
	generator.queue_free()
