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
	String[]  fireOnChange =   ["BLIND_BATHROOM_BLOCK",			"BLIND_BATHROOM_SHADE",
								"BLIND_BEDROOM_2_BLOCK",		"BLIND_BEDROOM_2_SHADE",
								"BLIND_BEDROOM_3_BLOCK",		"BLIND_BEDROOM_3_SHADE",
								"BLIND_DINING_BLOCK",			"BLIND_DINING_SHADE",
								"BLIND_GUEST_EXTERNAL",
								"BLIND_GUEST_DOOR_BLOCK",		"BLIND_GUEST_DOOR_SHADE",
								"BLIND_GUEST_LHS_BLOCK",		"BLIND_GUEST_LHS_SHADE",
								"BLIND_GUEST_RHS_BLOCK",		"BLIND_GUEST_RHS_SHADE",
								"BLIND_KITCHEN_BLOCK",			"BLIND_KITCHEN_SHADE",
								"BLIND_LIVING_LHS_SHADE",		"BLIND_LIVING_LHS_SHADE",
								"BLIND_LIVING_RHS_BLOCK",		"BLIND_LIVING_RHS_SHADE",
								"BLIND_LIVING_SIDE_LHS_BLOCK",	"BLIND_LIVING_SIDE_LHS_SHADE",
								"BLIND_LIVING_SIDE_RHS_BLOCK",	"BLIND_LIVING_SIDE_RHS_SHADE",
								"BLIND_STAIRS_BOTTOM",			"BLIND_STAIRS_TOP",
								"BLIND_MBED_CENTRE_BLOCK",		"BLIND_MBED_CENTRE_SHADE",
								"BLIND_MBED_LEFT_BLOCK",		"BLIND_MBED_LEFT_SHADE",
								"BLIND_MBED_RIGHT_BLOCK",		"BLIND_MBED_RIGHT_SHADE",
								"BLIND_MBED_ROBE",
								"BLIND_ENSUITE_BLOCK",			"BLIND_ENSUITE_SHADE",
								"BLIND_LIVING_TERRACE_FRONT",	"BLIND_LIVING_TERRACE_SIDE",
								"BLIND_ENTRY",
								"BLIND_RUMPUS_LEFT",			"BLIND_RUMPUS_RIGHT",
								"BLIND_RUMPUS_SIDE",
								"BLIND_RUMPUS_TERRACE_LEFT",	"BLIND_RUMPUS_TERRACE_RIGHT",
								"BLIND_STUDY"
								]

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
}

