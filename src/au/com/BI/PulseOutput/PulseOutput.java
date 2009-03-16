/*
 * Created on Sep 9, 2004
 *
 */
package au.com.BI.PulseOutput;
import au.com.BI.Util.*;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;




/**
 * @author Colin Canfield
 *
 **/
public class PulseOutput extends BaseDevice implements  DeviceType 
{
	protected int max = 255;
	
	public PulseOutput (String name, int deviceType,String outputKey, int max){
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
		return DeviceType.PULSE_OUTPUT;
	}


	/**
	 * Returns a display command represented by the pulise output object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		PulseOutputCommand counterCommand = new PulseOutputCommand ();
		counterCommand.setDisplayName(this.getOutputKey());
		return counterCommand;
	}
	
	public CommandInterface buildDisplayCommand (String theKey) {
	    PulseOutputCommand pulseOutputCommand = new PulseOutputCommand ();
	    pulseOutputCommand.setDisplayName(this.getOutputKey());
		return pulseOutputCommand;
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
