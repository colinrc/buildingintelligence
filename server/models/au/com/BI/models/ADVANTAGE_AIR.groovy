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
			
			if (i.getDeviceType() == DeviceType.THERMOSTAT && i.getKey() != 0){
				returnWrapper.addCommOutput  ("ZST=" + i.getKey() )
			}
		}
	}
	
	void processStringFromComms (String command , ReturnWrapper returnWrapper) {
		
		def partsOfCommand = command.split("=")

			try {
				def theCommand = partsOfCommand[0]
				switch (theCommand) {
					case "OK":
						// The last command has been acknowledged by the device so now send the next one
						comms.acknowledgeCommand("")
						comms.sendNextCommand()
						break;

					case "+FRE" :
						logger.log (Level.FINE,"FRE received " + command )

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
						                             
						                             
						if (freParm == "NOT INSTALLED") FRESH = "NO" else FRESH = "YES"
						// Colin: The above line needs to set a variable that can be checked for later to ensure
						// we don't send commands to a non existing feature.
						// CC:Moved to model wide scope; ie. not inside a particular method.
					
					case "+FIL" :
						logger.log (Level.FINE,"FIL received " + command )

						def filParm = partsOfCommand[1].split(",")
						// Check to see if the various things are installed
						
						switch (filParm[1]) {
						case "NOT INSTALLED" :
							FILTER = "NO"
							break;
						case "1" :
							FILTER = "YES"
							returnWrapper.addFlashCommand (hvacUnit,  "filter", "on" )
							break;
						case "0" :
							FILTER = "YES"
							returnWrapper.addFlashCommand (hvacUnit,  "filter", "off" )
							break;
						}
						
						switch (filParm[2]) {
						case "NOT INSTALLED" :
							IONISER = "NO"
							break;
						case "1" :
							IONISER = "YES"
							returnWrapper.addFlashCommand (hvacUnit,  "ioniser", "on" )
							break;
						case "0" :
							IONISER = "YES"
							returnWrapper.addFlashCommand (hvacUnit,  "ioniser", "off" )
							break;
						}
						
						switch (filParm[3]) {
						case "NOT INSTALLED" :
							UV = "NO"
							break;
						case "1" :
							UV = "YES"
							returnWrapper.addFlashCommand (hvacUnit,  "uv", "on" )
							break;
						case "0" :
							UV = "YES"
							returnWrapper.addFlashCommand (hvacUnit,  "uv", "off" )
							break;
						}
						
					case "+ZST" :
						logger.log (Level.FINE,"ZST received " + command )
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
							
							//returnWrapper.addFlashCommand(temperatureSensor,"on",currentTemp.toString(),zoneMode,zonePosition,setPoint.toString())
							returnWrapper.addFlashCommand (temperatureSensor,  "mode", zoneMode )
							returnWrapper.addFlashCommand (temperatureSensor,  "position", zonePosition )
							returnWrapper.addFlashCommand (temperatureSensor,  "set", setPoint )
							returnWrapper.addFlashCommand (temperatureSensor,  "on", currentTemp )
						}
						break
						
					case "+SYS" :
						logger.log (Level.FINE,"SYS received " + command )
						def sysParm = partsOfCommand[1].split(",")
						
						def sysStatus = ""
						def sysFan = ""
						def sysMode = ""
						def sysFresh = ""
						def sysFilter = ""
						def sysIoniser = ""
						def sysUV = ""
							
						// Deal with System Status
						if (sysParm[1] == "1") sysStatus = "on" else sysStatus = "off"
							
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
							
						// Deal with the System Mode
						def sysModeModes = sysParm[3]
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
						def sysFreshModes = sysParm[4]
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
							
						// Deal with the Filter Modes
						if (sysParm[5] == "1") sysFilter = "on" else sysFilter = "off"
							
						// Deal with the Ioniser Modes
						if (sysParm[6] == "1") sysIoniser = "on" else sysIoniser = "off"
							
						// Deal with the UV Modes
						if (sysParm[7] == "1") sysUV = "on" else sysUV = "off"
							
						returnWrapper.addFlashCommand (hvacUnit,  sysStatus )
						returnWrapper.addFlashCommand (hvacUnit,  "mode", sysMode )
						returnWrapper.addFlashCommand (hvacUnit,  "fan", sysFan )
						returnWrapper.addFlashCommand (hvacUnit,  "fresh", sysFresh )
						returnWrapper.addFlashCommand (hvacUnit,  "filter", sysFilter )
						returnWrapper.addFlashCommand (hvacUnit,  "ioniser", sysIoniser )
						returnWrapper.addFlashCommand (hvacUnit,  "uv", sysUV )
						break
					default:
					logger.log (Level.WARNING,"An unknown command was sent from the Advantage Air controller" )
				}			
			} catch (IndexOutOfBoundsException ex) {
				logger.log (Level.WARNING,"The string from Advantage Air was incorrectly formatted " + command)
			} catch (NumberFormatException ex) {
				logger.log (Level.WARNING,"The string from Advantage Air was incorrectly formatted " + command)
			}
	}


	void buildUnitControlString (Unit device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {
	// Colin: As discussed can we add a generic UNIT item to allow for system wide settings and control
	
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
			// COLIN: Is this correct? Can I check a model wide variable like this?	
			// CC: the var needs to be defined globally; ie. at the start.
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
		// Colin: This following system is very complex. We need to send a single command to the HVAC
		// with three seperatly controlled functions
		// Also check if those functions are installed via the variables above
		// Help required
		// You're right, very complex - this is basically not possible, for obvious reasons, if you don't know if something exists you can't decide whether to send it info.
		// the only way to do it; any time you receive one of the commands , run through a process similar to below.
		def tryToSendFilter = false
		
		if (command.getCommandCode() ==  "filter") {
			tryToSendFilter = true
			
			switch (command.getExtraInfo() ) {
			case "filter" :
				returnWrapper.addCommOutput ("FIL=1")
				FILTER = "YES"
				break;
				
			case "ioniser" :
				returnWrapper.addCommOutput ("FIL=2")
				IONISER = "YES"
				break;
				
			case "uv" :
				returnWrapper.addCommOutput ("FIL=4")
				UV = "YES"
				break;
			default :
				logger.log (Level.WARNING,"Invalid filter air HVAC Mode " + command )
			}
		}
		
		if (tryToSendFilter ){
			if (FIL != "" && IONISER != "" && UV != ""){
				// all have been defined, so build and send the string. Otherwise can't send anything until we know all the states.
				// 				returnWrapper.addCommOutput ("Filter=" + FIL + ",Ioniser" ....
				// can't tell from the logic above how you can tell if each filter (uv,ion,filter) is on or off.
				
			}
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