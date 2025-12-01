@echo off
echo Starting Keep Alive Service for Render API...
echo.
echo This will ping https://smart-license-api.onrender.com every 10 minutes
echo Press Ctrl+C to stop the service
echo.
pause
python keep_alive.py
