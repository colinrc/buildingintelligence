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
	
	RTI_IR () {
		super()

	}
	

	void processStringFromComms (String command , ReturnWrapper returnWrapper) {

		def partsOfCommand = command.split("=")

			try {

				def theCommand = partsOfCommand[0]
				def rtiUnit = configHelper.getControlledItem ("0")
				switch (theCommand) {
				
				// Deal with the standard BIRTI commands - eg: BIRTI=command,LOUNGE_LIGHT,on 
				case "BIRTI" :

					logger.log (Level.FINE,"BIRTI received " + command )
					
					// Deal with the RTI commands [control|runmacro|stopmacro]
					def birtiParm = partsOfCommand[1].split(",")
					def rtiPart1 = birtiParm[0]
					def rtiPart2 = birtiParm[1]
					
					if (birtiParm.length > 4 ) {
						logger.log (Level.WARNING,"Too many parameters for RTI model " + command )
						break;
					}	
					
					switch (rtiPart1) {
					
					// control is used to send eLIFE commands
					case "control" :
						if (birtiParm.length == 4 ) {
							// Example BIRTI=control,LOUNGE_AUDIO,volume,up
							def rtiPart3 = birtiParm[2]
							def rtiPart4 = birtiParm[3]
							returnWrapper.addFlashCommand (rtiPart1, rtiPart2, rtiPart3, rtiPart4)
							break;
						} else {
							// Example BIRTI=control,LOUNGE_LIGHT,on
							def rtiPart3 = birtiParm[2]
							def rtiPart4 = birtiParm[3]
							returnWrapper.addFlashCommand (rtiPart1, rtiPart2, rtiPart3)
						}
						break;
						
					// runmacro is used to start eLIFE macros
					case "runmacro" :
						// Example BIRTI=runmacro,fred
						returnWrapper.addFlashCommand ("MACRO" , "run" , rtiPart2 )
						break;
						
					case "stopmacro" :
						//Example BIRTI=stopmacro,fred
						returnWrapper.addFlashCommand ("MACRO" , "stop" , rtiPart2 )
						break;
					}

					returnWrapper.addFlashCommand (rtiUnit,  rtiCommand, rtiExtra, rtiExtra2)	
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

