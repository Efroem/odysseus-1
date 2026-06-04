' ============================================================
'  Odysseus autostart launcher (native Windows, no Docker)
'  1) Starts the Odysseus server HIDDEN (if not already running)
'  2) Waits until BOTH Odysseus (7000) AND Ollama (11434) are ready
'     (avoids a startup race where chatting too early -> 503)
'  3) Opens your default browser to Odysseus
'  Logs: logs\odysseus-autostart.{out,err}.log
'
'  To DISABLE autostart: delete the "Odysseus" shortcut from the
'  Startup folder (Win+R -> shell:startup).
' ============================================================

proj      = "C:\Users\ejhoe\Documents\GitHub\odysseus"
url       = "http://localhost:7000"
odyCheck  = url & "/login"
ollaCheck = "http://localhost:11434/api/tags"

Set sh = CreateObject("WScript.Shell")
sh.CurrentDirectory = proj

' Start the Odysseus server hidden, but only if it isn't already up.
If Not UrlUp(odyCheck) Then
    sh.Run "cmd /c " & proj & "\venv\Scripts\python.exe -m uvicorn app:app --host 127.0.0.1 --port 7000 > " & proj & "\logs\odysseus-autostart.out.log 2> " & proj & "\logs\odysseus-autostart.err.log", 0, False
End If

' Wait up to 5 minutes for BOTH the app and the local model server.
ready = False
For i = 1 To 150
    If UrlUp(odyCheck) And UrlUp(ollaCheck) Then
        ready = True
        Exit For
    End If
    WScript.Sleep 2000
Next

' Fallback: if Ollama never came up but the app did, still open it
' (you can use the cloud/Gemini model even without Ollama).
If Not ready Then
    If UrlUp(odyCheck) Then ready = True
End If

If ready Then
    CreateObject("Shell.Application").ShellExecute url, "", "", "open", 1
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
