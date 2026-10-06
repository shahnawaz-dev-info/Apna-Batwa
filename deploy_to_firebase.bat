@echo off
set "PATH=C:\Program Files\nodejs;C:\Users\SN\AppData\Roaming\npm;%PATH%"
echo ============================================================
echo   Apna Batwa - Firebase Hosting Deployer
echo   Project: apnabatwa-pk
echo ============================================================
echo.
echo Step 1: Logging in to Firebase...
echo (Agar browser khule to apna Google account select kar k Allow karein)
call firebase login
echo.
echo Step 2: Deploying web app to Firebase...
call firebase deploy --only hosting
echo.
echo ============================================================
echo   Mubarak ho! Aap ki app live ho chuki hai:
echo   https://apnabatwa-pk.web.app
echo ============================================================
pause
