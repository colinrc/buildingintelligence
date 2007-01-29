import au.com.BI.Script.*
import au.com.BI.Command.*

 public class DoorStrikeNew  implements BIScript  {


   // true if the script can be run multiple times in parallel
    boolean ableToRunMultiple = false
    
    // List the variables that will cause the script to run when they change
    String[]  fireOnChange =   ["GARAGE_LIGHT"]
    
    // If the script is able to be stopped before completion, generally no
    boolean  stoppable = false;
 
    
	def elife  = "${elife}"
	def   triggeringEvent = "${triggeringEvent}"
	def  cache = "${cache}"
	def labelMgr = "{labelMgr}"
	

	
	
	def main (String[] argv) {
	// The action contents of the script go here
	
		def currentValue = elife.getCommand("DINING_LIGHT")


		
		if (currentValue == "None" )  {
			// The light is not yet in the cache so switch it on 
			elife.on "DINING_LIGHT"
			
		} else {
			// it is there so find out what the last command structure sent to it is, and flip it
			

			if  (currentValue== "on") {
				elife.off "DINING_LIGHT"
			} else{
				elife.on "DINING_LIGHT"
			}
		}

	}
 
}

