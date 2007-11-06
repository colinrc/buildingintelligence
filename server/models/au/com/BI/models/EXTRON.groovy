package au.com.BI.models;

import au.com.BI.Util.*
import au.com.BI.Command.*
import au.com.BI.GroovyModels.*
import java.util.logging.Level
import au.com.BI.Config.ParameterException
import au.com.BI.Device.DeviceType
import au.com.BI.AV.AV
import au.com.BI.Unit.Unit
import java.util.regex.Matcher
import java.util.regex.Pattern


class EXTRON extends GroovyModel {

	String name = "EXTRON"
	String appendToSentStrings = "\n"
	
	EXTRON () {
		super()

	}
	
	void processStringFromComms (String command , ReturnWrapper returnWrapper) {
		
		try {
			switch (command) {
			
				// Handle any error messages
				case "E01":
					log ("Invalid input channel number (too large) " + command )
					break;
					
				case "E10":
					log ("Invalid command " + command )
					break;
					
				case "E11":
					log ("Invalid preset number " + command )
					break;
					
				case "E12":
					log ("Invalid output number (too large) " + command )
					break;
					
				case "E13":
					log ("Invalid value (out of range) " + command )
					break;
					
				case "E14":
					log ("Illegal command for this configuration " + command )
					break;
					
				case "E17":
					log ("Timeout (caused only by direct write of global preset) " + command )
					break;
					
				case "E21":
					log ("Invalid room number " + command )
					break;
					
				case "E24":
					log ("Priveledge violation " + command )
					break;

				default:
					logger.log (Level.INFO,"An unknown command was sent from the Extron Switcher " + command)
				}			
			} catch (IndexOutOfBoundsException ex) {
				logger.log (Level.WARNING,"The string from Extron Switcherr was incorrectly formatted " + command)
			} catch (NumberFormatException ex) {
				logger.log (Level.WARNING,"The string from Extron Switcher was incorrectly formatted " + command)
			}
	}

	void buildUnitControlString (Unit device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {

		// Mute all Audio or Video
		if (command.getCommandCode() == "mute") {
			switch (command.getExtraInfo() ) {
			case "video" :
				returnWrapper.addCommOutput ("1*B")
				break;
				
			case "audio" :
				returnWrapper.addCommOutput ("1*Z")
				break;
				
			}
		}
		
		// Unmute all Audio or Video
		if (command.getCommandCode() == "unmute") {
			switch (command.getExtraInfo() ) {
			case "video" :
				returnWrapper.addCommOutput ("0*B")
				break;
				
			case "audio" :
				returnWrapper.addCommOutput ("0*Z")
				break;
				
			}
		}
		
		// Recall a global preset
		if (command.getCommandCode() == "preset") {
				returnWrapper.addCommOutput (command.getExtraInfo() + ".")

		}
	}

	void buildAVControlString (AV device, CommandInterface command, ReturnWrapper returnWrapper) throws ParameterException {
		try {
			// Create ties
			if (command.getCommandCode() ==  "src") {
				String newSrc = getCatalogueValue (command.getExtraInfo(), "AV_INPUTS", device )
				if (device.getKey() != ("0") ) {
					switch (command.getExtra2Info() ) {
					case "AV" :
						returnWrapper.addCommOutput  (newSrc + "*" + device.getKey() + "!" )
						break;
				
					case "AUDIO_ONLY" :
						returnWrapper.addCommOutput  (newSrc + "*" + device.getKey() + "\$" )
						break;
					
					case "VIDEO_ONLY" :
						returnWrapper.addCommOutput  (newSrc + "*" + device.getKey() + "%" )
						break;
						}
				} else {
					switch (command.getExtra2Info() ) {
					case "AV" :
						returnWrapper.addCommOutput  (newSrc + "*!" )
						break;
					
					case "AUDIO_ONLY" :
						returnWrapper.addCommOutput  (newSrc + "*\$" )
						break;
						
					case "VIDEO_ONLY" :
						returnWrapper.addCommOutput  (newSrc + "*%" )
						break;
						}
					}
				}
			
			//Mute zone Audio or Video
			if (command.getCommandCode() == "mute") {
				switch (command.getExtraInfo() ) {
				case "video" :
					returnWrapper.addCommOutput (device.getKey() + "*1B")
					break;
					
				case "audio" :
					returnWrapper.addCommOutput (device.getKey() + "*1Z")
					break;
					
				}
			}
			
			//Unmute zone Audio or Video
			if (command.getCommandCode() == "unmute") {
				switch (command.getExtraInfo() ) {
				case "video" :
					returnWrapper.addCommOutput (device.getKey() + "*0B")
					break;
					
				case "audio" :
					returnWrapper.addCommOutput (device.getKey() + "*0Z")
					break;
					
				}
			}
			
		} catch (NumberFormatException ex){
			logger.log (Level.WARNING,"An invalid input was received " + command.getExtraInfo())
		}
	}
}



	