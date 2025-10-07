#!/usr/bin/env python3
"""
Configuration Management Script for ML Webcam Server
Allows easy modification of server configuration
"""

import sys
import json
from pathlib import Path

# Add src directory to Python path
src_dir = Path(__file__).parent / "src"
sys.path.insert(0, str(src_dir))

from src.core.config_manager import ConfigManager


def show_config():
    """Display current configuration"""
    print("=== Current Configuration ===")
    config_manager = ConfigManager()
    
    # Server config
    server_config = config_manager.get_server_config()
    print(f"\n📡 Server Configuration:")
    print(f"  Host: {server_config.get('host')}")
    print(f"  Port: {server_config.get('port')}")
    print(f"  Resolution: {server_config.get('frame_width')}x{server_config.get('frame_height')}")
    print(f"  FPS: {server_config.get('target_fps')}")
    print(f"  JPEG Quality: {server_config.get('jpeg_quality')}")
    print(f"  Detection Interval: {server_config.get('detection_interval')} frames")
    
    # ML config
    ml_config = config_manager.get_ml_config()
    print(f"\n🧠 ML Configuration:")
    print(f"  Models Directory: {ml_config.get('models_dir')}")
    print(f"  Default Model: {ml_config.get('default_model')}")
    
    # Available models
    available_models = config_manager.get_available_models()
    print(f"\n📋 Available Models ({len(available_models)}):")
    for model in available_models:
        status = "✅ Enabled" if model.get('enabled', True) else "❌ Disabled"
        print(f"  {model.get('name')}: {model.get('display_name')} {status}")
        print(f"    Description: {model.get('description')}")
        print(f"    Features: {', '.join(model.get('features', []))}")
    
    # Camera config
    camera_config = config_manager.get_camera_config()
    print(f"\n📹 Camera Configuration:")
    print(f"  Camera ID: {camera_config.get('camera_id')}")
    print(f"  Backend: {camera_config.get('backend')}")
    print(f"  Auto Resize: {camera_config.get('auto_resize')}")
    
    # Logging config
    logging_config = config_manager.get_logging_config()
    print(f"\n📝 Logging Configuration:")
    print(f"  Log Directory: {logging_config.get('log_dir')}")
    print(f"  Log Level: {logging_config.get('log_level')}")
    print(f"  Console Output: {logging_config.get('console_output')}")
    print(f"  File Output: {logging_config.get('file_output')}")


def set_default_model(model_name: str):
    """Set the default model"""
    config_manager = ConfigManager()
    
    # Check if model exists and is enabled
    if not config_manager.is_model_enabled(model_name):
        print(f"❌ Model '{model_name}' is not available or not enabled")
        return False
    
    # Update default model
    if config_manager.update_config("ml", "default_model", model_name):
        if config_manager.save_config():
            print(f"✅ Default model set to: {model_name}")
            return True
        else:
            print("❌ Failed to save configuration")
            return False
    else:
        print("❌ Failed to update configuration")
        return False


def enable_model(model_name: str, enabled: bool = True):
    """Enable or disable a model"""
    config_manager = ConfigManager()
    
    # Find the model in available models
    models = config_manager.get_available_models()
    model_found = False
    
    for model in models:
        if model.get("name") == model_name:
            model["enabled"] = enabled
            model_found = True
            break
    
    if not model_found:
        print(f"❌ Model '{model_name}' not found")
        return False
    
    # Update the config
    config_manager.config["ml"]["available_models"] = models
    
    if config_manager.save_config():
        status = "enabled" if enabled else "disabled"
        print(f"✅ Model '{model_name}' {status}")
        return True
    else:
        print("❌ Failed to save configuration")
        return False


def set_server_setting(key: str, value):
    """Set a server setting"""
    config_manager = ConfigManager()
    
    # Validate and convert value
    if key in ["port", "frame_width", "frame_height", "target_fps", "jpeg_quality", "detection_interval"]:
        try:
            value = int(value)
        except ValueError:
            print(f"❌ Invalid value for {key}: must be an integer")
            return False
    
    if key in ["host"]:
        if not isinstance(value, str):
            print(f"❌ Invalid value for {key}: must be a string")
            return False
    
    # Update the setting
    if config_manager.update_config("server", key, value):
        if config_manager.save_config():
            print(f"✅ Server setting updated: {key} = {value}")
            return True
        else:
            print("❌ Failed to save configuration")
            return False
    else:
        print("❌ Failed to update configuration")
        return False


def validate_config():
    """Validate the configuration"""
    print("=== Configuration Validation ===")
    config_manager = ConfigManager()
    
    if config_manager.validate_config():
        print("✅ Configuration is valid")
        
        # Additional checks
        models_dir = config_manager.get_models_dir()
        if Path(models_dir).exists():
            print(f"✅ Models directory exists: {models_dir}")
        else:
            print(f"⚠️ Models directory not found: {models_dir}")
        
        return True
    else:
        print("❌ Configuration validation failed")
        return False


def main():
    """Main function"""
    if len(sys.argv) < 2:
        print("Usage: python manage_config.py <command> [args...]")
        print("\nCommands:")
        print("  show                     - Show current configuration")
        print("  validate                 - Validate configuration")
        print("  set-default <model>      - Set default model")
        print("  enable <model>           - Enable a model")
        print("  disable <model>          - Disable a model")
        print("  set-server <key> <value> - Set server setting")
        print("\nExamples:")
        print("  python manage_config.py show")
        print("  python manage_config.py set-default glcm_lbp_hog_hsv")
        print("  python manage_config.py enable glcm_hog")
        print("  python manage_config.py set-server port 9999")
        return
    
    command = sys.argv[1].lower()
    
    if command == "show":
        show_config()
    
    elif command == "validate":
        validate_config()
    
    elif command == "set-default":
        if len(sys.argv) < 3:
            print("❌ Usage: python manage_config.py set-default <model_name>")
            return
        model_name = sys.argv[2]
        set_default_model(model_name)
    
    elif command == "enable":
        if len(sys.argv) < 3:
            print("❌ Usage: python manage_config.py enable <model_name>")
            return
        model_name = sys.argv[2]
        enable_model(model_name, True)
    
    elif command == "disable":
        if len(sys.argv) < 3:
            print("❌ Usage: python manage_config.py disable <model_name>")
            return
        model_name = sys.argv[2]
        enable_model(model_name, False)
    
    elif command == "set-server":
        if len(sys.argv) < 4:
            print("❌ Usage: python manage_config.py set-server <key> <value>")
            return
        key = sys.argv[2]
        value = sys.argv[3]
        set_server_setting(key, value)
    
    else:
        print(f"❌ Unknown command: {command}")
        print("Use 'python manage_config.py' without arguments to see usage")


if __name__ == "__main__":
    main()
