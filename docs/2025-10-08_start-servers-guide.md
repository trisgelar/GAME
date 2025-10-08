# How to Start Dual Webcam Servers

**Quick Guide:** Starting ML and Topeng servers in separate terminals

---

## 🎯 Quick Start (Separate Terminals)

### Step 1: Detect Your Cameras

```bash
cd "Webcam Server"
env\Scripts\activate.bat
python detect_cameras.py
```

**Example Output:**
```
✅ Camera 0: 1280x720 @ 30FPS - 🖥️  Internal (likely)
✅ Camera 1: 1280x720 @ 30FPS - 🔌 USB (likely)
✅ Camera 2: 1280x720 @ 30FPS - 🔌 USB (likely)

⚠️  IMPORTANT: Internal camera detected!
   To use USB cameras only:
      • ML Server: Camera ID 1 (First USB)
      • Topeng Server: Camera ID 2 (Second USB)
```

**Take note of which cameras are USB!**

---

### Step 2: Start ML Ethnicity Server

**Open Terminal 1:**

```bash
cd "Webcam Server"
start_ml_ethnicity_server.bat
```

**Or manually:**
```bash
cd "Webcam Server"
env\Scripts\activate.bat
python ml_webcam_server.py
```

**Expected Output:**
```
🎥 Initializing dedicated camera for ML server...
✅ Camera ready: 640x480 @ 15FPS (backend: DSHOW)
✅ Camera initialized - ML server ready!
🚀 ML-Enhanced UDP Server: 127.0.0.1:8888
🎥 Camera Status: Active and ready (dedicated hardware)
🔗 Waiting for client connections...
```

---

### Step 3: Start Topeng Mask Server

**Open Terminal 2 (NEW WINDOW):**

```bash
cd "Topeng Server"
start_topeng_mask_server.bat
```

**Or manually:**
```bash
cd "Topeng Server"
env\Scripts\activate.bat
python udp_webcam_server.py --port 8889 --camera_id 1
```

**Expected Output:**
```
🎭 Topeng Mask UDP Webcam Server
📹 Camera ID: 1
🚀 Optimized UDP Server: 127.0.0.1:8889
✅ Camera ready: 480x360 @ 15FPS
```

---

## ⚙️ Configuration for USB Cameras

If you have an **internal camera + 2 USB cameras**, you need to configure the servers to use the USB cameras.

### Scenario: Internal Camera Detected

**Your cameras:**
- Camera 0 = 🖥️  Internal laptop camera
- Camera 1 = 🔌 First USB webcam
- Camera 2 = 🔌 Second USB webcam

### Solution 1: Update ML Server Config

**File:** `Webcam Server/config.json`

```json
{
  "camera": {
    "camera_id": 1,  // Changed from 0 to 1 (First USB)
    "notes": "Camera ID 1 = First USB webcam"
  }
}
```

**Start ML Server:**
```bash
cd "Webcam Server"
start_ml_ethnicity_server.bat
```

### Solution 2: Update Topeng Server Startup

**File:** `Topeng Server/start_topeng_mask_server.bat`

Change line 60:
```bash
python udp_webcam_server.py --port 8889 --camera_id 2
```

**Or start manually with correct camera:**
```bash
cd "Topeng Server"
env\Scripts\activate.bat
python udp_webcam_server.py --port 8889 --camera_id 2
```

---

## 📝 Camera ID Quick Reference

### Common Setups

**Setup A: No Internal Camera (Desktop PC)**
```
Camera 0 = First USB webcam    → ML Server
Camera 1 = Second USB webcam   → Topeng Server
```

**Setup B: Laptop with Internal Camera**
```
Camera 0 = Internal camera (🖥️  Don't use)
Camera 1 = First USB webcam    → ML Server
Camera 2 = Second USB webcam   → Topeng Server
```

**Setup C: Disable Internal in BIOS**
```
Camera 0 = First USB webcam    → ML Server
Camera 1 = Second USB webcam   → Topeng Server
```

---

## ✅ Verification Steps

### 1. Check Camera Detection

```bash
cd "Webcam Server"
env\Scripts\activate.bat
python detect_cameras.py
```

Look for:
- ✅ At least 2 cameras detected
- 🔌 USB cameras identified
- Correct camera IDs noted

### 2. Start ML Server

**Terminal 1:**
```bash
cd "Webcam Server"
start_ml_ethnicity_server.bat
```

**Verify:**
- ✅ Camera initialized successfully
- ✅ Server shows "Active and ready"
- ✅ Port 8888 listening

### 3. Start Topeng Server

**Terminal 2 (NEW WINDOW):**
```bash
cd "Topeng Server"
start_topeng_mask_server.bat
```

**Verify:**
- ✅ Camera initialized successfully
- ✅ Server shows "Optimized UDP Server"
- ✅ Port 8889 listening
- ✅ Different camera than ML server

### 4. Test in Godot

1. Open Godot project
2. Open **Ethnicity Detection** scene
3. **Check:** Webcam feed appears (from ML server)
4. Exit to menu
5. Open **Topeng Nusantara** scene
6. **Check:** Webcam feed appears (from Topeng server)

---

## 🔧 Troubleshooting

### Problem: "Camera 0 not found"

**Cause:** Camera ID 0 is internal camera or doesn't exist

**Solution:**
1. Run `detect_cameras.py` to see available cameras
2. Update configuration to use USB camera IDs

### Problem: "Both servers using same camera"

**Cause:** Both servers configured with same camera_id

**Solution:**
1. ML Server: Use Camera ID 0 or 1
2. Topeng Server: Use different ID (1 or 2)
3. Make sure they're **different!**

### Problem: "Camera already in use"

**Cause:** Another application using the camera

**Solution:**
1. Close any camera applications (Zoom, Skype, etc.)
2. Restart the servers
3. Check Windows Camera app isn't running

### Problem: "Virtual environment not found"

**Cause:** Virtual environment not created

**Solution:**

**For ML Server:**
```bash
cd "Webcam Server"
python -m venv env
env\Scripts\activate.bat
pip install -r requirements.txt
```

**For Topeng Server:**
```bash
cd "Topeng Server"
python -m venv env
env\Scripts\activate.bat
pip install -r requirements_topeng.txt
```

---

## 📊 Server Status at a Glance

**Terminal 1 - ML Server:**
```
Port: 8888
Camera: 0 (or 1 if internal at 0)
Status: ✅ Active and ready
Purpose: Ethnicity detection with ML
```

**Terminal 2 - Topeng Server:**
```
Port: 8889
Camera: 1 (or 2 if internal at 0)
Status: ✅ Optimized UDP Server
Purpose: Mask overlay with MediaPipe
```

---

## 🎉 Summary

**To start servers:**
1. ✅ Run `detect_cameras.py` to identify USB cameras
2. ✅ Open Terminal 1 → Start ML server
3. ✅ Open Terminal 2 → Start Topeng server
4. ✅ Keep both terminals open
5. ✅ Test in Godot

**Each server has its own:**
- ✅ Dedicated USB webcam
- ✅ Separate virtual environment
- ✅ Independent port
- ✅ No conflicts!

---

**Status:** ✅ Ready for dual webcam operation!

