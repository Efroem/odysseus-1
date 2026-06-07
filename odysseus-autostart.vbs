' ============================================================
'  Odysseus autostart launcher (native Windows, no Docker)
'  Boot order: ChromaDB -> Odysseus -> (wait for Ollama) -> open browser
'    1) Start ChromaDB on :8100 (needed for memory, RAG, and the tool
'       index that surfaces MCP tools like the browser to the agent)
'    2) Start the Odysseus server HIDDEN
'    3) Wait until Odysseus (7000) AND Ollama (11434) are ready
'    4) Open the default browser to Odysseus
'  Logs: logs\odysseus-autostart.{out,err}.log ; chroma logs under
'        C:\Users\ejhoe\odysseus-chromadb\chroma.{out,err}.log
'
'  To DISABLE autostart: delete the "Odysseus" shortcut from the
'  Startup folder (Win+R -> shell:startup).
' ============================================================

proj        = "C:\Users\ejhoe\Documents\GitHub\odysseus"
chromaDir   = "C:\Users\ejhoe\odysseus-chromadb"
url         = "http://localhost:7000"
odyCheck    = url & "/login"
ollaCheck   = "http://localhost:11434/api/tags"
chromaCheck = "http://localhost:8100/api/v2/heartbeat"

Set sh = CreateObject("WScript.Shell")
sh.CurrentDirectory = proj

' 1) Start ChromaDB if it isn't already up.
If Not UrlUp(chromaCheck) Then
    sh.Run "cmd /c " & chromaDir & "\venv\Scripts\chroma.exe run --host localhost --port 8100 --path " & chromaDir & "\data > " & chromaDir & "\chroma.out.log 2> " & chromaDir & "\chroma.err.log", 0, False
End If
' Give Chroma up to ~60s so Odysseus connects to it at startup.
For i = 1 To 30
    If UrlUp(chromaCheck) Then Exit For
    WScript.Sleep 2000
Next

' 2) Start the Odysseus server hidden if it isn't already up.
If Not UrlUp(odyCheck) Then
    sh.Run "cmd /c " & proj & "\venv\Scripts\python.exe -m uvicorn app:app --host 127.0.0.1 --port 7000 > " & proj & "\logs\odysseus-autostart.out.log 2> " & proj & "\logs\odysseus-autostart.err.log", 0, False
End If

' 3) Wait up to 5 min for BOTH the app and the local model server.
ready = False
For i = 1 To 150
    If UrlUp(odyCheck) And UrlUp(ollaCheck) Then
        ready = True
        Exit For
    End If
    WScript.Sleep 2000
Next
If Not ready Then
    If UrlUp(odyCheck) Then ready = True
End If

' 4) Open it as a standalone APP WINDOW (Chrome --app), so it looks/behaves
'    like a native app rather than a browser tab. Falls back to the default
'    browser if Chrome isn't found.
If ready Then
    chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    If CreateObject("Scripting.FileSystemObject").FileExists(chromePath) Then
        sh.Run """" & chromePath & """ --app=" & url, 1, False
    Else
        CreateObject("Shell.Application").ShellExecute url, "", "", "open", 1
    End If
End If

' Returns True if a GET to the URL gets any non-server-error response.
Function UrlUp(u)
    Dim req
    UrlUp = False
    On Error Resume Next
    Set req = CreateObject("MSXML2.ServerXMLHTTP.6.0")
    req.setTimeouts 2000, 2000, 2000, 2000
    req.open "GET", u, False
    req.send
    If Err.Number = 0 Then
        If req.Status >= 200 And req.Status < 500 Then UrlUp = True
    End If
    On Error GoTo 0
End Function
