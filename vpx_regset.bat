SET ROM=%1
SET ALTMODE=%2
SET RESTOREFILE=%3

REM Store the current settings
REM QUERY returns multiple lines, we only care about the actual value, so extract and store in variable
FOR /F "skip=2 tokens=2,*" %%A IN ('REG QUERY "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v "sound_mode"') DO SET "sound_mode=%%B"
FOR /F "skip=2 tokens=2,*" %%A IN ('REG QUERY "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v "resampling_quality"') DO SET "resampling_quality=%%B"

ECHO REM %ROM%, %ALTMODE%>> %RESTOREFILE%

IF %ALTMODE%=="origsound" (
    REG ADD "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v sound_mode /t REG_DWORD /d 0 /f
    REG ADD "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v resampling_quality /t REG_DWORD /d 0 /f

    REM -----------  CLEANUP ON CLOSE -----------
    ECHO REG ADD "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v sound_mode /t REG_DWORD /d %sound_mode% /f>> %RESTOREFILE%
    ECHO REG ADD "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v resampling_quality /t REG_DWORD /d %resampling_quality% /f>> %RESTOREFILE%

    SET use_backglass=1
)

IF %ALTMODE%=="altsound" (
    REG ADD "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v sound_mode /t REG_DWORD /d 1 /f
    REG ADD "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v resampling_quality /t REG_DWORD /d 1 /f

    REM -----------  CLEANUP ON CLOSE -----------
    ECHO REG ADD "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v sound_mode /t REG_DWORD /d %sound_mode% /f>> %RESTOREFILE%
    ECHO REG ADD "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v resampling_quality /t REG_DWORD /d %resampling_quality% /f>> %RESTOREFILE%

    SET use_backglass=2
)

IF %ALTMODE%=="pinsound" (
    REG ADD "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v sound_mode /t REG_DWORD /d 2 /f
    REG ADD "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v resampling_quality /t REG_DWORD /d 1 /f

    REM -----------  CLEANUP ON CLOSE -----------
    ECHO REG ADD "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v sound_mode /t REG_DWORD /d %sound_mode% /f>> %RESTOREFILE%
    ECHO REG ADD "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v resampling_quality /t REG_DWORD /d %resampling_quality% /f>> %RESTOREFILE%

    SET use_backglass=1
)

REM Force cabinet mode to prevent PinMAME splash screen
FOR /F "skip=2 tokens=2,*" %%A IN ('REG QUERY "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v "cabinet_mode"') DO SET "cabinet_mode=%%B"
REG ADD "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v cabinet_mode /t REG_DWORD /d 1 /f
REM -----------  CLEANUP ON CLOSE -----------
ECHO REG ADD "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v cabinet_mode /t REG_DWORD /d %cabinet_mode% /f>> %RESTOREFILE%

REM Skip Pinball Test to Speed Up Table Load
FOR /F "skip=2 tokens=2,*" %%A IN ('REG QUERY "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v "cheat"') DO SET "cheat=%%B"
REG ADD "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v cheat /t REG_DWORD /d 1 /f
REM -----------  CLEANUP ON CLOSE -----------
ECHO REG ADD "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v cheat /t REG_DWORD /d %cheat% /f>> %RESTOREFILE%