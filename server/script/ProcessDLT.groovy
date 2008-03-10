import au.com.BI.Script.*
import au.com.BI.Command.*


public class ProcessDLT  extends BIScript  {
	
   // true if the script can be run multiple times in parallel
boolean ableToRunMultiple = false

// List the variables that will cause the script to run when they change
String[]  fireOnChange =   ["DLT_1", "DLT_2","DLT_3","DLT_4"]

// If the script is able to be stopped before completion, generally not
boolean  stoppable = false;

   
boolean hidden = true

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
				if (triggerCommand == "on"){
					// label is on, and DLT is still on so send volume
					elife.sendCommand( "MASTER_BED_LIGHT","on",triggerExtra)
				} else {
					// trigger command is off
					elife.sendCommand ("MASTER_BED_LIGHT","on","100")
				 	elife.sendCommand("DLT_1","label","OFF")					
				}
			}
			if (currentLabel == "OFF") {
				elife.sendCommand ("MASTER_BED_LIGHT","off","0")
				 elife.sendCommand("DLT_1","label","ON")
			}
			break
			
		case "DLT_2":
			switch (currentLabel){
			case "": 
				// The currently displayed text on the DLT is not known to eLife, so set it to something we can handle
				elife.sendCommand("DLT_2","label","CD1")
				break
				
			case "CD1":
				// The label on DLT 2 is currently CD1
				elife.sendCommand( "KITCHEN_AV","KITCHEN_AV","src","cd1")
				elife.sendCommand("DLT_2","label","CD2")
				break
				
			case "CD2":
				elife.sendCommand("KITCHEN_AV","src","cd2")
				elife.sendCommand("DLT_2","label","DVD")
				break
			
			case "DVD":
				elife.sendCommand( "KITCHEN_AV","KITCHEN_AV","src","dvd")
				elife.sendCommand("DLT_2","label","TV")
				break
		
			case "TV":
				elife.sendCommand( "KITCHEN_AV","KITCHEN_AV","src","tv")
				elife.sendCommand("DLT_2","label","CD1")
				break
		
			}
			break
			
		case "DLT_3" :
			// third button send volume
			elife.sendCommand( "KITCHEN_AV","volume",triggerExtra)
			break
		
			
		}
	}

	def registerScript () {
		def a = 4
		a = a + 1
	}
}

