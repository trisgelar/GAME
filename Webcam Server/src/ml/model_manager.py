#!/usr/bin/env python3
"""
ML Model Manager with Factory Pattern
Following SOLID principles for model loading and management
"""

import pickle
import json
import numpy as np
from abc import ABC, abstractmethod
from pathlib import Path
from typing import Dict, Any, Optional, Tuple, List
from ..core.logger import logger
from ..core.config_manager import ConfigManager


class IModelManager(ABC):
    """Abstract interface for model management (Interface Segregation Principle)"""
    
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
    
    @abstractmethod
    def get_model_info(self, model_name: str) -> Dict[str, Any]:
        """Get information about a specific model"""
        pass


class PickleModelManager(IModelManager):
    """Pickle-based model manager implementation"""
    
    def __init__(self, config_manager: Optional[ConfigManager] = None):
        self.config_manager = config_manager or ConfigManager()
        self.models: Dict[str, Any] = {}
        self.feature_config: Dict[str, Any] = {}
        self.ethnicity_map = {
            0: "Jawa",
            1: "Batak", 
            2: "Sasak",
            3: "Papua"
        }
        logger.info("Pickle model manager initialized")
    
    def load_models(self, models_dir: Optional[str] = None) -> Dict[str, Any]:
        """Load all available models from directory"""
        # Use config if no models_dir provided
        if models_dir is None:
            models_dir = self.config_manager.get_models_dir()
        
        models_path = Path(models_dir)
        if not models_path.exists():
            logger.error(f"Models directory does not exist: {models_dir}")
            return {}
        
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
                    'hsv': 'HSV_model.pkl',
                    'lbp_hog': 'LBP_HOG_model.pkl'
                }
                if model_name in filename_mapping:
                    model_files[model_name] = filename_mapping[model_name]
        
        loaded_models = {}
        
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
        
        self.models = loaded_models
        
        # Load feature configuration
        self._load_feature_config(models_path)
        
        logger.info(f"Successfully loaded {len(loaded_models)} models")
        return loaded_models
    
    def _load_feature_config(self, models_path: Path) -> None:
        """Load feature extraction configuration"""
        config_file = models_path / "feature_sets_summary_20250925_133309.json"
        if config_file.exists():
            try:
                with open(config_file, 'r') as f:
                    self.feature_config = json.load(f)
                logger.info("Loaded feature configuration")
            except Exception as e:
                logger.error(f"Failed to load feature config: {e}")
                self.feature_config = {}
        else:
            logger.warning("Feature configuration file not found")
            self.feature_config = {}
    
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
                # Fallback confidence calculation
                confidence = 0.8  # Default confidence
            
            # Map prediction to ethnicity name
            ethnicity = self.ethnicity_map.get(prediction, "Unknown")
            
            logger.debug(f"Prediction: {ethnicity} (confidence: {confidence:.3f}) using {model_name}")
            return ethnicity, confidence
            
        except Exception as e:
            logger.error(f"Prediction failed for model {model_name}: {e}")
            return None, 0.0
    
    def get_available_models(self) -> List[str]:
        """Get list of available model names"""
        return list(self.models.keys())
    
    def get_model_info(self, model_name: str) -> Dict[str, Any]:
        """Get information about a specific model"""
        if model_name not in self.models:
            return {}
        
        model = self.models[model_name]
        info = {
            'name': model_name,
            'type': type(model).__name__,
            'available': True
        }
        
        # Add model-specific information
        if hasattr(model, 'n_features_in_'):
            info['n_features'] = model.n_features_in_
        
        if hasattr(model, 'classes_'):
            info['classes'] = model.classes_.tolist()
        
        if hasattr(model, 'feature_importances_'):
            info['has_feature_importances'] = True
        
        return info
    
    def get_feature_config(self) -> Dict[str, Any]:
        """Get feature configuration"""
        return self.feature_config


class ModelManagerFactory:
    """Factory for creating model managers"""
    
    @staticmethod
    def create_manager(manager_type: str = "pickle", config_manager: Optional[ConfigManager] = None, **kwargs) -> IModelManager:
        """Create model manager based on type"""
        managers = {
            'pickle': PickleModelManager
        }
        
        if manager_type.lower() not in managers:
            raise ValueError(f"Unknown manager type: {manager_type}")
        
        manager_class = managers[manager_type.lower()]
        logger.info(f"Creating {manager_type} model manager")
        
        if manager_type.lower() == 'pickle':
            return manager_class(config_manager=config_manager, **kwargs)
        else:
            return manager_class(**kwargs)
