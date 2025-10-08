# Topeng Mask Overlay Server

**Port:** 8889 (Default)  
**Purpose:** Real-time face mask overlay with MediaPipe face detection

---

## Features

- ✅ Real-time face detection using MediaPipe
- ✅ 3D pose tracking (yaw, pitch, roll)
- ✅ Modular mask composition (base + mata/eyes + mulut/mouth)
- ✅ Multi-face support (up to 4 faces)
- ✅ Smooth motion tracking
- ✅ UDP command protocol for mask switching

---

## Installation

### 1. Install Dependencies

```bash
cd "D:\ISSAT Game\Game\Webcam Server\Topeng"
pip install -r requirements_topeng.txt
```

Required packages:
- `opencv-python==4.12.0.88`
- `numpy==2.2.6`
- `mediapipe==0.10.20`

### 2. Verify Installation

```bash
python -c "import cv2, numpy, mediapipe; print('✅ All dependencies installed!')"
```

---

## Usage

### Option 1: Run Directly

```bash
cd "D:\ISSAT Game\Game\Webcam Server\Topeng"
python udp_webcam_server.py
```

### Option 2: Use Batch File

Double-click `start_topeng_server.bat` in the parent folder.

### Option 3: Custom Port

```bash
python udp_webcam_server.py --port 9000
```

---

## UDP Commands

Send these commands as UTF-8 text to the server:

### Registration
```
REGISTER          # Connect to server
UNREGISTER        # Disconnect from server
```

### Single Mask
```
SET_MASK bali.png              # Load full mask by filename
SET_MASK_PATH /full/path.png   # Load mask by full path
```

### Custom Mask Composition
```
SET_CUSTOM_MASK 1,2,3     # base1.png + mata2.png + mulut3.png
SET_CUSTOM_MASK 2,0,1     # base2.png + (no eyes) + mulut1.png
SET_CUSTOM_MASK 0,0,0     # Clear mask
```

### List Available Masks
```
LIST_MASKS        # Returns comma-separated list of masks
```

---

## Available Masks

### Full Masks (Traditional Indonesian Masks)
- `bali.png` - Balinese mask
- `betawi.png` - Betawi mask
- `hudoq.png`, `hudoq1.png`, `hudoq3.png` - Hudoq (Dayak) masks
- `kelana.png` - Kelana mask
- `panji2.png`, `panji3.png` - Panji masks
- `prabu.png` - Prabu mask
- `sumatra.png` - Sumatran mask

### Modular Components
- **Base (Face):** `base1.png`, `base2.png`, `base3.png`
- **Eyes (Mata):** `mata1.png`, `mata2.png`, `mata3.png`
- **Mouth (Mulut):** `mulut1.png`, `mulut2.png`, `mulut3.png`

---

## Server Responses

```
REGISTERED                    # Registration successful
SET_MASK_RECEIVED             # Command received
MASK_SET:<filename>           # Mask successfully loaded
CUSTOM_MASK_SET:<ids>         # Custom mask successfully composed

ERR_SET_MASK:<filename>       # Mask loading failed
ERR_SET_CUSTOM_MASK:<ids>     # Custom mask composition failed
ERR_NO_ENGINE                 # FilterEngine not available
NO_MASKS / NO_FOLDER          # No masks found
```

---

## Configuration

### Mask Folder

The server auto-detects the `mask/` folder next to the script.

To use a different folder:
```bash
python udp_webcam_server.py --masks_folder /path/to/masks
```

### Camera Settings

Edit `udp_webcam_server.py` (lines 93-98):

```python
self.max_packet_size = 32768  # UDP packet size
self.target_fps = 15          # Frame rate
self.jpeg_quality = 40        # JPEG compression (0-100)
self.frame_width = 480        # Camera width
self.frame_height = 360       # Camera height
```

---

## Godot Integration

### In TopengWebcamController.gd

```gdscript
func setup_webcam_manager():
    # Load WebcamManagerUDP
    var webcam_script = load("res://Scenes/EthnicityDetection/WebcamClient/WebcamManagerUDP.gd")
    webcam_manager = webcam_script.new()
    add_child(webcam_manager)
    
    # ✅ IMPORTANT: Set port to 8889 for Topeng server
    webcam_manager.server_port = 8889
    
    # Connect signals
    webcam_manager.frame_received.connect(_on_webcam_frame_received)
    webcam_manager.connection_changed.connect(_on_webcam_connection_changed)
    
    # Connect to Topeng server
    webcam_manager.connect_to_webcam_server()

func select_mask(mask_name: String):
    var command = "SET_MASK " + mask_name
    var msg = command.to_utf8_buffer()
    webcam_manager.udp_client.put_packet(msg)

func customize_mask(base_id: int, mata_id: int, mulut_id: int):
    var command = "SET_CUSTOM_MASK %d,%d,%d" % [base_id, mata_id, mulut_id]
    var msg = command.to_utf8_buffer()
    webcam_manager.udp_client.put_packet(msg)
```

---

## Performance

### CPU Usage
- Idle (no clients): ~2%
- Active with 1 face: ~20-25%
- Active with 4 faces: ~35-40%

### Optimization
- Detection runs at 0.75x scale (configurable in `filter_ref.py` line 105)
- Face tracking reduces re-detection overhead
- Motion-adaptive smoothing improves stability

---

## Troubleshooting

### Server won't start
```bash
# Check if port 8889 is already in use
netstat -ano | findstr :8889

# Try a different port
python udp_webcam_server.py --port 9000
```

### Camera not found
```bash
# Check if camera is available
python -c "import cv2; cap = cv2.VideoCapture(0); print('Camera OK' if cap.isOpened() else 'Camera Error')"
```

### Mask not loading
- Verify mask file exists in `mask/` folder
- Check file format (must be PNG with transparency)
- Check server logs for error messages

### MediaPipe errors
```bash
# Reinstall MediaPipe
pip uninstall mediapipe
pip install mediapipe==0.10.20
```

---

## Architecture

```
UDP Client (Godot)
      │
      ├─> REGISTER / UNREGISTER
      ├─> SET_MASK / SET_CUSTOM_MASK
      │
      ▼
UDP Server (Port 8889)
      │
      ├─> Camera capture
      ├─> Filter Engine
      │
      ▼
FilterEngine (filter_ref.py)
      │
      ├─> MediaPipe face detection
      ├─> Pose estimation
      ├─> Mask composition
      ├─> 3D rotation
      │
      ▼
Processed frames with mask overlay
      │
      └─> Sent back to UDP client
```

---

## Files

```
Topeng/
├── udp_webcam_server.py       # Main server
├── filter_ref.py              # Face detection & mask overlay
├── requirements_topeng.txt    # Python dependencies
├── README_TOPENG.md           # This file
└── mask/                      # Mask assets (PNG)
    ├── bali.png
    ├── betawi.png
    ├── base1.png, base2.png, base3.png
    ├── mata1.png, mata2.png, mata3.png
    └── mulut1.png, mulut2.png, mulut3.png
```

---

## Credits

- **MediaPipe**: Google's face detection solution
- **OpenCV**: Computer vision library
- **Filter System**: Custom 3D mask overlay with pose tracking

---

**Status:** ✅ Ready for production  
**Port:** 8889 (default)  
**Recommended:** Run alongside Ethnicity Detection Server (Port 8888)

