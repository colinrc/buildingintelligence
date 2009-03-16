/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.Label;
import au.com.BI.Util.*;
import au.com.BI.CBUS.CBUSDevice;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;



/**
 * @author Colin Canfield
 * Labels are used to represent devices that can dynamically change their displayed text or image.
 * For example CBUS DLT switches.
 * 
 **/

public class Label extends BaseDevice implements DeviceType, CBUSDevice
{
	protected String defaultLabel = "";
	protected String applicationCode = "38";	
	protected boolean relay = false;
	protected int max = 255;
	protected boolean  generateDimmerVals = true;
	
	public Label (String name, int deviceType){
		super (name,deviceType);
		this.command = "";
		this.outputKey = "";
	}
	public boolean keepStateForStartup () {
		return false;
	}
	public int getDeviceType ()
	{
		return DeviceType.LABEL;
	}

	/**
	 * Returns a display command represented by the alert object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		LabelCommand alertCommand = new LabelCommand ();
		alertCommand.setDisplayName(this.getOutputKey());
		return alertCommand;
	}
	public String getDefaultLabel() {
		return defaultLabel;
	}
	public void setDefaultLabel(String defaultLabel) {
		this.defaultLabel = defaultLabel;
	}
	public String getApplicationCode() {
		return applicationCode;
	}
	public void setApplicationCode(String cbusApplication) {
		if (cbusApplication != null && cbusApplication.equals("")){
			this.applicationCode = cbusApplication;
		}
	}
	public int getMax() {
		return max;
	}
	public void setMax(int max) {
		this.max = max;
	}
	
	public boolean isRelay() {
		return relay;
	}
	
	public boolean supportsLevelMMI() {
		return true;
	}
	
	public boolean isAreaDevice () {
		return false;
	}
	public boolean isGenerateDimmerVals() {
		return generateDimmerVals;
	}
	public void setGenerateDimmerVals(boolean generateDimmerVals) {
		this.generateDimmerVals = generateDimmerVals;
	}

}
