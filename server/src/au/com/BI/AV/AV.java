/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.AV;
import au.com.BI.Util.*;
import au.com.BI.Command.*;



/**
 * @author Colin Canfield
 *
 **/
public class AV extends BaseDevice implements DeviceType
{
	protected String name="";
	protected String command="";
	
	public AV (String name, int deviceType){
		super (name,deviceType);
		this.command = "";
		this.outputKey = "";
	}
	public boolean keepStateForStartup () {
		return false;
	}
	public int getClientCommand ()
	{
		return DeviceType.AV;
	}

	public String getCommand () {
		return command;
	}

	/**
	 * Returns a display command represented by the alert object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		AVCommand alertCommand = new AVCommand ();
		alertCommand.setDisplayName(this.getOutputKey());
		return alertCommand;
	}

}
