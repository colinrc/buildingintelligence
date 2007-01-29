import au.com.BI.Script.*
import au.com.BI.Command.*

 public class DoorStrikeNew  implements BIScript  {


   // true if the script can be run multiple times in parallel
    def ableToRunMultiple = false
    
      // true if the script can be run multiple times in parallel
    def queueMultipleRuns = false
    
    // List the variables that will cause the script to run when they change
    def fireOnChange =  ["KITCHEN_LIGHT" , "GARAGE_LIGHT"]
    
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
	 	return ["KITCHEN_LIGHT" , "GARAGE_LIGHT"]
	}
	
	
	def main (String[] argv) {
	// The action contents of the script go here
	
			elife.on "DINING_LIGHT","100"
	}
 
}

