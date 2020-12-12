; This file should be called from Popper Setup->GlobalConfig->StartUP->"Menu StartUP Script":
; start /B "" "c:\Program Files\AutoHotkey\AutoHotkey.exe" "C:\PinUPSystem\Scripts\pinsound_launch.ahk"

; the following line should be added to the closing script to close pinsound:
; taskkill /IM PinSoundStudio.exe

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Run, c:\PinSoundStudio-18.8.3\PinSoundStudio.exe
WinWait, PinSound Studio
WinMinimize