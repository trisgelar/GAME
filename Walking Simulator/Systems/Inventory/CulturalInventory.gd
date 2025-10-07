class_name CulturalInventory
extends Control

# UI Elements
@onready var inventory_window: Panel = $InventoryWindow
@onready var slot_container: GridContainer = $InventoryWindow/SlotContainer
@onready var info_text: Label = $InventoryWindow/InfoText
@onready var progress_label: Label = $InventoryWindow/ProgressLabel

# Inventory data
var slots: Array[InventorySlot] = []
var collected_artifacts: Dictionary = {
	"Indonesia Barat": [],
	"Indonesia Tengah": [],
	"Indonesia Timur": []
}

# Exhibition tracking
var total_artifacts: int = 0
var collected_count: int = 0

func _ready():
	setup_inventory()
	connect_signals()
	update_display()
	
	# Register this instance with Global for artifact collection
	Global.cultural_inventory = self
	GameLogger.info("CulturalInventory registered with Global")
	
	# Set mouse filter to ignore when inventory is hidden
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func setup_inventory():
	# Create inventory slots
	for i in range(20):  # 20 slots for artifacts
		var slot = preload("res://Systems/Inventory/InventorySlot.tscn").instantiate()
		slot_container.add_child(slot)
		slots.append(slot)
		slot.inventory = self
		slot.set_item(null)
	
	# Hide inventory initially
	toggle_window(false)

func connect_signals():
	GlobalSignals.on_collect_artifact.connect(_on_artifact_collected)
	GlobalSignals.on_update_inventory_display.connect(update_display)

func _process(_delta):
	# Toggle inventory with I key
	if Input.is_action_just_pressed("inventory"):
		toggle_window(!inventory_window.visible)

func toggle_window(open: bool):
	inventory_window.visible = open
	
	if open:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		# Allow mouse input when inventory is open
		mouse_filter = Control.MOUSE_FILTER_STOP
		update_display()
		# Play inventory open sound
		GlobalSignals.on_play_ui_audio.emit("inventory_open")
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		# Ignore mouse input when inventory is closed
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Play inventory close sound
		GlobalSignals.on_play_ui_audio.emit("inventory_close")

func add_cultural_artifact(artifact: CulturalItem, region: String):
	GameLogger.debug("CulturalInventory.add_cultural_artifact() called")
	GameLogger.debug("Artifact: " + str(artifact))
	GameLogger.debug("Region: " + region)
	
	if artifact == null:
		GameLogger.error("Artifact is null!")
		return
	
	if not artifact.has_method("get_class") and not "display_name" in artifact:
		GameLogger.error("Artifact is not a valid CulturalItem!")
		return
	
	GameLogger.debug("Artifact display_name: " + artifact.display_name)
	
	# Add to collected artifacts
	if not region in collected_artifacts:
		collected_artifacts[region] = []
		GameLogger.debug("Created new region entry for: " + region)
	
	if not artifact.display_name in collected_artifacts[region]:
		collected_artifacts[region].append(artifact.display_name)
		collected_count += 1
		GameLogger.info("Added to collected artifacts: " + artifact.display_name + " (Total count: " + str(collected_count) + ")")
		
		# Play success audio for item collection
		GlobalSignals.on_play_ui_audio.emit("success")
	else:
		GameLogger.debug("Artifact already in collection: " + artifact.display_name)
	
	# Add to inventory slot
	var slot = get_empty_slot()
	if slot:
		slot.set_item(artifact)
		GameLogger.debug("Added artifact to inventory slot")
	else:
		GameLogger.warning("No empty slot available!")
	
	# Update display
	update_display()
	
	# Emit progress update
	GlobalSignals.on_exhibition_progress_update.emit({
		"region": region,
		"collected": collected_artifacts[region].size(),
		"total": get_total_artifacts_for_region(region)
	})

func get_empty_slot() -> InventorySlot:
	for slot in slots:
		if slot.item == null:
			return slot
	return null

func update_display():
	# Update progress information
	var progress_text = "Collected: %d/%d Artifacts\n" % [collected_count, total_artifacts]
	
	for region in collected_artifacts:
		var region_count = collected_artifacts[region].size()
		var region_total = get_total_artifacts_for_region(region)
		progress_text += "%s: %d/%d\n" % [region, region_count, region_total]
	
	progress_label.text = progress_text
	
	# Update info text
	if collected_count > 0:
		info_text.text = "Press I to open/close inventory\nRight-click items to view cultural information"
	else:
		info_text.text = "No artifacts collected yet.\nExplore the regions to find cultural items!"

func get_total_artifacts_for_region(region: String) -> int:
	# This would be loaded from a configuration file
	var region_totals = {
		"Indonesia Barat": 5,
		"Indonesia Tengah": 4,
		"Indonesia Timur": 6
	}
	return region_totals.get(region, 0)

func _on_artifact_collected(artifact_name: String, region: String):
	# This is handled by the Global system, but we can add additional logic here
	GameLogger.debug("Inventory: Artifact collected - " + artifact_name + " from " + region)

func get_collection_progress() -> Dictionary:
	return {
		"total_collected": collected_count,
		"total_available": total_artifacts,
		"by_region": collected_artifacts.duplicate()
	}

func reset_inventory():
	collected_artifacts.clear()
	collected_artifacts = {
		"Indonesia Barat": [],
		"Indonesia Tengah": [],
		"Indonesia Timur": []
	}
	collected_count = 0
	
	# Clear all slots
	for slot in slots:
		slot.set_item(null)
	
	update_display()
