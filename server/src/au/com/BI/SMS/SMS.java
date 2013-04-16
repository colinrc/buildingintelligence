/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.SMS;
import au.com.BI.Util.*;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;



/**
 * @author Colin Canfield
 *
 **/
public class SMS extends BaseDevice implements DeviceType
{
	
	public SMS (String name, int deviceType){
		super (name,deviceType);
		this.command = "";
		this.outputKey = "";
	}
	public boolean keepStateForStartup () {
		return false;
	}
	public int getDeviceType ()
	{
		return DeviceType.SMS;
	}

	public String getCommand () {
		return command;
	}

	/**
	 * Returns a display command represented by the alert object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		SMSCommand alertCommand = new SMSCommand ();
		alertCommand.setDisplayName(this.getOutputKey());
		return alertCommand;
	}

}
