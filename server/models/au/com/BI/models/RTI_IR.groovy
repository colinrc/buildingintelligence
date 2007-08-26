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
				
				// Deal with the standard BIRTI commands - eg: BIRTI=on,3 
				case "BIRTI" :

					logger.log (Level.FINE,"BIRTI received " + command )

					def birtiParm = partsOfCommand[1].split(",")
					def rtiCommand = birtiParm[0]
					def rtiExtra = birtiParm[1]
					def rtiExtra2 = birtiParm[2]
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

