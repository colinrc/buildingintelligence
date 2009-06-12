package au.com.BI.models;

import au.com.BI.Util.*
import au.com.BI.Command.*
import au.com.BI.GroovyModels.*
import java.util.logging.Level
import au.com.BI.Config.ParameterException
import au.com.BI.Device.DeviceType
import au.com.BI.Pump.Pump
import au.com.BI.Thermostat.Thermostat
import java.util.regex.Matcher
import java.util.regex.Pattern
import java.util.BitSet


class JANDY extends GroovyModel {

	String name = "JANDY"
	String appendToSentStrings = "\r"
	String version = "0.5"
	boolean checksumRequired = false
	
	JANDY () {
		super()
		 setDeviceKeysString (true) 
	}
	
	public void doStartup(ReturnWrapper returnWrapper) {
		  
		returnWrapper.addCommOutput ("#ECHO = OFF")
		returnWrapper.addCommOutput ("#RSPFMT = 0")
		returnWrapper.addCommOutput ("#COSMSGS = 1")
		returnWrapper.addCommOutput ("#CLEANR")
		
		def theDeviceList = configHelper.getAllControlledDeviceObjects ()
		for (i in theDeviceList){
			
			if (i.getDeviceType() == DeviceType.THERMOSTAT) {
				returnWrapper.addCommOutput  ("#" + i.getKey() + "?")
			}
			
			if (i.getDeviceType() == DeviceType.PUMP) {
				returnWrapper.addCommOutput  ("#" + i.getKey())
			}
		}
		// Usually polling is started once startup has been completed
		// enablePoll (6) 
		// The string will be sent every 3 seconds. Times less than around 3-5 seconds should not be used as most devices take around that long to respond, particularly if they are busy

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
					logger.log (Level.WARNING,"Invalid command warning " + theCommand )
				}
				
				switch (theCommand) {

					case "!00" :
						logger.log (Level.FINE,"Valid command received " + command )

						def zzParm = partsOfCommand[1]
						def jandyDevice = configHelper.getControlledItem (zzParm)
						
						if (jandyDevice == null){
							logger.log (Level.WARNING,"Command received for non configered device " + zzParm )
							return;
						}
						
						switch (zzParm) {
						case "PUMP" :
							if (partsOfCommand[3] == "1" ){
								returnWrapper.addFlashCommand ( jandyDevice, "on")
							} else {
								returnWrapper.addFlashCommand ( jandyDevice, "off")
							}
							break;
						case "PUMPLO" :
							if (partsOfCommand[3] == "1" ){
								returnWrapper.addFlashCommand ( jandyDevice, "on")
							} else {
								returnWrapper.addFlashCommand ( jandyDevice, "off")
							}
							break;
						case "SPA" :
							if (partsOfCommand[3] == "1" ){
								returnWrapper.addFlashCommand ( jandyDevice, "on")
							} else {
								returnWrapper.addFlashCommand ( jandyDevice, "off")
							}
							break;
						case "WFALL" :
							if (partsOfCommand[3] == "1" ){
								returnWrapper.addFlashCommand ( jandyDevice, "on")
							} else {
								returnWrapper.addFlashCommand ( jandyDevice, "off")
							}
							break;
						case "CLEANR" :
							if (partsOfCommand[3] == "1" ){
								returnWrapper.addFlashCommand ( jandyDevice, "on")
							} else {
								returnWrapper.addFlashCommand ( jandyDevice, "off")
							}
							break;
						case "POOLHT" :
							if (partsOfCommand[3] == "1" ){
								returnWrapper.addFlashCommand ( jandyDevice, "enable")
							} else {
								returnWrapper.addFlashCommand ( jandyDevice, "off")
							}
							returnWrapper.addFlashCommand ( jandyDevice, "temp" , partsOfCommand[3] , partsOfCommand[4] )
						    break;
							
						case "POOLTMP" :
							returnWrapper.addFlashCommand ( jandyDevice, "temp" , partsOfCommand[3] , partsOfCommand[4] )
						    break;
						case "AIRTMP" :
							returnWrapper.addFlashCommand ( jandyDevice, "temp" , partsOfCommand[3] , partsOfCommand[4] )
						    break;
						case "SPATMP" :
							returnWrapper.addFlashCommand ( jandyDevice, "temp" , partsOfCommand[3] , partsOfCommand[4] )
						    break;
						case "SOLTMP" :
							returnWrapper.addFlashCommand ( jandyDevice, "temp" , partsOfCommand[3] , partsOfCommand[4] )
						    break;
						case "POOLSP" :
							returnWrapper.addFlashCommand ( jandyDevice, "set" , partsOfCommand[3] , partsOfCommand[4] )
						    break;
						case "POOLSP2" :
							returnWrapper.addFlashCommand ( jandyDevice, "set" , partsOfCommand[3] , partsOfCommand[4] )
						    break;	
						case "LEDS" :
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
		
		// To switch on an Aqualink device it requires a string of this format      #PUMP=1 or #PUMP=0
		if (command.getCommandCode() ==  "on") {
			returnWrapper.addCommOutput  ("# " + device.getKey() + " = 1")
		}
		
		if (command.getCommandCode() == "off") {
			returnWrapper.addCommOutput ("# " + device.getKey() + " = 0")
		}

	}


	void buildThermostatControlString (Thermostat device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {
		try {
			// Zone Temperature Set Point requires a string "ZSE=[ZoneNumber],[ZoneMode],[Setting]"
			if (command.getCommandCode() ==  "set") {
				def setPointStr = command.getExtraInfo()
				def setPoint = setPointStr.toInteger() * 100
				returnWrapper.addCommOutput  ("ZSE" + device.getKey() + ",1," + setPoint)
			}
			
			// Zone set to Manual and Open requires a string "ZSE=[ZoneNumber],2,1"
			if (command.getCommandCode() ==  "position") {
				switch (command.getExtraInfo() ) {
				case "open" :
					returnWrapper.addCommOutput ("ZSE" + device.getKey() + ",2,1")
					break;
				case "closed" :
					returnWrapper.addCommOutput ("ZSE" + device.getKey() + ",2,0")
					break;
				default :
					logger.log (Level.WARNING,"Invalid HVAC zone position " + command )
				}
			}
		} catch (NumberFormatException ex){
			logger.log (Level.WARNING,"An invalid temperature was received " + command.getExtraInfo())
		}
	}
}
