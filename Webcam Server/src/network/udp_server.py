#!/usr/bin/env python3
"""
UDP Server Interface and Implementation
Following SOLID principles with abstract interfaces
"""

import socket
import struct
import threading
import time
import math
import json
from abc import ABC, abstractmethod
from typing import Set, Tuple, Optional, Dict, Any, Callable
from ..core.logger import logger


class IUDPServer(ABC):
    """Abstract interface for UDP server operations (Interface Segregation Principle)"""
    
    @abstractmethod
    def start(self, host: str, port: int) -> bool:
        """Start UDP server"""
        pass
    
    @abstractmethod
    def stop(self) -> None:
        """Stop UDP server"""
        pass
    
    @abstractmethod
    def send_to_client(self, client_addr: Tuple[str, int], data: bytes) -> bool:
        """Send data to specific client"""
        pass
    
    @abstractmethod
    def broadcast_to_all(self, data: bytes) -> None:
        """Broadcast data to all connected clients"""
        pass
    
    @abstractmethod
    def get_connected_clients(self) -> Set[Tuple[str, int]]:
        """Get set of connected client addresses"""
        pass
    
    @abstractmethod
    def is_running(self) -> bool:
        """Check if server is running"""
        pass


class UDPVideoServer(IUDPServer):
    """UDP server implementation for video streaming"""
    
    def __init__(self, max_packet_size: int = 32768):
        self.max_packet_size = max_packet_size
        self.server_socket: Optional[socket.socket] = None
        self.clients: Set[Tuple[str, int]] = set()
        self.running = False
        self.sequence_number = 0
        self._lock = threading.Lock()
        self._listen_thread: Optional[threading.Thread] = None
        
        # Message handlers
        self.message_handlers: Dict[str, Callable] = {}
        self._setup_default_handlers()
        
        logger.info(f"UDP video server initialized with max packet size {max_packet_size}")
    
    def _setup_default_handlers(self) -> None:
        """Setup default message handlers"""
        self.message_handlers = {
            "REGISTER": self._handle_register,
            "UNREGISTER": self._handle_unregister,
            "DETECTION_REQUEST": self._handle_detection_request,
        }
    
    def start(self, host: str, port: int) -> bool:
        """Start UDP server"""
        try:
            self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 655360)
            self.server_socket.bind((host, port))
            
            self.running = True
            
            # Start listening thread
            self._listen_thread = threading.Thread(target=self._listen_for_clients, daemon=True)
            self._listen_thread.start()
            
            logger.info(f"UDP server started on {host}:{port}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to start UDP server: {e}")
            return False
    
    def stop(self) -> None:
        """Stop UDP server"""
        logger.info("Stopping UDP server...")
        self.running = False
        
        if self.server_socket:
            self.server_socket.close()
            self.server_socket = None
        
        if self._listen_thread and self._listen_thread.is_alive():
            self._listen_thread.join(timeout=1.0)
        
        with self._lock:
            self.clients.clear()
        
        logger.info("UDP server stopped")
    
    def _listen_for_clients(self) -> None:
        """Listen for client messages in separate thread"""
        if not self.server_socket:
            return
        
        self.server_socket.settimeout(1.0)
        
        while self.running:
            try:
                data, addr = self.server_socket.recvfrom(1024)
                message = data.decode('utf-8')
                
                # Handle different message types
                if message.startswith("MODEL_SELECT:"):
                    self._handle_model_select(message, addr)
                elif message in self.message_handlers:
                    self.message_handlers[message](addr)
                else:
                    logger.warning(f"Unknown message from {addr}: {message}")
                    
            except socket.timeout:
                continue
            except Exception as e:
                if self.running:
                    logger.error(f"Error in client listener: {e}")
    
    def _handle_register(self, addr: Tuple[str, int]) -> None:
        """Handle client registration"""
        with self._lock:
            if addr not in self.clients:
                self.clients.add(addr)
                logger.log_client_connection("REGISTERED", f"{addr[0]}:{addr[1]}")
            
            # Send registration confirmation
            response = "REGISTERED".encode('utf-8')
            self.server_socket.sendto(response, addr)
    
    def _handle_unregister(self, addr: Tuple[str, int]) -> None:
        """Handle client unregistration"""
        with self._lock:
            self.clients.discard(addr)
            logger.log_client_connection("UNREGISTERED", f"{addr[0]}:{addr[1]}")
    
    def _handle_detection_request(self, addr: Tuple[str, int]) -> None:
        """Handle detection request from client"""
        # This will be handled by the main server
        logger.debug(f"Detection request from {addr}")
    
    def _handle_model_select(self, message: str, addr: Tuple[str, int]) -> None:
        """Handle model selection request"""
        try:
            model_name = message.split(":", 1)[1]
            
            # Send model selection confirmation
            response = f"MODEL_SELECTED:{model_name}".encode('utf-8')
            self.server_socket.sendto(response, addr)
            
            logger.log_model_operation("SELECTED", model_name, client=addr)
            
        except Exception as e:
            error_response = f"MODEL_ERROR:Invalid model selection".encode('utf-8')
            self.server_socket.sendto(error_response, addr)
            logger.error(f"Model selection error from {addr}: {e}")
    
    def send_to_client(self, client_addr: Tuple[str, int], data: bytes) -> bool:
        """Send data to specific client"""
        if not self.server_socket or not self.running:
            return False
        
        try:
            self.server_socket.sendto(data, client_addr)
            return True
        except Exception as e:
            logger.error(f"Failed to send data to {client_addr}: {e}")
            # Remove client if send fails
            with self._lock:
                self.clients.discard(client_addr)
            return False
    
    def broadcast_to_all(self, data: bytes) -> None:
        """Broadcast data to all connected clients"""
        if not self.server_socket or not self.running:
            return
        
        with self._lock:
            clients_copy = self.clients.copy()
        
        for client_addr in clients_copy:
            if not self.send_to_client(client_addr, data):
                logger.warning(f"Failed to send to client {client_addr}")
    
    def send_video_frame(self, frame_data: bytes) -> None:
        """Send video frame to all clients using packet fragmentation"""
        if not frame_data or not self.running:
            return
        
        with self._lock:
            if not self.clients:
                return
            
            clients_copy = self.clients.copy()
        
        self.sequence_number = (self.sequence_number + 1) % 65536
        frame_size = len(frame_data)
        
        header_size = 12
        payload_size = self.max_packet_size - header_size
        total_packets = math.ceil(frame_size / payload_size)
        
        for client_addr in clients_copy:
            try:
                for packet_index in range(total_packets):
                    start_pos = packet_index * payload_size
                    end_pos = min(start_pos + payload_size, frame_size)
                    
                    header = struct.pack("!III", self.sequence_number, total_packets, packet_index)
                    udp_packet = header + frame_data[start_pos:end_pos]
                    
                    self.server_socket.sendto(udp_packet, client_addr)
                
                # Log frame sending periodically
                if self.sequence_number % 60 == 1:
                    logger.info(f"Frame {self.sequence_number}: {frame_size//1024}KB → {len(clients_copy)} clients")
                    
            except Exception as e:
                logger.error(f"Send error to {client_addr}: {e}")
                with self._lock:
                    self.clients.discard(client_addr)
    
    def send_detection_result(self, client_addr: Tuple[str, int], result_data: Dict[str, Any]) -> None:
        """Send detection result to specific client"""
        try:
            message = f"DETECTION_RESULT:{json.dumps(result_data)}"
            self.send_to_client(client_addr, message.encode('utf-8'))
            logger.log_detection_result(
                result_data.get('ethnicity', 'Unknown'),
                result_data.get('confidence', 0.0),
                result_data.get('model', 'unknown'),
                client=client_addr
            )
        except Exception as e:
            logger.error(f"Failed to send detection result to {client_addr}: {e}")
    
    def get_connected_clients(self) -> Set[Tuple[str, int]]:
        """Get set of connected client addresses"""
        with self._lock:
            return self.clients.copy()
    
    def is_running(self) -> bool:
        """Check if server is running"""
        return self.running
    
    def get_client_count(self) -> int:
        """Get number of connected clients"""
        with self._lock:
            return len(self.clients)


class UDPServerFactory:
    """Factory for creating UDP servers"""
    
    @staticmethod
    def create_server(server_type: str = "video", **kwargs) -> IUDPServer:
        """Create UDP server based on type"""
        servers = {
            'video': UDPVideoServer
        }
        
        if server_type.lower() not in servers:
            raise ValueError(f"Unknown server type: {server_type}")
        
        server_class = servers[server_type.lower()]
        logger.info(f"Creating {server_type} UDP server")
        
        return server_class(**kwargs)
