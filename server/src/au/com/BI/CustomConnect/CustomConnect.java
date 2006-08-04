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
	protected Map <String,Map<String,String>>conditions;
	private boolean onlyOneExtra = true;
	
	public CustomConnect (){
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		conditions = new HashMap <String,Map<String,String>>();
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
		
	public Map <String,Map<String,String>>getConditions() {
		return conditions;
	}
	
	public void 	addCondition (String commandCondition, String extraVal, String value) {
		if (extraVal == null || extraVal.equals("")){
			Map <String,String>extraValues = new HashMap<String,String>();
			extraValues.put("*", value);
			conditions.put(commandCondition, extraValues);
		} else {
			Map <String,String>extraValues;
			if (conditions.containsKey(commandCondition)){
				extraValues = conditions.get(commandCondition);
				onlyOneExtra = false;
			} else {
				extraValues = new HashMap<String,String>();
			}
			extraValues.put(extraVal, value);
			conditions.put(commandCondition, extraValues);			
		}
	}
	
	public String getValue (String commandCondition, String extraVal) {
		Map <String,String>extraValues = conditions.get(commandCondition);
		
		if (onlyOneExtra || extraVal == null || extraVal.equals("") ){
			return extraValues.get("*");
		} else {
			if (extraValues.containsKey(extraVal)){
				return extraValues.get(extraVal);
			} else {
				if (extraValues.size() ==1){
					return extraValues.get("*");
				} else {
					return null;
				}
			} 
		}
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
