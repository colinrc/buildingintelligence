/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.Pump;
import au.com.BI.Util.*;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;



/**
 * @author Colin Canfield
 *
 **/
public class Pump extends BaseDevice implements DeviceType
{	
	public Pump (String name, int deviceType){
		super (name,deviceType);
		this.command = "";
		this.outputKey = "";
	}
	public boolean keepStateForStartup () {
		return false;
	}
	public int getDeviceType ()
	{
		return DeviceType.PUMP;
	}


	/**
	 * Returns a display command represented by the alert object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		PumpCommand alertCommand = new PumpCommand ();
		alertCommand.setDisplayName(this.getOutputKey());
		return alertCommand;
	}

}
