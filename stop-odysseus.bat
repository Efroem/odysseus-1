@echo off
REM ============================================================
REM  Stop the Odysseus stack: Odysseus server + ChromaDB + browser.
REM  (Ollama is left running as its own background service.)
REM  Double-click to shut everything down cleanly.
REM ============================================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0stop-odysseus.ps1"
pause
