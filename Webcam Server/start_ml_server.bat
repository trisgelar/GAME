@echo off
REM ML Ethnicity Detection Server Startup Script
REM This server runs on port 8888 with Camera ID 0

echo ========================================
echo   ML Ethnicity Detection Server
echo   Port: 8888
echo   Camera ID: 0 (First USB webcam)
echo ========================================
echo.

REM Check if virtual environment exists
if not exist "env\Scripts\activate.bat" (
    echo ERROR: Virtual environment not found!
    echo Please run: python -m venv env
    echo Then: env\Scripts\activate.bat
    echo Then: pip install -r requirements.txt
    pause
    exit /b 1
)

REM Activate virtual environment
echo Activating virtual environment...
call env\Scripts\activate.bat

REM Check if dependencies are installed
python -c "import cv2, numpy, scikit-learn" 2>nul
if errorlevel 1 (
    echo.
    echo ERROR: Dependencies not installed!
    echo Please run: pip install -r requirements.txt
    pause
    exit /b 1
)

REM Start the server
echo.
echo Starting ML server on port 8888 with Camera ID 0...
echo Press Ctrl+C to stop the server
echo.
python ml_webcam_server.py

REM Keep window open on error
if errorlevel 1 (
    echo.
    echo Server stopped with error!
    pause
)

