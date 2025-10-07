#!/usr/bin/env python3
"""
Camera Interface and Implementation
Following SOLID principles with abstract interfaces
"""

import cv2
import numpy as np
from abc import ABC, abstractmethod
from typing import Tuple, Optional, Dict, Any
from ..core.logger import logger


class ICamera(ABC):
    """Abstract interface for camera operations (Interface Segregation Principle)"""
    
    @abstractmethod
    def initialize(self) -> bool:
        """Initialize camera"""
        pass
    
    @abstractmethod
    def read_frame(self) -> Tuple[bool, Optional[np.ndarray]]:
        """Read a frame from camera"""
        pass
    
    @abstractmethod
    def set_resolution(self, width: int, height: int) -> bool:
        """Set camera resolution"""
        pass
    
    @abstractmethod
    def set_fps(self, fps: int) -> bool:
        """Set camera FPS"""
        pass
    
    @abstractmethod
    def release(self) -> None:
        """Release camera resources"""
        pass
    
    @abstractmethod
    def is_opened(self) -> bool:
        """Check if camera is opened"""
        pass
    
    @abstractmethod
    def get_properties(self) -> Dict[str, Any]:
        """Get camera properties"""
        pass


class OpenCVCamera(ICamera):
    """OpenCV-based camera implementation"""
    
    def __init__(self, camera_id: int = 0, backend: int = cv2.CAP_DSHOW):
        self.camera_id = camera_id
        self.backend = backend
        self.camera: Optional[cv2.VideoCapture] = None
        self.width = 480
        self.height = 360
        self.fps = 15
        self.buffer_size = 1
        logger.info(f"OpenCV camera initialized with ID {camera_id}, backend {backend}")
    
    def initialize(self) -> bool:
        """Initialize camera"""
        try:
            self.camera = cv2.VideoCapture(self.camera_id, self.backend)
            
            if not self.camera.isOpened():
                logger.error(f"Failed to open camera {self.camera_id}")
                return False
            
            # Set camera properties
            self.camera.set(cv2.CAP_PROP_FRAME_WIDTH, self.width)
            self.camera.set(cv2.CAP_PROP_FRAME_HEIGHT, self.height)
            self.camera.set(cv2.CAP_PROP_FPS, self.fps)
            self.camera.set(cv2.CAP_PROP_BUFFERSIZE, self.buffer_size)
            
            # Test camera by reading a frame
            ret, frame = self.camera.read()
            if ret and frame is not None:
                actual_width = int(self.camera.get(cv2.CAP_PROP_FRAME_WIDTH))
                actual_height = int(self.camera.get(cv2.CAP_PROP_FRAME_HEIGHT))
                actual_fps = self.camera.get(cv2.CAP_PROP_FPS)
                
                logger.info(f"Camera initialized successfully: {actual_width}x{actual_height} @ {actual_fps}FPS")
                return True
            else:
                logger.error("Failed to read test frame from camera")
                return False
                
        except Exception as e:
            logger.error(f"Camera initialization failed: {e}")
            return False
    
    def read_frame(self) -> Tuple[bool, Optional[np.ndarray]]:
        """Read a frame from camera"""
        if self.camera is None:
            logger.error("Camera not initialized")
            return False, None
        
        try:
            ret, frame = self.camera.read()
            if not ret or frame is None:
                logger.warning("Failed to read frame from camera")
                return False, None
            
            return True, frame
            
        except Exception as e:
            logger.error(f"Frame reading failed: {e}")
            return False, None
    
    def set_resolution(self, width: int, height: int) -> bool:
        """Set camera resolution"""
        if self.camera is None:
            logger.error("Camera not initialized")
            return False
        
        try:
            self.camera.set(cv2.CAP_PROP_FRAME_WIDTH, width)
            self.camera.set(cv2.CAP_PROP_FRAME_HEIGHT, height)
            
            # Verify resolution
            actual_width = int(self.camera.get(cv2.CAP_PROP_FRAME_WIDTH))
            actual_height = int(self.camera.get(cv2.CAP_PROP_FRAME_HEIGHT))
            
            if actual_width == width and actual_height == height:
                self.width = width
                self.height = height
                logger.info(f"Camera resolution set to {width}x{height}")
                return True
            else:
                logger.warning(f"Resolution not set correctly. Expected: {width}x{height}, Actual: {actual_width}x{actual_height}")
                return False
                
        except Exception as e:
            logger.error(f"Failed to set resolution: {e}")
            return False
    
    def set_fps(self, fps: int) -> bool:
        """Set camera FPS"""
        if self.camera is None:
            logger.error("Camera not initialized")
            return False
        
        try:
            self.camera.set(cv2.CAP_PROP_FPS, fps)
            actual_fps = self.camera.get(cv2.CAP_PROP_FPS)
            
            if abs(actual_fps - fps) < 1.0:  # Allow small tolerance
                self.fps = fps
                logger.info(f"Camera FPS set to {fps}")
                return True
            else:
                logger.warning(f"FPS not set correctly. Expected: {fps}, Actual: {actual_fps}")
                return False
                
        except Exception as e:
            logger.error(f"Failed to set FPS: {e}")
            return False
    
    def release(self) -> None:
        """Release camera resources"""
        if self.camera is not None:
            self.camera.release()
            self.camera = None
            logger.info("Camera released")
    
    def is_opened(self) -> bool:
        """Check if camera is opened"""
        return self.camera is not None and self.camera.isOpened()
    
    def get_properties(self) -> Dict[str, Any]:
        """Get camera properties"""
        if self.camera is None:
            return {}
        
        try:
            return {
                'width': int(self.camera.get(cv2.CAP_PROP_FRAME_WIDTH)),
                'height': int(self.camera.get(cv2.CAP_PROP_FRAME_HEIGHT)),
                'fps': self.camera.get(cv2.CAP_PROP_FPS),
                'buffer_size': int(self.camera.get(cv2.CAP_PROP_BUFFERSIZE)),
                'brightness': self.camera.get(cv2.CAP_PROP_BRIGHTNESS),
                'contrast': self.camera.get(cv2.CAP_PROP_CONTRAST),
                'saturation': self.camera.get(cv2.CAP_PROP_SATURATION)
            }
        except Exception as e:
            logger.error(f"Failed to get camera properties: {e}")
            return {}


class CameraFactory:
    """Factory for creating cameras"""
    
    @staticmethod
    def create_camera(camera_type: str = "opencv", **kwargs) -> ICamera:
        """Create camera based on type"""
        cameras = {
            'opencv': OpenCVCamera
        }
        
        if camera_type.lower() not in cameras:
            raise ValueError(f"Unknown camera type: {camera_type}")
        
        camera_class = cameras[camera_type.lower()]
        logger.info(f"Creating {camera_type} camera")
        
        return camera_class(**kwargs)
