#!/usr/bin/env python3
"""
Camera Detection Utility
Detects all available webcams connected to the system
"""

import cv2
import sys

def detect_cameras(max_cameras=10):
    """
    Detect all available cameras by testing camera IDs 0 through max_cameras-1
    
    Args:
        max_cameras: Maximum number of camera IDs to test (default: 10)
        
    Returns:
        List of available camera IDs with details
    """
    available_cameras = []
    
    print("🔍 Detecting available webcams...")
    print("=" * 60)
    
    for camera_id in range(max_cameras):
        try:
            # Try to open camera with DSHOW backend (Windows)
            cap = cv2.VideoCapture(camera_id, cv2.CAP_DSHOW)
            
            if cap.isOpened():
                # Try to read a frame to confirm camera is working
                ret, frame = cap.read()
                
                if ret and frame is not None:
                    # Get camera properties
                    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
                    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
                    fps = int(cap.get(cv2.CAP_PROP_FPS))
                    
                    # Try to determine if USB or internal
                    # Usually internal cameras are lower ID (0), USB cameras are higher (1, 2, etc.)
                    camera_type = "🖥️  Internal (likely)" if camera_id == 0 else "🔌 USB (likely)"
                    
                    available_cameras.append({
                        'id': camera_id,
                        'width': width,
                        'height': height,
                        'fps': fps,
                        'type': camera_type
                    })
                    
                    print(f"✅ Camera {camera_id}: {width}x{height} @ {fps}FPS - {camera_type}")
                else:
                    print(f"⚠️  Camera {camera_id}: Opened but failed to read frame")
                
                cap.release()
            else:
                # Camera ID not available (this is normal for unused IDs)
                pass
                
        except Exception as e:
            print(f"❌ Error testing camera {camera_id}: {e}")
    
    print("=" * 60)
    print(f"📊 Found {len(available_cameras)} working camera(s)")
    
    return available_cameras

def print_camera_recommendations(cameras):
    """Print recommendations for dual server setup"""
    print("\n📋 DUAL SERVER SETUP RECOMMENDATIONS")
    print("=" * 60)
    
    if len(cameras) == 0:
        print("❌ No cameras detected!")
        print("   Please check your USB webcam connections.")
        
    elif len(cameras) == 1:
        print("⚠️  Only 1 camera detected!")
        camera = cameras[0]
        print(f"   Camera ID {camera['id']}: {camera.get('type', 'Unknown')}")
        print("\n💡 You need 2 cameras for dual server setup:")
        print("   Option 1: Connect a second USB webcam (recommended)")
        print("   Option 2: Use single camera mode (not recommended)")
        
    else:
        # Check if we have internal + USB cameras
        has_internal = any(cam['id'] == 0 for cam in cameras)
        usb_cameras = [cam for cam in cameras if cam['id'] > 0]
        
        print(f"✅ {len(cameras)} cameras detected!")
        
        if has_internal and len(usb_cameras) >= 2:
            print("\n⚠️  IMPORTANT: Internal camera detected!")
            print(f"   Camera 0: {cameras[0].get('type', 'Unknown')}")
            print("   To use USB cameras only:")
            print(f"      • ML Server: Camera ID {usb_cameras[0]['id']} (First USB)")
            print(f"      • Topeng Server: Camera ID {usb_cameras[1]['id']} (Second USB)")
            print("\n📝 Update configuration:")
            print("   1. Webcam Server/config.json:")
            print(f'      "camera_id": {usb_cameras[0]["id"]}')
            print("   2. Topeng Server/start_topeng_mask_server.bat:")
            print(f'      --camera_id {usb_cameras[1]["id"]}')
            
        elif has_internal and len(usb_cameras) == 1:
            print("\n⚠️  WARNING: Only 1 USB camera + internal camera")
            print(f"   Camera 0: Internal camera")
            print(f"   Camera {usb_cameras[0]['id']}: USB camera")
            print("\n💡 Recommendations:")
            print("   • Connect second USB webcam for best results")
            print("   • OR use internal + USB (may have issues)")
            
        else:
            # Likely 2+ USB cameras without internal
            print("\n🎯 Recommended configuration (USB cameras):")
            print(f"   • ML Server (Ethnicity Detection): Camera ID {cameras[0]['id']}")
            print(f"   • Topeng Server (Mask Overlay): Camera ID {cameras[1]['id']}")
            
            if len(cameras) > 2:
                print(f"\n📌 Note: {len(cameras) - 2} additional camera(s) detected")
                print("   Available IDs:", [cam['id'] for cam in cameras[2:]])
            
            print("\n📝 Configuration files:")
            print("   1. Webcam Server/config.json:")
            print(f'      "camera_id": {cameras[0]["id"]}')
            print("   2. Topeng Server startup script:")
            print(f'      --camera_id {cameras[1]["id"]}')
    
    print("=" * 60)

def main():
    """Main function"""
    print("🎥 USB Webcam Detection Tool")
    print("   For ISSAT Game Dual Server Setup")
    print()
    
    # Detect cameras
    cameras = detect_cameras(max_cameras=10)
    
    # Print recommendations
    print_camera_recommendations(cameras)
    
    # Print detailed info
    if cameras:
        print("\n📊 DETAILED CAMERA INFORMATION")
        print("=" * 60)
        for cam in cameras:
            print(f"Camera ID: {cam['id']} - {cam.get('type', 'Unknown')}")
            print(f"  Resolution: {cam['width']}x{cam['height']}")
            print(f"  FPS: {cam['fps']}")
            print()
        
        # Additional tips
        print("💡 TIPS:")
        print("   • Camera ID 0 is usually the internal/built-in camera")
        print("   • USB cameras typically have IDs 1, 2, 3, etc.")
        print("   • For best results, use 2 USB webcams (not internal)")
        print("   • Disconnect internal camera in BIOS if you want USB to be ID 0")
        print()
    
    return 0 if len(cameras) >= 2 else 1

if __name__ == "__main__":
    sys.exit(main())

