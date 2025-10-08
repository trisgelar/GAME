@echo off
REM Topeng Mask Overlay Server Startup Script
REM This server runs on port 8889 with its own virtual environment

echo ========================================
echo   Topeng Mask Overlay Server
echo   Port: 8889 (separate from ML server)
echo ========================================
echo.

REM Check if virtual environment exists
if not exist "env\Scripts\activate.bat" (
    echo ERROR: Virtual environment not found!
    echo Please run: python -m venv env
    echo Then: env\Scripts\activate.bat
    echo Then: pip install -r requirements_topeng.txt
    pause
    exit /b 1
)

REM Activate virtual environment
echo Activating virtual environment...
call env\Scripts\activate.bat

REM Check if dependencies are installed
python -c "import mediapipe" 2>nul
if errorlevel 1 (
    echo.
    echo ERROR: Dependencies not installed!
    echo Please run: pip install -r requirements_topeng.txt
    pause
    exit /b 1
)

REM Start the server
echo.
echo Starting Topeng server on port 8889 with Camera ID 1...
echo Press Ctrl+C to stop the server
echo.
python udp_webcam_server.py --port 8889 --camera_id 1

REM Keep window open on error
if errorlevel 1 (
    echo.
    echo Server stopped with error!
    pause
)

