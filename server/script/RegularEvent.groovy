import au.com.BI.Script.*
import au.com.BI.Command.*


public class RegularEvent  extends BIScript  {
	
   // true if the script can be run multiple times in parallel
boolean ableToRunMultiple = false

// This script will be run by the regular 5 minute event.
String[]  fireOnChange =   ["TRIGGER"]

// If the script is able to be stopped before completion, generally not
boolean  stoppable = false;


	def main (String[] argv) {
	// The action contents of the script go here
		
		if (triggeringEvent  == null || triggerWasScript ) {
			return
			// Just in case the script was run from the Flash control plan, rather than picking up a message change.
		}
			
		elife.log ("Regular script was triggered by minutes :  " + triggerExtra)			
			
	}
}

