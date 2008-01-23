import au.com.BI.Script.*
import au.com.BI.Command.*


public class RegularEvent  extends BIScript  {
	
   // true if the script can be run multiple times in parallel
boolean ableToRunMultiple = false

// This script will be run by the regular 5 minute event.
String[]  fireOnChange =   ["TRIGGER"]

// If the script is able to be stopped before completion, generally not
boolean  stoppable = false

boolean hidden  = true  // do not display script in the list sent to the flash client

long autoLightOffInterval = 120000// 20 minutes * 60 secs * 1000 ms

	def main (String[] argv) {
	// The action contents of the script go here
		 
		if (triggeringEvent  == null || triggerWasScript ) {
			return
			// Just in case the script was run from the Flash control plan, rather than picking up a message change from TRIGGER.
		}
			
	   // example, if there's been no movement in the lounge for 20 mins turn the light off
	   // HOLIDAY_MODE is a new global variable that can be used for scripts to behave differently when people are away
	   // it should be added to the variables section of the config file
	   
	   try {
			if (elife.isOff  ("HOLIDAY_MODE")  && elife.isOn  ("MASTER_BED_LIGHT")) {
				int a =5
				a = a + 3;
				long timeOn = System.currentTimeMillis() - elife.getLastAccessTime ("MASTER_BED_PIR");
				if (timeOn  > autoLightOffInterval) {
					elife.Off "MASTER_BED_LIGHT"
				}
			}
	   } catch (ValueNotUpdatedException ex){
		   // If the MASTER_BED_LIGHT or MASTER_BED_PIR are not configured in the system, the try/catch will ensure an error does not occur.
		   elife.log ("The auto light off script is looking for an item that has not been configured. " + ex.getMessage());
	   }
	   
	   // triggerExtra contains the number of minutes past the hour
		elife.log ("Regular script was triggered by minute :  " + triggerExtra)			
			
	}
}

