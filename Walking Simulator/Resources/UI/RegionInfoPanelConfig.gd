class_name RegionInfoPanelConfig
extends Resource

## Configuration resource for RegionInfoPanel sizing and positioning
## Allows easy customization without hardcoding values

@export var panel_width: float = 480.0
@export var panel_height: float = 200.0
@export var panel_margin_from_placeholder: float = 50.0
@export var panel_background_color: Color = Color(0.149, 0.153, 0.125, 1)  # #262720

## Load default configuration
static func load_default() -> RegionInfoPanelConfig:
	var config = RegionInfoPanelConfig.new()
	return config

## Load configuration from file
static func load_from_file() -> RegionInfoPanelConfig:
	var config_path = "res://Resources/UI/RegionInfoPanelConfig.tres"
	if ResourceLoader.exists(config_path):
		var config = load(config_path) as RegionInfoPanelConfig
		if config:
			return config
	
	# Fallback to default if file doesn't exist
	GameLogger.warning("⚠️ RegionInfoPanelConfig not found, using defaults")
	return load_default()
