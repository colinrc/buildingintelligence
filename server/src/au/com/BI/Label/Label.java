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
 *
 **/
public class Label extends BaseDevice implements DeviceType, CBUSDevice
{
	protected String name="";
	protected String command="";
	protected String defaultLabel = "";
	protected String applicationCode = "38";
	protected int max = 100;
	
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

	public String getCommand () {
		return command;
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
		return false;
	}
	
	public boolean supportsLevelMMI() {
		return false;
	}
	
	public boolean isAreaDevice () {
		return false;
	}

}
