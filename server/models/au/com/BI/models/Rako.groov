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
	String appendToSentStrings = "\n"

	
	RAKO () {
		super()
		
		setQueueCommands(false) 
		// Set the default behaviour for comms commands to be queued before sending. Can be overridden for a returnWrapper object

		configHelper.addParameterBlock  "SCENES",DeviceModel.MAIN_DEVICE_GROUP,"Scene Levels"
	}

	void aboutToReadModelDetails() {
		addStringAttribute (DeviceType.LIGHT, "ROOM" )
		// The channel is considered the key hence does not need an extra field
	}
	
	void processStringFromComms (String command , ReturnWrapper returnWrapper) {
		
	
	}

	void buildLightControlString (LightFascade device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {
		// receives a message from flash and builds the appropriate string for the audio device
		
		try {
			// To switch on the audio device it requieres a string of this format      AU_PWR:zone:on or AW_PWR:zone:off
			if (command.getCommandCode() ==  "on") {
				def room = device.getAttributeValue ("ROOM")
					
				returnWrapper.addCommOutput  ("AU_PWR:" + device.getKey() + ":1")
			}
			
			if (command.getCommandCode() == "off") {
				returnWrapper.addCommOutput ("AU_PWR:" + device.getKey() + ":0")
			}
	
			// To change the volume the format will be AU_VOL:zone:- or AU_VOL:zone:+ 
			if (command.getCommandCode() == "volume") {
				
				if (command.getExtraInfo() == "up" )  {
					returnWrapper.addCommOutput  ("AU_VOL:" + device.getKey() + ":+"	)					
	
				} else { 
					returnWrapper.addCommOutput  ("AU_VOL:" + device.getKey() + ":-")
				}
			}
			
			
			// To change the input source the format will be AU_SRC:zone:src_val
			// The names of each input channel are listed in a catalogue that has been tied to AUDIO_INPUTS at the start of the model
			
			if (command.getCommandCode() == "src") {
				
					String newSrc = getCatalogueValue (command.getExtraInfo(), "AUDIO_INPUTS", device )
				
					returnWrapper.addCommOutput ("AU_SRC:" + device.getKey() + ":" + newSrc		)		 
			}
		} catch (UnknownFieldException ex){
			logger.log (Level.WARNING,ex.getMessage());
		}
	}
}