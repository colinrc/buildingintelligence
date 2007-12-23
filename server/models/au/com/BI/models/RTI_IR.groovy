package au.com.BI.models;

import au.com.BI.Util.*
import au.com.BI.Command.*
import au.com.BI.GroovyModels.*
import java.util.logging.Level
import au.com.BI.Config.ParameterException
import au.com.BI.Device.DeviceType
import au.com.BI.Unit.Unit
import java.util.regex.Matcher
import java.util.regex.Pattern


class RTI_IR extends GroovyModel {

	String name = "RTI_IR"
	String version = "1"
		
	RTI_IR () {
		super()

	}
	

	void processStringFromComms (String command , ReturnWrapper returnWrapper) {

		def partsOfCommand = command.split("=")

			try {

				def theCommand = partsOfCommand[0]
				def rtiUnit = configHelper.getControlledItem ("0")
				switch (theCommand) {
				
				// Deal with the standard BIRTI commands - eg: BIRTI=control,LOUNGE_LIGHT,on,foo 
				case "BIRTI" :

					logger.log (Level.FINE,"BIRTI received " + command )
					
					// Deal with the RTI commands [control|runmacro|stopmacro]
					def birtiParm = partsOfCommand[1].split(",")
					def rtiPart1 = birtiParm[0]
					def rtiPart2 = birtiParm[1]
					
					if (birtiParm.length > 5 ) {
						logger.log (Level.WARNING,"Too many parameters for RTI model " + command )
						break;
					}	
					
					switch (rtiPart1) {
					
					// control is used to send eLIFE commands
					case "control" :
						switch (birtiParm.length) {
						case "5":
							//Example BIRTI=control,LOUNGE_AUDIO,src,radio,AV
							def commandStr = birtiParm[2]
							def extraStr = birtiParm[3]
							def extra2Str = birtiParm[4]
							//Injects a command into the queue as if it came from a flash client.
							// Do not use this command to send to a DISPLAY_NAME that this model is processing in doOutputItems, or else a loop will result.
							returnWrapper.injectCommand (rtiPart2,commandStr,extraStr,extra2Str)
						break
						
						case "4":
							//Example BIRTI=control,LOUNGE_AUDIO,volume,up
							def commandStr = birtiParm[2]
							def extraStr = birtiParm[3]
							//Injects a command into the queue as if it came from a flash client.
							// Do not use this command to send to a DISPLAY_NAME that this model is processing in doOutputItems, or else a loop will result.
							returnWrapper.injectCommand (rtiPart2,commandStr,extraStr)
						break;

						default:
							// Example BIRTI=control,LOUNGE_LIGHT,on
							def commandStr = birtiParm[2]
							
							// returnWrapper.addFlashCommand (rtiPart2, commandStr)
							returnWrapper.injectCommand (rtiPart2,commandStr)
						break;
						}
						
					// runmacro is used to start eLIFE macros
					case "runmacro" :
						// Example BIRTI=runmacro,fred
						// returnWrapper.addFlashCommand ("MACRO" , "run" , rtiPart2 )
						
						// Fill this command structure in if you want to pass any parameters to the macro being run.
						Command commandForMacro = new Command();
						// commandForMacro.setCommand("");
						//   commandForMacro.setExtraInfo(""");

						macroHandler.run (rtiPart2,null, commandForMacro)
						break;
						
					case "stopmacro" :
						//Example BIRTI=stopmacro,fred
						//returnWrapper.addFlashCommand ("MACRO" , "stop" , rtiPart2 )
						macroHandler.abort (rtiPart2,null)
						break;
					}

					break;

				default :
					logger.log (Level.WARNING,"Unexpected string received " + command )
				}

			} catch (IndexOutOfBoundsException ex) {
				logger.log (Level.WARNING,"The string from RTI was incorrectly formatted " + command)
			} catch (NumberFormatException ex) {
				logger.log (Level.WARNING,"The string from RTI was incorrectly formatted " + command)
			}

	}
}

