import au.com.BI.Script.*
import au.com.BI.Command.*

 public class dlt_merik  extends BIScript  {
 
   // true if the script can be run multiple times in parallel
    boolean ableToRunMultiple = false
    
    // List the variables that will cause the script to run when they change
    String[]  fireOnChange =   ["DLT_1", "DLT_2","DLT_3","DLT_4"]
    
    // If the script is able to be stopped before completion, generally no
    boolean  stoppable = false;
 
    
	
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
			if (currentLabel == "LIGHTON") {
				elife.sendCommand ("LOUNGE_LIGHT","on","100")
				elife.sendCommand("DLT_1","label","LIGHTOFF")
			}
			if (currentLabel == "LIGHTOFF") {
				elife.sendCommand ("LOUNGE_LIGHT","off","0")
				elife.sendCommand("DLT_1","label","LIGHTON")
			}
			break
			
		case "DLT_2":
			switch (currentLabel){
			case "": 
				// The currently displayed text on the DLT is not known to eLife, so set it to something we can handle
				elife.sendCommand("DLT_2","label","TALK1")
				break
				
			case "TALK1":
				// The label on DLT 2 is currently TALK1
				elife.sendCommand( "M1","SPEAK_WORD","95")
				elife.sendCommand("DLT_2","label","TALK2")
				break
				
			case "TALK2":
				elife.sendCommand("M1","SPEAK_WORD","160")
				elife.sendCommand("DLT_2","label","TALK3")
				break
				
			case "TALK3":
				elife.sendCommand( "M1","SPEAK_WORD","190")
				elife.sendCommand("DLT_2","label","TALK1")
				break			}
			break
			
		case "DLT_3" :
			// third button send volume
			elife.sendCommand( "KITCHEN_AV","volume",triggeringEvent.getExtraInfo())
			break

			
		}
				   
	}
}
