# Godot Asset Viewer UI Guide for Beginners

## Introduction

This guide teaches you how to create simple UI tools in Godot to view, test, and manage 3D assets. Perfect for beginners who want to build asset viewers, testing tools, or asset management systems.

## Basic UI Concepts

### Godot UI System Overview

Godot's UI system is based on **Control nodes**:
- **Control**: Base UI container
- **Button**: Clickable buttons
- **Label**: Text display
- **VBoxContainer**: Vertical layout container
- **HBoxContainer**: Horizontal layout container
- **Panel**: Background container with styling

### Basic UI Structure

```gdscript
# Basic UI hierarchy
Control (main container)
├── Label (title)
├── VBoxContainer (button container)
│   ├── Button (action 1)
│   ├── Button (action 2)
│   └── Button (action 3)
└── Label (status)
```

## Creating a Simple Asset Viewer

### Step 1: Basic Scene Setup

Create a new scene with this structure:
```
Node3D (root)
├── Camera3D (for viewing assets)
├── DirectionalLight3D (for lighting)
└── Control (UI overlay)
```

### Step 2: Basic UI Creation

```gdscript
extends Node3D

# UI references
@onready var ui_panel: Control
@onready var status_label: Label
@onready var camera: Camera3D

# Asset management
var asset_container: Node3D
var current_asset: Node3D

func _ready():
    # Get camera reference
    camera = get_node_or_null("Camera3D")
    if not camera:
        print("Camera3D not found!")
        return
    
    # Create UI overlay
    create_ui_overlay()
    
    # Create asset container
    asset_container = Node3D.new()
    asset_container.name = "AssetContainer"
    add_child(asset_container)
    
    # Set initial status
    update_status("Asset Viewer Ready")

func create_ui_overlay():
    """Create a simple UI overlay with buttons"""
    # Create main UI panel
    ui_panel = Control.new()
    ui_panel.name = "UIPanel"
    add_child(ui_panel)
    
    # Set UI to fill screen
    ui_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    
    # Create status label
    status_label = Label.new()
    status_label.name = "StatusLabel"
    status_label.text = "Asset Viewer - Ready"
    status_label.position = Vector2(10, 10)
    status_label.size = Vector2(400, 30)
    ui_panel.add_child(status_label)
    
    # Create button container
    var button_container = VBoxContainer.new()
    button_container.name = "ButtonContainer"
    button_container.position = Vector2(10, 50)
    button_container.size = Vector2(200, 300)
    ui_panel.add_child(button_container)
    
    # Create buttons
    var buttons = [
        {"name": "LoadAsset", "text": "Load Asset", "callback": "load_test_asset"},
        {"name": "ClearAssets", "text": "Clear All", "callback": "clear_all_assets"},
        {"name": "RotateAsset", "text": "Rotate Asset", "callback": "rotate_current_asset"},
        {"name": "ToggleLight", "text": "Toggle Light", "callback": "toggle_lighting"}
    ]
    
    for button_data in buttons:
        var button = Button.new()
        button.name = button_data.name
        button.text = button_data.text
        button.custom_minimum_size = Vector2(180, 30)
        button_container.add_child(button)
        button.pressed.connect(Callable(self, button_data.callback))
    
    # Create camera controls info
    var camera_info = Label.new()
    camera_info.name = "CameraInfo"
    camera_info.text = "Camera: WASD to move, Mouse to look around"
    camera_info.position = Vector2(10, 360)
    camera_info.size = Vector2(300, 30)
    ui_panel.add_child(camera_info)
```

### Step 3: Basic Asset Loading

```gdscript
func load_test_asset():
    """Load a test asset"""
    update_status("Loading test asset...")
    
    # Clear existing assets
    clear_all_assets()
    
    # Create a simple test cube
    var cube = CSGBox3D.new()
    cube.name = "TestCube"
    cube.size = Vector3(2, 2, 2)
    
    # Create material
    var material = StandardMaterial3D.new()
    material.albedo_color = Color.RED
    cube.material = material
    
    # Add to container
    asset_container.add_child(cube)
    current_asset = cube
    
    update_status("Loaded test cube")

func clear_all_assets():
    """Clear all assets from the scene"""
    if asset_container:
        for child in asset_container.get_children():
            child.queue_free()
    current_asset = null
    update_status("Cleared all assets")

func rotate_current_asset():
    """Rotate the current asset"""
    if current_asset:
        current_asset.rotate_y(PI / 4)  # Rotate 45 degrees
        update_status("Rotated asset")
    else:
        update_status("No asset to rotate")

func toggle_lighting():
    """Toggle lighting on/off"""
    var light = get_node_or_null("DirectionalLight3D")
    if light:
        light.visible = !light.visible
        var status = "Lighting ON" if light.visible else "Lighting OFF"
        update_status(status)

func update_status(message: String):
    """Update the status label"""
    if status_label:
        status_label.text = "Asset Viewer - " + message
    print("Asset Viewer: " + message)
```

### Step 4: Camera Controls

```gdscript
func _input(event):
    """Handle input for camera controls"""
    if not camera:
        return
    
    # Mouse look (when right mouse button is held)
    if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        camera.rotate_y(-event.relative.x * 0.005)
        camera.rotate_object_local(Vector3.RIGHT, -event.relative.y * 0.005)
    
    # Keyboard movement
    var camera_speed = 5.0
    var delta = get_process_delta_time()
    
    if Input.is_key_pressed(KEY_W):
        camera.translate(Vector3.FORWARD * camera_speed * delta)
    if Input.is_key_pressed(KEY_S):
        camera.translate(Vector3.BACK * camera_speed * delta)
    if Input.is_key_pressed(KEY_A):
        camera.translate(Vector3.LEFT * camera_speed * delta)
    if Input.is_key_pressed(KEY_D):
        camera.translate(Vector3.RIGHT * camera_speed * delta)
    if Input.is_key_pressed(KEY_Q):
        camera.translate(Vector3.UP * camera_speed * delta)
    if Input.is_key_pressed(KEY_E):
        camera.translate(Vector3.DOWN * camera_speed * delta)
```

## Advanced Features

### Asset Loading from Files

```gdscript
func load_asset_from_path(asset_path: String):
    """Load an asset from a file path"""
    update_status("Loading asset: " + asset_path.get_file())
    
    # Try to load the asset
    var asset_scene = load(asset_path)
    if not asset_scene:
        update_status("Failed to load asset: " + asset_path)
        return
    
    # Clear existing assets
    clear_all_assets()
    
    # Instantiate the asset
    var asset_instance = asset_scene.instantiate()
    if not asset_instance:
        update_status("Failed to instantiate asset")
        return
    
    # Add to container
    asset_container.add_child(asset_instance)
    current_asset = asset_instance
    
    # Center the camera on the asset
    center_camera_on_asset(asset_instance)
    
    update_status("Loaded: " + asset_path.get_file())

func center_camera_on_asset(asset: Node3D):
    """Center the camera on an asset"""
    if not camera or not asset:
        return
    
    # Simple centering - position camera behind and above asset
    camera.position = asset.position + Vector3(5, 3, 5)
    camera.look_at(asset.position)
```

### Asset Browser UI

```gdscript
func create_asset_browser():
    """Create an asset browser with file list"""
    # Create browser panel
    var browser_panel = Panel.new()
    browser_panel.name = "AssetBrowser"
    browser_panel.position = Vector2(220, 50)
    browser_panel.size = Vector2(300, 400)
    ui_panel.add_child(browser_panel)
    
    # Create title
    var title = Label.new()
    title.text = "Asset Browser"
    title.position = Vector2(10, 10)
    title.size = Vector2(280, 30)
    browser_panel.add_child(title)
    
    # Create asset list
    var asset_list = VBoxContainer.new()
    asset_list.name = "AssetList"
    asset_list.position = Vector2(10, 50)
    asset_list.size = Vector2(280, 300)
    browser_panel.add_child(asset_list)
    
    # Add some example assets
    var example_assets = [
        "res://Assets/PSX/PSX Nature/Models/FBX/tree_1.fbx",
        "res://Assets/PSX/PSX Nature/Models/FBX/grass_1.fbx",
        "res://Assets/PSX/PSX Nature/Models/FBX/stone_1.fbx"
    ]
    
    for asset_path in example_assets:
        var button = Button.new()
        button.text = asset_path.get_file()
        button.custom_minimum_size = Vector2(260, 25)
        button.pressed.connect(Callable(self, "load_asset_from_path").bind(asset_path))
        asset_list.add_child(button)
```

## PSX Nature Asset Example

### Complete PSX Asset Viewer

```gdscript
extends Node3D

# PSX Asset Viewer - Complete Example
class_name PSXAssetViewer

# UI references
@onready var ui_panel: Control
@onready var status_label: Label
@onready var camera: Camera3D

# Asset management
var asset_container: Node3D
var current_asset: Node3D

# PSX asset categories
var asset_categories = {
    "trees": [
        "res://Assets/PSX/PSX Nature/Models/FBX/tree_1.fbx",
        "res://Assets/PSX/PSX Nature/Models/FBX/tree_5.fbx",
        "res://Assets/PSX/PSX Nature/Models/FBX/tree_6.fbx"
    ],
    "vegetation": [
        "res://Assets/PSX/PSX Nature/Models/FBX/grass_1.fbx",
        "res://Assets/PSX/PSX Nature/Models/FBX/grass_2.fbx",
        "res://Assets/PSX/PSX Nature/Models/FBX/fern_1.fbx"
    ],
    "stones": [
        "res://Assets/PSX/PSX Nature/Models/FBX/stone_1.fbx",
        "res://Assets/PSX/PSX Nature/Models/FBX/stone_2.fbx",
        "res://Assets/PSX/PSX Nature/Models/FBX/stone_3.fbx"
    ]
}

func _ready():
    # Setup camera
    camera = get_node_or_null("Camera3D")
    if not camera:
        print("Camera3D not found!")
        return
    
    # Create UI
    create_psx_ui_overlay()
    
    # Create asset container
    asset_container = Node3D.new()
    asset_container.name = "PSXAssetContainer"
    add_child(asset_container)
    
    # Initialize
    update_status("PSX Asset Viewer Ready")

func create_psx_ui_overlay():
    """Create PSX-specific UI overlay"""
    # Main UI panel
    ui_panel = Control.new()
    ui_panel.name = "PSXUIPanel"
    add_child(ui_panel)
    ui_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    
    # Status label
    status_label = Label.new()
    status_label.name = "StatusLabel"
    status_label.text = "PSX Asset Viewer - Ready"
    status_label.position = Vector2(10, 10)
    status_label.size = Vector2(400, 30)
    ui_panel.add_child(status_label)
    
    # Create category tabs
    create_category_tabs()
    
    # Create control panel
    create_control_panel()

func create_category_tabs():
    """Create tabs for different asset categories"""
    var tab_container = HBoxContainer.new()
    tab_container.name = "CategoryTabs"
    tab_container.position = Vector2(10, 50)
    tab_container.size = Vector2(600, 40)
    ui_panel.add_child(tab_container)
    
    for category in asset_categories:
        var tab_button = Button.new()
        tab_button.name = category.capitalize() + "Tab"
        tab_button.text = category.capitalize()
        tab_button.custom_minimum_size = Vector2(100, 35)
        tab_button.pressed.connect(Callable(self, "show_category").bind(category))
        tab_container.add_child(tab_button)
    
    # Create asset list
    var asset_list = VBoxContainer.new()
    asset_list.name = "AssetList"
    asset_list.position = Vector2(10, 100)
    asset_list.size = Vector2(600, 300)
    ui_panel.add_child(asset_list)

func create_control_panel():
    """Create control panel for asset manipulation"""
    var control_panel = Panel.new()
    control_panel.name = "ControlPanel"
    control_panel.position = Vector2(620, 50)
    control_panel.size = Vector2(200, 400)
    ui_panel.add_child(control_panel)
    
    # Control title
    var title = Label.new()
    title.text = "Asset Controls"
    title.position = Vector2(10, 10)
    title.size = Vector2(180, 30)
    control_panel.add_child(title)
    
    # Control buttons
    var control_container = VBoxContainer.new()
    control_container.name = "ControlContainer"
    control_container.position = Vector2(10, 50)
    control_container.size = Vector2(180, 340)
    control_panel.add_child(control_container)
    
    var controls = [
        {"name": "LoadRandom", "text": "Load Random", "callback": "load_random_asset"},
        {"name": "ClearAll", "text": "Clear All", "callback": "clear_all_assets"},
        {"name": "RotateAsset", "text": "Rotate Asset", "callback": "rotate_current_asset"},
        {"name": "ScaleUp", "text": "Scale Up", "callback": "scale_asset_up"},
        {"name": "ScaleDown", "text": "Scale Down", "callback": "scale_asset_down"},
        {"name": "ApplyTexture", "text": "Apply Texture", "callback": "apply_test_texture"},
        {"name": "ResetTransform", "text": "Reset Transform", "callback": "reset_asset_transform"}
    ]
    
    for control in controls:
        var button = Button.new()
        button.name = control.name
        button.text = control.text
        button.custom_minimum_size = Vector2(160, 30)
        control_container.add_child(button)
        button.pressed.connect(Callable(self, control.callback))

func show_category(category: String):
    """Show assets from a specific category"""
    update_status("Showing " + category + " assets")
    
    # Clear current asset list
    var asset_list = ui_panel.get_node_or_null("AssetList")
    if asset_list:
        for child in asset_list.get_children():
            child.queue_free()
    
    # Add category assets
    var assets = asset_categories.get(category, [])
    for asset_path in assets:
        var button = Button.new()
        button.text = asset_path.get_file()
        button.custom_minimum_size = Vector2(580, 25)
        button.pressed.connect(Callable(self, "load_psx_asset").bind(asset_path))
        asset_list.add_child(button)

func load_psx_asset(asset_path: String):
    """Load a PSX asset"""
    update_status("Loading PSX asset: " + asset_path.get_file())
    
    # Clear existing assets
    clear_all_assets()
    
    # Load asset
    var asset_scene = load(asset_path)
    if not asset_scene:
        update_status("Failed to load asset: " + asset_path)
        return
    
    # Instantiate
    var asset_instance = asset_scene.instantiate()
    if not asset_instance:
        update_status("Failed to instantiate asset")
        return
    
    # Add to container
    asset_container.add_child(asset_instance)
    current_asset = asset_instance
    
    # Center camera
    center_camera_on_asset(asset_instance)
    
    update_status("Loaded: " + asset_path.get_file())

func load_random_asset():
    """Load a random asset from any category"""
    var all_assets = []
    for category in asset_categories:
        all_assets.append_array(asset_categories[category])
    
    if all_assets.size() > 0:
        var random_asset = all_assets[randi() % all_assets.size()]
        load_psx_asset(random_asset)

func rotate_current_asset():
    """Rotate the current asset"""
    if current_asset:
        current_asset.rotate_y(PI / 4)
        update_status("Rotated asset")

func scale_asset_up():
    """Scale the current asset up"""
    if current_asset:
        current_asset.scale *= 1.2
        update_status("Scaled asset up")

func scale_asset_down():
    """Scale the current asset down"""
    if current_asset:
        current_asset.scale *= 0.8
        update_status("Scaled asset down")

func apply_test_texture():
    """Apply a test texture to the current asset"""
    if current_asset:
        # Create a simple test texture
        var material = StandardMaterial3D.new()
        material.albedo_color = Color(0.2, 0.8, 0.2)  # Green
        
        # Apply to all mesh instances
        apply_material_recursive(current_asset, material)
        update_status("Applied test texture")

func apply_material_recursive(node: Node, material: Material):
    """Recursively apply material to all mesh instances"""
    if node is MeshInstance3D:
        node.material_override = material
    
    for child in node.get_children():
        apply_material_recursive(child, material)

func reset_asset_transform():
    """Reset the current asset's transform"""
    if current_asset:
        current_asset.transform = Transform3D.IDENTITY
        update_status("Reset asset transform")

func clear_all_assets():
    """Clear all assets"""
    if asset_container:
        for child in asset_container.get_children():
            child.queue_free()
    current_asset = null
    update_status("Cleared all assets")

func center_camera_on_asset(asset: Node3D):
    """Center camera on asset"""
    if not camera or not asset:
        return
    
    # Simple centering - position camera behind and above asset
    camera.position = asset.position + Vector3(5, 3, 5)
    camera.look_at(asset.position)

func update_status(message: String):
    """Update status label"""
    if status_label:
        status_label.text = "PSX Asset Viewer - " + message
    print("PSX Asset Viewer: " + message)

func _input(event):
    """Handle camera input"""
    if not camera:
        return
    
    # Mouse look
    if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        camera.rotate_y(-event.relative.x * 0.005)
        camera.rotate_object_local(Vector3.RIGHT, -event.relative.y * 0.005)
    
    # Keyboard movement
    var camera_speed = 5.0
    var delta = get_process_delta_time()
    
    if Input.is_key_pressed(KEY_W):
        camera.translate(Vector3.FORWARD * camera_speed * delta)
    if Input.is_key_pressed(KEY_S):
        camera.translate(Vector3.BACK * camera_speed * delta)
    if Input.is_key_pressed(KEY_A):
        camera.translate(Vector3.LEFT * camera_speed * delta)
    if Input.is_key_pressed(KEY_D):
        camera.translate(Vector3.RIGHT * camera_speed * delta)
    if Input.is_key_pressed(KEY_Q):
        camera.translate(Vector3.UP * camera_speed * delta)
    if Input.is_key_pressed(KEY_E):
        camera.translate(Vector3.DOWN * camera_speed * delta)
```

## Common UI Patterns

### Modal Dialogs

```gdscript
func create_modal_dialog(title: String, content: String):
    """Create a modal dialog"""
    # Create background overlay
    var overlay = ColorRect.new()
    overlay.name = "ModalOverlay"
    overlay.color = Color(0, 0, 0, 0.5)
    overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    ui_panel.add_child(overlay)
    
    # Create dialog panel
    var dialog = Panel.new()
    dialog.name = "ModalDialog"
    dialog.position = Vector2(300, 200)
    dialog.size = Vector2(400, 200)
    overlay.add_child(dialog)
    
    # Add title
    var title_label = Label.new()
    title_label.text = title
    title_label.position = Vector2(10, 10)
    title_label.size = Vector2(380, 30)
    dialog.add_child(title_label)
    
    # Add content
    var content_label = Label.new()
    content_label.text = content
    content_label.position = Vector2(10, 50)
    content_label.size = Vector2(380, 100)
    dialog.add_child(content_label)
    
    # Add close button
    var close_button = Button.new()
    close_button.text = "Close"
    close_button.position = Vector2(150, 160)
    close_button.size = Vector2(100, 30)
    close_button.pressed.connect(Callable(overlay, "queue_free"))
    dialog.add_child(close_button)
```

## Troubleshooting

### Common UI Issues

#### Problem 1: UI Not Visible
**Solutions**:
- Check if UI panel has proper anchors
- Ensure UI is added to the scene tree
- Verify UI position is within screen bounds

#### Problem 2: Buttons Not Responding
**Solutions**:
- Check button signal connections
- Ensure button is not covered by other UI elements
- Verify button is enabled and visible

#### Problem 3: Assets Not Loading
**Solutions**:
- Check file paths are correct
- Verify asset files exist
- Check for loading errors in console

### Debug Tips

```gdscript
func debug_ui_hierarchy():
    """Print UI hierarchy for debugging"""
    print_ui_tree(ui_panel, 0)

func print_ui_tree(node: Node, depth: int):
    """Recursively print UI tree"""
    var indent = "  ".repeat(depth)
    print(indent + "- " + node.name + " (" + node.get_class() + ")")
    
    for child in node.get_children():
        print_ui_tree(child, depth + 1)

func debug_asset_loading(asset_path: String):
    """Debug asset loading process"""
    print("Attempting to load: " + asset_path)
    
    if not FileAccess.file_exists(asset_path):
        print("ERROR: File does not exist!")
        return
    
    var asset = load(asset_path)
    if not asset:
        print("ERROR: Failed to load asset!")
        return
    
    print("SUCCESS: Asset loaded successfully")
    print("Asset type: " + asset.get_class())
```

## Usage Instructions

1. **Run the scene** in Godot
2. **Use category tabs** to browse different asset types
3. **Click on assets** to load them into the viewer
4. **Use camera controls**:
   - WASD: Move camera
   - Right mouse: Look around
   - Q/E: Move up/down
5. **Use control panel** to manipulate loaded assets

This guide should help you create powerful asset viewing tools in Godot, perfect for testing and managing your 3D assets!
