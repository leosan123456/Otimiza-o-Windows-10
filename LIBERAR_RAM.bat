@echo off
title Liberador de RAM - Windows 10
color 0B
PowerShell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0LiberarRAM.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo  [ERRO] Nao foi possivel executar o script.
    pause
)
