# Topeng Server - Installation Guide

**Last Updated:** October 8, 2025  
**MediaPipe Version:** 0.10.5+ (tested up to 0.10.21)

---

## ✅ Quick Install

### Step 1: Create Virtual Environment

```bash
cd "Topeng Server"
python -m venv env
```

### Step 2: Activate Environment

```bash
env\Scripts\activate.bat
```

You should see `(env)` prefix in your prompt:
```
(env) D:\ISSAT Game\Game\Topeng Server>
```

### Step 3: Install Dependencies

```bash
pip install -r requirements_topeng.txt
```

**Expected packages:**
```
Successfully installed:
  - opencv-python (4.12.0.88 or similar)
  - numpy (1.24.x - 1.26.x, NOT 2.x)
  - mediapipe (0.10.5 - 0.10.21)
  - Pillow (10.0.0+)
```

**Installation time:** ~2-3 minutes

---

## 📦 Dependency Details

### MediaPipe Versions

According to [PyPI MediaPipe](https://pypi.org/project/mediapipe/#history), available versions are:

| Version | Release Date | Status | Notes |
|---------|--------------|--------|-------|
| **0.10.21** | Feb 6, 2025 | ✅ Latest | Recommended |
| **0.10.20** | Jan 30, 2025 | ✅ Stable | - |
| **0.10.19** | Jan 27, 2025 | ✅ Stable | - |
| **0.10.18** | Jan 16, 2025 | ✅ Stable | - |
| **...** | ... | ... | ... |
| **0.10.5** | Jun 2023 | ✅ Minimum | Oldest supported |

**Note:** There is **no 0.10.0 version** on PyPI. The earliest available is **0.10.5**.

---

### NumPy Compatibility

**CRITICAL:** MediaPipe requires `numpy<2.0`

| numpy Version | MediaPipe Compatible? | ML Server Compatible? |
|--------------|---------------------|---------------------|
| **1.24.x** | ✅ YES | ❌ NO (too old) |
| **1.26.x** | ✅ YES | ❌ NO |
| **2.0.x** | ❌ NO | ✅ YES |
| **2.2.x** | ❌ NO | ✅ YES |

**This is why we need separate virtual environments!**

---

## 🧪 Verify Installation

### Test 1: Check Installed Packages

```bash
pip list | findstr /i "numpy opencv mediapipe"
```

**Expected output:**
```
mediapipe          0.10.21 (or 0.10.5 - 0.10.20)
numpy              1.26.4 (or 1.24.x - 1.26.x)
opencv-python      4.12.0.88 (or similar)
```

✅ **Verify numpy is < 2.0**

---

### Test 2: Import Test

```bash
python -c "import cv2, mediapipe, numpy; print(f'OpenCV: {cv2.__version__}'); print(f'MediaPipe: {mediapipe.__version__}'); print(f'NumPy: {numpy.__version__}')"
```

**Expected output:**
```
OpenCV: 4.12.0
MediaPipe: 0.10.21
NumPy: 1.26.4
```

✅ **If no errors, installation is successful!**

---

### Test 3: MediaPipe Face Detection

```bash
python -c "from mediapipe.python.solutions import face_mesh; print('✅ MediaPipe face detection ready!')"
```

**Expected output:**
```
✅ MediaPipe face detection ready!
```

---

### Test 4: Start Server

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

**Press Ctrl+C to stop**

✅ **Server is working!**

---

## 🔧 Troubleshooting

### Error: "Cannot install mediapipe... numpy conflict"

**Full error message:**
```
ERROR: Cannot install mediapipe because these package versions have conflicting dependencies.
The conflict is caused by:
    mediapipe 0.10.20 depends on numpy<2
```

**Cause:** Wrong numpy version installed

**Fix:**
```bash
# Uninstall numpy 2.x
pip uninstall numpy -y

# Install compatible numpy
pip install "numpy>=1.24.0,<2.0.0"

# Install mediapipe
pip install "mediapipe>=0.10.5"
```

---

### Error: "No module named 'mediapipe'"

**Cause:** Virtual environment not activated

**Fix:**
```bash
cd "Topeng Server"
env\Scripts\activate.bat
python -c "import mediapipe; print('OK')"
```

---

### Error: "mediapipe 0.10.0 not found"

**Cause:** Version 0.10.0 doesn't exist on PyPI

**Fix:** Use `>=0.10.5` instead (already updated in requirements_topeng.txt)

---

### Warning: "Deprecated numpy API"

**Example:**
```
numpy/_core/__init__.py:44: UserWarning: A NumPy version >=1.24.0 and <2.3.0 is required for this version of SciPy
```

**Cause:** Normal warning, safe to ignore

**Fix:** No action needed (numpy 1.26.x works fine)

---

## 📋 Complete Requirements File

```txt
# Requirements for Topeng Mask Overlay Server
# Install with: pip install -r requirements_topeng.txt
#
# NOTE: MediaPipe requires numpy<2, so we use numpy 1.26.x
# This is different from the Webcam Server (ML) which uses numpy 2.x

opencv-python>=4.8.0
numpy>=1.24.0,<2.0.0
mediapipe>=0.10.5
Pillow>=10.0.0

# Latest mediapipe version: 0.10.21 (Feb 2025)
# Minimum tested version: 0.10.5 (Jun 2023)
```

**Key points:**
- ✅ `mediapipe>=0.10.5` (not 0.10.0, doesn't exist)
- ✅ `numpy>=1.24.0,<2.0.0` (critical constraint)
- ✅ `opencv-python>=4.8.0` (flexible)
- ✅ `Pillow>=10.0.0` (flexible)

---

## 🎯 What Gets Installed

When you run `pip install -r requirements_topeng.txt`, pip will install:

### Primary Dependencies
1. **opencv-python** (4.12.0.88 or latest)
2. **numpy** (1.26.4 or similar, <2.0)
3. **mediapipe** (0.10.21 or latest >=0.10.5)
4. **Pillow** (10.0.0 or latest)

### Secondary Dependencies (auto-installed)
- `absl-py` (for MediaPipe)
- `attrs` (for MediaPipe)
- `flatbuffers` (for MediaPipe)
- `jax` (for MediaPipe)
- `matplotlib` (for MediaPipe)
- `protobuf` (for MediaPipe)
- `sounddevice` (for MediaPipe)
- And more...

**Total download size:** ~200-300 MB  
**Installation time:** ~2-3 minutes

---

## ✅ Final Checklist

Installation is complete when:

- [x] Virtual environment created (`Topeng Server/env`)
- [x] Environment activated (`(env)` in prompt)
- [x] All packages installed (no errors)
- [x] `pip list` shows numpy<2.0
- [x] `pip list` shows mediapipe>=0.10.5
- [x] Import test passes
- [x] Server starts without errors
- [x] Shows "camera paused" when idle
- [x] CPU usage ~2-3% when idle

---

## 🚀 Next Steps

After successful installation:

1. **Test the server:**
   ```bash
   start_topeng_server.bat
   ```

2. **Start both servers:**
   ```bash
   cd ..
   start_both_servers.bat
   ```

3. **Connect from Godot:**
   - Open TopengNusantara scene
   - Server should show "camera resumed"
   - You should see webcam feed with mask overlay

---

## 📚 References

- [MediaPipe on PyPI](https://pypi.org/project/mediapipe/#history) - Official package page
- [MediaPipe Documentation](https://developers.google.com/mediapipe) - Official docs
- [NumPy Compatibility](https://numpy.org/doc/stable/release.html) - Version info

---

**Installation Guide Status:** ✅ **COMPLETE**  
**Last Verified:** October 8, 2025  
**MediaPipe Version:** 0.10.5 - 0.10.21

