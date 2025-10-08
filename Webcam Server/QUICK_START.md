# 🚀 Quick Start - Dual Webcam Server System

**Last Updated:** October 8, 2025  
**Time to Setup:** ~5 minutes

---

## Step 1: Install Dependencies (One Time Only)

Open **Command Prompt** or **PowerShell**:

```bash
# Navigate to Webcam Server
cd "D:\ISSAT Game\Game\Webcam Server"

# Install ethnicity ML dependencies
pip install -r requirements.txt

# Install Topeng mask dependencies
cd Topeng
pip install -r requirements_topeng.txt
```

**Expected output:**
```
Successfully installed opencv-python-4.12.0.88 numpy-2.2.6 scikit-image-0.25.2 scikit-learn-1.7.2 scipy-1.16.2 mediapipe-0.10.20
```

---

## Step 2: Start Both Servers

**Option A: Easy Way** (Recommended)

1. Navigate to: `D:\ISSAT Game\Game\Webcam Server\`
2. Double-click: **`start_both_servers.bat`**
3. Two command windows will open automatically

**Option B: Manual Way**

```bash
# Terminal 1: Ethnicity Server
cd "D:\ISSAT Game\Game\Webcam Server"
python ml_webcam_server.py

# Terminal 2: Topeng Server (in a NEW terminal)
cd "D:\ISSAT Game\Game\Webcam Server\Topeng"
python udp_webcam_server.py
```

### Expected Server Output

**Window 1 - Ethnicity ML Server:**
```
=== ML-Enhanced UDP Webcam Server ===
✅ Loaded configuration
✅ Loaded glcm_lbp_hog_hsv model
✅ Camera ready: 640x480 @ 15FPS
🚀 ML-Enhanced UDP Server: 127.0.0.1:8888
⏸️  No clients connected - camera paused
```

**Window 2 - Topeng Mask Server:**
```
=== Topeng Mask UDP Webcam Server ===
🎭 Port: 8889
ℹ️ Auto-detected masks folder: ...\mask
🔧 FilterEngine initialized
✅ Camera ready: 480x360 @ 15FPS
🚀 Optimized UDP Server: 127.0.0.1:8889
```

---

## Step 3: Test in Godot

### Test Ethnicity Detection

1. **Run your game** → Main Menu
2. **Navigate to:** Ethnicity Detection scene
3. **Check Ethnicity server window:**
   ```
   ✅ Client: ('127.0.0.1', 58692) (Total: 1)
   ▶️  Client(s) connected (1) - camera resumed
   ```
4. **In game:** Click "Deteksi" button
5. **Check server window:**
   ```
   🔍 Extracted 34658 features for model 'glcm_lbp_hog_hsv'
   🧠 ML DETECTION Result: Jawa (Confidence: 85.3%)
   ```
6. **Exit to Main Menu**
7. **Check server:**
   ```
   ❌ Client left: ('127.0.0.1', 58692)
   ⏸️  No clients connected - camera paused
   ```

✅ **Success!** Ethnicity detection is working.

### Test Topeng Mask Overlay

1. **From Main Menu:** Navigate to Topeng Nusantara scene
2. **Select a mask** (e.g., Bali, Betawi, Hudoq)
3. **Check Topeng server window:**
   ```
   ✅ Client: ('127.0.0.1', 58693) (Total: 1)
   🎭 Mask set to: bali.png
   ```
4. **In game:** You should see:
   - Live webcam feed
   - Traditional mask overlay on your face
   - Mask follows your head movements (yaw, pitch, roll)
   - FPS counter showing ~15 FPS
5. **Exit to Main Menu**
6. **Check server:**
   ```
   ❌ Client left: ('127.0.0.1', 58693)
   ```

✅ **Success!** Topeng mask overlay is working.

---

## Step 4: Test Scene Switching

1. **Go to Ethnicity Detection** → Should see "camera resumed" on Port 8888
2. **Exit to menu** → Should see "camera paused" on Port 8888
3. **Go to Topeng Nusantara** → Should see connection on Port 8889
4. **Exit to menu** → Topeng server shows client left
5. **Switch back and forth** → Clean connections/disconnections

✅ **Success!** Multi-scene webcam sharing is working.

---

## 🎯 What Each Server Does

### Ethnicity ML Server (Port 8888)

**Purpose:** Analyze your face to predict ethnicity

**What it does:**
1. Detects your face using Haar Cascade
2. Extracts 34,658 features (HOG, GLCM, LBP, HSV)
3. Runs RandomForestClassifier ML model
4. Returns prediction: Jawa, Sasak, or Papua

**When to use:** Ethnicity Detection scene

### Topeng Mask Server (Port 8889)

**Purpose:** Apply traditional Indonesian masks to your face

**What it does:**
1. Detects your face using MediaPipe (more accurate!)
2. Tracks 3D pose (yaw, pitch, roll)
3. Overlays mask PNG with proper perspective
4. Supports custom mask composition
5. Smooth motion tracking

**When to use:** Topeng Nusantara scene

---

## 🐛 Troubleshooting

### "MediaPipe not found"

```bash
pip install mediapipe==0.10.20
```

### "Camera not found"

```bash
# Make sure no other app is using the camera
# Close Zoom, Skype, etc.
# Then restart servers
```

### "Port already in use"

```bash
# Check what's using the port
netstat -ano | findstr :8889

# Kill it or restart your computer
```

### "Feature dimension mismatch" (Ethnicity server)

This should be fixed now. If you still see it:
```
❌ X has 2072 features, but expects 34658
```

Make sure you're using the updated `ml_webcam_server.py` (October 8, 2025 version).

### Godot not connecting

1. Check both servers are running (look for "Server ready")
2. Verify port in Godot code:
   - Ethnicity: port 8888 (default)
   - Topeng: port 8889 (set in TopengWebcamController.gd line 96)
3. Check Windows Firewall (allow Python)

---

## 📖 More Help?

- **Complete guide:** `README_DUAL_SERVER.md`
- **Topeng details:** `Topeng/README_TOPENG.md`
- **ML changes explained:** `docs/2025-10-08_ml-server-changes-detailed-explanation.md`
- **Integration guide:** `docs/2025-10-08_topeng-nusantara-integration-guide.md`

---

## ✅ Success Indicators

You'll know everything is working when:

✅ Both server windows open and show "Camera ready"  
✅ Servers show "camera paused" when no Godot clients  
✅ Servers show "camera resumed" when you enter scenes  
✅ Ethnicity scene returns predictions (Jawa/Sasak/Papua)  
✅ Topeng scene shows masks on your face  
✅ Masks follow your head movements smoothly  
✅ No errors when switching between scenes  
✅ Servers properly pause/resume camera

---

**Ready to start?**

```bash
pip install mediapipe==0.10.20
start_both_servers.bat
```

Then test in Godot! 🎮✨

---

**Status:** ✅ Everything integrated and ready!  
**Your action:** Install mediapipe → Test → Enjoy! 🎭

