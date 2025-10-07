#!/usr/bin/env python3
"""
Video Performance Visualizer
Creates a video with real-time FPS and latency overlays
"""

import cv2
import numpy as np
import time
import json
import os
from datetime import datetime
from pathlib import Path
import sys

# Add src directory to path for imports
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

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
                import pickle
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
    P = P[P > 0]
    return -np.sum(P * np.log2(P))

def extract_hog_features_exact(image):
    """Extract HOG features with exact training parameters"""
    try:
        from skimage.feature import hog
        
        if len(image.shape) == 3:
            gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
        else:
            gray = image
        
        features = hog(gray, 
                      orientations=9,
                      pixels_per_cell=(8, 8),
                      cells_per_block=(2, 2), 
                      block_norm='L2-Hys',
                      feature_vector=True,
                      channel_axis=None)
        
        return features
    except Exception as e:
        print(f"HOG extraction error: {e}")
        return None

def extract_glcm_features_exact(image):
    """Extract GLCM features with exact training parameters"""
    try:
        from skimage.feature import graycomatrix, graycoprops
        
        if len(image.shape) == 3:
            gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
        else:
            gray = image
        
        if gray.shape[0] > 256 or gray.shape[1] > 256:
            gray = cv2.resize(gray, (256, 256))
        
        distances = [1]
        angles = [0, 45, 90, 135]
        levels = 256
        
        angles_rad = [np.radians(angle) for angle in angles]
        
        glcm = graycomatrix(gray, 
                           distances=distances, 
                           angles=angles_rad,
                           levels=levels, 
                           symmetric=True, 
                           normed=True)
        
        properties = ['contrast', 'homogeneity', 'correlation', 'energy']
        haralick_features = []
        
        for prop in properties:
            feature_values = graycoprops(glcm, prop).ravel()
            haralick_features.extend(feature_values)
        
        entropy_features = []
        for j in range(len(angles_rad)):
            P_avg = np.mean(glcm[:, :, :, j], axis=2)
            entropy_val = shannon_entropy(P_avg)
            entropy_features.append(entropy_val)
        
        all_features = np.concatenate([haralick_features, entropy_features])
        return all_features
    except Exception as e:
        print(f"GLCM extraction error: {e}")
        return None

def extract_lbp_features_exact(image):
    """Extract LBP features with exact training parameters"""
    try:
        from skimage.feature import local_binary_pattern
        
        if len(image.shape) == 3:
            gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
        else:
            gray = image
        
        P = 8
        R = 1.0
        method = 'uniform'
        bins = P + 2
        
        lbp = local_binary_pattern(gray, P, R, method=method)
        hist, _ = np.histogram(lbp.ravel(), bins=bins, range=(0, bins), density=True)
        
        return hist.astype(np.float32)
    except Exception as e:
        print(f"LBP extraction error: {e}")
        return None

def extract_hsv_features_exact(image):
    """Extract HSV features with exact training parameters"""
    try:
        hsv = cv2.cvtColor(image, cv2.COLOR_RGB2HSV)
        
        bins = 16
        channels = [1, 2]  # S and V channels only
        
        features = []
        for channel in channels:
            hist = cv2.calcHist([hsv], [channel], None, [bins], [0, 256])
            hist = hist.flatten() / (hist.sum() + 1e-7)
            features.extend(hist)
        
        return np.array(features)
    except Exception as e:
        print(f"HSV extraction error: {e}")
        return None

def detect_faces(image):
    """Detect faces in image"""
    try:
        cascade_path = cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
        face_cascade = cv2.CascadeClassifier(cascade_path)
        
        gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
        faces = face_cascade.detectMultiScale(gray, 1.1, 4)
        
        return faces
    except Exception as e:
        print(f"Face detection error: {e}")
        return []

def draw_performance_overlay(frame, fps, latency_ms, model_name, prediction, confidence=None):
    """Draw performance metrics overlay on frame"""
    height, width = frame.shape[:2]
    
    # Create overlay background
    overlay = frame.copy()
    
    # Performance metrics box
    box_height = 120
    box_width = 300
    box_x = 10
    box_y = 10
    
    # Draw semi-transparent background
    cv2.rectangle(overlay, (box_x, box_y), (box_x + box_width, box_y + box_height), (0, 0, 0), -1)
    cv2.addWeighted(overlay, 0.7, frame, 0.3, 0, frame)
    
    # Performance metrics text
    font = cv2.FONT_HERSHEY_SIMPLEX
    font_scale = 0.6
    color = (0, 255, 0)  # Green
    thickness = 2
    
    # FPS
    fps_text = f"FPS: {fps:.1f}"
    cv2.putText(frame, fps_text, (box_x + 10, box_y + 25), font, font_scale, color, thickness)
    
    # Latency
    latency_text = f"Latency: {latency_ms:.1f} ms"
    cv2.putText(frame, latency_text, (box_x + 10, box_y + 50), font, font_scale, color, thickness)
    
    # Model name
    model_text = f"Model: {model_name}"
    cv2.putText(frame, model_text, (box_x + 10, box_y + 75), font, font_scale, color, thickness)
    
    # Prediction
    if prediction is not None:
        pred_text = f"Ethnicity: {prediction}"
        cv2.putText(frame, pred_text, (box_x + 10, box_y + 100), font, font_scale, color, thickness)
    
    return frame

def create_performance_video(input_video_path, output_video_path, models, model_name='glcm_lbp_hog_hsv'):
    """Create video with performance overlays"""
    
    if not os.path.exists(input_video_path):
        print(f"Input video not found: {input_video_path}")
        return False
    
    if model_name not in models:
        print(f"Model {model_name} not found in loaded models")
        return False
    
    model = models[model_name]
    
    print(f"Creating performance video with {model_name} model...")
    print(f"Input: {input_video_path}")
    print(f"Output: {output_video_path}")
    
    # Open input video
    cap = cv2.VideoCapture(input_video_path)
    
    if not cap.isOpened():
        print(f"Could not open input video: {input_video_path}")
        return False
    
    # Get video properties
    fps_input = cap.get(cv2.CAP_PROP_FPS)
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    
    print(f"Video properties: {width}x{height}, {fps_input:.2f} FPS, {total_frames} frames")
    
    # Setup output video writer
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(output_video_path, fourcc, fps_input, (width, height))
    
    frame_count = 0
    start_time = time.time()
    
    # Performance tracking
    fps_history = []
    latency_history = []
    
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        
        frame_start_time = time.perf_counter()
        
        # Convert BGR to RGB for processing
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        
        # Resize for processing (256x256)
        frame_processed = cv2.resize(frame_rgb, (256, 256))
        
        # Detect faces
        faces = detect_faces(frame_processed)
        
        prediction = None
        confidence = None
        
        if len(faces) > 0:
            try:
                # Use the first detected face
                x, y, w, h = faces[0]
                face_roi = frame_processed[y:y+h, x:x+w]
                face_roi = cv2.resize(face_roi, (256, 256))
                
                # Extract features based on model
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
                
                if features:
                    # Predict ethnicity
                    features_array = np.array(features).reshape(1, -1)
                    prediction = model.predict(features_array)[0]
                    
                    # Get prediction confidence (if available)
                    if hasattr(model, 'predict_proba'):
                        proba = model.predict_proba(features_array)[0]
                        confidence = np.max(proba)
            
            except Exception as e:
                print(f"Prediction error on frame {frame_count}: {e}")
        
        frame_end_time = time.perf_counter()
        latency_ms = (frame_end_time - frame_start_time) * 1000
        
        # Calculate current FPS
        current_time = time.time()
        elapsed_time = current_time - start_time
        current_fps = frame_count / elapsed_time if elapsed_time > 0 else 0
        
        # Store performance metrics
        fps_history.append(current_fps)
        latency_history.append(latency_ms)
        
        # Keep only last 30 frames for smooth display
        if len(fps_history) > 30:
            fps_history.pop(0)
            latency_history.pop(0)
        
        # Use smoothed values
        avg_fps = np.mean(fps_history) if fps_history else 0
        avg_latency = np.mean(latency_history) if latency_history else 0
        
        # Draw performance overlay
        frame = draw_performance_overlay(frame, avg_fps, avg_latency, model_name, prediction, confidence)
        
        # Write frame to output video
        out.write(frame)
        
        frame_count += 1
        
        # Progress indicator
        if frame_count % 100 == 0:
            progress = (frame_count / total_frames) * 100
            print(f"Progress: {progress:.1f}% ({frame_count}/{total_frames}) - FPS: {avg_fps:.1f}, Latency: {avg_latency:.1f}ms")
    
    # Cleanup
    cap.release()
    out.release()
    
    print(f"Performance video created successfully!")
    print(f"Output saved to: {output_video_path}")
    print(f"Total frames processed: {frame_count}")
    print(f"Average FPS: {np.mean(fps_history):.2f}")
    print(f"Average Latency: {np.mean(latency_history):.2f} ms")
    
    return True

def main():
    """Main function"""
    print("=== Video Performance Visualizer ===")
    
    # Load configuration
    config = load_config()
    models_dir = config.get('ml', {}).get('models_dir', 'models/run_20250925_133309')
    
    # Video paths
    input_video_path = "performance/cropped_video_480x360.mp4"
    
    if not os.path.exists(input_video_path):
        print(f"ERROR: Input video not found: {input_video_path}")
        print("Please run video_crop.py first to create the cropped video.")
        return 1
    
    # Load models
    models = load_models(models_dir)
    if not models:
        print("ERROR: No models loaded")
        return 1
    
    print(f"Loaded {len(models)} models: {list(models.keys())}")
    
    # Create output directory
    output_dir = Path("performance/visualizations")
    output_dir.mkdir(exist_ok=True)
    
    # Create performance videos for different models
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    successful_videos = []
    
    # Test with different models
    test_models = ['glcm_lbp_hog_hsv', 'hsv']  # Start with the working models
    
    for model_name in test_models:
        if model_name in models:
            output_video_path = output_dir / f"performance_video_{model_name}_{timestamp}.mp4"
            
            print(f"\nCreating performance video with {model_name} model...")
            success = create_performance_video(input_video_path, str(output_video_path), models, model_name)
            
            if success:
                successful_videos.append((model_name, str(output_video_path)))
                print(f"✅ Successfully created: {output_video_path}")
            else:
                print(f"❌ Failed to create video for {model_name}")
        else:
            print(f"⚠️ Model {model_name} not available")
    
    # Summary
    print(f"\n=== PERFORMANCE VISUALIZATION SUMMARY ===")
    print(f"Input video: {input_video_path}")
    print(f"Output directory: {output_dir}")
    print(f"Successful videos created: {len(successful_videos)}")
    
    for model_name, output_path in successful_videos:
        print(f"  - {model_name}: {output_path}")
    
    if successful_videos:
        print(f"\n🎉 Performance visualization completed successfully!")
        print(f"📹 Videos with real-time FPS and latency overlays are ready!")
    else:
        print(f"\n❌ No performance videos were created successfully.")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())
