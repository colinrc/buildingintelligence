import au.com.BI.Script.*
import au.com.BI.Command.*

public class blinds extends BIScript  {

	  /*
    For each blind you wish to control with a CBUS shutter relay:
    
    TODO:  CBUS STUFF HERE
    
    In the server configuration file you must have an entry in the variables section for each blind
    
    <CONTROLS>
      <VARIABLES>
        <VARIABLE ACTIVE="Y" NAME="Lounge Blind Dummy" DISPLAY_NAME="LOUNGE_BLIND"/>
        <VARIABLE ACTIVE="Y" NAME="Dining Blind Dummy" DISPLAY_NAME="DINING_BLIND"/>
      </VARIABLES>
      ...
      ...
    
    In the CBUS Section you will have the real shutter relay group addresses
    
    <CBUS>
      <LIGHT_CBUS KEY="01" ACTIVE="Y" RELAY="Y" NAME="Lounge Blind" DISPLAY_NAME="LOUNGE_BLIND_CBUS" />
      <LIGHT_CBUS KEY="02" ACTIVE="Y" RELAY="Y" NAME="Dining Blind" DISPLAY_NAME="DINING_BLIND_CBUS" />
    ...
    ...
    
    In the client configuration you will have three buttons defined
    
    <controlTypes>
    	<control type="blind">
			<row>
				<item type="label" />
			</row>
			<row>
				<item type="button" label="up" command="up" width="30" />
				<item type="button" label="stop" command="stop" width="40" />
				<item type="button" label="down" command="down" width="30" />
			</row>
		</control>
	...
	...
	
	You would use this control by using the non CBUS DISPLAY_NAME
	
	<control name="Lounge Blinds" key="LOUNGE_BLIND" type="blind" />
	...
	...
 */  
	
	
	
	
	// true if the script can be run multiple times in parallel
	boolean ableToRunMultiple = true

	// List the variables that will cause the script to run when they change
	String[]  fireOnChange =   ["FAMILY_BLIND","DINING_BLIND"]

	// If the script is able to be stopped before completion, generally no
	boolean  stoppable = false;

	def main (String[] argv){

		// The action contents of the script go here

		if (triggeringEvent  == null) {
			return
			// Just in case the script was run from the Flash control plan, rather than picking up a message change.
		}

		def cbusDisplayName = triggerDisplayName + "_CBUS"
		
		switch (triggerCommand) {

			case "down": 
				elife.sendCommand (cbusDisplayName,"off","0")
				break
				
			case "stop":
				elife.sendCommand (cbusDisplayName,"on","2")
				break
				
			case "up":
				elife.sendCommand (cbusDisplayName,"on","100")
				break
		}
			
}

