/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.Label;
import au.com.BI.Util.*;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;



/**
 * @author Colin Canfield
 *
 **/
public class Label extends BaseDevice implements DeviceType
{
	protected String name="";
	protected String command="";
	protected String defaultLabel = "";
	
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
	


}
