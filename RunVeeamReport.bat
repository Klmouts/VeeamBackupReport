@echo off
title Veeam Backup Report
color 0A

echo.
echo ==========================================
echo     Veeam Backup Report - Powered by PS
echo ==========================================
echo.

:: Get current directory (where this .bat is located)
set "ScriptDir=%~dp0"

:: Run PowerShell script
PowerShell -NoProfile -ExecutionPolicy Bypass -File "%ScriptDir%main.ps1"

echo.
echo ------------------------------------------
echo Report generation complete.
echo Press any key to exit...
pause >nul
