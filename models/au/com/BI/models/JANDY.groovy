package au.com.BI.models;

import au.com.BI.Util.*
import au.com.BI.Command.*
import au.com.BI.GroovyModels.*
import java.util.logging.Level
import au.com.BI.Config.ParameterException
import au.com.BI.Device.DeviceType
import au.com.BI.Pump.Pump
import au.com.BI.Thermostat.Thermostat
import au.com.BI.Heater.Heater
import au.com.BI.Auxiliary.Auxiliary;
import au.com.BI.ToggleSwitch.ToggleSwitch
import java.util.regex.Matcher
import java.util.regex.Pattern
import java.util.BitSet


class JANDY extends GroovyModel {

	String name = "JANDY"
	String appendToSentStrings = "\r"
	String version = "1.0"
	boolean checksumRequired = false

	
	JANDY () {
		super()
		 setDeviceKeysString (true) 
	}
	
	public void doStartup(ReturnWrapper returnWrapper) {
		  
		returnWrapper.addCommOutput ("#ECHO = OFF")
		returnWrapper.addCommOutput ("#RSPFMT = 0")
		returnWrapper.addCommOutput ("#COSMSGS = 1")
		
		doPoll (returnWrapper)
		this.setIPHeartbeat(true) 
		
		// Usually polling is started once startup has been completed
		//enablePoll (6) 
		// Jandy is supposed to announce changes so we'll keep polling off to see how reliable it is

	}
	

	
// We may have to poll for LED status
//	public void doPoll(ReturnWrapper returnWrapper) {
//		
//		returnWrapper.addCommOutput ("#LEDS?")
//	}
	
	void processStringFromComms (String command , ReturnWrapper returnWrapper) {
		
		def partsOfCommand = command.split(" ")

			try {
				def theCommand = partsOfCommand[0]
				
				if (theCommand.startsWith("?")){
					if (!theCommand.equals("?11") && !theCommand.equals("?12") ) {
						
						logger.log (Level.WARNING,"Invalid command " + command )
					}
				}
				
				switch (theCommand) {

					case "Jandy" :
						doStartup(returnWrapper) // unit was reset
						break
						
					case "!00" :
						logger.log (Level.FINE,"Valid command received " + command )

						def zzParm = partsOfCommand[1]

                        if (zzParm == "ECHO" || zzParm == "RSPFMT" || zzParm == "COSMSGS") 
                        	return;

						def jandyDevice = configHelper.getControlledItem (zzParm)
						
						if (jandyDevice == null){
							logger.log (Level.WARNING,"Command received for non configered device " + zzParm )
							return;
						}
						
						switch (zzParm) {

							
						case "PUMP" : case "PUMPLO" : case "SPA" : case "WFALL" : 
							if (partsOfCommand[3] == "1" ){
								returnWrapper.addFlashCommand ( jandyDevice, "on")
							} else {
								returnWrapper.addFlashCommand ( jandyDevice, "off")
							}
							break;
							
							
						 case "CLEANR" :
							if (partsOfCommand[3] == "ON" ){
								returnWrapper.addFlashCommand ( jandyDevice, "on")
							} else {
								returnWrapper.addFlashCommand ( jandyDevice, "off")
							}
							break;
							
						case "POOLHT" :  case "SPAHT" : 
							if (partsOfCommand[3] == "1" ){
								returnWrapper.addFlashCommand ( jandyDevice, "on" , partsOfCommand[3]  )
							} else {
								returnWrapper.addFlashCommand ( jandyDevice, "off")
							}
						    break;


						case ~/AUX[1-9]/ : 
							if (partsOfCommand[3] == "1" ){
								returnWrapper.addFlashCommand ( jandyDevice, "on" , partsOfCommand[3]  )
							} else {
								returnWrapper.addFlashCommand ( jandyDevice, "off")
							}
						    break;

						case ~/AUXX/ : 
							if (partsOfCommand[3] == "1" ){
								returnWrapper.addFlashCommand ( jandyDevice, "on" , partsOfCommand[3]  )
							} else {
								returnWrapper.addFlashCommand ( jandyDevice, "off")
							}
						    break;

						case "POOLTMP" : case "AIRTMP" : case "SPATMP" : case "SOLTMP" :  case "POOLSP" : case "POOLSP2" : case "SPASP" :
							returnWrapper.addFlashCommand ( jandyDevice, "on" , Integer.parseInt(partsOfCommand[3]) & 127 )
						    break;
							
							
						case "LEDS_OLD" : // do not want this to be picked up
							def ledString = new String( partsOfCommand[3].toString(2) + partsOfCommand[4].toString(2) + partsOfCommand[5].toString(2) + partsOfCommand[6].toString(2) + partsOfCommand[7].toString(2))
							def ledBits = new BitSet(ledString.length())
							def spaDevice = configHelper.getControlledItem(SPA)
							def pumpDevice = configHelper.getControlledItem(PUMP)
							
							// Read the LED bits into a BitSet
							// Merik; I Don't think this is right, looks like you are reading in a bit series eg. 100100100 rather than an integer that you convert.
							
							/* 
							// You probably want something like;
							// int toTest[] = new int[5];
							// toTest[3] = Integer.parseInt(partsOfCommand[3])
							
							// then to test if the bit 0 is true
							//  if (toTest[3] && 1 == 1 ) { 
							 * do stuff 
							 * }
							 * 
							 * to test if bit 1 is true
							//  if (toTest[3 && 2 == 2) { 
							 * do stuff  
							 * }
							 * 
							 * 	to test if bit 2 is true
							//  if (toTest[3 && 4 == 4) { 
							 * do stuff  
							 * }

							*/
							
							for (int i = 0; i < ledString.lenght(); i++){
								if (ledString.charAt(i) == '1'){
									ledBits.set(i)
								} else {
									ledBits.clear(i)
								}
								}
							
							// Check the Real SPA status
							if (ledBits.get(10)){
								if (ledBits.get(11)){
									// If bit 10 and 11 is 1 do nothing
									return
								} else {
									// If bit 10 is 1 and 11 is 0
									returnWrapper.addFlashCommand ( spaDevice, "on")
									return
								}
							}
							else{
								
								if (ledBits.get(11)){
										// If bit 10 is 0 and bit 11 is 1
										returnWrapper.addFlashCommand ( spaDevice, "cool")
										return
									} else {
										// If bit 10 is 0 and bit 11 is 0
										returnWrapper.addFlashCommand ( spaDevice, "off")
								}
							}
							
							// Check the Real Filter Pump status
							if (ledBits.get(10)){
								if (ledBits.get(11)){
									// If bit 10 and 11 is 1 do nothing
									return
								} else {
									// If bit 10 is 1 and 11 is 0
									returnWrapper.addFlashCommand ( pumpDevice, "on")
									return
								}
							}
							else{
								
								if (ledBits.get(11)){
										// If bit 10 is 0 and bit 11 is 1
										returnWrapper.addFlashCommand ( pumpDevice, "wait")
										return
									} else {
										// If bit 10 is 0 and bit 11 is 0
										returnWrapper.addFlashCommand ( pumpDevice, "off")
								}
							}
							
							// Check the Real Heater status
							if (ledBits.get(28)){
								if (ledBits.get(29)){
									// If bit 10 and 11 is 1 do nothing
									return
								} else {
									// If bit 10 is 1 and 11 is 0
									returnWrapper.addFlashCommand ( pumpDevice, "on")
									return
								}
							}
							else{
								
								if (ledBits.get(11)){
										// If bit 10 is 0 and bit 11 is 1
										returnWrapper.addFlashCommand ( pumpDevice, "wait")
										return
									} else {
										// If bit 10 is 0 and bit 11 is 0
										returnWrapper.addFlashCommand ( pumpDevice, "off")
								}
							}
						 
							break;
						case "2" :
						    FRESH = "YES"
						    returnWrapper.addFlashCommand (hvacUnit,  "fresh", "recirc" )
						    break;
						case "4" :
						    FRESH = "YES"
						    returnWrapper.addFlashCommand (hvacUnit,  "fresh", "auto" )
						    break;
						}                            
						break;                             

						
				}			
			} catch (IndexOutOfBoundsException ex) {
				logger.log (Level.WARNING,"The string from the Jandy pool controller was incorrectly formatted " + command + " " +ex.getMessage() )
			} catch (NumberFormatException ex) {
				logger.log (Level.WARNING,"The string from Jandy pool controller was incorrectly formatted " + command + " " +ex.getMessage() )
			}
	}

	void buildPumpControlString (Pump device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {
		
		// To switch on an Aqualink device it requires a string of this format      #PUMP= ON or #PUMP= OFF
		if (command.getCommandCode() ==  "on") {
			returnWrapper.addCommOutput  ("#" + device.getKey() + " = ON")
			return
		}
		
		if (command.getCommandCode() == "off") {
			returnWrapper.addCommOutput ("#" + device.getKey() + " = OFF")
			return
		}

	}

	void buildHeaterControlString (Heater device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {
		
		// To switch on an Aqualink device it requires a string of this format      #PUMP= ON or #PUMP=OFF
		if (command.getCommandCode() ==  "on") {
			returnWrapper.addCommOutput  ("#" + device.getKey() + " = ON")
			return
		}
		
		if (command.getCommandCode() == "off") {
			returnWrapper.addCommOutput ("#" + device.getKey() + " = OFF")
			return
		}

	}

	void buildAuxiliaryControlString (Auxiliary device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {
		
		// To switch on an Aqualink device it requires a string of this format      #PUMP= ON or #PUMP=OFF
		if (command.getCommandCode() ==  "on") {
			returnWrapper.addCommOutput  ("#" + device.getKey() + " = ON")
			return
		}
		
		if (command.getCommandCode() == "off") {
			returnWrapper.addCommOutput ("#" + device.getKey() + " = OFF")
			return
		}

		if (command.getCommandCode() == "up") {
			returnWrapper.addCommOutput ("#" + device.getKey() + " +")
			return
		}

		if (command.getCommandCode() == "down") {
			returnWrapper.addCommOutput ("#" + device.getKey() + " -")
			return
		}
	}
	
	void buildToggleOutputControlString (ToggleSwitch device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {
		
		// To switch on an Aqualink device it requires a string of this format      #PUMP= ON  or #PUMP= OFF
		if (command.getCommandCode() ==  "on") {
			returnWrapper.addCommOutput  ("#" + device.getKey() + " = ON")
			return
		}
		
		if (command.getCommandCode() == "off") {
			returnWrapper.addCommOutput ("#" + device.getKey() + " = OFF")
			return
		}

	}
	
	void buildThermostatControlString (Thermostat device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {
		
		try {
			int x = 0;
			x = Integer.parseInt(command.getExtraInfo()) // Make sure it really is a number
			returnWrapper.addCommOutput ("#" + device.getKey() + " = " + x)
			
		} catch (IllegalFormatException ex){
			logger.log (Level.WARNING,"An incorrect command was sent to the Jandy heater " + command.getCommandCode());
		}
	}
	
	void doPoll (ReturnWrapper returnWrapper){

		def theDeviceList = configHelper.getAllControlledDeviceObjects ()
		for ( DeviceType i in theDeviceList){
			String stringToAdd = ""
			if (  i.getDeviceType()  == DeviceType.SENSOR) {
				stringToAdd = "#" + i.getKey() + " ?";
			}
			
			if (i.getDeviceType() == DeviceType.PUMP  ) {
				stringToAdd = "#" + i.getKey() + " ?";
			}
			
			if (  i.getDeviceType()   == DeviceType.THERMOSTAT) {
				stringToAdd = "#" + i.getKey() + " ?";
			}

			if (  i.getDeviceType()   == DeviceType.HEATER ) {
				stringToAdd =  "#" + i.getKey() + " ?";
			}

			if (  i.getDeviceType()   == DeviceType.AUXILIARY  ) {
				if (i.getKey().equals("CLEANR")){
					stringToAdd = "#CLEANR";
				} else {
					stringToAdd = "#" + i.getKey() + " ?";				
				}
			}
			if (stringToAdd != "") {
				logger.log (Level.INFO,"Sending command : " + stringToAdd)
				returnWrapper.addCommOutput(stringToAdd)
			}
		}

	}
}
