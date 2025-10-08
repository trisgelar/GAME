# Topeng Mask Overlay Server - Setup Guide

**Port:** 8889 (separate from ML server on 8888)  
**Date:** October 8, 2025

---

## 🎯 Why a Separate Server?

The Topeng server is kept separate from the Ethnicity ML server because:

| Feature | Ethnicity ML (8888) | Topeng Masks (8889) |
|---------|-------------------|-------------------|
| **numpy version** | 2.2.6 (for ML models) | 1.24-1.26 (for MediaPipe) |
| **Main dependency** | scikit-learn, scikit-image | mediapipe |
| **Purpose** | Ethnicity detection | Face mask overlay |
| **Virtual environment** | `Webcam Server/env` | `Topeng Server/env` |

**CONFLICT:** MediaPipe requires `numpy<2`, but the ML server uses `numpy>=2`. Therefore, each server has its own virtual environment.

---

## ⚡ Quick Setup

### Step 1: Create Virtual Environment

```bash
cd "Topeng Server"
python -m venv env
```

**Expected output:**
```
Creating virtual environment...
(creates env folder)
```

---

### Step 2: Activate Environment

**Windows:**
```bash
env\Scripts\activate.bat
```

**Expected prompt:**
```
(env) D:\ISSAT Game\Game\Topeng Server>
```

---

### Step 3: Install Dependencies

```bash
pip install -r requirements_topeng.txt
```

**Expected packages:**
- ✅ opencv-python (>=4.8.0)
- ✅ numpy (1.24-1.26, **NOT 2.x**)
- ✅ mediapipe (>=0.10.0)
- ✅ Pillow (>=10.0.0)

**Installation time:** ~2-3 minutes

---

### Step 4: Test Server

```bash
python udp_webcam_server.py --port 8889
```

**Expected output:**
```
=== Topeng Mask UDP Webcam Server ===
🎭 Port: 8889
📡 Host: 127.0.0.1
✅ Found masks folder: D:\ISSAT Game\Game\Topeng Server\mask
✅ FilterEngine initialized with 19 masks
🎥 Initializing camera...
✅ Camera ready: 640x480 @ 15FPS
🚀 Optimized UDP Server: 127.0.0.1:8889
⏸️  No clients connected - camera paused (saves CPU/bandwidth)
```

**Press Ctrl+C to stop.**

✅ If you see this, setup is complete!

---

## 🚀 Running the Server

### Option 1: Batch Script (Recommended)

Double-click: `start_topeng_server.bat`

**This script:**
- ✅ Checks if virtual environment exists
- ✅ Activates environment automatically
- ✅ Checks if dependencies are installed
- ✅ Starts server on port 8889
- ✅ Shows clear error messages if something is wrong

---

### Option 2: Manual Command

```bash
cd "Topeng Server"
env\Scripts\activate.bat
python udp_webcam_server.py --port 8889
```

---

### Option 3: Start Both Servers

From the main game folder, double-click: `start_both_servers.bat`

**This opens 2 windows:**
1. Ethnicity ML Server (Port 8888)
2. Topeng Mask Server (Port 8889)

---

## 🎭 Server Features

### ✅ Camera Pause/Resume

**When no clients:**
```
⏸️  No clients connected - camera paused (saves CPU/bandwidth)
```
- CPU usage: ~2-3%
- Camera not accessed
- MediaPipe not running

**When client connects:**
```
✅ Client: ('127.0.0.1', 58693) (Total: 1)
▶️  Client(s) connected (1) - camera resumed
📤 Frame 1: 12KB → 1 clients
```
- CPU usage: ~20-25%
- Camera streaming
- MediaPipe processing

---

### ✅ Mask Commands

The server supports these commands from Godot:

**1. SET_MASK (preset mask)**
```
SET_MASK bali.png
```

**2. SET_MASK_PATH (full path)**
```
SET_MASK_PATH D:/path/to/custom_mask.png
```

**3. SET_CUSTOM_MASK (modular mask)**
```
SET_CUSTOM_MASK 1,2,3
```
(base_id, mata_id, mulut_id)

**4. LIST_MASKS**
```
LIST_MASKS
```

---

### ✅ Available Masks

The `mask` folder contains 19 PNG masks:

**Base masks (full face):**
- `bali.png`
- `betawi.png`
- `hudoq.png`, `hudoq1.png`, `hudoq3.png`
- `kelana.png`
- `panji2.png`, `panji3.png`
- `prabu.png`
- `sumatra.png`

**Modular components:**
- **Base:** `base1.png`, `base2.png`, `base3.png`
- **Eyes:** `mata1.png`, `mata2.png`, `mata3.png`
- **Mouth:** `mulut1.png`, `mulut2.png`, `mulut3.png`

---

## 🔧 Troubleshooting

### Error: "Cannot install numpy==2.2.6"

**Cause:** MediaPipe requires `numpy<2`

**Fix:**
```bash
# Edit requirements_topeng.txt to use:
numpy>=1.24.0,<2.0.0

# Then install:
pip install -r requirements_topeng.txt
```

✅ **Already fixed in current version!**

---

### Error: "Virtual environment not found"

**Fix:**
```bash
cd "Topeng Server"
python -m venv env
```

---

### Error: "ModuleNotFoundError: No module named 'mediapipe'"

**Fix:**
```bash
cd "Topeng Server"
env\Scripts\activate.bat
pip install -r requirements_topeng.txt
```

---

### Error: "Camera already in use"

**Cause:** Another program (or the Ethnicity server) is using the camera

**Fix:**
- Only run ONE camera server at a time (either Ethnicity OR Topeng)
- OR: Use the dual-server architecture where each server pauses when not in use

---

### Warning: "FilterEngine not available"

**Cause:** `filter_ref.py` not found

**Fix:**
- Ensure `filter_ref.py` is in the same folder as `udp_webcam_server.py`
- If missing, copy from source: `D:\Torrent\Compressed\Godot\Webcam Server\filter_ref.py`

---

### Error: "Masks folder not found"

**Cause:** `mask` folder is missing

**Fix:**
- Ensure `mask` folder exists in `Topeng Server` directory
- Should contain 19 PNG files
- If missing, copy from source

---

## 📊 Performance

### Idle (No Clients)
- **CPU:** ~2-3%
- **Memory:** ~150-200 MB
- **Network:** 0 bytes/s

### Active (1 Client)
- **CPU:** ~20-25%
- **Memory:** ~200-250 MB
- **Network:** ~30-50 KB/s (15 FPS, Q40)

### MediaPipe Processing
- **Face Detection:** ~5-10ms per frame
- **Mask Overlay:** ~2-5ms per frame
- **Total Latency:** ~50-100ms (including network)

---

## 🎮 Godot Integration

### Scene Connection

The TopengWebcamController connects to port 8889:

```gdscript
func setup_webcam_manager():
    webcam_manager.server_port = 8889  # ✅ Topeng server
    webcam_manager.connect_to_server()
```

### Cleanup on Exit

```gdscript
func cleanup_resources() -> void:
    if webcam_manager:
        webcam_manager.disconnect_from_server()  # ✅ Sends UNREGISTER
        webcam_manager.queue_free()
        webcam_manager = null
```

**Result:** Server pauses camera automatically

---

## 🔍 Verify Setup

### Checklist

- [ ] Virtual environment created (`env` folder exists)
- [ ] Dependencies installed (`pip list` shows mediapipe, opencv-python, numpy<2)
- [ ] `mask` folder exists with 19 PNG files
- [ ] `filter_ref.py` exists
- [ ] `udp_webcam_server.py` exists
- [ ] Server starts without errors
- [ ] Shows "camera paused" message when no clients
- [ ] CPU usage is 2-3% when idle

### Test Command

```bash
cd "Topeng Server"
env\Scripts\activate.bat
python -c "import cv2, mediapipe, numpy; print('✅ All dependencies OK!')"
python udp_webcam_server.py --port 8889
```

**Expected:**
```
✅ All dependencies OK!
=== Topeng Mask UDP Webcam Server ===
🎭 Port: 8889
📡 Host: 127.0.0.1
⏸️  No clients connected - camera paused
```

---

## 📚 Related Documentation

- **README_TOPENG.md** - Topeng server overview
- **filter_ref.py** - MediaPipe face detection and mask overlay engine
- **requirements_topeng.txt** - Python dependencies (numpy<2)
- **../Webcam Server/README.md** - Ethnicity ML server (numpy 2.x)
- **../start_both_servers.bat** - Dual server startup script

---

## ✅ Summary

### Setup Complete When:

✅ Virtual environment created and activated  
✅ Dependencies installed (numpy<2, mediapipe, opencv)  
✅ Server starts on port 8889  
✅ Shows "camera paused" when idle  
✅ CPU usage ~2-3% when no clients  
✅ Mask folder contains 19 PNG files  
✅ No error messages

### Next Steps:

1. Test connecting from Godot (TopengNusantara scene)
2. Verify mask overlay works
3. Test scene switching (Ethnicity ↔ Topeng)
4. Confirm proper cleanup (UNREGISTER message)

---

**Setup Status:** ✅ **READY**  
**Server Port:** 8889  
**Virtual Env:** Separate from ML server (numpy<2)  
**Last Updated:** October 8, 2025

