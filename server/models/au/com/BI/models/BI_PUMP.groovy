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


/**
   This demonstration shows the basic pattern for groovy models.
   
   This system is an example of a controller that can set a temperature for a heater, read current temperature and control a pump.
   
   The model contains various functions that are called by the system during operations.
   
   On startup the system will call doStartup()  ,this should contain any required commands to put the device in a state for communications with eLife.
   
   When instructions are received from the device  the model's processStringFromComms method is called. This is where you will process instructions 
   and usually send the appropriate message to the flash client.
   
   When instructions are received from the flash client the models doOutputItem method is called.
   
   This model expects the device to send OK after processing every command and will send AU_STARTED after completion of a startup initialisation
   
   The commands to and from flash (or scripts) are similar to below
   <CONTROL KEY="POOL_PUMP" COMMAND="off" EXTRA="" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />    
               produced device command PUMP_PWR:2:0
               
     device command CURRENT_TEMP:1:40 produces
     <CONTROL KEY="POOL_TEMP" COMMAND="on" EXTRA="75" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
       
     <CONTROL KEY="POOL_TEMP" COMMAND="set" EXTRA="75" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
              produces  device command  TEMP_SET1:40

**/

class BI_PUMP extends GroovyModel {

	// Our audio device expects 2 characters to specify the zone 
	int keyPadding = 2;
	String name = "BI_PUMP"
	String appendToSentStrings = "\n"


	
	BI_PUMP () {
		super()
		setIPHeartbeat(false)
		// We will be polling so do not need an artificial heartbeat to keep IP connections alive
		
		setQueueCommands(true) 
		// Set the default behaviour for comms commands to be queued before sending. 
		// Can be overridden for each returnWrapper object by calling returnWrapper.setQueueCommands(true|false)

	}
	
	public void doStartup(ReturnWrapper returnWrapper) {
		// Any instructions that should be set up the device for communication should be included here.
		// This method is called after connection is made to the device

		returnWrapper.addCommOutput ("AU_STARTUP_FIRST")
		returnWrapper.addCommOutput ("AU_STARTUP_SECOND")

	}


	public void doPoll(ReturnWrapper returnWrapper) {
		// This method is called each time the poll time occurs
		// At the simplest this method may just send a known string, for more complex polling the system may iterate through all configured items and query each one
		// independantly.
		
		returnWrapper.addCommOutput ("AU_GET_STATE");
	}
	
	public void doRestOfStartup(ReturnWrapper returnWrapper) {
		// This method is called by the script, after receiving confirmation that the initial startup has been successful.
		// Typically this would be where each device line from the configuration file is queried for its initial state.
		// If there is no initial setup requirements for the device these instructions could be placed in the doStartup method instead.
		
		def theDeviceList = configHelper.getAllControlledDeviceObjects ()
		for (i in theDeviceList){

			if (i.getDeviceType() == DeviceType.PUMP){
				returnWrapper.addCommOutput  ("PUMP_STATE_QUERY:" + i.getKey() )
				// query the state of all pump devices that have been listed in the configuration file
			}
			
			if (i.getDeviceType() == DeviceType.THERMOSTAT){
				returnWrapper.addCommOutput  ("GET_CURRENT_TEMP:" + i.getKey() )
				// query the current temperatures of all thermo devices that have been listed in the configuration file
				
				// The temperature type could also be used to store checkpoint information, in which case the value returned would be the checkpoint setting
			}
			

		}
		
		// Usually polling is started once startup has been completed
		enablePoll (3) 
		// The string will be sent every 3 seconds. Times less than around 3-5 seconds should not be used as most devices take around that long to respond, particularly if they are busy
	}
	
	void processStringFromComms (String command , ReturnWrapper returnWrapper) {

		def matcher = command =~ /(OK|PUMP_PWR|CURRENT_TEMP|AU_STARTED):?(\d*):?(\d*)/
		 //  For details on groovy regular expressions see   http://groovy.codehaus.org/Tutorial+4+-+Regular+expressions+basics
		
		 // For example
		 // CURRENT_TEMP:5:12    = temperature sensor at channel 5 sent a reading of 12, this will probably need translating into 0-100
		 // PUMP_PWR:1:0  = The pump device on channel 1 sent a 0 which could mean the pump has been switched off.
	
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
						
					case "CURRENT_TEMP" :
						def zone = matcher[0][2]
						      				// The zone will be used to look up the key field that is specified in the configuration file to refer to each temperature channel
						      				                  		
						 def value = matcher[0][3]
						 def temperatureSensor = configHelper.getControlledItem (zone)

						 if (temperatureSensor == null){
							 logger.log (Level.INFO,"An instruction received for a temperature sensor that has not been configured " + zone)
						 } else {
								def scaledTemp = Utility.scaleForFlash(value,-20,60,false);
								// the raw temperature from the device must be scaled to 0-100 for flash; assume -20 - 60 is being mapped into 0-100
								// The final false parameter tells the scaler not to invert the scale for display, in other words 60=100, rather than -20=100
								// The scaler returns an integer so it must be converted to a string.
								
								returnWrapper.addFlashCommand (buildCommandForFlash (temperatureSensor,  "on", scaledTemp.toString()) )	
						 }
						break
					
					case "PUMP_PWR"  :
						def zone = matcher[0][2]
							      				// The zone will be used to look up the key field that is specified in the configuration file to refer to each pump
							      				                  		
						def param = matcher[0][3]
						def pump = configHelper.getControlledItem (zone)
						 if (pump == null){
							 logger.log (Level.INFO,"An instruction received for a pump channel that has not been configured " + zone)
						 } else {
																	
							if (param  == "0" ) {
								returnWrapper.addFlashCommand (buildOffCommandForFlash (pump)  )
							} else {
								returnWrapper.addFlashCommand (buildCommandForFlash (pump,  "on") )	
							}	
						 }
						break
						
					default:
						logger.log (Level.WARNING,"An unknown command was sent from flash to the pump controller" )
				}			
			} catch (IndexOutOfBoundsException ex) {
				logger.log (Level.WARNING,"The string from the pump controller device was incorrectly formatted " + command)
			}
		} else {
			logger.log (Level.WARNING,"The string from the pump controller device was incorrectly formatted " + command)
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