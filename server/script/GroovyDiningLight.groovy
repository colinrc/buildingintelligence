import au.com.BI.Script.*
import au.com.BI.Command.*

 public class DoorStrikeNew  implements BIScript  {


   // true if the script can be run multiple times in parallel
    boolean ableToRunMultiple = false
    
      // true if the script can be run multiple times in parallel
    boolean  queueMultipleRuns = false
    
    // List the variables that will cause the script to run when they change
    String[]  fireOnChange =  ["KITCHEN_LIGHT" , "GARAGE_LIGHT"]
    
    // If the script is able to be stopped before completion, generally no
    boolean   stoppable = false;
 
    
	def elife  = "${elife}"
	def   triggeringEvent = "${triggeringEvent}"
	def  cache = "${cache}"
	def labelMgr = "{labelMgr}"
	

	
	def main (String[] argv) {
	// The action contents of the script go here
	
			elife.on "DINING_LIGHT","100"
			elife.sendCommand "AV.GC100_IR1","NEC.On","2"
	}
 
}

