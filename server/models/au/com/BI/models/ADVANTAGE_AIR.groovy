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


class ADVANTAGE_AIR extends GroovyModel {

	String name = "ADVANTAGE_AIR"
	String appendToSentStrings = "\n"

	
	ADVANTAGE_AIR () {
		super()
		
		setQueueCommands(true) 

	}
	
	public void doStartup(ReturnWrapper returnWrapper) {

		returnWrapper.addCommOutput ("ASU=1")
		returnWrapper.addCommOutput ("RCS=?")
		def theDeviceList = configHelper.getAllControlledDeviceObjects ()
		for (i in theDeviceList){
			
			if (i.getDeviceType() == DeviceType.THERMOSTAT){
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

					case "+ZST" :
						logger.log (Level.FINE,"ZST received " + command )
						def parameters = partsOfCommand[1].split(",")
						def temperatureSensor = configHelper.getControlledItem (parameters[0])
						if (temperatureSensor != null )
						{	
							def zoneMode = ""
							def zonePosition = ""
							
							if (parameters[1] == "1") zoneMode = "auto" else zoneMode = "manual"
							
							def setPointStr = parameters[2]
							def setPoint = setPointStr.toInteger() / 100
							
							if (parameters[3] == "1") zonePosition = "open" else zonePosition = "closed"
							
							def currentTempStr = parameters[4]
							def currentTemp = currentTempStr.toInteger() / 100
							
							//returnWrapper.addFlashCommand(temperatureSensor,"on",currentTemp.toString(),zoneMode,zonePosition,setPoint.toString())
							returnWrapper.addFlashCommand (temperatureSensor,  "mode", zoneMode )
							returnWrapper.addFlashCommand (temperatureSensor,  "position", zonePosition )
							returnWrapper.addFlashCommand (temperatureSensor,  "set", setPoint )
							returnWrapper.addFlashCommand (temperatureSensor,  "on", currentTemp )
						}
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


	void buildPumpControlString (Pump device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {
		// receives a message from flash and builds the appropriate string for the audio device
		
		// To switch on the pump  device it requieres a string of this format      PUMP_PWR:zone:on or PUMP_PWR:zone:off
		if (command.getCommandCode() ==  "on") {
			returnWrapper.addCommOutput  ("PUMP_PWR:" + device.getKey() + ":1")
		}
		
		if (command.getCommandCode() == "off") {
			returnWrapper.addCommOutput ("PUMP_PWR:" + device.getKey() + ":0")
		}

	}

	void buildThermostatControlString (Thermostat device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {
		// receives a message from flash and builds the appropriate string for the audio device
		
		// To switch on the audio device it requieres a string of this format      AU_PWR:zone:on or AW_PWR:zone:off
		if (command.getCommandCode() ==  "set") {
			def scaledVal =  Utility.scaleFromFlash(command.getExtraInfo(),-20,60,false)
			returnWrapper.addCommOutput  ("TEMP_SET" + device.getKey() + ":" + scaledVal)
		}
	}

}