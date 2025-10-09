@echo off
echo Starting Topeng Server with Logging...

REM Create logs directory if it doesn't exist
if not exist "logs" mkdir logs

REM Start the server and redirect output to log files
python udp_webcam_server.py > logs\topeng_server_%date:~-4,4%%date:~-10,2%%date:~-7,2%.log 2>&1

REM Alternative: Use PowerShell for better timestamp formatting
REM powershell "python udp_webcam_server.py *>&1 | Tee-Object -FilePath 'logs\topeng_server_$(Get-Date -Format 'yyyyMMdd').log'"

echo Topeng Server stopped.
pause
