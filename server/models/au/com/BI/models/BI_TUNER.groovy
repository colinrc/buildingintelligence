package au.com.BI.models;

import au.com.BI.Util.*
import au.com.BI.Command.*
import au.com.BI.GroovyModels.*
import au.com.BI.CustomInput.CustomInput 
import au.com.BI.CustomConnect.CustomConnect
import java.util.regex.Matcher
import java.util.regex.Pattern


class RawTest extends GroovyModel {

	// Our audio device expects 2 characters to specify the zone 
	int keyPadding = 2;
	String name = "BI_TUNER"
	
	RawTest() {
		super()
		configHelper.addParameterBlock  "AUDIO_INPUTS",DeviceModel.MAIN_DEVICE_GROUP,"Audio Source"
	}
	
	void processStringFromComms (String command , ReturnWrapper returnWrapper) {
		def matcher = command =~ /(AU_PWR|AU_VOL|AU_SRC):(\d+):(\d+)/

		// Process string from the device that looks like  AU_VOL:zone:level
	
		try {
			command = matcher(0)
			zone = matcher(1)
			// The zone is the key field that is specified in the configuration file to refer to each audio zone
			                  		
			param = matcher(2)
			theAudioDevice = configHelper.getControlledItem (zone)

			switch (command) {
				case "AU_VOL" :
						
					if (param == "00" ) {
						returnWrapper.addFlashCommand (buildOffCommandForFlash ( theAudioDevice) )
					} else {
						returnWrapper.addFlashCommand (buildCommandForFlash (theAudioDevice,  "on", param) )	
					}
					break
				
				case "AU_PWR"  :
							
					if (param  == "0" ) {
						returnWrapper.addFlashCommand (buildOffCommandForFlash (theAudioDevice)  )
					} else {
						returnWrapper.addFlashCommand (buildCommandForFlash (theAudioDevice,  "on") )	
					}					
					break
					
				default:
					logger.log (Level.WARNING,"An unknown command was sent from flash to the audio device" )
			}			
		} catch (IndexOutOfBoundsException ex) {
			logger.log (Level.WARNING,"The string from the audio device was incorrectly formatted " + stringFromComms)
		}
	}

	
	void buildCustomConnectString (CustomConnect device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {
				// receives a message from flash and builds the appropriate string for the audio device
				
				// To switch on the audio device it requieres a string of this format      AU_PWR:zone:on or AW_PWR:zone:off
				if (command.getCommandCode() ==  "off") {
					returnWrapper.addCommsString  ("AU_PWR:" + device.getKey() + ":1\n")
				}
				
				if (command.getCommandCode() == "on") {
					returnWrapper.addCommsString ("AU_PWR:" + device.getKey() + ":0\n")
				}
	
				// To change the volume the format will be AU_VOL:zone:- or AU_VOL:zone:+ 
				if (command.getCommandCode() == "vol") {
					
					if (command.getExtraInfo() == "up" )  {
						returnWrapper.addCommsString  ("AU_VOL:" + device.getKey() + ":+\n"	)					

					} else { 
						returnWrapper.addCommsString  ("AU_VOL:" + device.getKey() + ":-\n")
					}
				}
				
				
				// To change the input source the format will be AU_SRC:zone:src_val
				// The names of each input channel are listed in a catalogue that has been tied to AUDIO_INPUTS at the start of the model
				
				if (command.getCommandCode() == "src") {
					
						String newSrc = findKeyForParameterValue (command.getExtraInfo(), "AUDIO_INPUTS", device )
					
						returnWrapper.addCommsString ("AU_SRC:" + device.getKey() + ":" + newSrc + "\n"			)		 
				}
	}

}