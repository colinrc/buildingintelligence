import au.com.BI.Script.*
import au.com.BI.Command.*

 public class GroovyDiningLight  extends BIScript  {


   // true if the script can be run multiple times in parallel
    boolean ableToRunMultiple = false
    
      // true if the script should be queued if a second attempt is made to run it while it is already running
    boolean  queueMultipleRuns = false
    
    // List the variables that will cause the script to run when they change
    String[]  fireOnChange =  ["KITCHEN_LIGHT" ]
    
    // If the script is able to be stopped before completion, generally no
    boolean   stoppable = false
 
    // hidden sets that the script will by default not be visible in the list sent to the flash client. This can be overwritten in the script_status file
    boolean hidden = false
    


	
	def main (String[] argv) {
	// The action contents of the script go here
	
			elife.on "DINING_LIGHT","100"
			elife.sendCommand "","AV.GC100_IR1","NEC.on","2"
	}
 
}

