@echo off
REM ML Ethnicity Detection Server Startup Script
REM Port 8888, Camera ID 0 (First USB webcam)

echo ========================================
echo   ML Ethnicity Detection Server
echo   Port: 8888
echo   Camera ID: 0 (First USB webcam)
echo ========================================
echo.

REM Navigate to Webcam Server directory
cd /d "%~dp0"

REM Check if virtual environment exists
if not exist "env\Scripts\activate.bat" (
    echo ERROR: Virtual environment not found!
    echo.
    echo Please run the following commands first:
    echo   1. python -m venv env
    echo   2. env\Scripts\activate.bat
    echo   3. pip install -r requirements.txt
    echo.
    pause
    exit /b 1
)

REM Activate virtual environment
echo Activating virtual environment...
call env\Scripts\activate.bat

REM Check if dependencies are installed
echo Checking dependencies...
python -c "import cv2, numpy, sklearn" 2>nul
if errorlevel 1 (
    echo.
    echo ERROR: Dependencies not installed!
    echo Please run: pip install -r requirements.txt
    echo.
    pause
    exit /b 1
)

REM Verify camera is available
echo.
echo Verifying Camera ID 0 is available...
python -c "import cv2; cap = cv2.VideoCapture(0, cv2.CAP_DSHOW); print('✅ Camera 0 detected' if cap.isOpened() else '❌ Camera 0 not found'); cap.release()"

echo.
echo ========================================
echo   IMPORTANT: Camera Configuration
echo ========================================
echo This server uses Camera ID 0
echo.
echo If you have an internal laptop camera:
echo   - Internal camera is usually ID 0
echo   - First USB camera is usually ID 1
echo   - Second USB camera is usually ID 2
echo.
echo To use USB cameras only:
echo   1. Run: python detect_cameras.py
echo   2. Identify which IDs are USB cameras
echo   3. Update config.json with correct camera_id
echo.
echo Current: Using Camera ID 0
echo ========================================
echo.

REM Start the server
echo Starting ML Ethnicity Detection Server...
echo Press Ctrl+C to stop the server
echo.
python ml_webcam_server.py

REM Keep window open on error
if errorlevel 1 (
    echo.
    echo Server stopped with error!
    pause
)

