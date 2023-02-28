@echo off

cls
powershell -ExecutionPolicy Bypass -File .\make.ps1
powershell -ExecutionPolicy Bypass -File .\exec.ps1

cls
pause
