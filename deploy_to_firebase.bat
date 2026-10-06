@echo off
set "PATH=C:\Program Files\nodejs;C:\Users\SN\AppData\Roaming\npm;%PATH%"
echo ============================================================
echo   Apna Batwa - Firebase Hosting Deployer
echo   Site: apnabatwa.web.app (Project: apnabatwa-pk)
echo ============================================================
echo.
echo Step 1: Checking Firebase login...
call firebase login
echo.
echo Step 2: Deploying web app to apnabatwa.web.app...
call firebase deploy --only hosting
echo.
echo ============================================================
echo   Mubarak ho! Aap ki app live ho chuki hai:
echo   https://apnabatwa.web.app
echo ============================================================
pause
