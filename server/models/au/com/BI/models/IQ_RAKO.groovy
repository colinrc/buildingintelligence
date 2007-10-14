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


class IQRAKO extends GroovyModel {

	String name = "IQRAKO"
	String appendToSentStrings = "\r"
	
	IQRAKO () {
		super()

	}
	
	void aboutToReadModelDetails() {
		addStringAttribute (DeviceType.LIGHT, "ROOM" , true)
		// The Room is needed as well as the channel (key) in order to build a unique identifier for the light. The element is mandatory.
				
		// addStringAttribute (DeviceType.TOGGLE_INPUT, "MASTER", false )
		// A button can be a controller for the next four rooms as well as itself, this is an optional attribute.
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
				// decodeScene (returnWrapper,command.getExtraInfo())
			}
			
		} catch (UnknownFieldException ex){
			logger.log (Level.WARNING,ex.getMessage());
		}
	}
}

