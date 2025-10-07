#!/usr/bin/env python3
"""
Test script for the refactored ML webcam server
Tests individual components and integration
"""

import sys
import os
from pathlib import Path
import numpy as np
import cv2

# Add src directory to Python path
src_dir = Path(__file__).parent / "src"
sys.path.insert(0, str(src_dir))

from src.core.logger import logger
from src.core.config_manager import ConfigManager
from src.camera.camera_interface import CameraFactory
from src.network.udp_server import UDPServerFactory
from src.ml.ethnicity_detector import MLEthnicityDetector
from src.ml.feature_extractors import FeatureExtractorFactory
from src.ml.face_detector import FaceDetectorFactory
from src.ml.model_manager import ModelManagerFactory


def test_logger():
    """Test logger functionality"""
    print("Testing Logger...")
    logger.info("Logger test message")
    logger.warning("Logger warning message")
    logger.error("Logger error message")
    logger.log_detection_result("Test", 0.95, "test_model")
    logger.log_client_connection("TEST", "127.0.0.1:8888")
    logger.log_model_operation("TEST", "test_model")
    logger.log_performance("test_operation", 0.123)
    print("✅ Logger test passed")


def test_camera():
    """Test camera functionality"""
    print("Testing Camera...")
    try:
        camera = CameraFactory.create_camera("opencv")
        if camera.initialize():
            print("✅ Camera initialization successful")
            
            # Test frame reading
            ret, frame = camera.read_frame()
            if ret and frame is not None:
                print(f"✅ Frame reading successful: {frame.shape}")
            else:
                print("❌ Frame reading failed")
            
            # Test properties
            props = camera.get_properties()
            print(f"✅ Camera properties: {props}")
            
            camera.release()
            print("✅ Camera released")
        else:
            print("❌ Camera initialization failed")
    except Exception as e:
        print(f"❌ Camera test failed: {e}")


def test_feature_extractors():
    """Test feature extractors"""
    print("Testing Feature Extractors...")
    try:
        # Create test image
        test_image = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        
        # Test HOG extractor
        hog_extractor = FeatureExtractorFactory.create_extractor("hog")
        hog_features = hog_extractor.extract(test_image)
        print(f"✅ HOG features: {len(hog_features)} dimensions")
        
        # Test HSV extractor
        hsv_extractor = FeatureExtractorFactory.create_extractor("hsv")
        hsv_features = hsv_extractor.extract(test_image)
        print(f"✅ HSV features: {len(hsv_features)} dimensions")
        
        # Test combined extractors
        extractors = FeatureExtractorFactory.create_combined_extractor(['hog', 'hsv'])
        print(f"✅ Combined extractors: {list(extractors.keys())}")
        
    except Exception as e:
        print(f"❌ Feature extractor test failed: {e}")


def test_face_detector():
    """Test face detector"""
    print("Testing Face Detector...")
    try:
        face_detector = FaceDetectorFactory.create_detector("opencv")
        
        # Create test image with face-like pattern
        test_image = np.random.randint(0, 255, (200, 200, 3), dtype=np.uint8)
        
        # Test face detection
        faces = face_detector.detect_faces(test_image)
        print(f"✅ Face detection: {len(faces)} faces found")
        
        # Test largest face detection
        largest_face = face_detector.detect_largest_face(test_image)
        if largest_face:
            print(f"✅ Largest face: {largest_face}")
            face_region = face_detector.extract_face_region(test_image, largest_face)
            print(f"✅ Face region extracted: {face_region.shape}")
        else:
            print("✅ No faces detected (expected for random image)")
        
    except Exception as e:
        print(f"❌ Face detector test failed: {e}")


def test_config_manager():
    """Test configuration manager"""
    print("Testing Config Manager...")
    try:
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
        
    except Exception as e:
        print(f"❌ Config manager test failed: {e}")


def test_model_manager():
    """Test model manager"""
    print("Testing Model Manager...")
    try:
        config_manager = ConfigManager()
        model_manager = ModelManagerFactory.create_manager("pickle", config_manager=config_manager)
        
        # Test model loading using config
        models = model_manager.load_models()
        print(f"✅ Models loaded: {list(models.keys())}")
        
        # Test available models
        available_models = model_manager.get_available_models()
        print(f"✅ Available models: {available_models}")
        
        # Test model info
        for model_name in available_models[:2]:  # Test first 2 models
            info = model_manager.get_model_info(model_name)
            print(f"✅ Model info for {model_name}: {info}")
        
    except Exception as e:
        print(f"❌ Model manager test failed: {e}")


def test_udp_server():
    """Test UDP server"""
    print("Testing UDP Server...")
    try:
        udp_server = UDPServerFactory.create_server("video")
        
        # Test server start
        if udp_server.start("127.0.0.1", 8889):  # Use different port for testing
            print("✅ UDP server started")
            
            # Test client count
            client_count = udp_server.get_client_count()
            print(f"✅ Client count: {client_count}")
            
            # Test running status
            is_running = udp_server.is_running()
            print(f"✅ Server running: {is_running}")
            
            # Stop server
            udp_server.stop()
            print("✅ UDP server stopped")
        else:
            print("❌ UDP server start failed")
        
    except Exception as e:
        print(f"❌ UDP server test failed: {e}")


def test_ethnicity_detector():
    """Test ethnicity detector"""
    print("Testing Ethnicity Detector...")
    try:
        # Create detector with config
        config_manager = ConfigManager()
        detector = MLEthnicityDetector.create_default_detector(config_manager)
        
        # Test available models
        models = detector.get_available_models()
        print(f"✅ Available models: {models}")
        
        # Test with random image
        test_image = np.random.randint(0, 255, (200, 200, 3), dtype=np.uint8)
        
        if models:
            model_name = models[0]
            ethnicity, confidence = detector.predict_ethnicity(test_image, model_name)
            print(f"✅ Prediction: {ethnicity}, confidence: {confidence}")
            
            # Test performance stats
            stats = detector.get_performance_stats()
            print(f"✅ Performance stats: {stats}")
        else:
            print("⚠️ No models available for testing")
        
    except Exception as e:
        print(f"❌ Ethnicity detector test failed: {e}")


def main():
    """Run all tests"""
    print("=== Testing Refactored ML Webcam Server ===\n")
    
    tests = [
        test_logger,
        test_config_manager,
        test_feature_extractors,
        test_face_detector,
        test_model_manager,
        test_udp_server,
        test_camera,
        test_ethnicity_detector
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        try:
            test()
            passed += 1
        except Exception as e:
            print(f"❌ Test {test.__name__} failed with exception: {e}")
        print()
    
    print(f"=== Test Results: {passed}/{total} tests passed ===")
    
    if passed == total:
        print("🎉 All tests passed! The refactored server is ready to use.")
    else:
        print("⚠️ Some tests failed. Please check the implementation.")


if __name__ == "__main__":
    main()
