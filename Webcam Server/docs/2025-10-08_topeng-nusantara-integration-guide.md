# Topeng Nusantara Integration Guide

**Date:** October 8, 2025  
**Source:** `D:\Torrent\Compressed\Godot\Webcam Server\`  
**Purpose:** Integrate facemask overlay system with existing ML webcam server

---

## Overview

You have a **complete facemask overlay system** that:
- ✅ Uses MediaPipe for face detection and tracking
- ✅ Supports custom mask composition (base + mata/eyes + mulut/mouth)
- ✅ Has pose-aware 3D rotation (yaw, pitch, roll)
- ✅ Includes UDP server with command protocol
- ✅ Thread-safe mask switching

This is **separate and complementary** to the ethnicity detection system!

---

## Your Current Implementation

### Architecture

```
┌────────────────────────────────────────────────────────────┐
│           udp_webcam_server.py (Port 8888)                  │
│  - Camera capture                                           │
│  - UDP frame broadcasting                                   │
│  - Command handling (SET_MASK, SET_CUSTOM_MASK)            │
│  └─> Calls filter_ref.FilterEngine.process_frame()         │
└────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌────────────────────────────────────────────────────────────┐
│           filter_ref.FilterEngine                           │
│  - MediaPipe face detection                                 │
│  - Face tracking across frames                              │
│  - Mask composition (base + mata + mulut)                   │
│  - 3D pose estimation (yaw, pitch, roll)                    │
│  - Dynamic scaling and smoothing                            │
│  └─> Returns processed frame with mask overlay             │
└────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌────────────────────────────────────────────────────────────┐
│                    Mask Assets (PNG)                        │
│  Base masks: base1.png, base2.png, base3.png              │
│  Eyes: mata1.png, mata2.png, mata3.png                    │
│  Mouth: mulut1.png, mulut2.png, mulut3.png                │
│  Full masks: bali.png, betawi.png, hudoq.png, etc.        │
└────────────────────────────────────────────────────────────┘
```

### Key Features

| Feature | Implementation | Quality |
|---------|---------------|---------|
| **Face Detection** | MediaPipe Face Detection | ⭐⭐⭐⭐⭐ Excellent |
| **Face Tracking** | Greedy nearest-neighbor with timeout | ⭐⭐⭐⭐ Good |
| **Mask Composition** | 3-layer RGBA blending | ⭐⭐⭐⭐⭐ Excellent |
| **Pose Estimation** | Keypoint-based (eyes, nose) | ⭐⭐⭐⭐ Good |
| **3D Rotation** | Perspective warp | ⭐⭐⭐⭐ Good |
| **Smoothing** | Motion-adaptive alpha blending | ⭐⭐⭐⭐⭐ Excellent |
| **Multi-face** | Up to 4 faces simultaneously | ⭐⭐⭐⭐ Good |
| **Performance** | Downscaled detection (0.75x) | ⭐⭐⭐⭐ Optimized |

---

## Command Protocol

### Supported Commands

Your server supports these UDP text commands:

```python
# 1. Registration
"REGISTER"           # Client connects
"UNREGISTER"         # Client disconnects

# 2. Single mask (full mask image)
"SET_MASK <filename>"        # e.g., "SET_MASK bali.png"
"SET_MASK_PATH <fullpath>"   # e.g., "SET_MASK_PATH /full/path/mask.png"

# 3. Custom composition (modular)
"SET_CUSTOM_MASK <base_id>,<mata_id>,<mulut_id>"
# e.g., "SET_CUSTOM_MASK 1,2,3"  → base1.png + mata2.png + mulut3.png
# 0 or omit = don't use that layer

# 4. List available masks
"LIST_MASKS"         # Returns comma-separated filenames
```

### Response Messages

```python
"REGISTERED"                 # Registration confirmed
"SET_MASK_RECEIVED"          # Command received (queued)
"MASK_SET:<filename>"        # Mask successfully set
"ERR_SET_MASK:<filename>"    # Mask loading failed

"CUSTOM_MASK_SET:<ids>"      # Custom mask successfully set
"ERR_SET_CUSTOM_MASK:<ids>"  # Custom mask loading failed

"NO_MASKS" / "NO_FOLDER"     # No masks available
"ERR_NO_ENGINE"              # FilterEngine not available
```

---

## Integration Options

### Option 1: Run as Separate Server (RECOMMENDED)

**Pros:**
- ✅ No conflicts with ethnicity detection server
- ✅ Can run simultaneously on different ports
- ✅ Easier to debug and maintain
- ✅ Each server has its own resources

**Setup:**
```python
# Ethnicity Detection Server (Port 8888)
cd "D:\ISSAT Game\Game\Webcam Server"
python ml_webcam_server.py

# Topeng Mask Server (Port 8889)
cd "D:\Torrent\Compressed\Godot\Webcam Server"
python udp_webcam_server.py --port 8889
```

**Godot Client:**
```gdscript
# EthnicityDetectionController.gd
var server_port = 8888  # Ethnicity detection

# TopengWebcamController.gd
var server_port = 8889  # Mask overlay
```

### Option 2: Merge into Single Server (COMPLEX)

**Pros:**
- ✅ Single server to manage
- ✅ Can share camera resource
- ✅ Unified configuration

**Cons:**
- ❌ Complex integration
- ❌ ML and MediaPipe in same process (threading issues?)
- ❌ Harder to debug
- ❌ Code maintenance overhead

I **DO NOT recommend this** unless you have a specific reason.

---

## Recommended Architecture: Dual Server

```
┌─────────────────────────────────────────────────────────────┐
│                        Game (Godot)                          │
└─────────────────────────────────────────────────────────────┘
                 │                           │
                 │                           │
     Port 8888   │                           │   Port 8889
    ┌────────────▼─────┐          ┌─────────▼────────┐
    │  ML Webcam Server │          │ Mask Webcam Server│
    │  (ml_webcam_      │          │ (udp_webcam_     │
    │   server.py)      │          │  server.py)      │
    │                   │          │                  │
    │ - Ethnicity ML    │          │ - Face detection │
    │ - HOG/GLCM/LBP    │          │ - Mask overlay   │
    │ - 34,658 features │          │ - Pose tracking  │
    └───────────────────┘          └──────────────────┘
            │                               │
            └───────────┬───────────────────┘
                        │
                   Camera (0)
           (Shared via OS, not conflict)
```

### Why This Works

1. **OS-level camera sharing**: Modern OS allows multiple processes to access webcam
2. **Independent control**: Each server has its own clients/commands
3. **Scene-specific**: Ethnicity scene uses port 8888, Topeng scene uses port 8889
4. **No code conflicts**: No need to merge complex codebases

---

## Step-by-Step Integration

### Step 1: Copy Topeng Server to Game Project

```bash
# Copy the mask server files
mkdir "D:\ISSAT Game\Game\Webcam Server\Topeng"
cp "D:\Torrent\Compressed\Godot\Webcam Server\udp_webcam_server.py" "D:\ISSAT Game\Game\Webcam Server\Topeng\"
cp "D:\Torrent\Compressed\Godot\Webcam Server\filter_ref.py" "D:\ISSAT Game\Game\Webcam Server\Topeng\"
cp -r "D:\Torrent\Compressed\Godot\Webcam Server\mask" "D:\ISSAT Game\Game\Webcam Server\Topeng\"
```

### Step 2: Install Dependencies

```bash
cd "D:\ISSAT Game\Game\Webcam Server\Topeng"
pip install mediapipe opencv-python numpy
```

Create `requirements_topeng.txt`:
```txt
opencv-python==4.12.0.88
numpy==2.2.6
mediapipe==0.10.20
```

### Step 3: Modify Topeng Server for Port 8889

```python
# In udp_webcam_server.py, line 475+:
if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, default=8889, help="UDP port")
    parser.add_argument("--masks_folder", default=None, help="Masks folder")
    args = parser.parse_args()
    
    print("=== Topeng Mask UDP Server ===")
    server = UDPWebcamServer(port=args.port, masks_folder=args.masks_folder)
    server.start_server()
```

### Step 4: Create Startup Scripts

**`start_ethnicity_server.bat`:**
```batch
@echo off
cd "D:\ISSAT Game\Game\Webcam Server"
echo Starting Ethnicity Detection ML Server (Port 8888)...
python ml_webcam_server.py
pause
```

**`start_topeng_server.bat`:**
```batch
@echo off
cd "D:\ISSAT Game\Game\Webcam Server\Topeng"
echo Starting Topeng Mask Server (Port 8889)...
python udp_webcam_server.py --port 8889
pause
```

**`start_both_servers.bat`:**
```batch
@echo off
cd "D:\ISSAT Game\Game\Webcam Server"
echo Starting BOTH servers...
echo.
echo [1/2] Starting Ethnicity Detection Server (Port 8888)...
start "Ethnicity Server" cmd /k "python ml_webcam_server.py"
timeout /t 2 /nobreak >nul

echo [2/2] Starting Topeng Mask Server (Port 8889)...
cd Topeng
start "Topeng Server" cmd /k "python udp_webcam_server.py --port 8889"

echo.
echo Both servers started in separate windows!
echo Press any key to close this window...
pause >nul
```

### Step 5: Update Godot TopengWebcamController

```gdscript
# TopengWebcamController.gd

extends Control

@onready var webcam_feed = $MainContainer/WebcamContainer/WebcamPanel/WebcamFeed
@onready var mask_selector = $MainContainer/ControlPanel/MaskSelector  # Add UI dropdown
@onready var customize_button = $MainContainer/ControlPanel/CustomizeButton

var webcam_manager: Node
var current_mask: String = "bali.png"

func _ready():
	print("=== TopengWebcamController._ready() ===")
	setup_webcam_manager()
	setup_mask_selector()

func setup_webcam_manager():
	"""Setup WebcamManagerUDP for Topeng server (Port 8889)"""
	print("=== Setting up WebcamManagerUDP for Topeng ===")
	
	# Load WebcamManagerUDP script
	var webcam_script = load("res://Scenes/EthnicityDetection/WebcamClient/WebcamManagerUDP.gd")
	if webcam_script == null:
		print("❌ ERROR: Could not load WebcamManagerUDP.gd script!")
		return
	
	print("Creating WebcamManagerUDP instance...")
	webcam_manager = webcam_script.new()
	add_child(webcam_manager)
	
	# IMPORTANT: Override port for Topeng server!
	webcam_manager.server_port = 8889  # ✅ Different from ethnicity (8888)
	
	# Connect signals
	if webcam_manager.has_signal("frame_received"):
		webcam_manager.frame_received.connect(_on_webcam_frame_received)
	
	if webcam_manager.has_signal("connection_changed"):
		webcam_manager.connection_changed.connect(_on_webcam_connection_changed)
	
	# Connect to Topeng server
	print("Attempting UDP connection to Topeng server (port 8889)...")
	webcam_manager.connect_to_webcam_server()

func setup_mask_selector():
	"""Setup UI for mask selection"""
	# Request list of available masks from server
	if webcam_manager and webcam_manager.is_connected:
		var list_msg = "LIST_MASKS".to_utf8_buffer()
		webcam_manager.udp_client.put_packet(list_msg)
		print("📋 Requested mask list from server")

func _on_mask_selected(mask_filename: String):
	"""Called when user selects a mask from UI"""
	print("🎭 Selecting mask: ", mask_filename)
	
	if not webcam_manager or not webcam_manager.is_connected:
		print("❌ Not connected to Topeng server")
		return
	
	# Send SET_MASK command to server
	var command = "SET_MASK " + mask_filename
	var msg = command.to_utf8_buffer()
	webcam_manager.udp_client.put_packet(msg)
	
	current_mask = mask_filename
	print("📤 Sent SET_MASK command:", mask_filename)

func _on_customize_mask(base_id: int, mata_id: int, mulut_id: int):
	"""Called when user customizes mask layers"""
	print("🎨 Customizing mask: base=%d, mata=%d, mulut=%d" % [base_id, mata_id, mulut_id])
	
	if not webcam_manager or not webcam_manager.is_connected:
		print("❌ Not connected to Topeng server")
		return
	
	# Send SET_CUSTOM_MASK command
	var command = "SET_CUSTOM_MASK %d,%d,%d" % [base_id, mata_id, mulut_id]
	var msg = command.to_utf8_buffer()
	webcam_manager.udp_client.put_packet(msg)
	
	print("📤 Sent SET_CUSTOM_MASK command")

func _on_webcam_frame_received(texture: ImageTexture):
	"""Receive frame with mask overlay"""
	if not webcam_feed:
		return
	
	# Frame already has mask overlay applied by server!
	webcam_feed.texture = texture

func _on_webcam_connection_changed(connected: bool):
	"""Handle connection status"""
	print("Topeng webcam connection changed: ", connected)
	if connected:
		print("✅ Connected to Topeng Mask Server (Port 8889)")
		# Load default mask
		_on_mask_selected("bali.png")

func cleanup_resources():
	"""Clean up on exit"""
	print("=== TopengWebcamController: Cleaning up ===")
	
	if webcam_manager:
		if webcam_manager.has_method("disconnect_from_server"):
			webcam_manager.disconnect_from_server()
		webcam_manager.queue_free()
		webcam_manager = null

func _notification(what):
	"""Handle scene exit"""
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE or what == NOTIFICATION_PREDELETE:
		cleanup_resources()
```

### Step 6: Update WebcamManagerUDP to Support Port Override

```gdscript
# WebcamManagerUDP.gd - Add this to support different ports

extends Node

signal frame_received(texture: ImageTexture)
signal connection_changed(connected: bool)
signal error_message(message: String)

var udp_client: PacketPeerUDP
var is_connected: bool = false
var server_host: String = "127.0.0.1"
var server_port: int = 8888  # Default, can be overridden!

# ... rest of code unchanged ...

func connect_to_webcam_server():
	if is_connected:
		return
		
	print("🔄 Connecting to server at %s:%d..." % [server_host, server_port])  # ✅ Uses custom port
	
	var error = udp_client.connect_to_host(server_host, server_port)
	if error != OK:
		_emit_error("UDP setup failed: " + str(error))
		return
	
	# ... rest unchanged ...
```

---

## Testing Checklist

### Test Ethnicity Detection (Port 8888)
- [ ] Start `ml_webcam_server.py`
- [ ] Open Ethnicity Detection scene in Godot
- [ ] Should connect to port 8888
- [ ] Click "Deteksi" → Should get ethnicity prediction
- [ ] Expected: 34,658 features extracted
- [ ] Expected: "Jawa" / "Sasak" / "Papua" result

### Test Topeng Masks (Port 8889)
- [ ] Start `udp_webcam_server.py --port 8889`
- [ ] Open Topeng Nusantara scene in Godot
- [ ] Should connect to port 8889
- [ ] Select mask (e.g., "bali.png")
- [ ] Expected: Mask appears on face with pose tracking
- [ ] Try custom mask: base1 + mata2 + mulut3
- [ ] Expected: Composed mask appears

### Test Both Servers Simultaneously
- [ ] Run `start_both_servers.bat`
- [ ] Both server windows open
- [ ] Switch between Ethnicity and Topeng scenes
- [ ] No conflicts, no errors
- [ ] Each scene uses its own server

---

## Advantages of This Architecture

| Aspect | Benefit |
|--------|---------|
| **Separation of Concerns** | Ethnicity ML and mask overlay are independent |
| **Easy Debugging** | Can test/fix each server separately |
| **Performance** | Each server optimized for its task |
| **Maintainability** | Changes to one don't affect the other |
| **Flexibility** | Can run either or both servers as needed |
| **Resource Isolation** | Memory/CPU issues isolated to one server |
| **Development Speed** | Can develop features in parallel |

---

## Performance Considerations

### Camera Sharing
- ✅ **Modern OS handles this**: Windows 10+ allows multiple apps to use webcam
- ✅ **No conflict**: Each server gets its own camera handle
- ⚠️ **Higher CPU**: Two face detection pipelines running

### CPU Usage Estimate

| Scenario | Ethnicity Server | Topeng Server | Total |
|----------|-----------------|---------------|-------|
| Both idle (no clients) | ~2% | ~2% | ~4% |
| Only Ethnicity active | ~15-20% | ~2% | ~17-22% |
| Only Topeng active | ~2% | ~20-25% | ~22-27% |
| Both active | ~15-20% | ~20-25% | ~35-45% |

**Note:** You'll never have both active simultaneously in normal gameplay (user is in one scene at a time).

---

## Advanced: Single Server Integration (NOT RECOMMENDED)

If you **really** want to merge both into one server, here's how:

```python
# hybrid_server.py
from ml_webcam_server import MLEthnicityDetector
from filter_ref import FilterEngine

class HybridServer:
    def __init__(self):
        self.ml_detector = MLEthnicityDetector()  # For ethnicity
        self.filter_engine = FilterEngine()        # For masks
        self.mode = "ethnicity"  # or "mask"
    
    def process_frame(self, frame):
        if self.mode == "ethnicity":
            # ML detection mode
            return frame  # Return unmodified for ML
        elif self.mode == "mask":
            # Mask overlay mode
            return self.filter_engine.process_frame(frame)
```

**Why NOT recommended:**
- ❌ Complex mode switching
- ❌ MediaPipe + scikit-learn in same process (potential conflicts)
- ❌ Harder to debug
- ❌ More memory usage (both systems loaded)
- ❌ Threading issues (Med iapipe is not thread-safe)

---

## File Structure

```
D:\ISSAT Game\Game\
└── Webcam Server/
    ├── ml_webcam_server.py          # Ethnicity detection (Port 8888)
    ├── config.json
    ├── requirements.txt
    ├── models/                       # ML models for ethnicity
    ├── start_ethnicity_server.bat
    │
    └── Topeng/                       # ✅ NEW: Topeng mask system
        ├── udp_webcam_server.py      # Mask overlay (Port 8889)
        ├── filter_ref.py
        ├── requirements_topeng.txt
        ├── start_topeng_server.bat
        └── mask/                      # Mask PNG assets
            ├── bali.png
            ├── betawi.png
            ├── hudoq.png
            ├── base1.png, base2.png, base3.png
            ├── mata1.png, mata2.png, mata3.png
            └── mulut1.png, mulut2.png, mulut3.png
```

---

## Summary

### What You Have
- ✅ **Sophisticated mask overlay system** with MediaPipe
- ✅ **Complete UDP server** with command protocol
- ✅ **Modular mask composition** (base + eyes + mouth)
- ✅ **Pose-aware 3D tracking**

### What You Need to Do
1. ✅ Copy files to `Webcam Server/Topeng/`
2. ✅ Install MediaPipe: `pip install mediapipe`
3. ✅ Modify server to use port 8889
4. ✅ Update `TopengWebcamController.gd` to connect to port 8889
5. ✅ Add mask selection UI
6. ✅ Test both servers running simultaneously

### Result
```
Ethnicity Detection Scene → ml_webcam_server.py (Port 8888) → ML predictions
Topeng Nusantara Scene → udp_webcam_server.py (Port 8889) → Mask overlays
```

**No conflicts, clean separation, easy maintenance!** 🎭✨

---

**Status:** ✅ Ready for integration  
**Recommended Approach:** Dual server (Port 8888 + 8889)  
**Next Step:** Copy files and test

