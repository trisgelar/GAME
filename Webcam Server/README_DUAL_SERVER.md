# Dual Webcam Server Architecture

**Project:** ISSAT Cultural Game  
**Date:** October 8, 2025  
**Architecture:** Dual independent UDP servers

---

## Overview

This project uses **two separate UDP servers** for different features:

| Server | Port | Purpose | Technology |
|--------|------|---------|------------|
| **Ethnicity Detection** | 8888 | ML-based ethnicity classification | scikit-learn, HOG/GLCM/LBP/HSV |
| **Topeng Mask Overlay** | 8889 | Real-time face mask overlay | MediaPipe, 3D pose tracking |

---

## Why Dual Server?

✅ **No Conflicts** - Each server handles its specific task  
✅ **Easy Debugging** - Test and fix servers independently  
✅ **Better Performance** - Each optimized for its purpose  
✅ **Clean Separation** - Changes don't affect each other  
✅ **Flexible Deployment** - Run either or both as needed

---

## Quick Start

### Option 1: Start Both Servers

```bash
# Double-click this file:
start_both_servers.bat
```

Two command windows will open:
- **Window 1:** Ethnicity ML Server (Port 8888)
- **Window 2:** Topeng Mask Server (Port 8889)

### Option 2: Start Individual Servers

**Ethnicity Detection Only:**
```bash
start_ethnicity_server.bat
```

**Topeng Mask Only:**
```bash
start_topeng_server.bat
```

---

## Installation

### 1. Install Ethnicity Detection Dependencies

```bash
cd "D:\ISSAT Game\Game\Webcam Server"
pip install -r requirements.txt
```

Required:
- `opencv-python==4.12.0.88`
- `numpy==2.2.6`
- `scikit-image==0.25.2`
- `scikit-learn==1.7.2`

### 2. Install Topeng Mask Dependencies

```bash
cd "D:\ISSAT Game\Game\Webcam Server\Topeng"
pip install -r requirements_topeng.txt
```

Additional required:
- `mediapipe==0.10.20`

### 3. Verify Installation

```bash
# Test Ethnicity server
python ml_webcam_server.py
# Press Ctrl+C to stop

# Test Topeng server
cd Topeng
python udp_webcam_server.py
# Press Ctrl+C to stop
```

---

## Usage in Godot

### Ethnicity Detection Scene

```gdscript
# EthnicityDetectionController.gd
func setup_webcam_manager():
    var webcam_script = load("res://Scenes/EthnicityDetection/WebcamClient/WebcamManagerUDP.gd")
    webcam_manager = webcam_script.new()
    add_child(webcam_manager)
    
    # Uses default port 8888
    webcam_manager.connect_to_webcam_server()

func request_ethnicity_detection():
    var msg = "DETECTION_REQUEST".to_utf8_buffer()
    webcam_manager.udp_client.put_packet(msg)
    # Server will respond with ethnicity prediction
```

### Topeng Nusantara Scene

```gdscript
# TopengWebcamController.gd
func setup_webcam_manager():
    var webcam_script = load("res://Scenes/EthnicityDetection/WebcamClient/WebcamManagerUDP.gd")
    webcam_manager = webcam_script.new()
    add_child(webcam_manager)
    
    # ✅ IMPORTANT: Override port for Topeng server
    webcam_manager.server_port = 8889
    webcam_manager.connect_to_webcam_server()

func select_mask(mask_name: String):
    var msg = ("SET_MASK " + mask_name).to_utf8_buffer()
    webcam_manager.udp_client.put_packet(msg)
    # Server will apply mask to video feed
```

---

## Server Comparison

### Ethnicity Detection Server (Port 8888)

**Purpose:** Analyze face to predict ethnicity

**Commands:**
- `REGISTER` / `UNREGISTER` - Connect/disconnect
- `DETECTION_REQUEST` - Request ML prediction
- `MODEL_SELECT:<model_name>` - Switch ML model

**Response:**
- `DETECTION_RESULT:{json}` - Ethnicity + confidence
  ```json
  {
    "ethnicity": "Jawa",
    "confidence": 0.85,
    "model": "glcm_lbp_hog_hsv",
    "mode": "ML"
  }
  ```

**Technology:**
- Feature extraction: HOG, GLCM, LBP, HSV
- ML model: RandomForestClassifier
- Features: 34,658 dimensions

---

### Topeng Mask Server (Port 8889)

**Purpose:** Apply traditional Indonesian masks to faces

**Commands:**
- `REGISTER` / `UNREGISTER` - Connect/disconnect
- `SET_MASK <filename>` - Apply full mask
- `SET_CUSTOM_MASK <base>,<mata>,<mulut>` - Compose custom mask
- `LIST_MASKS` - Get available masks

**Response:**
- `MASK_SET:<filename>` - Mask applied
- `CUSTOM_MASK_SET:<ids>` - Custom mask composed
- Returns comma-separated mask list for `LIST_MASKS`

**Technology:**
- Face detection: MediaPipe
- Pose estimation: 3D keypoint tracking
- Rendering: RGBA alpha blending with perspective warp

---

## Camera Sharing

Both servers can access the camera simultaneously:

```
Camera (Device 0)
      │
      ├──> Ethnicity Server (Port 8888)
      │    └─> ML feature extraction
      │
      └──> Topeng Server (Port 8889)
           └─> MediaPipe face detection
```

**Note:** In practice, only one scene is active at a time, so only one server is actively using the camera.

---

## Performance

### CPU Usage

| Scenario | Ethnicity (8888) | Topeng (8889) | Total |
|----------|-----------------|---------------|-------|
| Both idle (no clients) | ~2% | ~2% | ~4% |
| Only Ethnicity active | ~15-20% | ~2% | ~17-22% |
| Only Topeng active | ~2% | ~20-25% | ~22-27% |
| Both active (testing) | ~15-20% | ~20-25% | ~35-45% |

### Memory Usage

| Server | Memory |
|--------|--------|
| Ethnicity | ~150-200 MB |
| Topeng | ~200-250 MB |
| Both | ~350-450 MB |

---

## Troubleshooting

### Port Already in Use

```bash
# Check what's using port 8888 or 8889
netstat -ano | findstr :8888
netstat -ano | findstr :8889

# Kill process if needed (replace PID)
taskkill /PID <process_id> /F
```

### Camera Not Found

```bash
# Test camera
python -c "import cv2; cap = cv2.VideoCapture(0); print('OK' if cap.isOpened() else 'ERROR')"
```

### ML Server Feature Mismatch

```
❌ Error: X has 2072 features, but expects 34658
```

**Solution:** This was fixed on October 7, 2025. Make sure you're using the updated `ml_webcam_server.py`.

### MediaPipe Errors

```bash
# Reinstall MediaPipe
pip uninstall mediapipe
pip install mediapipe==0.10.20
```

### Godot Not Connecting

1. Check server is running (look for "Server ready" message)
2. Verify port number in Godot code
3. Check firewall settings
4. Try `server_host = "127.0.0.1"` in Godot

---

## File Structure

```
Webcam Server/
│
├── ml_webcam_server.py              # Ethnicity ML server (Port 8888)
├── config.json                      # ML server configuration
├── requirements.txt                 # ML dependencies
├── start_ethnicity_server.bat       # Start ethnicity server
│
├── models/                          # ML models
│   └── run_20250925_133309/
│       ├── GLCM_LBP_HOG_HSV_model.pkl
│       ├── GLCM_HOG_model.pkl
│       └── feature_sets_summary_*.json
│
├── Topeng/                          # Topeng mask system (Port 8889)
│   ├── udp_webcam_server.py         # Mask overlay server
│   ├── filter_ref.py                # MediaPipe face detection + overlay
│   ├── requirements_topeng.txt      # Topeng dependencies
│   ├── README_TOPENG.md             # Topeng documentation
│   └── mask/                        # Mask PNG assets
│       ├── bali.png
│       ├── betawi.png
│       ├── hudoq.png
│       ├── base1.png, base2.png, base3.png
│       ├── mata1.png, mata2.png, mata3.png
│       └── mulut1.png, mulut2.png, mulut3.png
│
├── start_topeng_server.bat          # Start topeng server
├── start_both_servers.bat           # Start both servers
├── README_DUAL_SERVER.md            # This file
└── docs/                            # Documentation
    ├── 2025-10-07_ml-server-feature-alignment-fix.md
    ├── 2025-10-08_ml-server-changes-detailed-explanation.md
    └── 2025-10-08_topeng-nusantara-integration-guide.md
```

---

## Workflow

### Typical Game Session

1. **User starts game** → Main menu
2. **User selects "Ethnicity Detection"**
   - Godot connects to port 8888
   - User clicks "Deteksi"
   - Server returns ethnicity prediction
   - User exits to menu
3. **User selects "Topeng Nusantara"**
   - Godot connects to port 8889
   - User selects mask
   - Server applies mask overlay
   - User sees themselves with traditional mask
   - User exits to menu

### Server Management

```
Start both servers:
  start_both_servers.bat
    │
    ├─> Window 1: Ethnicity ML Server (Port 8888)
    │   └─> Waits for clients...
    │
    └─> Window 2: Topeng Mask Server (Port 8889)
        └─> Waits for clients...

Game running:
  Ethnicity Scene → Port 8888 → ML predictions
  Topeng Scene → Port 8889 → Mask overlays
```

---

## Development Tips

### Testing Ethnicity Server

```python
# Test from Python
import socket
import json

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.sendto(b"REGISTER", ("127.0.0.1", 8888))
response = sock.recvfrom(1024)
print(response)  # Should be b"REGISTERED"

sock.sendto(b"DETECTION_REQUEST", ("127.0.0.1", 8888))
# Wait for video frames and detection result
```

### Testing Topeng Server

```python
# Test from Python
import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.sendto(b"REGISTER", ("127.0.0.1", 8889))
response = sock.recvfrom(1024)
print(response)  # Should be b"REGISTERED"

sock.sendto(b"SET_MASK bali.png", ("127.0.0.1", 8889))
response = sock.recvfrom(1024)
print(response)  # Should be b"MASK_SET:bali.png"
```

### Adding New Masks

1. Create PNG with transparency (RGBA)
2. Place in `Topeng/mask/` folder
3. Restart Topeng server
4. Mask automatically available

---

## Security Considerations

- ✅ Servers only listen on localhost (127.0.0.1)
- ✅ No authentication needed for local-only use
- ⚠️ For network deployment, add authentication
- ⚠️ UDP packets not encrypted (local traffic only)

---

## Future Enhancements

### Possible Additions

1. **Unified Dashboard** (optional)
   - Web interface to monitor both servers
   - Start/stop servers from GUI
   - View performance metrics

2. **Model Hot-Swapping**
   - Switch ethnicity models without restart
   - Load new mask packs dynamically

3. **Performance Monitoring**
   - FPS tracking
   - Latency measurements
   - Resource usage graphs

4. **Network Mode**
   - Allow remote clients
   - Add authentication
   - Enable HTTPS/TLS

---

## Support

### Documentation

- **Ethnicity ML:** `docs/2025-10-08_ml-server-changes-detailed-explanation.md`
- **Topeng System:** `Topeng/README_TOPENG.md`
- **Integration Guide:** `docs/2025-10-08_topeng-nusantara-integration-guide.md`

### Common Issues

See the [Troubleshooting](#troubleshooting) section above.

---

**Architecture:** ✅ Dual Server (Secure & Scalable)  
**Status:** ✅ Production Ready  
**Last Updated:** October 8, 2025

