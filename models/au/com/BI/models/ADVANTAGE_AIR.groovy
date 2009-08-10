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
	String appendToSentStrings = "\n"
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
	
	void processStringFromComms (String command , ReturnWrapper returnWrapper) {
		
		def partsOfCommand = command.split("=")

			try {
				def theCommand = partsOfCommand[0]
				def hvacUnit = configHelper.getControlledItem ("0")
				switch (theCommand) {
					case "OK":
						logger.log (Level.FINE,"OK received " + command )
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
						    returnWrapper.addFlashCommand (hvacUnit,  "fresh", "outside" )
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
							returnWrapper.addFlashCommand (hvacUnit,  "filter", "on" )
							FILTER_STATE = "1"
							break;
						case "0" :
							FILTER = "YES"
							returnWrapper.addFlashCommand (hvacUnit,  "filter", "off" )
							FILTER_STATE = "0"
							break;
						}
						
						switch (filParm[2]) {
						case "NOT INSTALLED" :
							IONISER = "NO"
							break;
						case "1" :
							IONISER = "YES"
							returnWrapper.addFlashCommand (hvacUnit,  "ioniser", "on" )
							IONISER_STATE = "1"
							break;
						case "0" :
							IONISER = "YES"
							returnWrapper.addFlashCommand (hvacUnit,  "ioniser", "off" )
							IONISER_STATE = "0"
							break;
						}
						
						switch (filParm[3]) {
						case "NOT INSTALLED" :
							UV = "NO"
							break;
						case "1" :
							UV = "YES"
							returnWrapper.addFlashCommand (hvacUnit,  "uv", "on" )
							UV_STATE = "1"
							break;
						case "0" :
							UV = "YES"
							returnWrapper.addFlashCommand (hvacUnit,  "uv", "off" )
							UV_STATE = "0"
							break;
						}
						
					case "+ZST" :
						logger.log (Level.FINE,"+ZST received " + command )
						def zstParm = partsOfCommand[1].split(",")
						def temperatureSensor = configHelper.getControlledItem (zstParm[0])
						if (temperatureSensor != null )
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
							
							// Deal with the Current Zone Temperature
							def currentTempStr = zstParm[4]
							def currentTemp = currentTempStr.toInteger() / 100
							
							returnWrapper.addFlashCommand (temperatureSensor,  "mode", zoneMode )
							returnWrapper.addFlashCommand (temperatureSensor,  "position", zonePosition )
							returnWrapper.addFlashCommand (temperatureSensor,  "set", setPoint )
							returnWrapper.addFlashCommand (temperatureSensor,  "on", currentTemp )
						}
						break
						
					case "+SYS" :
						logger.log (Level.FINE,"+SYS received " + command )
						def sysParm = partsOfCommand[1].split(",")
						
						def sysStatus = ""
						def sysFan = ""
						def sysMode = ""
						def sysFresh = ""
						def sysFilter = ""
						def sysIoniser = ""
						def sysUV = ""
							
						// Deal with System Status
						if (sysParm[0] == "1")  sysStatus = "on"  else  sysStatus = "off"
							
						// Deal with the Fan Modes
						def sysFanModes = sysParm[1]
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
							
						// Deal with the System Mode
						def sysModeModes = sysParm[2]
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
							
						// Deal with the Fresh Air Modes
						def sysFreshModes = sysParm[3]
						switch (sysFreshModes) {
						case "1" :
							sysFresh = "outside"
							break;
						case "2" :
							sysFresh = "recirc"
							break;
						case "3" :
							sysFresh = "auto"
							break;
						}
						
						// TODO: Check what comes back if these options are not present
						// Deal with the Filter Modes
						def sysFilterModes = sysParm[4]
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
							
						// Deal with the Ioniser Modes
						def sysIoniserModes = sysParm[5]
						switch (sysIoniserModes) {
						case "1" :
							sysIoniser = "on"
							IONISER_STATE = "1"
							break;
						case "0" :
							sysIoniser = "off"
							IONISER_STATE = "0"
							break;
						}
							
						// Deal with the UV Modes
						def sysUVModes = sysParm[6]
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
							
						returnWrapper.addFlashCommand (hvacUnit,  sysStatus )
						returnWrapper.addFlashCommand (hvacUnit,  "mode", sysMode )
						returnWrapper.addFlashCommand (hvacUnit,  "fan", sysFan )
						returnWrapper.addFlashCommand (hvacUnit,  "fresh", sysFresh )
						returnWrapper.addFlashCommand (hvacUnit,  "filter", sysFilter )
						returnWrapper.addFlashCommand (hvacUnit,  "ioniser", sysIoniser )
						returnWrapper.addFlashCommand (hvacUnit,  "uv", sysUV )
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

		// To switch on the HVAC system requires a string "SRU=1"
		if (command.getCommandCode() == "on") {
			returnWrapper.addCommOutput ("SRU=1")
		}
		
		// To switch off the HVAC system requires a string "SRU=0"
		if (command.getCommandCode() == "off") {
			returnWrapper.addCommOutput ("SRU=0")
		}
		
		// To set the HVAC fan speed requires a string "SFA=[SPEED]"
		if (command.getCommandCode() ==  "fan") {
			switch (command.getExtraInfo() ) {
			case "low" :
				returnWrapper.addCommOutput ("ZFA=1")
				break;
			case "medium" :
				returnWrapper.addCommOutput ("ZFA=2")
				break;
			case "high" :
				returnWrapper.addCommOutput ("ZFA=3")
				break;
			default :
				logger.log (Level.WARNING,"Invalid HVAC fan speed " + command )
			}
		}
		
		// To set the HVAC mode requires a string "SMO=[MODE]"
		if (command.getCommandCode() ==  "mode") {
			switch (command.getExtraInfo() ) {
			case "cool" :
				returnWrapper.addCommOutput ("SMO=1")
				break;
			case "heat" :
				returnWrapper.addCommOutput ("SMO=2")
				break;
			case "vent" :
				returnWrapper.addCommOutput ("SMO=3")
				break;
			case "auto" :
				returnWrapper.addCommOutput ("SMO=4")
				break;
			default :
				logger.log (Level.WARNING,"Invalid HVAC Mode " + command )
			}
		}
		
		// To set the HVAC fresh air mode requires a string "FRE=[MODE]"
		if (command.getCommandCode() ==  "fresh") {
			if (FRESH == "YES") {
				switch (command.getExtraInfo() ) {
				case "outside" :
					returnWrapper.addCommOutput ("FRE=1")
					break;
				case "recirc" :
					returnWrapper.addCommOutput ("FRE=2")
					break;
				case "auto" :
					returnWrapper.addCommOutput ("FRE=4")
					break;
				default :
					logger.log (Level.WARNING,"Invalid  fresh air HVAC Mode " + command )
				}
			}
			else
				logger.log (Level.WARNING,"Command for non-installed Fresh Air Unit received " + command )
			}
		
		// To set the HVAC filter mode requires a string "FIL=[FilterON/OFF],[IoniserON/OFF],[UVLightON/OFF]"
		if (command.getCommandCode() ==  "filter") {
			if ( FILTER == "YES" || FILTER_STATE != "" ) {
				switch (command.getExtraInfo() ) {
				case "on" :
					returnWrapper.addCommOutput ( "FIL=1," + IONISER_STATE + "," + UV_STATE )
					break;
				case "off" :
					returnWrapper.addCommOutput ("FIL=0," + IONISER_STATE + "," + UV_STATE )
					break;
				default :
					logger.log (Level.WARNING,"Invalid filter command " + command )
				}
			}
			else
				logger.log (Level.WARNING,"Command for non-installed Filter Unit received or unknown state " + command )
			}
		
		if (command.getCommandCode() ==  "ioniser") {
			if ( IONISER == "YES" || IOSISER_STATE != "" ) {
				switch (command.getExtraInfo() ) {
				case "on" :
					returnWrapper.addCommOutput ( "FIL=" + FILTER_STATE + ",1," + UV_STATE )
					break;
				case "off" :
					returnWrapper.addCommOutput ( "FIL=" + FILTER_STATE + ",0," + UV_STATE )
					break;
				default :
					logger.log (Level.WARNING,"Invalid ioniser command " + command )
				}
			}
			else
				logger.log (Level.WARNING,"Command for non-installed Ioniser Unit received or unknown state " + command )
			}
		
		if (command.getCommandCode() ==  "uv") {
			if ( UV == "YES" || UV_STATE != "" ) {
				switch (command.getExtraInfo() ) {
				case "on" :
					returnWrapper.addCommOutput ( "FIL=" + FILTER_STATE + "," + IONISER_STATE + ",1" )
					break;
				case "off" :
					returnWrapper.addCommOutput ( "FIL=" + FILTER_STATE + "," + IONISER_STATE + ",0" )
					break;
				default :
					logger.log (Level.WARNING,"Invalid uv command " + command )
				}
			}
			else
				logger.log (Level.WARNING,"Command for non-installed UV Unit received or unknown state " + command )
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
