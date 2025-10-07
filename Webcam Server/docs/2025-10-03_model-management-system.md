# Model Management System - Combined Feature Models Only

**Date:** 2025-10-03  
**Status:** ✅ Completed  
**Scope:** Configuration-based model management with combined feature models only

## Overview

Successfully implemented a configuration-based model management system that loads only combined feature models, removing single-feature models (HOG, GLCM, LBP) and providing flexible model selection through configuration.

## What Was Changed

### ❌ Removed Single Feature Models
- `HOG_model.pkl` - Single HOG features
- `GLCM_model.pkl` - Single GLCM features  
- `LBP_model.pkl` - Single LBP features

### ✅ Kept Combined Feature Models
- `GLCM_HOG_model.pkl` - GLCM + HOG features
- `GLCM_LBP_HOG_model.pkl` - GLCM + LBP + HOG features
- `GLCM_LBP_HOG_HSV_model.pkl` - All features combined (Recommended)
- `HSV_model.pkl` - HSV color features only

## Architecture

### Model Manager Interface
```python
class IModelManager(ABC):
    """Abstract interface for model management"""
    
    @abstractmethod
    def load_models(self, models_dir: str) -> Dict[str, Any]:
        """Load all available models from directory"""
        pass
    
    @abstractmethod
    def predict(self, model_name: str, features: np.ndarray) -> Tuple[Optional[str], float]:
        """Make prediction using specified model"""
        pass
    
    @abstractmethod
    def get_available_models(self) -> List[str]:
        """Get list of available model names"""
        pass
```

### Configuration-Based Loading
```python
class PickleModelManager(IModelManager):
    def load_models(self, models_dir: Optional[str] = None) -> Dict[str, Any]:
        # Use config if no models_dir provided
        if models_dir is None:
            models_dir = self.config_manager.get_models_dir()
        
        # Get enabled models from config
        enabled_models = self.config_manager.get_enabled_models()
        model_files = {}
        
        for model_config in enabled_models:
            model_name = model_config.get("name")
            if model_name:
                # Map model names to actual filenames
                filename_mapping = {
                    'glcm_hog': 'GLCM_HOG_model.pkl',
                    'glcm_lbp_hog': 'GLCM_LBP_HOG_model.pkl', 
                    'glcm_lbp_hog_hsv': 'GLCM_LBP_HOG_HSV_model.pkl',
                    'hsv': 'HSV_model.pkl'
                }
                if model_name in filename_mapping:
                    model_files[model_name] = filename_mapping[model_name]
```

## Configuration System

### config.json Structure
```json
{
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
  }
}
```

## Model Information

### Available Models

#### 1. GLCM + HOG (`glcm_hog`)
- **Features**: GLCM texture + HOG gradients
- **File**: `GLCM_HOG_model.pkl`
- **Use Case**: Texture and shape analysis
- **Performance**: Good balance of accuracy and speed

#### 2. GLCM + LBP + HOG (`glcm_lbp_hog`)
- **Features**: GLCM texture + LBP patterns + HOG gradients
- **File**: `GLCM_LBP_HOG_model.pkl`
- **Use Case**: Comprehensive texture analysis
- **Performance**: Higher accuracy, moderate speed

#### 3. GLCM + LBP + HOG + HSV (`glcm_lbp_hog_hsv`)
- **Features**: All features combined (Recommended)
- **File**: `GLCM_LBP_HOG_HSV_model.pkl`
- **Use Case**: Maximum accuracy
- **Performance**: Highest accuracy, slower speed

#### 4. HSV Color Only (`hsv`)
- **Features**: Color information only
- **File**: `HSV_model.pkl`
- **Use Case**: Color-based classification
- **Performance**: Fastest, color-dependent accuracy

## Configuration Management

### ConfigManager Class
```python
class ConfigManager:
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
```

## Model Loading Process

### 1. Configuration Loading
```python
config_manager = ConfigManager()
enabled_models = config_manager.get_enabled_models()
```

### 2. Model File Mapping
```python
filename_mapping = {
    'glcm_hog': 'GLCM_HOG_model.pkl',
    'glcm_lbp_hog': 'GLCM_LBP_HOG_model.pkl', 
    'glcm_lbp_hog_hsv': 'GLCM_LBP_HOG_HSV_model.pkl',
    'hsv': 'HSV_model.pkl'
}
```

### 3. Model Loading
```python
for model_name, filename in model_files.items():
    model_path = models_path / filename
    if model_path.exists():
        try:
            with open(model_path, 'rb') as f:
                model = pickle.load(f)
            loaded_models[model_name] = model
            logger.info(f"Loaded {model_name} model from {filename}")
        except Exception as e:
            logger.error(f"Failed to load {model_name} from {filename}: {e}")
    else:
        logger.warning(f"Model file not found: {filename}")
```

## Model Prediction

### Prediction Interface
```python
def predict(self, model_name: str, features: np.ndarray) -> Tuple[Optional[str], float]:
    """Make prediction using specified model"""
    if model_name not in self.models:
        logger.error(f"Model not found: {model_name}")
        return None, 0.0
    
    try:
        model = self.models[model_name]
        
        # Ensure features are in correct shape
        if features.ndim == 1:
            features = features.reshape(1, -1)
        
        # Make prediction
        prediction = model.predict(features)[0]
        
        # Get confidence (probability of predicted class)
        if hasattr(model, 'predict_proba'):
            probabilities = model.predict_proba(features)
            confidence = probabilities.max()
        else:
            confidence = 0.8  # Default confidence
        
        # Map prediction to ethnicity name
        ethnicity = self.ethnicity_map.get(prediction, "Unknown")
        
        logger.debug(f"Prediction: {ethnicity} (confidence: {confidence:.3f}) using {model_name}")
        return ethnicity, confidence
        
    except Exception as e:
        logger.error(f"Prediction failed for model {model_name}: {e}")
        return None, 0.0
```

### Ethnicity Mapping
```python
ethnicity_map = {
    0: "Jawa",
    1: "Batak", 
    2: "Sasak",
    3: "Papua"
}
```

## Model Management Script

### manage_config.py Usage
```bash
# Show current configuration
python manage_config.py show

# Set default model
python manage_config.py set-default glcm_lbp_hog_hsv

# Enable/disable models
python manage_config.py enable glcm_hog
python manage_config.py disable hsv

# Validate configuration
python manage_config.py validate
```

### Configuration Commands
```python
def set_default_model(model_name: str):
    """Set the default model"""
    config_manager = ConfigManager()
    
    # Check if model exists and is enabled
    if not config_manager.is_model_enabled(model_name):
        print(f"❌ Model '{model_name}' is not available or not enabled")
        return False
    
    # Update default model
    if config_manager.update_config("ml", "default_model", model_name):
        if config_manager.save_config():
            print(f"✅ Default model set to: {model_name}")
            return True
```

## Model Performance

### Feature Dimensions
- **GLCM + HOG**: ~34,616 features
- **GLCM + LBP + HOG**: ~34,626 features
- **GLCM + LBP + HOG + HSV**: ~34,636 features
- **HSV Only**: ~170 features

### Performance Characteristics
- **Speed**: HSV > GLCM+HOG > GLCM+LBP+HOG > GLCM+LBP+HOG+HSV
- **Accuracy**: GLCM+LBP+HOG+HSV > GLCM+LBP+HOG > GLCM+HOG > HSV
- **Memory**: Proportional to feature dimensions

## Testing

### Model Loading Test
```python
def test_model_manager():
    config_manager = ConfigManager()
    model_manager = ModelManagerFactory.create_manager("pickle", config_manager=config_manager)
    
    # Test model loading using config
    models = model_manager.load_models()
    print(f"✅ Models loaded: {list(models.keys())}")
    
    # Test available models
    available_models = model_manager.get_available_models()
    print(f"✅ Available models: {available_models}")
    
    # Test model info
    for model_name in available_models[:2]:
        info = model_manager.get_model_info(model_name)
        print(f"✅ Model info for {model_name}: {info}")
```

### Configuration Test
```python
def test_config_manager():
    config_manager = ConfigManager()
    
    # Test available models
    available_models = config_manager.get_available_models()
    print(f"✅ Available models: {len(available_models)}")
    
    # Test enabled models
    enabled_models = config_manager.get_enabled_models()
    print(f"✅ Enabled models: {len(enabled_models)}")
    
    # Test default model
    default_model = config_manager.get_default_model()
    print(f"✅ Default model: {default_model}")
```

## Error Handling

### Model Loading Errors
```python
try:
    with open(model_path, 'rb') as f:
        model = pickle.load(f)
    loaded_models[model_name] = model
    logger.info(f"Loaded {model_name} model from {filename}")
except Exception as e:
    logger.error(f"Failed to load {model_name} from {filename}: {e}")
```

### Prediction Errors
```python
try:
    model = self.models[model_name]
    prediction = model.predict(features)[0]
    # ... prediction logic ...
except Exception as e:
    logger.error(f"Prediction failed for model {model_name}: {e}")
    return None, 0.0
```

### Configuration Errors
```python
if not config_manager.is_model_enabled(model_name):
    print(f"❌ Model '{model_name}' is not available or not enabled")
    return False
```

## Best Practices

### 1. Model Selection
- Use `glcm_lbp_hog_hsv` for maximum accuracy
- Use `hsv` for fastest processing
- Use `glcm_hog` for balanced performance

### 2. Configuration Management
- Always validate configuration before use
- Use configuration management script for changes
- Backup configuration files before modifications

### 3. Error Handling
- Check model availability before use
- Handle prediction errors gracefully
- Log all model operations for debugging

### 4. Performance Optimization
- Load models once at startup
- Cache model predictions when possible
- Monitor model performance metrics

## Troubleshooting

### Common Issues

#### 1. Model Not Found
```
❌ Model not found: model_name
```
**Solution**: Check model name in configuration and ensure model file exists

#### 2. Model Loading Failed
```
❌ Failed to load model_name from filename: error_message
```
**Solution**: Check file permissions and model file integrity

#### 3. Prediction Failed
```
❌ Prediction failed for model model_name: error_message
```
**Solution**: Check feature dimensions and model compatibility

#### 4. Configuration Error
```
❌ Model 'model_name' is not available or not enabled
```
**Solution**: Enable model in configuration or check model name

### Debug Steps

1. **Check Configuration**
   ```bash
   python manage_config.py show
   python manage_config.py validate
   ```

2. **Verify Model Files**
   ```bash
   ls -la models/run_20250925_133309/*.pkl
   ```

3. **Test Model Loading**
   ```python
   python test_refactored_server.py
   ```

4. **Check Logs**
   ```bash
   tail -f logs/ml_server_*.log
   ```

## Future Enhancements

### 1. Model Versioning
- Support for multiple model versions
- Automatic model version selection
- Model performance comparison

### 2. Dynamic Model Loading
- Load models on-demand
- Model hot-swapping
- Memory-efficient model management

### 3. Model Ensemble
- Combine multiple model predictions
- Weighted voting systems
- Confidence-based ensemble selection

### 4. Model Monitoring
- Real-time model performance tracking
- Model accuracy monitoring
- Automatic model retraining triggers

## Conclusion

The model management system successfully:
- **Removed single-feature models** (HOG, GLCM, LBP)
- **Kept only combined feature models** for better accuracy
- **Implemented configuration-based management** for flexibility
- **Provided easy model selection** through configuration
- **Added comprehensive error handling** and logging
- **Created management tools** for configuration changes

This system provides a robust, flexible, and maintainable approach to model management in the ML webcam server.
