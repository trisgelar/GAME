# Quick Start Guide - ML Webcam Server

**Date:** 2025-10-03  
**Status:** ✅ Completed  
**Scope:** Quick start guide for the refactored ML webcam server

## Overview

This guide provides step-by-step instructions to quickly get the ML webcam server running with the new SOLID architecture and configuration system.

## Prerequisites

### System Requirements
- Python 3.12+
- Windows 10/11 (for Windows-specific commands)
- Webcam/camera device
- 4GB+ RAM
- 2GB+ free disk space

### Dependencies
```bash
pip install -r requirements.txt
```

Required packages:
- opencv-python==4.8.1.78
- numpy==1.24.3
- scikit-learn==1.3.0
- scikit-image==0.21.0
- joblib==1.3.2

## Quick Setup

### 1. Clone and Navigate
```bash
cd "Webcam Server"
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Verify Configuration
```bash
python manage_config.py show
python manage_config.py validate
```

### 4. Test Components
```bash
python test_refactored_server.py
```

### 5. Start Server
```bash
python run_ml_server.py
```

## Configuration

### Default Configuration
The server comes with a default `config.json`:
- **Host**: 127.0.0.1
- **Port**: 8888
- **Resolution**: 480x360
- **FPS**: 15
- **Default Model**: glcm_lbp_hog_hsv (recommended)

### Available Models
- `glcm_hog` - GLCM + HOG features
- `glcm_lbp_hog` - GLCM + LBP + HOG features
- `glcm_lbp_hog_hsv` - All features (recommended)
- `hsv` - HSV color only

### Change Default Model
```bash
python manage_config.py set-default glcm_hog
```

### Enable/Disable Models
```bash
python manage_config.py enable glcm_hog
python manage_config.py disable hsv
```

## Usage

### Start Server
```bash
python run_ml_server.py
```

### Server Output
```
=== ML-Enhanced UDP Webcam Server (SOLID Architecture) ===
🚀 ML-Enhanced UDP Server: 127.0.0.1:8888
📊 Settings: 480x360, 15FPS, Q40
🧠 ML Models loaded: ['glcm_hog', 'glcm_lbp_hog', 'glcm_lbp_hog_hsv', 'hsv']
📹 Camera: 640x360 @ 15FPS
```

### Connect Godot Client
The server accepts UDP connections on port 8888. The Godot client can connect using the `MLWebcamManager.gd` script.

## Troubleshooting

### Common Issues

#### 1. Module Not Found
```
ModuleNotFoundError: No module named 'cv2'
```
**Solution**: Install OpenCV
```bash
pip install opencv-python
```

#### 2. Camera Not Found
```
❌ Camera initialization failed
```
**Solution**: Check camera permissions and device ID

#### 3. Models Not Loaded
```
🧠 ML Models loaded: []
```
**Solution**: Verify model files exist in `models/run_20250925_133309/`

#### 4. Configuration Error
```
❌ Configuration validation failed
```
**Solution**: Check `config.json` syntax

### Debug Steps

1. **Check Dependencies**
   ```bash
   pip list | findstr opencv
   ```

2. **Validate Configuration**
   ```bash
   python manage_config.py validate
   ```

3. **Test Components**
   ```bash
   python test_refactored_server.py
   ```

4. **Check Logs**
   ```bash
   type logs\ml_server_*.log
   ```

## Configuration Management

### View Configuration
```bash
python manage_config.py show
```

### Change Server Settings
```bash
python manage_config.py set-server port 9999
python manage_config.py set-server target_fps 30
```

### Model Management
```bash
python manage_config.py set-default glcm_lbp_hog_hsv
python manage_config.py enable glcm_hog
python manage_config.py disable hsv
```

## Performance Tuning

### For Better Performance
- Use `hsv` model for fastest processing
- Reduce `detection_interval` for more frequent detection
- Increase `jpeg_quality` for better image quality

### For Better Accuracy
- Use `glcm_lbp_hog_hsv` model (default)
- Increase `frame_width` and `frame_height`
- Reduce `target_fps` for more processing time

## Logging

### Log Files
- `logs/ml_server_YYYYMMDD.log` - All logs
- `logs/ml_server_errors_YYYYMMDD.log` - Error logs

### Log Levels
- DEBUG: Detailed debugging information
- INFO: General information (default)
- WARNING: Warning messages
- ERROR: Error conditions
- CRITICAL: Critical errors

## API Reference

### UDP Messages
- `REGISTER` - Client registration
- `UNREGISTER` - Client unregistration
- `DETECTION_REQUEST` - Request detection result
- `MODEL_SELECT:<model_name>` - Select ML model

### Responses
- `REGISTERED` - Registration confirmation
- `DETECTION_RESULT:<json_data>` - Detection result
- `MODEL_SELECTED:<model_name>` - Model selection confirmation

## Support

### Documentation
- `docs/2025-10-03_solid-architecture-refactoring.md`
- `docs/2025-10-03_comprehensive-logging-system.md`
- `docs/2025-10-03_model-management-system.md`
- `docs/2025-10-03_configuration-management-system.md`
- `docs/2025-10-03_testing-and-validation.md`

### Testing
- `test_refactored_server.py` - Component tests
- `manage_config.py` - Configuration management
- `run_ml_server.py` - Server launcher

## Conclusion

The ML webcam server is now ready to use with:
- ✅ SOLID architecture implementation
- ✅ Comprehensive logging system
- ✅ Configuration-based model management
- ✅ Combined feature models only
- ✅ Easy configuration management
- ✅ Comprehensive testing and validation

Follow this guide to get started quickly with the refactored ML webcam server.