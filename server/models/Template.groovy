package models;

import au.com.BI.Device.DeviceType
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


public class Template  extends GroovyModel  {
	// All models must extend GroovyModel



	String name = "Template"
	// This name corresponds with the DEVICE name in the configuration file

	boolean deviceKeysDecimal = false 
	// If the device requires keys specified in decimal, set this to true. For most devices this should be false
	
	int padding = 2 
    // The number of digits padding for device keys.
	
	String  appendToSentStrings = "\n"
	// Any characters that should be appended to the end of strings sent to devices, generally this is used for carriage return and/or linefeed
	// This is only applicable for devices controlled by text strings, models that build numeric byte arrays to send to the device gernaly do not require this.
	
	String version="1"
	// The version will be reported back to the Flash client to assist in debugging model problems

	
	// DevicesControlled = [LightFascade:List]
	// This will provide a list of devices supported by the model, it will be used by the admin GUI to determine the input list


	/*
	     If this device requires a checksum to be added to each string or byte array ,the calculation should be coded here 
	*/
	byte[] addChecksum (byte[] orig) {
		return orig
	}
}