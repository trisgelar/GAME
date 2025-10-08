#!/usr/bin/env python3
"""
Simple Camera Test - One at a time with timeout
"""

import cv2
import sys
import time

def test_single_camera(camera_id):
    """Test a single camera with timeout"""
    print(f"\n{'='*60}")
    print(f"🎥 Testing Camera {camera_id}")
    print('='*60)
    
    try:
        # Open camera
        print(f"Opening camera {camera_id}...")
        cap = cv2.VideoCapture(camera_id, cv2.CAP_DSHOW)
        
        if not cap.isOpened():
            print(f"❌ Cannot open camera {camera_id}")
            return False
        
        # Get properties
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        print(f"✅ Camera {camera_id}: {width}x{height}")
        
        # Try to read ONE frame with timeout
        print("Attempting to read frame (5 second timeout)...")
        start_time = time.time()
        
        # Set a shorter timeout by trying to read in a loop
        ret = False
        frame = None
        attempts = 0
        max_attempts = 10  # 10 attempts with 0.5s each = 5s total
        
        while attempts < max_attempts:
            ret, frame = cap.read()
            if ret and frame is not None:
                print(f"✅ Successfully read frame from camera {camera_id}")
                
                # Save a test image
                filename = f"test_camera_{camera_id}.jpg"
                cv2.imwrite(filename, frame)
                print(f"📸 Saved test image: {filename}")
                print(f"   → Open this file to see what camera {camera_id} shows!")
                break
            
            attempts += 1
            time.sleep(0.5)
        
        if not ret:
            print(f"⚠️  Camera {camera_id} opened but couldn't read frame (timeout)")
            print(f"   This might be a virtual/dummy camera device")
        
        cap.release()
        elapsed = time.time() - start_time
        print(f"Time taken: {elapsed:.2f}s")
        
        return ret
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    """Test each camera individually"""
    if len(sys.argv) < 2:
        print("🎥 Simple Camera Test Tool")
        print()
        print("Usage: python test_camera_simple.py <camera_id>")
        print()
        print("Examples:")
        print("  python test_camera_simple.py 0    # Test Camera 0")
        print("  python test_camera_simple.py 1    # Test Camera 1")
        print("  python test_camera_simple.py 2    # Test Camera 2")
        print("  python test_camera_simple.py 3    # Test Camera 3")
        print()
        print("Detected cameras: [0, 1, 2, 3]")
        print()
        print("📝 Recommendation:")
        print("   Test each camera one by one to identify your USB webcams")
        print("   Look at the saved test_camera_X.jpg files to see what each camera sees")
        return 1
    
    camera_id = int(sys.argv[1])
    print(f"\n🎥 Testing Camera {camera_id}")
    
    success = test_single_camera(camera_id)
    
    if success:
        print(f"\n✅ Camera {camera_id} works!")
        print(f"📸 Check the saved image: test_camera_{camera_id}.jpg")
    else:
        print(f"\n❌ Camera {camera_id} failed or timeout")
    
    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())

