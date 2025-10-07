extends Node

# Global game state management for the exhibition

# Current region being explored
var current_region: String = ""

# Player progress tracking
var visited_regions: Array[String] = []
var collected_artifacts: Dictionary = {}
var cultural_knowledge: Dictionary = {}

# System references
var cultural_inventory: CulturalInventory
var audio_manager: Node

# Loading overlay (created on demand)
var _loading_overlay: Node = null
var _loading_config: Resource = null
var _loading_defaults := {
	"design_width": 1920,
	"design_height": 1080,
	"background_paths": {
		"papua": "res://Assets/Splash/papua-loading.png",
		"tambora": "res://Assets/Splash/tambora-loading.png",
		"pasar": "res://Assets/Splash/pasar-loading.png"
	},
	"bar_frame_path": "res://Assets/Splash/loading_bar_empty_frame.png",
	"bar_fill_path": "res://Assets/Splash/loading_bar_fill.png",
	"bar_width_percent": 0.5,
	"bar_min_width": 480,
	"bar_max_width": 960,
	"bar_height": 36,
	"bar_y_percent": 0.82
}

# Fake loading animation controls
var _use_fake_progress: bool = true
var _fake_progress_duration: float = 7.0
var _loading_start_time: float = 0.0

func _ensure_loading_config():
	if _loading_config != null:
		return
	if ResourceLoader.exists("res://Resources/Loading/LoadingConfig.tres"):
		_loading_config = load("res://Resources/Loading/LoadingConfig.tres")
	else:
		_loading_config = null

func _cfg_get(name: String):
	if _loading_config and name in _loading_config:
		return _loading_config.get(name)
	return _loading_defaults.get(name)

func _get_loading_background(scene_path: String) -> Texture2D:
	_ensure_loading_config()
	var bg_paths: Dictionary = (_cfg_get("background_paths") as Dictionary)
	var lower := scene_path.to_lower()
	var chosen := ""
	if lower.find("papua") != -1 or current_region.find("Timur") != -1:
		chosen = bg_paths.get("papua", "")
	elif lower.find("tambora") != -1 or current_region.find("Tengah") != -1:
		chosen = bg_paths.get("tambora", "")
	elif lower.find("pasar") != -1 or lower.find("barat") != -1 or current_region.find("Barat") != -1:
		chosen = bg_paths.get("pasar", "")
	if chosen == "":
		chosen = bg_paths.get("pasar", "")
	if chosen != "":
		return load(chosen)
	return null

func _create_loading_overlay(scene_path: String):
	# Create a simple in-code loading UI so no scene file is needed
	if _loading_overlay and is_instance_valid(_loading_overlay):
		return
	var canvas := CanvasLayer.new()
	canvas.layer = 100
	_ensure_loading_config()
	var viewport_size := get_viewport().get_visible_rect().size
	var root := Control.new()
	root.size = viewport_size
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Opaque base to hide scene
	var base := ColorRect.new()
	base.color = Color(0, 0, 0, 1.0)
	base.size = root.size
	base.anchor_right = 1.0
	base.anchor_bottom = 1.0
	# Background image centered without scaling (KEEP)
	var bg := TextureRect.new()
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.StretchMode.STRETCH_KEEP
	# use top-left anchors; we'll center via position
	bg.anchor_left = 0.0
	bg.anchor_top = 0.0
	bg.anchor_right = 0.0
	bg.anchor_bottom = 0.0
	var tex := _get_loading_background(scene_path)
	if tex:
		bg.texture = tex
		bg.size = tex.get_size()
		# Center both horizontally and vertically without scaling
		bg.position = Vector2((viewport_size.x - bg.size.x) / 2.0, (viewport_size.y - bg.size.y) / 2.0)
	# Optional darken overlay for readability
	var dimmer := ColorRect.new()
	dimmer.color = Color(0, 0, 0, 0.30)
	dimmer.size = root.size
	dimmer.anchor_right = 1.0
	dimmer.anchor_bottom = 1.0
	# Build a textured progress bar
	var bar := TextureProgressBar.new()
	bar.min_value = 0
	bar.max_value = 1
	bar.value = 0
	# Load textures
	var frame_path: String = str(_cfg_get("bar_frame_path"))
	var fill_path: String = str(_cfg_get("bar_fill_path"))
	# Prefer small fill if available
	if ResourceLoader.exists("res://Assets/Splash/fill_red.png"):
		fill_path = "res://Assets/Splash/fill_red.png"
	if ResourceLoader.exists(frame_path):
		bar.texture_under = load(frame_path)
	if ResourceLoader.exists(fill_path):
		bar.texture_progress = load(fill_path)
	bar.fill_mode = TextureProgressBar.FILL_LEFT_TO_RIGHT
	bar.stretch_margin_left = 0
	bar.stretch_margin_right = 0
	bar.stretch_margin_top = 0
	bar.stretch_margin_bottom = 0
	# Size: use frame texture size if available for perfect alignment
	var target_size := Vector2.ZERO
	if bar.texture_under:
		target_size = bar.texture_under.get_size()
	else:
		var bar_width: int = clamp(int(viewport_size.x * float(_cfg_get("bar_width_percent"))), int(_cfg_get("bar_min_width")), int(_cfg_get("bar_max_width")))
		var bar_height: int = int(_cfg_get("bar_height"))
		target_size = Vector2(bar_width, bar_height)
	bar.custom_minimum_size = target_size
	bar.size = target_size
	# Place progress bar center-bottom (not too close to edge)
	var view_size := root.size
	bar.position = Vector2(view_size.x / 2.0 - (bar.custom_minimum_size.x / 2.0), view_size.y * float(_cfg_get("bar_y_percent")))
	root.add_child(base)
	root.add_child(bg)
	root.add_child(dimmer)
	root.add_child(bar)
	canvas.add_child(root)
	add_child(canvas)
	_loading_overlay = canvas
	_loading_overlay.set_meta("progress_bar", bar)
	_loading_overlay.set_meta("progress_target", 0.0)
	_loading_start_time = Time.get_ticks_msec() / 1000.0

func _update_loading_progress(p: float):
	if _loading_overlay and is_instance_valid(_loading_overlay):
		var bar: TextureProgressBar = _loading_overlay.get_meta("progress_bar")
		if bar:
			# Smoothly animate to target
			var target := clampf(p, 0.0, 1.0)
			var current_target := float(_loading_overlay.get_meta("progress_target"))
			current_target = target
			_loading_overlay.set_meta("progress_target", current_target)
			# Lerp current bar value towards target
			bar.value = lerpf(bar.value, current_target, 0.25)

func _remove_loading_overlay():
	if _loading_overlay and is_instance_valid(_loading_overlay):
		_loading_overlay.queue_free()
	_loading_overlay = null

# Exhibition settings
var exhibition_mode: bool = true
var session_duration: float = 900.0  # 15 minutes default
var current_session_time: float = 0.0

# Audio settings
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 0.8

# Language settings (for international audience)
var current_language: String = "en"  # Default to English

# Topeng Nusantara settings
var selected_mask_type: String = ""  # "preset" or "custom"
var selected_mask_id: int = -1       # For preset masks (1-7)
var custom_mask_components: Dictionary = {
	"base": -1,
	"mata": -1,
	"mulut": -1
}

# Region-specific data
var region_data: Dictionary = {
	"Indonesia Barat": {
		"title": "Traditional Market Cuisine",
		"description": "Explore Indonesian street food culture in traditional markets",
		"duration": 600.0,  # 10 minutes
		"foods": ["Soto", "Lotek", "Baso", "Sate"],
		"locations": ["Jakarta", "Serang", "Bandung", "Bogor", "Garut", "Cirebon"]
	},
	"Indonesia Tengah": {
		"title": "Mount Tambora Historical Experience",
		"description": "Journey through the 1815 eruption that changed the world",
		"duration": 900.0,  # 15 minutes
		"historical_events": ["1815 Eruption", "Global Climate Impact", "Historical Significance"],
		"elevations": ["Base Camp", "Mid Slope", "Summit"]
	},
	"Indonesia Timur": {
		"title": "Papua Cultural Artifact Collection",
		"description": "Discover ancient artifacts and Papua ethnic culture",
		"duration": 1200.0,  # 20 minutes
		"artifacts": ["Batu Dootomo", "Kapak Perunggu", "Traditional Tools"],
		"sites": ["Bukit Megalitik Tutari", "Traditional Villages", "Archaeological Sites"]
	}
}

func _ready():
	# Make this node persistent across scene changes
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Initialize audio manager
	initialize_audio_manager()

func initialize_audio_manager():
	"""Initialize the audio manager"""
	# Load the audio manager scene
	var audio_manager_scene = load("res://Systems/Audio/CulturalAudioManager.tscn")
	if audio_manager_scene:
		audio_manager = audio_manager_scene.instantiate()
		add_child(audio_manager)
		GameLogger.info("🎵 Audio manager initialized in Global")
	else:
		GameLogger.error("❌ Failed to load audio manager scene")

func change_scene_with_loading(scene_path: String) -> void:
	GameLogger.info("🔄 Loading scene with overlay: " + scene_path)
	_create_loading_overlay(scene_path)
	await get_tree().process_frame
	var ok := ResourceLoader.load_threaded_request(scene_path, "PackedScene")
	if ok != OK:
		GameLogger.error("❌ Threaded load request failed for: " + scene_path)
		_remove_loading_overlay()
		return
	var progress := []
	while true:
		var status := ResourceLoader.load_threaded_get_status(scene_path, progress)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var packed: PackedScene = ResourceLoader.load_threaded_get(scene_path)
			if packed:
				get_tree().change_scene_to_packed(packed)
			else:
				GameLogger.error("❌ Loaded resource is null: " + scene_path)
			break
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			GameLogger.error("❌ Threaded load failed for: " + scene_path)
			break
		else:
			var p := 0.0
			if progress.size() >= 1:
				p = float(progress[0])
			# Apply fake progress to create visible animation while loading
			if _use_fake_progress:
				var elapsed := (Time.get_ticks_msec() / 1000.0) - _loading_start_time
				var fake_p := clampf(elapsed / _fake_progress_duration, 0.0, 0.98)
				if fake_p > p:
					p = fake_p
			_update_loading_progress(p)
			# update multiple times per frame for smoother bar
			await get_tree().process_frame
			_update_loading_progress(p)
	_remove_loading_overlay()

func _process(delta):
	if exhibition_mode:
		current_session_time += delta
		
		# Check if session time limit reached
		var current_region_data = region_data.get(current_region, {})
		var max_duration = current_region_data.get("duration", session_duration)
		
		if current_session_time >= max_duration:
			show_session_complete_message()

func start_region_session(region_name: String):
	current_region = region_name
	current_session_time = 0.0
	
	if not region_name in visited_regions:
		visited_regions.append(region_name)
	
	GameLogger.info("Started session for: " + region_name)
	
	# Start region-specific audio
	if audio_manager:
		audio_manager.play_region_ambience(region_name)

func get_current_region_data() -> Dictionary:
	return region_data.get(current_region, {})

func add_cultural_knowledge(region: String, knowledge: String):
	if not region in cultural_knowledge:
		cultural_knowledge[region] = []
	
	if not knowledge in cultural_knowledge[region]:
		cultural_knowledge[region].append(knowledge)
		
		# Emit signal for UI updates
		GlobalSignals.on_learn_cultural_info.emit(knowledge, region)

func collect_artifact(region: String, artifact: String):
	GameLogger.debug("Global.collect_artifact() called with region: " + region + ", artifact: " + artifact)
	
	if not region in collected_artifacts:
		collected_artifacts[region] = []
	
	if not artifact in collected_artifacts[region]:
		collected_artifacts[region].append(artifact)
		GameLogger.info("Collected artifact: " + artifact + " in " + region)
		
		# Update inventory if available
		GameLogger.debug("Checking cultural_inventory: " + str(cultural_inventory))
		if cultural_inventory:
			# Load the cultural item resource with better error handling
			var item_path = "res://Systems/Items/ItemData/" + artifact + ".tres"
			GameLogger.debug("Loading item from path: " + item_path)
			GameLogger.debug("Resource exists: " + str(ResourceLoader.exists(item_path)))
			
			if ResourceLoader.exists(item_path):
				# Try loading with load() first
				var item = load(item_path)
				GameLogger.debug("Loaded with load(): " + str(item))
				
				if item == null:
					# Try with ResourceLoader.load()
					GameLogger.debug("Trying ResourceLoader.load()...")
					item = ResourceLoader.load(item_path)
					GameLogger.debug("Loaded with ResourceLoader.load(): " + str(item))
				
				if item != null:
					GameLogger.debug("Item class: " + item.get_class())
					GameLogger.debug("Item has display_name: " + str("display_name" in item))
					GameLogger.debug("Item has icon property: " + str("icon" in item))
					if "display_name" in item:
						GameLogger.debug("Item display_name: " + item.display_name)
					if "icon" in item:
						GameLogger.debug("Item icon: " + str(item.icon))
						GameLogger.debug("Item icon type: " + (item.icon.get_class() if item.icon else "null"))
					cultural_inventory.add_cultural_artifact(item, region)
				else:
					GameLogger.error("Both load methods returned null!")
					# Create a fallback CulturalItem with icon
					var fallback_item = CulturalItem.new()
					fallback_item.display_name = artifact
					fallback_item.cultural_region = region
					fallback_item.description = "Collected " + artifact
					
					# Try to load icon separately
					var icon_path = "res://Assets/Images/" + artifact + ".png"
					if ResourceLoader.exists(icon_path):
						var icon_texture = load(icon_path)
						if icon_texture:
							fallback_item.icon = icon_texture
							GameLogger.debug("Loaded icon for fallback item: " + str(icon_texture))
						else:
							GameLogger.debug("Failed to load icon from: " + icon_path)
					else:
						GameLogger.debug("Icon file not found at: " + icon_path)
					GameLogger.info("Created fallback item: " + fallback_item.display_name)
					cultural_inventory.add_cultural_artifact(fallback_item, region)
			else:
				GameLogger.error("Item resource not found at: " + item_path)
				# Create a fallback CulturalItem with icon
				var fallback_item = CulturalItem.new()
				fallback_item.display_name = artifact
				fallback_item.cultural_region = region
				fallback_item.description = "Collected " + artifact
				
				# Try to load icon separately
				var icon_path = "res://Assets/Images/" + artifact + ".png"
				if ResourceLoader.exists(icon_path):
					var icon_texture = load(icon_path)
					if icon_texture:
						fallback_item.icon = icon_texture
						GameLogger.debug("Loaded icon for fallback item: " + str(icon_texture))
					else:
						GameLogger.debug("Failed to load icon from: " + icon_path)
				else:
					GameLogger.debug("Icon file not found at: " + icon_path)
				GameLogger.info("Created fallback item for missing resource: " + fallback_item.display_name)
				cultural_inventory.add_cultural_artifact(fallback_item, region)
		else:
			GameLogger.error("cultural_inventory is null!")
		
		# Play collection audio
		if audio_manager:
			audio_manager.play_cultural_audio("artifact_collection", region)
	else:
		GameLogger.debug("Artifact already collected: " + artifact)

func get_session_progress() -> float:
	var current_region_data = region_data.get(current_region, {})
	var max_duration = current_region_data.get("duration", session_duration)
	return (current_session_time / max_duration) * 100.0

func get_remaining_time() -> float:
	var current_region_data = region_data.get(current_region, {})
	var max_duration = current_region_data.get("duration", session_duration)
	return max(0.0, max_duration - current_session_time)

func show_session_complete_message():
	# This will be called when session time is up
	GameLogger.info("Session complete for: " + current_region)
	# You can implement a UI popup here to show completion message

func reset_exhibition_data():
	current_region = ""
	visited_regions.clear()
	collected_artifacts.clear()
	cultural_knowledge.clear()
	current_session_time = 0.0

func save_exhibition_data():
	# Save progress for exhibition tracking
	var save_data = {
		"visited_regions": visited_regions,
		"collected_artifacts": collected_artifacts,
		"cultural_knowledge": cultural_knowledge,
		"session_time": current_session_time
	}
	
	var save_file = FileAccess.open("user://exhibition_data.save", FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()

func load_exhibition_data():
	# Load saved progress
	if FileAccess.file_exists("user://exhibition_data.save"):
		var save_file = FileAccess.open("user://exhibition_data.save", FileAccess.READ)
		if save_file:
			var json_string = save_file.get_as_text()
			save_file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				var data = json.data
				# Cast arrays to proper types
				var temp_visited = data.get("visited_regions", [])
				visited_regions.clear()
				for region in temp_visited:
					visited_regions.append(str(region))
				
				collected_artifacts = data.get("collected_artifacts", {}).duplicate()
				cultural_knowledge = data.get("cultural_knowledge", {}).duplicate()
				current_session_time = data.get("session_time", 0.0)

# Save/Load system support
func get_collected_items() -> Array:
	# Return collected items for save system
	# This can be expanded to include inventory items, achievements, etc.
	var items = []
	if current_region != "":
		items.append({"type": "region", "name": current_region})
	return items
