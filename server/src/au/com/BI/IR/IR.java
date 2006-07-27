/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.IR;
import au.com.BI.Util.*;
import au.com.BI.Device.DeviceType;
import au.com.BI.Dynalite.*;
import au.com.BI.Command.*;
import au.com.BI.GC100.IRCommand;


/**
 * @author Colin Canfield
 *
 **/
public class IR extends BaseDevice implements DeviceType,DynaliteInputDevice
{
	protected int box = 0; // used for Dynalite IR input
	
	public IR (String name, int deviceType, String outputKey){
		super (name,deviceType,outputKey);
	}
	

	/**
	 * Returns a display command represented by the light object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		IRCommand iRCommand = new IRCommand ();
		iRCommand.setDisplayName(getOutputKey());
		return iRCommand;
	}
	public boolean keepStateForStartup () {
		return false;
	}
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
