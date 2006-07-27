/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.Analog;
import au.com.BI.Util.*;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;



/**
 * @author Colin Canfield
 *
 **/
public class Analog extends BaseDevice implements DeviceType
{
	protected String key;
	
	public Analog (String name, int deviceType, String outputKey){
		super (name,deviceType,outputKey);
		this.outputKey = outputKey;
	}
	public boolean keepStateForStartup () {
		return false;
	}
	public int getClientCommand ()
	{
		return DeviceType.NA;
	}

	/**
	 * Returns a display command represented by the analogue object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		AnalogCommand analogueCommand = new AnalogCommand ();
		analogueCommand.setDisplayName(this.getOutputKey());
		return analogueCommand;
	}
	
	/**
	 * @return Returns the key.
	 */
	public String getKey() {
		if (key == null) return "";
		if (key.length() == 1) {
			return "0" + key;
		}
		else {
			return key;
		}
	}
	/**
	 * @param key The key to set.
	 */
	public void setKey(String key) {
		this.key = key;
	}
}
