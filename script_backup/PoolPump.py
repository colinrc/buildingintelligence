import sys
import time

elife.fireScriptOn("POOL_FILTER_PUMP")
elife.fireScriptOn("POOL_CLEANER_PUMP")

if triggeringEvent != None:

if triggeringEvent.getDisplayName () == "POOL_CLEANER_PUMP":
	if triggeringEvent.getCommandCode () == "on":
		elife.sendCommand( "POOL_FILTER_PUMP","on","")
		elife.log ("Turning Filter Pump On ")	

elif triggeringEvent.getDisplayName () == "POOL_FILTER_PUMP":
	if triggeringEvent.getCommandCode () == "off":
		elife.sendCommand( "POOL_CLEANER_PUMP","off","")
		elife.log ("Turning Cleaner Pump Off ")