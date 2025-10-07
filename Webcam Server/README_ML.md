# ML-Enhanced Ethnicity Detection System

## Overview

This system integrates machine learning models for real-time ethnicity detection using webcam input. It consists of two main components:

1. **ML Webcam Server** (Python) - Processes webcam frames with trained ML models
2. **Godot Client** - Displays results and handles user interaction

## Architecture

```
┌─────────────────┐    UDP     ┌──────────────────┐
│   Godot Client  │◄──────────►│  ML Webcam Server│
│                 │            │                  │
│ - UI Display    │            │ - Webcam Capture │
│ - Result Show   │            │ - ML Processing  │
│ - Model Select  │            │ - Model Inference│
└─────────────────┘            └──────────────────┘
```

## Available ML Models

The system supports multiple trained models:

| Model | Description | Features Used |
|-------|-------------|---------------|
| `glcm_lbp_hog_hsv` | **Best Model** | GLCM + LBP + HOG + HSV |
| `glcm_lbp_hog` | High Performance | GLCM + LBP + HOG |
| `glcm_hog` | Balanced | GLCM + HOG |
| `hog` | HOG Only | HOG Features |
| `glcm` | GLCM Only | GLCM Features |
| `lbp` | LBP Only | LBP Features |
| `hsv` | HSV Only | HSV Color Features |

## Setup Instructions

### 1. Install Dependencies

```bash
cd "Webcam Server"
pip install -r requirements.txt
```

### 2. Verify Models

Ensure your trained models are in the correct location:
```
Webcam Server/
└── models/
    └── run_20250925_133309/
        ├── GLCM_HOG_model.pkl
        ├── GLCM_LBP_HOG_model.pkl
        ├── GLCM_LBP_HOG_HSV_model.pkl
        └── ... (other model files)
```

### 3. Test the System

```bash
# Test ML functionality
python test_ml_server.py

# Run the ML server
python ml_webcam_server.py
```

### 4. Run Godot Client

1. Open Godot project: `Walking Simulator`
2. Run scene: `Scenes/EthnicityDetection/EthnicityDetectionScene.tscn`
3. The client will automatically connect to the ML server

## Usage

### Starting the System

1. **Start ML Server**:
   ```bash
   cd "Webcam Server"
   python ml_webcam_server.py
   ```
   
   Expected output:
   ```
   🎥 Initializing ML-enhanced camera...
   ✅ Camera ready: 480x360 @ 15FPS
   🤖 ML Models loaded: ['glcm_lbp_hog_hsv', 'glcm_lbp_hog', ...]
   🚀 ML-Enhanced UDP Server: 127.0.0.1:8888
   ```

2. **Run Godot Client**:
   - Open the ethnicity detection scene
   - The client will automatically connect
   - Select your preferred ML model from the dropdown
   - Click "Mulai Deteksi ML" to start detection

### Model Selection

The Godot client provides a dropdown to select different ML models:

- **GLCM + LBP + HOG + HSV**: Best accuracy (recommended)
- **GLCM + LBP + HOG**: High performance
- **Individual models**: For testing specific features

### Detection Process

1. **Face Detection**: System automatically detects faces in webcam feed
2. **Feature Extraction**: Extracts HOG, GLCM, LBP, and/or HSV features
3. **ML Inference**: Runs trained model to predict ethnicity
4. **Result Display**: Shows ethnicity and confidence score
5. **Scene Navigation**: Redirects to appropriate cultural scene

## Communication Protocol

### UDP Messages

**Client → Server**:
- `REGISTER` - Register for video stream
- `DETECTION_REQUEST` - Request ethnicity detection
- `MODEL_SELECT:model_name` - Select ML model
- `UNREGISTER` - Disconnect

**Server → Client**:
- `REGISTERED` - Registration confirmed
- `DETECTION_RESULT:{"ethnicity":"Jawa","confidence":0.85,"model":"glcm_lbp_hog_hsv"}` - Detection result
- `MODEL_SELECTED:model_name` - Model selection confirmed
- `MODEL_ERROR:error_message` - Model selection error

## Performance Optimization

### Server Settings

```python
# In ml_webcam_server.py
self.target_fps = 15          # Frame rate
self.jpeg_quality = 40        # JPEG quality (20-80)
self.frame_width = 480        # Frame width
self.frame_height = 360       # Frame height
self.detection_interval = 30  # Process every N frames
```

### Client Settings

```gdscript
# In MLWebcamManager.gd
var max_packets_per_frame: int = 10  # Packet processing limit
var frame_timeout: float = 0.5       # Frame timeout
```

## Troubleshooting

### Common Issues

1. **"No models loaded"**:
   - Check model files exist in `models/run_20250925_133309/`
   - Verify model files are not corrupted
   - Run `python test_ml_server.py` to test models

2. **"Camera initialization failed"**:
   - Check webcam is connected and not used by other applications
   - Try different camera index in `cv2.VideoCapture(0)`

3. **"Connection timeout"**:
   - Ensure ML server is running on port 8888
   - Check firewall settings
   - Verify IP address (127.0.0.1 for local)

4. **"No face detected"**:
   - Ensure good lighting
   - Face should be clearly visible
   - Check face detection cascade file

### Debug Mode

Enable debug logging:
```python
# In ml_webcam_server.py
print(f"🧠 Detection: {ethnicity} (confidence: {confidence:.2f})")
```

## File Structure

```
Webcam Server/
├── ml_webcam_server.py          # Main ML server
├── test_ml_server.py            # Test script
├── requirements.txt             # Python dependencies
├── README_ML.md                 # This file
└── models/
    └── run_20250925_133309/     # Trained models
        ├── GLCM_HOG_model.pkl
        ├── GLCM_LBP_HOG_model.pkl
        └── ...

Walking Simulator/Scenes/EthnicityDetection/
├── MLEthnicityDetectionController.gd  # ML-enhanced controller
├── WebcamClient/
│   └── MLWebcamManager.gd       # ML webcam client
└── EthnicityDetectionScene.tscn # UI scene
```

## Model Training Notes

The models were trained on the following features:

- **HOG**: Histogram of Oriented Gradients (texture features)
- **GLCM**: Gray-Level Co-occurrence Matrix (texture features)  
- **LBP**: Local Binary Patterns (texture features)
- **HSV**: Hue-Saturation-Value (color features)

Combined models typically achieve better accuracy than individual feature models.

## Future Enhancements

- [ ] Real-time model switching
- [ ] Confidence threshold adjustment
- [ ] Batch processing mode
- [ ] Model performance metrics
- [ ] Web-based configuration interface
