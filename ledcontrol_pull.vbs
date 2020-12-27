Option Explicit
' ledcontrol_pull.vbs  - Utility to download ledcontrol.ini files from LedWiz Config Tool (http://vpuniverse.com/ledwiz)
'
' For support goto http://vpuniverse.com/forums/index.php/topic/332-ledwiz-configtool-downloader/
'
' Version History
'	1.0 	- Initial Release
'	1.1 	- Improved login/session recognition 
'	2.0 	- Use new APIs 
'

Dim sVersion
sVersion = "2.0"

'Set default parameter values.
Dim param_apikey
Dim param_savefile
Dim param_vptablespath
Dim param_verbose
Dim param_log
Dim param_overwrite
Dim param_debug
Dim param_forceupdate

param_apikey = ""
param_savefile = "directoutputconfig.zip"
param_vptablespath = ""
param_verbose = True
param_log = False
param_overwrite = 1
param_debug = False
param_forceupdate = False

' Process parameters passed to script.
If WScript.Arguments.Count > 0 Then
	Dim objArgs
	Set objArgs = WScript.Arguments
	Dim Argument
	For Each Argument in objArgs
		Select Case UCase(Left(Argument,3))
			Case "/A="	' API Key
				param_apikey = Mid(Argument,4)
			Case "/F="	' File names and optionally path to save the downloaded zip.  defaults to ledcontrol.zip in the script execution directory.
				param_savefile = Mid(Argument,4)
			Case "/T="	' Where to save the ledcontrol.ini files. Should be your Visual Pinball Tables path but will default to the script execution directory.
				param_vptablespath = Mid(Argument,4)
			Case "/V"	' Display Messages
				param_verbose = True
			Case "/-V"	' Do not display Messages (aka silent mode)
				param_verbose = False
			Case "/L"	' Turn on detailed loging
				param_log = True
			Case "/-L"	' Turn off detailed loging
				param_log = False
			Case "/Y"	' Overwrite files
				param_overwrite = 2
			Case "/-Y"	' Do not overwrite files
				param_overwrite = 1
			Case "/D"	' Display Debug Messages
				param_debug = True
			Case "/F"	' Force Update
				param_forceupdate = True
			Case Else
				MsgBox "Error: Unrecogognized parameter." & Chr(13) & Chr(10) & Argument, 16
				WScript.Echo "Error: Unrecogognized parameter." & Chr(13) & Chr(10) & "Parameter: " & Argument
		End Select
	Next
End If

If param_verbose Then
	WScript.Echo "**** LEDWiz Config Tool Pull Utility (v" & sVersion & ") by Zarquon"
	WScript.Echo ""
	WScript.Echo "     For support goto http://vpuniverse.com/forums/index.php/topic/332-ledwiz-configtool-downloader/"
	WScript.Echo ""
End If

If param_debug Then
	WScript.Echo "** Debug: Parameters"
	WScript.Echo "     param_apikey = " & param_apikey
	WScript.Echo "     param_savefile = " & param_savefile
	WScript.Echo "     param_vptablespath = " & param_vptablespath
	WScript.Echo "     param_verbose = " & IIF(param_verbose, "True", "False")
	WScript.Echo "     param_log = " & IIF(param_log, "True", "False")
	WScript.Echo "     param_overwrite = " & param_overwrite 
	WScript.Echo "     param_forceupdate = " & param_forceupdate 
End If

'Get script path
Dim sScriptPath
sScriptPath = Left(WScript.ScriptFullName,(Len(WScript.ScriptFullName)-Len(Wscript.ScriptName)))

'If no path supplied for vptables director use the scripts directory
If param_vptablespath = "" Then
	param_vptablespath = sScriptPath
End If

'URLs to open....
Dim sVersionUrl
Dim sDownloadUrl
sVersionUrl = "http://configtool.vpuniverse.com/api.php?query=version"
sDownloadUrl = "http://configtool.vpuniverse.com/api.php?query=getconfig&apikey=" & param_apikey

'If the extraction location does not exist create it.
Dim fso
Set fso = CreateObject("Scripting.FileSystemObject")
If NOT fso.FolderExists(param_vptablespath) Then
	WScript.Echo "** Error: Invalid Destination Path [" & param_vptablespath & "]"
Else
	Dim oXMLHTTP
	Set oXMLHTTP = CreateObject("Microsoft.XMLHTTP")

	Dim bDoDownload
	bDoDownload = False
	If param_forceupdate Then
		bDoDownload = True
	Else
		If param_debug Or param_verbose Then WScript.Echo "**** Checking INI Version ****"
		Dim iIniVersion
		iIniVersion = ReadIni(param_vptablespath & "\ledcontrol.ini", "version", "version")
		If IsNumeric(iIniVersion) Then
			iIniVersion = CInt(iIniVersion)
			If param_debug Or param_verbose Then WScript.Echo "     INI Version = " & iIniVersion
		Else
			WScript.Echo "** Warning: Version not found in ini file (" & param_vptablespath & "\ledcontrol.ini).  will update regardless of the online version."
			iIniVersion = -1
		End If

		Dim iOnlineVersion
		iOnlineVersion = 0

		If param_debug Or param_verbose Then WScript.Echo "**** Requesting Online Version ****"

		'Request Zip File
		oXMLHTTP.open "GET", sVersionUrl, False
		oXMLHTTP.send
		If oXMLHTTP.Status = 200 Then
			If IsNumeric(oXMLHTTP.responseText) Then
				iOnlineVersion = CInt(oXMLHTTP.responseText)
				If param_debug Or param_verbose Then WScript.Echo "     Online Version = " & iOnlineVersion
			End If
		Else
			WScript.Echo "** Error: Unable to get version."
		End If
		
		bDoDownload = CBool(iOnlineVersion > iIniVersion)
		If Not bDoDownload Then
			If iOnlineVersion < iIniVersion Then
				WScript.Echo "** Warning: You seem to have a newer version (" & iIniVersion & ") than the online version (" & iOnlineVersion & ")"
			Else
				WScript.Echo "** Version (" & iOnlineVersion & ") is current."
			End If
		End If
	End If
	If bDoDownload Then
		If param_debug Or param_verbose Then WScript.Echo "**** Requesting File ****"

		'Request Zip File
		oXMLHTTP.open "GET", sDownloadUrl, False
		oXMLHTTP.send

		If oXMLHTTP.Status = 200 Then
			'Download and Save Zip file
			Dim oStream
			Set oStream = CreateObject("ADODB.Stream")
			oStream.Type = 1 'adTypeBinary
			oStream.Open
			oStream.Write oXMLHTTP.responseBody
			oStream.SaveToFile param_savefile, param_overwrite
			oStream.Close
			Set oStream = Nothing
		Else
			WScript "** Error: Unable to download."
		End If

		If (NOT fso.FileExists(param_savefile)) Or fso.GetFile(param_savefile).Size < 1024 Then
			WScript "** Error: Archive not downloaded correctly."
		Else
			'Ensure full path to zip file is used.
			If Instr(param_savefile, "\") = 0 Then
				If param_debug Then WScript.Echo "** Debug: Adjusting Zip file Path"
				param_savefile = fso.GetFile(param_savefile).Path
			End If
			
			If param_debug Or param_verbose Then WScript.Echo "**** Extracting Files ****"

			If param_debug Then WScript.Echo "** Debug: Extracting From " & param_savefile
			If param_debug Then WScript.Echo "** Debug: Extracting To   " & param_vptablespath

			Dim iCopyOptions
			iCopyOptions = 0
			If Not param_verbose Then iCopyOptions = iCopyOptions + 4
			If param_overwrite = 2 Then iCopyOptions = iCopyOptions + 16

			'Extract the contants of the zip file.
			Dim oShell
			Dim oFilesInZip
			Set oShell = CreateObject("Shell.Application")
			Set oFilesInZip = oShell.NameSpace(param_savefile).items

			oShell.NameSpace(param_vptablespath).CopyHere oFilesInZip, iCopyOptions
			Set oShell = Nothing
		End If
	End If
	Set oXMLHTTP = Nothing
End If
Set fso = Nothing

Function IIf(bBoolean, vTrueResponse, vFalseResponse)
   IIf = vFalseResponse
   If bBoolean Then IIf = vTrueResponse
End Function

'INI File Functions - From http://www.robvanderwoude.com/vbstech_files_ini.php
Function ReadIni( myFilePath, mySection, myKey )
    ' This function returns a value read from an INI file
    '
    ' Arguments:
    ' myFilePath  [string]  the (path and) file name of the INI file
    ' mySection   [string]  the section in the INI file to be searched
    ' myKey       [string]  the key whose value is to be returned
    '
    ' Returns:
    ' the [string] value for the specified key in the specified section
    '
    ' CAVEAT:     Will return a space if key exists but value is blank
    '
    ' Written by Keith Lacelle
    ' Modified by Denis St-Pierre and Rob van der Woude

    Const ForReading   = 1
    Const ForWriting   = 2
    Const ForAppending = 8

    Dim intEqualPos
    Dim objFSO, objIniFile
    Dim strFilePath, strKey, strLeftString, strLine, strSection

    Set objFSO = CreateObject( "Scripting.FileSystemObject" )

    ReadIni     = ""
    strFilePath = Trim( myFilePath )
    strSection  = Trim( mySection )
    strKey      = Trim( myKey )
    If objFSO.FileExists( strFilePath ) Then
        Set objIniFile = objFSO.OpenTextFile( strFilePath, ForReading, False )
        Do While objIniFile.AtEndOfStream = False
            strLine = Trim( objIniFile.ReadLine )

            ' Check if section is found in the current line
            If LCase( strLine ) = "[" & LCase( strSection ) & "]" Then
                strLine = Trim( objIniFile.ReadLine )

                ' Parse lines until the next section is reached
                Do While Left( strLine, 1 ) <> "["
                    ' Find position of equal sign in the line
                    intEqualPos = InStr( 1, strLine, "=", 1 )
                    If intEqualPos > 0 Then
                        strLeftString = Trim( Left( strLine, intEqualPos - 1 ) )
                        ' Check if item is found in the current line
                        If LCase( strLeftString ) = LCase( strKey ) Then
                            ReadIni = Trim( Mid( strLine, intEqualPos + 1 ) )
                            ' In case the item exists but value is blank
                            If ReadIni = "" Then
                                ReadIni = " "
                            End If
                            ' Abort loop when item is found
                            Exit Do
                        End If
                    End If

                    ' Abort if the end of the INI file is reached
                    If objIniFile.AtEndOfStream Then Exit Do

                    ' Continue with next line
                    strLine = Trim( objIniFile.ReadLine )
                Loop
            Exit Do
            End If
        Loop
        objIniFile.Close
    Else
        WScript.Echo strFilePath & " doesn't exists. Exiting..."
        Wscript.Quit 1
    End If
End Function

