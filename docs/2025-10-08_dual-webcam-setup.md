# Dual Webcam Setup Guide

**Date:** October 8, 2025  
**Solution:** Using 2 separate USB webcams for reliable dual server operation  
**Status:** ✅ **RECOMMENDED APPROACH**

---

## 🎯 Overview

This guide explains how to set up **two separate USB webcams** for the ISSAT Game dual server system, completely eliminating webcam resource conflicts.

### Why Dual Webcams?

**Previous Approach (Single Webcam):**
- ❌ Shared resource between two servers
- ❌ Complex camera release/reinit logic needed
- ❌ Timing-sensitive scene switching
- ❌ Black screen issues when switching
- ❌ Resource conflicts and instability

**New Approach (Dual Webcams):**
- ✅ **Each server gets dedicated hardware**
- ✅ **No resource sharing = No conflicts**
- ✅ **Instant, reliable scene switching**
- ✅ **Simpler, more stable code**
- ✅ **Professional multi-camera setup**

---

## 📋 Prerequisites

### Hardware Requirements

1. **2 USB Webcams** (any USB webcam will work)
   - Can be identical models or different models
   - Recommended: 720p or higher resolution
   - USB 2.0 or USB 3.0

2. **Available USB Ports**
   - 2 available USB ports on your computer
   - Can use USB hub if needed

### Software Requirements

- Windows 10/11
- Python 3.8 or higher
- OpenCV (already in requirements)
- Both virtual environments set up:
  - `Webcam Server/env`
  - `Topeng Server/env`

---

## 🔧 Setup Instructions

### Step 1: Connect Your Webcams

1. **Connect both USB webcams** to your computer
2. Windows should automatically detect them
3. They will be assigned camera IDs (usually 0 and 1)

### Step 2: Detect Available Cameras

Run the camera detection utility to see what cameras are available:

```bash
cd "Webcam Server"
env\Scripts\activate.bat
python detect_cameras.py
```

**Expected Output:**
```
🔍 Detecting available webcams...
============================================================
✅ Camera 0: 1280x720 @ 30FPS
✅ Camera 1: 1280x720 @ 30FPS
============================================================
📊 Found 2 working camera(s)

📋 DUAL SERVER SETUP RECOMMENDATIONS
============================================================
✅ 2 cameras detected - Ready for dual server setup!

🎯 Recommended configuration:
   • ML Server (Ethnicity Detection): Camera ID 0
   • Topeng Server (Mask Overlay): Camera ID 1
============================================================
```

### Step 3: Verify Configuration

Both servers are already configured for dual webcam setup:

**ML Server (Webcam Server/config.json):**
```json
{
  "camera": {
    "camera_id": 0,
    "notes": "Camera ID 0 = First USB webcam (dedicated to ML/Ethnicity server)"
  }
}
```

**Topeng Server (start script):**
```bash
python udp_webcam_server.py --port 8889 --camera_id 1
```

### Step 4: Start Both Servers

**Option A: Automatic (Recommended)**
```bash
start_dual_webcam_servers.bat
```

This will:
1. Detect available cameras
2. Start ML server (Port 8888, Camera 0)
3. Start Topeng server (Port 8889, Camera 1)
4. Open both in separate windows

**Option B: Manual**

Start each server separately:

```bash
# Terminal 1: ML Server
cd "Webcam Server"
env\Scripts\activate.bat
python ml_webcam_server.py

# Terminal 2: Topeng Server
cd "Topeng Server"
env\Scripts\activate.bat
python udp_webcam_server.py --port 8889 --camera_id 1
```

---

## 🎮 Using the Dual Webcam System

### In Godot

Once both servers are running:

1. **Ethnicity Detection Scene:**
   - Connects to port 8888 (ML server)
   - Uses Camera ID 0
   - Shows webcam feed with ML detection

2. **Topeng Nusantara Scene:**
   - Connects to port 8889 (Topeng server)
   - Uses Camera ID 1
   - Shows webcam feed with mask overlay

3. **Switching Between Scenes:**
   - ✅ Instant switching - no delays needed!
   - ✅ No black screens
   - ✅ No camera resource conflicts
   - ✅ Works in any order, any number of times

### Camera Assignment

| Camera ID | Server | Port | Scene |
|-----------|--------|------|-------|
| **0** | ML Ethnicity Detection | 8888 | Ethnicity Detection |
| **1** | Topeng Mask Overlay | 8889 | Topeng Nusantara |

---

## 🔍 Troubleshooting

### Issue: "Only 1 camera detected"

**Cause:** Second webcam not connected or not recognized

**Solutions:**
1. Check USB connection for second webcam
2. Try different USB port
3. Restart computer
4. Check Windows Device Manager for camera devices
5. Try unplugging and replugging the webcam

### Issue: "Camera 0 works but Camera 1 shows black screen"

**Cause:** Camera ID assignment different than expected

**Solutions:**
1. Run `detect_cameras.py` to see actual camera IDs
2. Update camera_id in server configuration
3. Try swapping the USB webcams

### Issue: "Both cameras detected but one server fails"

**Cause:** Virtual environment or dependency issues

**Solutions:**
1. Check that both virtual environments are set up:
   ```bash
   # ML Server
   cd "Webcam Server"
   python -m venv env
   env\Scripts\activate.bat
   pip install -r requirements.txt
   
   # Topeng Server
   cd "Topeng Server"
   python -m venv env
   env\Scripts\activate.bat
   pip install -r requirements_topeng.txt
   ```

2. Verify dependencies are installed:
   ```bash
   # In each server folder
   python -c "import cv2, numpy"
   ```

### Issue: "Servers start but Godot shows black screen"

**Cause:** Godot client not connecting to correct port

**Solutions:**
1. Check that servers are running (console should show active)
2. Verify Godot is connecting to correct ports:
   - Ethnicity scene → Port 8888
   - Topeng scene → Port 8889
3. Check firewall isn't blocking connections
4. Restart Godot scene

---

## 💡 Advanced Configuration

### Using Different Camera IDs

If your cameras are detected as different IDs (e.g., 0 and 2):

**ML Server (config.json):**
```json
{
  "camera": {
    "camera_id": 0
  }
}
```

**Topeng Server (command line):**
```bash
python udp_webcam_server.py --port 8889 --camera_id 2
```

### Swapping Camera Assignments

To swap which camera is used by which server:

**ML Server uses Camera 1:**
```json
{
  "camera": {
    "camera_id": 1
  }
}
```

**Topeng Server uses Camera 0:**
```bash
python udp_webcam_server.py --port 8889 --camera_id 0
```

### Using Different Webcam Models

You can use any combination of webcams:
- Both same model
- Different resolutions
- Different brands
- Built-in laptop camera + external USB webcam

The servers will automatically adjust to each camera's capabilities.

---

## 📊 System Architecture

### Before: Single Webcam (Problems)

```
┌─────────────────────────┐
│   Single USB Webcam     │
│      (Camera 0)         │
└────────────┬────────────┘
             │
    ┌────────┴────────┐
    │  SHARED ACCESS  │  ← Resource Conflict!
    │  (One at a time)│
    └────────┬────────┘
             │
    ┌────────┴────────┐
    │                 │
┌───▼────┐      ┌────▼────┐
│ML Server│      │Topeng  │
│Port 8888│      │Port 8889│
└─────────┘      └─────────┘
    ❌              ❌
```

### After: Dual Webcams (Solution)

```
┌─────────────┐     ┌─────────────┐
│  Webcam 0   │     │  Webcam 1   │
│  (First USB)│     │ (Second USB)│
└──────┬──────┘     └──────┬──────┘
       │                   │
       │ DEDICATED         │ DEDICATED
       │ ACCESS            │ ACCESS
       │                   │
┌──────▼──────┐     ┌──────▼──────┐
│  ML Server  │     │   Topeng    │
│  Port 8888  │     │  Port 8889  │
│  Camera 0   │     │  Camera 1   │
└─────────────┘     └─────────────┘
       ✅                  ✅
```

**Benefits:**
- ✅ No resource sharing
- ✅ No conflicts
- ✅ Both can run simultaneously
- ✅ Instant scene switching
- ✅ Simple, stable operation

---

## 📝 Configuration Files Reference

### ML Server Configuration

**File:** `Webcam Server/config.json`

```json
{
  "server": {
    "host": "127.0.0.1",
    "port": 8888,
    "frame_width": 640,
    "frame_height": 480,
    "target_fps": 15,
    "jpeg_quality": 40
  },
  "camera": {
    "camera_id": 0,
    "backend": "opencv",
    "auto_resize": true,
    "notes": "Camera ID 0 = First USB webcam (dedicated to ML/Ethnicity server)"
  }
}
```

### Topeng Server Configuration

**File:** `Topeng Server/udp_webcam_server.py` (command line arguments)

```bash
python udp_webcam_server.py --port 8889 --camera_id 1
```

Or use the startup script:
```bash
start_topeng_server.bat
```

---

## 🎯 Best Practices

### 1. Consistent Camera Assignment

Always use the same physical webcam for the same server:
- Keep Camera 0 (first USB) for ML server
- Keep Camera 1 (second USB) for Topeng server

This ensures consistent behavior across sessions.

### 2. Camera Positioning

Position your webcams appropriately:
- **Ethnicity Detection:** Position for face detection (eye level)
- **Topeng Mask:** Position for mask overlay (same as above)
- Can use the same physical position for both if needed

### 3. USB Port Selection

- Use USB 3.0 ports if available (faster data transfer)
- Avoid USB hubs if possible (use direct motherboard ports)
- If using hub, ensure it's powered USB hub

### 4. Server Startup Order

While order doesn't matter with dual webcams, recommended:
1. Start ML server first (Camera 0)
2. Wait 2-3 seconds
3. Start Topeng server (Camera 1)

This ensures clean initialization.

---

## ✅ Verification Checklist

Use this checklist to verify your dual webcam setup:

### Hardware
- [ ] Two USB webcams connected
- [ ] Both webcams detected by Windows
- [ ] Webcams have enough USB power

### Software
- [ ] Python installed
- [ ] Both virtual environments created
- [ ] All dependencies installed
- [ ] Camera detection script runs successfully

### Configuration
- [ ] ML server configured for Camera 0
- [ ] Topeng server configured for Camera 1
- [ ] Port 8888 free for ML server
- [ ] Port 8889 free for Topeng server

### Testing
- [ ] Both servers start without errors
- [ ] ML server shows "Camera 0" in logs
- [ ] Topeng server shows "Camera 1" in logs
- [ ] Both webcam feeds visible in Godot
- [ ] Scene switching works smoothly
- [ ] No black screens or errors

---

## 🚀 Quick Start Summary

1. **Connect 2 USB webcams**
2. **Run detection:** `python detect_cameras.py`
3. **Start servers:** `start_dual_webcam_servers.bat`
4. **Test in Godot:** Open both scenes and switch between them
5. **Enjoy!** No more webcam conflicts!

---

## 🎉 Benefits Summary

| Feature | Single Webcam | Dual Webcams |
|---------|--------------|--------------|
| **Resource Conflicts** | ❌ Frequent | ✅ None |
| **Scene Switching** | ❌ Complex | ✅ Simple |
| **Black Screens** | ❌ Common | ✅ Never |
| **Stability** | ❌ Unreliable | ✅ Rock Solid |
| **Setup Complexity** | ⚠️ High | ✅ Low |
| **Code Complexity** | ⚠️ High | ✅ Low |
| **Maintenance** | ⚠️ Difficult | ✅ Easy |
| **User Experience** | ❌ Poor | ✅ Excellent |

---

## 📞 Support

If you encounter issues:

1. **Check this guide** for troubleshooting section
2. **Run camera detection** to verify hardware
3. **Check server logs** for error messages
4. **Verify configuration** files are correct
5. **Test each camera** individually first

---

**Setup Status:** ✅ **COMPLETE AND READY**  
**Solution:** Dual USB webcams for dedicated server access  
**Result:** Stable, conflict-free dual server operation!

