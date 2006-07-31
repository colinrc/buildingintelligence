/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.CustomConnect;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;

import au.com.BI.Util.*;

import java.util.HashMap;
import java.util.Map;
import java.util.logging.*;



/**
 * @author Colin Canfield
 *
 **/
public class CustomConnect extends BaseDevice implements DeviceType
{
	protected Logger logger;
	protected Map <String,String>conditions;
	
	public CustomConnect (){
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		conditions = new HashMap <String,String>();
	}
	
	public boolean keepStateForStartup () {
		return false;
	}
	
	public final int getDeviceType () {
		return DeviceType.CUSTOM_CONNECT;
	}
	
	public int getClientCommand ()
	{
		return DeviceType.NA;
	}
		

	/**
	 * Returns a display command represented by the custom input object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		CustomConnectCommand customInputCommand = new CustomConnectCommand ();
		customInputCommand.setDisplayName(this.getOutputKey());
		customInputCommand.setTargetDeviceID(0);
		return customInputCommand;
	}


}
