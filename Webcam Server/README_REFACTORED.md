# ML-Enhanced Webcam Server - SOLID Architecture

This document describes the refactored ML webcam server implementation following SOLID principles with comprehensive logging.

## Architecture Overview

The refactored server uses a modular, SOLID-compliant architecture with the following components:

```
src/
├── core/                    # Core utilities
│   └── logger.py           # Thread-safe singleton logger
├── ml/                     # Machine Learning components
│   ├── face_detector.py    # Face detection interfaces
│   ├── feature_extractors.py # Feature extraction (HOG, GLCM, LBP, HSV)
│   ├── model_manager.py    # ML model management
│   └── ethnicity_detector.py # Main ML detector
├── camera/                 # Camera interfaces
│   └── camera_interface.py # Camera abstraction
├── network/                # Network components
│   └── udp_server.py       # UDP server implementation
└── server/                 # Main server
    └── ml_webcam_server.py # Refactored main server
```

## SOLID Principles Implementation

### 1. Single Responsibility Principle (SRP)
- **Logger**: Handles only logging operations
- **FaceDetector**: Handles only face detection
- **FeatureExtractor**: Handles only feature extraction
- **ModelManager**: Handles only model loading and prediction
- **Camera**: Handles only camera operations
- **UDPServer**: Handles only network communication

### 2. Open/Closed Principle (OCP)
- Abstract interfaces allow extension without modification
- New feature extractors can be added by implementing `IFeatureExtractor`
- New camera types can be added by implementing `ICamera`
- New model managers can be added by implementing `IModelManager`

### 3. Liskov Substitution Principle (LSP)
- All implementations can be substituted for their interfaces
- Factory patterns ensure proper instantiation
- Interface contracts are maintained across implementations

### 4. Interface Segregation Principle (ISP)
- Interfaces are focused and specific
- `IFeatureExtractor` only contains feature extraction methods
- `ICamera` only contains camera-related methods
- `ILogger` only contains logging methods

### 5. Dependency Inversion Principle (DIP)
- High-level modules depend on abstractions
- `MLEthnicityDetector` depends on `IFaceDetector`, `IFeatureExtractor`, `IModelManager`
- `MLWebcamServer` depends on `ICamera`, `IUDPServer`, `MLEthnicityDetector`
- Dependencies are injected through constructors

## Key Features

### Comprehensive Logging
- Thread-safe singleton logger
- Multiple log levels (DEBUG, INFO, WARNING, ERROR, CRITICAL)
- File and console output
- Performance metrics logging
- Specialized logging for ML operations, client connections, and model operations

### Modular Design
- Each component is independently testable
- Clear separation of concerns
- Easy to extend and maintain
- Factory patterns for object creation

### Performance Monitoring
- Frame rate control
- Detection performance tracking
- Client connection monitoring
- Resource usage logging

## Usage

### Running the Server
```bash
# Using the launcher script
python run_ml_server.py

# Or directly
python src/server/ml_webcam_server.py
```

### Testing Components
```bash
# Test all components
python test_refactored_server.py

# Test individual components
python -c "from src.core.logger import logger; logger.info('Test message')"
```

## Configuration

### Server Settings
- **Host**: 127.0.0.1 (default)
- **Port**: 8888 (default)
- **Frame Rate**: 15 FPS
- **Resolution**: 480x360
- **JPEG Quality**: 40
- **Detection Interval**: Every 30 frames

### Logging Configuration
- **Log Directory**: `logs/`
- **Log Files**: 
  - `ml_server_YYYYMMDD.log` - All logs
  - `ml_server_errors_YYYYMMDD.log` - Error logs only
- **Console Output**: INFO level and above
- **File Output**: DEBUG level and above

## ML Models

The server supports the following ML models:
- `glcm_hog` - GLCM + HOG features
- `glcm_lbp_hog` - GLCM + LBP + HOG features
- `glcm_lbp_hog_hsv` - GLCM + LBP + HOG + HSV features
- `hsv` - HSV color features only

## API Endpoints

### UDP Messages
- `REGISTER` - Client registration
- `UNREGISTER` - Client unregistration
- `DETECTION_REQUEST` - Request detection result
- `MODEL_SELECT:<model_name>` - Select ML model

### Responses
- `REGISTERED` - Registration confirmation
- `DETECTION_RESULT:<json_data>` - Detection result
- `MODEL_SELECTED:<model_name>` - Model selection confirmation
- `MODEL_ERROR:<error_message>` - Model selection error

## Performance Metrics

The server tracks the following metrics:
- Total frames processed
- Detection count and average time
- Client connections
- Frame sending performance
- Model prediction performance

## Error Handling

- Comprehensive error logging
- Graceful degradation on component failures
- Automatic client disconnection on errors
- Resource cleanup on shutdown

## Dependencies

- OpenCV 4.8.1.78
- NumPy 1.24.3
- scikit-learn 1.3.0
- scikit-image 0.21.0
- joblib 1.3.2

## Future Enhancements

- Additional feature extractors
- Model ensemble support
- Real-time performance optimization
- Web-based configuration interface
- Docker containerization
- Health check endpoints
