# Multi-Scene Webcam Architecture Guide

**Date:** October 7, 2025  
**Question:** Can one webcam be used for both Ethnicity Detection and Topeng Nusantara scenes?  
**Answer:** YES! Your current UDP implementation already supports this perfectly.

---

## Current Architecture ✅

### Single Server, Multiple Clients

```
┌─────────────────────────────────────────────────────────────────┐
│                  ML Webcam Server (Python)                       │
│                    Port 8888 (UDP)                               │
│  - Continuously streams video frames                            │
│  - Handles DETECTION_REQUEST for ML predictions                 │
│  - Supports multiple simultaneous clients                       │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │ UDP
                ┌─────────────┴─────────────┐
                │                           │
        ┌───────▼──────────┐       ┌───────▼──────────┐
        │ Ethnicity Scene  │       │   Topeng Scene   │
        │ (Godot Client)   │       │  (Godot Client)  │
        │                  │       │                  │
        │ - Receives frames│       │ - Receives frames│
        │ - Sends DETECTION│       │ - Overlays mask  │
        │   _REQUEST       │       │ - No ML needed   │
        └──────────────────┘       └──────────────────┘
```

### How It Works Now

1. **Server Side (Python)**:
   - Runs continuously on port 8888
   - Streams frames to all registered clients
   - Listens for `DETECTION_REQUEST` messages
   - Returns ethnicity predictions when requested

2. **Client Side (Godot)**:
   - Both scenes use `WebcamManagerUDP.gd`
   - Connect/disconnect on scene load/unload
   - Can request ML detection independently

---

## Why Your Current Implementation is Perfect

### ✅ Advantages of UDP Architecture

| Feature | UDP (Current) | REST/Flask |
|---------|--------------|------------|
| **Latency** | Very low (~5-10ms) | Higher (~50-100ms) |
| **Streaming** | Native, continuous | Requires polling or WebSocket |
| **Overhead** | Minimal (no HTTP) | HTTP headers on every request |
| **Video Quality** | Excellent for real-time | Better for on-demand |
| **Complexity** | Simple point-to-point | Requires web framework |
| **Multiple Clients** | Native support | Requires session management |

### ✅ What You Already Have

1. **Frame Broadcasting**: Server automatically sends frames to all connected clients
2. **Client Independence**: Each scene connects/disconnects independently
3. **On-Demand ML**: Ethnicity detection only runs when requested
4. **Resource Cleanup**: Clients properly unregister on scene exit

---

## The Only Issues to Fix

### Issue 1: Server Continues Streaming After Scene Exit ⚠️

**Problem**: Server keeps capturing and sending frames even when no clients are connected.

**Why It Happens**: 
```python
# In ml_webcam_server.py - _broadcast_frames()
while self.running:
    if len(self.clients) == 0:
        time.sleep(0.1)  # ⚠️ Just sleeps, but camera keeps running!
        continue
```

**Solution**: Pause camera when no clients are connected:

```python
def _broadcast_frames(self):
    last_frame_time = 0
    camera_active = True
    
    while self.running:
        # Check if we have clients
        if len(self.clients) == 0:
            if camera_active:
                print("⏸️ No clients connected - pausing camera")
                camera_active = False
            time.sleep(0.5)  # Check less frequently when idle
            continue
        
        # Resume camera if needed
        if not camera_active:
            print("▶️ Client connected - resuming camera")
            camera_active = True
        
        # ... rest of frame capture and broadcast logic ...
```

### Issue 2: No Model Selection for Different Scenes 🔄

**Current**: Both scenes would use the same ML model (`glcm_lbp_hog_hsv`)

**What You Need**:
- Ethnicity Detection → Uses ethnicity ML model
- Topeng Nusantara → Could use face landmark/pose detection (future)

**Solution**: Add model context to requests

---

## Recommended Improvements

### 1. Add Scene-Aware Detection Requests

Update `WebcamManagerUDP.gd` to support different detection types:

```gdscript
# WebcamManagerUDP.gd
enum DetectionType {
    ETHNICITY,    # For Ethnicity Detection scene
    FACE_POSE,    # For Topeng Nusantara (future)
    NONE          # Just video feed
}

var detection_type: DetectionType = DetectionType.NONE

func request_detection(type: DetectionType = DetectionType.ETHNICITY):
    """Request ML detection with specific model"""
    if not is_connected:
        return
    
    var request_data = {
        "type": DetectionType.keys()[type],
        "timestamp": Time.get_ticks_msec()
    }
    
    var message = "DETECTION_REQUEST:" + JSON.stringify(request_data)
    udp_client.put_packet(message.to_utf8_buffer())
    print("📤 Detection request sent: ", type)
```

### 2. Update Server to Handle Different Models

```python
# In ml_webcam_server.py
def handle_detection_request(self, addr, request_data=None):
    """Handle detection request with model selection"""
    print(f"🔍 Detection request from {addr}")
    
    # Parse request type
    detection_type = "ethnicity"  # default
    if request_data:
        try:
            data = json.loads(request_data)
            detection_type = data.get("type", "ethnicity").lower()
        except:
            pass
    
    # Select appropriate model
    if detection_type == "ethnicity":
        model_name = self.current_model  # glcm_lbp_hog_hsv
        result = self._detect_ethnicity(frame)
    elif detection_type == "face_pose":
        # Future: face landmark detection
        result = self._detect_face_landmarks(frame)
    else:
        result = None
    
    # Send result back...
```

### 3. Improve Client Connection Management

```gdscript
# EthnicityDetectionController.gd
func _exit_tree():
    """Properly cleanup when scene exits"""
    print("🧹 Cleaning up Ethnicity Detection scene...")
    cleanup_resources()

func cleanup_resources():
    """Clean up webcam and disconnect"""
    if webcam_manager:
        if webcam_manager.has_method("disconnect_from_server"):
            webcam_manager.disconnect_from_server()
        webcam_manager.queue_free()
        webcam_manager = null
    print("✅ Resources cleaned up")
```

Update `WebcamManagerUDP.gd`:

```gdscript
func disconnect_from_server():
    """Properly unregister from server"""
    if not is_connected:
        return
    
    print("🔌 Disconnecting from server...")
    var message = "UNREGISTER".to_utf8_buffer()
    udp_client.put_packet(message)
    
    is_connected = false
    connection_changed.emit(false)
    udp_client.close()
    print("✅ Disconnected from webcam server")
```

---

## Do You Need Flask/REST API? 🤔

### NO, if you want:
- ✅ Real-time video streaming (< 100ms latency)
- ✅ Continuous webcam feed
- ✅ Simple client-server communication
- ✅ Low overhead
- ✅ Local network only

### YES, if you want:
- 📱 Web browser access
- 🌐 Remote access over internet
- 🔐 Authentication/authorization
- 📊 Complex request/response formats
- 💾 Persistent sessions/state
- 🔄 RESTful CRUD operations

### Hybrid Approach (Optional)

You could combine both:

```python
# Start both servers
if __name__ == "__main__":
    # UDP server for real-time video (port 8888)
    udp_thread = threading.Thread(target=start_udp_server)
    udp_thread.start()
    
    # Flask API for commands/queries (port 5000)
    # - GET /api/status
    # - POST /api/model/select
    # - GET /api/detection/latest
    flask_app.run(port=5000)
```

But for your use case, **UDP alone is sufficient**.

---

## Implementation Plan

### Phase 1: Fix Current Issues ✅ COMPLETED

<function_calls>
<invoke name="todo_write">
<parameter name="merge">false
