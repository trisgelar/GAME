@echo off
REM Monitor ML Server Logs in Real-Time
REM This script will show the latest log entries as they appear

echo ========================================
echo   ML Server Log Monitor
echo   Monitoring logs in real-time...
echo ========================================
echo.

REM Get the current date for log file
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YYYY=%dt:~0,4%"
set "MM=%dt:~4,2%"
set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%"
set "MIN=%dt:~10,2%"
set "SS=%dt:~12,2%"

set "LOG_FILE=logs\ml_server_%YYYY%%MM%%DD%.log"
set "ERROR_LOG_FILE=logs\ml_server_errors_%YYYY%%MM%%DD%.log"

echo Monitoring: %LOG_FILE%
echo Error Log: %ERROR_LOG_FILE%
echo.
echo Press Ctrl+C to stop monitoring
echo.

REM Monitor the log file
powershell "Get-Content '%LOG_FILE%' -Wait -Tail 20"
