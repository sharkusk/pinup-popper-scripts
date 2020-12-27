@ECHO OFF
REM Adjust the following Paramters to match your system
REM   LCP_APIKEY      - This is the API Key for the LedWiz ConfigTool (See http://configtool.vpuniverse.com/) 
REM   LCP_VPTABLEPATH - Path to your Visual Pinball Tables directory (Should contain a training "\" ) leaving this blank it will use the script directory
SET LCP_APIKEY=6BRVYSk1iwd6lWjx7T8x
SET LCP_VPTABLEPATH=C:\DirectOutput\Config
SET LCP_ADDITIONAL_PARAM=/D /V /F
REM IF NOT EXIST "%LCP_VPTABLEPATH%\ledcontrol.ini" SET LCP_ADDITIONAL_PARAM=/F

SET CSCRIPT_EXE=cscript.exe
IF EXIST %SystemRoot%\syswow64\cscript.exe SET CSCRIPT_EXE=%SystemRoot%\syswow64\cscript.exe
%CSCRIPT_EXE% /NoLogo ledcontrol_pull.vbs /a=%LCP_APIKEY% /T="%LCP_VPTABLEPATH%" /-v /y %LCP_ADDITIONAL_PARAM%
