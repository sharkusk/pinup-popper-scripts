REM Call this batch file from Popper's Visual Pinball X Launch Script.  It should be the first line.
REM CALL [STARTDIR]Scripts\vpx_launch.bat "[DIREMU]" "[DIRGAME]" "[DIRROM]" "[GAMEFULLNAME]" "[GAMENAME]" "[GAMEEXT]" "[STARTDIR]" "[CUSTOM1]" "[CUSTOM2]" "[CUSTOM3]" "[ALTEXE]" "[ALTMODE]" "[MEDIADIR]" "[?ROM?]" "[?GameType?]"

REM VPX Pinup Popper Launch Script (by Sharkus)

REM As this launch script executes, it creates "restore_settings.bat" that will revert all changes.
REM This keeps all of the code co-located and prevents accidents (i.e. bugs).
REM "restore_settings.bat" should be called from the close script.

REM Altmodes supported:
REM backglass - do not run a pup-pack and use a backglass named [tablename].BG
REM origsound - use the original rom sound with a forced backglass
REM altsound - use the altsound with a forced backglass
REM pinsound - use the pinsound with a forced backglass

REM Use shift since we have more than 9 parameters
REM Remove quotes from variables
SET DIREMU=%~1
SHIFT
SET DIRGAME=%~1
SHIFT
SET DIRROM=%~1
SHIFT
SET GAMEFULLNAME=%~1
SHIFT
SET GAMENAME=%~1
SHIFT
SET GAMEEXT=%~1
SHIFT
SET STARTDIR=%~1
SHIFT
SET CUSTOM1=%~1
SHIFT
SET CUSTOM2=%~1
SHIFT
SET CUSTOM3=%~1
SHIFT
SET ALTEXE=%~1
SHIFT
SET ALTMODE=%~1
SHIFT
SET MEDIADIR=%~1
SHIFT
REM ?game_field? entries...
SET ROM=%~1
SHIFT
SET GameType=%~1
SHIFT

ECHO VPX launch script start> "%STARTDIR%\scripts\logs\debug.log"
ECHO ... DIREMU: %DIREMU%>> "%STARTDIR%\scripts\logs\debug.log"
ECHO ... DIRGAME: %DIRGAME%>> "%STARTDIR%\scripts\logs\debug.log"
ECHO ... DIRROM: %DIRROM%>> "%STARTDIR%\scripts\logs\debug.log"
ECHO ... GAMEFULLNAME: %GAMEFULLNAME%>> "%STARTDIR%\scripts\logs\debug.log"
ECHO ... GAMENAME: %GAMENAME%>> "%STARTDIR%\scripts\logs\debug.log"
ECHO ... GAMEEXT: %GAMEEXT%>> "%STARTDIR%\scripts\logs\debug.log"
ECHO ... STARTDIR: %STARTDIR%>> "%STARTDIR%\scripts\logs\debug.log"
ECHO ... CUSTOM1: %CUSTOM1%>> "%STARTDIR%\scripts\logs\debug.log"
ECHO ... CUSTOM2: %CUSTOM2%>> "%STARTDIR%\scripts\logs\debug.log"
ECHO ... CUSTOM3: %CUSTOM3%>> "%STARTDIR%\scripts\logs\debug.log"
ECHO ... ALTEXE: %ALTEXE%>> "%STARTDIR%\scripts\logs\debug.log"
ECHO ... ALTMODE: %ALTMODE%>> "%STARTDIR%\scripts\logs\debug.log"
ECHO ... MEDIADIR: %MEDIADIR%>> "%STARTDIR%\scripts\logs\debug.log"
ECHO ... ROM: %ROM%>> "%STARTDIR%\scripts\logs\debug.log"
ECHO ... GameType: %GameType%>> "%STARTDIR%\scripts\logs\debug.log"

REM Initialize a file that is going to restore any settings we change when we close
ECHO REM Restore settings for %GAMENAME%> "%STARTDIR%restore_settings.bat" 

SET use_backglass=0

IF "%ALTMODE%"=="backglass" (
    SET use_backglass=1
)

REM Check if we are dealing with a PinMAME ROM
REG QUERY "HKCU\Software\Freeware\Visual PinMame\%ROM%" /v "sound_mode"
IF %errorlevel%==0 (
    ECHO Detected PinMAME ROM>> "%STARTDIR%\scripts\logs\debug.log"
    SET PinMAME=1
) else (
    ECHO Non PinMAME Table found>> "%STARTDIR%\scripts\logs\debug.log"
    SET PinMAME=0
)

IF %PinMAME%==1 (
    ECHO Setting PinMAME register settings...>> "%STARTDIR%\scripts\logs\debug.log"
    CALL "%STARTDIR%scripts\vpx_regset.bat" %ROM% "%ALTMODE%" "%STARTDIR%restore_settings.bat"
    ECHO Register settings complete>> "%STARTDIR%\scripts\logs\debug.log"
)

IF %use_backglass%==1 (
    ECHO Using backglass...>> "%STARTDIR%\scripts\logs\debug.log"
    IF EXIST "%STARTDIR%PUPVideos\%ROM%\" (
        ECHO Telling pinup to hide next...>> "%STARTDIR%\scripts\logs\debug.log"
        REM Tell PinUp Player to not use Pup pack this time around
        ECHO 1>> "%STARTDIR%PUPVideos\%ROM%\PUPHideNext.txt"
    )

    REM If we have a backglass available, copy it and delete on exit to restore law and order
    IF EXIST "%DIRGAME%\%GAMENAME%.BG" (
        ECHO Copying "%DIRGAME%\%GAMENAME%.BG" to "%DIRGAME%\%GAMENAME%.directb2s">> "%STARTDIR%\scripts\logs\debug.log"
        COPY /Y "%DIRGAME%\%GAMENAME%.BG" "%DIRGAME%\%GAMENAME%.directb2s"

        REM -----------  CLEANUP ON CLOSE -----------
        ECHO DEL "%DIRGAME%\%GAMENAME%.directb2s">> "%STARTDIR%restore_settings.bat"
    )

    IF EXIST "%DIRROM%\%ROM%.zip.BG" (
        IF NOT EXIST "%DIRROM%\%ROM%.zip.pinup" (
            COPY /Y "%DIRROM%\%ROM%.zip" "%DIRROM%\%ROM%.zip.pinup"
        )
        ECHO Copying "%DIRROM%\%ROM%.zip.BG" to "%DIRROM%\%ROM%.zip">> "%STARTDIR%\scripts\logs\debug.log"
        COPY /Y "%DIRROM%\%ROM%.zip.BG" "%DIRROM%\%ROM%.zip"

        REM -----------  CLEANUP ON CLOSE -----------
        ECHO COPY /Y "%DIRROM%\%ROM%.zip.pinup" "%DIRROM%\%ROM%.zip">> "%STARTDIR%restore_settings.bat"
    )
)
ECHO VPX launch script complete>> "%STARTDIR%\scripts\logs\debug.log"
exit /B