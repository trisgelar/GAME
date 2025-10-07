#!/usr/bin/env python3
"""
Video-Based Performance Benchmark
Benchmarks ML ethnicity detection performance using real video frames
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

try:
    from core.config_manager import ConfigManager
    from ml.ethnicity_detector import MLEthnicityDetector
    from core.logger import logger
except ImportError as e:
    print(f"Import error: {e}")
    print("Trying alternative import method...")
    
    # Alternative import method
    import importlib.util
    
    # Import ConfigManager
    config_spec = importlib.util.spec_from_file_location(
        "config_manager", 
        os.path.join(os.path.dirname(__file__), 'src', 'core', 'config_manager.py')
    )
    config_module = importlib.util.module_from_spec(config_spec)
    config_spec.loader.exec_module(config_module)
    ConfigManager = config_module.ConfigManager
    
    # Import logger
    logger_spec = importlib.util.spec_from_file_location(
        "logger", 
        os.path.join(os.path.dirname(__file__), 'src', 'core', 'logger.py')
    )
    logger_module = importlib.util.module_from_spec(logger_spec)
    logger_spec.loader.exec_module(logger_module)
    logger = logger_module.logger
    
    # Import MLEthnicityDetector
    detector_spec = importlib.util.spec_from_file_location(
        "ethnicity_detector", 
        os.path.join(os.path.dirname(__file__), 'src', 'ml', 'ethnicity_detector.py')
    )
    detector_module = importlib.util.module_from_spec(detector_spec)
    detector_spec.loader.exec_module(detector_module)
    MLEthnicityDetector = detector_module.MLEthnicityDetector


class VideoPerformanceBenchmark:
    """Benchmark performance using real video frames"""
    
    def __init__(self, config_manager: ConfigManager):
        self.config_manager = config_manager
        self.ethnicity_detector = MLEthnicityDetector.create_default_detector(config_manager)
        self.timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.results = {}
        
        # Create performance directory
        self.performance_dir = Path("performance")
        self.performance_dir.mkdir(exist_ok=True)
        
        logger.info(f"Video performance benchmark initialized with timestamp: {self.timestamp}")
    
    def extract_video_frames(self, video_path: str, max_frames: int = 100) -> list:
        """
        Extract frames from video file
        
        Args:
            video_path: Path to video file
            max_frames: Maximum number of frames to extract
            
        Returns:
            List of video frames as numpy arrays
        """
        frames = []
        
        if not os.path.exists(video_path):
            logger.error(f"Video file not found: {video_path}")
            return frames
        
        logger.info(f"Extracting frames from video: {video_path}")
        
        try:
            cap = cv2.VideoCapture(video_path)
            
            if not cap.isOpened():
                logger.error(f"Could not open video file: {video_path}")
                return frames
            
            frame_count = 0
            total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
            fps = cap.get(cv2.CAP_PROP_FPS)
            
            logger.info(f"Video info: {total_frames} frames, {fps:.2f} FPS")
            
            # Extract frames evenly distributed throughout the video
            frame_interval = max(1, total_frames // max_frames)
            
            while frame_count < max_frames:
                ret, frame = cap.read()
                
                if not ret:
                    break
                
                # Resize frame to standard size (200x200 for face detection)
                frame = cv2.resize(frame, (200, 200))
                frames.append(frame)
                frame_count += 1
                
                # Skip frames to get evenly distributed samples
                for _ in range(frame_interval - 1):
                    cap.read()
            
            cap.release()
            logger.info(f"Extracted {len(frames)} frames from video")
            
        except Exception as e:
            logger.error(f"Error extracting video frames: {e}")
        
        return frames
    
    def benchmark_feature_extraction(self, frames: list, feature_combinations: list) -> dict:
        """
        Benchmark feature extraction performance
        
        Args:
            frames: List of video frames
            feature_combinations: List of feature combinations to test
            
        Returns:
            Dictionary with benchmark results
        """
        results = {}
        
        logger.info("Starting feature extraction benchmark with video frames")
        
        for combination in feature_combinations:
            logger.info(f"Benchmarking feature extraction: {combination}")
            
            # Create extractors for this combination
            extractors = {}
            features = combination.split('+')
            
            for feature in features:
                if feature == 'hog':
                    from ml.feature_extractors import HOGFeatureExtractor
                    extractors[feature] = HOGFeatureExtractor()
                elif feature == 'glcm':
                    from ml.feature_extractors import GLCMFeatureExtractor
                    extractors[feature] = GLCMFeatureExtractor()
                elif feature == 'lbp':
                    from ml.feature_extractors import LBPFeatureExtractor
                    extractors[feature] = LBPFeatureExtractor()
                elif feature == 'hsv':
                    from ml.feature_extractors import HSVFeatureExtractor
                    extractors[feature] = HSVFeatureExtractor()
            
            # Benchmark this combination
            latencies = []
            successful_extractions = 0
            
            for frame in frames:
                try:
                    start_time = time.perf_counter()
                    
                    # Extract features
                    combined_features = []
                    for feature_name, extractor in extractors.items():
                        features = extractor.extract_features(frame)
                        if features is not None:
                            combined_features.extend(features)
                    
                    if combined_features:
                        end_time = time.perf_counter()
                        latency_ms = (end_time - start_time) * 1000
                        latencies.append(latency_ms)
                        successful_extractions += 1
                
                except Exception as e:
                    logger.warning(f"Feature extraction failed for {combination}: {e}")
                    continue
            
            if latencies:
                results[combination] = {
                    'feature_combination': combination,
                    'avg_latency_ms': np.mean(latencies),
                    'std_latency_ms': np.std(latencies),
                    'min_latency_ms': np.min(latencies),
                    'max_latency_ms': np.max(latencies),
                    'fps': 1000 / np.mean(latencies),
                    'sample_count': len(latencies),
                    'successful_extractions': successful_extractions
                }
                
                logger.info(f"Feature extraction benchmark completed: {results[combination]}")
            else:
                logger.warning(f"No successful extractions for {combination}")
        
        return results
    
    def benchmark_model_prediction(self, frames: list, model_names: list) -> dict:
        """
        Benchmark model prediction performance using video frames
        
        Args:
            frames: List of video frames
            model_names: List of model names to test
            
        Returns:
            Dictionary with benchmark results
        """
        results = {}
        
        logger.info("Starting model prediction benchmark with video frames")
        
        for model_name in model_names:
            logger.info(f"Benchmarking model prediction: {model_name}")
            
            latencies = []
            successful_predictions = 0
            predictions = []
            
            for frame in frames:
                try:
                    start_time = time.perf_counter()
                    
                    # Predict ethnicity using the model
                    ethnicity, confidence = self.ethnicity_detector.predict_ethnicity(frame, model_name)
                    
                    end_time = time.perf_counter()
                    latency_ms = (end_time - start_time) * 1000
                    
                    if ethnicity is not None:
                        latencies.append(latency_ms)
                        predictions.append(ethnicity)
                        successful_predictions += 1
                
                except Exception as e:
                    logger.warning(f"Model prediction failed for {model_name}: {e}")
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
                
                logger.info(f"Model prediction benchmark completed: {results[model_name]}")
            else:
                logger.warning(f"No successful predictions for {model_name}")
        
        return results
    
    def run_comprehensive_benchmark(self, video_path: str) -> dict:
        """
        Run comprehensive benchmark using video frames
        
        Args:
            video_path: Path to video file
            
        Returns:
            Dictionary with all benchmark results
        """
        logger.info("Starting comprehensive video-based performance benchmark")
        
        # Extract frames from video
        frames = self.extract_video_frames(video_path, max_frames=50)
        
        if not frames:
            logger.error("No frames extracted from video")
            return {}
        
        logger.info(f"Using {len(frames)} video frames for benchmarking")
        
        # Get available models
        available_models = list(self.ethnicity_detector.model_manager.models.keys())
        logger.info(f"Available models: {available_models}")
        
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
        feature_results = self.benchmark_feature_extraction(frames, feature_combinations)
        
        # Benchmark model prediction
        model_results = self.benchmark_model_prediction(frames, available_models)
        
        # Combine results
        comprehensive_results = {
            'timestamp': self.timestamp,
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
        
        logger.info("Comprehensive video benchmark completed")
        return comprehensive_results
    
    def save_results(self, results: dict):
        """Save benchmark results to files"""
        logger.info("Saving results...")
        
        # Create results directory
        results_dir = self.performance_dir / f"video_benchmark_{self.timestamp}"
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
                f.write(f"  Sample Count: {data['sample_count']}\n\n")
        
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
            f.write("VIDEO-BASED PERFORMANCE SUMMARY\n")
            f.write("=" * 80 + "\n\n")
            
            f.write(f"Timestamp: {results['timestamp']}\n")
            f.write(f"Video Path: {results['video_path']}\n")
            f.write(f"Frames Used: {results['frames_used']}\n\n")
            
            f.write("Feature Extraction Performance:\n")
            f.write("-" * 40 + "\n")
            for combination, data in results.get('feature_extraction', {}).items():
                f.write(f"{combination:20} : {data['avg_latency_ms']:6.2f} ms, {data['fps']:8.2f} FPS\n")
            
            f.write("\nModel Prediction Performance:\n")
            f.write("-" * 40 + "\n")
            for model_name, data in results.get('model_prediction', {}).items():
                f.write(f"{model_name:20} : {data['avg_latency_ms']:6.2f} ms, {data['fps']:8.2f} FPS\n")
            
            f.write(f"\nSummary:\n")
            f.write(f"Total Feature Combinations: {results['summary']['total_feature_combinations']}\n")
            f.write(f"Total Models: {results['summary']['total_models']}\n")
            f.write(f"Successful Feature Tests: {results['summary']['successful_feature_tests']}\n")
            f.write(f"Successful Model Tests: {results['summary']['successful_model_tests']}\n")
        
        logger.info(f"Results saved to: {results_dir}")
        return results_dir


def main():
    """Main function"""
    print("=== Video-Based ML Performance Benchmark ===")
    
    # Initialize configuration
    config_manager = ConfigManager()
    
    # Video path
    video_path = "performance/cropped_video_480x360.mp4"
    
    if not os.path.exists(video_path):
        print(f"ERROR: Video file not found: {video_path}")
        print("Please run video_crop.py first to create the cropped video.")
        return 1
    
    print(f"Using video: {video_path}")
    
    # Create benchmark instance
    benchmark = VideoPerformanceBenchmark(config_manager)
    
    # Run comprehensive benchmark
    print("Running video-based performance benchmark...")
    results = benchmark.run_comprehensive_benchmark(video_path)
    
    if not results:
        print("ERROR: Benchmark failed - no results generated")
        return 1
    
    # Save results
    results_dir = benchmark.save_results(results)
    
    print(f"\nSUCCESS: Video-based benchmark completed!")
    print(f"Results saved to: {results_dir}")
    print(f"Files created:")
    print(f"  - detailed_results.json")
    print(f"  - feature_extraction_performance.txt")
    print(f"  - model_prediction_performance.txt")
    print(f"  - performance_summary.txt")
    
    # Print summary
    print("\n" + "=" * 80)
    print("VIDEO-BASED PERFORMANCE SUMMARY")
    print("=" * 80)
    
    print(f"Video: {results['video_path']}")
    print(f"Frames Used: {results['frames_used']}")
    
    print("\nFeature Extraction Performance:")
    print("-" * 40)
    for combination, data in results.get('feature_extraction', {}).items():
        print(f"{combination:20} : {data['avg_latency_ms']:6.2f} ms, {data['fps']:8.2f} FPS")
    
    print("\nModel Prediction Performance:")
    print("-" * 40)
    for model_name, data in results.get('model_prediction', {}).items():
        print(f"{model_name:20} : {data['avg_latency_ms']:6.2f} ms, {data['fps']:8.2f} FPS")
    
    return 0


if __name__ == "__main__":
    exit(main())
