class_name AudioResource
extends Resource

@export var audio_stream: AudioStream
@export var volume_db: float = 0.0
@export var pitch_scale: float = 1.0
@export var loop: bool = false
@export var category: String = "general"
@export var description: String = ""

func get_audio_stream() -> AudioStream:
	return audio_stream

func get_volume_db() -> float:
	return volume_db

func get_pitch_scale() -> float:
	return pitch_scale

func is_looping() -> bool:
	return loop

func get_category() -> String:
	return category

func get_description() -> String:
	return description
