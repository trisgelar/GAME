@echo off
REM ML Ethnicity Detection Server Startup Script with File Logging
REM Port 8888, Camera ID 0 (First USB webcam)
REM Logs output to file instead of terminal

echo ========================================
echo   ML Ethnicity Detection Server
echo   Port: 8888
echo   Camera ID: 0 (First USB webcam)
echo   Logging to: logs\ml_ethnicity_server_%date:~-4,4%%date:~-10,2%%date:~-7,2%.log
echo ========================================
echo.

REM Navigate to Webcam Server directory
cd /d "%~dp0"

REM Create logs directory if it doesn't exist
if not exist "logs" mkdir logs

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

REM Generate log filename with current date
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "logfile=logs\ml_ethnicity_server_%YYYY%%MM%%DD%_%HH%%Min%%Sec%.log"

echo Starting ML Ethnicity Detection Server...
echo Output will be saved to: %logfile%
echo Press Ctrl+C to stop the server
echo.

REM Start the server with output redirected to log file
python ml_webcam_server.py > "%logfile%" 2>&1

REM Keep window open on error and show last few lines of log
if errorlevel 1 (
    echo.
    echo Server stopped with error!
    echo.
    echo Last 20 lines of log file:
    echo ========================================
    if exist "%logfile%" (
        powershell "Get-Content '%logfile%' | Select-Object -Last 20"
    ) else (
        echo Log file not created.
    )
    echo ========================================
    echo.
    echo Full log available at: %logfile%
    pause
) else (
    echo.
    echo Server stopped normally.
    echo Log saved to: %logfile%
    pause
)
