import au.com.BI.Script.*
import au.com.BI.Command.*

public class BlindUp extends BIScript  {

   // true if the script can be run multiple times in parallel
	boolean ableToRunMultiple = false
	
	// This script will be run by the regular 5 minute event.
	String[]  fireOnChange =   ["BLINDS"]
	
	// If the script is able to be stopped before completion, generally not
	boolean  stoppable = false;


	def main (String[] argv) {
		// The action contents of the script go here
		
		
		if (triggerCommand == "down") { 
		
			elife.off "BLIND_DN"
			
			elife.setVariable "BlindDn",False
			elife.setVariable "BlindUp",True
			
			Thread.sleep 1000 
			
			elife.on "BLIND_UP"
			
			blindUpCyc = 60
			
			while (blindUpCyc > 0 && elife.getVariable ("BlindUp" ) == True) {
				Thread.sleep(1000)
				blindUpCyc --
			}
			elife.setVariable "BlindUp",False
			elife.off "BLIND_UP"
		}
	}
}
	