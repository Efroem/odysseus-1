' ============================================================
'  Odysseus ON/OFF toggle
'    - If Odysseus is running  -> stop it (Odysseus + ChromaDB + browser)
'    - If Odysseus is stopped  -> start it (and open the app when ready)
'  Ollama is left running either way (shared background service).
' ============================================================
proj = "C:\Users\ejhoe\Documents\GitHub\odysseus"
Set sh = CreateObject("WScript.Shell")

If UrlUp("http://127.0.0.1:7000/login") Then
    ' Running -> turn OFF (wait for the stop to finish, then confirm)
    sh.Run "powershell -NoProfile -ExecutionPolicy Bypass -File """ & proj & "\stop-odysseus.ps1""", 0, True
    sh.Popup "Odysseus has been turned OFF.", 5, "Odysseus", 64
Else
    ' Stopped -> turn ON (starts ChromaDB + Odysseus, opens the app when ready)
    sh.Run "wscript """ & proj & "\odysseus-autostart.vbs""", 0, False
    sh.Popup "Odysseus is starting..." & vbCrLf & vbCrLf & _
             "The app opens automatically when it's ready (up to ~1 minute on a cold start).", 6, "Odysseus", 64
End If

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
