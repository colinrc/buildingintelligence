import au.com.BI.Script.*
import au.com.BI.Command.*

public class M1_CBUS_Example extends BIScript  {

	// true if the script can be run multiple times in parallel
	boolean ableToRunMultiple = false

	// List the variables that will cause the script to run when they change
	String[]  fireOnChange =   ["CBUS_TRIGGER_DISPLAY_NAME"]

	// If the script is able to be stopped before completion, generally no
	boolean  stoppable = false;
	
	// If hidden is set to true then the script will not be visible to the client
	boolean hidden = true

	def main (String[] argv){

		// The action contents of the script go here

		if (triggeringEvent  == null || triggerWasScript ) {
			return
			// Just in case the script was run from the Flash control plan, rather than picking up a message change.
		}
		
		if (getValue ("DISPLAY_NAME_OF_M1_OUTPUT") == "on") {
		    elife.sendCommand ("REAL_CBUS_DISPLAY_NAME","on")
		    elife.sendCommand ("MACRO","abort","EXTRA STUFF TO RUN WHEN M1 OUTPUT ON")
			elife.sendCommand ("MACRO","run","EXTRA STUFF TO RUN WHEN M1 OUTPUT ON")
		}
		else if (getvalue ("DISPLAY_NAME_OF_M1_OUTPUT") == "off") {
			elife.sendCommand ("MACRO","abort","EXTRA STUFF TO RUN WHEN M1 OUTPUT OFF")
			elife.sendCommand ("MACRO","run","EXTRA STUFF TO RUN WHEN M1 OUTPUT OFF")
		} 
	}
}

