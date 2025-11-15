@echo off
title Restart to UEFI
cls

:: ===========================================================
:: ENABLE ANSI COLOR PROCESSING (Windows 10+)
:: ===========================================================
for /f "delims=" %%E in ('echo prompt $E^| cmd') do set "ESC=%%E"

:: Color shortcuts
set "RED=%ESC%[31m"
set "GREEN=%ESC%[32m"
set "YELLOW=%ESC%[33m"
set "BLUE=%ESC%[34m"
set "MAGENTA=%ESC%[35m"
set "CYAN=%ESC%[36m"
set "RESET=%ESC%[0m"

:: ===========================================================
:: AUTO-ELEVATE TO ADMIN
:: ===========================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo %YELLOW%Requesting administrator access...%RESET%
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

cls
call :banner

:: ===========================================================
:: UEFI SUPPORT CHECK
:: ===========================================================
echo %CYAN%Checking if this system supports UEFI boot...%RESET%

powershell -Command "(Confirm-SecureBootUEFI -ErrorAction SilentlyContinue)" >nul 2>&1

if %errorlevel% neq 0 (
    echo.
    echo %YELLOW%WARNING: This system may NOT support UEFI firmware boot!%RESET%
    echo %YELLOW%The /fw reboot command may be ignored on this machine.%RESET%
    echo.
    echo Press Ctrl+C to cancel, or press any key to continue anyway...
    pause >nul
)

cls
call :banner

:: ===========================================================
:: CONFIRMATION PROMPT
:: ===========================================================
echo %MAGENTA%This will restart your PC directly into UEFI/BIOS firmware.%RESET%
echo.
choice /m "Are you sure you want to proceed"

if %errorlevel% neq 1 (
    echo.
    echo %RED%Operation cancelled.%RESET%
    timeout /t 2 >nul
    exit /b
)

cls
call :banner

:: ===========================================================
:: COUNTDOWN TIMER (5 SECONDS) — CALL OF DUTY TONES
:: ===========================================================
set SECONDS=5

echo %GREEN%Restarting into UEFI in %SECONDS% seconds...%RESET%
echo %YELLOW%Press CTRL+C to cancel.%RESET%
echo.

for /l %%i in (%SECONDS%,-1,1) do (
    echo %CYAN%%%i%...%RESET%

    if %%i==5 powershell -c "[console]::beep(1200,140)"
    if %%i==4 powershell -c "[console]::beep(1000,140)"
    if %%i==3 powershell -c "[console]::beep(800,140)"
    if %%i==2 powershell -c "[console]::beep(600,140)"
    if %%i==1 powershell -c "[console]::beep(300,180)"

    timeout /t 1 >nul
)

:: FINAL COD-STYLE LOW BOOM
powershell -c "[console]::beep(120,350)"

:: ===========================================================
:: INITIATE UEFI REBOOT
:: ===========================================================
echo.
echo %GREEN%Initiating UEFI reboot now...%RESET%

powershell -Command "Start-Process shutdown -ArgumentList '/r /fw /t 0' -Verb RunAs"
exit /b


:: ===========================================================
:: SMART BANNER FUNCTION — WINDOWS TERMINAL DETECTION
:: ===========================================================
:banner
if defined WT_SESSION (
    echo %CYAN%==============================================================%RESET%
    echo %GREEN%                        RESTART TO UEFI                       %RESET%
    echo %CYAN%==============================================================%RESET%
    echo.
) else (
    echo ==================================================
    echo                RESTART TO UEFI
    echo ==================================================
    echo.
)
exit /b
