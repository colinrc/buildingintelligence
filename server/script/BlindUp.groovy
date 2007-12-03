import au.com.BI.Script.*
import au.com.BI.Command.*

public class BlindUp extends BIScript  {

   // true if the script can be run multiple times in parallel
	boolean ableToRunMultiple = false
	
	String[]  fireOnChange =   ["BLINDS:up"]
	
	// If the script is able to be stopped before completion, generally not
	boolean  stoppable = false;


	def main (String[] argv) {
		// The action contents of the script go here
		
		elife.off "BLIND_DN"
		
		elife.setVariable "BlindDn",false
		elife.setVariable "BlindUp",true
		
		Thread.sleep 1000 
		
		elife.on "BLIND_UP"
		
		blindUpCyc = 60
		
		while (blindUpCyc > 0 && elife.getBooleanVariable ("BlindUp" ) == true) {
			Thread.sleep(1000)
			blindUpCyc --
		}
		elife.setVariable "BlindUp",false
		elife.off "BLIND_UP"

	}
}
	