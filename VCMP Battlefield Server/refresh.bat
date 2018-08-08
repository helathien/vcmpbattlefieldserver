@echo off
:1
tasklist /FI "IMAGENAME eq SERVER64.EXE" 2>NUL | find /I /N "SERVER64.EXE">NUL
if NOT "%ERRORLEVEL%" == "0" start "" "SERVER64.EXE"
goto :1