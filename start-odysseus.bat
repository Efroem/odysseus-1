@echo off
REM ============================================================
REM  Start Odysseus (native Windows, no Docker)
REM  Double-click this file to launch the server.
REM  Keep this window OPEN while using Odysseus.
REM  Close the window (or press Ctrl+C) to stop the server.
REM ============================================================

cd /d "%~dp0"

set "PY=%~dp0venv\Scripts\python.exe"

if not exist "%PY%" (
    echo.
    echo ERROR: virtual environment not found at:
    echo   %PY%
    echo.
    echo Run the one-time setup first ^(create venv + install deps^), then re-run this file.
    echo.
    pause
    exit /b 1
)

echo.
echo  Starting Odysseus...
echo  When it says "Application startup complete", open:
echo.
echo      http://localhost:7000
echo.
echo  (Leave this window open. Press Ctrl+C or close it to stop.)
echo.

"%PY%" -m uvicorn app:app --host 127.0.0.1 --port 7000

echo.
echo  Odysseus has stopped.
echo  (If you saw an "address already in use" error, it was already running --
echo   just open http://localhost:7000 in your browser.)
echo.
pause
