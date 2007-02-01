import sys
import time

elife.fireScriptOn("DINING_LIGHT")
elife.fireScriptOn("GARAGE_LIGHT")

if triggeringEvent != None:

	if triggeringEvent.getDisplayName () == "GARAGE_LIGHT":
		if triggeringEvent.getCommandCode () == "on":
			elife.sendCommand( "DINING_LIGHT","on","")
			elife.log ("Turning Filter Pump On ")	

	elif triggeringEvent.getDisplayName () == "DINING_LIGHT":
		if triggeringEvent.getCommandCode () == "off":
			elife.sendCommand( "GARAGE_LIGHT","off","")
			elife.log ("Turning Cleaner Pump Off ")