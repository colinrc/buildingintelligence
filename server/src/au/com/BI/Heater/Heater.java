/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.Heater;
import au.com.BI.Util.*;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;



/**
 * @author Colin Canfield
 *
 **/
public class Heater extends BaseDevice implements DeviceType
{	
	int thermostat;
	boolean activated = false;
	
	public Heater (String name, int deviceType){
		super (name,deviceType);
		this.command = "";
		this.outputKey = "";
		this.thermostat = 0;
	}
	
	public boolean keepStateForStartup () {
		return false;
	}

	public int getDeviceType ()
	{
		return DeviceType.HEATER;
	}


	/**
	 * Returns a display command represented by the alert object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		HeaterCommand alertCommand = new HeaterCommand ();
		alertCommand.setDisplayName(this.getOutputKey());
		return alertCommand;
	}
	
	public int getThermostat() {
		return thermostat;
	}
	
	public void setThermostat(int thermostat) {
		this.thermostat = thermostat;
	}

	public boolean isActivated() {
		return activated;
	}

	public void setActivated(boolean activated) {
		this.activated = activated;
	}

}
