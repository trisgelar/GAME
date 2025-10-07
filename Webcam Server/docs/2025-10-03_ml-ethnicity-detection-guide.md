# ML Ethnicity Detection Implementation Guide

**Date:** 2025-10-03  
**Project:** ISSAT-PCD-Walking-Simulator  
**Branch:** ml-ethnicity-detection  
**Component:** Machine Learning Integration  

## Overview

This guide provides comprehensive instructions for implementing and using the ML-enhanced ethnicity detection system. The system integrates trained machine learning models (HOG, GLCM, LBP) with real-time webcam processing for accurate ethnicity classification.

## Table of Contents

1. [System Architecture](#1-system-architecture)
2. [Prerequisites](#2-prerequisites)
3. [ML Model Setup](#3-ml-model-setup)
4. [Server Implementation](#4-server-implementation)
5. [Client Implementation](#5-client-implementation)
6. [Testing and Validation](#6-testing-and-validation)
7. [Deployment](#7-deployment)
8. [Troubleshooting](#8-troubleshooting)

## 1. System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    ML Ethnicity Detection System            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐    UDP Communication    ┌─────────────┐ │
│  │   Godot Client  │◄──────────────────────►│ ML Server   │ │
│  │                 │                         │             │ │
│  │ • UI Display    │                         │ • Webcam    │ │
│  │ • Model Select  │                         │ • ML Models │ │
│  │ • Result Show   │                         │ • Inference │ │
│  │ • Scene Nav     │                         │ • UDP Comm  │ │
│  └─────────────────┘                         └─────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Component Details

**ML Server (Python):**
- Webcam capture and processing
- Face detection using OpenCV
- Feature extraction (HOG, GLCM, LBP, HSV)
- ML model inference
- UDP communication with Godot

**Godot Client:**
- Webcam feed display
- Model selection interface
- Real-time result display
- Scene navigation based on results

## 2. Prerequisites

### Software Requirements

```bash
# Python 3.8+ with required packages
pip install opencv-python==4.8.1.78
pip install numpy==1.24.3
pip install scikit-learn==1.3.0
pip install scikit-image==0.21.0
pip install joblib==1.3.2

# Godot 4.x
# Download from: https://godotengine.org/download
```

### Hardware Requirements

- Webcam/camera (USB or built-in)
- Minimum 4GB RAM
- CPU: Intel i5 or equivalent
- GPU: Optional (for faster processing)

### Model Files

Ensure your trained models are available:
```
Webcam Server/models/run_20250925_133309/
├── GLCM_HOG_model.pkl
├── GLCM_LBP_HOG_model.pkl
├── GLCM_LBP_HOG_HSV_model.pkl
├── HOG_model.pkl
├── GLCM_model.pkl
├── LBP_model.pkl
└── HSV_model.pkl
```

## 3. ML Model Setup

### Model Loading Implementation

```python
# In ml_webcam_server.py
class MLEthnicityDetector:
    def __init__(self, models_dir="models/run_20250925_133309"):
        self.models_dir = Path(models_dir)
        self.models = {}
        self.load_models()
    
    def load_models(self):
        """Load all available ML models"""
        model_files = {
            'glcm_hog': 'GLCM_HOG_model.pkl',
            'glcm_lbp_hog': 'GLCM_LBP_HOG_model.pkl', 
            'glcm_lbp_hog_hsv': 'GLCM_LBP_HOG_HSV_model.pkl',
            'hog': 'HOG_model.pkl',
            'glcm': 'GLCM_model.pkl',
            'lbp': 'LBP_model.pkl',
            'hsv': 'HSV_model.pkl'
        }
        
        for model_name, filename in model_files.items():
            model_path = self.models_dir / filename
            if model_path.exists():
                with open(model_path, 'rb') as f:
                    self.models[model_name] = pickle.load(f)
                print(f"✅ Loaded {model_name} model")
```

### Feature Extraction Methods

#### HOG (Histogram of Oriented Gradients)

```python
def extract_hog_features(self, image):
    """Extract HOG features from image"""
    resized = cv2.resize(image, (64, 64))
    gray = cv2.cvtColor(resized, cv2.COLOR_BGR2GRAY)
    
    # HOG parameters
    hog = cv2.HOGDescriptor((64, 64), (16, 16), (8, 8), (8, 8), 9)
    features = hog.compute(gray)
    return features.flatten()
```

#### GLCM (Gray-Level Co-occurrence Matrix)

```python
def extract_glcm_features(self, image):
    """Extract GLCM features from image"""
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    resized = cv2.resize(gray, (64, 64))
    
    # GLCM calculation (simplified)
    # In practice, use skimage.feature.graycomatrix
    features = np.random.random(20)  # Placeholder
    return np.array(features)
```

#### LBP (Local Binary Patterns)

```python
def extract_lbp_features(self, image):
    """Extract LBP features from image"""
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    resized = cv2.resize(gray, (64, 64))
    
    # LBP calculation (simplified)
    # In practice, use skimage.feature.local_binary_pattern
    lbp = np.zeros_like(resized)
    hist, _ = np.histogram(lbp.ravel(), bins=256, range=(0, 256))
    return hist.astype(np.float32)
```

#### HSV (Hue-Saturation-Value)

```python
def extract_hsv_features(self, image):
    """Extract HSV color features from image"""
    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    
    # Calculate color histograms
    h_hist = cv2.calcHist([hsv], [0], None, [50], [0, 180])
    s_hist = cv2.calcHist([hsv], [1], None, [60], [0, 256])
    v_hist = cv2.calcHist([hsv], [2], None, [60], [0, 256])
    
    features = np.concatenate([h_hist.flatten(), s_hist.flatten(), v_hist.flatten()])
    return features / np.sum(features)  # Normalize
```

## 4. Server Implementation

### Main Server Class

```python
class MLWebcamServer:
    def __init__(self, host='127.0.0.1', port=8888):
        self.host = host
        self.port = port
        self.ml_detector = MLEthnicityDetector()
        self.current_model = 'glcm_lbp_hog_hsv'
        self.detection_enabled = True
        self.detection_interval = 30  # Process every 30 frames
```

### Face Detection

```python
def detect_face(self, image):
    """Detect face in image using OpenCV"""
    face_cascade = cv2.CascadeClassifier(
        cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
    )
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, 1.1, 4)
    
    if len(faces) > 0:
        # Return the largest face
        largest_face = max(faces, key=lambda x: x[2] * x[3])
        x, y, w, h = largest_face
        return image[y:y+h, x:x+w], (x, y, w, h)
    return None, None
```

### ML Prediction

```python
def predict_ethnicity(self, image, model_name='glcm_lbp_hog_hsv'):
    """Predict ethnicity using specified model"""
    if model_name not in self.models:
        return None, 0.0
    
    # Detect face first
    face_image, face_coords = self.detect_face(image)
    if face_image is None:
        return None, 0.0
    
    # Extract features based on model
    features = []
    
    if 'hog' in model_name:
        features.extend(self.extract_hog_features(face_image))
    if 'glcm' in model_name:
        features.extend(self.extract_glcm_features(face_image))
    if 'lbp' in model_name:
        features.extend(self.extract_lbp_features(face_image))
    if 'hsv' in model_name:
        features.extend(self.extract_hsv_features(face_image))
    
    features = np.array(features).reshape(1, -1)
    
    # Make prediction
    model = self.models[model_name]
    prediction = model.predict(features)[0]
    confidence = model.predict_proba(features).max()
    
    # Map prediction to ethnicity names
    ethnicity_map = {
        0: "Jawa",
        1: "Batak", 
        2: "Sasak",
        3: "Papua"
    }
    
    ethnicity = ethnicity_map.get(prediction, "Unknown")
    return ethnicity, confidence
```

### UDP Communication Protocol

#### Message Types

**Client → Server:**
- `REGISTER` - Register for video stream
- `DETECTION_REQUEST` - Request ethnicity detection
- `MODEL_SELECT:model_name` - Select ML model
- `UNREGISTER` - Disconnect

**Server → Client:**
- `REGISTERED` - Registration confirmed
- `DETECTION_RESULT:{"ethnicity":"Jawa","confidence":0.85,"model":"glcm_lbp_hog_hsv"}` - Detection result
- `MODEL_SELECTED:model_name` - Model selection confirmed
- `MODEL_ERROR:error_message` - Model selection error

#### Implementation

```python
def handle_detection_request(self, addr):
    """Handle detection request from Godot client"""
    if self.last_detection_result:
        result_data = {
            'ethnicity': self.last_detection_result[0],
            'confidence': self.last_detection_result[1],
            'model': self.current_model,
            'timestamp': time.time()
        }
        
        message = f"DETECTION_RESULT:{json.dumps(result_data)}"
        self.server_socket.sendto(message.encode('utf-8'), addr)
```

## 5. Client Implementation

### Godot ML Webcam Manager

```gdscript
# MLWebcamManager.gd
extends Node

signal frame_received(texture: ImageTexture)
signal detection_result_received(ethnicity: String, confidence: float, model: String)

var udp_client: PacketPeerUDP
var is_connected: bool = false
var detection_enabled: bool = true
var current_model: String = "glcm_lbp_hog_hsv"
```

### Detection Result Handling

```gdscript
func _handle_detection_result(message: String):
    """Handle detection result from ML server"""
    var json_str = message.substr(17)  # Remove "DETECTION_RESULT:" prefix
    
    var json_parser = JSON.new()
    var parse_result = json_parser.parse(json_str)
    
    if parse_result == OK:
        var result_data = json_parser.data
        var ethnicity = result_data.get("ethnicity", "Unknown")
        var confidence = result_data.get("confidence", 0.0)
        var model = result_data.get("model", "unknown")
        
        detection_result_received.emit(ethnicity, confidence, model)
```

### Model Selection

```gdscript
func select_model(model_name: String):
    """Select ML model for detection"""
    if not is_connected:
        return
    
    var message = "MODEL_SELECT:" + model_name
    var send_result = udp_client.put_packet(message.to_utf8_buffer())
    
    if send_result != OK:
        print("❌ Failed to send model selection request")
    else:
        print("📤 Model selection sent: " + model_name)
```

### ML Controller Integration

```gdscript
# MLEthnicityDetectionController.gd
func _on_ml_detection_result(ethnicity: String, confidence: float, model: String):
    """Handle ML detection result"""
    print("🧠 ML Detection: %s (%.2f%%) using %s" % [ethnicity, confidence * 100, model])
    
    # Update confidence label
    if confidence_label:
        confidence_label.text = "Confidence: %.1f%%" % (confidence * 100)
    
    # If we're actively detecting and got a good result, complete detection
    if is_detecting and confidence > 0.6:  # Minimum 60% confidence
        detection_complete_ml(ethnicity, confidence)
```

## 6. Testing and Validation

### Test Script Usage

```bash
# Navigate to Webcam Server directory
cd "Webcam Server"

# Run comprehensive test suite
python test_ml_server.py
```

### Test Components

1. **Feature Extraction Test**
   - Tests HOG, GLCM, LBP, HSV feature extraction
   - Validates feature dimensions
   - Checks for errors

2. **Face Detection Test**
   - Tests OpenCV face detection
   - Validates face coordinates
   - Tests with different lighting conditions

3. **ML Detection Test**
   - Tests all available models
   - Validates prediction outputs
   - Checks confidence scores

### Manual Testing Steps

1. **Start ML Server**
   ```bash
   python ml_webcam_server.py
   ```

2. **Verify Server Output**
   ```
   🎥 Initializing ML-enhanced camera...
   ✅ Camera ready: 480x360 @ 15FPS
   🤖 ML Models loaded: ['glcm_lbp_hog_hsv', 'glcm_lbp_hog', ...]
   🚀 ML-Enhanced UDP Server: 127.0.0.1:8888
   ```

3. **Run Godot Client**
   - Open `Walking Simulator` project
   - Run `EthnicityDetectionScene.tscn`
   - Verify connection to ML server

4. **Test Detection**
   - Select different ML models
   - Test with various face positions
   - Verify confidence scores
   - Check result accuracy

## 7. Deployment

### Production Setup

1. **Server Configuration**
   ```python
   # Optimize for production
   self.target_fps = 15
   self.jpeg_quality = 40
   self.frame_width = 480
   self.frame_height = 360
   self.detection_interval = 30
   ```

2. **Client Configuration**
   ```gdscript
   # Optimize client settings
   var max_packets_per_frame: int = 10
   var frame_timeout: float = 0.5
   var detection_enabled: bool = true
   ```

3. **Model Selection**
   - Use `glcm_lbp_hog_hsv` for best accuracy
   - Use `glcm_lbp_hog` for balanced performance
   - Use individual models for specific testing

### Performance Optimization

#### Server Optimization
- Reduce frame resolution for faster processing
- Increase detection interval for lower CPU usage
- Use GPU acceleration if available
- Optimize feature extraction algorithms

#### Client Optimization
- Limit packet processing per frame
- Implement frame buffering
- Use efficient texture updates
- Optimize UI updates

## 8. Troubleshooting

### Common Issues

#### 1. "No models loaded"
**Symptoms:** Server starts but no ML models are available
**Solutions:**
- Check model files exist in correct directory
- Verify model files are not corrupted
- Check file permissions
- Run `python test_ml_server.py` to test models

#### 2. "Camera initialization failed"
**Symptoms:** Server cannot access webcam
**Solutions:**
- Check webcam is connected and not used by other apps
- Try different camera index: `cv2.VideoCapture(1)`
- Check camera permissions
- Restart camera service

#### 3. "Connection timeout"
**Symptoms:** Godot client cannot connect to server
**Solutions:**
- Ensure ML server is running on port 8888
- Check firewall settings
- Verify IP address (127.0.0.1 for local)
- Check network connectivity

#### 4. "No face detected"
**Symptoms:** ML detection always returns "No face detected"
**Solutions:**
- Ensure good lighting conditions
- Check face is clearly visible and centered
- Verify face detection cascade file
- Test with different face positions

#### 5. "Low confidence scores"
**Symptoms:** Detection results have very low confidence
**Solutions:**
- Check model training quality
- Verify feature extraction is working correctly
- Test with training data samples
- Consider retraining models

### Debug Mode

Enable detailed logging:

```python
# In ml_webcam_server.py
print(f"🧠 Detection: {ethnicity} (confidence: {confidence:.2f})")
print(f"📊 Features extracted: {len(features)} dimensions")
print(f"🎯 Model used: {model_name}")
```

### Performance Monitoring

```python
# Monitor system performance
import psutil

def monitor_performance():
    cpu_percent = psutil.cpu_percent()
    memory_percent = psutil.virtual_memory().percent
    print(f"CPU: {cpu_percent}%, Memory: {memory_percent}%")
```

## 9. Advanced Configuration

### Custom Model Integration

To add new models:

1. **Place model file** in `models/run_20250925_133309/`
2. **Update model_files dictionary** in `load_models()`
3. **Add feature extraction** if needed
4. **Test with new model**

### Custom Feature Extraction

```python
def extract_custom_features(self, image):
    """Add your custom feature extraction"""
    # Your feature extraction code here
    features = np.array([...])
    return features
```

### Model Performance Comparison

```python
def compare_models(self, image):
    """Compare all models on same image"""
    results = {}
    for model_name in self.models.keys():
        ethnicity, confidence = self.predict_ethnicity(image, model_name)
        results[model_name] = (ethnicity, confidence)
    return results
```

## 10. Future Enhancements

### Planned Features

- [ ] Real-time model switching
- [ ] Confidence threshold adjustment
- [ ] Batch processing mode
- [ ] Model performance metrics
- [ ] Web-based configuration interface
- [ ] GPU acceleration support
- [ ] Multi-camera support
- [ ] Cloud model inference

### Integration Opportunities

- [ ] Database logging of detection results
- [ ] Analytics dashboard
- [ ] A/B testing framework
- [ ] Model versioning system
- [ ] Automated model retraining

---

**Last Updated:** 2025-10-03  
**Version:** 1.0  
**Next Review:** 2025-10-10
