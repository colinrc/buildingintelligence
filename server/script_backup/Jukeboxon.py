import sys
import time
elife.fireScriptOn("JUKEBOXIN")
a = elife.getCommand("JUKEBOXIN")
elife.log("Start of script")
if a == "on":
	elife.sendCommand("BAR_AUDIO","BAR_AUDIO","src","JUKEBOX")
elif a == "off":
	elife.sendCommand("BAR_AUDIO","BAR_AUDIO","src","TUNER")
