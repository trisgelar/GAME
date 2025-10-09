# ISSAT Game - Root Documentation

**Last Updated:** October 8, 2025

This folder contains project-wide documentation for the ISSAT Game dual webcam server system.

---

## 📚 Documentation Index

### Dual Webcam Setup (October 8, 2025)

**Main Guides:**
- **[2025-10-08_dual-webcam-setup.md](2025-10-08_dual-webcam-setup.md)** - Complete dual webcam setup guide
- **[2025-10-08_start-servers-guide.md](2025-10-08_start-servers-guide.md)** - Step-by-step server startup instructions
- **[2025-10-08_dual-servers-separate-terminals.md](2025-10-08_dual-servers-separate-terminals.md)** - Running servers in separate terminals

**Testing:**
- **[2025-10-08_test-webcam-switching.md](2025-10-08_test-webcam-switching.md)** - Webcam switching test documentation

### Joystick & Input Setup (October 8, 2025)

**Controller Configuration:**
- **[2025-10-08_joystick-setup.md](2025-10-08_joystick-setup.md)** - Xbox-like controller setup guide
- **[2025-10-08_input-settings-guide.md](2025-10-08_input-settings-guide.md)** - Resource-based input settings (no code editing!)
- **[2025-10-08_joystick-all-scenes-update.md](2025-10-08_joystick-all-scenes-update.md)** - All scenes now support joystick!
- **[JOYSTICK_QUICK_REFERENCE.md](JOYSTICK_QUICK_REFERENCE.md)** - Quick reference card (pin to monitor!)

### UI & Theme Setup (October 9, 2025)

**Menu Button Configuration:**
- **[2025-10-09_menu-button-theme-guide.md](2025-10-09_menu-button-theme-guide.md)** - Configurable button backgrounds using .tres resources

---

## 🎯 Quick Links

### For Users

**Getting Started:**
1. Read: [2025-10-08_dual-webcam-setup.md](2025-10-08_dual-webcam-setup.md)
2. Follow: [2025-10-08_start-servers-guide.md](2025-10-08_start-servers-guide.md)
3. Test: [2025-10-08_test-webcam-switching.md](2025-10-08_test-webcam-switching.md)

**Quick Start:**
```bash
# Step 1: Detect cameras
cd "Webcam Server"
env\Scripts\activate.bat
python detect_cameras.py

# Step 2: Start ML Server (Terminal 1)
cd "Webcam Server"
start_ml_ethnicity_server.bat

# Step 3: Start Topeng Server (Terminal 2)
cd "Topeng Server"
start_topeng_mask_server.bat
```

### For Developers

**Architecture:**
- See: `../README_SERVERS.md` (Root folder)
- ML Server: `../Webcam Server/docs/`
- Topeng Server: `../Topeng Server/docs/`

---

## 📂 Related Documentation

### Server-Specific Documentation

**ML Ethnicity Detection Server:**
- Location: `../Webcam Server/docs/`
- Main README: `../Webcam Server/README.md`

**Topeng Mask Overlay Server:**
- Location: `../Topeng Server/docs/`
- Main README: `../Topeng Server/README.md`

### Godot Project Documentation

**Walking Simulator:**
- Location: `../Walking Simulator/docs/`

---

## 🔄 Documentation Organization

**Date Format:** `YYYY-MM-DD_title-with-hyphens.md`

**Categories:**
- **Setup Guides** - Installation and configuration
- **Architecture** - System design and structure  
- **Testing** - Test procedures and results
- **Troubleshooting** - Problem solving guides
- **Integration** - Component integration guides

---

## 📝 Recent Changes

### October 9, 2025 - UI Theme System
- ✅ Added configurable button theme system
- ✅ Button backgrounds with hover/pressed/disabled states
- ✅ Easy customization via .tres resource files
- ✅ Applied to all MainMenu buttons
- ✅ Created comprehensive theme configuration guide

### October 8, 2025 - Dual Webcam & Input

#### Dual Webcam Implementation
- ✅ Implemented dual USB webcam support
- ✅ Separate camera for each server (Camera 0 & 1)
- ✅ Eliminated resource conflicts
- ✅ Continuous webcam operation (no pause/resume)
- ✅ Instant scene switching in Godot

#### Documentation Updates
- ✅ Organized all .md files into docs folders
- ✅ Standardized date format (2025-10-08_xxx.md)
- ✅ Created comprehensive guides
- ✅ Added camera detection documentation

#### Joystick & Input Updates
- ✅ Added Xbox-like controller support
- ✅ Right analog stick for camera control
- ✅ Resource-based input settings (no hardcoded values!)
- ✅ Easy-to-edit .tres file for "pelupa" users
- ✅ All settings adjustable via Godot Inspector

---

## 🎯 Key Features

### Dual Webcam System
- **Camera 0** → ML Ethnicity Detection (Port 8888)
- **Camera 1** → Topeng Mask Overlay (Port 8889)
- **No conflicts** between servers
- **Instant switching** between scenes
- **Continuous operation** (no pause/resume bugs)

### Separate Virtual Environments
- ML Server: numpy 2.x + scikit-learn
- Topeng Server: numpy 1.x + MediaPipe
- Separate terminals required

---

## 📖 How to Navigate

1. **Start here:** `2025-10-08_dual-webcam-setup.md`
2. **For troubleshooting:** Check each server's docs folder
3. **For development:** See architecture docs in server folders

---

**Project Status:** ✅ Production Ready  
**Main README:** `../README_SERVERS.md`

