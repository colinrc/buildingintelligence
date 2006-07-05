; The name of the installer
Name "eLIFE Administration Tool"

; The file to write
OutFile "elife-admin-install.exe"

; The default installation directory
InstallDir "$PROGRAMFILES\BI\eLIFE Administration Tool"

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\BI\eLIFE Administration Tool" "Install_Dir"

;--------------------------------

; Pages

Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

; The stuff to install
Section "eLIFE Administration Tool (required)"

  SectionIn RO
  
  SetOutPath $INSTDIR
  File "admin-tool.exe"
  File "eLIFEAdminTool.chm"
  File "wodSFTP.dll"
  File "BIwodSFTP.ocx"
  File "haspdinst.exe"

  SetOutPath "$INSTDIR\wscite"
  File "wscite\*.*"

  SetOutPath "$INSTDIR\library"
  SetOutPath "$INSTDIR\library\AlertGroups"
  SetOutPath "$INSTDIR\library\Calender"
  SetOutPath "$INSTDIR\library\Calendar_Settings"
  SetOutPath "$INSTDIR\library\Calendar_Tab"
  SetOutPath "$INSTDIR\library\CBus"
  SetOutPath "$INSTDIR\library\Client"
  SetOutPath "$INSTDIR\library\ClientAlerts"
  SetOutPath "$INSTDIR\library\ClientApps_Bar"
  SetOutPath "$INSTDIR\library\ClientArbitrary"
  SetOutPath "$INSTDIR\library\ClientControl"
  SetOutPath "$INSTDIR\library\ClientControl_Panel_Apps"
  SetOutPath "$INSTDIR\library\ClientControl_Types"
  SetOutPath "$INSTDIR\library\ClientDoors"
  SetOutPath "$INSTDIR\library\ClientIcon"
  SetOutPath "$INSTDIR\library\ClientRoom"
  SetOutPath "$INSTDIR\library\ClientSounds"
  SetOutPath "$INSTDIR\library\ClientTab"
  SetOutPath "$INSTDIR\library\ClientWindow"
  SetOutPath "$INSTDIR\library\Comfort"
  SetOutPath "$INSTDIR\library\Dynalite"
  SetOutPath "$INSTDIR\library\GC100"
  SetOutPath "$INSTDIR\library\Hal"
  SetOutPath "$INSTDIR\library\IRLearner"
  SetOutPath "$INSTDIR\library\Kramer"
  SetOutPath "$INSTDIR\library\Logging"
  SetOutPath "$INSTDIR\library\LoggingGroup"
  SetOutPath "$INSTDIR\library\M1"
  SetOutPath "$INSTDIR\library\Nuvo"
  SetOutPath "$INSTDIR\library\Oregon"
  SetOutPath "$INSTDIR\library\Panel"
  SetOutPath "$INSTDIR\library\Property"
  SetOutPath "$INSTDIR\library\Raw_Connection"
  SetOutPath "$INSTDIR\library\Server"
  SetOutPath "$INSTDIR\library\SignVideo"
  SetOutPath "$INSTDIR\library\StatusBar"
  SetOutPath "$INSTDIR\library\StatusBarGroup"
  SetOutPath "$INSTDIR\library\Tutondo"
  SetOutPath "$INSTDIR\library\Variables"
  SetOutPath "$INSTDIR\library\Zone"
  SetOutPath "$INSTDIR\library\Macros"
  SetOutPath "$INSTDIR\script"
  SetOutPath "$INSTDIR\defaults"
  File "defaults\*.*"
  SetOutPath "$INSTDIR\data"
  File "data\*.*"
  SetOutPath "$INSTDIR\datafiles"
  File "datafiles\*.*"
  SetOutPath "$INSTDIR\lib"
  SetOutPath "$INSTDIR\lib\backgrounds"
  SetOutPath "$INSTDIR\lib\icons"
  File "lib\icons\*.*"
  SetOutPath "$INSTDIR\lib\objects"
  SetOutPath "$INSTDIR\lib\maps"
  SetOutPath "$INSTDIR\lib\sounds"

  Exec '"regsvr32 $INSTDIR\wodSFTP.dll"'
  Exec '"regsvr32 $INSTDIR\BIwodSFTP.ocx"'

  ReadRegStr $R0 HKCR ".elp" ""
  StrCmp $R0 "ELPFile" 0 +2
    DeleteRegKey HKCR "ELPFile"

  WriteRegStr HKCR ".elp" "" "eLIFE.Project"
  WriteRegStr HKCR "eLIFE.Project" "" "eLife Project File"
  WriteRegStr HKCR "eLIFE.Project\DefaultIcon" "" "$INSTDIR\admin-tool.exe"
  WriteRegStr HKCR "eLIFE.Project\shell\open\command" "" '$INSTDIR\admin-tool.exe "%1"'

  ; Write the installation path into the registry
  WriteRegStr HKLM "SOFTWARE\BI\eLIFE Administration Tool" "Install_Dir" "$INSTDIR"
  
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BI\eLIFE Administration Tool" "DisplayName" "eLIFE Administration Tool"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BI\eLIFE Administration Tool" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BI\eLIFE Administration Tool" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BI\eLIFE Administration Tool" "NoRepair" 1
  WriteUninstaller "uninstall.exe"
  
SectionEnd

; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts"

  CreateDirectory "$SMPROGRAMS\BI\eLIFE Administration Tool"
  CreateShortCut "$SMPROGRAMS\BI\eLIFE Administration Tool\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortCut "$SMPROGRAMS\BI\eLIFE Administration Tool\eLIFE Administration Tool.lnk" "$INSTDIR\admin-tool.exe" "" "$INSTDIR\admin-tool.exe" 0
  
SectionEnd

; Optional section (can be disabled by the user)
Section "Desktop Shortcut"

  CreateShortCut "$DESKTOP\eLIFE Administration Tool.lnk" "$INSTDIR\admin-tool.exe" "" "$INSTDIR\admin-tool.exe" 0
  
SectionEnd

; Optional section (can be disabled by the user)
Section "HASP Key Driver"

  Exec '"$INSTDIR\haspdinst.exe -install"'
  
SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"
  
  ReadRegStr $R0 HKCR ".elp" ""
  StrCmp $R0 "ELPFile" 0 +2
    DeleteRegKey HKCR "ELPFile"

  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BI\eLIFE Administration Tool"
  DeleteRegKey HKLM "SOFTWARE\BI\eLIFE Administration Tool"

  Exec '"regsvr32 $INSTDIR\wodSFTP.dll /u"'
  Exec '"regsvr32 $INSTDIR\BIwodSFTP.ocx /u"'

  Exec '"$EXEDIR\haspdinst.exe -remove -kp -nomsg"'

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\BI\eLIFE Administration Tool\*.*"

  ; Remove directories used
  RMDir /r "$SMPROGRAMS\BI"
  RMDir /r "$INSTDIR"

SectionEnd
