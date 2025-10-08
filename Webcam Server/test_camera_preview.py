#!/usr/bin/env python3
"""
Camera Preview Tool
Shows video preview from each detected camera to help identify physical devices
"""

import cv2
import sys

def test_camera(camera_id):
    """Test a specific camera and show preview"""
    print(f"\n{'='*60}")
    print(f"Testing Camera {camera_id}")
    print('='*60)
    print("Press 'q' to close this camera and test next one")
    print("Press ESC to exit completely")
    
    try:
        # Open camera with DSHOW backend
        cap = cv2.VideoCapture(camera_id, cv2.CAP_DSHOW)
        
        if not cap.isOpened():
            print(f"❌ Cannot open camera {camera_id}")
            return False
        
        # Get properties
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        fps = int(cap.get(cv2.CAP_PROP_FPS))
        
        print(f"✅ Camera {camera_id} opened: {width}x{height} @ {fps}FPS")
        print(f"📹 Showing preview window...")
        
        # Create window
        window_name = f"Camera {camera_id} - {width}x{height}"
        cv2.namedWindow(window_name, cv2.WINDOW_NORMAL)
        
        frame_count = 0
        while True:
            ret, frame = cap.read()
            
            if not ret:
                print(f"❌ Failed to read frame from camera {camera_id}")
                break
            
            frame_count += 1
            
            # Add overlay text
            text = f"Camera {camera_id} - Frame {frame_count}"
            cv2.putText(frame, text, (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 
                       1, (0, 255, 0), 2, cv2.LINE_AA)
            
            cv2.putText(frame, "Press 'q' for next camera, ESC to exit", 
                       (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 
                       0.6, (255, 255, 255), 1, cv2.LINE_AA)
            
            # Show frame
            cv2.imshow(window_name, frame)
            
            # Check for key press
            key = cv2.waitKey(1) & 0xFF
            if key == ord('q'):  # 'q' for next camera
                print(f"✅ Camera {camera_id} test complete")
                break
            elif key == 27:  # ESC to exit
                print("👋 Exiting camera preview")
                cap.release()
                cv2.destroyAllWindows()
                return False
        
        cap.release()
        cv2.destroyAllWindows()
        return True
        
    except Exception as e:
        print(f"❌ Error testing camera {camera_id}: {e}")
        return False

def main():
    print("🎥 Camera Preview Tool")
    print("   Identify Your Physical Cameras")
    print()
    
    # Get list of detected cameras
    detected_cameras = []
    for camera_id in range(10):
        cap = cv2.VideoCapture(camera_id, cv2.CAP_DSHOW)
        if cap.isOpened():
            ret, _ = cap.read()
            if ret:
                detected_cameras.append(camera_id)
        cap.release()
    
    if not detected_cameras:
        print("❌ No cameras detected!")
        return 1
    
    print(f"📊 Found {len(detected_cameras)} camera(s): {detected_cameras}")
    print()
    print("Instructions:")
    print("  • Each camera will show video preview")
    print("  • Look at your physical cameras to see which one is active")
    print("  • Note which Camera ID corresponds to which physical camera")
    print("  • Press 'q' to test next camera")
    print("  • Press ESC to exit")
    print()
    input("Press ENTER to start testing cameras...")
    
    # Test each camera
    for camera_id in detected_cameras:
        if not test_camera(camera_id):
            break  # User pressed ESC
    
    print()
    print("="*60)
    print("✅ Camera testing complete!")
    print()
    print("📝 Recommendation for dual server setup:")
    print("   • Use 2 different USB cameras (not internal)")
    print("   • Update config.json with the correct camera IDs")
    print()
    
    return 0

if __name__ == "__main__":
    sys.exit(main())

