# Dual Servers - Separate Terminals Setup

**Created:** October 8, 2025  
**Purpose:** Run ML and Topeng servers in separate terminals with dedicated USB webcams

---

## 📁 New Files Created

### Startup Scripts

1. **`Webcam Server/start_ml_ethnicity_server.bat`**
   - Starts ML Ethnicity Detection server
   - Port 8888
   - Camera ID 0 (configurable)
   - Verifies camera availability
   - Shows USB camera warnings

2. **`Topeng Server/start_topeng_mask_server.bat`**
   - Starts Topeng Mask Overlay server
   - Port 8889
   - Camera ID 1 (configurable via --camera_id)
   - Verifies camera availability
   - Shows USB camera warnings

### Camera Detection

3. **`Webcam Server/detect_cameras.py`** (Enhanced)
   - Detects all available cameras
   - Identifies USB vs Internal cameras
   - Provides configuration recommendations
   - Warns about internal camera conflicts

### Documentation

4. **`START_SERVERS_GUIDE.md`**
   - Complete step-by-step guide
   - Camera configuration instructions
   - Troubleshooting tips
   - Quick reference

5. **`DUAL_SERVERS_SEPARATE_TERMINALS.md`** (This file)
   - Summary of changes
   - Quick start instructions

---

## 🚀 Quick Start

### Step 1: Detect Your Cameras

**Open Command Prompt:**
```bash
cd "D:\ISSAT Game\Game\Webcam Server"
env\Scripts\activate.bat
python detect_cameras.py
```

**Look for output like:**
```
✅ Camera 0: 1280x720 @ 30FPS - 🖥️  Internal (likely)
✅ Camera 1: 1280x720 @ 30FPS - 🔌 USB (likely)
✅ Camera 2: 1280x720 @ 30FPS - 🔌 USB (likely)

⚠️  IMPORTANT: Internal camera detected!
   To use USB cameras only:
      • ML Server: Camera ID 1 (First USB)
      • Topeng Server: Camera ID 2 (Second USB)
```

**Note the USB camera IDs!**

---

### Step 2: Configure Servers (If Using USB Cameras)

#### If you have internal camera at ID 0:

**ML Server - Update config.json:**
```json
{
  "camera": {
    "camera_id": 1,  // First USB camera
    "notes": "Camera ID 1 = First USB webcam"
  }
}
```

**Topeng Server - Edit startup script:**

Open `Topeng Server/start_topeng_mask_server.bat`

Change line 60 to:
```bash
python udp_webcam_server.py --port 8889 --camera_id 2
```

---

### Step 3: Start ML Server

**Terminal 1:**
```bash
cd "D:\ISSAT Game\Game\Webcam Server"
start_ml_ethnicity_server.bat
```

**Keep this terminal open!**

---

### Step 4: Start Topeng Server

**Terminal 2 (NEW WINDOW):**
```bash
cd "D:\ISSAT Game\Game\Topeng Server"
start_topeng_mask_server.bat
```

**Keep this terminal open too!**

---

## ✅ Expected Results

### Terminal 1 - ML Server
```
🎥 Initializing dedicated camera for ML server...
✅ Camera 1 detected
✅ Camera initialized - ML server ready!
🚀 ML-Enhanced UDP Server: 127.0.0.1:8888
🎥 Camera Status: Active and ready (dedicated hardware)
```

### Terminal 2 - Topeng Server
```
🎭 Topeng Mask UDP Webcam Server
📹 Camera ID: 2
✅ Camera 2 detected
🚀 Optimized UDP Server: 127.0.0.1:8889
```

---

## 🎮 Testing in Godot

1. **Open Godot** and load your project
2. **Run Ethnicity Detection scene**
   - Should see webcam feed (from Camera 1)
   - ML detection works automatically
3. **Exit to menu**
4. **Run Topeng Nusantara scene**
   - Should see webcam feed (from Camera 2)
   - Mask overlay works
5. **Switch between scenes**
   - ✅ No delays
   - ✅ No black screens
   - ✅ Works perfectly!

---

## 📊 Camera Configuration Examples

### Example 1: Desktop PC (No Internal Camera)

**Cameras:**
- Camera 0 = First USB webcam
- Camera 1 = Second USB webcam

**Configuration:**
- ML Server: Camera ID 0 (default)
- Topeng Server: Camera ID 1 (default)

**No changes needed!** ✅

---

### Example 2: Laptop (Internal + 2 USB)

**Cameras:**
- Camera 0 = Internal laptop camera
- Camera 1 = First USB webcam
- Camera 2 = Second USB webcam

**Configuration:**
- ML Server: Camera ID 1 (UPDATE config.json)
- Topeng Server: Camera ID 2 (UPDATE startup script)

**Changes needed!** See Step 2 above.

---

### Example 3: Laptop (Internal + 1 USB) ⚠️

**Cameras:**
- Camera 0 = Internal laptop camera
- Camera 1 = USB webcam

**Problem:** Only 1 USB camera!

**Solutions:**
1. **Recommended:** Connect second USB webcam
2. **Alternative:** Use internal (ID 0) + USB (ID 1)
   - May have compatibility issues
   - Internal cameras sometimes have different drivers

---

## 🔧 Troubleshooting

### Both servers show same camera

**Problem:** Both using Camera 0

**Solution:**
1. Check `config.json` → should be different IDs
2. Check startup script → should use `--camera_id` with different number
3. Restart both servers

---

### "Camera already in use"

**Problem:** Another app using the camera

**Solution:**
1. Close Zoom, Skype, Teams, etc.
2. Close Windows Camera app
3. Restart the servers

---

### "Camera not detected"

**Problem:** Camera not connected or driver issue

**Solution:**
1. Check USB connection
2. Try different USB port
3. Run `detect_cameras.py` again
4. Check Device Manager for camera drivers

---

## 📝 Important Notes

### Virtual Environments

**Each server has its own virtual environment!**

- ML Server: `Webcam Server/env/`
  - Uses numpy 2.x
  - scikit-learn for ML models

- Topeng Server: `Topeng Server/env/`
  - Uses numpy 1.x
  - MediaPipe for face detection

**That's why you need separate terminals!**

---

### Camera IDs

**Camera IDs are assigned by Windows:**

- Usually Camera 0 = First detected camera
- Internal cameras get ID 0 (if present)
- USB cameras get IDs 1, 2, 3, etc.

**To force USB cameras to be 0 and 1:**
- Disable internal camera in BIOS
- Or physically disconnect it

---

### Port Numbers

**Fixed ports - don't change:**

- ML Server: Port 8888 (Godot Ethnicity scene connects here)
- Topeng Server: Port 8889 (Godot Topeng scene connects here)

---

## 🎯 Summary

**What you need:**
- ✅ 2 USB webcams connected
- ✅ Both virtual environments set up
- ✅ Two terminal windows

**What to do:**
1. ✅ Run `detect_cameras.py` to identify cameras
2. ✅ Configure camera IDs if needed
3. ✅ Terminal 1: Start ML server
4. ✅ Terminal 2: Start Topeng server
5. ✅ Test in Godot

**Benefits:**
- ✅ Each server has dedicated webcam
- ✅ No resource conflicts
- ✅ Instant scene switching
- ✅ Stable and reliable!

---

## 📖 Additional Documentation

- **`START_SERVERS_GUIDE.md`** - Detailed startup guide
- **`DUAL_WEBCAM_SETUP.md`** - Complete dual webcam documentation
- **`CONTINUOUS_OPERATION.md`** - How continuous mode works
- **`README_SERVERS.md`** - Server architecture overview

---

**Status:** ✅ **READY FOR PRODUCTION**  
**Last Updated:** October 8, 2025

