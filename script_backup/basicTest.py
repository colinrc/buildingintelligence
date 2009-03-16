import sys
import time
print "start Hi there from basic test"

#a = int(DO.getValue("LOUNGE_LIGHT"))
#print a
#if a > 50:
#    DO.runMacro("test")
#else:
#    print "not yet"
#
#print DO.getCommand("LOUNGE_LIGHT")
b = elife.isScriptStillRunning()

#print DO.getValue("LOUNGE_PIR","on")
#print DO.getCommand("LOUNGE_PIR","on")

#do.on("LOWER_STAIR_LIGHT")
#do.on("LOUNGE_LIGHT")
#if do.getValue("LOUNGE_LIGHT") == "100": 
#   do.off("LOUNGE_LIGHT")

#do.dumpCommands()
#print DO.getValue("LOUNGE_AUDIO")
a = do.getValue("LOUNGE_LIGHT")
b= do.getValue("GARAGE_LIGHT")
print a + " from basictest lounge"
print b + " from basictest garage"
print "wait for 10.........."
#time.sleep(10)

print "finished waiting"

#do.off("LOUNGE_LIGHT")
#do.off("GARAGE_LIGHT")
time.sleep(1)
print "finished script now....."

#do.sendMessage("In script 1","warning","The big test","Y","Y")

#do.video("video","play","1") 