REM VPX Pinup Popper Launch Script (by Sharkus)
REM This entire file should be copied to the "Launch Script" found in Popper Setup->Emulators->Launch Setup (Visual Pinball X)

REM As this launch script executes, it creates "restore_settings.bat" that will revert all changes.
REM This keeps all of the code co-located and prevents accidents (i.e. bugs).
REM "restore_settings.bat" should be called from the close script.

REM Altmodes supported:
REM backglass - do not run a pup-pack and use a backglass named [tablename].directb2s.BG
REM origsound - use the original rom sound with a forced backglass
REM altsound - use the altsound with a forced backglass
REM pinsound - use the pinsound with a forced backglass

ECHO VPX Launch Starting... ROM: [?ROM?]> "[STARTDIR]\scripts\logs\debug.log"

REM Initialize a file that is going to restore any settings we change when we close
ECHO REM Restore settings for [GAMENAME]> "[STARTDIR]restore_settings.bat" 

SET use_backglass=0

IF "[ALTMODE]"=="backglass" (
    SET use_backglass=1
)

REM Check if we are dealing with a PinMAME ROM
REG QUERY "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v "sound_mode"
IF %errorlevel%==0 (
    SET PinMAME=1
) else (
    SET PinMAME=0
)

IF %PinMAME%==1 (
    CALL "[STARTDIR]scripts\vpx_regset.bat" [?ROM?] "[ALTMODE]" "[STARTDIR]restore_settings.bat"
)

IF %use_backglass%==1 (
    IF EXIST "[STARTDIR]PUPVideos\[?ROM?]\" (
        REM Tell PinUp Player to not use Pup pack this time around
        ECHO 1>> "[STARTDIR]PUPVideos\[?ROM?]\PUPHideNext.txt"
    )

    REM If we have a backglass available, copy it and delete on exit to restore law and order
    IF EXIST "[DIRGAME]\[GAMENAME].directb2s.BG" (
        COPY /Y "[DIRGAME]\[GAMENAME].directb2s.BG" "[DIRGAME]\[GAMENAME].directb2s"

        REM -----------  CLEANUP ON CLOSE -----------
        ECHO DEL "[DIRGAME]\[GAMENAME].directb2s">> "[STARTDIR]restore_settings.bat"
    )

    IF EXIST "[DIRROM]\[?ROM?].zip.BG" (
        IF NOT EXIST "[DIRROM]\[?ROM?].zip.pinup" (
            COPY /Y "[DIRROM]\[?ROM?].zip" "[DIRROM]\[?ROM?].zip.pinup"
        )
        COPY /Y "[DIRROM]\[?ROM?].zip.BG" "[DIRROM]\[?ROM?].zip"

        REM -----------  CLEANUP ON CLOSE -----------
        ECHO COPY /Y "[DIRROM]\[?ROM?].zip.pinup" "[DIRROM]\[?ROM?].zip">> "[STARTDIR]restore_settings.bat"
    )
)

TIMEOUT /T 1 /NOBREAK

START "" "[STARTDIR]Launch\VPXSTARTER.exe" 30 10 60 “Visual Pinball Player” 2
CD /d "[DIREMU]"

IF "[RECMODE]"=="1" (
    START /min "" vpinballx.exe "[DIREMU]" -DisableTrueFullscreen -minimized -play "[GAMEFULLNAME]"
) else (
    START /min "" vpinballx.exe "[DIREMU]" -minimized -play "[GAMEFULLNAME]"
)