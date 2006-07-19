package au.com.BI.DMX

import au.com.BI.Uti.DeviceType
import au.com.BI.Command.CommandInterface
import au.com.BI.GroovyModels.*
import au.com.BI.Lights.*
import au.com.BI.AV.AV
import au.com.BI.Audio.Audio
import au.com.BI.Sensor.Sensor
import au.com.BI.Analog.Analog
import au.com.BI.Camera.Camera
import au.com.BI.ToggleSwitch.ToggleSwitch
import au.com.BI.PulseOutput.PulseOutput
import au.com.BI.Util.DeviceModel
// Include this block in all models


public class DMX  extends GroovyModel  {
	// All models must extend GroovyModel
	
	@Property String name = "DMX"
	// This name corresponds with the DEVICE name in the configuration file
	
	// @Property List DevicesControlled = [LightFascade:List]
	// This will provide a list of devices supported by the model, it will be used by the admin GUI to determine the input list
	
	@Property boolean deviceKeysDecimal = false 
	// If the device requires keys specified in decimal, set this to true. For most devices this should be fast
	
	@Property int padding = 2 
    // The number of digits padding for device keys.
	
	@Property String  appendToSentStrings = "\n"
	// Any characters that should be appended to the end of strings sent to devices, generally this is used for carriage return and/or linefeed
	
	/*
	   In this section the method to build the codes to be sent to the physical device based on the representation in the configuration will be built. 
	   Fill in the section for the device your model controls.
	*/
	byte [] buildLightString (LightFascade device, CommandInterface command) {
			String retCode = "test" +  device.getKey() + "."

			return retCode.getBytes()
	}
	
	/*
	     If this device requires a checksum to be added to each string ,the calculation should be placed here 
	*/
	byte[] addChecksum (byte[] orig) {
		return orig
	}
	
	
}

