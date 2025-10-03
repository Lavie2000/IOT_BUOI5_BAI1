# IoT Demo System Launcher - PowerShell Version
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "IoT Demo System Launcher" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Starting all components..." -ForegroundColor Yellow
Write-Host ""

# Get current script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir

# Start ESP32 Simulator in new window
Write-Host "Starting ESP32 Device Simulator..." -ForegroundColor Blue
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectRoot'; python simulators\esp32_simulator.py" -WindowStyle Normal

# Wait 3 seconds
Start-Sleep -Seconds 3

# Start Web Server in new window
Write-Host "Starting Web Dashboard Server..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectRoot\web\src'; python -m http.server 3000" -WindowStyle Normal

# Wait 2 seconds
Start-Sleep -Seconds 2

# Start Flutter App in new window
Write-Host "Starting Flutter Mobile App..." -ForegroundColor Magenta
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectRoot\app_flutter\build\web'; python -m http.server 8080" -WindowStyle Normal

Write-Host ""
Write-Host "All components started!" -ForegroundColor Green
Write-Host ""
Write-Host "Web Dashboard: http://localhost:3000/index.html" -ForegroundColor Cyan
Write-Host "Flutter Mobile App: http://localhost:8080/index.html" -ForegroundColor Cyan
Write-Host "ESP32 Simulator: Running in background" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Optional: Open browsers automatically
Write-Host "Opening web interfaces..." -ForegroundColor Yellow
Start-Process "http://localhost:3000/index.html"
Start-Process "http://localhost:8080/index.html"

Write-Host "System is ready! Check the opened browser tabs." -ForegroundColor Green