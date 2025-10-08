# 👋 START HERE - Dual Webcam Server System

**Welcome!** This is your complete webcam server system for the ISSAT Cultural Game.

---

## 🎯 What You Have

You now have **TWO powerful webcam servers** integrated into one codebase:

| Server | What It Does | Port |
|--------|--------------|------|
| **Ethnicity Detection** 🧠 | Analyzes your face and predicts ethnicity using ML (Jawa/Sasak/Papua) | 8888 |
| **Topeng Mask Overlay** 🎭 | Applies traditional Indonesian masks to your face with 3D tracking | 8889 |

Both are **completely integrated, documented, and ready to use!** ✅

---

## ⚡ Quick Start (3 Steps)

### 1️⃣ Install Dependencies (One Time)

```bash
cd "D:\ISSAT Game\Game\Webcam Server"
pip install -r requirements.txt

cd Topeng
pip install -r requirements_topeng.txt
```

### 2️⃣ Start Servers

**Double-click:** `start_both_servers.bat`

Two windows will open - keep them running while you play!

### 3️⃣ Test in Godot

- **Ethnicity Detection scene** → Click "Deteksi" → Get ethnicity prediction
- **Topeng Nusantara scene** → Select mask → See mask on your face

**Done!** 🎉

---

## 📚 Documentation Structure

**Choose what you need:**

### For Quick Setup
→ **QUICK_START.md** - 5-minute setup guide (you are here!)

### For Complete Understanding
→ **README_DUAL_SERVER.md** - Everything about both servers

### For Ethnicity ML
→ **README_ML.md** - ML models, features, training details  
→ **docs/2025-10-08_ml-server-changes-detailed-explanation.md** - What changed and why

### For Topeng Masks
→ **Topeng/README_TOPENG.md** - Mask server documentation  
→ **docs/2025-10-08_topeng-nusantara-integration-guide.md** - Integration details

### For Technical Details
→ **docs/** folder - All technical documentation

---

## 🎮 Usage in Your Game

### Scene 1: Ethnicity Detection

**What the player does:**
1. Enters Ethnicity Detection scene
2. Sees themselves on webcam
3. Clicks "Deteksi" button
4. Gets ethnicity prediction: "Anda adalah: Jawa (Confidence: 85%)"

**What happens behind the scenes:**
- Godot connects to Port 8888
- Sends `DETECTION_REQUEST`
- Server extracts 34,658 features
- ML model predicts ethnicity
- Server sends result back
- Player sees prediction

### Scene 2: Topeng Nusantara

**What the player does:**
1. Enters Topeng Nusantara scene
2. Selects a traditional mask (Bali, Betawi, Hudoq, etc.)
3. Sees mask appear on their face
4. Moves head → Mask follows smoothly with 3D rotation

**What happens behind the scenes:**
- Godot connects to Port 8889
- Sends `SET_MASK bali.png`
- Server detects face with MediaPipe
- Server overlays mask with 3D pose tracking
- Player sees themselves with traditional mask

---

## 🔧 File Structure

```
Webcam Server/
│
├── 🎯 start_both_servers.bat          # ← START HERE (double-click!)
│
├── Ethnicity ML Server (Port 8888)
│   ├── ml_webcam_server.py
│   ├── config.json
│   ├── requirements.txt
│   └── models/ (ML models)
│
├── Topeng Mask Server (Port 8889)
│   └── Topeng/
│       ├── udp_webcam_server.py
│       ├── filter_ref.py
│       ├── requirements_topeng.txt
│       └── mask/ (19 PNG masks)
│
└── Documentation
    ├── README_START_HERE.md (this file)
    ├── QUICK_START.md
    ├── README_DUAL_SERVER.md
    ├── INTEGRATION_COMPLETE.md
    ├── INTEGRATION_STATUS.md
    ├── Topeng/README_TOPENG.md
    └── docs/ (technical docs)
```

---

## 💡 Key Concepts

### Why Two Servers?

**Because they do completely different things:**

| Aspect | Ethnicity Detection | Topeng Mask |
|--------|-------------------|-------------|
| **Technology** | Machine Learning (scikit-learn) | Computer Vision (MediaPipe) |
| **Purpose** | Classify ethnicity | Overlay mask |
| **Features** | 34,658 ML features | Face landmarks + pose |
| **Output** | Text prediction | Modified video |
| **Complexity** | High (ML model) | High (3D tracking) |

**Running them separately makes everything:**
- ✅ Easier to debug
- ✅ Easier to maintain
- ✅ More reliable
- ✅ Better performance

### How They Share the Webcam

Modern Windows allows multiple programs to use the webcam simultaneously:

```
Your Webcam
    ↓
    ├─→ Ethnicity Server (Port 8888) → When Ethnicity scene is active
    └─→ Topeng Server (Port 8889) → When Topeng scene is active
```

In practice, only **one scene is active at a time**, so there's no conflict!

---

## ✅ Verification Checklist

After starting the servers, verify:

- [ ] **Window 1 shows:** "🚀 ML-Enhanced UDP Server: 127.0.0.1:8888"
- [ ] **Window 2 shows:** "🚀 Optimized UDP Server: 127.0.0.1:8889"
- [ ] **Both show:** "⏸️ No clients connected - camera paused"
- [ ] **No errors** in either window

In Godot:
- [ ] Ethnicity scene connects to Port 8888 ✅
- [ ] Topeng scene connects to Port 8889 ✅
- [ ] No conflicts when switching between scenes ✅

---

## 🎉 What You Can Do Now

### Try These Features:

**In Ethnicity Detection:**
- ✅ Get real-time ethnicity prediction
- ✅ See confidence percentage
- ✅ ML model with 34,658 features working
- ✅ Three ethnicities: Jawa, Sasak, Papua

**In Topeng Nusantara:**
- ✅ Choose from 7 preset traditional Indonesian masks
- ✅ Create custom masks (3×3×3 = 27 combinations!)
- ✅ See masks follow your head in 3D
- ✅ Smooth pose tracking
- ✅ Multi-face support (try with a friend!)

---

## 🆘 Need Help?

### Quick Fixes

**Servers won't start?**
→ Make sure you installed all dependencies (Step 1)

**Camera not working?**
→ Close other apps using webcam (Zoom, Skype, etc.)

**Godot not connecting?**
→ Check server windows are open and show "Server ready"

### Documentation

- **Quick questions:** See **QUICK_START.md**
- **Setup issues:** See **README_DUAL_SERVER.md**
- **Technical details:** See **docs/** folder

---

## 🚀 Ready to Go!

```bash
# 1. Install (one time)
pip install mediapipe==0.10.20

# 2. Start servers
start_both_servers.bat

# 3. Play in Godot!
```

**Have fun with your cultural game!** 🎭✨

---

**Status:** ✅ System Complete & Production Ready  
**Next:** Install dependencies → Start servers → Test & enjoy!

