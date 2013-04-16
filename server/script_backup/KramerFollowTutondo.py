import sys
import time

tmp = elife.fireScriptOn("KITCHEN_AV")
if triggeringEvent != None:

	if triggeringEvent.getCommandCode () == "src":
		if triggeringEvent.getExtraInfo () == "cd1":
			elife.sendCommand( "DINING_LIGHT","DINING_LIGHT","on","100")
	
		elif triggeringEvent.getExtraInfo () == "cd2":
			elife.sendCommand( "DINING_LIGHT","DINING_LIGHT","off","")
	
