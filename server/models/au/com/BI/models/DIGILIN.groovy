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


class DIGILIN extends GroovyModel {

	String name = "DIGILIN"
	String version = "1.0"
		
	DIGILIN () {
		super()

	}
	
	void buildUnitControlString (Unit device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {

		// Recall a Scene
		if (command.getCommandCode() == "on") {
			//lightScene= paramToInt (command, EXTRA, 0, 500, "The scene is incorrect");
			returnWrapper.addCommOutput (command.getExtraInfo() + "\n")

		}else {
		// build off string
			returnWrapper.addCommOutput ("0\n" );
		}
	}

}

