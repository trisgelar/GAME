#!/usr/bin/env python3
"""
Configuration Manager for ML Webcam Server
Handles loading and validation of configuration files
"""

import json
from pathlib import Path
from typing import Dict, Any, List, Optional
from .logger import logger


class ConfigManager:
    """Configuration manager for the ML webcam server"""
    
    def __init__(self, config_file: str = "config.json"):
        self.config_file = Path(config_file)
        self.config: Dict[str, Any] = {}
        self.load_config()
    
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
            "ml": {
                "models_dir": "models/run_20250925_133309",
                "default_model": "glcm_lbp_hog_hsv",
                "available_models": [
                    {
                        "name": "glcm_hog",
                        "display_name": "GLCM + HOG",
                        "description": "Gray-Level Co-occurrence Matrix + Histogram of Oriented Gradients",
                        "features": ["glcm", "hog"],
                        "enabled": True
                    },
                    {
                        "name": "glcm_lbp_hog",
                        "display_name": "GLCM + LBP + HOG",
                        "description": "GLCM + Local Binary Pattern + HOG",
                        "features": ["glcm", "lbp", "hog"],
                        "enabled": True
                    },
                    {
                        "name": "glcm_lbp_hog_hsv",
                        "display_name": "GLCM + LBP + HOG + HSV",
                        "description": "All features combined (Recommended)",
                        "features": ["glcm", "lbp", "hog", "hsv"],
                        "enabled": True
                    },
                    {
                        "name": "hsv",
                        "display_name": "HSV Color Only",
                        "description": "Hue-Saturation-Value color features",
                        "features": ["hsv"],
                        "enabled": True
                    }
                ]
            },
            "camera": {
                "camera_id": 0,
                "backend": "opencv",
                "auto_resize": True
            },
            "logging": {
                "log_dir": "logs",
                "log_level": "INFO",
                "console_output": True,
                "file_output": True,
                "max_log_files": 7
            },
            "performance": {
                "max_packet_size": 32768,
                "client_timeout": 30,
                "enable_performance_monitoring": True
            }
        }
        
        try:
            with open(self.config_file, 'w', encoding='utf-8') as f:
                json.dump(default_config, f, indent=2)
            
            self.config = default_config
            logger.info(f"Default configuration created at {self.config_file}")
            
        except Exception as e:
            logger.error(f"Failed to create default config: {e}")
    
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
    
    def get_models_dir(self) -> str:
        """Get models directory path"""
        ml_config = self.get_ml_config()
        return ml_config.get("models_dir", "models/run_20250925_133309")
    
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
    
    def get_config_summary(self) -> Dict[str, Any]:
        """Get a summary of the current configuration"""
        return {
            "config_file": str(self.config_file),
            "server": self.get_server_config(),
            "ml": {
                "models_dir": self.get_models_dir(),
                "default_model": self.get_default_model(),
                "available_models": len(self.get_available_models()),
                "enabled_models": len(self.get_enabled_models())
            },
            "camera": self.get_camera_config(),
            "logging": self.get_logging_config(),
            "performance": self.get_performance_config()
        }
