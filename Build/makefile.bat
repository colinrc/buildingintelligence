@ECHO OFF
:: makefile.bat
::
:: Creates library directories
:: Author : David Gavin
:: Building Intelligence 2006

if exist library goto makeScript
mkdir library

:makeScript
if exist library goto makeFolders
mkdir script

:makefolders
cd library
if exist AlertGroups goto makeCalendar
mkdir AlertGroups

:makeCalendar
if exist Calender goto makeCalender_Settings
mkdir Calender

:makeCalender_Settings
if exist Calendar_Settings goto makeCalendar_Tab
mkdir Calendar_Settings

:makeCalendar_Tab
if exist Calendar_Tab goto makeCBus
mkdir Calendar_Tab

:makeCbus
if exist CBus goto makeClient
mkdir CBus

:makeClient
if exist Client goto makeClientAlerts
mkdir Client

:makeClientAlerts
if exist ClientAlerts goto makeClientApps_Bar
mkdir ClientAlerts

:makeClientApps_Bar
if exist ClientApps_Bar goto makeClientArbitrary
mkdir ClientApps_Bar

:makeClientArbitrary
if exist ClientArbitrary goto makeClientControl
mkdir ClientArbitrary

:makeClientControl
if exist ClientControl goto makeClientControl_Panel_Apps
mkdir ClientControl

:makeClientControl_Panel_Apps
if exist ClientControl_Panel_Apps goto makeClientControl_Types
mkdir ClientControl_Panel_Apps

:makeClientControl_Types
if exist ClientControl_Types goto makeClientDoors
mkdir ClientControl_Types

:makeClientDoors
if exist ClientDoors goto makeClientIcon
mkdir ClientDoors

:makeClientIcon
if exist ClientIcon goto makeClientRoom
mkdir ClientIcon

:makeClientRoom
if exist ClientRoom goto makeClientSounds
mkdir ClientRoom

:makeClientSounds
if exist ClientSounds goto makeClientTab
mkdir ClientSounds

:makeClientTab
if exist ClientTab goto makeClientWindow
mkdir ClientTab

:makeClientWindow
if exist ClientWindow goto makeComfort
mkdir ClientWindow

:makeComfort
if exist Comfort goto makeDynalite
mkdir Comfort

:makeDynalite
if exist Dynalite goto makeGC100
mkdir Dynalite

:makeGC100
if exist GC100 goto makeHal
mkdir GC100

:makeHal
if exist Hal goto makeIRLearner
mkdir Hal

:makeIRLearner
if exist IRLearner goto makeKramer
mkdir IRLearner

:makeKramer
if exist Kramer goto makeLogging
mkdir Kramer

:makeLogging
if exist Logging goto makeLoggingGroup
mkdir Logging

:makeLoggingGroup
if exist LoggingGroup goto makeM1
mkdir LoggingGroup

:makeM1
if exist M1 goto makeNuvo
mkdir M1

:makeNuvo
if exist Nuvo goto makeOregon
mkdir Nuvo

:makeOregon
if exist Oregon goto makePanel
mkdir Oregon

:makePanel
if exist Panel goto makeProperty
mkdir Panel

:makeProperty
if exist Property goto makeRaw_Connection
mkdir Property

:makeRaw_Connection
if exist Raw_Connection goto makeServer
mkdir Raw_Connection

:makeServer
if exist Server goto makeSignVideo
mkdir Server

:makeSignVideo
if exist SignVideo goto makeStatusBar
mkdir SignVideo

:makeStatusBar
if exist StatusBar goto makeStatusBarGroup
mkdir StatusBar

:makeStatusBarGroup
if exist StatusBarGroup goto makeTutondo
mkdir StatusBarGroup

:makeTutondo
if exist Tutondo goto makeVariables
mkdir Tutondo

:makeVariables
if exist Variables goto makeZone
mkdir Variables

:makeZone
if exist Zone goto makeMacros
mkdir Zone

:makeMacros
if exist Macros goto end
mkdir Macros

:end