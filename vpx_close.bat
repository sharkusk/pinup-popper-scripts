REM Call this batch file from Popper's Visual Pinball X Close Script.  It should be the last line.
REM CALL [STARTDIR]Scripts\vpx_launch.bat "[DIREMU]" "[DIRGAME]" "[DIRROM]" "[GAMEFULLNAME]" "[GAMENAME]" "[GAMEEXT]" "[STARTDIR]" "[CUSTOM1]" "[CUSTOM2]" "[CUSTOM3]" "[ALTEXE]" "[ALTMODE]" "[MEDIADIR]" "[?ROM?]" "[?GameType?]"

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

ECHO VPX close script start>> "%STARTDIR%\scripts\logs\debug.log"

IF NOT "%ROM%"=="" (
    ECHO Starting high score generation...>> "%STARTDIR%\scripts\logs\debug.log"
    ECHO "%STARTDIR%Scripts\hiscore.bat" %ROM% "%GAMENAME%" "%GameType%">> "%STARTDIR%\scripts\logs\debug.log"

    REM Generate HiScore media file
    CALL "%STARTDIR%Scripts\hiscore.bat" %ROM% "%GAMENAME%" "%GameType%"
    ECHO Completed high score generation>> "%STARTDIR%\scripts\logs\debug.log"
)

ECHO Restoring settings...>> "%STARTDIR%\scripts\logs\debug.log"
CALL "%STARTDIR%restore_settings.bat"
REM DEL "%STARTDIR%restore_settings.bat"

ECHO Settings have been restored.>> "%STARTDIR%\scripts\logs\debug.log"
ECHO VPX close script end>> "%STARTDIR%\scripts\logs\debug.log"