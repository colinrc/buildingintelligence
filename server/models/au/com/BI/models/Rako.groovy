package au.com.BI.models;

import au.com.BI.Util.*
import au.com.BI.Command.*
import au.com.BI.GroovyModels.*
import java.util.logging.Level
import au.com.BI.Config.ParameterException
import au.com.BI.Device.UnknownFieldException
import au.com.BI.Device.DeviceType
import au.com.BI.ToggleSwitch.ToggleSwitch
import au.com.BI.Lights.LightFascade
import java.util.regex.Matcher
import java.util.regex.Pattern


/**
   This demonstration shows the basic pattern for groovy models.
   
   The model contains various functions that are called by the system during operations.
   
   On startup the system will call doStartup()  ,this should contain any required commands to put the device in a state for communications with eLife.
   
   When instructions are received from the device  the model's processStringFromComms method is called. This is where you will process instructions 
   and usually send the appropriate message to the flash client.
   
   When instructions are received from the flash client the models doOutputItem method is called.
   

**/

class RAKO extends GroovyModel {

	// Our light device expects 2 characters to specify the zone 
	int keyPadding = 2;
	String name = "RAKO"
	String appendToSentStrings = "\r"
	String version = "1.0"
	
	RAKO () {
		super()
		
		setQueueCommands(false) 
		// Set the default behaviour for comms commands to be queued before sending. Can be overridden for a returnWrapper object
		setDeviceKeysDecimal  (true) // the Rako expects keys passed to it to be in decimal
		configHelper.addParameterBlock  "SCENES",DeviceModel.MAIN_DEVICE_GROUP,"Scene Levels"
	}

	void aboutToReadModelDetails() {
		// Adding attributes allows a model to dynamically add more parameters on a line in the configuration file
		
		addStringAttribute (DeviceType.LIGHT, "ROOM" , true)
		// The Room is needed as well as the channel (key) in order to build a unique identifier for the light. The element is mandatory.
				
		addStringAttribute (DeviceType.TOGGLE_INPUT, "MASTER", false )
		// A button can be a controller for the next four rooms as well as itself, this is an optional attribute.
	}
	
	void processStringFromComms (String command , ReturnWrapper returnWrapper) {
		if (command == "OK") return
		
		// command pattern   RRR:CC:IN 
		if (command.startsWith ("<")){
			def String[] parts = command.split (":")
			if (parts.length == 3){
				def room = parts[0]
				def channel = parts[1]
				def instruction = parts[2]
			}
		} else {
			logger.log (Level.WARNING,"The instruction from the Rako was not correctly formatted " + command)
		}
	
	}

	void buildLightControlString (LightFascade device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {
		// receives a message from flash and builds the appropriate string for the audio device
		
		try {
			// To switch on the audio device it requieres a string of this format      AU_PWR:zone:on or AW_PWR:zone:off
			if (command.getCommandCode() ==  "on") {
				def room = device.getAttributeValue ("ROOM")
				returnWrapper.addCommOutput  ("ROOM " + room)	
				returnWrapper.addCommOutput  ("CHANNEL " + device.getKey())
				def levelForRako = Utility.scaleFromFlash (command.getExtraInfo(), 0,255,false) // false indicates the value does not need to be inverted, ie. 0 is the min level for the Rako
				returnWrapper.addCommOutput  ("LEVEL " + levelForRako)
			}
			
			if (command.getCommandCode() == "off") {
				def room = device.getAttributeValue ("ROOM")
				returnWrapper.addCommOutput  ("ROOM " + room)	
				returnWrapper.addCommOutput  ("CHANNEL " + device.getKey())
				returnWrapper.addCommOutput  ("OFF")
			}
			
			if (command.getCommandCode() == "scene") {
				def room = device.getAttributeValue ("ROOM")
				returnWrapper.addCommOutput  ("ROOM " + room)	
				returnWrapper.addCommOutput  ("CHANNEL " + device.getKey())
				returnWrapper.addCommOutput  ("SCENE " + command.getExtraInfo())
				decodeScene (returnWrapper,command.getExtraInfo())
			}
			
		} catch (UnknownFieldException ex){
			logger.log (Level.WARNING,ex.getMessage());
		}
	}

	

	void decodeScene (ReturnWrapper returnWrapper , String sceneNumber){
		
	}
	
}