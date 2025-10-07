#!/usr/bin/env python3
"""
ML-Enhanced UDP Webcam Server - SOLID Architecture Implementation
Refactored using SOLID principles with comprehensive logging
"""

import cv2
import threading
import time
import json
from typing import Optional, Dict, Any
from ..core.logger import logger
from ..core.config_manager import ConfigManager
from ..camera.camera_interface import ICamera, CameraFactory
from ..network.udp_server import IUDPServer, UDPServerFactory
from ..ml.ethnicity_detector import MLEthnicityDetector


class MLWebcamServer:
    """
    Main ML-Enhanced Webcam Server
    Following SOLID principles with dependency injection and composition
    """
    
    def __init__(self, config_file: str = "config.json"):
        # Load configuration
        self.config_manager = ConfigManager(config_file)
        
        # Get server configuration
        server_config = self.config_manager.get_server_config()
        self.host = server_config.get("host", "127.0.0.1")
        self.port = server_config.get("port", 8888)
        self.frame_width = server_config.get("frame_width", 480)
        self.frame_height = server_config.get("frame_height", 360)
        self.target_fps = server_config.get("target_fps", 15)
        self.jpeg_quality = server_config.get("jpeg_quality", 40)
        self.detection_interval = server_config.get("detection_interval", 30)
        
        # Dependencies (Dependency Injection)
        self.camera: Optional[ICamera] = None
        self.udp_server: Optional[IUDPServer] = None
        self.ethnicity_detector: Optional[MLEthnicityDetector] = None
        
        # Server state
        self.running = False
        self.frame_count = 0
        self.current_model = self.config_manager.get_default_model()
        
        # Performance settings
        self.frame_send_time = 1.0 / self.target_fps
        
        # Threading
        self._broadcast_thread: Optional[threading.Thread] = None
        
        logger.info(f"ML Webcam Server initialized: {self.host}:{self.port}")
    
    def initialize(self) -> bool:
        """Initialize all server components"""
        try:
            logger.info("Initializing ML Webcam Server components...")
            
            # Get camera configuration
            camera_config = self.config_manager.get_camera_config()
            camera_id = camera_config.get("camera_id", 0)
            
            # Initialize camera
            self.camera = CameraFactory.create_camera("opencv", camera_id=camera_id)
            if not self.camera.initialize():
                logger.error("Camera initialization failed")
                return False
            
            # Set camera properties
            self.camera.set_resolution(self.frame_width, self.frame_height)
            self.camera.set_fps(self.target_fps)
            
            # Initialize UDP server
            self.udp_server = UDPServerFactory.create_server("video")
            if not self.udp_server.start(self.host, self.port):
                logger.error("UDP server initialization failed")
                return False
            
            # Initialize ML detector with config
            self.ethnicity_detector = MLEthnicityDetector.create_default_detector(self.config_manager)
            
            logger.info("All components initialized successfully")
            return True
            
        except Exception as e:
            logger.error(f"Server initialization failed: {e}")
            return False
    
    def start(self) -> None:
        """Start the ML webcam server"""
        if not self.initialize():
            logger.error("Failed to initialize server")
            return
        
        self.running = True
        
        # Log server information
        available_models = self.ethnicity_detector.get_available_models()
        camera_props = self.camera.get_properties()
        
        logger.info(f"🚀 ML-Enhanced UDP Server: {self.host}:{self.port}")
        logger.info(f"📊 Settings: {self.frame_width}x{self.frame_height}, {self.target_fps}FPS, Q{self.jpeg_quality}")
        logger.info(f"🧠 ML Models loaded: {available_models}")
        logger.info(f"📹 Camera: {camera_props.get('width', 'N/A')}x{camera_props.get('height', 'N/A')} @ {camera_props.get('fps', 'N/A')}FPS")
        
        # Start frame broadcasting thread
        self._broadcast_thread = threading.Thread(target=self._broadcast_frames, daemon=True)
        self._broadcast_thread.start()
        
        try:
            # Main server loop
            while self.running:
                time.sleep(1)
                
                # Log server status periodically
                if self.frame_count % 300 == 0:  # Every 300 frames (~20 seconds at 15fps)
                    self._log_server_status()
                    
        except KeyboardInterrupt:
            logger.info("🛑 Server stopped by user")
        except Exception as e:
            logger.error(f"Server error: {e}")
        finally:
            self.stop()
    
    def _broadcast_frames(self) -> None:
        """Broadcast frames to connected clients"""
        last_frame_time = 0
        
        while self.running:
            try:
                current_time = time.time()
                
                # Check if we have clients
                if self.udp_server.get_client_count() == 0:
                    time.sleep(0.1)
                    continue
                
                # Frame rate control
                if current_time - last_frame_time < self.frame_send_time:
                    time.sleep(0.01)
                    continue
                
                # Read frame from camera
                ret, frame = self.camera.read_frame()
                if not ret:
                    logger.warning("Failed to read frame from camera")
                    continue
                
                # ML Detection (every N frames)
                if self.frame_count % self.detection_interval == 0:
                    self._perform_ml_detection(frame)
                
                self.frame_count += 1
                
                # Encode frame
                encode_param = [cv2.IMWRITE_JPEG_QUALITY, self.jpeg_quality]
                result, encoded_img = cv2.imencode('.jpg', frame, encode_param)
                
                if result:
                    frame_data = encoded_img.tobytes()
                    self.udp_server.send_video_frame(frame_data)
                    last_frame_time = current_time
                else:
                    logger.warning("Failed to encode frame")
                    
            except Exception as e:
                logger.error(f"Frame broadcasting error: {e}")
                time.sleep(0.1)
    
    def _perform_ml_detection(self, frame) -> None:
        """Perform ML ethnicity detection on frame"""
        try:
            ethnicity, confidence = self.ethnicity_detector.predict_ethnicity(frame, self.current_model)
            
            if ethnicity:
                # Send detection result to all clients
                result_data = {
                    'ethnicity': ethnicity,
                    'confidence': confidence,
                    'model': self.current_model,
                    'timestamp': time.time()
                }
                
                # Broadcast to all clients
                for client_addr in self.udp_server.get_connected_clients():
                    self.udp_server.send_detection_result(client_addr, result_data)
                    
        except Exception as e:
            logger.error(f"ML detection error: {e}")
    
    def _log_server_status(self) -> None:
        """Log server status information"""
        try:
            client_count = self.udp_server.get_client_count()
            perf_stats = self.ethnicity_detector.get_performance_stats()
            
            logger.info(f"📊 Server Status: {client_count} clients, {self.frame_count} frames processed")
            logger.info(f"🧠 ML Stats: {perf_stats['total_detections']} detections, avg {perf_stats['average_time']:.3f}s")
            
        except Exception as e:
            logger.error(f"Status logging error: {e}")
    
    def stop(self) -> None:
        """Stop the ML webcam server"""
        logger.info("⏹️ Stopping ML server...")
        self.running = False
        
        # Stop UDP server
        if self.udp_server:
            self.udp_server.stop()
        
        # Release camera
        if self.camera:
            self.camera.release()
        
        # Wait for broadcast thread
        if self._broadcast_thread and self._broadcast_thread.is_alive():
            self._broadcast_thread.join(timeout=2.0)
        
        logger.info("✅ ML server stopped")
    
    def get_server_info(self) -> Dict[str, Any]:
        """Get server information"""
        return {
            'host': self.host,
            'port': self.port,
            'running': self.running,
            'frame_count': self.frame_count,
            'client_count': self.udp_server.get_client_count() if self.udp_server else 0,
            'available_models': self.ethnicity_detector.get_available_models() if self.ethnicity_detector else [],
            'current_model': self.current_model,
            'camera_properties': self.camera.get_properties() if self.camera else {},
            'performance_stats': self.ethnicity_detector.get_performance_stats() if self.ethnicity_detector else {}
        }


def main():
    """Main function to run the ML webcam server"""
    print("=== ML-Enhanced UDP Webcam Server (SOLID Architecture) ===")
    
    # Create and start server
    server = MLWebcamServer()
    
    try:
        server.start()
    except Exception as e:
        logger.critical(f"Server startup failed: {e}")
    finally:
        server.stop()


if __name__ == "__main__":
    main()
