@echo off
REM Dual Webcam Server Startup Script
REM Starts both ML server and Topeng server with dedicated USB webcams
REM 
REM Requirements:
REM   - 2 USB webcams connected
REM   - Camera ID 0 = ML/Ethnicity Detection Server (Port 8888)
REM   - Camera ID 1 = Topeng Mask Overlay Server (Port 8889)

echo ================================================================
echo   ISSAT Game - Dual Webcam Server Startup
echo ================================================================
echo.
echo This script will start BOTH servers with dedicated webcams:
echo   1. ML Ethnicity Detection Server (Port 8888, Camera 0)
echo   2. Topeng Mask Overlay Server (Port 8889, Camera 1)
echo.
echo IMPORTANT: Make sure you have 2 USB webcams connected!
echo.
echo ================================================================

REM First, detect available cameras
echo.
echo Step 1: Detecting available cameras...
echo ----------------------------------------------------------------
cd "Webcam Server"
if exist "env\Scripts\python.exe" (
    env\Scripts\python.exe detect_cameras.py
    if errorlevel 1 (
        echo.
        echo ERROR: Camera detection failed or insufficient cameras!
        echo Please make sure you have 2 USB webcams connected.
        pause
        cd ..
        exit /b 1
    )
) else (
    echo WARNING: Cannot detect cameras - virtual environment not found
    echo Attempting to start servers anyway...
)
cd ..

echo.
echo ----------------------------------------------------------------
echo Step 2: Starting servers...
echo ----------------------------------------------------------------
echo.

REM Start ML server in a new window
echo Starting ML Server (Port 8888, Camera 0)...
start "ML Ethnicity Detection Server (Port 8888)" cmd /k "cd /d "%CD%\Webcam Server" && call env\Scripts\activate.bat && python ml_webcam_server.py"

REM Wait a moment for first server to initialize
timeout /t 3 /nobreak >nul

REM Start Topeng server in a new window
echo Starting Topeng Server (Port 8889, Camera 1)...
start "Topeng Mask Overlay Server (Port 8889)" cmd /k "cd /d "%CD%\Topeng Server" && call env\Scripts\activate.bat && python udp_webcam_server.py --port 8889 --camera_id 1"

echo.
echo ================================================================
echo   Both servers started successfully!
echo ================================================================
echo.
echo Two new windows have opened:
echo   1. ML Ethnicity Detection Server (Port 8888, Camera 0)
echo   2. Topeng Mask Overlay Server (Port 8889, Camera 1)
echo.
echo You can now:
echo   - Open the Ethnicity Detection scene in Godot
echo   - Open the Topeng Nusantara scene in Godot
echo   - Switch between scenes without webcam conflicts!
echo.
echo To stop servers: Close each server window or press Ctrl+C
echo.
echo ================================================================

pause

