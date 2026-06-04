' ============================================================
'  Odysseus autostart launcher (native Windows, no Docker)
'  Starts the Odysseus server HIDDEN (no console window) at login.
'  Logs go to logs\odysseus-autostart.{out,err}.log
'
'  To DISABLE autostart: delete the "Odysseus" shortcut from the
'  Startup folder (Win+R -> shell:startup).
' ============================================================
Dim sh
Set sh = CreateObject("WScript.Shell")
sh.CurrentDirectory = "C:\Users\ejhoe\Documents\GitHub\odysseus"
sh.Run "cmd /c C:\Users\ejhoe\Documents\GitHub\odysseus\venv\Scripts\python.exe -m uvicorn app:app --host 127.0.0.1 --port 7000 > C:\Users\ejhoe\Documents\GitHub\odysseus\logs\odysseus-autostart.out.log 2> C:\Users\ejhoe\Documents\GitHub\odysseus\logs\odysseus-autostart.err.log", 0, False
