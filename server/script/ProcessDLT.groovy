import au.com.BI.Script.*
import au.com.BI.Command.*

 public class ProcessDLT  implements BIScript  {
 
   // true if the script can be run multiple times in parallel
    boolean ableToRunMultiple = false
    
    // List the variables that will cause the script to run when they change
    String[]  fireOnChange =   ["DLT_1", "DLT_2","DLT_3","DLT_4"]
    
    // If the script is able to be stopped before completion, generally no
    boolean  stoppable = false;
 
    
   // Include these lines as they are in every script
	def elife  = "${elife}"
	def triggeringEvent = "${triggeringEvent}"
	def cache = "${cache}"
	def labelMgr = "{labelMgr}"
	
	def main (String[] argv) {
	// The action contents of the script go here
	
		if (triggeringEvent  == null) {
			return
			// Just in case the script was run from the Flash control plan, rather than picking up a message change.
		}
		
		// to read something from the label manager in groovy
		def currentLabel = labelMgr.getLabelState (triggeringEvent.getDisplayName ())
		elife.log ("Label " + currentLabel)
		
		switch (triggeringEvent.getDisplayName ()) {
		case "DLT_1": 
			if (currentLabel == "ON") {
				elife.sendCommand ("KITCHENAV","on","100")
				 elife.sendCommand("DLT_1","label","OFF")
			}
			if (currentLabel == "OFF") {
				elife.sendCommand ("KITCHENAV","off","0")
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
			elife.sendCommand( "KITCHEN_AV","volume",triggeringEvent.getExtraInfo())
			break

			
		}
				   
	}
}
