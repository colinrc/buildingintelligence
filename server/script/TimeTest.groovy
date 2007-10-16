import au.com.BI.Script.*
import au.com.BI.Command.*
import au.com.BI.Util.*
import java.util.logging.Level
import groovy.time.*
import java.util.*


public class TimeTest  extends BIScript  {
	
   // true if the script can be run multiple times in parallel
boolean ableToRunMultiple = false

// List the variables that will cause the script to run when they change
String[]  fireOnChange =   ["TIME_TEST","TIMETEST_TIMER"]

// If the script is able to be stopped before completion, generally not
boolean  stoppable = false;


	def main (String[] argv) {
	// The action contents of the script go here
	
	if (triggerWasScript ) {
		return
		// Just in case the script was run from the Flash control plan, rather than picking up a message change.
	}
	
	switch (triggerDisplayName) {
	case "TIMETEST_TIMER":
		switch (triggerCommand) {
		case "on":
		break

		case "off":
			elife.sendCommand ("HALL_LIGHTS","off")
		break
		}
		
	case "TIME_TEST":
		cal = Calendar.getInstance()
		hour = cal.get(Calendar.HOUR_OF_DAY)
		elife.log ("TIME IS " + hour)
		switch (hour) {
		case 0: case 1: case 2: case 3: case 4: case 5: case 6:
		case 7: case 21: case 22: case 23: case 24:
			elife.log ("NIGHT TIME")
			elife.sendCommand ("HALL_LIGHTS","on","30")
			elife.sendCommand ("MACRO","abort","TimeTestTimer")
			elife.sendCommand ("MACRO","run","TimeTestTimer")
			break
		case 18: case 19: case 20:
			elife.log ("EVENING TIME")
			elife.sendCommand ("HALL_LIGHTS","on","100")
			elife.sendCommand ("MACRO","abort","TimeTestTimer")
			elife.sendCommand ("MACRO","run","TimeTestTimer")
			break
		default :
			elife.log ("DAY TIME")
		}
	break
	}	
}

}