/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.DynamicDevice;
import au.com.BI.Util.*;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;



/**
 * @author Colin Canfield
 *
 **/
public class DynamicDevice extends BaseDevice implements DeviceType
{
	
	public DynamicDevice (String name, int deviceType){
		super (name,deviceType);
		this.command = "";
		this.outputKey = "";
	}
	public boolean keepStateForStartup () {
		return false;
	}
	public int getDeviceType ()
	{
		return DeviceType.LABEL;
	}

	public String getCommand () {
		return command;
	}

	/**
	 * Returns a display command represented by the alert object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		DynamicDeviceCommand alertCommand = new DynamicDeviceCommand ();
		alertCommand.setDisplayName(this.getOutputKey());
		return alertCommand;
	}

}
