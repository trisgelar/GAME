class_name LoadingConfig
extends Resource

@export var design_width: int = 1920
@export var design_height: int = 1080

# Background images by region keyword
@export var background_paths := {
	"papua": "res://Assets/Splash/papua-loading.png",
	"tambora": "res://Assets/Splash/tambora-loading.png",
	"pasar": "res://Assets/Splash/pasar-loading.png"
}

# Progress bar textures
@export var bar_frame_path: String = "res://Assets/Splash/loading_bar_empty_frame.png"
@export var bar_fill_path: String = "res://Assets/Splash/loading_bar_fill.png"

# Layout
@export var bar_width_percent: float = 0.5   # 50% of viewport width
@export var bar_min_width: int = 480
@export var bar_max_width: int = 960
@export var bar_height: int = 36
@export var bar_y_percent: float = 0.82     # 82% down the screen

func get_background_for(scene_path: String, current_region: String) -> String:
	var lower := scene_path.to_lower()
	if lower.find("papua") != -1 or current_region.find("Timur") != -1:
		return background_paths.get("papua", "")
	if lower.find("tambora") != -1 or current_region.find("Tengah") != -1:
		return background_paths.get("tambora", "")
	if lower.find("pasar") != -1 or lower.find("barat") != -1 or current_region.find("Barat") != -1:
		return background_paths.get("pasar", "")
	return background_paths.get("pasar", "")
