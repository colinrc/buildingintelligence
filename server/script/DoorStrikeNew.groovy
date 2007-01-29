import au.com.BI.Script.*
import au.com.BI.Command.*

 public class DoorStrikeNew  implements BIScript  {


   // true if the script can be run multiple times in parallel
    def ableToRunMultiple = false
    
    // List the variables that will cause the script to run when they change
    def fireOnChange =   ["GARAGE_LIGHT"]
    
    // If the script is able to be stopped before completion, generally no
    def  stoppable = false;
 
    
	def elife  = "${elife}"
	def   triggeringEvent = "${triggeringEvent}"
	def  cache = "${cache}"
	def labelMgr = "{labelMgr}"
	
	boolean isAbleToRunMultiple () {
		return false;
	}
	
	boolean isStoppable () {
		return false;
	}
	
	String [] getFireOnChange() {
	 	return [ "GARAGE_LIGHT"]
	}
	
	
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

