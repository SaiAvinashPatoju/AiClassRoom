@echo off
echo ========================================
echo   Lecture to Slides - Development Mode
echo ========================================
echo.

echo Starting Backend Server...
start "Backend Server" cmd /k "cd backend && set SECRET_KEY=super_secret_jwt_key_for_development_change_in_production_12345 && set GOOGLE_API_KEY=AIzaSyCIk5gH-tDX2ygGeNlCAykpVGDtzrngCRY && python main.py"

timeout /t 3 /nobreak > nul

echo Starting Frontend Server...
start "Frontend Server" cmd /k "cd frontend && npm run dev"

echo.
echo ========================================
echo   Servers Starting...
echo ========================================
echo Backend:  http://localhost:8000
echo Frontend: http://localhost:3000
echo.
echo Press any key to close this window...
pause > nul