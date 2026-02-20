@echo off
title Otimizador Windows 10
color 0B
echo.
echo  ========================================
echo    OTIMIZADOR WINDOWS 10 - Interface GUI
echo  ========================================
echo.
echo  Iniciando interface grafica...
echo  (Sera solicitada permissao de Administrador)
echo.

PowerShell.exe -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File "%~dp0OtimizadorWindows10_GUI.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo  [ERRO] Nao foi possivel iniciar a interface grafica.
    echo  Verifique se o PowerShell esta instalado e tente novamente.
    echo.
    pause
)
