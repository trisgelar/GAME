# System Architecture - Dual Webcam Server

**Date:** October 8, 2025  
**Architecture Type:** Independent Dual Server (UDP)

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     GODOT GAME (Walking Simulator)                  │
│                                                                     │
│  ┌──────────────────────────┐      ┌─────────────────────────────┐│
│  │  Ethnicity Detection     │      │   Topeng Nusantara          ││
│  │  Scene                   │      │   Scene                     ││
│  │                          │      │                             ││
│  │  - WebcamManagerUDP      │      │  - WebcamManagerUDP         ││
│  │  - Port: 8888           │      │  - Port: 8889 ⚠️           ││
│  │  - Sends:                │      │  - Sends:                   ││
│  │    DETECTION_REQUEST     │      │    SET_MASK <name>          ││
│  │  - Receives:             │      │    SET_CUSTOM_MASK <ids>    ││
│  │    Ethnicity prediction  │      │  - Receives:                ││
│  │                          │      │    Video + mask overlay     ││
│  └─────────┬────────────────┘      └────────────┬────────────────┘│
└────────────┼─────────────────────────────────────┼─────────────────┘
             │ UDP                                  │ UDP
             │ 127.0.0.1:8888                      │ 127.0.0.1:8889
             │                                      │
   ┌─────────▼──────────┐              ┌──────────▼─────────────┐
   │  Ethnicity ML      │              │  Topeng Mask           │
   │  Server            │              │  Server                │
   │  (Python)          │              │  (Python)              │
   │                    │              │                        │
   │  - Port 8888       │              │  - Port 8889           │
   │  - Camera: 640x480 │              │  - Camera: 480x360     │
   │  - FPS: 15         │              │  - FPS: 15             │
   │  ┌────────────────┐│              │  ┌────────────────────┐│
   │  │ ML Pipeline    ││              │  │ Filter Pipeline    ││
   │  │                ││              │  │                    ││
   │  │ 1. Face detect ││              │  │ 1. Face detect     ││
   │  │    (Haar)      ││              │  │    (MediaPipe)     ││
   │  │ 2. Extract     ││              │  │ 2. Pose estimate   ││
   │  │    features    ││              │  │    (yaw/pitch/roll)││
   │  │    (34,658)    ││              │  │ 3. Compose mask    ││
   │  │ 3. Predict     ││              │  │    (RGBA blend)    ││
   │  │    (RandomFor) ││              │  │ 4. 3D rotation     ││
   │  │ 4. Return      ││              │  │    (perspective)   ││
   │  │    ethnicity   ││              │  │ 5. Overlay         ││
   │  └────────────────┘│              │  └────────────────────┘│
   └────────┬───────────┘              └────────┬───────────────┘
            │                                    │
            └────────────────┬───────────────────┘
                             │
                        Camera (0)
                   (Shared via OS)
```

---

## Detailed Component Diagram

### Ethnicity ML Server (Port 8888)

```
┌─────────────────────────────────────────────────────────┐
│              ml_webcam_server.py                         │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ MLEthnicityDetector                              │  │
│  │                                                   │  │
│  │  ┌─────────────────────────────────────────┐    │  │
│  │  │ Feature Extractors:                     │    │  │
│  │  │ • extract_hog_features()    ~34,596     │    │  │
│  │  │ • extract_glcm_features()   20          │    │  │
│  │  │ • extract_lbp_features()    10          │    │  │
│  │  │ • extract_hsv_features()    32          │    │  │
│  │  │                       Total: 34,658 ✅  │    │  │
│  │  └─────────────────────────────────────────┘    │  │
│  │                                                   │  │
│  │  ┌─────────────────────────────────────────┐    │  │
│  │  │ ML Models (RandomForestClassifier):     │    │  │
│  │  │ • glcm_lbp_hog_hsv (best accuracy)     │    │  │
│  │  │ • glcm_lbp_hog                         │    │  │
│  │  │ • glcm_hog                             │    │  │
│  │  │ • hsv (fastest)                        │    │  │
│  │  └─────────────────────────────────────────┘    │  │
│  │                                                   │  │
│  │  predict_ethnicity(image, model) → (ethnicity, confidence)  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  UDP Commands:                                          │
│  • REGISTER / UNREGISTER                               │
│  • DETECTION_REQUEST → returns JSON with prediction    │
│  • MODEL_SELECT:<name> → switch ML model               │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Topeng Mask Server (Port 8889)

```
┌─────────────────────────────────────────────────────────┐
│           udp_webcam_server.py                          │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ UDPWebcamServer                                  │  │
│  │                                                   │  │
│  │  • Camera capture (480x360 @ 15 FPS)            │  │
│  │  • Command queue (thread-safe)                   │  │
│  │  • Client management (multi-client)              │  │
│  │  • Frame broadcasting                            │  │
│  └──────────────────────────────────────────────────┘  │
│                          │                               │
│                          ▼                               │
│  ┌──────────────────────────────────────────────────┐  │
│  │ FilterEngine (filter_ref.py)                     │  │
│  │                                                   │  │
│  │  ┌────────────────────────────────────────┐     │  │
│  │  │ MediaPipe Face Detection:              │     │  │
│  │  │ • Detect faces (up to 4)               │     │  │
│  │  │ • Extract keypoints (eyes, nose)       │     │  │
│  │  │ • Track faces across frames (greedy)   │     │  │
│  │  └────────────────────────────────────────┘     │  │
│  │                                                   │  │
│  │  ┌────────────────────────────────────────┐     │  │
│  │  │ Pose Estimation:                       │     │  │
│  │  │ • Yaw (left/right rotation)            │     │  │
│  │  │ • Pitch (up/down rotation)             │     │  │
│  │  │ • Roll (tilt rotation)                 │     │  │
│  │  └────────────────────────────────────────┘     │  │
│  │                                                   │  │
│  │  ┌────────────────────────────────────────┐     │  │
│  │  │ Mask Composition:                      │     │  │
│  │  │ • Load mask PNG (RGBA)                 │     │  │
│  │  │ • Or compose: base + mata + mulut      │     │  │
│  │  │ • Scale to face size                   │     │  │
│  │  │ • Apply 3D rotation (perspective warp) │     │  │
│  │  │ • Alpha blend onto frame               │     │  │
│  │  └────────────────────────────────────────┘     │  │
│  │                                                   │  │
│  │  ┌────────────────────────────────────────┐     │  │
│  │  │ Smoothing:                             │     │  │
│  │  │ • Motion-adaptive alpha blending       │     │  │
│  │  │ • Prevents jitter and jumping          │     │  │
│  │  │ • Smooth scale transitions             │     │  │
│  │  └────────────────────────────────────────┘     │  │
│  │                                                   │  │
│  │  process_frame(frame) → frame_with_mask          │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  UDP Commands:                                          │
│  • REGISTER / UNREGISTER                               │
│  • SET_MASK <filename> → load full mask                │
│  • SET_CUSTOM_MASK <base>,<mata>,<mulut> → compose     │
│  • LIST_MASKS → get available masks                    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Data Flow Diagrams

### Ethnicity Detection Flow

```
Player enters Ethnicity scene
    │
    ├─→ Godot: Load scene
    │       │
    │       └─→ Create WebcamManagerUDP
    │           │
    │           └─→ Send "REGISTER" to Port 8888
    │
    ├─→ Server: Receive REGISTER
    │       │
    │       ├─→ Add client to list
    │       ├─→ Resume camera (if paused)
    │       └─→ Send "REGISTERED" response
    │
    ├─→ Server: Start streaming frames
    │       │
    │       └─→ Send JPEG frames via UDP packets
    │
    ├─→ Godot: Receive frames
    │       │
    │       └─→ Display on webcam_feed TextureRect
    │
Player clicks "Deteksi" button
    │
    ├─→ Godot: Send "DETECTION_REQUEST"
    │
    ├─→ Server: Receive request
    │       │
    │       ├─→ Capture current frame
    │       ├─→ Detect face (Haar Cascade)
    │       ├─→ Resize face to 256x256
    │       ├─→ Extract GLCM features (20)
    │       ├─→ Extract LBP features (10)
    │       ├─→ Extract HOG features (~34,596)
    │       ├─→ Extract HSV features (32)
    │       ├─→ Combine: 34,658 features
    │       ├─→ Run RandomForestClassifier
    │       ├─→ Get prediction: class + confidence
    │       ├─→ Map to ethnicity name
    │       └─→ Send "DETECTION_RESULT:{json}"
    │
    └─→ Godot: Display prediction
            │
            └─→ Show: "Anda adalah: Jawa (85%)"
```

### Topeng Mask Flow

```
Player enters Topeng scene
    │
    ├─→ Godot: Load scene
    │       │
    │       └─→ Create WebcamManagerUDP
    │           │
    │           ├─→ Set server_port = 8889 ⚠️
    │           └─→ Send "REGISTER" to Port 8889
    │
    ├─→ Server: Receive REGISTER
    │       │
    │       └─→ Add client, start streaming
    │
Player selects mask "bali.png"
    │
    ├─→ Godot: Send "SET_MASK bali.png"
    │
    ├─→ Server: Receive command
    │       │
    │       └─→ Queue command for main thread
    │
    ├─→ Server (broadcast thread):
    │       │
    │       ├─→ Execute queued command
    │       ├─→ Load bali.png (RGBA)
    │       ├─→ Store in FilterEngine
    │       └─→ Send "MASK_SET:bali.png" response
    │
    ├─→ Server: Process frames
    │       │
    │       ├─→ Capture camera frame
    │       ├─→ FilterEngine.process_frame()
    │       │   │
    │       │   ├─→ MediaPipe face detection
    │       │   ├─→ For each face:
    │       │   │   ├─→ Extract keypoints (eyes, nose)
    │       │   │   ├─→ Calculate pose (yaw, pitch, roll)
    │       │   │   ├─→ Track face ID (greedy matching)
    │       │   │   ├─→ Smooth pose with alpha blending
    │       │   │   ├─→ Scale mask to face size
    │       │   │   ├─→ Rotate mask (3D perspective warp)
    │       │   │   └─→ Alpha blend mask onto frame
    │       │   │
    │       │   └─→ Return frame with all masks
    │       │
    │       ├─→ Encode as JPEG
    │       └─→ Send via UDP packets
    │
    └─→ Godot: Display frame
            │
            └─→ Show webcam + mask overlay with 3D tracking
```

---

## Component Interaction

### When Both Servers Are Running

```
┌─────────────────────┐
│   Your Webcam       │
│   (Device 0)        │
└──────────┬──────────┘
           │
           ├───────────────────────┐
           │                       │
    ┌──────▼──────┐        ┌──────▼──────┐
    │ Ethnicity   │        │  Topeng     │
    │ Server      │        │  Server     │
    │ Process 1   │        │  Process 2  │
    │ Port 8888   │        │  Port 8889  │
    └──────┬──────┘        └──────┬──────┘
           │                       │
           │ UDP                   │ UDP
           │                       │
    ┌──────▼──────────────────────▼──────┐
    │        Godot Game                   │
    │  (Only connects to ONE at a time)  │
    └────────────────────────────────────┘
```

**Key Point:** OS allows both servers to access camera, but Godot only connects to **one server at a time** based on which scene is active.

---

## Feature Comparison

### Ethnicity Detection (ML-based)

**Input:** Face image  
**Processing:**
1. Haar Cascade face detection
2. Feature extraction (HOG, GLCM, LBP, HSV)
3. Machine learning classification
4. Confidence calculation

**Output:** 
```json
{
  "ethnicity": "Jawa",
  "confidence": 0.853,
  "model": "glcm_lbp_hog_hsv",
  "mode": "ML"
}
```

**Features:**
- ✅ 34,658 dimensional feature vector
- ✅ 4 feature types combined
- ✅ RandomForestClassifier
- ✅ 3 ethnicity classes
- ✅ Confidence percentage

**Strengths:**
- Very accurate for trained ethnicities
- Quantifiable confidence
- Scientific approach

**Limitations:**
- Requires pre-trained model
- Fixed to 3 ethnicities
- Higher CPU usage for training

---

### Topeng Mask Overlay (Computer Vision)

**Input:** Face image  
**Processing:**
1. MediaPipe face detection
2. 3D pose estimation
3. Mask composition (if custom)
4. Dynamic scaling
5. 3D rotation (perspective warp)
6. Alpha blending

**Output:** Frame with mask overlay (RGBA)

**Features:**
- ✅ Real-time 3D pose tracking
- ✅ Multi-face support (up to 4)
- ✅ Modular mask composition
- ✅ Smooth motion tracking
- ✅ Perspective-correct rotation
- ✅ 19+ mask options

**Strengths:**
- Visually impressive
- Smooth real-time tracking
- Interactive and fun
- No training required

**Limitations:**
- Requires good lighting
- Performance depends on face count
- MediaPipe face detection only

---

## Technology Stack

### Ethnicity ML Server

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| **Face Detection** | OpenCV Haar Cascade | 4.12.0.88 | Detect face region |
| **Feature Extraction** | scikit-image (HOG, GLCM, LBP) | 0.25.2 | Extract texture patterns |
| **Color Features** | OpenCV (HSV histogram) | 4.12.0.88 | Extract color info |
| **ML Model** | scikit-learn RandomForest | 1.7.2 | Classification |
| **Networking** | Python socket (UDP) | Built-in | Client communication |
| **Video** | OpenCV VideoCapture | 4.12.0.88 | Camera access |

### Topeng Mask Server

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| **Face Detection** | MediaPipe Face Detection | 0.10.20 | Detect faces + keypoints |
| **Pose Estimation** | Keypoint geometry | Custom | Calculate yaw/pitch/roll |
| **Face Tracking** | Greedy nearest-neighbor | Custom | Maintain face identity |
| **Mask Overlay** | OpenCV + NumPy | 4.12.0.88 | RGBA alpha blending |
| **3D Rotation** | Perspective transform | Custom | Rotate mask to match pose |
| **Smoothing** | Motion-adaptive blending | Custom | Prevent jitter |
| **Networking** | Python socket (UDP) | Built-in | Client communication |

---

## Performance Optimization

### Ethnicity Server Optimizations

1. **Downscaled Detection:** Face detection on smaller image
2. **Camera Pause:** Stops capture when no clients (saves 85% CPU)
3. **Efficient Feature Extraction:** Optimized numpy operations
4. **Frame Rate Control:** 15 FPS (not 30) for balance
5. **JPEG Compression:** Quality 40 (smaller packets)

### Topeng Server Optimizations

1. **Detection Scale:** 0.75x downscale for face detection (faster)
2. **Face Tracking:** Reduces re-detection overhead
3. **Motion-Adaptive Smoothing:** Less processing when still
4. **Rotation Fast-Path:** Skips warp if angle < 1°
5. **Stale Track Cleanup:** Removes old tracks after 1 second
6. **Thread-Safe Commands:** Queue prevents MediaPipe threading issues

---

## Security Considerations

### Current (Local Only)

- ✅ Both servers bind to `127.0.0.1` (localhost only)
- ✅ No authentication needed (local network)
- ✅ UDP packets not encrypted (not exposed to internet)
- ✅ Camera access only on user's machine

### For Future Network Deployment

If you want to allow remote access:

1. **Add Authentication:**
   ```python
   # Require token/password
   if message.startswith("AUTH:"):
       token = message.split(":")[1]
       if verify_token(token):
           # Allow connection
   ```

2. **Use Encrypted Connection:**
   - Switch to DTLS (UDP with TLS)
   - Or use SSH tunneling

3. **Rate Limiting:**
   ```python
   # Limit requests per client
   if client_request_count[addr] > MAX_REQUESTS_PER_MINUTE:
       # Reject or throttle
   ```

4. **Bind to Network Interface:**
   ```python
   # Allow connections from network
   server = UDPWebcamServer(host='0.0.0.0', port=8889)
   ```

---

## Scalability

### Current Architecture Supports

- ✅ Multiple clients per server
- ✅ Multiple faces per frame (Topeng: up to 4)
- ✅ Model switching (Ethnicity: 7 models)
- ✅ Mask switching (Topeng: 19+ masks)

### Future Expansion Possibilities

1. **Add More Models:**
   ```python
   model_files = {
       'glcm_lbp_hog_hsv': 'GLCM_LBP_HOG_HSV_model.pkl',
       'emotion_detection': 'Emotion_model.pkl',  # New!
       'age_detection': 'Age_model.pkl',          # New!
   }
   ```

2. **Add More Masks:**
   - Just add PNG files to `Topeng/mask/` folder
   - Server auto-detects them
   - No code changes needed

3. **Add More Servers:**
   ```bash
   # Emotion Detection Server (Port 8890)
   # Age Detection Server (Port 8891)
   # etc.
   ```

4. **Load Balancing:**
   ```python
   # Distribute clients across multiple server instances
   # For high-load scenarios
   ```

---

## Deployment Options

### Option 1: Local Development (Current)

```
Developer Machine:
  ├─ Ethnicity Server (Port 8888)
  ├─ Topeng Server (Port 8889)
  └─ Godot Game
```

**Use case:** Development, testing, single-player

### Option 2: Local Network Deployment

```
Server Machine:
  ├─ Ethnicity Server (192.168.1.100:8888)
  └─ Topeng Server (192.168.1.100:8889)

Client Machines:
  └─ Godot Game → Connect to 192.168.1.100
```

**Use case:** Lab environment, multiple students

### Option 3: Cloud Deployment (Advanced)

```
Cloud VM:
  ├─ Ethnicity Server (public_ip:8888)
  ├─ Topeng Server (public_ip:8889)
  └─ Authentication layer

Client (Anywhere):
  └─ Godot Game → Connect to public_ip (with auth)
```

**Use case:** Remote learning, distributed deployment

---

## Maintenance

### Regular Tasks

**Weekly:**
- Check server logs for errors
- Monitor CPU/memory usage
- Verify camera is working

**Monthly:**
- Update dependencies if needed
- Review and archive old logs
- Test all features still working

**As Needed:**
- Add new masks
- Update ML models with new training data
- Optimize performance based on usage patterns

### Backup Strategy

**Critical Files to Backup:**
```
Webcam Server/
├── ml_webcam_server.py
├── config.json
├── models/ (ML models - very important!)
├── Topeng/
│   ├── udp_webcam_server.py
│   ├── filter_ref.py
│   └── mask/ (mask assets)
```

**Less Critical:**
- Logs (can be regenerated)
- Benchmark scripts
- Cache files

---

## Summary

### Architecture Principles

1. **Separation of Concerns:** Each server does one thing well
2. **Independent Operation:** Servers don't depend on each other
3. **Shared Resources:** Camera shared via OS, not code
4. **Clean Communication:** UDP protocol, simple commands
5. **Fail-Safe Design:** One server can fail without affecting the other

### Benefits Achieved

✅ **Aman (Safe):** No conflicts or interference  
✅ **Terpisah (Separated):** Clear boundaries  
✅ **Mudah (Easy):** Simple to understand and debug  
✅ **Fleksibel (Flexible):** Run either or both  
✅ **Efisien (Efficient):** Optimized for performance  
✅ **Scalable:** Easy to add more features

---

**This is production-ready architecture!** 🏗️✨

**Next:** Install dependencies → Start servers → Test → Enjoy! 🎮

---

**Status:** ✅ Architecture Complete & Documented  
**Last Updated:** October 8, 2025

