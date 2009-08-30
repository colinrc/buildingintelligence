package au.com.BI.models;

import au.com.BI.Util.*
import au.com.BI.Command.*
import au.com.BI.GroovyModels.*
import java.util.logging.Level
import au.com.BI.Config.ParameterException
import au.com.BI.Device.DeviceType
import au.com.BI.Pump.Pump
import au.com.BI.Unit.Unit
import au.com.BI.Thermostat.Thermostat
import java.util.regex.Matcher
import java.util.regex.Pattern

class ADVANTAGE_AIR extends GroovyModel {
	
	String name = "ADVANTAGE_AIR"
	String appendToSentStrings = "\r"
	def FRESH = ""
	def FILTER = ""
	def IONISER = ""
	def UV = ""
	def FILTER_STATE = ""
	def IONISER_STATE = ""
	def UV_STATE = ""
	
	ADVANTAGE_AIR () {
		super()
		
		setQueueCommands(true) 

	}
	
	public void doStartup(ReturnWrapper returnWrapper) {
		setDeviceKeysString(true)
		returnWrapper.addCommOutput ("ASU=1")
		returnWrapper.addCommOutput ("RCS=?")
		returnWrapper.addCommOutput ("FRE=?")
		returnWrapper.addCommOutput ("FIL=?")
		def theDeviceList = configHelper.getAllControlledDeviceObjects ()
		for (i in theDeviceList){
			
			if (i.getDeviceType() == DeviceType.THERMOSTAT) {
				returnWrapper.addCommOutput  ("ZST=" + i.getKey() )
			}
		}
	}
	
	String formatKey (String key, DeviceType theDevice){
		if (theDevice.getDeviceType() == DeviceType.SENSOR){
			return "SE:" + key // if this is a sensor build an artifical key for the zone so we do not get conflict with the thermostat
		}
		
		return key
	}
	
	void processStringFromComms (String command , ReturnWrapper returnWrapper) {
		
		def partsOfCommand = command.split("=")

			try {
				def theCommand = partsOfCommand[0]
				def hvacUnit = configHelper.getControlledItem ("0")
				if (hvacUnit == null){
					logger.log (Level.WARNING,"No Advantage AIR system unit with key 0 has been defined")
					return
				}
				switch (theCommand) {
					case "OK":
						logger.log (Level.FINE,"OK received " + command )
						comms.acknowledgeCommand("",false)
						comms.sendNextCommand()
						break;

					case "ERROR":
						logger.log (Level.FINE,"ERROR received " + command )
						comms.acknowledgeCommand("",false)
						comms.sendNextCommand()
						break;
						
					case "+FRE" :
						logger.log (Level.FINE,"+FRE received " + command )

						def freParm = partsOfCommand[1]
						
						switch (freParm) {
						case "NOT INSTALLED" :
							FRESH = "NO"
							break;
						case "1" :
						    FRESH = "YES"
						    returnWrapper.addComplexFlashCommand (hvacUnit,  "fresh", "outside" )
						    break;
						case "2" :
						    FRESH = "YES"
						    returnWrapper.addComplexFlashCommand (hvacUnit,  "fresh", "recirc" )
						    break;
						case "4" :
						    FRESH = "YES"
						    returnWrapper.addComplexFlashCommand (hvacUnit,  "fresh", "auto" )
						    break;
						}                             
						                             

					case "+FIL" :
						logger.log (Level.FINE,"+FIL received " + command )

						def filParm = partsOfCommand[1].split(",")
						// Check to see if the various things are installed
						// Populate cache if they are present
						
						switch (filParm[1]) {
						case "NOT INSTALLED" :
							FILTER = "NO"
							break;
						case "1" :
							FILTER = "YES"
							returnWrapper.addComplexFlashCommand (hvacUnit,  "filter", "on" )
							FILTER_STATE = "1"
							break;
						case "0" :
							FILTER = "YES"
							returnWrapper.addComplexFlashCommand (hvacUnit,  "filter", "off" )
							FILTER_STATE = "0"
							break;
						}
						
						switch (filParm[2]) {
						case "NOT INSTALLED" :
							IONISER = "NO"
							break;
						case "1" :
							IONISER = "YES"
							returnWrapper.addComplexFlashCommand (hvacUnit,  "ioniser", "on" )
							IONISER_STATE = "1"
							break;
						case "0" :
							IONISER = "YES"
							returnWrapper.addComplexFlashCommand (hvacUnit,  "ioniser", "off" )
							IONISER_STATE = "0"
							break;
						}
						
						switch (filParm[3]) {
						case "NOT INSTALLED" :
							UV = "NO"
							break;
						case "1" :
							UV = "YES"
							returnWrapper.addComplexFlashCommand (hvacUnit,  "uv", "on" )
							UV_STATE = "1"
							break;
						case "0" :
							UV = "YES"
							returnWrapper.addComplexFlashCommand (hvacUnit,  "uv", "off" )
							UV_STATE = "0"
							break;
						}
						
					case "+ZST" :
						logger.log (Level.FINE,"+ZST received " + command )
						def zstParm = partsOfCommand[1].split(",")
						def thermostat = configHelper.getControlledItem (zstParm[0])
						if (thermostat != null )
						{	
							def zoneMode = ""
							def zonePosition = ""
							
							// Deal with the Zone Mode
							if (zstParm[1] == "1") zoneMode = "auto" else zoneMode = "manual"
							
							// Deal with the Zone Set Point
							def setPointStr = zstParm[2]
							def setPoint = setPointStr.toInteger() / 100
							
							// Deal with the Zone Position
							if (zstParm[3] == "1") zonePosition = "open" else zonePosition = "closed"
							

							
							returnWrapper.addComplexFlashCommand (thermostat,  "mode", zoneMode )
							returnWrapper.addComplexFlashCommand (thermostat,  "position", zonePosition )
							returnWrapper.addComplexFlashCommand (thermostat,  "set", setPoint )

						}
						
						def thermometer = configHelper.getControlledItem ("SE:"+zstParm[0])
						if (thermometer != null )
						{	
							// Deal with the Current Zone Temperature
							def currentTempStr = zstParm[4]
							def currentTemp = currentTempStr.toInteger() / 100
							returnWrapper.addFlashCommand (thermometer,  "on", currentTemp )							
						}
						break

// SYS=[on/off],[ SystemMode],[SystemFan],[Economy],[FreshAirMode],[FilterON/OFF],[ IoniserON/OFF],[UVLightON/OFF] 
					      

					case "+SYS" :
						logger.log (Level.FINE,"+SYS received " + command )
						def sysParm = partsOfCommand[1].split(",")
						
						def sysStatus = ""
						def sysEconomy = ""
						def sysFan = ""
						def sysMode = ""
						def sysFresh = ""
						def sysFilter = ""
						def sysIoniser = ""
						def sysUV = ""
							
						// Deal with System Status
						if (sysParm[0] == "1")  sysStatus = "on"  else  sysStatus = "off"

						// Deal with the System Mode
						def sysModeModes = sysParm[1]
						switch (sysModeModes) {
							case "1" :
								sysMode = "cool"
								break;
							case "2" :
								sysMode = "heat"
								break;
							case "3" :
								sysMode = "vent"
								break;
							case "4" :
								sysMode = "auto"
								break;
							}
						
						// Deal with the Fan Modes
						def sysFanModes = sysParm[2]
						switch (sysFanModes) {
						case "1" :
							sysFan = "low"
							break;
						case "2" :
							sysFan = "medium"
							break;
						case "3" :
							sysFan = "high"
							break;
						}

						// Deal with Economy Mode
						def sysEconomyMode = sysParm[3]
						switch (sysEconomyMode) {
						case "1" :
							sysEconomy = "on"
							break;
						case "0" :
							sysEconomy = "off"
							break;
						}
						

							
						// Deal with the Fresh Air Modes
						def sysFreshModes = sysParm[4]
						switch (sysFreshModes) {
						case "1" :
							sysFresh = "outside"
							break;
						case "2" :
							sysFresh = "recirc"
							break;
						case "4" :
							sysFresh = "auto"
							break;
						}
						
						// TODO: Check what comes back if these options are not present
						// Deal with the Filter Modes
						def sysFilterModes = sysParm[5]
						switch (sysFilterModes) {
						case "1" :
							sysFilter = "on"
							FILTER_STATE = "1"
							break;
						case "0" :
							sysFilter = "off"
							FILTER_STATE = "0"
							break;
						}
							

							
						// Deal with the UV Modes
						def sysUVModes = sysParm[7]
						switch (sysUVModes) {
						case "1" :
							sysUV = "on"
							UV_STATE = "1"
							break;
						case "0" :
							sysUV = "off"
							UV_STATE = "0"
							break;
						}
							
						returnWrapper.addComplexFlashCommand (hvacUnit,  sysStatus )
						returnWrapper.addComplexFlashCommand (hvacUnit,  "mode", sysMode )
						returnWrapper.addComplexFlashCommand (hvacUnit,  "fan", sysFan )
						returnWrapper.addComplexFlashCommand (hvacUnit,  "fresh", sysFresh )
						returnWrapper.addComplexFlashCommand (hvacUnit,  "filter", sysFilter )
						returnWrapper.addComplexFlashCommand (hvacUnit,  "economy", sysEconomy )
						// not implemented by advantage air returnWrapper.addComplexFlashCommand (hvacUnit,  "ioniser", sysIoniser )
						returnWrapper.addComplexFlashCommand (hvacUnit,  "uv", sysUV )
						break
					default:
					logger.log (Level.WARNING,"An unknown command was sent from the Advantage Air controller " + command)
				}			
			} catch (IndexOutOfBoundsException ex) {
				logger.log (Level.WARNING,"The string from Advantage Air was incorrectly formatted " + command)
			} catch (NumberFormatException ex) {
				logger.log (Level.WARNING,"The string from Advantage Air was incorrectly formatted " + command)
			}
	}



	void buildUnitControlString (Unit device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {

		boolean foundCommand = false
		
		// To switch on the HVAC system requires a string "SRU=1"
		if (command.getCommandCode() == "on") {
			returnWrapper.addCommOutput ("SRU=1")
			return;
		}
		
		// To switch off the HVAC system requires a string "SRU=0"
		if (command.getCommandCode() == "off") {
			returnWrapper.addCommOutput ("SRU=0")
			return;
		}
		
		// To set the HVAC fan speed requires a string "SFA=[SPEED]"
		if (command.getCommandCode() ==  "fan") {
			switch (command.getExtraInfo() ) {
			case "low" :
				returnWrapper.addCommOutput ("ZFA=1")
				foundCommand =true
				break;
			case "medium" :
				returnWrapper.addCommOutput ("ZFA=2")
				foundCommand =true
				break;
			case "high" :
				returnWrapper.addCommOutput ("ZFA=3")
				foundCommand =true
				break;
			default :
				logger.log (Level.WARNING,"Invalid HVAC fan speed " + command )
			}
			if (foundCommand) return;

		}
		
		// To set the HVAC mode requires a string "SMO=[MODE]"
		if (command.getCommandCode() ==  "mode") {
			switch (command.getExtraInfo() ) {
			case "cool" :
				returnWrapper.addCommOutput ("SMO=1")
				foundCommand =true
				break;
			case "heat" :
				returnWrapper.addCommOutput ("SMO=2")
				foundCommand =true
				break;
			case "vent" :
				returnWrapper.addCommOutput ("SMO=3")
				foundCommand =true
				break;
			case "auto" :
				returnWrapper.addCommOutput ("SMO=4")
				foundCommand =true
				break;
			default :
				logger.log (Level.WARNING,"Invalid HVAC Mode " + command )
			}
			if (foundCommand) return;
		}
		
		// To set the HVAC fresh air mode requires a string "FRE=[MODE]"
		if (command.getCommandCode() ==  "fresh") {
			if (FRESH == "YES") {
				switch (command.getExtraInfo() ) {
				case "outside" :
					returnWrapper.addCommOutput ("FRE=1")
					foundCommand =true
					break;
				case "recirc" :
					returnWrapper.addCommOutput ("FRE=2")
					foundCommand =true
					break;
				case "auto" :
					returnWrapper.addCommOutput ("FRE=4")
					foundCommand =true
					break;
				default :
					logger.log (Level.WARNING,"Invalid  fresh air HVAC Mode " + command )
				}
			}
			else {
				logger.log (Level.WARNING,"Command for non-installed Fresh Air Unit received " + command )

			}
			if (foundCommand) return;
		}
			
		
		// To set the HVAC filter mode requires a string "FIL=[FilterON/OFF],[IoniserON/OFF],[UVLightON/OFF]"
		if (command.getCommandCode() ==  "filter") {
			if ( FILTER == "YES" || FILTER_STATE != "" ) {
				switch (command.getExtraInfo() ) {
				case "on" :
					returnWrapper.addCommOutput ( "FIL=1," + IONISER_STATE + "," + UV_STATE )
					foundCommand =true
					break;
				case "off" :
					returnWrapper.addCommOutput ("FIL=0," + IONISER_STATE + "," + UV_STATE )
					foundCommand =true
					break;
				default :
					logger.log (Level.WARNING,"Invalid filter command " + command )
				}
			}
			else {
				logger.log (Level.WARNING,"Command for non-installed Filter Unit received or unknown state " + command )
			}
			if (foundCommand) return;
		}
		
		if (command.getCommandCode() ==  "ioniser") {
			if ( IONISER == "YES" || IOSISER_STATE != "" ) {
				switch (command.getExtraInfo() ) {
				case "on" :
					returnWrapper.addCommOutput ( "FIL=" + FILTER_STATE + ",1," + UV_STATE )
					foundCommand =true				
					break;
				case "off" :
					returnWrapper.addCommOutput ( "FIL=" + FILTER_STATE + ",0," + UV_STATE )
					foundCommand =true
					break;
				default :
					logger.log (Level.WARNING,"Invalid ioniser command " + command )
				}
			}
			else{
				logger.log (Level.WARNING,"Command for non-installed Ioniser Unit received or unknown state " + command )
			}
			if (foundCommand) return;
		}
		
		if (command.getCommandCode() ==  "uv") {
			if ( UV == "YES" || UV_STATE != "" ) {
				switch (command.getExtraInfo() ) {
				case "on" :
					returnWrapper.addCommOutput ( "FIL=" + FILTER_STATE + "," + IONISER_STATE + ",1" )
					foundCommand =true
					break;
				case "off" :
					returnWrapper.addCommOutput ( "FIL=" + FILTER_STATE + "," + IONISER_STATE + ",0" )
					foundCommand =true
					break;
				default :
					logger.log (Level.WARNING,"Invalid uv command " + command )
				}
			}
			else{
				logger.log (Level.WARNING,"Command for non-installed UV Unit received or unknown state " + command )
			}
			if (foundCommand) return;
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
	
