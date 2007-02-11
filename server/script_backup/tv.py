import sys
import time
a = elife.getCommand("MASTERBED_LIGHT")
elife.log ("Value of a is")
elife.log(a)
elife.log("....")
if a == "on":
	elife.on("AV.LGTV","LGTV.poweron")
elif a == "off":
	elife.on("AV.LGTV","LGTV.poweroff")