import au.com.BI.Script.*
import au.com.BI.Command.*


public class TimeTest  extends BIScript  {
	
   // true if the script can be run multiple times in parallel
boolean ableToRunMultiple = false

// List the variables that will cause the script to run when they change
String[]  fireOnChange =   ["DLT_1", "DLT_2","DLT_3","DLT_4"]

// If the script is able to be stopped before completion, generally not
boolean  stoppable = false;


	def main (String[] argv) {
	// The action contents of the script go here
		
		if (triggeringEvent  == null || triggerWasScript ) {
			return
			// Just in case the script was run from the Flash control plan, rather than picking up a message change.
		}
			
		// to read something from the label manager in groovy
		def currentLabel = labelMgr.getLabelState (triggerDisplayName)
		elife.log ("Label " + currentLabel)
		
		switch (triggerDisplayName) {
		case "DLT_1": 
			if (currentLabel == "ON") {
				elife.sendCommand ("KITCHENAV","on","100")
				 elife.sendCommand("DLT_1","label","OFF")
			}
			if (currentLabel == "OFF") {
				elife.sendCommand ("KITCHENAV","off","0")
				 elife.sendCommand("DLT_1","label","ON")
				 elife.sendCommand ("KITCHENAV","off","0")
				 elife.sendCommand("DLT_1","label","ON")
			}
		break
			
		}
	}
}

