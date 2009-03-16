import sys
import time

elife.fireScriptOn("DLT_1")
elife.fireScriptOn("DLT_2")
elife.fireScriptOn("DLT_3")
elife.fireScriptOn("DLT_4")

labelMgr = elife.getLabelMgr()

if triggeringEvent != None:
	currentLabel = labelMgr.getLabelState (triggeringEvent.getDisplayName ())
	elife.log ("Label " + currentLabel)

	#First button
	
	if triggeringEvent.getDisplayName () == "DLT_1":
		if currentLabel == "ON":
			elife.sendCommand( "KITCHEN_AV","KITCHEN_AV","on","")
			elife.sendCommand("DLT_1","DLT_1","label","OFF")
	
		elif currentLabel == "OFF":
			elife.sendCommand( "KITCHEN_AV","KITCHEN_AV","off","")
			elife.sendCommand("DLT_1","DLT_1","label","ON")
	
  
    # Second button, select source
    
	if triggeringEvent.getDisplayName () == "DLT_2":
		if currentLabel == None:
			# Unknown label
			elife.sendCommand("DLT_2","DLT_2","label","CD1")
			
			
		elif currentLabel == "CD1":
			elife.sendCommand( "KITCHEN_AV","KITCHEN_AV","src","cd1")
			elife.sendCommand("DLT_2","DLT_2","label","CD2")

		elif currentLabel == "CD2":
			elife.sendCommand( "KITCHEN_AV","KITCHEN_AV","src","cd2")
			elife.sendCommand("DLT_2","DLT_2","label","DVD")
			
		elif currentLabel == "DVD":
			elife.sendCommand( "KITCHEN_AV","KITCHEN_AV","src","dvd")
			elife.sendCommand("DLT_2","DLT_2","label","TV")
			
		elif currentLabel == "TV":
			elife.sendCommand( "KITCHEN_AV","KITCHEN_AV","src","tv")
			elife.sendCommand("DLT_2","DLT_2","label","CD1")


    # Third button, volume
    
	if triggeringEvent.getDisplayName () == "DLT_3":
		elife.sendCommand( "KITCHEN_AV","KITCHEN_AV","volume",triggerEvent.getExtraInfo())

