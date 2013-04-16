/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.Unit;
import au.com.BI.Util.*;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;



/**
 * @author Colin Canfield
 *
 **/
public class Unit extends BaseDevice implements DeviceType
{	
	public Unit (String name, int deviceType){
		super (name,deviceType);
		this.command = "";
		this.outputKey = "";
	}
	public boolean keepStateForStartup () {
		return false;
	}
	public int getDeviceType ()
	{
		return DeviceType.UNIT;
	}


	/**
	 * Returns a display command represented by the alert object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		UnitCommand alertCommand = new UnitCommand ();
		alertCommand.setDisplayName(this.getOutputKey());
		return alertCommand;
	}

}
