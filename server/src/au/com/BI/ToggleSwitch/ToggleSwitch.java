/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.ToggleSwitch;
import au.com.BI.Util.*;
import au.com.BI.Dynalite.*;



/**
 * @author Colin Canfield
 *
 **/
public class ToggleSwitch extends BaseDevice implements DeviceType,DynaliteInputDevice
{
	protected int box = 0; // used for dynalite
	
	public ToggleSwitch (String name, int deviceType){
		super(name,deviceType);
	}

	public ToggleSwitch (String name, int deviceType, String outputKey){
		super(name,deviceType,outputKey);
	}


	public boolean keepStateForStartup () {
		return false;
	}
	/**
	 * Return the client display command for the toggleSwitch.
	 * For a toggleSwitch this is the same as the interpretted command
	 */
	public int getClientCommand ()
	{
		return DeviceType.NA;
	}

	public int getBox() {
		return box;
	}

	public void setBox(int box) {
		this.box = box;
	}

}
