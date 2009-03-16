import au.com.BI.Script.*
import au.com.BI.Command.*

public class BlindDown extends BIScript  {

   // true if the script can be run multiple times in parallel
	boolean ableToRunMultiple = false
	
	String[]  fireOnChange =   ["BLINDS:down"]
	
	// If the script is able to be stopped before completion, generally not
	boolean  stoppable = false;


	def main (String[] argv) {
		// The action contents of the script go here
		
		elife.off "BLIND_UP"
		
		elife.setVariable "BlindUp",false
		elife.setVariable "BlindDn",true
		
		Thread.sleep 1000
		elife.on "BLIND_DN"
		
		blindDnCyc = 60
		
		while (blindDnCyc > 0 &&  elife.getBooleanVariable("BlindDn") == true) {
		
			Thread.sleep 1000 
			blindDnCyc --
		}
		elife.setVariable "BlindDn",false		
		elife.off "BLIND_DN" 
	}
}