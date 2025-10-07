#!/usr/bin/env python3
"""
Thread-safe Singleton Logger Implementation
Based on SOLID principles with comprehensive logging capabilities
"""

import logging
import os
import datetime
import threading
from abc import ABC, abstractmethod
from pathlib import Path
from typing import Optional


class ThreadSafeSingleton:
    """Thread-safe singleton implementation"""
    _instance = None
    _lock = threading.Lock()

    def __new__(cls, *args, **kwargs):
        if cls._instance is None:
            with cls._lock:
                if cls._instance is None:
                    cls._instance = super().__new__(cls)
        return cls._instance


class ILogger(ABC):
    """Abstract logger interface (Interface Segregation Principle)"""
    
    @abstractmethod
    def debug(self, message: str, **kwargs) -> None:
        pass
    
    @abstractmethod
    def info(self, message: str, **kwargs) -> None:
        pass
    
    @abstractmethod
    def warning(self, message: str, **kwargs) -> None:
        pass
    
    @abstractmethod
    def error(self, message: str, **kwargs) -> None:
        pass
    
    @abstractmethod
    def critical(self, message: str, **kwargs) -> None:
        pass


class MLServerLogger(ThreadSafeSingleton, ILogger):
    """Thread-safe singleton logger for ML server"""
    
    def __init__(self, log_dir: str = "logs"):
        if not hasattr(self, '_initialized'):
            self._logger: Optional[logging.Logger] = None
            self._log_dir = Path(log_dir)
            self._setup_logger()
            self._initialized = True
    
    def _setup_logger(self) -> None:
        """Setup logger with file and console handlers"""
        # Create logs directory if it doesn't exist
        self._log_dir.mkdir(exist_ok=True)
        
        # Create logger
        self._logger = logging.getLogger('ml_server')
        self._logger.setLevel(logging.DEBUG)
        
        # Clear existing handlers
        self._logger.handlers.clear()
        
        # Create formatters
        detailed_formatter = logging.Formatter(
            '%(asctime)s | %(name)s | %(levelname)s | %(funcName)s:%(lineno)d | %(message)s'
        )
        simple_formatter = logging.Formatter(
            '%(asctime)s | %(levelname)s | %(message)s'
        )
        
        # File handler for all logs
        log_file = self._log_dir / f"ml_server_{datetime.datetime.now().strftime('%Y%m%d')}.log"
        file_handler = logging.FileHandler(log_file, encoding='utf-8')
        file_handler.setLevel(logging.DEBUG)
        file_handler.setFormatter(detailed_formatter)
        
        # Console handler for INFO and above
        console_handler = logging.StreamHandler()
        console_handler.setLevel(logging.INFO)
        console_handler.setFormatter(simple_formatter)
        
        # Error file handler
        error_log_file = self._log_dir / f"ml_server_errors_{datetime.datetime.now().strftime('%Y%m%d')}.log"
        error_handler = logging.FileHandler(error_log_file, encoding='utf-8')
        error_handler.setLevel(logging.ERROR)
        error_handler.setFormatter(detailed_formatter)
        
        # Add handlers
        self._logger.addHandler(file_handler)
        self._logger.addHandler(console_handler)
        self._logger.addHandler(error_handler)
        
        # Prevent propagation to root logger
        self._logger.propagate = False
    
    def debug(self, message: str, **kwargs) -> None:
        """Log debug message"""
        if self._logger:
            self._logger.debug(self._format_message(message, **kwargs))
    
    def info(self, message: str, **kwargs) -> None:
        """Log info message"""
        if self._logger:
            self._logger.info(self._format_message(message, **kwargs))
    
    def warning(self, message: str, **kwargs) -> None:
        """Log warning message"""
        if self._logger:
            self._logger.warning(self._format_message(message, **kwargs))
    
    def error(self, message: str, **kwargs) -> None:
        """Log error message"""
        if self._logger:
            self._logger.error(self._format_message(message, **kwargs))
    
    def critical(self, message: str, **kwargs) -> None:
        """Log critical message"""
        if self._logger:
            self._logger.critical(self._format_message(message, **kwargs))
    
    def _format_message(self, message: str, **kwargs) -> str:
        """Format message with additional context"""
        if kwargs:
            context = " | ".join([f"{k}={v}" for k, v in kwargs.items()])
            return f"{message} | {context}"
        return message
    
    def log_performance(self, operation: str, duration: float, **kwargs) -> None:
        """Log performance metrics"""
        self.info(f"Performance | {operation} completed in {duration:.3f}s", **kwargs)
    
    def log_detection_result(self, ethnicity: str, confidence: float, model: str, **kwargs) -> None:
        """Log ML detection results"""
        self.info(f"Detection | {ethnicity} ({confidence:.2f}) using {model}", **kwargs)
    
    def log_client_connection(self, action: str, client_addr: str, **kwargs) -> None:
        """Log client connection events"""
        self.info(f"Client | {action} | {client_addr}", **kwargs)
    
    def log_model_operation(self, operation: str, model_name: str, **kwargs) -> None:
        """Log model-related operations"""
        self.info(f"Model | {operation} | {model_name}", **kwargs)


# Global logger instance (singleton)
logger = MLServerLogger()
