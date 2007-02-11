package au.com.BI.Thermostat;

import au.com.BI.Device.DeviceType;
import au.com.BI.Util.BaseDevice;

public class Thermostat extends BaseDevice implements DeviceType {
	
	public Thermostat (String name, int deviceType){
		super(name,deviceType);
	}

	public Thermostat (String name, int deviceType, String outputKey){
		super(name,deviceType,outputKey);
	}


	public boolean keepStateForStartup () {
		return false;
	}
}
