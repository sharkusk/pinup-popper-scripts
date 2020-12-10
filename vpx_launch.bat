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

START "" "[STARTDIR]Launch\VPXSTARTER.exe" 30 10 60 “Visual Pinball Player” 2
CD /d "[DIREMU]"

REM Initialize a file that is going to restore any settings we change when we close
ECHO @ECHO OFF> "[STARTDIR]restore_settings.bat"

SET use_backglass=0

IF "[ALTMODE]"=="backglass" (
    SET use_backglass=1
)

REM Force cabinet mode to prevent PinMAME splash screen
REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v cabinet_mode /t REG_DWORD /d 1 /f

REM Skip Pinball Test to Speed Up Table Load
REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v cheat /t REG_DWORD /d 1 /f

REM Store the current audio settings
REM QUERY returns multiple lines, we only care about the actual value, so extract and store in variable
FOR /F "skip=2 tokens=2,*" %%A IN ('REG QUERY "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v "sound_mode"') DO SET "sound_mode=%%B"
FOR /F "skip=2 tokens=2,*" %%A IN ('REG QUERY "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v "resampling_quality"') DO SET "resampling_quality=%%B"
 
IF "[ALTMODE]"=="origsound" (
    REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v sound_mode /t REG_DWORD /d 0 /f
    REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v resampling_quality /t REG_DWORD /d 0 /f

    REM -----------  CLEANUP ON CLOSE -----------
    ECHO REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v sound_mode /t REG_DWORD /d %sound_mode% /f>> "[STARTDIR]restore_settings.bat"
    ECHO REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v resampling_quality /t REG_DWORD /d %resampling_quality% /f>> "[STARTDIR]restore_settings.bat"

    SET use_backglass=1
)

IF "[ALTMODE]"=="altsound" (
    REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v sound_mode /t REG_DWORD /d 1 /f
    REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v resampling_quality /t REG_DWORD /d 1 /f

    REM -----------  CLEANUP ON CLOSE -----------
    ECHO REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v sound_mode /t REG_DWORD /d %sound_mode% /f>> "[STARTDIR]restore_settings.bat"
    ECHO REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v resampling_quality /t REG_DWORD /d %resampling_quality% /f>> "[STARTDIR]restore_settings.bat"

    SET use_backglass=1
)

IF "[ALTMODE]"=="pinsound" (
    REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v sound_mode /t REG_DWORD /d 2 /f
    REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v resampling_quality /t REG_DWORD /d 1 /f

    REM -----------  CLEANUP ON CLOSE -----------
    ECHO REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v sound_mode /t REG_DWORD /d %sound_mode% /f>> "[STARTDIR]restore_settings.bat"
    ECHO REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v resampling_quality /t REG_DWORD /d %resampling_quality% /f>> "[STARTDIR]restore_settings.bat"

    SET use_backglass=1
)

IF %use_backglass%==1 (
    REM Tell PinUp Player to not use Pup pack this time around
    ECHO 1>> "[STARTDIR]PUPVideos\[?ROM?]\PUPHideNext.txt"

    REM If we have a backglass available, copy it and delete on exit to restore law and order
    IF EXIST "[DIRGAME]\[GAMENAME].directb2s.BG" (
        COPY /Y "[DIRGAME]\[GAMENAME].directb2s.BG" "[DIRGAME]\[GAMENAME].directb2s"

        REM -----------  CLEANUP ON CLOSE -----------
        ECHO DEL "[DIRGAME]\[GAMENAME].directb2s">> "[STARTDIR]restore_settings.bat"
    )
)

IF "[RECMODE]"=="1" (
    START /min "" vpinballx.exe "[DIREMU]" -DisableTrueFullscreen -minimized -play "[GAMEFULLNAME]"
) else (
    START /min "" vpinballx.exe "[DIREMU]" -minimized -play "[GAMEFULLNAME]"
)