import sys
import time
elife.fireScriptOn("SWITCH_TWO")
a = elife.getCommand("SWITCH_TWO")
if a == "on":
	elife.sendCommand("LOUNGE_AUDIO","LOUNGE_AUDIO", "src","cd1")
elif a == "off":
	elife.sendCommand("LOUNGE_AUDIO","LOUNGE_AUDIO", "src","digital")
 