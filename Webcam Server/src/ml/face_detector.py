#!/usr/bin/env python3
"""
Face Detection Interface and Implementation
Following SOLID principles with abstract interfaces
"""

import cv2
import numpy as np
from abc import ABC, abstractmethod
from typing import Tuple, Optional, List
from ..core.logger import logger


class IFaceDetector(ABC):
    """Abstract interface for face detection (Interface Segregation Principle)"""
    
    @abstractmethod
    def detect_faces(self, image: np.ndarray) -> List[Tuple[int, int, int, int]]:
        """Detect faces in image and return list of (x, y, w, h) coordinates"""
        pass
    
    @abstractmethod
    def detect_largest_face(self, image: np.ndarray) -> Optional[Tuple[int, int, int, int]]:
        """Detect the largest face in image and return (x, y, w, h) coordinates"""
        pass
    
    @abstractmethod
    def extract_face_region(self, image: np.ndarray, face_coords: Tuple[int, int, int, int]) -> np.ndarray:
        """Extract face region from image using coordinates"""
        pass


class OpenCVFaceDetector(IFaceDetector):
    """OpenCV-based face detector implementation"""
    
    def __init__(self, cascade_path: Optional[str] = None):
        """
        Initialize face detector with Haar cascade
        
        Args:
            cascade_path: Path to Haar cascade file. If None, uses default frontal face cascade.
        """
        if cascade_path is None:
            cascade_path = cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
        
        self.face_cascade = cv2.CascadeClassifier(cascade_path)
        
        if self.face_cascade.empty():
            raise ValueError(f"Failed to load cascade classifier from {cascade_path}")
        
        logger.info(f"OpenCV face detector initialized with cascade: {cascade_path}")
    
    def detect_faces(self, image: np.ndarray) -> List[Tuple[int, int, int, int]]:
        """Detect all faces in image"""
        try:
            # Convert to grayscale for face detection
            if len(image.shape) == 3:
                gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
            else:
                gray = image
            
            # Detect faces
            faces = self.face_cascade.detectMultiScale(
                gray,
                scaleFactor=1.1,
                minNeighbors=4,
                minSize=(30, 30),
                flags=cv2.CASCADE_SCALE_IMAGE
            )
            
            # Convert to list of tuples
            face_list = [(int(x), int(y), int(w), int(h)) for x, y, w, h in faces]
            
            logger.debug(f"Detected {len(face_list)} faces in image")
            return face_list
            
        except Exception as e:
            logger.error(f"Face detection failed: {e}")
            return []
    
    def detect_largest_face(self, image: np.ndarray) -> Optional[Tuple[int, int, int, int]]:
        """Detect the largest face in image"""
        faces = self.detect_faces(image)
        
        if not faces:
            logger.debug("No faces detected in image")
            return None
        
        # Find face with largest area
        largest_face = max(faces, key=lambda face: face[2] * face[3])
        
        logger.debug(f"Largest face detected: {largest_face}")
        return largest_face
    
    def extract_face_region(self, image: np.ndarray, face_coords: Tuple[int, int, int, int]) -> np.ndarray:
        """Extract face region from image"""
        try:
            x, y, w, h = face_coords
            
            # Ensure coordinates are within image bounds
            h_img, w_img = image.shape[:2]
            x = max(0, min(x, w_img - 1))
            y = max(0, min(y, h_img - 1))
            w = max(1, min(w, w_img - x))
            h = max(1, min(h, h_img - y))
            
            # Extract face region
            face_region = image[y:y+h, x:x+w]
            
            logger.debug(f"Extracted face region: {face_region.shape}")
            return face_region
            
        except Exception as e:
            logger.error(f"Face region extraction failed: {e}")
            return np.array([])


class FaceDetectorFactory:
    """Factory for creating face detectors"""
    
    @staticmethod
    def create_detector(detector_type: str = "opencv", **kwargs) -> IFaceDetector:
        """Create face detector based on type"""
        detectors = {
            'opencv': OpenCVFaceDetector
        }
        
        if detector_type.lower() not in detectors:
            raise ValueError(f"Unknown detector type: {detector_type}")
        
        detector_class = detectors[detector_type.lower()]
        logger.info(f"Creating {detector_type} face detector")
        
        return detector_class(**kwargs)
