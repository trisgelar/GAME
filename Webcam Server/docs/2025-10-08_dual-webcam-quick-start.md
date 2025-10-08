# Dual Webcam Quick Start

**Solution:** Use 2 separate USB webcams to eliminate resource conflicts

---

## ✅ Quick Setup (3 Steps)

### 1️⃣ Connect Hardware
- Plug in **2 USB webcams** to your computer
- Windows will auto-detect them as Camera 0 and Camera 1

### 2️⃣ Detect Cameras
```bash
cd "Webcam Server"
env\Scripts\activate.bat
python detect_cameras.py
```

Expected: "✅ 2 cameras detected - Ready for dual server setup!"

### 3️⃣ Start Servers
```bash
start_dual_webcam_servers.bat
```

Two windows will open:
- **Window 1:** ML Server (Port 8888, Camera 0)
- **Window 2:** Topeng Server (Port 8889, Camera 1)

---

## 🎮 Using in Godot

- **Ethnicity Detection Scene** → Port 8888 (Camera 0)
- **Topeng Nusantara Scene** → Port 8889 (Camera 1)
- Switch between scenes freely - no conflicts!

---

## 🔧 Camera Assignment

| Camera ID | Server | Port | Used By |
|-----------|--------|------|---------|
| **0** | ML Ethnicity Detection | 8888 | Ethnicity scene |
| **1** | Topeng Mask Overlay | 8889 | Topeng scene |

---

## ⚠️ Troubleshooting

**"Only 1 camera detected"**
- Check both webcams are plugged in
- Try different USB ports
- Run `detect_cameras.py` to verify

**"Server fails to start"**
- Check virtual environment: `env\Scripts\activate.bat`
- Install dependencies: `pip install -r requirements.txt`

**"Black screen in Godot"**
- Verify both servers are running
- Check correct port in Godot scene
- Restart the Godot scene

---

## 💡 Why Dual Webcams?

| Single Webcam | Dual Webcams |
|--------------|--------------|
| ❌ Resource conflicts | ✅ No conflicts |
| ❌ Black screens | ✅ Stable feeds |
| ❌ Complex switching | ✅ Instant switching |
| ❌ Unreliable | ✅ Rock solid |

---

## 📖 Full Documentation

See [DUAL_WEBCAM_SETUP.md](../DUAL_WEBCAM_SETUP.md) for complete guide.

---

**Status:** ✅ Ready to use with 2 USB webcams!

