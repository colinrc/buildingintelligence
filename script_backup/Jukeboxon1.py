import sys
import time
elife.fireScriptOn("JUKEBOX")
a = elife.getCommand("JUKEBOXIN")
if a == "on":
	elife.sendCommand( "BAR_AUDIO","src","JUKEBOX")
elif a == "off":
        elife.sendCommand("BAR_AUDIO","src","TUNER")
