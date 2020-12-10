; This file should be called from Popper Setup->GlobalConfig->StartUP->"Closing Script":
; start /B "" "c:\Program Files\AutoHotkey\AutoHotkey.exe" "C:\PinUPSystem\Scripts\pinsound_close.ahk"

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

WinClose, PinSound Studio