#!/usr/bin/env python3
"""
Launcher script for ML-Enhanced UDP Webcam Server
Uses the refactored SOLID architecture implementation
"""

import sys
import os
from pathlib import Path

# Add src directory to Python path
src_dir = Path(__file__).parent / "src"
sys.path.insert(0, str(src_dir))

from src.server.ml_webcam_server import main

if __name__ == "__main__":
    main()
