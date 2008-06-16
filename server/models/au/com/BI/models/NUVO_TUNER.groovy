package au.com.BI.models;

import au.com.BI.Util.*
import au.com.BI.Command.*
import au.com.BI.GroovyModels.*
import java.util.logging.Level
import au.com.BI.Config.ParameterException
import au.com.BI.Device.DeviceType
import au.com.BI.Audio.Audio




class NUVO_TUNER extends GroovyModel {

	String name = "NUVO_TUNER"
	String appendToSentStrings = "\r"
	String version = "1.0"
	boolean checksumRequired = false
	String lastMatched = ""

	NUVO_TUNER () {
		super()
		
	}

	public void doStartup(ReturnWrapper returnWrapper) {
		def theDeviceList = configHelper.getAllControlledDeviceObjects ()
		for (i in theDeviceList){
			
			if (i.getDeviceType() == DeviceType.AUDIO) {
				returnWrapper.addCommOutput  ("*T'" + i.getKey() + "'STATUS\r")
			}
		}
	}

	
	void processStringFromComms (String command , ReturnWrapper returnWrapper) {

		if (lastMatched.equals (command)) return // if the same string has been sent as last time do nothing
		
		boolean commandFound = false
		
		// Process string from the device; there can be two AUDIO devices; A and B
		// eg. 	#TÕtÕPRESETnn,ÓxyzÓ
		
		def theTuner = command.substring(3,4)
		def String toMatch = command.substring(5) 
		def theAudioDevice = configHelper.getControlledItem (theTuner)
		def freqType = ""
		def frequency = ""
		
		if (theAudioDevice == null) {
			logger.log (Level.WARNING,"The tuner " + theTuner + " was not specified in the configuration file")
			return
		}
		
		if (!commandFound && toMatch.equals("OFF")){
			// #T't'OFF
			// generate command for flash to show that the tuner is off
			returnWrapper.addFlashCommand (buildCommandForFlash (theAudioDevice,  "off") )	
			commandFound = true
		}
		
		if (!commandFound && toMatch.startsWith("ON")){
			def freqString = toMatch.substring (3,5)
			switch (freqString) {
			//#T't'ON,FM103.5
			case "FM" :
				freqType = "FM"
				frequency = toMatch.substring (5)
				break;
			//#T't'ON,AM550
			case "AM" :
				freqType = "AM"
				frequency = toMatch.substring (5)
				break;
			//#T't'ON,WX1
			case "WX" :
				freqType = "WX"
				frequency = toMatch.substring (5)
				break;
			//#T't'ON,AUX
			case "AU" :
				freqType = "AUX"
				frequency = "01"
				break;
			}
			// generate command for flash to show that the tuner is on
			returnWrapper.addFlashCommand (buildCommandForFlash (theAudioDevice,  "on") )
			returnWrapper.addFlashCommand (buildCommandForFlash (theAudioDevice,  "tune" , freqType , frequency , "" , "" , "") )	
			commandFound = true
		}


		if (!commandFound && toMatch.startsWith("PRESET")){
			// #TÕtÕPRESETnnÓxyzÓ
			def presetNumber = toMatch.substring (6,8)
			def String presetDesc = toMatch.substring (9)
			
			if (presetDesc.length() > 1) presetDesc  = presetDesc.substring (1,presetDesc.length()-1) // remove the first and last double quotes
			
			returnWrapper.addFlashCommand (buildCommandForFlash (theAudioDevice,  "preset" , presetNumber , presetDesc) )
			commandFound = true
		}

		if (!commandFound && toMatch.startsWith("RDSPSN")){
			// #TÕtÕRDSPSNÓstringÓ
			// def String rdspsnString = toMatch.substring (7)
			
			// if (rdspsnString.length() > 1) rdspsnString  = rdspsnString.substring (0,rdspsnString.length()-1) // remove the last double quote
			
			//returnWrapper.addFlashCommand (buildCommandForFlash (theAudioDevice,  "RDSPSN" , rdspsnString) )	
			commandFound = true
		}
		
		if (!commandFound && toMatch.startsWith("RDSRT")){
			// #TÕtÕRDSRTÓxyzÓ
			def String rdsrtString = toMatch.substring (6)
			
			if (rdsrtString.length() > 1) rdsrtString  = rdsrtString.substring (0,rdsrtString.length()-1) // remove the last double quote
			
			returnWrapper.addFlashCommand (buildCommandForFlash (theAudioDevice,  "RDSRT" , rdsrtString) )	
			commandFound = true
		}
		
		if (!commandFound && toMatch.startsWith("FREQDESC")){
			// #TÕtÕFREQDESCÓxyzÓ
			def String descString = toMatch.substring (9)
			
			if (descString.length() > 1) descString  = descString.substring (0,descString.length()-1) // remove the last double quote
			
			returnWrapper.addFlashCommand (buildCommandForFlash (theAudioDevice,  "FREQDESC" , descString) )	
			commandFound = true
		}
		
		if (!commandFound){
			logger.log (Level.WARNING,"The string from the tuner was incorrectly formatted " + command)
		} 
		lastMatched = command// cache the command we just matched so we do not process it again if it is repeated
	}


	void buildAudioControlString (Audio device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {
		
		// Deal with turning the Tuner on
		if (command.getCommandCode() ==  "on") {
			returnWrapper.addCommOutput  ("*T'" + device.getKey() + "'ON")
		}
		
		if (command.getCommandCode() == "off") {
			returnWrapper.addCommOutput  ("*T'" + device.getKey() + "'OFF")
		}
		
		if (command.getCommandCode() == "tune") {
			
			switch (command.getExtraInfo() ) {
			case "FM" :
				if (command.getExtra2Info() != "")  {
					returnWrapper.addCommOutput  ("*T'" + device.getKey() + "'FM" + command.getExtra2Info()	)
					break;

				} else { 
					logger.log (Level.WARNING,"No FM Frequency given " + command)
				}
				break;
			
			case "AM" :
				if (command.getExtra2Info() != "")  {
					returnWrapper.addCommOutput  ("*T'" + device.getKey() + "'AM" + command.getExtra2Info()	)
					break;

				} else { 
					logger.log (Level.WARNING,"No AM Frequency given " + command)
				}
				break;
				
			case "WX" :
				if (command.getExtra2Info() != "")  {
					returnWrapper.addCommOutput  ("*T'" + device.getKey() + "'WX" + command.getExtra2Info()	)
					break;

				} else { 
					logger.log (Level.WARNING,"No WX Frequency given " + command)
				}
				
			case "AUX" :
				returnWrapper.addCommOutput  ("*T'" + device.getKey() + "'AUX" )
				break;
				
			default:
				logger.log (Level.WARNING,"No Frequency type given " + command)
			
			}
		}
		
		if (command.getCommandCode() == "preset" && command.getExtraInfo() != "" ) {
			returnWrapper.addCommOutput  ("*T'" + device.getKey() + "'PRESET" + command.getExtraInfo() )
		}
		else { 
			logger.log (Level.WARNING,"No preset given " + command)
		}
	}
}
