REM VPX Pinup Popper Close Script (by Sharkus)
REM This entire file should be copied to the "Close Script" found in Popper Setup->Emulators->Launch Setup (Visual Pinball X)

"[STARTDIR]LAUNCH\PUPCLOSER.EXE" WINTIT "Visual Pinball" 10 1 

CALL [STARTDIR]"restore_settings.bat"
DEL [STARTDIR]"restore_settings.bat"