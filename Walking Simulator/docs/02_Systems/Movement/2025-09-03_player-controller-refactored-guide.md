# PlayerControllerRefactored - Enhanced Player Movement & Camera System

**Date:** 2025-09-03  
**Script:** `Player Controller/PlayerControllerRefactored.gd`  
**Scene:** `Player Controller/PlayerRefactored.tscn`  
**Test Scene:** `Player Controller/PlayerControllerTest.tscn`

## 🎯 **What This System Provides**

### **1. Smooth Movement System**
- **Smooth acceleration/deceleration** like the demo player
- **Camera-relative movement** (WASD always moves relative to camera direction)
- **Running system** with Shift key
- **Smooth speed transitions** with configurable acceleration/deceleration

### **2. Following Camera System**
- **Third-person camera** that follows behind the player
- **Smooth camera following** with configurable smoothness
- **Collision-aware** using SpringArm3D
- **First/third person toggle** with V key
- **Mouse look** with configurable sensitivity

### **3. Exploration-Focused Design**
- **Ground-level perspective** for immersive exploration
- **Hidden map boundaries** - player must explore to discover areas
- **Smooth navigation** through complex terrain
- **Responsive controls** for finding collectibles and NPCs

## 🚀 **Key Features**

### **Movement Features**
- **WASD Movement**: Smooth, responsive movement in all directions
- **Running**: Hold Shift to run at double speed
- **Jumping**: Space bar for jumping with configurable force
- **Smooth Transitions**: Gradual speed changes for natural feel
- **Air Control**: Limited movement control while in air

### **Camera Features**
- **Following Camera**: Camera automatically follows player
- **Mouse Look**: Smooth camera rotation with mouse
- **View Toggle**: Switch between first and third person (V key)
- **Collision Detection**: Camera avoids obstacles automatically
- **Configurable Distance**: Adjustable camera follow distance

### **Input Features**
- **Mouse Capture**: Automatic mouse capture for smooth camera control
- **Escape Toggle**: ESC key toggles mouse visibility
- **Debug Info**: T key shows player status information
- **Fullscreen Toggle**: F key toggles fullscreen mode

## 🎮 **Controls**

### **Movement Controls**
- **W**: Move forward (relative to camera)
- **A**: Move left (relative to camera)
- **S**: Move backward (relative to camera)
- **D**: Move right (relative to camera)
- **Shift**: Run (double speed)
- **Space**: Jump

### **Camera Controls**
- **Mouse**: Look around (camera rotation)
- **V**: Toggle between first/third person
- **ESC**: Toggle mouse capture mode

### **Debug Controls**
- **T**: Show debug information
- **F**: Toggle fullscreen
- **1**: Test player teleportation
- **2**: Test camera system
- **3**: Test movement system
- **R**: Reset player position
- **H**: Show test help

## 🔧 **Configuration**

### **Movement Settings**
```gdscript
@export var move_speed: float = 8.0          # Base movement speed
@export var run_speed: float = 16.0          # Running speed
@export var jump_force: float = 8.0          # Jump strength
@export var acceleration: float = 25.0       # Speed increase rate
@export var deceleration: float = 30.0       # Speed decrease rate
@export var air_control: float = 0.3         # Air movement control
```

### **Camera Settings**
```gdscript
@export var mouse_sensitivity: float = 0.002    # Mouse look sensitivity
@export var camera_distance: float = 6.0        # Camera follow distance
@export var camera_height: float = 2.0          # Camera height above player
@export var camera_smoothness: float = 8.0      # Camera follow smoothness
@export var max_pitch: float = 70.0             # Maximum upward look angle
@export var min_pitch: float = -30.0            # Maximum downward look angle
```

### **Physics Settings**
```gdscript
@export var gravity: float = 40.0               # Gravity strength
@export var max_fall_speed: float = 50.0        # Maximum fall speed
```

## 🏗️ **Scene Structure**

### **Required Node Hierarchy**
```
PlayerRefactored (CharacterBody3D)
├── CollisionShape3D
├── PlayerBody (MeshInstance3D)
├── CameraPivot (Node3D)
│   └── CameraArm (SpringArm3D)
│       └── Camera3D
├── InteractionController (RayCast3D)
│   └── InteractionPrompt (Label)
└── GroundCheck (RayCast3D)
```

### **Camera System Components**
- **CameraPivot**: Handles vertical camera rotation (pitch)
- **CameraArm**: SpringArm3D for collision detection and distance
- **Camera3D**: The actual camera with configurable properties

## 📱 **Input Action Mapping**

### **Required Input Actions**
Make sure these actions are defined in **Project Settings > Input Map**:

```
move_forward  → W key
move_back     → S key
move_left     → A key
move_right    → D key
jump          → Space key
sprint        → Shift key
```

### **Fallback Input System**
The controller also supports direct key detection as a fallback:
- `Input.is_key_pressed(KEY_W)` for movement
- `Input.is_key_pressed(KEY_SHIFT)` for running
- `Input.is_key_pressed(KEY_SPACE)` for jumping

## 🎯 **Public API Functions**

### **Player Information**
```gdscript
func get_player_position() -> Vector3          # Get current position
func get_movement_speed() -> float            # Get current speed
func is_player_running() -> bool              # Check if running
func get_camera_distance() -> float           # Get camera distance
```

### **Player Control**
```gdscript
func set_player_position(new_position: Vector3)  # Teleport player
func set_movement_speed(new_speed: float)        # Change movement speed
func set_camera_distance(new_distance: float)    # Change camera distance
```

### **Debug Functions**
```gdscript
func print_debug_info()                        # Print player status
func toggle_mouse_mode()                       # Toggle mouse capture
func toggle_camera_view()                      # Toggle first/third person
func toggle_fullscreen()                       # Toggle fullscreen
```

## 🔄 **Integration with Existing Systems**

### **Non-Destructive Design**
- **Separate script**: `PlayerControllerRefactored.gd` doesn't replace existing code
- **Compatible structure**: Works with existing `InteractionController`
- **Easy migration**: Can be gradually adopted in scenes

### **Scene Integration**
1. **Replace script**: Change Player scene script to `PlayerControllerRefactored.gd`
2. **Update scene structure**: Ensure camera hierarchy matches requirements
3. **Test movement**: Verify WASD movement and camera following work
4. **Adjust settings**: Configure movement and camera parameters as needed

### **Existing Scene Compatibility**
- **Papua Scene**: Can replace existing player controller
- **Tambora Scene**: Can replace existing player controller
- **Test Scenes**: Use new test scene for validation

## 🧪 **Testing and Validation**

### **Test Scene Features**
- **Movement Testing**: Test all movement directions and speeds
- **Camera Testing**: Test camera following and rotation
- **Collision Testing**: Test obstacle avoidance
- **Performance Testing**: Monitor FPS and responsiveness

### **Test Commands**
- **1**: Test player teleportation
- **2**: Test camera system
- **3**: Test movement system
- **R**: Reset player position
- **H**: Show test help

### **Validation Checklist**
- [ ] WASD movement works smoothly
- [ ] Camera follows player correctly
- [ ] Mouse look responds properly
- [ ] Running (Shift) works
- [ ] Jumping (Space) works
- [ ] Camera collision detection works
- [ ] First/third person toggle works
- [ ] Performance is acceptable (60+ FPS)

## 🎨 **Customization Examples**

### **Fast Movement Setup**
```gdscript
# In the scene or via code
player.move_speed = 12.0
player.run_speed = 24.0
player.acceleration = 35.0
```

### **Smooth Camera Setup**
```gdscript
# For very smooth camera following
player.camera_smoothness = 4.0
player.mouse_sensitivity = 0.001
```

### **Exploration-Focused Setup**
```gdscript
# For immersive exploration
player.camera_distance = 8.0
player.camera_height = 1.5
player.move_speed = 6.0
```

## 🚨 **Troubleshooting**

### **Common Issues**

#### **Camera Not Following**
- Check if `CameraPivot` node exists
- Verify `CameraArm` is a `SpringArm3D`
- Ensure `Camera3D` is a child of `CameraArm`

#### **Movement Not Working**
- Verify input actions are mapped in Project Settings
- Check if `CharacterBody3D` collision is enabled
- Ensure script is properly attached

#### **Poor Performance**
- Reduce `camera_smoothness` value
- Lower `mouse_sensitivity` if too responsive
- Check for excessive debug logging

### **Debug Commands**
- **T**: Shows comprehensive debug information
- **Console**: Check for error messages
- **Performance**: Monitor FPS in debug info

## 🔗 **Related Files**

- **Main Script**: `Player Controller/PlayerControllerRefactored.gd`
- **Player Scene**: `Player Controller/PlayerRefactored.tscn`
- **Test Scene**: `Player Controller/PlayerControllerTest.tscn`
- **Documentation**: This file
- **Demo Reference**: `demo/src/Player.gd` (inspiration for smooth movement)

## 🎯 **Use Cases**

### **Perfect For**
- **Exploration Games**: Hidden map discovery
- **Adventure Games**: Smooth navigation through complex environments
- **Cultural Games**: Immersive cultural exploration
- **Test Scenes**: Player movement validation

### **Benefits**
1. **Smooth Movement**: Professional-grade movement feel
2. **Immersive Camera**: Following camera for exploration
3. **Configurable**: Easy to adjust for different game styles
4. **Non-Destructive**: Doesn't break existing systems
5. **Well-Tested**: Comprehensive test scene included

---

**Note**: This system provides a modern, smooth player controller that's perfect for exploration-focused gameplay where players need to discover the world around them without seeing the full map extent from the start.
