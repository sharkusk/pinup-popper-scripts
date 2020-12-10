REM Altmodes supported:
REM backglass - do not run a pup-pack and use a backglass named table.directb3s.bak
REM origsound - use the original rom sound with a forced backglass
REM altsound - use the altsound with a forced backglass
REM pinsound - use the pinsound with a forced backglass

START "" "[STARTDIR]Launch\VPXSTARTER.exe" 30 10 60 “Visual Pinball Player” 2
CD /d "[DIREMU]"

REM Initialize a file that is going to restore any settings we change when we close
ECHO @ECHO OFF> [STARTDIR]"restore_settings.bat"

REM Ghostbusters requires freezy 1.71 (be sure to name it 'DmdDevice.dll.spagb100' in VPinMame directory)
IF "[?ROM?]"=="spagb100" (
    IF EXIST "[DIREMU]\VPinMAME\DmdDevice.dll.180" (
        REM Something bad happened and our backup got left around.
        REM We will assume that the spagb100 version of dmddevice is still in place.
    ) ELSE (
        REM Backup current version of DMD Device
        COPY /Y "[DIREMU]\VPinMAME\DmdDevice.ini" "[DIREMU]\VPinMAME\DmdDevice.ini.180"
        COPY /Y "[DIREMU]\VPinMAME\DmdDevice.dll" "[DIREMU]\VPinMAME\DmdDevice.dll.180"

        REM Copy version needed by Ghostbusters
        COPY /Y "[DIREMU]\VPinMAME\DmdDevice.ini.spagb100" "[DIREMU]\VPinMAME\DmdDevice.ini"
        COPY /Y "[DIREMU]\VPinMAME\DmdDevice.dll.spagb100" "[DIREMU]\VPinMAME\DmdDevice.dll"
    )

    REM Need to wait for VP to release the DLL before we can copy
    ECHO TIMEOUT /t 2 /nobreak>> [STARTDIR]"restore_settings.bat"
    REM Restore previous version on table close
    ECHO COPY /Y "[DIREMU]\VPinMAME\DmdDevice.ini.180" "[DIREMU]\VPinMAME\DmdDevice.ini">> [STARTDIR]"restore_settings.bat"
    ECHO COPY /Y "[DIREMU]\VPinMAME\DmdDevice.dll.180" "[DIREMU]\VPinMAME\DmdDevice.dll">> [STARTDIR]"restore_settings.bat"

    REM Delete the backup when the table closes
    ECHO DEL "[DIREMU]\VPinMAME\DmdDevice.ini.180">> [STARTDIR]"restore_settings.bat"
    ECHO DEL "[DIREMU]\VPinMAME\DmdDevice.dll.180">> [STARTDIR]"restore_settings.bat"
)

SET use_backglass=0

IF "[ALTMODE]"=="backglass" (
    SET use_backglass=1
)

REM QUERY returns multiple lines, we only care about the actual value, so extract and store in variable
FOR /F "skip=2 tokens=2,*" %%A IN ('REG QUERY "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v "sound_mode"') DO SET "sound_mode=%%B"
FOR /F "skip=2 tokens=2,*" %%A IN ('REG QUERY "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v "resampling_quality"') DO SET "resampling_quality=%%B"
 
IF "[ALTMODE]"=="origsound" (
    ECHO REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v sound_mode /t REG_DWORD /d %sound_mode% /f>> [STARTDIR]"restore_settings.bat"
    ECHO REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v resampling_quality /t REG_DWORD /d %resampling_quality% /f>> [STARTDIR]"restore_settings.bat"

    REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v sound_mode /t REG_DWORD /d 0 /f
    REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v resampling_quality /t REG_DWORD /d 0 /f

    SET use_backglass=1
)

IF "[ALTMODE]"=="altsound" (
    ECHO REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v sound_mode /t REG_DWORD /d %sound_mode% /f>> [STARTDIR]"restore_settings.bat"
    ECHO REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v resampling_quality /t REG_DWORD /d %resampling_quality% /f>> [STARTDIR]"restore_settings.bat"

    REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v sound_mode /t REG_DWORD /d 1 /f
    REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v resampling_quality /t REG_DWORD /d 1 /f

    SET use_backglass=1
)

IF "[ALTMODE]"=="pinsound" (
    ECHO REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v sound_mode /t REG_DWORD /d %sound_mode% /f>> [STARTDIR]"restore_settings.bat"
    ECHO REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v resampling_quality /t REG_DWORD /d %resampling_quality% /f>> [STARTDIR]"restore_settings.bat"

    REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v sound_mode /t REG_DWORD /d 2 /f
    REG ADD "HKCU\Software\Freeware\Visual PinMame\[?ROM?]" /v resampling_quality /t REG_DWORD /d 1 /f

    SET use_backglass=1
)

IF %use_backglass%==1 (
    REM Tell PinUp Player to not use Pup pack this time around
    ECHO 1>> "[STARTDIR]PUPVideos\[?ROM?]\PUPHideNext.txt"

    REM If we have a backglass available, copy it and delete on exit to restore law and order
    IF EXIST "[DIRGAME]\[GAMENAME].directb2s.bak" (
        COPY /Y "[DIRGAME]\[GAMENAME].directb2s.bak" "[DIRGAME]\[GAMENAME].directb2s"
        ECHO DEL "[DIRGAME]\[GAMENAME].directb2s">> [STARTDIR]"restore_settings.bat"
    )
)

IF "[RECMODE]"=="1" (
    START /min "" vpinballx.exe "[DIREMU]" -DisableTrueFullscreen -minimized -play "[GAMEFULLNAME]"
) else (
    START /min "" vpinballx.exe "[DIREMU]" -minimized -play "[GAMEFULLNAME]"
)