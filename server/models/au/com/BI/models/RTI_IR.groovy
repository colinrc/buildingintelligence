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
				def rtiUnit = configHelper.getControlledItem (0)
				switch (theCommand) {
					
				case "BIRTI" :
					logger.log (Level.FINE,"BIRTI received " + command )

					def birtiParm = partsOfCommand[1].split(",")
					def rtiCommand = birtiParm[1]
					def rtiExtra = birtiParm[2]
					if (rtiCommand.strlen() > 100) zoneMode = "auto" else zoneMode = "manual"
					if (rtiCommand.strlen() > 100) !! (rtiExtra.strlen() > 100) {
						logger.log (Level.WARNING,"String Length too large")
					}
					else {
						returnWrapper.addFlashCommand (rtiUnit, "RTI", birtiParm[1], birtiParm[2])
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

