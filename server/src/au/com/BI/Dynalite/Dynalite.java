/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.Dynalite;
import au.com.BI.Util.*;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;
import au.com.BI.Lights.*;

/*
 * @TODO store previous light level; an ON with no ramp will use this level
 */


/**
 * @author Colin Canfield 
 *
 **/
public class Dynalite extends BaseDevice implements LightDevice,DeviceType,DynaliteDevice,DynaliteInputDevice
{
	protected String areaCode = "01"; 
	protected int max = 255;
	protected String rampRate = "4";
	protected String relay = "N";
	protected int channel = 0;
	protected int box = 0;
	protected String BLA = "";
	protected int bLAInt = 255;
	protected boolean devFromLink = false;
	protected int linkCount = 0;
	protected boolean areaDevice = false;
	
	public Dynalite (String name, int deviceType){
		this.name = name;
		this.deviceType = deviceType;
		this.command = "";
		this.outputKey = "";
	}
	

	/**
	 * Returns a display command represented by the light object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		DynaliteCommand cBUSCommand = new DynaliteCommand ();
		cBUSCommand.setDisplayName(getOutputKey());
		return cBUSCommand;
	}

	/**
	 * @return Returns the areaCode.
	 */
	public String getAreaCode() {
		return areaCode;	
	}
	/**
	 * @param areaCode The areaCode to set.
	 */
	public void setAreaCode(String areaCode) {
		if (areaCode == null) {
			areaCode  = "01";
			this.areaCode = areaCode;
			return;
		}
			
		if (areaCode.length() == 1) {
			areaCode  = "0"+ areaCode;
			this.areaCode = areaCode;
			return;
		}
		this.areaCode = areaCode;
	}
	
	public boolean doIPHeartbeat () {
	    return false;
	}
	/**
	 * @return Returns the max.
	 */
	public int getMax() {
		return 255;
	}

	/**
	 * @return Returns the max as a string.
	 */
	public String getMaxStr() {
		return "FF";
	}



	public String getRelay() {
		return relay;
	}
	


	public void setRelay(String relay) {
		this.relay = relay;
	}
	/**
	 * Return the client display command for the light.
	 * For a light this is the same as the interpretted command
	 */
	public int getDeviceType ()
	{
		if (this.isAreaDevice())
			return DeviceType.LIGHT_DYNALITE_AREA;
		else
			return DeviceType.LIGHT_DYNALITE;
	}
	
	public boolean keepStateForStartup () {
		return true;
	}


	public int getChannel() {
		return channel;
	}


	public void setChannel(int channel) {
		this.channel = channel;
	}


	public int getBox() {
		return box;
	}


	public void setBox(int box) {
		this.box = box;
	}


	public void setMax(int max) {
		this.max = max;
	}


	public boolean isAreaDevice() {
		return areaDevice;
	}


	public void setAreaDevice(boolean areaDevice) {
		this.areaDevice = areaDevice;
	}


	public String getBLA() {
		return BLA;
	}


	public void setBLA(String bla) throws NumberFormatException{
		BLA = bla;
		bLAInt = Integer.parseInt(bla,16);
	}


	public int listensToLinkArea (int linkOffset) {
		int toLink = 255;
		
		if (this.bLAInt != 255) {
			toLink = bLAInt + linkOffset;
			if (toLink > 255) toLink = 255;
		}
		return toLink;
	}


	public boolean isLinked() {
		if (linkCount > 0) return true; else return  false;
	}

	public void incLinkCount () {
		linkCount ++;
	}
	
	public void decLinkCount () {
		if (linkCount > 0 ) linkCount --;
	}

}
