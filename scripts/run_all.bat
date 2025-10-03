@echo off
echo =================================
echo 🚀 IoT Demo System Launcher
echo =================================
echo.

echo 🎯 Starting all components...
echo.

REM Start ESP32 Simulator in background
echo 📡 Starting ESP32 Device Simulator...
start "ESP32 Simulator" cmd /k "cd /d %~dp0.. && python simulators\esp32_simulator.py"

REM Wait 2 seconds
timeout /t 2 /nobreak >nul

REM Start Web Server in background  
echo 🌐 Starting Web Dashboard Server...
start "Web Server" cmd /k "cd /d %~dp0..\web\src && python -m http.server 3000"

REM Wait 2 seconds
timeout /t 2 /nobreak >nul

REM Start Flutter App in background
echo 📱 Starting Flutter Mobile App...
start "Flutter App" cmd /k "cd /d %~dp0..\app_flutter\build\web && python -m http.server 8080"

echo.
echo ✅ All components started!
echo.
echo 🌐 Web Dashboard: http://localhost:3000/index.html
echo 📱 Flutter Mobile App: http://localhost:8080/index.html
echo 🤖 ESP32 Simulator: Running in background
echo.
echo Press any key to exit launcher...
pause >nul