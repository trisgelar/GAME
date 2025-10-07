#!/usr/bin/env python3
"""
Corrected Video-Based Performance Benchmark
Benchmarks ML ethnicity detection performance using real video frames
with correct feature dimensions matching the trained models
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
        'hsv': 'HSV_model.pkl'
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

def extract_hog_features(image):
    """Extract HOG features with correct parameters"""
    try:
        from skimage.feature import hog
        
        # Convert to grayscale for HOG
        if len(image.shape) == 3:
            gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
        else:
            gray = image
        
        # HOG parameters to match training (64x64 image)
        features = hog(gray, 
                      orientations=9, 
                      pixels_per_cell=(8, 8),
                      cells_per_block=(2, 2), 
                      block_norm='L2-Hys',
                      visualize=False,
                      channel_axis=None)  # Fixed: use channel_axis instead of multichannel
        
        return features
    except Exception as e:
        print(f"HOG extraction error: {e}")
        return None

def extract_glcm_features(image):
    """Extract GLCM features with correct parameters"""
    try:
        from skimage.feature import graycomatrix, graycoprops
        from skimage.color import rgb2gray
        
        # Convert to grayscale
        if len(image.shape) == 3:
            gray = rgb2gray(image)
        else:
            gray = image
        
        gray = (gray * 255).astype(np.uint8)
        
        # Calculate GLCM with multiple distances and angles
        distances = [1, 2, 3, 4, 5]
        angles = [0, 45, 90, 135]
        
        glcm = graycomatrix(gray, distances=distances, angles=angles,
                           levels=256, symmetric=True, normed=True)
        
        # Extract properties
        contrast = graycoprops(glcm, 'contrast').ravel()
        dissimilarity = graycoprops(glcm, 'dissimilarity').ravel()
        homogeneity = graycoprops(glcm, 'homogeneity').ravel()
        energy = graycoprops(glcm, 'energy').ravel()
        correlation = graycoprops(glcm, 'correlation').ravel()
        
        features = np.concatenate([contrast, dissimilarity, homogeneity, energy, correlation])
        return features
    except Exception as e:
        print(f"GLCM extraction error: {e}")
        return None

def extract_lbp_features(image):
    """Extract LBP features with correct parameters"""
    try:
        from skimage.feature import local_binary_pattern
        from skimage.color import rgb2gray
        
        # Convert to grayscale
        if len(image.shape) == 3:
            gray = rgb2gray(image)
        else:
            gray = image
        
        gray = (gray * 255).astype(np.uint8)
        
        # LBP parameters
        radius = 1
        n_points = 8 * radius
        lbp = local_binary_pattern(gray, n_points, radius, method='uniform')
        
        # Calculate histogram
        hist, _ = np.histogram(lbp.ravel(), bins=n_points + 2, range=(0, n_points + 2))
        hist = hist.astype(float)
        hist /= (hist.sum() + 1e-7)  # Normalize
        
        return hist
    except Exception as e:
        print(f"LBP extraction error: {e}")
        return None

def extract_hsv_features(image):
    """Extract HSV features with correct parameters"""
    try:
        # Convert to HSV
        hsv = cv2.cvtColor(image, cv2.COLOR_RGB2HSV)
        
        # Calculate histograms with correct bins to match training
        h_hist = cv2.calcHist([hsv], [0], None, [50], [0, 180])
        s_hist = cv2.calcHist([hsv], [1], None, [60], [0, 256])
        v_hist = cv2.calcHist([hsv], [2], None, [60], [0, 256])
        
        # Normalize histograms
        h_hist = h_hist.flatten() / (h_hist.sum() + 1e-7)
        s_hist = s_hist.flatten() / (s_hist.sum() + 1e-7)
        v_hist = v_hist.flatten() / (v_hist.sum() + 1e-7)
        
        features = np.concatenate([h_hist, s_hist, v_hist])
        return features
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
            
            # Resize frame to standard size (64x64 for feature extraction)
            frame = cv2.resize(frame, (64, 64))
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
    
    print("Starting feature extraction benchmark with video frames")
    
    # Expected feature counts from CSV
    expected_features = {
        'glcm+lbp': 30,
        'lbp+hog': 34606,
        'glcm+hog': 34616,
        'glcm+lbp+hog': 34626,
        'glcm+lbp+hog+hsv': 34658,  # Approximate
        'hsv': 170  # 50+60+60
    }
    
    for combination in feature_combinations:
        print(f"Benchmarking feature extraction: {combination}")
        
        latencies = []
        successful_extractions = 0
        feature_counts = []
        
        for frame in frames:
            try:
                start_time = time.perf_counter()
                
                # Extract features based on combination
                combined_features = []
                features = combination.split('+')
                
                for feature in features:
                    if feature == 'hog':
                        feat = extract_hog_features(frame)
                    elif feature == 'glcm':
                        feat = extract_glcm_features(frame)
                    elif feature == 'lbp':
                        feat = extract_lbp_features(frame)
                    elif feature == 'hsv':
                        feat = extract_hsv_features(frame)
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
                'avg_latency_ms': np.mean(latencies),
                'std_latency_ms': np.std(latencies),
                'min_latency_ms': np.min(latencies),
                'max_latency_ms': np.max(latencies),
                'fps': 1000 / np.mean(latencies),
                'sample_count': len(latencies),
                'successful_extractions': successful_extractions,
                'avg_features_extracted': avg_features,
                'expected_features': expected,
                'feature_match': abs(avg_features - expected) < 100  # Allow some tolerance
            }
            
            print(f"Feature extraction benchmark completed: {results[combination]}")
        else:
            print(f"No successful extractions for {combination}")
    
    return results

def benchmark_model_prediction(frames, models):
    """Benchmark model prediction performance"""
    results = {}
    
    print("Starting model prediction benchmark with video frames")
    
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
                face_roi = cv2.resize(face_roi, (64, 64))
                
                # Extract features based on model
                features = []
                
                if 'hog' in model_name:
                    hog_feat = extract_hog_features(face_roi)
                    if hog_feat is not None:
                        features.extend(hog_feat)
                
                if 'glcm' in model_name:
                    glcm_feat = extract_glcm_features(face_roi)
                    if glcm_feat is not None:
                        features.extend(glcm_feat)
                
                if 'lbp' in model_name:
                    lbp_feat = extract_lbp_features(face_roi)
                    if lbp_feat is not None:
                        features.extend(lbp_feat)
                
                if 'hsv' in model_name:
                    hsv_feat = extract_hsv_features(face_roi)
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
            prediction_dist = dict(zip(unique_predictions, counts))
            
            results[model_name] = {
                'model_name': model_name,
                'avg_latency_ms': np.mean(latencies),
                'std_latency_ms': np.std(latencies),
                'min_latency_ms': np.min(latencies),
                'max_latency_ms': np.max(latencies),
                'fps': 1000 / np.mean(latencies),
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
    results_dir = Path("performance") / f"corrected_video_benchmark_{timestamp}"
    results_dir.mkdir(exist_ok=True)
    
    # Save detailed results as JSON
    json_file = results_dir / "detailed_results.json"
    with open(json_file, 'w') as f:
        json.dump(results, f, indent=2, default=str)
    
    # Save feature extraction performance
    feature_file = results_dir / "feature_extraction_performance.txt"
    with open(feature_file, 'w') as f:
        f.write("=== FEATURE EXTRACTION PERFORMANCE ===\n\n")
        
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
        f.write("=== MODEL PREDICTION PERFORMANCE ===\n\n")
        
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
        f.write("CORRECTED VIDEO-BASED PERFORMANCE SUMMARY\n")
        f.write("=" * 80 + "\n\n")
        
        f.write(f"Timestamp: {results['timestamp']}\n")
        f.write(f"Video Path: {results['video_path']}\n")
        f.write(f"Frames Used: {results['frames_used']}\n\n")
        
        f.write("Feature Extraction Performance:\n")
        f.write("-" * 40 + "\n")
        for combination, data in results.get('feature_extraction', {}).items():
            match_status = "OK" if data['feature_match'] else "MISMATCH"
            f.write(f"{combination:20} : {data['avg_latency_ms']:6.2f} ms, {data['fps']:8.2f} FPS {match_status}\n")
        
        f.write("\nModel Prediction Performance:\n")
        f.write("-" * 40 + "\n")
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
    print("=== Corrected Video-Based ML Performance Benchmark ===")
    
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
    
    print(f"\nSUCCESS: Corrected video-based benchmark completed!")
    print(f"Results saved to: {results_dir}")
    print(f"Files created:")
    print(f"  - detailed_results.json")
    print(f"  - feature_extraction_performance.txt")
    print(f"  - model_prediction_performance.txt")
    print(f"  - performance_summary.txt")
    
    # Print summary
    print("\n" + "=" * 80)
    print("CORRECTED VIDEO-BASED PERFORMANCE SUMMARY")
    print("=" * 80)
    
    print(f"Video: {comprehensive_results['video_path']}")
    print(f"Frames Used: {comprehensive_results['frames_used']}")
    
    print("\nFeature Extraction Performance:")
    print("-" * 40)
    for combination, data in comprehensive_results.get('feature_extraction', {}).items():
        match_status = "OK" if data['feature_match'] else "MISMATCH"
        print(f"{combination:20} : {data['avg_latency_ms']:6.2f} ms, {data['fps']:8.2f} FPS {match_status}")
    
    print("\nModel Prediction Performance:")
    print("-" * 40)
    for model_name, data in comprehensive_results.get('model_prediction', {}).items():
        print(f"{model_name:20} : {data['avg_latency_ms']:6.2f} ms, {data['fps']:8.2f} FPS")
    
    return 0

if __name__ == "__main__":
    exit(main())
