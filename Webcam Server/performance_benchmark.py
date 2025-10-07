#!/usr/bin/env python3
"""
Performance Benchmark Script for ML Webcam Server
Measures latency and FPS for different feature combinations
"""

import sys
import os
import time
import json
import numpy as np
from pathlib import Path
from datetime import datetime
import cv2

# Add src directory to Python path
src_dir = Path(__file__).parent / "src"
sys.path.insert(0, str(src_dir))

from src.core.logger import logger
from src.core.config_manager import ConfigManager
from src.ml.ethnicity_detector import MLEthnicityDetector
from src.ml.feature_extractors import FeatureExtractorFactory


class PerformanceBenchmark:
    """Performance benchmark for ML feature combinations"""
    
    def __init__(self):
        self.config_manager = ConfigManager()
        self.detector = MLEthnicityDetector.create_default_detector(self.config_manager)
        self.results = {}
        
        # Create performance directory
        self.performance_dir = Path("performance")
        self.performance_dir.mkdir(exist_ok=True)
        
        # Generate timestamp for this benchmark
        self.timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        logger.info(f"Performance benchmark initialized with timestamp: {self.timestamp}")
    
    def create_test_images(self, count=100):
        """Create test images for benchmarking using real camera or realistic synthetic faces"""
        test_images = []
        
        # Try to get real camera frames first
        try:
            camera = cv2.VideoCapture(0, cv2.CAP_DSHOW)
            if camera.isOpened():
                logger.info("Using real camera frames for benchmarking")
                for i in range(min(count, 50)):  # Limit to 50 real frames
                    ret, frame = camera.read()
                    if ret and frame is not None:
                        # Resize to standard size
                        frame = cv2.resize(frame, (200, 200))
                        test_images.append(frame)
                    else:
                        break
                camera.release()
                
                # If we got some real frames, use them and fill the rest with synthetic
                if test_images:
                    logger.info(f"Captured {len(test_images)} real camera frames")
                    remaining = count - len(test_images)
                    if remaining > 0:
                        synthetic_images = self._create_synthetic_faces(remaining)
                        test_images.extend(synthetic_images)
                else:
                    # No real frames, create synthetic faces
                    test_images = self._create_synthetic_faces(count)
            else:
                # Camera not available, create synthetic faces
                test_images = self._create_synthetic_faces(count)
        except Exception as e:
            logger.warning(f"Camera not available: {e}. Using synthetic faces.")
            test_images = self._create_synthetic_faces(count)
        
        logger.info(f"Created {len(test_images)} test images")
        return test_images
    
    def _create_synthetic_faces(self, count):
        """Create synthetic images with realistic face-like features"""
        test_images = []
        
        for i in range(count):
            # Create base image
            img = np.random.randint(100, 200, (200, 200, 3), dtype=np.uint8)
            
            # Create a more realistic face-like structure
            # Face outline (oval)
            center_x, center_y = 100, 100
            cv2.ellipse(img, (center_x, center_y), (80, 100), 0, 0, 360, (180, 160, 140), -1)
            
            # Eyes
            cv2.circle(img, (center_x - 25, center_y - 20), 8, (50, 50, 50), -1)
            cv2.circle(img, (center_x + 25, center_y - 20), 8, (50, 50, 50), -1)
            
            # Nose
            cv2.ellipse(img, (center_x, center_y + 5), (5, 15), 0, 0, 360, (160, 140, 120), -1)
            
            # Mouth
            cv2.ellipse(img, (center_x, center_y + 30), (15, 8), 0, 0, 180, (100, 50, 50), -1)
            
            # Add some texture variation
            noise = np.random.randint(-20, 20, (200, 200, 3), dtype=np.int16)
            img = np.clip(img.astype(np.int16) + noise, 0, 255).astype(np.uint8)
            
            test_images.append(img)
        
        return test_images
    
    def benchmark_feature_extraction(self, test_images, feature_combination):
        """Benchmark feature extraction for a specific combination"""
        logger.info(f"Benchmarking feature extraction: {feature_combination}")
        
        # Create feature extractors for this combination
        extractors = {}
        if 'glcm' in feature_combination:
            extractors['glcm'] = FeatureExtractorFactory.create_extractor('glcm')
        if 'lbp' in feature_combination:
            extractors['lbp'] = FeatureExtractorFactory.create_extractor('lbp')
        if 'hog' in feature_combination:
            extractors['hog'] = FeatureExtractorFactory.create_extractor('hog')
        if 'hsv' in feature_combination:
            extractors['hsv'] = FeatureExtractorFactory.create_extractor('hsv')
        
        # Benchmark feature extraction
        extraction_times = []
        
        for img in test_images:
            start_time = time.time()
            
            # Extract features based on combination
            features = []
            if 'glcm' in feature_combination:
                features.extend(extractors['glcm'].extract(img))
            if 'lbp' in feature_combination:
                features.extend(extractors['lbp'].extract(img))
            if 'hog' in feature_combination:
                features.extend(extractors['hog'].extract(img))
            if 'hsv' in feature_combination:
                features.extend(extractors['hsv'].extract(img))
            
            end_time = time.time()
            extraction_times.append((end_time - start_time) * 1000)  # Convert to ms
        
        # Calculate statistics
        avg_latency = np.mean(extraction_times)
        std_latency = np.std(extraction_times)
        min_latency = np.min(extraction_times)
        max_latency = np.max(extraction_times)
        
        # Calculate FPS (frames per second)
        fps = 1000.0 / avg_latency if avg_latency > 0 else 0
        
        result = {
            'feature_combination': feature_combination,
            'avg_latency_ms': round(avg_latency, 2),
            'std_latency_ms': round(std_latency, 2),
            'min_latency_ms': round(min_latency, 2),
            'max_latency_ms': round(max_latency, 2),
            'fps': round(fps, 2),
            'sample_count': len(test_images)
        }
        
        logger.info(f"Feature extraction benchmark completed: {result}")
        return result
    
    def benchmark_model_prediction(self, test_images, model_name):
        """Benchmark model prediction for a specific model"""
        logger.info(f"Benchmarking model prediction: {model_name}")
        
        prediction_times = []
        successful_predictions = 0
        
        for img in test_images:
            start_time = time.time()
            
            try:
                ethnicity, confidence = self.detector.predict_ethnicity(img, model_name)
                end_time = time.time()
                
                if ethnicity is not None:
                    successful_predictions += 1
                    prediction_times.append((end_time - start_time) * 1000)  # Convert to ms
            except Exception as e:
                logger.warning(f"Prediction failed for {model_name}: {e}")
                continue
        
        if not prediction_times:
            logger.warning(f"No successful predictions for {model_name}")
            return None
        
        # Calculate statistics
        avg_latency = np.mean(prediction_times)
        std_latency = np.std(prediction_times)
        min_latency = np.min(prediction_times)
        max_latency = np.max(prediction_times)
        
        # Calculate FPS
        fps = 1000.0 / avg_latency if avg_latency > 0 else 0
        
        result = {
            'model_name': model_name,
            'avg_latency_ms': round(avg_latency, 2),
            'std_latency_ms': round(std_latency, 2),
            'min_latency_ms': round(min_latency, 2),
            'max_latency_ms': round(max_latency, 2),
            'fps': round(fps, 2),
            'successful_predictions': successful_predictions,
            'total_attempts': len(test_images),
            'success_rate': round(successful_predictions / len(test_images) * 100, 2)
        }
        
        logger.info(f"Model prediction benchmark completed: {result}")
        return result
    
    def run_comprehensive_benchmark(self):
        """Run comprehensive performance benchmark"""
        logger.info("Starting comprehensive performance benchmark")
        
        # Create test images
        test_images = self.create_test_images(100)
        
        # Get available models
        available_models = self.detector.get_available_models()
        logger.info(f"Available models: {available_models}")
        
        # Benchmark feature extraction for different combinations
        feature_combinations = [
            'glcm+lbp',
            'lbp+hog', 
            'glcm+hog',
            'glcm+lbp+hog',
            'glcm+lbp+hog+hsv',
            'hsv'
        ]
        
        feature_results = []
        for combination in feature_combinations:
            try:
                result = self.benchmark_feature_extraction(test_images, combination)
                feature_results.append(result)
            except Exception as e:
                logger.error(f"Feature extraction benchmark failed for {combination}: {e}")
        
        # Benchmark model prediction for available models
        model_results = []
        for model_name in available_models:
            try:
                result = self.benchmark_model_prediction(test_images, model_name)
                if result:
                    model_results.append(result)
            except Exception as e:
                logger.error(f"Model prediction benchmark failed for {model_name}: {e}")
        
        # Compile results
        self.results = {
            'timestamp': self.timestamp,
            'test_configuration': {
                'test_image_count': len(test_images),
                'image_size': '200x200x3',
                'available_models': available_models
            },
            'feature_extraction_results': feature_results,
            'model_prediction_results': model_results
        }
        
        logger.info("Comprehensive benchmark completed")
        return self.results
    
    def save_results(self):
        """Save benchmark results to files"""
        if not self.results:
            logger.error("No results to save. Run benchmark first.")
            return
        
        # Create results directory with timestamp
        results_dir = self.performance_dir / f"benchmark_{self.timestamp}"
        results_dir.mkdir(exist_ok=True)
        
        # Save detailed JSON results
        json_file = results_dir / "detailed_results.json"
        with open(json_file, 'w') as f:
            json.dump(self.results, f, indent=2)
        
        # Save feature extraction results table
        self.save_feature_extraction_table(results_dir)
        
        # Save model prediction results table
        self.save_model_prediction_table(results_dir)
        
        # Save summary report
        self.save_summary_report(results_dir)
        
        logger.info(f"Results saved to: {results_dir}")
        return results_dir
    
    def save_feature_extraction_table(self, results_dir):
        """Save feature extraction results as table"""
        table_file = results_dir / "feature_extraction_performance.txt"
        
        with open(table_file, 'w') as f:
            f.write("Feature Extraction Performance Results\n")
            f.write("=" * 50 + "\n")
            f.write(f"Timestamp: {self.timestamp}\n")
            f.write(f"Test Images: {self.results['test_configuration']['test_image_count']}\n")
            f.write(f"Image Size: {self.results['test_configuration']['image_size']}\n\n")
            
            f.write("Table 1. Feature Extraction Performance Metrics\n")
            f.write("-" * 80 + "\n")
            f.write(f"{'Feature Combination':<20} {'Avg Latency (ms)':<18} {'FPS':<10} {'Std Dev (ms)':<15}\n")
            f.write("-" * 80 + "\n")
            
            for result in self.results['feature_extraction_results']:
                f.write(f"{result['feature_combination']:<20} "
                       f"{result['avg_latency_ms']:<18} "
                       f"{result['fps']:<10} "
                       f"{result['std_latency_ms']:<15}\n")
            
            f.write("-" * 80 + "\n\n")
            
            # Detailed statistics
            f.write("Detailed Statistics:\n")
            f.write("-" * 30 + "\n")
            for result in self.results['feature_extraction_results']:
                f.write(f"\n{result['feature_combination']}:\n")
                f.write(f"  Average Latency: {result['avg_latency_ms']} ms\n")
                f.write(f"  Standard Deviation: {result['std_latency_ms']} ms\n")
                f.write(f"  Min Latency: {result['min_latency_ms']} ms\n")
                f.write(f"  Max Latency: {result['max_latency_ms']} ms\n")
                f.write(f"  FPS: {result['fps']}\n")
                f.write(f"  Sample Count: {result['sample_count']}\n")
    
    def save_model_prediction_table(self, results_dir):
        """Save model prediction results as table"""
        table_file = results_dir / "model_prediction_performance.txt"
        
        with open(table_file, 'w') as f:
            f.write("Model Prediction Performance Results\n")
            f.write("=" * 50 + "\n")
            f.write(f"Timestamp: {self.timestamp}\n")
            f.write(f"Test Images: {self.results['test_configuration']['test_image_count']}\n")
            f.write(f"Available Models: {', '.join(self.results['test_configuration']['available_models'])}\n\n")
            
            f.write("Table 2. Model Prediction Performance Metrics\n")
            f.write("-" * 90 + "\n")
            f.write(f"{'Model Name':<20} {'Avg Latency (ms)':<18} {'FPS':<10} {'Success Rate (%)':<18} {'Std Dev (ms)':<15}\n")
            f.write("-" * 90 + "\n")
            
            for result in self.results['model_prediction_results']:
                f.write(f"{result['model_name']:<20} "
                       f"{result['avg_latency_ms']:<18} "
                       f"{result['fps']:<10} "
                       f"{result['success_rate']:<18} "
                       f"{result['std_latency_ms']:<15}\n")
            
            f.write("-" * 90 + "\n\n")
            
            # Detailed statistics
            f.write("Detailed Statistics:\n")
            f.write("-" * 30 + "\n")
            for result in self.results['model_prediction_results']:
                f.write(f"\n{result['model_name']}:\n")
                f.write(f"  Average Latency: {result['avg_latency_ms']} ms\n")
                f.write(f"  Standard Deviation: {result['std_latency_ms']} ms\n")
                f.write(f"  Min Latency: {result['min_latency_ms']} ms\n")
                f.write(f"  Max Latency: {result['max_latency_ms']} ms\n")
                f.write(f"  FPS: {result['fps']}\n")
                f.write(f"  Success Rate: {result['success_rate']}%\n")
                f.write(f"  Successful Predictions: {result['successful_predictions']}/{result['total_attempts']}\n")
    
    def save_summary_report(self, results_dir):
        """Save summary report"""
        report_file = results_dir / "performance_summary.txt"
        
        with open(report_file, 'w') as f:
            f.write("ML Webcam Server Performance Benchmark Summary\n")
            f.write("=" * 60 + "\n")
            f.write(f"Timestamp: {self.timestamp}\n")
            f.write(f"Test Configuration: {self.results['test_configuration']}\n\n")
            
            # Feature extraction summary
            f.write("FEATURE EXTRACTION PERFORMANCE:\n")
            f.write("-" * 30 + "\n")
            if self.results['feature_extraction_results']:
                fastest_feature = min(self.results['feature_extraction_results'], 
                                    key=lambda x: x['avg_latency_ms'])
                slowest_feature = max(self.results['feature_extraction_results'], 
                                    key=lambda x: x['avg_latency_ms'])
                
                f.write(f"Fastest: {fastest_feature['feature_combination']} "
                       f"({fastest_feature['avg_latency_ms']} ms, {fastest_feature['fps']} FPS)\n")
                f.write(f"Slowest: {slowest_feature['feature_combination']} "
                       f"({slowest_feature['avg_latency_ms']} ms, {slowest_feature['fps']} FPS)\n")
            
            f.write("\n")
            
            # Model prediction summary
            f.write("MODEL PREDICTION PERFORMANCE:\n")
            f.write("-" * 30 + "\n")
            if self.results['model_prediction_results']:
                fastest_model = min(self.results['model_prediction_results'], 
                                  key=lambda x: x['avg_latency_ms'])
                slowest_model = max(self.results['model_prediction_results'], 
                                  key=lambda x: x['avg_latency_ms'])
                
                f.write(f"Fastest: {fastest_model['model_name']} "
                       f"({fastest_model['avg_latency_ms']} ms, {fastest_model['fps']} FPS)\n")
                f.write(f"Slowest: {slowest_model['model_name']} "
                       f"({slowest_model['avg_latency_ms']} ms, {slowest_model['fps']} FPS)\n")
                
                # Best accuracy (highest success rate)
                best_accuracy = max(self.results['model_prediction_results'], 
                                  key=lambda x: x['success_rate'])
                f.write(f"Best Accuracy: {best_accuracy['model_name']} "
                       f"({best_accuracy['success_rate']}% success rate)\n")
            
            f.write("\n")
            
            # Recommendations
            f.write("RECOMMENDATIONS:\n")
            f.write("-" * 15 + "\n")
            if self.results['feature_extraction_results']:
                f.write("For real-time applications, consider using faster feature combinations.\n")
                f.write("For accuracy-critical applications, use comprehensive feature combinations.\n")
            
            if self.results['model_prediction_results']:
                f.write("Balance between speed and accuracy based on application requirements.\n")
                f.write("Monitor success rates to ensure reliable predictions.\n")


def main():
    """Main function to run performance benchmark"""
    print("=== ML Webcam Server Performance Benchmark ===")
    
    try:
        # Create benchmark instance
        benchmark = PerformanceBenchmark()
        
        # Run comprehensive benchmark
        print("Running performance benchmark...")
        results = benchmark.run_comprehensive_benchmark()
        
        # Save results
        print("Saving results...")
        results_dir = benchmark.save_results()
        
        print(f"✅ Benchmark completed successfully!")
        print(f"📊 Results saved to: {results_dir}")
        print(f"📁 Files created:")
        print(f"   - detailed_results.json")
        print(f"   - feature_extraction_performance.txt")
        print(f"   - model_prediction_performance.txt")
        print(f"   - performance_summary.txt")
        
        # Print summary to console
        print("\n" + "="*60)
        print("PERFORMANCE SUMMARY")
        print("="*60)
        
        if results['feature_extraction_results']:
            print("\nFeature Extraction Performance:")
            print("-" * 30)
            for result in results['feature_extraction_results']:
                print(f"{result['feature_combination']:<20}: "
                      f"{result['avg_latency_ms']:>8} ms, "
                      f"{result['fps']:>6} FPS")
        
        if results['model_prediction_results']:
            print("\nModel Prediction Performance:")
            print("-" * 30)
            for result in results['model_prediction_results']:
                print(f"{result['model_name']:<20}: "
                      f"{result['avg_latency_ms']:>8} ms, "
                      f"{result['fps']:>6} FPS, "
                      f"{result['success_rate']:>5}% success")
        
    except Exception as e:
        logger.error(f"Benchmark failed: {e}")
        print(f"❌ Benchmark failed: {e}")
        return 1
    
    return 0


if __name__ == "__main__":
    exit(main())
