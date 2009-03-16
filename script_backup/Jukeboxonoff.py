import sys
import time
elife.fireScriptOn("JUKEBOX")
a = elife.getCommand("JUKEBOXIN")
if a=="on"
	elife.sendCommand("2", "BAR_AUDIO", "src", "TUNER")
elif a == "off":
        elife.sendCommand("BAR_AUDIO","src","TUNER")