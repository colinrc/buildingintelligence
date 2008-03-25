package au.com.BI.models;

import au.com.BI.Util.*
import au.com.BI.Command.*
import au.com.BI.GroovyModels.*
import java.util.logging.Level
import au.com.BI.Config.ParameterException
import au.com.BI.CustomInput.CustomInput 
import au.com.BI.Device.DeviceType
import au.com.BI.CustomConnect.CustomConnect
import au.com.BI.Thermostat.Thermostat
import au.com.BI.ToggleSwitch.ToggleSwitch
import au.com.BI.Audio.Audio
import au.com.BI.AV.AV
import java.util.regex.Matcher
import java.util.regex.Pattern


/**
   
   This model expects:
	      A parameter block AV_INPUTS that describes the input connectors.
          A parameter PROTOCOL that describes how the Integra is being communicated with, IP or serial .
               - this is the final connection to the Integra, not the server. A Serial device connected via a GC100 has a SERIAL protocol.
          A parameter MODEL with the integra model; eg. DTR5.2
          AV zones in the configuration must follow a particular pattern, 01 is for the main zone, 02 for zone 2, 03 for zone 3.
**/

class Integra extends GroovyModel {

	// Our audio device expects 2 characters to specify the zone 
	int keyPadding = 2;
	String name = "Integra"
	String appendToSentStrings = "\n"
	String model = "DTR5.2"
	boolean requiresChecksum = false // fasle is default
	boolean ipProtocol = true // IP is default unless serial is specified
	
	Integra () {
		super()
		
		configHelper.addParameterBlock  "AV_INPUTS", DeviceModel.MAIN_DEVICE_GROUP, "AV Sources"
		
	}
	
	public void doStartup(ReturnWrapper returnWrapper) {
		// Any instructions that should be set up the device for communication should be included here.
		// This method is called after connection is made to the device
		
		def protocol = configHelper.getParameterValue ("PROTOCOL", DeviceModel.MAIN_DEVICE_GROUP)
		if (protocol == null || protocol == "SERIAL") ipProtocol = false

		def modelPar = configHelper.getParameterValue ("MODEL", DeviceModel.MAIN_DEVICE_GROUP)
		if (modelPar != null ) model = modelPar

	}


	
	void processStringFromComms (String command , ReturnWrapper returnWrapper) {

	
	}



	void buildAVControlString (AV device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {
		// receives a message from flash and builds the appropriate string for the audio device 
		if (device.getKey() == "01") buildAVControlStringMain (device,  command,  returnWrapper) ;
		if (device.getKey() == "02") buildAVControlStringZone2 (device,  command,  returnWrapper) ;
		if (device.getKey() == "03") buildAVControlStringZone3 (device,  command,  returnWrapper) ;
	}

	void buildAVControlStringMain (AV device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {

		// To switch on the audio device it requieres a string of this format      AU_PWR:zone:on or AW_PWR:zone:off
		if (command.getCommandCode() ==  "on") {
			buildOutputString ("1PWR" + device.getKey() + "01", returnWrapper)
		}
		
		if (command.getCommandCode() ==  "off") {
			buildOutputString  ("1PWR" + device.getKey() + "01", returnWrapper)
		}
		

		// To change the volume the format will be AU_VOL:zone:- or AU_VOL:zone:+ 
		if (command.getCommandCode() == "volume") {
			
			if (command.getExtraInfo() == "up" )  {
				buildOutputString   ("1MVL" + device.getKey() + ":+"	, returnWrapper)					
			} 
			if (command.getExtraInfo() == "down" )  {
				buildOutputString   ("1MVL" + device.getKey() + ":+"	, returnWrapper)					
			} 
			
			else { 
				buildOutputString   ("1MVL" + device.getKey() + ":-", returnWrapper)
			}
		}
		
		// The names of each input channel are listed in a catalogue that has been tied to AV_INPUTS at the start of the model
		
		if (command.getCommandCode() == "src") {
			
				String newSrc = getCatalogueValue (command.getExtraInfo(), "AV_INPUTS", device )
			
				buildOutputString  ("SLI" + device.getKey() + ":" + newSrc		,returnWrapper		 )
		}
	}

	
	void buildAVControlStringZone2 (AV device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {
		// receives a message from flash and builds the appropriate string for the audio device
		
	}
	
	
	void buildOutputString(String rawCommand, ReturnWrapper returnWrapper){
		if (ipProtocol){
			// Integra is using IP protocol
			returnWrapper.addCommOutput(rawCommand.getBytes() + "\n");	
		} else {
			// Serial protocol
			returnWrapper.addCommOutput("!" + rawCommand + "\n");
		}
	}
	
}