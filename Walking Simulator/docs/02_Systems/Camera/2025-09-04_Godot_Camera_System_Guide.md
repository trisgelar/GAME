# Godot Camera System Architecture Guide - 2025-09-04

## 🎯 **Overview**
Comprehensive guide to Godot camera systems, focusing on the complex camera architecture used in the Papua scene project. This guide explains the node hierarchy, camera types, and implementation patterns for beginners.

## 🏗️ **Camera System Architecture**

### **Basic Camera Structure**
```
Player (CharacterBody3D)
├── CameraPivot (Node3D)           # Camera rotation center
│   ├── SpringArm3D (SpringArm3D)  # Camera arm with collision
│   │   └── Camera3D (Camera3D)    # Actual camera
│   └── [Alternative: CameraArm]   # Different naming conventions
```

### **Node Purposes Explained**

#### **1. Player (CharacterBody3D)**
- **Purpose**: Main character body with physics
- **Role**: Provides position and movement for camera system
- **Properties**: Position, rotation, velocity, collision

#### **2. CameraPivot (Node3D)**
- **Purpose**: Camera rotation center point
- **Role**: Handles horizontal (Y-axis) rotation
- **Properties**: Position relative to player, Y-axis rotation
- **Why needed**: Separates player movement from camera rotation

#### **3. SpringArm3D (SpringArm3D)**
- **Purpose**: Camera arm with automatic collision avoidance
- **Role**: Handles vertical (X-axis) rotation and distance
- **Properties**: Spring length, collision detection, X-axis rotation
- **Benefits**: Prevents camera clipping through walls

#### **4. Camera3D (Camera3D)**
- **Purpose**: Actual camera that renders the scene
- **Role**: Final camera position and rendering
- **Properties**: FOV, near/far clipping, projection mode

## 🔧 **Camera Implementation Patterns**

### **Pattern 1: Simple First-Person Camera**
```gdscript
# Simple camera attached directly to player
@onready var camera: Camera3D = $Camera3D

func _ready():
    camera.current = true
```

### **Pattern 2: Complex Third-Person Camera (Our Implementation)**
```gdscript
# Complex camera with pivot and arm
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D

func _ready():
    camera.current = true
    setup_camera()
```

### **Pattern 3: Robust Camera Resolution (Our Solution)**
```gdscript
# Handles different scene structures
func setup_camera():
    # Try CameraArm first (for Fixed scene)
    if has_node("CameraPivot/CameraArm"):
        camera_arm = get_node("CameraPivot/CameraArm") as SpringArm3D
        camera = get_node("CameraPivot/CameraArm/Camera3D") as Camera3D
    # Try SpringArm3D (for TerrainAssets scene)
    elif has_node("CameraPivot/SpringArm3D"):
        camera_arm = get_node("CameraPivot/SpringArm3D") as SpringArm3D
        camera = get_node("CameraPivot/SpringArm3D/Camera3D") as Camera3D
    else:
        print("No camera found!")
```

## 🎮 **Camera Control Systems**

### **Mouse Look Implementation**
```gdscript
# Mouse input handling
func _input(event):
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        last_mouse_delta = event.relative

# Camera rotation processing
func handle_mouse_look():
    var mouse_delta = last_mouse_delta
    last_mouse_delta = Vector2.ZERO
    
    if mouse_delta.length() > 0.0:
        # Update target rotation
        target_camera_rotation.x -= mouse_delta.x * mouse_sensitivity
        target_camera_rotation.y -= mouse_delta.y * mouse_sensitivity
        
        # Clamp pitch (vertical rotation)
        target_camera_rotation.y = clamp(target_camera_rotation.y, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
```

### **Camera Smoothing**
```gdscript
# Smooth camera rotation
func handle_complex_camera(delta: float):
    # Update camera rotation with smoothing
    camera_rotation = camera_rotation.lerp(target_camera_rotation, camera_smoothness * delta)
    
    # Apply camera rotation
    camera_pivot.rotation.y = camera_rotation.x  # Horizontal (Y-axis)
    camera_arm.rotation.x = camera_rotation.y    # Vertical (X-axis)
```

## 🖱️ **Mouse Mode Management**

### **Mouse Mode Types**
```gdscript
# Mouse mode options
Input.MOUSE_MODE_VISIBLE    # Mouse visible, can interact with UI
Input.MOUSE_MODE_CAPTURED   # Mouse captured, for camera control
Input.MOUSE_MODE_CONFINED   # Mouse confined to window
Input.MOUSE_MODE_HIDDEN     # Mouse hidden but not captured
```

### **Mouse Mode Toggle Implementation**
```gdscript
func _input(event):
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_M:  # M key toggles mouse mode
            if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
                Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
                print("Mouse mode: VISIBLE")
            else:
                Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
                print("Mouse mode: CAPTURED")
```

## 📐 **Camera Settings and Parameters**

### **Essential Camera Parameters**
```gdscript
# Camera sensitivity and limits
var mouse_sensitivity: float = 0.00025  # Mouse sensitivity
var camera_distance: float = 6.0        # SpringArm3D length
var camera_height: float = 1.5          # Camera height above player
var camera_smoothness: float = 2.0      # Rotation smoothing
var max_pitch: float = 70.0             # Maximum vertical rotation
var min_pitch: float = -30.0            # Minimum vertical rotation
```

### **Camera3D Properties**
```gdscript
# Camera3D node properties
camera.fov = 70.0           # Field of view (degrees)
camera.near = 0.1           # Near clipping plane
camera.far = 100.0          # Far clipping plane
camera.current = true       # Make this camera active
```

## 🎯 **Common Camera Issues and Solutions**

### **Issue 1: Camera Not Working**
**Symptoms**: Camera doesn't respond to mouse input
**Causes**: 
- Wrong mouse mode
- Missing camera node references
- Incorrect input handling

**Solutions**:
```gdscript
# Check mouse mode
if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Verify camera references
if not camera:
    print("Camera not found!")
    return
```

### **Issue 2: Camera Looking Wrong Direction**
**Symptoms**: Camera points at sky or ground
**Causes**: 
- Incorrect initial rotation
- Wrong transform setup

**Solutions**:
```gdscript
# Reset camera rotations
camera_pivot.rotation = Vector3.ZERO
camera_arm.rotation = Vector3.ZERO
camera.rotation = Vector3.ZERO

# Set initial rotation
target_camera_rotation = Vector2.ZERO
camera_rotation = Vector2.ZERO
```

### **Issue 3: Camera Clipping Through Walls**
**Symptoms**: Camera goes through objects
**Causes**: 
- No SpringArm3D collision
- Wrong collision settings

**Solutions**:
```gdscript
# Enable SpringArm3D collision
camera_arm.collision_mask = 1  # Collide with layer 1
camera_arm.spring_length = 6.0
```

### **Issue 4: Camera Too Sensitive/Not Sensitive Enough**
**Symptoms**: Camera moves too fast or too slow
**Causes**: 
- Wrong mouse sensitivity value

**Solutions**:
```gdscript
# Adjust sensitivity
var mouse_sensitivity: float = 0.00025  # Increase for faster, decrease for slower
```

## 🔄 **Camera System Integration**

### **Integration with Player Movement**
```gdscript
# Camera-relative movement
func get_camera_relative_input() -> Vector3:
    var input_dir: Vector3 = Vector3.ZERO
    
    if not camera:
        return input_dir
    
    # Use camera basis for movement direction
    if move_input.x < 0: # Left
        input_dir -= camera.global_transform.basis.x
    if move_input.x > 0: # Right
        input_dir += camera.global_transform.basis.x
    if move_input.y < 0: # Forward
        input_dir -= camera.global_transform.basis.z
    if move_input.y > 0: # Backward
        input_dir += camera.global_transform.basis.z
    
    return input_dir
```

### **Integration with UI Systems**
```gdscript
# Handle UI interaction
func _input(event):
    # Mouse mode toggle for UI interaction
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_M:
            toggle_mouse_mode()
    
    # Mouse look only when captured
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        handle_mouse_look()
```

## 📚 **Best Practices**

### **1. Camera Setup**
- Always set `camera.current = true` for the active camera
- Use SpringArm3D for third-person cameras to avoid clipping
- Implement robust camera node resolution for different scenes

### **2. Input Handling**
- Use appropriate mouse modes for different contexts
- Implement mouse mode toggles for UI interaction
- Handle input only when appropriate (e.g., mouse look when captured)

### **3. Performance**
- Use camera smoothing for better feel
- Limit debug logging to avoid performance issues
- Cache camera references to avoid repeated node lookups

### **4. Debugging**
- Add debug logging for camera position and rotation
- Log mouse mode changes
- Verify camera node references on startup

## 🎮 **Multi-View Camera System (Future)**

### **Camera View Types**
```gdscript
enum CameraView {
    FIRST_PERSON,   # Current implementation
    THIRD_PERSON,   # Behind player
    CANOPY,         # High altitude view
    CINEMATIC       # Scripted camera movements
}
```

### **View Switching Implementation**
```gdscript
var current_view: CameraView = CameraView.FIRST_PERSON
var camera_controllers: Dictionary = {}

func switch_camera_view(new_view: CameraView):
    current_view = new_view
    setup_camera_for_view(new_view)
```

## 📝 **Summary**

### **Key Takeaways**
1. **Node Hierarchy Matters**: Proper camera structure is crucial for functionality
2. **Mouse Mode Management**: Essential for UI interaction vs camera control
3. **Robust Resolution**: Handle different scene structures gracefully
4. **Smooth Controls**: Implement camera smoothing for better feel
5. **Debug Logging**: Add comprehensive logging for troubleshooting

### **Essential Components**
- **CameraPivot**: Rotation center
- **SpringArm3D**: Collision-aware camera arm
- **Camera3D**: Actual camera
- **Mouse Mode Toggle**: For UI interaction
- **Input Handling**: Mouse look and movement

### **Common Patterns**
- **First-Person**: Direct camera attachment
- **Third-Person**: Pivot + Arm + Camera
- **Robust Resolution**: Multiple node path attempts
- **Mouse Mode Toggle**: M key for UI interaction

---
*Guide created: 2025-09-04*  
*Based on: Papua scene camera system implementation*  
*Status: Comprehensive reference for Godot camera systems*
