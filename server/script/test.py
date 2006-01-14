import sys
import time

z=0
elife.setVariable("zxc",z)
z = elife.getLongVariable("zxc")
elife.log("z="+str(z))
elife.incrementVariable("zxc")
z = elife.getLongVariable("zxc")
elife.log(str(z))
time.sleep(4)
elife.decrementVariable("zxc")
z = elife.getLongVariable("zxc")
elife.log(str(z))
