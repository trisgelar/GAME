@echo off
REM Topeng Mask Overlay Server Startup Script
REM Port 8889, Camera ID 1 (Second USB webcam)

echo ========================================
echo   Topeng Mask Overlay Server
echo   Port: 8889
echo   Camera ID: 1 (Second USB webcam)
echo ========================================
echo.

REM Navigate to Topeng Server directory
cd /d "%~dp0"

REM Check if virtual environment exists
if not exist "env\Scripts\activate.bat" (
    echo ERROR: Virtual environment not found!
    echo.
    echo Please run the following commands first:
    echo   1. python -m venv env
    echo   2. env\Scripts\activate.bat
    echo   3. pip install -r requirements_topeng.txt
    echo.
    pause
    exit /b 1
)

REM Activate virtual environment
echo Activating virtual environment...
call env\Scripts\activate.bat

REM Check if dependencies are installed
echo Checking dependencies...
python -c "import cv2, mediapipe" 2>nul
if errorlevel 1 (
    echo.
    echo ERROR: Dependencies not installed!
    echo Please run: pip install -r requirements_topeng.txt
    echo.
    pause
    exit /b 1
)

REM Verify camera is available
echo.
echo Verifying Camera ID 1 is available...
python -c "import cv2; cap = cv2.VideoCapture(1, cv2.CAP_DSHOW); print('✅ Camera 1 detected' if cap.isOpened() else '❌ Camera 1 not found'); cap.release()"

echo.
echo ========================================
echo   IMPORTANT: Camera Configuration
echo ========================================
echo This server uses Camera ID 1
echo.
echo If you have an internal laptop camera:
echo   - Internal camera is usually ID 0
echo   - First USB camera is usually ID 1
echo   - Second USB camera is usually ID 2
echo.
echo To use USB cameras only:
echo   1. Run: cd "..\Webcam Server" 
echo   2. Run: env\Scripts\activate.bat
echo   3. Run: python detect_cameras.py
echo   4. Identify which IDs are USB cameras
echo   5. Update startup script with correct --camera_id
echo.
echo Current: Using Camera ID 1
echo ========================================
echo.

REM Start the server
echo Starting Topeng Mask Overlay Server...
echo Press Ctrl+C to stop the server
echo.
python udp_webcam_server.py --port 8889 --camera_id 1

REM Keep window open on error
if errorlevel 1 (
    echo.
    echo Server stopped with error!
    pause
)

