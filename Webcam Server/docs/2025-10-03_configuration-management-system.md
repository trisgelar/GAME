# Configuration Management System

**Date:** 2025-10-03  
**Status:** ✅ Completed  
**Scope:** Comprehensive configuration system for ML webcam server

## Overview

Implemented a comprehensive configuration management system that allows easy modification of server settings, model selection, and system behavior through JSON configuration files and management tools.

## Architecture

### ConfigManager Class
```python
class ConfigManager:
    """Configuration manager for the ML webcam server"""
    
    def __init__(self, config_file: str = "config.json"):
        self.config_file = Path(config_file)
        self.config: Dict[str, Any] = {}
        self.load_config()
```

### Key Features
- **JSON-based configuration** for easy editing
- **Automatic validation** of configuration
- **Default configuration creation** if file doesn't exist
- **Runtime configuration updates** with persistence
- **Configuration summary** and status reporting

## Configuration Structure

### Complete config.json
```json
{
  "server": {
    "host": "127.0.0.1",
    "port": 8888,
    "frame_width": 480,
    "frame_height": 360,
    "target_fps": 15,
    "jpeg_quality": 40,
    "detection_interval": 30
  },
  "ml": {
    "models_dir": "models/run_20250925_133309",
    "default_model": "glcm_lbp_hog_hsv",
    "available_models": [
      {
        "name": "glcm_hog",
        "display_name": "GLCM + HOG",
        "description": "Gray-Level Co-occurrence Matrix + Histogram of Oriented Gradients",
        "features": ["glcm", "hog"],
        "enabled": true
      },
      {
        "name": "glcm_lbp_hog",
        "display_name": "GLCM + LBP + HOG",
        "description": "GLCM + Local Binary Pattern + HOG",
        "features": ["glcm", "lbp", "hog"],
        "enabled": true
      },
      {
        "name": "glcm_lbp_hog_hsv",
        "display_name": "GLCM + LBP + HOG + HSV",
        "description": "All features combined (Recommended)",
        "features": ["glcm", "lbp", "hog", "hsv"],
        "enabled": true
      },
      {
        "name": "hsv",
        "display_name": "HSV Color Only",
        "description": "Hue-Saturation-Value color features",
        "features": ["hsv"],
        "enabled": true
      }
    ]
  },
  "camera": {
    "camera_id": 0,
    "backend": "opencv",
    "auto_resize": true
  },
  "logging": {
    "log_dir": "logs",
    "log_level": "INFO",
    "console_output": true,
    "file_output": true,
    "max_log_files": 7
  },
  "performance": {
    "max_packet_size": 32768,
    "client_timeout": 30,
    "enable_performance_monitoring": true
  }
}
```

## Configuration Sections

### 1. Server Configuration
```json
{
  "server": {
    "host": "127.0.0.1",           // Server host address
    "port": 8888,                  // Server port
    "frame_width": 480,            // Video frame width
    "frame_height": 360,           // Video frame height
    "target_fps": 15,              // Target frames per second
    "jpeg_quality": 40,            // JPEG compression quality (1-100)
    "detection_interval": 30       // ML detection interval (frames)
  }
}
```

### 2. ML Configuration
```json
{
  "ml": {
    "models_dir": "models/run_20250925_133309",  // Models directory path
    "default_model": "glcm_lbp_hog_hsv",         // Default model name
    "available_models": [                         // Available models list
      {
        "name": "glcm_hog",                       // Model identifier
        "display_name": "GLCM + HOG",            // Human-readable name
        "description": "Gray-Level Co-occurrence Matrix + Histogram of Oriented Gradients",
        "features": ["glcm", "hog"],             // Feature types used
        "enabled": true                          // Whether model is enabled
      }
    ]
  }
}
```

### 3. Camera Configuration
```json
{
  "camera": {
    "camera_id": 0,               // Camera device ID
    "backend": "opencv",          // Camera backend
    "auto_resize": true           // Automatic resize to target resolution
  }
}
```

### 4. Logging Configuration
```json
{
  "logging": {
    "log_dir": "logs",            // Log directory path
    "log_level": "INFO",          // Log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
    "console_output": true,       // Enable console output
    "file_output": true,          // Enable file output
    "max_log_files": 7            // Maximum number of log files to keep
  }
}
```

### 5. Performance Configuration
```json
{
  "performance": {
    "max_packet_size": 32768,     // Maximum UDP packet size
    "client_timeout": 30,         // Client connection timeout (seconds)
    "enable_performance_monitoring": true  // Enable performance monitoring
  }
}
```

## Configuration Management Methods

### 1. Loading Configuration
```python
def load_config(self) -> bool:
    """Load configuration from file"""
    try:
        if not self.config_file.exists():
            logger.warning(f"Config file not found: {self.config_file}")
            self._create_default_config()
            return False
        
        with open(self.config_file, 'r', encoding='utf-8') as f:
            self.config = json.load(f)
        
        logger.info(f"Configuration loaded from {self.config_file}")
        return True
        
    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON in config file: {e}")
        return False
    except Exception as e:
        logger.error(f"Failed to load config file: {e}")
        return False
```

### 2. Default Configuration Creation
```python
def _create_default_config(self) -> None:
    """Create default configuration if config file doesn't exist"""
    default_config = {
        "server": {
            "host": "127.0.0.1",
            "port": 8888,
            "frame_width": 480,
            "frame_height": 360,
            "target_fps": 15,
            "jpeg_quality": 40,
            "detection_interval": 30
        },
        # ... other sections ...
    }
    
    try:
        with open(self.config_file, 'w', encoding='utf-8') as f:
            json.dump(default_config, f, indent=2)
        
        self.config = default_config
        logger.info(f"Default configuration created at {self.config_file}")
        
    except Exception as e:
        logger.error(f"Failed to create default config: {e}")
```

### 3. Configuration Validation
```python
def validate_config(self) -> bool:
    """Validate configuration"""
    try:
        # Check required sections
        required_sections = ["server", "ml", "camera", "logging"]
        for section in required_sections:
            if section not in self.config:
                logger.error(f"Missing required config section: {section}")
                return False
        
        # Validate server config
        server_config = self.get_server_config()
        required_server_keys = ["host", "port", "frame_width", "frame_height", "target_fps"]
        for key in required_server_keys:
            if key not in server_config:
                logger.error(f"Missing required server config key: {key}")
                return False
        
        # Validate ML config
        ml_config = self.get_ml_config()
        if "available_models" not in ml_config:
            logger.error("Missing available_models in ML config")
            return False
        
        # Check if default model exists in available models
        default_model = self.get_default_model()
        available_model_names = [model.get("name") for model in self.get_available_models()]
        if default_model not in available_model_names:
            logger.error(f"Default model '{default_model}' not found in available models")
            return False
        
        logger.info("Configuration validation passed")
        return True
        
    except Exception as e:
        logger.error(f"Configuration validation failed: {e}")
        return False
```

## Configuration Access Methods

### 1. Section Access
```python
def get_server_config(self) -> Dict[str, Any]:
    """Get server configuration"""
    return self.config.get("server", {})

def get_ml_config(self) -> Dict[str, Any]:
    """Get ML configuration"""
    return self.config.get("ml", {})

def get_camera_config(self) -> Dict[str, Any]:
    """Get camera configuration"""
    return self.config.get("camera", {})

def get_logging_config(self) -> Dict[str, Any]:
    """Get logging configuration"""
    return self.config.get("logging", {})

def get_performance_config(self) -> Dict[str, Any]:
    """Get performance configuration"""
    return self.config.get("performance", {})
```

### 2. Model-Specific Access
```python
def get_available_models(self) -> List[Dict[str, Any]]:
    """Get list of available models from config"""
    ml_config = self.get_ml_config()
    return ml_config.get("available_models", [])

def get_enabled_models(self) -> List[Dict[str, Any]]:
    """Get list of enabled models"""
    models = self.get_available_models()
    return [model for model in models if model.get("enabled", True)]

def get_default_model(self) -> str:
    """Get default model name"""
    ml_config = self.get_ml_config()
    return ml_config.get("default_model", "glcm_lbp_hog_hsv")

def is_model_enabled(self, model_name: str) -> bool:
    """Check if a model is enabled"""
    models = self.get_available_models()
    for model in models:
        if model.get("name") == model_name:
            return model.get("enabled", True)
    return False

def get_model_info(self, model_name: str) -> Optional[Dict[str, Any]]:
    """Get information about a specific model"""
    models = self.get_available_models()
    for model in models:
        if model.get("name") == model_name:
            return model
    return None
```

### 3. Configuration Updates
```python
def update_config(self, section: str, key: str, value: Any) -> bool:
    """Update a specific configuration value"""
    try:
        if section not in self.config:
            self.config[section] = {}
        
        self.config[section][key] = value
        logger.info(f"Updated config: {section}.{key} = {value}")
        return True
        
    except Exception as e:
        logger.error(f"Failed to update config: {e}")
        return False

def save_config(self) -> bool:
    """Save current configuration to file"""
    try:
        with open(self.config_file, 'w', encoding='utf-8') as f:
            json.dump(self.config, f, indent=2)
        
        logger.info(f"Configuration saved to {self.config_file}")
        return True
        
    except Exception as e:
        logger.error(f"Failed to save config: {e}")
        return False
```

## Configuration Management Script

### manage_config.py Features
```bash
# Show current configuration
python manage_config.py show

# Validate configuration
python manage_config.py validate

# Set default model
python manage_config.py set-default glcm_lbp_hog_hsv

# Enable/disable models
python manage_config.py enable glcm_hog
python manage_config.py disable hsv

# Set server settings
python manage_config.py set-server port 9999
python manage_config.py set-server target_fps 30
```

### Script Implementation
```python
def show_config():
    """Display current configuration"""
    print("=== Current Configuration ===")
    config_manager = ConfigManager()
    
    # Server config
    server_config = config_manager.get_server_config()
    print(f"\n📡 Server Configuration:")
    print(f"  Host: {server_config.get('host')}")
    print(f"  Port: {server_config.get('port')}")
    print(f"  Resolution: {server_config.get('frame_width')}x{server_config.get('frame_height')}")
    print(f"  FPS: {server_config.get('target_fps')}")
    print(f"  JPEG Quality: {server_config.get('jpeg_quality')}")
    print(f"  Detection Interval: {server_config.get('detection_interval')} frames")
    
    # ML config
    ml_config = config_manager.get_ml_config()
    print(f"\n🧠 ML Configuration:")
    print(f"  Models Directory: {ml_config.get('models_dir')}")
    print(f"  Default Model: {ml_config.get('default_model')}")
    
    # Available models
    available_models = config_manager.get_available_models()
    print(f"\n📋 Available Models ({len(available_models)}):")
    for model in available_models:
        status = "✅ Enabled" if model.get('enabled', True) else "❌ Disabled"
        print(f"  {model.get('name')}: {model.get('display_name')} {status}")
        print(f"    Description: {model.get('description')}")
        print(f"    Features: {', '.join(model.get('features', []))}")
```

## Integration with Components

### 1. Server Integration
```python
class MLWebcamServer:
    def __init__(self, config_file: str = "config.json"):
        # Load configuration
        self.config_manager = ConfigManager(config_file)
        
        # Get server configuration
        server_config = self.config_manager.get_server_config()
        self.host = server_config.get("host", "127.0.0.1")
        self.port = server_config.get("port", 8888)
        self.frame_width = server_config.get("frame_width", 480)
        self.frame_height = server_config.get("frame_height", 360)
        self.target_fps = server_config.get("target_fps", 15)
        self.jpeg_quality = server_config.get("jpeg_quality", 40)
        self.detection_interval = server_config.get("detection_interval", 30)
        
        # Get camera configuration
        camera_config = self.config_manager.get_camera_config()
        camera_id = camera_config.get("camera_id", 0)
        
        # Initialize components with config
        self.camera = CameraFactory.create_camera("opencv", camera_id=camera_id)
        self.udp_server = UDPServerFactory.create_server("video")
        self.ethnicity_detector = MLEthnicityDetector.create_default_detector(self.config_manager)
```

### 2. Model Manager Integration
```python
class PickleModelManager(IModelManager):
    def __init__(self, config_manager: Optional[ConfigManager] = None):
        self.config_manager = config_manager or ConfigManager()
        # ... initialization ...
    
    def load_models(self, models_dir: Optional[str] = None) -> Dict[str, Any]:
        # Use config if no models_dir provided
        if models_dir is None:
            models_dir = self.config_manager.get_models_dir()
        
        # Get enabled models from config
        enabled_models = self.config_manager.get_enabled_models()
        # ... model loading logic ...
```

### 3. Ethnicity Detector Integration
```python
class MLEthnicityDetector:
    def __init__(self, face_detector, feature_extractors, model_manager, config_manager):
        self.config_manager = config_manager
        self.models_dir = config_manager.get_models_dir()
        # ... initialization ...
    
    def predict_ethnicity(self, image: np.ndarray, model_name: Optional[str] = None) -> Tuple[Optional[str], float]:
        # Use default model from config if not specified
        if model_name is None:
            model_name = self.config_manager.get_default_model()
        # ... prediction logic ...
```

## Configuration Best Practices

### 1. Configuration Structure
- Use consistent naming conventions
- Group related settings together
- Provide clear descriptions for complex settings
- Use appropriate data types for each setting

### 2. Validation
- Always validate configuration on load
- Check for required sections and keys
- Validate data types and ranges
- Provide meaningful error messages

### 3. Default Values
- Provide sensible defaults for all settings
- Document default values in comments
- Allow configuration to override defaults
- Handle missing configuration gracefully

### 4. Updates and Persistence
- Validate updates before applying
- Save configuration changes immediately
- Provide rollback mechanisms
- Log all configuration changes

## Error Handling

### 1. Configuration Loading Errors
```python
try:
    with open(self.config_file, 'r', encoding='utf-8') as f:
        self.config = json.load(f)
    logger.info(f"Configuration loaded from {self.config_file}")
    return True
except json.JSONDecodeError as e:
    logger.error(f"Invalid JSON in config file: {e}")
    return False
except Exception as e:
    logger.error(f"Failed to load config file: {e}")
    return False
```

### 2. Validation Errors
```python
def validate_config(self) -> bool:
    try:
        # Check required sections
        required_sections = ["server", "ml", "camera", "logging"]
        for section in required_sections:
            if section not in self.config:
                logger.error(f"Missing required config section: {section}")
                return False
        # ... more validation ...
    except Exception as e:
        logger.error(f"Configuration validation failed: {e}")
        return False
```

### 3. Update Errors
```python
def update_config(self, section: str, key: str, value: Any) -> bool:
    try:
        if section not in self.config:
            self.config[section] = {}
        
        self.config[section][key] = value
        logger.info(f"Updated config: {section}.{key} = {value}")
        return True
    except Exception as e:
        logger.error(f"Failed to update config: {e}")
        return False
```

## Testing

### 1. Configuration Loading Test
```python
def test_config_manager():
    config_manager = ConfigManager()
    
    # Test config loading
    print("✅ Config manager initialized")
    
    # Test server config
    server_config = config_manager.get_server_config()
    print(f"✅ Server config: {server_config}")
    
    # Test ML config
    ml_config = config_manager.get_ml_config()
    print(f"✅ ML config: {ml_config}")
    
    # Test available models
    available_models = config_manager.get_available_models()
    print(f"✅ Available models: {len(available_models)}")
    
    # Test enabled models
    enabled_models = config_manager.get_enabled_models()
    print(f"✅ Enabled models: {len(enabled_models)}")
    
    # Test default model
    default_model = config_manager.get_default_model()
    print(f"✅ Default model: {default_model}")
    
    # Test config validation
    is_valid = config_manager.validate_config()
    print(f"✅ Config validation: {is_valid}")
```

### 2. Configuration Update Test
```python
def test_config_updates():
    config_manager = ConfigManager()
    
    # Test model enable/disable
    config_manager.update_config("ml", "available_models", [
        {"name": "test_model", "enabled": True}
    ])
    
    # Test server setting update
    config_manager.update_config("server", "port", 9999)
    
    # Test save
    success = config_manager.save_config()
    print(f"✅ Config save: {success}")
```

## Troubleshooting

### Common Issues

#### 1. Configuration File Not Found
```
⚠️ Config file not found: config.json
```
**Solution**: Check file path and permissions

#### 2. Invalid JSON
```
❌ Invalid JSON in config file: Expecting ',' delimiter: line 5 column 3
```
**Solution**: Validate JSON syntax and fix formatting

#### 3. Missing Required Sections
```
❌ Missing required config section: server
```
**Solution**: Add missing sections to configuration

#### 4. Invalid Model Configuration
```
❌ Default model 'invalid_model' not found in available models
```
**Solution**: Check model name and enable status

### Debug Steps

1. **Check Configuration File**
   ```bash
   cat config.json | python -m json.tool
   ```

2. **Validate Configuration**
   ```bash
   python manage_config.py validate
   ```

3. **Show Current Configuration**
   ```bash
   python manage_config.py show
   ```

4. **Check Logs**
   ```bash
   tail -f logs/ml_server_*.log
   ```

## Future Enhancements

### 1. Configuration Versioning
- Support for configuration schema versions
- Automatic migration between versions
- Backward compatibility maintenance

### 2. Dynamic Configuration
- Runtime configuration updates without restart
- Configuration change notifications
- Hot-reload capabilities

### 3. Configuration Templates
- Predefined configuration templates
- Environment-specific configurations
- Configuration inheritance

### 4. Advanced Validation
- Schema-based validation
- Custom validation rules
- Configuration dependency checking

## Conclusion

The configuration management system provides:
- **Flexible configuration** through JSON files
- **Comprehensive validation** and error handling
- **Easy management** through command-line tools
- **Integration** with all system components
- **Runtime updates** with persistence
- **Default configuration** creation
- **Detailed logging** of all operations

This system enables easy customization and maintenance of the ML webcam server without code modifications.
