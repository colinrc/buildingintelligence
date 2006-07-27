package au.com.BI.models;

import au.com.BI.Util.*
import au.com.BI.Command.*
import au.com.BI.GroovyModels.*
import au.com.BI.Lights.*
import au.com.BI.AV.AV
import au.com.BI.Audio.Audio
import au.com.BI.Sensors.Sensor
import au.com.BI.CustomInput.CustomInput 
import au.com.BI.Analog.Analog
import au.com.BI.Camera.Camera
import au.com.BI.ToggleSwitch.ToggleSwitch
import au.com.BI.PulseOutput.PulseOutput
import au.com.BI.Util.DeviceModel
// Include this block in all models

 class DMX  extends GroovyModel  {
		// All models must extend GroovyModel
		
		String name = "DMX"
		// This name corresponds with the DEVICE name in the configuration file
		
		String version="1.0"
		// The version will be reported back to the Flash client to assist in debugging model problems

		// DevicesControlled = [LightFascade:List]
		// This will provide a list of devices supported by the model, it will be used by the admin GUI to determine the input list
			
		/*
		   In this section the method to build the codes to be sent to the physical device based on the representation in the configuration will be built. 
		   Fill in the section for the device your model controls.
		*/
		
		void buildLightString (LightFascade device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {
				if (command.getCommandCode () == "on") {
					// build on string
					lightLevel = paramToInt (command, EXTRA, 0, 255, "The light level is incorrect");
					lightRate= paramToInt (command, EXTRA2, 0, 255, "The fade rate is incorrect");
					
					returnWrapper.addCommOutput( device.getKey() + " " +  lightLevel  + " " + lightRate + "\n");
				} else {
					// build off string
					returnWrapper.addCommOutput( device.getKey() + " 0 0\n" );
				}
		}

		
		
	}
