/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.CBUS;
import au.com.BI.Util.*;
import au.com.BI.Lights.*;
import au.com.BI.Command.*;

/*
 * @TODO store previous light level; an ON with no ramp will use this level
 */


/**
 * @author Colin Canfield
 *
 **/
public class CBUS extends BaseDevice implements LightDevice,CBUSDevice
{
	protected String applicationCode = "38";
	protected int max = 255;
	protected String rampRate = "4";
	protected String relay = "N";
	protected boolean areaDevice = false;

	
	public CBUS (String name, int deviceType){
		this.name = name;
		this.deviceType = deviceType;
		this.command = "";
		this.outputKey = "";
	}
	
	public boolean supportsLevelMMI () {
		return true;
	}
	

	/**
	 * Returns a display command represented by the light object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		CBUSCommand cBUSCommand = new CBUSCommand ();
		cBUSCommand.setDisplayName(getOutputKey());
		return cBUSCommand;
	}

	/**
	 * @return Returns the applicationCode.
	 */
	public String getApplicationCode() {
		return applicationCode;	
	}
	/**
	 * @param applicationCode The applicationCode to set.
	 */
	public void setApplicationCode(String applicationCode) {
		if (applicationCode == null) {
			applicationCode  = Byte.toString((byte)56);
			return;
		}
			
		if (applicationCode.length() == 1) {
			applicationCode  = "0"+ applicationCode;
			return;
		}
		this.applicationCode = applicationCode;
	}
	
	public boolean doIPHeartbeat () {
	    return false;
	}
	/**
	 * @return Returns the max.
	 */
	public int getMax() {
		return max;
	}
	/**
	 * @param max The max to set.
	 */
	public void setMax(int max) {
		this.max = max;
	}


	public String getRelay() {
		return relay;
	}
	


	public void setRelay(String relay) {
		this.relay = relay;
	}

	public boolean isAreaDevice() {
		return areaDevice;
	}

	public void setAreaDevice(boolean areaDevice) {
		this.areaDevice = areaDevice;
	}
	

}
