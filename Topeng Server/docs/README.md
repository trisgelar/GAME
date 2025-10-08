# Topeng Mask Overlay Server - Documentation

**Last Updated:** October 8, 2025

This folder contains documentation for the Topeng Mask Overlay Server.

---

## 📚 Documentation Index

### October 8, 2025

**Fixes and Improvements:**
- **[2025-10-08_mask-overlay-fix.md](2025-10-08_mask-overlay-fix.md)** - Mask overlay system fixes and MediaPipe integration

---

## 🎭 Server Overview

**Purpose:** Face mask overlay with MediaPipe face detection  
**Port:** 8889  
**Camera:** ID 1 (Second USB webcam)  
**Dependencies:** numpy<2.0, MediaPipe, OpenCV

---

## 🚀 Quick Start

### Setup

```bash
cd "Topeng Server"
python -m venv env
env\Scripts\activate.bat
pip install -r requirements_topeng.txt
```

### Start Server

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

---

## 📝 Main Documentation Files

**In Parent Folder:**
- **`../README.md`** - Main Topeng server overview
- **`../README_TOPENG.md`** - Detailed server documentation
- **`../SETUP.md`** - Installation guide
- **`../INSTALL_GUIDE.md`** - Installation instructions

---

## 🔧 Configuration

### Camera Configuration

**Default:** Camera ID 1 (Second USB webcam)

**To change:**
```bash
python udp_webcam_server.py --port 8889 --camera_id 2
```

### Mask Assets

**Location:** `../mask/`

**Available masks:**
- bali.png
- betawi.png
- hudoq.png
- kelana.png
- panji.png
- prabu.png
- sumatra.png
- And modular parts (base, mata, mulut)

---

## 🎯 Key Features

### MediaPipe Face Detection
- Real-time face landmark detection
- Mask overlay alignment
- Multiple mask support
- Custom mask composition

### UDP Video Streaming
- Port 8889
- Optimized 480x360 @ 15FPS
- JPEG compression (Q40)
- Efficient packet fragmentation

---

## 📖 Related Documentation

### Root Documentation
- `../../docs/` - Project-wide dual webcam docs
- `../../README_SERVERS.md` - Dual server architecture

### ML Server Documentation
- `../../Webcam Server/docs/` - ML server documentation

---

## 🔄 Recent Updates

### October 8, 2025
- ✅ Added dual webcam support
- ✅ Updated to use dedicated Camera ID 1
- ✅ Created separate startup script
- ✅ Organized documentation

---

**Server Status:** ✅ Production Ready  
**Port:** 8889  
**Camera:** ID 1 (USB)

