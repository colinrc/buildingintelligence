/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.Auxiliary;
import au.com.BI.Util.*;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;



/**
 * @author Colin Canfield
 *
 **/
public class Auxiliary extends BaseDevice implements DeviceType
{	
	public Auxiliary (String name, int deviceType){
		super (name,deviceType);
		this.command = "";
		this.outputKey = "";
	}
	public boolean keepStateForStartup () {
		return false;
	}
	public int getDeviceType ()
	{
		return DeviceType.AUXILIARY;
	}


	/**
	 * Returns a display command represented by the alert object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		AuxiliaryCommand alertCommand = new AuxiliaryCommand ();
		alertCommand.setDisplayName(this.getOutputKey());
		return alertCommand;
	}

}
