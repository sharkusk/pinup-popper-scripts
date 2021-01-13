ECHO Closing VPX>> "[STARTDIR]\scripts\logs\debug.log"
START "" "[STARTDIR]LAUNCH\PUPCLOSER.EXE" WINTIT "Visual Pinball" 10 1

TIMEOUT /T 1 /NOBREAK

IF NOT "[?ROM?]"=="" (
    ECHO "[STARTDIR]Scripts\hiscore.bat" [?ROM?] "[GAMENAME]" "[?GameType?]">> "[STARTDIR]\scripts\logs\debug.log"

    REM Generate HiScore media file
    CALL "[STARTDIR]Scripts\hiscore.bat" [?ROM?] "[GAMENAME]" "[?GameType?]"
    ECHO Generated high score>> "[STARTDIR]\scripts\logs\debug.log"
)

CALL "[STARTDIR]restore_settings.bat"
REM DEL "[STARTDIR]restore_settings.bat"

ECHO Restored settings... Done.>> "[STARTDIR]\scripts\logs\debug.log"