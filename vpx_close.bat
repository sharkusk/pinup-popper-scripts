START "" "[STARTDIR]LAUNCH\PUPCLOSER.EXE" WINTIT "Visual Pinball" 10 1 

ECHO REM "[STARTDIR]Scripts\hiscore.bat" [?ROM?] "[GAMENAME]" "[?GameType?]">> "[STARTDIR]restore_settings.bat"

REM Generate HiScore media file
CALL "[STARTDIR]Scripts\hiscore.bat" [?ROM?] "[GAMENAME]" "[?GameType?]"

CALL "[STARTDIR]restore_settings.bat"
REM DEL "[STARTDIR]restore_settings.bat"

ECHO REM Reached end...>> "[STARTDIR]restore_settings.bat"
