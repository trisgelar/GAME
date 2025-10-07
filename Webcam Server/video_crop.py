#!/usr/bin/env python3
"""
Video Crop Script
Crops Full HD video to 480x360 focusing on the face in the top-left corner
"""

import subprocess
import os
from pathlib import Path


def get_video_dimensions(input_path):
    """
    Get video dimensions using ffprobe
    
    Args:
        input_path: Path to input video file
        
    Returns:
        tuple: (width, height) or (None, None) if failed
    """
    try:
        cmd = [
            'ffprobe',
            '-v', 'quiet',
            '-print_format', 'json',
            '-show_streams',
            input_path
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        
        import json
        data = json.loads(result.stdout)
        
        for stream in data['streams']:
            if stream['codec_type'] == 'video':
                width = int(stream['width'])
                height = int(stream['height'])
                return width, height
                
        return None, None
        
    except (subprocess.CalledProcessError, json.JSONDecodeError, KeyError, ValueError) as e:
        print(f"WARNING: Could not get video dimensions: {e}")
        return None, None


def crop_video(input_path, output_path, width=480, height=360, x_offset=None, y_offset=None):
    """
    Crop video using ffmpeg
    
    Args:
        input_path: Path to input video file
        output_path: Path to output video file
        width: Output width (default: 480)
        height: Output height (default: 360)
        x_offset: X offset for cropping (None for auto-center)
        y_offset: Y offset for cropping (None for auto-center)
    """
    
    # Check if input file exists
    if not os.path.exists(input_path):
        print(f"ERROR: Input file not found: {input_path}")
        return False
    
    # Get video dimensions for auto-centering
    if x_offset is None or y_offset is None:
        print("Getting video dimensions...")
        input_width, input_height = get_video_dimensions(input_path)
        
        if input_width is None or input_height is None:
            print("WARNING: Could not get video dimensions. Using manual offsets.")
            x_offset = x_offset or 0
            y_offset = y_offset or 0
        else:
            print(f"Input video dimensions: {input_width}x{input_height}")
            
            # Auto-center the crop
            if x_offset is None:
                x_offset = max(0, (input_width - width) // 2)
            if y_offset is None:
                y_offset = max(0, (input_height - height) // 2)
            
            print(f"Auto-centered crop offset: ({x_offset}, {y_offset})")
    
    # Create output directory if it doesn't exist
    output_dir = os.path.dirname(output_path)
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # FFmpeg command to crop video
    # -i: input file
    # -vf: video filter (crop=width:height:x:y)
    # -c:v: video codec (libx264)
    # -c:a: audio codec (copy to preserve original)
    # -y: overwrite output file if it exists
    
    cmd = [
        'ffmpeg',
        '-i', input_path,
        '-vf', f'crop={width}:{height}:{x_offset}:{y_offset}',
        '-c:v', 'libx264',
        '-c:a', 'copy',
        '-y',
        output_path
    ]
    
    print(f"Cropping video...")
    print(f"Input: {input_path}")
    print(f"Output: {output_path}")
    print(f"Size: {width}x{height}")
    print(f"Offset: ({x_offset}, {y_offset})")
    print(f"Command: {' '.join(cmd)}")
    print()
    
    try:
        # Run ffmpeg command
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        
        print("SUCCESS: Video cropped successfully!")
        
        # Check if output file was created
        if os.path.exists(output_path):
            file_size = os.path.getsize(output_path)
            print(f"Output file size: {file_size / (1024*1024):.2f} MB")
            return True
        else:
            print("ERROR: Output file was not created")
            return False
            
    except subprocess.CalledProcessError as e:
        print(f"ERROR: FFmpeg error: {e}")
        print(f"Error output: {e.stderr}")
        return False
    except FileNotFoundError:
        print("ERROR: FFmpeg not found. Please install FFmpeg and add it to your PATH.")
        print("Download from: https://ffmpeg.org/download.html")
        return False


def main():
    """Main function"""
    print("=== Video Crop Tool ===")
    
    # Input and output paths
    input_path = r"C:\Users\balaplumpat\Videos\2025-10-03 14-30-15.mp4"
    output_path = "performance/cropped_video_480x360.mp4"
    
    # Crop parameters
    # Crop from top-left with 20px margin to capture the face
    width = 480
    height = 360
    x_offset = 60  # 20 pixels from left edge
    y_offset = 0  # 20 pixels from top edge
    
    print(f"Input video: {input_path}")
    print(f"Output video: {output_path}")
    print(f"Crop size: {width}x{height}")
    print(f"Crop offset: (20, 20) - 20px margin from top-left")
    print()
    
    # Check if input file exists
    if not os.path.exists(input_path):
        print(f"ERROR: Input file not found: {input_path}")
        print("Please check the file path and try again.")
        return 1
    
    # Get input file info
    input_size = os.path.getsize(input_path)
    print(f"Input file size: {input_size / (1024*1024):.2f} MB")
    
    # Crop the video
    success = crop_video(input_path, output_path, width, height, x_offset, y_offset)
    
    if success:
        print("\nSUCCESS: Video cropping completed successfully!")
        print(f"Cropped video saved to: {output_path}")
        print("\nYou can now use this cropped video for performance benchmarking.")
        return 0
    else:
        print("\nERROR: Video cropping failed!")
        return 1


if __name__ == "__main__":
    exit(main())
