import au.com.BI.Script.*
import au.com.BI.Command.*

 public class DoorStrikeNew  extends BIScript  {


   // true if the script can be run multiple times in parallel
    boolean ableToRunMultiple = false
    
    // List the variables that will cause the script to run when they change
    String[]  fireOnChange =   ["GARAGE_LIGHT"]
    
    // If the script is able to be stopped before completion, generally no
    boolean  stoppable = false;
 
    
   // Include these lines as they are in every script
	def elife  = "${elife}"
	def   triggeringEvent = "${triggeringEvent}"
	def  cache = "${cache}"
	def labelMgr = "{labelMgr}"
	

	
	
	def main (String[] argv) {
	// The action contents of the script go here

	
		// Find out the last command sent to dining light, and flip it.
					
		def currentValue = elife.getCommand("DINING_LIGHT")
	
		switch (currentValue){
			case "on":
				elife.off "DINING_LIGHT"
				elife.log ("Turning dining light off")
				break
						
			case  "off" :  case "None" :   // None is a special value, indicating no previous commands have been received for the light.
				elife.on "DINING_LIGHT"
				elife.log ("Turning dining light on")
				break
		}
	
	}
 
}

