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
   This demonstration shows the basic pattern for groovy models.
   
   The model contains various functions that are called by the system during operations.
   
   On startup the system will call doStartup()  ,this should contain any required commands to put the device in a state for communications with eLife.
   
   When instructions are received from the device  the model's processStringFromComms method is called. This is where you will process instructions 
   and usually send the appropriate message to the flash client.
   
   When instructions are received from the flash client the models doOutputItem method is called.
   

**/

class Integra extends GroovyModel {

	// Our audio device expects 2 characters to specify the zone 
	int keyPadding = 2;
	String name = "Integra"
	String appendToSentStrings = "\n"

	
	Integra () {
		super()
		
		configHelper.addParameterBlock  "AV",DeviceModel.MAIN_DEVICE_GROUP,"AV Source"
	}
	
	public void doStartup(ReturnWrapper returnWrapper) {
		// Any instructions that should be set up the device for communication should be included here.
		// This method is called after connection is made to the device

	}


	
	void processStringFromComms (String command , ReturnWrapper returnWrapper) {

		def matcher = command =~ /(OK|AU_PWR|AU_VOL|AU_SRC|AU_STARTED):?(\d*):?(\d*)/
		 //  For details on groovy regular expressions see   http://groovy.codehaus.org/Tutorial+4+-+Regular+expressions+basics
		
		// Process string from the device that looks like  AU_VOL:zone:level  , AU_PWR:zone:0|1,   AU_SRC:zone:src,  AU_STARTED
	
		if (matcher.matches()) {
			try {
				def theCommand = matcher[0][1]  // For a pattern match that has only captured one line, each capture group i reffered to by matcher[0][group]
	
				switch (theCommand) {
					case "OK":
						// The last command has been acknowledged by the device so now send the next one
						comms.acknowledgeCommand("")
						comms.sendNextCommand()
						break;

					case "ERROR":
						// The last command has been acknowledged by the device so now send the next one
						comms.resendAllSentCommands()
						break;

					case "AU_STARTED" :
						// received confirmation from the device that the initial setup is complete, now query the state of each item from the configuration file
						doRestOfStartup(returnWrapper)
						break
						
					case "AU_VOL" :
						def zone = matcher[0][2]
						      				// The zone will be used to look up the key field that is specified in the configuration file to refer to each audio zone
						      				                  		
						 def param = matcher[0][3]
						 def theAudioDevice = configHelper.getControlledItem (zone)

						 if (theAudioDevice == null){
							 logger.log (Level.INFO,"An instruction received for a zone that has not been configured " + zone)
						 } else {
								
							if (param == "00" ) {
								returnWrapper.addFlashCommand (buildOffCommandForFlash ( theAudioDevice) )
							} else {
								returnWrapper.addFlashCommand (buildCommandForFlash (theAudioDevice,  "on", param) )	
							}
						 }
						break
					
					case "AU_PWR"  :
						def zone = matcher[0][2]
							      				// The zone will be used to look up the key field that is specified in the configuration file to refer to each audio zone
							      				                  		
						def param = matcher[0][3]
						def theAudioDevice = configHelper.getControlledItem (zone)
						 if (theAudioDevice == null){
							 logger.log (Level.INFO,"An instruction received for a zone that has not been configured " + zone)
						 } else {
																	
							if (param  == "0" ) {
								returnWrapper.addFlashCommand (buildOffCommandForFlash (theAudioDevice)  )
							} else {
								returnWrapper.addFlashCommand (buildCommandForFlash (theAudioDevice,  "on") )	
							}	
						 }
						break
						
					case "AU_SRC"  :
						def zone = matcher[0][2]
							      				// The zone will be used to look up the key field that is specified in the configuration file to refer to each audio zone
							      				                  		
						def param = matcher[0][3]
						def theAudioDevice = configHelper.getControlledItem (zone)
						 if (theAudioDevice == null){
							 logger.log (Level.INFO,"An instruction received for a zone that has not been configured " + zone)
						 } else {
							 try {
								 def srcVal =  findKeyForParameterValue (param, "AUDIO_INPUTS", theAudioDevice )
																		
									returnWrapper.addFlashCommand (buildCommandForFlash (theAudioDevice,  "src", srcVal) )	
							 } catch (ParameterException ex){
								 logger.log (Level.INFO,"A source request was received for an input that has not been defined")
							 }
						 }
						break
					default:
						logger.log (Level.WARNING,"An unknown command was sent from flash to the audio device" )
				}			
			} catch (IndexOutOfBoundsException ex) {
				logger.log (Level.WARNING,"The string from the audio device was incorrectly formatted " + command)
			}
		} else {
			logger.log (Level.WARNING,"The string from the audio device was incorrectly formatted " + command)
		}
	}



	void buildAVControlString (AV device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {
		// receives a message from flash and builds the appropriate string for the audio device
		
		// To switch on the audio device it requieres a string of this format      AU_PWR:zone:on or AW_PWR:zone:off
		if (command.getCommandCode() ==  "on") {
			returnWrapper.  ("!1PWR" + device.getKey() + "01")
		}
		
		if (command.getCommandCode() ==  "off") {
			returnWrapper.  ("!1PWR" + device.getKey() + "01")
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
		
		// The names of each input channel are listed in a catalogue that has been tied to AV_INPUTS at the start of the model
		
		if (command.getCommandCode() == "src") {
			
				String newSrc = getCatalogueValue (command.getExtraInfo(), "AV_INPUTS", device )
			
				returnWrapper.addCommOutput ("AU_SRC:" + device.getKey() + ":" + newSrc		)		 
		}
	}


	
	public Byte addCheckSum(byte [] calcValue) {

		byte checksum = 0;
		for (int i in calcValue){ 
			checksum += i;
		}

		return new Byte((byte)(checksum&0xff));
	}

}