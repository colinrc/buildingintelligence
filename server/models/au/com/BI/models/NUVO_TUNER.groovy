package au.com.BI.models;

import au.com.BI.Util.*
import au.com.BI.Command.*
import au.com.BI.GroovyModels.*
import java.util.logging.Level
import au.com.BI.Config.ParameterException
import au.com.BI.Device.DeviceType
import au.com.BI.Audio.Audio
import au.com.BI.AV.AV



class NUVO_TUNER extends GroovyModel {

	// Our audio device expects 2 characters to specify the zone 
	int keyPadding = 2;
	String name = "NUVO_TUNER"
	String appendToSentStrings = "\n"
	boolean checksumRequired = false
	
	NUVO_TUNER () {
		super()
		

		configHelper.addParameterBlock  "AUDIO_INPUTS",DeviceModel.MAIN_DEVICE_GROUP,"Audio Source"
	}
	
	public void doStartup(ReturnWrapper returnWrapper) {

	}

	
	void processStringFromComms (String command , ReturnWrapper returnWrapper) {

		boolean commandFound = false
		
		// Process string from the device; there can be two AUDIO devices; A and B..   eg. 			#TÕtÕPRESETnn,ÓxyzÓ
	
		def  theTuner = command.subString (2,3) 
		// second character, this may be the incorrect place, from the manual it is impossible to tell if the single quotes are included in the string or not.
		
		def String toMatch = command.subString (3) 

		def theAudioDevice = configHelper.getControlledItem (theTuner)
		if (theAudioDevice == null) {
			logger.log (Level.WARNING,"The tuner " + theTuner + " was not specified in the configuration file")
			return
		}
		
		if (!commandFound && toMatch.equals("OFF")){
			// generate command for flash to show that the tuner is off
			returnWrapper.addFlashCommand (buildCommandForFlash (theAudioDevice,  "off") )	
			commandFound = true
		}


		if (!commandFound && toMatch.startsWith("PRESET")){
			// #TÕtÕPRESETnn,ÓxyzÓ
			def presetNumber = toMatch.subString (6,8)
			def String presetDesc = toMatch.subString (10)
			
			if (presetDesc.length() > 1) presetDesc  = presetDesc.subString (presetDesc.length()-1) // remove the last double quote
			
			returnWrapper.addFlashCommand (buildCommandForFlash (theAudioDevice,  "preset",presetNumber, presetDesc) )	
			commandFound = true
		}

		
		if (!commandFound){
			logger.log (Level.WARNING,"The string from the tuner was incorrectly formatted " + command)
		}
	}

	

	void buildAudioControlString (Audio device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {
	}

	void buildAVControlString (AV device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {
		/* this will need to be fleshed out for NUVO tuner, you need to choose whether these will be AUDIO or AV devices in the config file */
		
		// To switch on the audio device it requieres a string of this format      AU_PWR:zone:on or AW_PWR:zone:off
		if (command.getCommandCode() ==  "on") {
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
	}


}