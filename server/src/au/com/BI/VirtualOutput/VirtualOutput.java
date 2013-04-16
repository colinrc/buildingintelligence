/*
 * Created on Sep 9, 2004
 *
 */
package au.com.BI.VirtualOutput;
import au.com.BI.Util.*;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;




/**
 * @author Colin Canfield
 *
 **/
public class VirtualOutput extends BaseDevice implements  DeviceType 
{
	protected int max;
	
	public VirtualOutput (String name, int deviceType,String outputKey, int max){
		super (name,deviceType,outputKey);
		this.max = max;
	}

	public boolean keepStateForStartup () {
		return false;
	}



	/**
	 * Returns a display command represented by the light object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		VirtualOutputCommand counterCommand = new VirtualOutputCommand ();
		counterCommand.setDisplayName(this.getOutputKey());
		return counterCommand;
	}
	
	/**
	 * @return Returns the mAX.
	 */
	public int getMax() {
		return max;
	}
	/**
	 * @param max The mAX to set.
	 */
	public void setMAX(int max) {
		this.max = max;
	}
}
