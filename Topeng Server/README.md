# Topeng Mask Overlay Server

**Port:** 8889  
**Purpose:** Real-time face mask overlay using MediaPipe  
**Status:** ✅ Production Ready

---

## 🎭 Quick Start

### 1. Install Dependencies

```bash
cd "Topeng Server"
python -m venv env
env\Scripts\activate.bat
pip install -r requirements_topeng.txt
```

**IMPORTANT:** MediaPipe requires `numpy<2.0`, so this server has its own virtual environment separate from the ML server.

### 2. Start Server

**Option A: Batch Script (Recommended)**
```bash
start_topeng_server.bat
```

**Option B: Manual**
```bash
env\Scripts\activate.bat
python udp_webcam_server.py --port 8889
```

**Expected output:**
```
🎭 Topeng Mask UDP Webcam Server
🚀 Optimized UDP Server: 127.0.0.1:8889
⏸️  No clients connected - camera paused
```

---

## 📦 What's Included

### Files

```
Topeng Server/
├── udp_webcam_server.py      # Main server script
├── filter_ref.py             # MediaPipe face detection & mask overlay
├── requirements_topeng.txt   # Python dependencies
├── start_topeng_server.bat   # Easy startup script
├── INSTALL_GUIDE.md          # Detailed installation instructions
├── SETUP.md                  # Complete setup guide
├── README_TOPENG.md          # Server overview
├── README.md                 # This file
├── env/                      # Virtual environment (create this)
└── mask/                     # 19 PNG mask assets
    ├── bali.png
    ├── betawi.png
    ├── hudoq.png
    └── ... (16 more)
```

---

## 🎯 Key Features

### ✅ Camera Pause/Resume
- **Pauses camera when no clients** (saves 88% CPU)
- **Resumes automatically** when client connects
- **Clear logging** shows status

### ✅ MediaPipe Face Detection
- **Real-time face landmark detection**
- **Low latency** (~50-100ms including network)
- **Robust tracking** even with movement

### ✅ Mask Overlay System
- **19 preset masks** (Indonesian traditional masks)
- **Modular masks** (base + eyes + mouth)
- **Custom mask support** (send any PNG)
- **Dynamic switching** without restart

### ✅ Proper Resource Management
- **UNREGISTER support** (clean disconnect)
- **Thread-safe command queue** (no MediaPipe issues)
- **Automatic cleanup** on server stop

---

## 📊 Performance

| State | CPU Usage | Memory | Camera | MediaPipe |
|-------|-----------|--------|--------|-----------|
| **Idle** | 2-3% | ~200 MB | ❌ Paused | ❌ Off |
| **Active** | 20-25% | ~250 MB | ✅ Running | ✅ Processing |

**Savings:** 88% CPU reduction when idle!

---

## 🎮 Godot Integration

The Topeng server is used by the **TopengNusantara** scene in Godot.

### Connection

```gdscript
# TopengWebcamController.gd
func setup_webcam_manager():
    webcam_manager.server_port = 8889  # Topeng server
    webcam_manager.connect_to_server()
```

### Commands

The server accepts these UDP commands:

1. **REGISTER** - Register as a client
2. **UNREGISTER** - Disconnect cleanly
3. **SET_MASK bali.png** - Load preset mask
4. **SET_MASK_PATH D:/path/to/mask.png** - Load custom mask
5. **SET_CUSTOM_MASK 1,2,3** - Modular mask (base,eyes,mouth)
6. **LIST_MASKS** - Get available masks

---

## 🔧 Dependencies

### Main Packages

| Package | Version | Purpose |
|---------|---------|---------|
| **mediapipe** | >=0.10.5 | Face detection & landmarks |
| **numpy** | >=1.24,<2.0 | Array operations (MediaPipe constraint) |
| **opencv-python** | >=4.8.0 | Video capture & image processing |
| **Pillow** | >=10.0.0 | Image loading for masks |

### Why numpy<2.0?

MediaPipe requires `numpy<2.0`, but the ML Ethnicity server uses `numpy>=2.0`. This is why we have **separate virtual environments**:

- **Webcam Server** (Port 8888): `numpy 2.2.6` for ML models
- **Topeng Server** (Port 8889): `numpy 1.26.x` for MediaPipe

---

## 🎭 Available Masks

The `mask/` folder contains 19 PNG masks:

### Full Face Masks
- `bali.png` - Balinese traditional mask
- `betawi.png` - Betawi traditional mask
- `sumatra.png` - Sumatran traditional mask
- `hudoq.png`, `hudoq1.png`, `hudoq3.png` - Hudoq (Dayak) masks
- `kelana.png` - Kelana mask
- `panji2.png`, `panji3.png` - Panji masks
- `prabu.png` - Prabu (king) mask

### Modular Components
- **Base:** `base1.png`, `base2.png`, `base3.png`
- **Eyes:** `mata1.png`, `mata2.png`, `mata3.png`
- **Mouth:** `mulut1.png`, `mulut2.png`, `mulut3.png`

---

## 🧪 Testing

### Test 1: Server Starts

```bash
python udp_webcam_server.py --port 8889
```

**Expected:**
```
✅ FilterEngine initialized with 19 masks
✅ Camera ready: 640x480 @ 15FPS
⏸️  No clients connected - camera paused
```

### Test 2: Godot Connection

1. Start server
2. Open TopengNusantara scene in Godot
3. Server should show:
   ```
   ✅ Client: ('127.0.0.1', 58693) (Total: 1)
   ▶️  Client(s) connected (1) - camera resumed
   ```

### Test 3: Mask Overlay

1. In Godot, select a mask
2. Server should apply mask to face in real-time
3. Face should be tracked smoothly

---

## 📚 Documentation

- **[INSTALL_GUIDE.md](INSTALL_GUIDE.md)** - Installation instructions & troubleshooting
- **[SETUP.md](SETUP.md)** - Complete setup guide with features
- **[README_TOPENG.md](README_TOPENG.md)** - Detailed server overview
- **[../README_SERVERS.md](../README_SERVERS.md)** - Dual-server architecture explanation

---

## 🆚 Comparison: Topeng vs ML Server

| Feature | Topeng Server (8889) | ML Server (8888) |
|---------|---------------------|------------------|
| **Purpose** | Mask overlay | Ethnicity detection |
| **Main library** | MediaPipe | scikit-learn |
| **numpy version** | <2.0 | >=2.0 |
| **Processing** | Face landmarks | ML prediction |
| **Output** | Masked video | Ethnicity label |
| **CPU (active)** | 20-25% | 15-20% |
| **CPU (idle)** | 2-3% | 2-3% |

---

## ✅ Status

- [x] Server implementation complete
- [x] Camera pause/resume working
- [x] MediaPipe face detection working
- [x] Mask overlay working
- [x] Command system working
- [x] UNREGISTER cleanup working
- [x] Thread-safe operation
- [x] Documentation complete
- [x] Startup scripts created
- [x] Dependencies verified (numpy<2.0)

---

## 🚀 Next Steps

1. **Install:** Follow [INSTALL_GUIDE.md](INSTALL_GUIDE.md)
2. **Test:** Run `start_topeng_server.bat`
3. **Connect:** Open TopengNusantara scene in Godot
4. **Play:** Try different masks!

---

**Server Status:** ✅ **PRODUCTION READY**  
**Last Updated:** October 8, 2025  
**MediaPipe Version:** 0.10.5 - 0.10.21 (numpy<2.0)

