# Stop the Odysseus stack (Odysseus server + ChromaDB + Playwright browser).
# Ollama is left running (it's a shared background service).
$ErrorActionPreference = 'SilentlyContinue'

function Kill-Match($name, $pattern, $label) {
    Get-CimInstance Win32_Process -Filter "Name='$name'" |
        Where-Object { $_.CommandLine -match $pattern } |
        ForEach-Object {
            Write-Host ("  - {0} (PID {1})" -f $label, $_.ProcessId)
            Stop-Process -Id $_.ProcessId -Force
        }
}

Write-Host ""
Write-Host "Stopping Odysseus stack..." -ForegroundColor Cyan

# Odysseus web server (its built-in MCP child processes exit when its pipes close)
Kill-Match 'python.exe' 'uvicorn app:app' 'Odysseus server'

# ChromaDB server (runs from its own venv at odysseus-chromadb)
Kill-Match 'chroma.exe'  'odysseus-chromadb' 'ChromaDB'
Kill-Match 'python.exe'  'odysseus-chromadb' 'ChromaDB'

# Playwright Browser MCP (node) and any Chromium it launched
Kill-Match 'node.exe' 'playwright' 'Browser MCP'
Get-Process chrome -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -like '*ms-playwright*' } |
    ForEach-Object { Stop-Process -Id $_.Id -Force }

Write-Host ""
Write-Host "Done. Odysseus + ChromaDB + browser stopped." -ForegroundColor Green
Write-Host "(Ollama is still running as its own service. Restart everything with start-odysseus.bat or a reboot.)"
Write-Host ""
