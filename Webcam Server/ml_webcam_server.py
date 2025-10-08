#!/usr/bin/env python3
"""
ML-Enhanced UDP Webcam Server
Integrates trained ML models for real-time ethnicity detection
"""

import cv2
import socket
import struct
import threading
import time
import math
import pickle
import numpy as np
import json
from pathlib import Path
from skimage.feature import hog, graycomatrix, graycoprops, local_binary_pattern

class MLEthnicityDetector:
    def __init__(self, models_dir="models/run_20250925_133309"):
        self.models_dir = Path(models_dir)
        self.models = {}
        self.feature_extractors = {}
        self.load_models()
        
    def load_models(self):
        """Load all available ML models"""
        print("🤖 Loading ML models...")
        
        # Available models
        model_files = {
            'glcm_hog': 'GLCM_HOG_model.pkl',
            'glcm_lbp_hog': 'GLCM_LBP_HOG_model.pkl', 
            'glcm_lbp_hog_hsv': 'GLCM_LBP_HOG_HSV_model.pkl',
            'hog': 'HOG_model.pkl',
            'glcm': 'GLCM_model.pkl',
            'lbp': 'LBP_model.pkl',
            'hsv': 'HSV_model.pkl'
        }
        
        for model_name, filename in model_files.items():
            model_path = self.models_dir / filename
            if model_path.exists():
                try:
                    with open(model_path, 'rb') as f:
                        self.models[model_name] = pickle.load(f)
                    print(f"✅ Loaded {model_name} model")
                except Exception as e:
                    print(f"❌ Failed to load {model_name}: {e}")
            else:
                print(f"⚠️ Model not found: {filename}")
        
        # Load feature configuration if available
        self.load_feature_config()
        
    def load_feature_config(self):
        """Load feature extraction configuration"""
        config_file = self.models_dir / "feature_sets_summary_20250925_133309.json"
        if config_file.exists():
            try:
                with open(config_file, 'r') as f:
                    self.feature_config = json.load(f)
                print("✅ Loaded feature configuration")
            except Exception as e:
                print(f"❌ Failed to load feature config: {e}")
                self.feature_config = {}
        else:
            self.feature_config = {}
    
    def extract_hog_features(self, image):
        """Extract HOG features with EXACT training parameters (256x256, 9 bins, (8,8) cell, (2,2) block)"""
        # Resize to 256x256 - CRITICAL: must match training!
        resized = cv2.resize(image, (256, 256))
        
        # Convert to grayscale
        if len(image.shape) == 3:
            gray = cv2.cvtColor(resized, cv2.COLOR_BGR2GRAY)
        else:
            gray = resized
        
        # EXACT training parameters from exact_training_benchmark.py
        features = hog(gray, 
                      orientations=9,
                      pixels_per_cell=(8, 8),
                      cells_per_block=(2, 2),
                      block_norm='L2-Hys',
                      feature_vector=True,
                      channel_axis=None)
        
        return features.astype(np.float32)
    
    def shannon_entropy(self, P):
        """Calculate Shannon entropy"""
        # Remove zeros to avoid log(0)
        P = P[P > 0]
        return -np.sum(P * np.log2(P))
    
    def extract_glcm_features(self, image):
        """Extract GLCM features with EXACT training parameters (20 features: 4 props×4 angles + 4 entropy)"""
        # Convert to grayscale
        if len(image.shape) == 3:
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        else:
            gray = image
        
        # Resize to 256x256 - CRITICAL: must match training!
        if gray.shape[0] > 256 or gray.shape[1] > 256:
            gray = cv2.resize(gray, (256, 256))
        
        # EXACT training parameters from exact_training_benchmark.py
        distances = [1]  # NOT [1,2,3]!
        angles = [0, 45, 90, 135]  # in degrees
        levels = 256
        
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
            entropy_val = self.shannon_entropy(P_avg)
            entropy_features.append(entropy_val)
        
        # Combine all features (16 Haralick + 4 entropy = 20)
        all_features = np.concatenate([haralick_features, entropy_features])
        
        return all_features.astype(np.float32)
    
    def extract_lbp_features(self, image):
        """Extract LBP features with EXACT training parameters (uniform, 10 bins)"""
        # Convert to grayscale
        if len(image.shape) == 3:
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        else:
            gray = image
        
        # Resize to 256x256 - CRITICAL: must match training!
        gray = cv2.resize(gray, (256, 256))
        
        # EXACT training parameters from exact_training_benchmark.py
        P = 8  # Number of points
        R = 1.0  # Radius
        method = 'uniform'
        bins = P + 2  # 10 bins for uniform method (NOT 256!)
        
        # Calculate LBP
        lbp = local_binary_pattern(gray, P, R, method=method)
        
        # Calculate histogram (exact from training)
        hist, _ = np.histogram(lbp.ravel(), bins=bins, range=(0, bins), density=True)
        
        return hist.astype(np.float32)
    
    def extract_hsv_features(self, image):
        """Extract HSV color features with EXACT training parameters (32 features: 16 bins for S + 16 bins for V)"""
        # Convert to HSV (handle both BGR and RGB)
        if len(image.shape) == 3:
            # Check if BGR or RGB based on opencv default
            hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
        else:
            raise ValueError("Image must be color (3 channels) for HSV extraction")
        
        # EXACT training parameters from exact_training_benchmark.py
        bins = 16  # 16 bins per channel
        channels = [1, 2]  # S and V channels only
        
        features = []
        for channel in channels:
            hist = cv2.calcHist([hsv], [channel], None, [bins], [0, 256])
            hist = hist.flatten() / (hist.sum() + 1e-7)  # Normalize with epsilon to avoid division by zero
            features.extend(hist)
        
        return np.array(features, dtype=np.float32)
    
    def detect_face(self, image):
        """Detect face in image using OpenCV"""
        face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        faces = face_cascade.detectMultiScale(gray, 1.1, 4)
        
        if len(faces) > 0:
            # Return the largest face
            largest_face = max(faces, key=lambda x: x[2] * x[3])
            x, y, w, h = largest_face
            return image[y:y+h, x:x+w], (x, y, w, h)
        return None, None
    
    def predict_ethnicity(self, image, model_name='glcm_lbp_hog_hsv'):
        """Predict ethnicity using specified model"""
        if model_name not in self.models:
            return None, 0.0
        
        # Detect face first
        face_image, face_coords = self.detect_face(image)
        if face_image is None:
            return None, 0.0
        
        # Extract features based on model (only extract what the model expects)
        features = []
        
        if model_name == 'hsv':
            # HSV model only needs HSV features (32 features)
            features.extend(self.extract_hsv_features(face_image))
        elif model_name == 'glcm_hog':
            # GLCM+HOG model needs both features
            features.extend(self.extract_glcm_features(face_image))
            features.extend(self.extract_hog_features(face_image))
        elif model_name == 'glcm_lbp_hog':
            # GLCM+LBP+HOG model needs all three features
            features.extend(self.extract_glcm_features(face_image))
            features.extend(self.extract_lbp_features(face_image))
            features.extend(self.extract_hog_features(face_image))
        elif model_name == 'glcm_lbp_hog_hsv':
            # GLCM+LBP+HOG+HSV model needs all features
            features.extend(self.extract_glcm_features(face_image))
            features.extend(self.extract_lbp_features(face_image))
            features.extend(self.extract_hog_features(face_image))
            features.extend(self.extract_hsv_features(face_image))
        else:
            print(f"⚠️ Unknown model: {model_name}")
            return None, 0.0
        
        features = np.array(features).reshape(1, -1)
        
        # Debug: Log feature count
        print(f"🔍 Extracted {features.shape[1]} features for model '{model_name}'")
        
        # Make prediction
        try:
            model = self.models[model_name]
            prediction = model.predict(features)[0]
            confidence = model.predict_proba(features).max()
            
            # Map prediction to ethnicity names (5 classes: Banjar, Bugis, Javanese, Malay, Sundanese)
            # Mapping: Javanese/Sundanese/Malay → Jawa, Banjar → Sasak, Bugis → Papua
            ethnicity_map = {
                0: "Sasak",     # Banjar
                1: "Papua",     # Bugis
                2: "Jawa",      # Javanese
                3: "Jawa",      # Malay
                4: "Jawa"       # Sundanese
            }
            
            ethnicity = ethnicity_map.get(prediction, "Unknown")
            return ethnicity, confidence
            
        except Exception as e:
            print(f"❌ Prediction error: {e}")
            return None, 0.0

class MLWebcamServer:
    def __init__(self, host='127.0.0.1', port=8888):
        # Load configuration
        self.config = self.load_config()
        
        self.host = self.config.get('server', {}).get('host', host)
        self.port = self.config.get('server', {}).get('port', port)
        self.server_socket = None
        self.clients = set()
        self.camera = None
        self.running = False
        self.sequence_number = 0
        
        # ML Detector - Use config path or fallback
        models_dir = self.config.get('ml', {}).get('models_dir', 'models/run_20250925_133309')
        models_path = Path(__file__).parent / models_dir
        print(f"🔍 Looking for models in: {models_path}")
        self.ml_detector = MLEthnicityDetector(str(models_path))
        
        # Use config default model or fallback
        self.current_model = self.config.get('ml', {}).get('default_model', 'hsv')
        self.detection_enabled = True
        
        # Log ML status
        self.log_ml_status()
        
        # Load server settings from config
        self.detection_interval = self.config.get('server', {}).get('detection_interval', 30)
        self.max_packet_size = self.config.get('performance', {}).get('max_packet_size', 32768)
        self.target_fps = self.config.get('server', {}).get('target_fps', 15)
        self.jpeg_quality = self.config.get('server', {}).get('jpeg_quality', 40)
        self.frame_width = self.config.get('server', {}).get('frame_width', 480)
        self.frame_height = self.config.get('server', {}).get('frame_height', 360)
        
        # Performance monitoring
        self.frame_send_time = 1.0 / self.target_fps
        self.frame_count = 0
        self.last_detection_result = None
        # detection_mode is set by log_ml_status() based on loaded models
    
    def load_config(self):
        """Load configuration from config.json"""
        config_path = Path(__file__).parent / "config.json"
        try:
            if config_path.exists():
                with open(config_path, 'r', encoding='utf-8') as f:
                    config = json.load(f)
                print(f"✅ Loaded configuration from: {config_path}")
                return config
            else:
                print(f"⚠️ Config file not found: {config_path}, using defaults")
                return {}
        except Exception as e:
            print(f"❌ Error loading config: {e}, using defaults")
            return {}
        
    def initialize_camera(self):
        print("🎥 Initializing ML-enhanced camera...")
        camera_id = self.config.get('camera', {}).get('camera_id', 0)
        self.camera = cv2.VideoCapture(camera_id, cv2.CAP_DSHOW)
        
        if self.camera.isOpened():
            self.camera.set(cv2.CAP_PROP_FRAME_WIDTH, self.frame_width)
            self.camera.set(cv2.CAP_PROP_FRAME_HEIGHT, self.frame_height)
            self.camera.set(cv2.CAP_PROP_FPS, self.target_fps)
            self.camera.set(cv2.CAP_PROP_BUFFERSIZE, 1)
            
            ret, frame = self.camera.read()
            if ret and frame is not None:
                print(f"✅ Camera ready: {self.frame_width}x{self.frame_height} @ {self.target_fps}FPS")
                print(f"🤖 ML Models loaded: {list(self.ml_detector.models.keys())}")
                return True
        
        print("❌ Camera initialization failed")
        return False
    
    def log_ml_status(self):
        """Log the current ML detection status"""
        loaded_models = list(self.ml_detector.models.keys())
        if loaded_models:
            self.detection_mode = "ML"
            print(f"🧠 ML Detection: ENABLED")
            print(f"📊 Available models: {loaded_models}")
            print(f"🎯 Using model: {self.current_model}")
            if self.current_model in loaded_models:
                print(f"✅ Selected model '{self.current_model}' is available")
            else:
                print(f"⚠️ Selected model '{self.current_model}' not found, using first available")
                self.current_model = loaded_models[0] if loaded_models else None
        else:
            self.detection_mode = "SIMULATION"
            print(f"🎭 ML Detection: DISABLED (No models loaded)")
            print(f"⚠️ Will use simulation mode")
    
    def log_detection_result(self, ethnicity, confidence, is_ml_result=True):
        """Log detection results with clear ML/Simulation indication"""
        mode = "🧠 ML DETECTION" if is_ml_result else "🎭 SIMULATION"
        print(f"{mode} Result: {ethnicity} (Confidence: {confidence:.1f}%)")
        self.last_detection_result = {
            'ethnicity': ethnicity,
            'confidence': confidence,
            'mode': mode,
            'timestamp': time.time()
        }
    
    def start_server(self):
        if not self.initialize_camera():
            return
        
        self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 655360)
        self.server_socket.bind((self.host, self.port))
        
        print(f"🚀 ML-Enhanced UDP Server: {self.host}:{self.port}")
        print(f"📊 Settings: {self.frame_width}x{self.frame_height}, {self.target_fps}FPS, Q{self.jpeg_quality}")
        print(f"🧠 ML Detection: {'Enabled' if self.detection_enabled else 'Disabled'}")
        
        self.running = True
        
        # Start threads
        threading.Thread(target=self.listen_for_clients, daemon=True).start()
        threading.Thread(target=self._broadcast_frames, daemon=True).start()
        
        try:
            while self.running:
                time.sleep(1)
        except KeyboardInterrupt:
            print("\n🛑 Server stopped")
        finally:
            self.stop_server()
    
    def listen_for_clients(self):
        self.server_socket.settimeout(1.0)
        
        while self.running:
            try:
                data, addr = self.server_socket.recvfrom(1024)
                message = data.decode('utf-8')
                
                if message == "REGISTER":
                    if addr not in self.clients:
                        self.clients.add(addr)
                        print(f"✅ Client: {addr} (Total: {len(self.clients)})")
                    
                    self.server_socket.sendto("REGISTERED".encode('utf-8'), addr)
                
                elif message == "UNREGISTER":
                    self.clients.discard(addr)
                    print(f"❌ Client left: {addr}")
                
                elif message.startswith("DETECTION_REQUEST"):
                    # Handle detection request from client
                    self.handle_detection_request(addr)
                
                elif message.startswith("MODEL_SELECT:"):
                    # Handle model selection
                    model_name = message.split(":")[1]
                    self.select_model(model_name, addr)
                    
            except socket.timeout:
                continue
            except Exception as e:
                if self.running:
                    print(f"⚠️ Client error: {e}")
    
    def handle_detection_request(self, addr):
        """Handle detection request from Godot client"""
        print(f"🔍 Detection request from {addr}")
        
        # Try to get current frame for detection
        if self.camera and self.camera.isOpened():
            ret, frame = self.camera.read()
            if ret and frame is not None:
                # Perform ML detection if models are loaded
                print(f"🔍 Debug: detection_mode='{self.detection_mode}', models_loaded={len(self.ml_detector.models)}")
                if self.detection_mode == "ML" and self.ml_detector.models:
                    print(f"🧠 Performing ML detection with model: {self.current_model}")
                    ethnicity, confidence = self.ml_detector.predict_ethnicity(frame, self.current_model)
                    
                    if ethnicity and confidence > 0:
                        # Real ML detection successful
                        self.log_detection_result(ethnicity, confidence * 100, is_ml_result=True)
                        result_data = {
                            'ethnicity': ethnicity,
                            'confidence': confidence,
                            'model': self.current_model,
                            'mode': 'ML',
                            'timestamp': time.time()
                        }
                    else:
                        # ML detection failed, use simulation
                        print("⚠️ ML detection failed, falling back to simulation")
                        ethnicity, confidence = self._get_simulation_result()
                        self.log_detection_result(ethnicity, confidence, is_ml_result=False)
                        result_data = {
                            'ethnicity': ethnicity,
                            'confidence': confidence,
                            'model': 'simulation',
                            'mode': 'SIMULATION',
                            'timestamp': time.time()
                        }
                else:
                    # No ML models loaded, use simulation
                    print("🎭 No ML models available, using simulation")
                    ethnicity, confidence = self._get_simulation_result()
                    self.log_detection_result(ethnicity, confidence, is_ml_result=False)
                    result_data = {
                        'ethnicity': ethnicity,
                        'confidence': confidence,
                        'model': 'simulation',
                        'mode': 'SIMULATION',
                        'timestamp': time.time()
                    }
                
                # Send result to client
                message = f"DETECTION_RESULT:{json.dumps(result_data)}"
                self.server_socket.sendto(message.encode('utf-8'), addr)
                print(f"📤 Sent detection result to {addr}: {result_data['ethnicity']} ({result_data['confidence']:.1f}%) - {result_data['mode']}")
                
                # Store result for future requests
                self.last_detection_result = (ethnicity, confidence)
            else:
                # No frame available, send error
                error_data = {'error': 'No camera frame available'}
                message = f"DETECTION_ERROR:{json.dumps(error_data)}"
                self.server_socket.sendto(message.encode('utf-8'), addr)
                print(f"❌ No camera frame available for detection")
        else:
            # Camera not available, send error
            error_data = {'error': 'Camera not available'}
            message = f"DETECTION_ERROR:{json.dumps(error_data)}"
            self.server_socket.sendto(message.encode('utf-8'), addr)
            print(f"❌ Camera not available for detection")
    
    def _get_simulation_result(self):
        """Get simulation result (fallback when ML fails)"""
        # Only include ethnicities that match the actual model output
        ethnicities = ["Jawa", "Sasak", "Papua"]  # Removed "Batak" as it's not in the model
        ethnicity = ethnicities[hash(str(time.time())) % len(ethnicities)]
        confidence = 0.80 + (hash(str(time.time())) % 20) / 100.0  # 80-99%
        return ethnicity, confidence
    
    def select_model(self, model_name, addr):
        """Select ML model for detection"""
        if model_name in self.ml_detector.models:
            self.current_model = model_name
            response = f"MODEL_SELECTED:{model_name}"
            self.server_socket.sendto(response.encode('utf-8'), addr)
            print(f"🧠 Model changed to: {model_name}")
        else:
            response = f"MODEL_ERROR:Model {model_name} not found"
            self.server_socket.sendto(response.encode('utf-8'), addr)
    
    def _broadcast_frames(self):
        last_frame_time = 0
        camera_paused = False
        
        while self.running:
            current_time = time.time()
            
            # ✅ FIX: Pause camera when no clients to save resources
            if len(self.clients) == 0:
                if not camera_paused:
                    print("⏸️  No clients connected - camera paused (saves CPU/bandwidth)")
                    camera_paused = True
                time.sleep(0.5)  # Check less frequently when idle
                continue
            
            # ✅ Resume camera when client connects
            if camera_paused:
                print(f"▶️  Client(s) connected ({len(self.clients)}) - camera resumed")
                camera_paused = False
                last_frame_time = 0  # Reset timing
            
            if current_time - last_frame_time < self.frame_send_time:
                time.sleep(0.01)
                continue
            
            ret, frame = self.camera.read()
            if not ret:
                break
            
            # ML Detection (every N frames)
            if self.detection_enabled and self.frame_count % self.detection_interval == 0:
                ethnicity, confidence = self.ml_detector.predict_ethnicity(frame, self.current_model)
                if ethnicity:
                    self.last_detection_result = (ethnicity, confidence)
                    print(f"🧠 Detection: {ethnicity} (confidence: {confidence:.2f})")
            
            self.frame_count += 1
            
            # Encode and send frame
            encode_param = [cv2.IMWRITE_JPEG_QUALITY, self.jpeg_quality]
            result, encoded_img = cv2.imencode('.jpg', frame, encode_param)
            
            if result:
                frame_data = encoded_img.tobytes()
                self.send_frame_to_clients(frame_data)
                last_frame_time = current_time
    
    def send_frame_to_clients(self, frame_data):
        if not frame_data or len(self.clients) == 0:
            return
        
        self.sequence_number = (self.sequence_number + 1) % 65536
        frame_size = len(frame_data)
        
        header_size = 12
        payload_size = self.max_packet_size - header_size
        total_packets = math.ceil(frame_size / payload_size)
        
        for client_addr in self.clients.copy():
            try:
                for packet_index in range(total_packets):
                    start_pos = packet_index * payload_size
                    end_pos = min(start_pos + payload_size, frame_size)
                    
                    header = struct.pack("!III", self.sequence_number, total_packets, packet_index)
                    udp_packet = header + frame_data[start_pos:end_pos]
                    
                    self.server_socket.sendto(udp_packet, client_addr)
                
                if self.sequence_number % 60 == 1:
                    print(f"📤 Frame {self.sequence_number}: {frame_size//1024}KB → {len(self.clients)} clients")
                    
            except Exception as e:
                print(f"❌ Send error {client_addr}: {e}")
                self.clients.discard(client_addr)
    
    def stop_server(self):
        print("⏹️ Stopping ML server...")
        self.running = False
        
        if self.server_socket:
            self.server_socket.close()
        if self.camera:
            self.camera.release()
        
        print("✅ ML server stopped")

if __name__ == "__main__":
    print("=== ML-Enhanced UDP Webcam Server ===")
    server = MLWebcamServer()
    server.start_server()
