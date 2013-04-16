/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.Counter;
import au.com.BI.Util.*;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;




/**
 * @author Colin Canfield
 *
 **/
public class Counter extends BaseDevice implements  DeviceType 
{
	protected int max;
	
	public Counter (String name, int deviceType,String outputKey, int max){
		super (name,deviceType,outputKey);
		this.max = max;
	}

	public boolean keepStateForStartup () {
		return false;
	}
	/**
	 * Return the client display command for the toggleSwitch.
	 * For a counter this is the same as the interpretted command
	 */
	public int getDeviceType ()
	{
		return DeviceType.COUNTER;
	}


	/**
	 * Returns a display command represented by the light object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		CounterCommand counterCommand = new CounterCommand ();
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
