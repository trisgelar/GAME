#!/usr/bin/env python3
"""
Test script for ML Webcam Server
Tests the ML ethnicity detection functionality
"""

import cv2
import numpy as np
import time
from ml_webcam_server import MLEthnicityDetector

def test_ml_detector():
    """Test the ML ethnicity detector with sample images"""
    print("=== Testing ML Ethnicity Detector ===")
    
    # Initialize detector
    detector = MLEthnicityDetector()
    
    if not detector.models:
        print("❌ No models loaded! Please check model files.")
        return False
    
    print(f"✅ Loaded {len(detector.models)} models:")
    for model_name in detector.models.keys():
        print(f"  - {model_name}")
    
    # Test with webcam or sample image
    print("\n🎥 Testing with webcam...")
    cap = cv2.VideoCapture(0)
    
    if not cap.isOpened():
        print("❌ Could not open webcam")
        return False
    
    print("✅ Webcam opened. Press 'q' to quit, 's' to save test image")
    
    frame_count = 0
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        
        frame_count += 1
        
        # Test detection every 30 frames
        if frame_count % 30 == 0:
            print(f"\n🧠 Testing detection (frame {frame_count})...")
            
            # Test each available model
            for model_name in detector.models.keys():
                ethnicity, confidence = detector.predict_ethnicity(frame, model_name)
                if ethnicity:
                    print(f"  {model_name}: {ethnicity} (confidence: {confidence:.2f})")
                else:
                    print(f"  {model_name}: No face detected")
        
        # Display frame
        cv2.imshow('ML Test', frame)
        
        key = cv2.waitKey(1) & 0xFF
        if key == ord('q'):
            break
        elif key == ord('s'):
            # Save test image
            cv2.imwrite('test_image.jpg', frame)
            print("💾 Test image saved as 'test_image.jpg'")
    
    cap.release()
    cv2.destroyAllWindows()
    return True

def test_feature_extraction():
    """Test individual feature extraction methods"""
    print("\n=== Testing Feature Extraction ===")
    
    detector = MLEthnicityDetector()
    
    # Create a sample image
    sample_image = np.random.randint(0, 255, (480, 640, 3), dtype=np.uint8)
    
    print("Testing HOG features...")
    try:
        hog_features = detector.extract_hog_features(sample_image)
        print(f"✅ HOG features: {len(hog_features)} dimensions")
    except Exception as e:
        print(f"❌ HOG extraction failed: {e}")
    
    print("Testing GLCM features...")
    try:
        glcm_features = detector.extract_glcm_features(sample_image)
        print(f"✅ GLCM features: {len(glcm_features)} dimensions")
    except Exception as e:
        print(f"❌ GLCM extraction failed: {e}")
    
    print("Testing LBP features...")
    try:
        lbp_features = detector.extract_lbp_features(sample_image)
        print(f"✅ LBP features: {len(lbp_features)} dimensions")
    except Exception as e:
        print(f"❌ LBP extraction failed: {e}")
    
    print("Testing HSV features...")
    try:
        hsv_features = detector.extract_hsv_features(sample_image)
        print(f"✅ HSV features: {len(hsv_features)} dimensions")
    except Exception as e:
        print(f"❌ HSV extraction failed: {e}")

def test_face_detection():
    """Test face detection functionality"""
    print("\n=== Testing Face Detection ===")
    
    detector = MLEthnicityDetector()
    
    # Test with webcam
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        print("❌ Could not open webcam for face detection test")
        return False
    
    print("✅ Testing face detection. Press 'q' to quit")
    
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        
        # Detect face
        face_image, face_coords = detector.detect_face(frame)
        
        if face_image is not None:
            x, y, w, h = face_coords
            cv2.rectangle(frame, (x, y), (x+w, y+h), (0, 255, 0), 2)
            cv2.putText(frame, "Face Detected", (x, y-10), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
        else:
            cv2.putText(frame, "No Face", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)
        
        cv2.imshow('Face Detection Test', frame)
        
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    
    cap.release()
    cv2.destroyAllWindows()
    return True

if __name__ == "__main__":
    print("🧪 ML Webcam Server Test Suite")
    print("=" * 50)
    
    # Test 1: Feature extraction
    test_feature_extraction()
    
    # Test 2: Face detection
    test_face_detection()
    
    # Test 3: Full ML detection
    test_ml_detector()
    
    print("\n✅ All tests completed!")
    print("\nTo run the full ML server:")
    print("python ml_webcam_server.py")
