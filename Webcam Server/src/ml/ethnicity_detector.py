#!/usr/bin/env python3
"""
ML Ethnicity Detector Implementation
Following SOLID principles with dependency injection and composition
"""

import numpy as np
import time
from typing import Tuple, Optional, Dict, Any, List
from .face_detector import IFaceDetector, FaceDetectorFactory
from .feature_extractors import IFeatureExtractor, FeatureExtractorFactory
from .model_manager import IModelManager, ModelManagerFactory
from ..core.logger import logger
from ..core.config_manager import ConfigManager


class MLEthnicityDetector:
    """
    Main ML Ethnicity Detector class
    Uses dependency injection and composition following SOLID principles
    """
    
    def __init__(
        self,
        face_detector: IFaceDetector,
        feature_extractors: Dict[str, IFeatureExtractor],
        model_manager: IModelManager,
        config_manager: ConfigManager
    ):
        self.face_detector = face_detector
        self.feature_extractors = feature_extractors
        self.model_manager = model_manager
        self.config_manager = config_manager
        self.models_dir = config_manager.get_models_dir()
        
        # Performance tracking
        self.detection_count = 0
        self.total_detection_time = 0.0
        self.last_detection_result: Optional[Tuple[str, float]] = None
        
        logger.info("ML Ethnicity Detector initialized")
    
    @classmethod
    def create_default_detector(cls, config_manager: Optional[ConfigManager] = None) -> 'MLEthnicityDetector':
        """Factory method to create detector with default components"""
        logger.info("Creating default ML Ethnicity Detector")
        
        # Create config manager if not provided
        if config_manager is None:
            config_manager = ConfigManager()
        
        # Create face detector
        face_detector = FaceDetectorFactory.create_detector("opencv")
        
        # Create feature extractors
        feature_extractors = FeatureExtractorFactory.create_combined_extractor(
            ['hog', 'glcm', 'lbp', 'hsv']
        )
        
        # Create model manager with config
        model_manager = ModelManagerFactory.create_manager("pickle", config_manager=config_manager)
        
        # Load models using config
        model_manager.load_models()
        
        return cls(face_detector, feature_extractors, model_manager, config_manager)
    
    def predict_ethnicity(self, image: np.ndarray, model_name: Optional[str] = None) -> Tuple[Optional[str], float]:
        """
        Predict ethnicity from image using specified model
        
        Args:
            image: Input image
            model_name: Name of the model to use for prediction (uses default from config if None)
            
        Returns:
            Tuple of (ethnicity, confidence) or (None, 0.0) if prediction fails
        """
        # Use default model from config if not specified
        if model_name is None:
            model_name = self.config_manager.get_default_model()
        
        start_time = time.time()
        
        try:
            # Step 1: Face detection
            face_coords = self.face_detector.detect_largest_face(image)
            if face_coords is None:
                logger.debug("No face detected in image")
                return None, 0.0
            
            # Extract face region
            face_image = self.face_detector.extract_face_region(image, face_coords)
            if face_image.size == 0:
                logger.warning("Failed to extract face region")
                return None, 0.0
            
            # Step 2: Feature extraction
            features = self._extract_combined_features(face_image, model_name)
            if len(features) == 0:
                logger.warning("Failed to extract features")
                return None, 0.0
            
            # Step 3: ML prediction
            ethnicity, confidence = self.model_manager.predict(model_name, features)
            
            # Update performance tracking
            detection_time = time.time() - start_time
            self._update_performance_stats(detection_time)
            
            # Store last result
            self.last_detection_result = (ethnicity, confidence)
            
            if ethnicity:
                logger.log_detection_result(ethnicity, confidence, model_name)
            
            return ethnicity, confidence
            
        except Exception as e:
            logger.error(f"Ethnicity prediction failed: {e}")
            return None, 0.0
    
    def _extract_combined_features(self, face_image: np.ndarray, model_name: str) -> np.ndarray:
        """Extract features based on model requirements"""
        try:
            features = []
            
            # Extract features based on model name
            if 'hog' in model_name and 'hog' in self.feature_extractors:
                hog_features = self.feature_extractors['hog'].extract(face_image)
                features.extend(hog_features)
                logger.debug(f"Extracted {len(hog_features)} HOG features")
            
            if 'glcm' in model_name and 'glcm' in self.feature_extractors:
                glcm_features = self.feature_extractors['glcm'].extract(face_image)
                features.extend(glcm_features)
                logger.debug(f"Extracted {len(glcm_features)} GLCM features")
            
            if 'lbp' in model_name and 'lbp' in self.feature_extractors:
                lbp_features = self.feature_extractors['lbp'].extract(face_image)
                features.extend(lbp_features)
                logger.debug(f"Extracted {len(lbp_features)} LBP features")
            
            if 'hsv' in model_name and 'hsv' in self.feature_extractors:
                hsv_features = self.feature_extractors['hsv'].extract(face_image)
                features.extend(hsv_features)
                logger.debug(f"Extracted {len(hsv_features)} HSV features")
            
            if not features:
                logger.warning(f"No features extracted for model {model_name}")
                return np.array([])
            
            return np.array(features, dtype=np.float32)
            
        except Exception as e:
            logger.error(f"Feature extraction failed: {e}")
            return np.array([])
    
    def _update_performance_stats(self, detection_time: float) -> None:
        """Update performance statistics"""
        self.detection_count += 1
        self.total_detection_time += detection_time
        
        # Log performance periodically
        if self.detection_count % 10 == 0:
            avg_time = self.total_detection_time / self.detection_count
            logger.log_performance("Ethnicity Detection", avg_time, count=self.detection_count)
    
    def get_available_models(self) -> List[str]:
        """Get list of available models"""
        return self.model_manager.get_available_models()
    
    def get_model_info(self, model_name: str) -> Dict[str, Any]:
        """Get information about a specific model"""
        return self.model_manager.get_model_info(model_name)
    
    def get_last_detection_result(self) -> Optional[Tuple[str, float]]:
        """Get the last detection result"""
        return self.last_detection_result
    
    def get_performance_stats(self) -> Dict[str, Any]:
        """Get performance statistics"""
        if self.detection_count == 0:
            return {
                'total_detections': 0,
                'average_time': 0.0,
                'total_time': 0.0
            }
        
        return {
            'total_detections': self.detection_count,
            'average_time': self.total_detection_time / self.detection_count,
            'total_time': self.total_detection_time
        }
    
    def reset_performance_stats(self) -> None:
        """Reset performance statistics"""
        self.detection_count = 0
        self.total_detection_time = 0.0
        logger.info("Performance statistics reset")
