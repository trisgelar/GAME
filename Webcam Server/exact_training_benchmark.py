#!/usr/bin/env python3
"""
Exact Training Parameters Video-Based Performance Benchmark
Uses the exact same feature extraction parameters as the training code
"""

import cv2
import numpy as np
import time
import json
import os
import pickle
from datetime import datetime
from pathlib import Path
import sys

def load_config():
    """Load configuration from config.json"""
    config_file = "config.json"
    if os.path.exists(config_file):
        with open(config_file, 'r') as f:
            return json.load(f)
    return {}

def load_models(models_dir):
    """Load ML models from pickle files"""
    models = {}
    
    if not os.path.exists(models_dir):
        print(f"Models directory not found: {models_dir}")
        return models
    
    model_files = {
        'glcm_hog': 'GLCM_HOG_model.pkl',
        'glcm_lbp_hog': 'GLCM_LBP_HOG_model.pkl', 
        'glcm_lbp_hog_hsv': 'GLCM_LBP_HOG_HSV_model.pkl',
        'hsv': 'HSV_model.pkl',
        'lbp_hog': 'LBP_HOG_model.pkl'
    }
    
    for model_name, filename in model_files.items():
        filepath = os.path.join(models_dir, filename)
        if os.path.exists(filepath):
            try:
                with open(filepath, 'rb') as f:
                    models[model_name] = pickle.load(f)
                print(f"Loaded {model_name} model")
            except Exception as e:
                print(f"Error loading {model_name}: {e}")
        else:
            print(f"Model file not found: {filepath}")
    
    return models

def shannon_entropy(P):
    """Calculate Shannon entropy"""
    # Remove zeros to avoid log(0)
    P = P[P > 0]
    return -np.sum(P * np.log2(P))

def extract_hog_features_exact(image):
    """Extract HOG features with exact training parameters"""
    try:
        from skimage.feature import hog
        
        # Convert to grayscale for HOG
        if len(image.shape) == 3:
            gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
        else:
            gray = image
        
        # Exact training parameters from HOGFeatureExtractor
        features = hog(gray, 
                      orientations=9,  # Default from training
                      pixels_per_cell=(8, 8),  # Default from training
                      cells_per_block=(2, 2),  # Default from training
                      block_norm='L2-Hys',
                      feature_vector=True,  # Important: feature_vector=True
                      channel_axis=None)
        
        return features
    except Exception as e:
        print(f"HOG extraction error: {e}")
        return None

def extract_glcm_features_exact(image):
    """Extract GLCM features with exact training parameters"""
    try:
        from skimage.feature import graycomatrix, graycoprops
        
        # Convert to grayscale
        if len(image.shape) == 3:
            gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
        else:
            gray = image
        
        # Resize to 256x256 if needed (training preprocessing)
        if gray.shape[0] > 256 or gray.shape[1] > 256:
            gray = cv2.resize(gray, (256, 256))
        
        # Exact training parameters from GLCFeatureExtractor
        distances = [1]  # Default from config
        angles = [0, 45, 90, 135]  # Default from config (in degrees)
        levels = 256  # Default from config
        
        # Convert angles to radians
        angles_rad = [np.radians(angle) for angle in angles]
        
        # Calculate GLCM
        glcm = graycomatrix(gray, 
                           distances=distances, 
                           angles=angles_rad,
                           levels=levels, 
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
            entropy_val = shannon_entropy(P_avg)
            entropy_features.append(entropy_val)
        
        # Combine all features
        all_features = np.concatenate([haralick_features, entropy_features])
        
        return all_features
    except Exception as e:
        print(f"GLCM extraction error: {e}")
        return None

def extract_lbp_features_exact(image):
    """Extract LBP features with exact training parameters"""
    try:
        from skimage.feature import local_binary_pattern
        
        # Convert to grayscale
        if len(image.shape) == 3:
            gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
        else:
            gray = image
        
        # Exact training parameters from LBPFeatureExtractor
        P = 8  # Default from training
        R = 1.0  # Default from training
        method = 'uniform'  # Default from training
        bins = P + 2  # Default from training (10 for uniform method)
        
        # Calculate LBP
        lbp = local_binary_pattern(gray, P, R, method=method)
        
        # Calculate histogram (exact from training)
        hist, _ = np.histogram(lbp.ravel(), bins=bins, range=(0, bins), density=True)
        
        return hist.astype(np.float32)
    except Exception as e:
        print(f"LBP extraction error: {e}")
        return None

def extract_hsv_features_exact(image):
    """Extract HSV features with exact training parameters"""
    try:
        # Convert to HSV
        hsv = cv2.cvtColor(image, cv2.COLOR_RGB2HSV)
        
        # Exact training parameters from ColorHistogramFeatureExtractor
        # Default config: color_bins=16, color_channels=[1,2] (S and V)
        bins = 16  # Default from config
        channels = [1, 2]  # S and V channels only
        
        features = []
        for channel in channels:
            hist = cv2.calcHist([hsv], [channel], None, [bins], [0, 256])
            hist = hist.flatten() / (hist.sum() + 1e-7)  # Normalize
            features.extend(hist)
        
        return np.array(features)
    except Exception as e:
        print(f"HSV extraction error: {e}")
        return None

def detect_faces(image):
    """Detect faces in image"""
    try:
        # Load Haar cascade
        cascade_path = cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
        face_cascade = cv2.CascadeClassifier(cascade_path)
        
        # Convert to grayscale
        gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
        
        # Detect faces
        faces = face_cascade.detectMultiScale(gray, 1.1, 4)
        
        return faces
    except Exception as e:
        print(f"Face detection error: {e}")
        return []

def extract_video_frames(video_path, max_frames=50):
    """Extract frames from video file"""
    frames = []
    
    if not os.path.exists(video_path):
        print(f"Video file not found: {video_path}")
        return frames
    
    print(f"Extracting frames from video: {video_path}")
    
    try:
        cap = cv2.VideoCapture(video_path)
        
        if not cap.isOpened():
            print(f"Could not open video file: {video_path}")
            return frames
        
        frame_count = 0
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        fps = cap.get(cv2.CAP_PROP_FPS)
        
        print(f"Video info: {total_frames} frames, {fps:.2f} FPS")
        
        # Extract frames evenly distributed throughout the video
        frame_interval = max(1, total_frames // max_frames)
        
        while frame_count < max_frames:
            ret, frame = cap.read()
            
            if not ret:
                break
            
            # Convert BGR to RGB
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            
            # Resize frame to 256x256 (training preprocessing)
            frame = cv2.resize(frame, (256, 256))
            frames.append(frame)
            frame_count += 1
            
            # Skip frames to get evenly distributed samples
            for _ in range(frame_interval - 1):
                cap.read()
        
        cap.release()
        print(f"Extracted {len(frames)} frames from video")
        
    except Exception as e:
        print(f"Error extracting video frames: {e}")
    
    return frames

def benchmark_feature_extraction(frames, feature_combinations):
    """Benchmark feature extraction performance"""
    results = {}
    
    print("Starting feature extraction benchmark with exact training parameters")
    
    # Expected feature counts from CSV
    expected_features = {
        'glcm+lbp': 30,
        'lbp+hog': 34606,
        'glcm+hog': 34616,
        'glcm+lbp+hog': 34626,
        'glcm+lbp+hog+hsv': 34658,  # Approximate
        'hsv': 32  # 16+16 for S and V channels
    }
    
    for combination in feature_combinations:
        print(f"Benchmarking feature extraction: {combination}")
        
        latencies = []
        successful_extractions = 0
        feature_counts = []
        
        for frame in frames:
            try:
                start_time = time.perf_counter()
                
                # Extract features based on combination using exact training parameters
                combined_features = []
                features = combination.split('+')
                
                for feature in features:
                    if feature == 'hog':
                        feat = extract_hog_features_exact(frame)
                    elif feature == 'glcm':
                        feat = extract_glcm_features_exact(frame)
                    elif feature == 'lbp':
                        feat = extract_lbp_features_exact(frame)
                    elif feature == 'hsv':
                        feat = extract_hsv_features_exact(frame)
                    else:
                        continue
                    
                    if feat is not None:
                        combined_features.extend(feat)
                
                if combined_features:
                    end_time = time.perf_counter()
                    latency_ms = (end_time - start_time) * 1000
                    latencies.append(latency_ms)
                    feature_counts.append(len(combined_features))
                    successful_extractions += 1
            
            except Exception as e:
                print(f"Feature extraction failed for {combination}: {e}")
                continue
        
        if latencies:
            avg_features = np.mean(feature_counts)
            expected = expected_features.get(combination, 0)
            
            results[combination] = {
                'feature_combination': combination,
                'avg_latency_ms': float(np.mean(latencies)),
                'std_latency_ms': float(np.std(latencies)),
                'min_latency_ms': float(np.min(latencies)),
                'max_latency_ms': float(np.max(latencies)),
                'fps': float(1000 / np.mean(latencies)),
                'sample_count': len(latencies),
                'successful_extractions': successful_extractions,
                'avg_features_extracted': float(avg_features),
                'expected_features': expected,
                'feature_match': abs(avg_features - expected) < 100  # Allow tolerance
            }
            
            print(f"Feature extraction benchmark completed: {results[combination]}")
        else:
            print(f"No successful extractions for {combination}")
    
    return results

def benchmark_model_prediction(frames, models):
    """Benchmark model prediction performance"""
    results = {}
    
    print("Starting model prediction benchmark with exact training parameters")
    
    for model_name, model in models.items():
        print(f"Benchmarking model prediction: {model_name}")
        
        latencies = []
        successful_predictions = 0
        predictions = []
        
        for frame in frames:
            try:
                # Detect faces first
                faces = detect_faces(frame)
                
                if len(faces) == 0:
                    continue
                
                # Use the first detected face
                x, y, w, h = faces[0]
                face_roi = frame[y:y+h, x:x+w]
                face_roi = cv2.resize(face_roi, (256, 256))  # Training preprocessing
                
                # Extract features based on model using exact training parameters
                features = []
                
                if 'hog' in model_name:
                    hog_feat = extract_hog_features_exact(face_roi)
                    if hog_feat is not None:
                        features.extend(hog_feat)
                
                if 'glcm' in model_name:
                    glcm_feat = extract_glcm_features_exact(face_roi)
                    if glcm_feat is not None:
                        features.extend(glcm_feat)
                
                if 'lbp' in model_name:
                    lbp_feat = extract_lbp_features_exact(face_roi)
                    if lbp_feat is not None:
                        features.extend(lbp_feat)
                
                if 'hsv' in model_name:
                    hsv_feat = extract_hsv_features_exact(face_roi)
                    if hsv_feat is not None:
                        features.extend(hsv_feat)
                
                if not features:
                    continue
                
                start_time = time.perf_counter()
                
                # Predict ethnicity
                features_array = np.array(features).reshape(1, -1)
                prediction = model.predict(features_array)[0]
                
                end_time = time.perf_counter()
                latency_ms = (end_time - start_time) * 1000
                
                latencies.append(latency_ms)
                predictions.append(prediction)
                successful_predictions += 1
            
            except Exception as e:
                print(f"Model prediction failed for {model_name}: {e}")
                continue
        
        if latencies:
            # Calculate prediction distribution
            unique_predictions, counts = np.unique(predictions, return_counts=True)
            prediction_dist = {int(k): int(v) for k, v in zip(unique_predictions, counts)}
            
            results[model_name] = {
                'model_name': model_name,
                'avg_latency_ms': float(np.mean(latencies)),
                'std_latency_ms': float(np.std(latencies)),
                'min_latency_ms': float(np.min(latencies)),
                'max_latency_ms': float(np.max(latencies)),
                'fps': float(1000 / np.mean(latencies)),
                'sample_count': len(latencies),
                'successful_predictions': successful_predictions,
                'prediction_distribution': prediction_dist
            }
            
            print(f"Model prediction benchmark completed: {results[model_name]}")
        else:
            print(f"No successful predictions for {model_name}")
    
    return results

def save_results(results, timestamp):
    """Save benchmark results to files"""
    print("Saving results...")
    
    # Create results directory
    results_dir = Path("performance") / f"exact_training_benchmark_{timestamp}"
    results_dir.mkdir(exist_ok=True)
    
    # Save detailed results as JSON
    json_file = results_dir / "detailed_results.json"
    with open(json_file, 'w') as f:
        json.dump(results, f, indent=2, default=str)
    
    # Save feature extraction performance
    feature_file = results_dir / "feature_extraction_performance.txt"
    with open(feature_file, 'w') as f:
        f.write("=== EXACT TRAINING PARAMETERS FEATURE EXTRACTION PERFORMANCE ===\n\n")
        
        for combination, data in results.get('feature_extraction', {}).items():
            f.write(f"{combination}:\n")
            f.write(f"  Average Latency: {data['avg_latency_ms']:.2f} ms\n")
            f.write(f"  Standard Deviation: {data['std_latency_ms']:.2f} ms\n")
            f.write(f"  Min Latency: {data['min_latency_ms']:.2f} ms\n")
            f.write(f"  Max Latency: {data['max_latency_ms']:.2f} ms\n")
            f.write(f"  FPS: {data['fps']:.2f}\n")
            f.write(f"  Successful Extractions: {data['successful_extractions']}\n")
            f.write(f"  Sample Count: {data['sample_count']}\n")
            f.write(f"  Avg Features Extracted: {data['avg_features_extracted']:.0f}\n")
            f.write(f"  Expected Features: {data['expected_features']}\n")
            f.write(f"  Feature Match: {data['feature_match']}\n\n")
    
    # Save model prediction performance
    model_file = results_dir / "model_prediction_performance.txt"
    with open(model_file, 'w') as f:
        f.write("=== EXACT TRAINING PARAMETERS MODEL PREDICTION PERFORMANCE ===\n\n")
        
        for model_name, data in results.get('model_prediction', {}).items():
            f.write(f"{model_name}:\n")
            f.write(f"  Average Latency: {data['avg_latency_ms']:.2f} ms\n")
            f.write(f"  Standard Deviation: {data['std_latency_ms']:.2f} ms\n")
            f.write(f"  Min Latency: {data['min_latency_ms']:.2f} ms\n")
            f.write(f"  Max Latency: {data['max_latency_ms']:.2f} ms\n")
            f.write(f"  FPS: {data['fps']:.2f}\n")
            f.write(f"  Successful Predictions: {data['successful_predictions']}\n")
            f.write(f"  Sample Count: {data['sample_count']}\n")
            f.write(f"  Prediction Distribution: {data['prediction_distribution']}\n\n")
    
    # Save performance summary
    summary_file = results_dir / "performance_summary.txt"
    with open(summary_file, 'w') as f:
        f.write("=" * 80 + "\n")
        f.write("EXACT TRAINING PARAMETERS VIDEO-BASED PERFORMANCE SUMMARY\n")
        f.write("=" * 80 + "\n\n")
        
        f.write(f"Timestamp: {results['timestamp']}\n")
        f.write(f"Video Path: {results['video_path']}\n")
        f.write(f"Frames Used: {results['frames_used']}\n\n")
        
        f.write("Feature Extraction Performance (Exact Training Parameters):\n")
        f.write("-" * 60 + "\n")
        for combination, data in results.get('feature_extraction', {}).items():
            match_status = "OK" if data['feature_match'] else "MISMATCH"
            f.write(f"{combination:20} : {data['avg_latency_ms']:6.2f} ms, {data['fps']:8.2f} FPS {match_status}\n")
        
        f.write("\nModel Prediction Performance (Exact Training Parameters):\n")
        f.write("-" * 60 + "\n")
        for model_name, data in results.get('model_prediction', {}).items():
            f.write(f"{model_name:20} : {data['avg_latency_ms']:6.2f} ms, {data['fps']:8.2f} FPS\n")
        
        f.write(f"\nSummary:\n")
        f.write(f"Total Feature Combinations: {results['summary']['total_feature_combinations']}\n")
        f.write(f"Total Models: {results['summary']['total_models']}\n")
        f.write(f"Successful Feature Tests: {results['summary']['successful_feature_tests']}\n")
        f.write(f"Successful Model Tests: {results['summary']['successful_model_tests']}\n")
    
    print(f"Results saved to: {results_dir}")
    return results_dir

def main():
    """Main function"""
    print("=== Exact Training Parameters Video-Based ML Performance Benchmark ===")
    
    # Load configuration
    config = load_config()
    models_dir = config.get('ml', {}).get('models_dir', 'models/run_20250925_133309')
    
    # Video path
    video_path = "performance/cropped_video_480x360.mp4"
    
    if not os.path.exists(video_path):
        print(f"ERROR: Video file not found: {video_path}")
        print("Please run video_crop.py first to create the cropped video.")
        return 1
    
    print(f"Using video: {video_path}")
    print(f"Models directory: {models_dir}")
    
    # Load models
    models = load_models(models_dir)
    if not models:
        print("ERROR: No models loaded")
        return 1
    
    print(f"Loaded {len(models)} models: {list(models.keys())}")
    
    # Extract frames from video
    frames = extract_video_frames(video_path, max_frames=50)
    
    if not frames:
        print("ERROR: No frames extracted from video")
        return 1
    
    print(f"Using {len(frames)} video frames for benchmarking")
    
    # Feature combinations to test
    feature_combinations = [
        'glcm+lbp',
        'lbp+hog', 
        'glcm+hog',
        'glcm+lbp+hog',
        'glcm+lbp+hog+hsv',
        'hsv'
    ]
    
    # Benchmark feature extraction
    feature_results = benchmark_feature_extraction(frames, feature_combinations)
    
    # Benchmark model prediction
    model_results = benchmark_model_prediction(frames, models)
    
    # Combine results
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    comprehensive_results = {
        'timestamp': timestamp,
        'video_path': video_path,
        'frames_used': len(frames),
        'feature_extraction': feature_results,
        'model_prediction': model_results,
        'summary': {
            'total_feature_combinations': len(feature_results),
            'total_models': len(model_results),
            'successful_feature_tests': len([r for r in feature_results.values() if r]),
            'successful_model_tests': len([r for r in model_results.values() if r])
        }
    }
    
    # Save results
    results_dir = save_results(comprehensive_results, timestamp)
    
    print(f"\nSUCCESS: Exact training parameters benchmark completed!")
    print(f"Results saved to: {results_dir}")
    print(f"Files created:")
    print(f"  - detailed_results.json")
    print(f"  - feature_extraction_performance.txt")
    print(f"  - model_prediction_performance.txt")
    print(f"  - performance_summary.txt")
    
    # Print summary
    print("\n" + "=" * 80)
    print("EXACT TRAINING PARAMETERS VIDEO-BASED PERFORMANCE SUMMARY")
    print("=" * 80)
    
    print(f"Video: {comprehensive_results['video_path']}")
    print(f"Frames Used: {comprehensive_results['frames_used']}")
    
    print("\nFeature Extraction Performance (Exact Training Parameters):")
    print("-" * 60)
    for combination, data in comprehensive_results.get('feature_extraction', {}).items():
        match_status = "OK" if data['feature_match'] else "MISMATCH"
        print(f"{combination:20} : {data['avg_latency_ms']:6.2f} ms, {data['fps']:8.2f} FPS {match_status}")
    
    print("\nModel Prediction Performance (Exact Training Parameters):")
    print("-" * 60)
    for model_name, data in comprehensive_results.get('model_prediction', {}).items():
        print(f"{model_name:20} : {data['avg_latency_ms']:6.2f} ms, {data['fps']:8.2f} FPS")
    
    return 0

if __name__ == "__main__":
    exit(main())
