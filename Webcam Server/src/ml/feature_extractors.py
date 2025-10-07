#!/usr/bin/env python3
"""
Feature Extractor Interfaces and Implementations
Following SOLID principles with abstract interfaces and concrete implementations
"""

import cv2
import numpy as np
from abc import ABC, abstractmethod
from typing import Tuple, Optional, Dict, Any
from ..core.logger import logger


class IFeatureExtractor(ABC):
    """Abstract interface for feature extractors (Interface Segregation Principle)"""
    
    @abstractmethod
    def extract(self, image: np.ndarray) -> np.ndarray:
        """Extract features from image"""
        pass
    
    @abstractmethod
    def get_feature_name(self) -> str:
        """Get the name of this feature extractor"""
        pass
    
    @abstractmethod
    def get_feature_dimensions(self) -> int:
        """Get the expected feature dimensions"""
        pass


class HOGFeatureExtractor(IFeatureExtractor):
    """HOG (Histogram of Oriented Gradients) feature extractor with exact training parameters"""
    
    def __init__(self, image_size: Tuple[int, int] = (64, 64)):
        self.image_size = image_size
        # Use exact training parameters from HOGFeatureExtractor
        self.hog = cv2.HOGDescriptor(
            (image_size[0], image_size[1]),  # winSize
            (16, 16),                        # blockSize
            (8, 8),                          # blockStride
            (8, 8),                          # cellSize
            9                                # nbins (orientations)
        )
        logger.info(f"HOG extractor initialized with image size {image_size} (exact training parameters)")
    
    def extract(self, image: np.ndarray) -> np.ndarray:
        """Extract HOG features from image"""
        try:
            # Resize image to standard size
            resized = cv2.resize(image, self.image_size)
            gray = cv2.cvtColor(resized, cv2.COLOR_BGR2GRAY)
            
            # Compute HOG features
            features = self.hog.compute(gray)
            if features is not None:
                return features.flatten()
            else:
                logger.warning("HOG computation returned None")
                return np.array([])
                
        except Exception as e:
            logger.error(f"HOG feature extraction failed: {e}")
            return np.array([])
    
    def get_feature_name(self) -> str:
        return "HOG"
    
    def get_feature_dimensions(self) -> int:
        # Calculate expected HOG dimensions
        win_size = self.image_size
        block_size = (16, 16)
        block_stride = (8, 8)
        cell_size = (8, 8)
        nbins = 9
        
        # Number of blocks in each dimension
        n_blocks_x = (win_size[0] - block_size[0]) // block_stride[0] + 1
        n_blocks_y = (win_size[1] - block_size[1]) // block_stride[1] + 1
        
        # Number of cells per block
        n_cells_per_block_x = block_size[0] // cell_size[0]
        n_cells_per_block_y = block_size[1] // cell_size[1]
        
        return n_blocks_x * n_blocks_y * n_cells_per_block_x * n_cells_per_block_y * nbins


class GLCMFeatureExtractor(IFeatureExtractor):
    """GLCM (Gray-Level Co-occurrence Matrix) feature extractor with exact training parameters"""
    
    def __init__(self, image_size: Tuple[int, int] = (64, 64)):
        self.image_size = image_size
        # Exact training parameters from GLCFeatureExtractor
        self.distances = [1]  # Default from config
        self.angles = [0, 45, 90, 135]  # Default from config (in degrees)
        self.levels = 256  # Default from config
        logger.info(f"GLCM extractor initialized with image size {image_size} (exact training parameters)")
    
    def extract(self, image: np.ndarray) -> np.ndarray:
        """Extract GLCM features from image using exact training parameters"""
        try:
            from skimage.feature import graycomatrix, graycoprops
            
            # Convert to grayscale
            if len(image.shape) == 3:
                gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
            else:
                gray = image
            
            # Resize to 256x256 if needed (training preprocessing)
            if gray.shape[0] > 256 or gray.shape[1] > 256:
                gray = cv2.resize(gray, (256, 256))
            
            # Convert angles to radians
            angles_rad = [np.radians(angle) for angle in self.angles]
            
            # Calculate GLCM
            glcm = graycomatrix(gray, 
                               distances=self.distances, 
                               angles=angles_rad,
                               levels=self.levels, 
                               symmetric=True, 
                               normed=True)
            
            # Extract Haralick features (exact from training)
            properties = ['contrast', 'homogeneity', 'correlation', 'energy']
            haralick_features = []
            
            for prop in properties:
                feature_values = graycoprops(glcm, prop).ravel()
                haralick_features.extend(feature_values)
            
            # Extract entropy for each angle (exact from training)
            entropy_features = []
            for j in range(len(angles_rad)):
                # Average GLCM across distances for angle j
                P_avg = np.mean(glcm[:, :, :, j], axis=2)
                entropy_val = self._shannon_entropy(P_avg)
                entropy_features.append(entropy_val)
            
            # Combine all features
            all_features = np.concatenate([haralick_features, entropy_features])
            
            return all_features.astype(np.float32)
            
        except Exception as e:
            logger.error(f"GLCM feature extraction failed: {e}")
            return np.array([])
    
    def _shannon_entropy(self, P):
        """Calculate Shannon entropy"""
        P = P[P > 0]
        return -np.sum(P * np.log2(P))
    
    def _extract_basic_texture_features(self, gray_image: np.ndarray) -> list:
        """Extract basic texture features as GLCM approximation"""
        features = []
        
        # Calculate gradients
        grad_x = cv2.Sobel(gray_image, cv2.CV_64F, 1, 0, ksize=3)
        grad_y = cv2.Sobel(gray_image, cv2.CV_64F, 0, 1, ksize=3)
        
        # Gradient magnitude and direction
        magnitude = np.sqrt(grad_x**2 + grad_y**2)
        direction = np.arctan2(grad_y, grad_x)
        
        # Statistical features
        features.extend([
            np.mean(magnitude),
            np.std(magnitude),
            np.mean(direction),
            np.std(direction),
            np.min(magnitude),
            np.max(magnitude),
            np.percentile(magnitude, 25),
            np.percentile(magnitude, 75),
            np.percentile(magnitude, 50)  # median
        ])
        
        # Local binary pattern approximation
        lbp_features = self._extract_lbp_approximation(gray_image)
        features.extend(lbp_features)
        
        return features
    
    def _extract_lbp_approximation(self, gray_image: np.ndarray) -> list:
        """Extract LBP-like features as approximation"""
        features = []
        
        # Calculate local differences
        h, w = gray_image.shape
        center = gray_image[1:h-1, 1:w-1]
        
        # 8-neighborhood differences
        neighbors = [
            gray_image[0:h-2, 1:w-1] - center,  # top
            gray_image[0:h-2, 2:w] - center,    # top-right
            gray_image[1:h-1, 2:w] - center,    # right
            gray_image[2:h, 2:w] - center,      # bottom-right
            gray_image[2:h, 1:w-1] - center,    # bottom
            gray_image[2:h, 0:w-2] - center,    # bottom-left
            gray_image[1:h-1, 0:w-2] - center,  # left
            gray_image[0:h-2, 0:w-2] - center   # top-left
        ]
        
        # Calculate LBP-like features
        for neighbor in neighbors:
            binary = (neighbor >= 0).astype(np.float32)
            features.extend([
                np.mean(binary),
                np.std(binary)
            ])
        
        return features
    
    def get_feature_name(self) -> str:
        return "GLCM"
    
    def get_feature_dimensions(self) -> int:
        # Basic features + LBP approximation
        return 9 + (8 * 2)  # 9 statistical + 8 neighbors * 2 features each


class LBPFeatureExtractor(IFeatureExtractor):
    """LBP (Local Binary Pattern) feature extractor with exact training parameters"""
    
    def __init__(self, image_size: Tuple[int, int] = (64, 64), radius: int = 1, n_points: int = 8):
        self.image_size = image_size
        # Exact training parameters from LBPFeatureExtractor
        self.radius = 1  # Default from training
        self.n_points = 8  # Default from training
        self.method = 'uniform'  # Default from training
        self.bins = self.n_points + 2  # Default from training (10 for uniform method)
        logger.info(f"LBP extractor initialized with image size {image_size} (exact training parameters)")
    
    def extract(self, image: np.ndarray) -> np.ndarray:
        """Extract LBP features from image using exact training parameters"""
        try:
            from skimage.feature import local_binary_pattern
            
            # Convert to grayscale
            if len(image.shape) == 3:
                gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
            else:
                gray = image
            
            # Calculate LBP using exact training parameters
            lbp = local_binary_pattern(gray, self.n_points, self.radius, method=self.method)
            
            # Calculate histogram using exact training parameters
            hist, _ = np.histogram(lbp.ravel(), bins=self.bins, range=(0, self.bins), density=True)
            
            return hist.astype(np.float32)
            
        except Exception as e:
            logger.error(f"LBP feature extraction failed: {e}")
            return np.array([])
    
    def _calculate_lbp(self, gray_image: np.ndarray) -> np.ndarray:
        """Calculate Local Binary Pattern"""
        h, w = gray_image.shape
        lbp = np.zeros_like(gray_image)
        
        # Define circular neighborhood
        angles = np.linspace(0, 2 * np.pi, self.n_points, endpoint=False)
        offsets = []
        
        for angle in angles:
            x_offset = int(self.radius * np.cos(angle))
            y_offset = int(self.radius * np.sin(angle))
            offsets.append((x_offset, y_offset))
        
        # Calculate LBP for each pixel
        for y in range(self.radius, h - self.radius):
            for x in range(self.radius, w - self.radius):
                center_value = gray_image[y, x]
                binary_string = ""
                
                for dx, dy in offsets:
                    neighbor_value = gray_image[y + dy, x + dx]
                    binary_string += "1" if neighbor_value >= center_value else "0"
                
                # Convert binary string to decimal
                lbp[y, x] = int(binary_string, 2)
        
        return lbp
    
    def get_feature_name(self) -> str:
        return "LBP"
    
    def get_feature_dimensions(self) -> int:
        return 256  # Histogram bins


class HSVFeatureExtractor(IFeatureExtractor):
    """HSV (Hue-Saturation-Value) color feature extractor with exact training parameters"""
    
    def __init__(self, h_bins: int = 50, s_bins: int = 60, v_bins: int = 60):
        # Exact training parameters from ColorHistogramFeatureExtractor
        self.h_bins = 50  # Default from config
        self.s_bins = 60  # Default from config  
        self.v_bins = 60  # Default from config
        self.h_ranges = [0, 180]  # OpenCV uses 0-180 for hue
        self.s_ranges = [0, 256]
        self.v_ranges = [0, 256]
        # Training uses only S and V channels
        self.channels = [1, 2]  # S and V channels only
        logger.info(f"HSV extractor initialized with bins H:{self.h_bins}, S:{self.s_bins}, V:{self.v_bins} (exact training parameters)")
    
    def extract(self, image: np.ndarray) -> np.ndarray:
        """Extract HSV color features from image using exact training parameters"""
        try:
            # Convert BGR to HSV
            hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
            
            # Calculate histograms only for S and V channels (exact training parameters)
            features = []
            for channel in self.channels:
                if channel == 1:  # S channel
                    hist = cv2.calcHist([hsv], [channel], None, [self.s_bins], self.s_ranges)
                elif channel == 2:  # V channel
                    hist = cv2.calcHist([hsv], [channel], None, [self.v_bins], self.v_ranges)
                
                # Normalize histogram
                hist = hist.flatten() / (hist.sum() + 1e-7)
                features.extend(hist)
            
            return np.array(features, dtype=np.float32)
            
        except Exception as e:
            logger.error(f"HSV feature extraction failed: {e}")
            return np.array([])
    
    def get_feature_name(self) -> str:
        return "HSV"
    
    def get_feature_dimensions(self) -> int:
        # Only S and V channels (exact training parameters)
        return self.s_bins + self.v_bins


class FeatureExtractorFactory:
    """Factory for creating feature extractors (Factory Pattern)"""
    
    @staticmethod
    def create_extractor(extractor_type: str, **kwargs) -> IFeatureExtractor:
        """Create feature extractor based on type"""
        extractors = {
            'hog': HOGFeatureExtractor,
            'glcm': GLCMFeatureExtractor,
            'lbp': LBPFeatureExtractor,
            'hsv': HSVFeatureExtractor
        }
        
        if extractor_type.lower() not in extractors:
            raise ValueError(f"Unknown extractor type: {extractor_type}")
        
        extractor_class = extractors[extractor_type.lower()]
        logger.info(f"Creating {extractor_type} feature extractor")
        
        return extractor_class(**kwargs)
    
    @staticmethod
    def create_combined_extractor(extractor_types: list, **kwargs) -> Dict[str, IFeatureExtractor]:
        """Create multiple feature extractors"""
        extractors = {}
        for extractor_type in extractor_types:
            extractors[extractor_type] = FeatureExtractorFactory.create_extractor(extractor_type, **kwargs)
        
        logger.info(f"Created combined extractors: {list(extractors.keys())}")
        return extractors
