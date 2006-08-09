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
	protected Map <String,Map<String,CustomExtraValue>>conditions;
	private boolean onlyOneExtra = true;

	public CustomConnect (){
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		conditions = new HashMap <String,Map<String,CustomExtraValue>>();
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
		
	public Map <String,Map<String,CustomExtraValue>>getConditions() {
		return conditions;
	}
	
	public void 	addCondition (String commandCondition, String extraVal, String value, String eachLineName) {
		if (extraVal == null || extraVal.equals("")){
			Map <String,CustomExtraValue>extraValues = new HashMap<String,CustomExtraValue>();
			
			extraValues.put("*", new CustomExtraValue (value,eachLineName));
			conditions.put(commandCondition, extraValues);
		} else {
			Map <String,CustomExtraValue>extraValues;
			if (conditions.containsKey(commandCondition)){
				extraValues = conditions.get(commandCondition);
				onlyOneExtra = false;
			} else {
				extraValues = new HashMap<String,CustomExtraValue>();
			}
			extraValues.put(extraVal, new CustomExtraValue (value,eachLineName));
			conditions.put(commandCondition, extraValues);			
		}
	}
	
	public CustomExtraValueReturn getValue (String commandCondition, String extraVal) {
		CustomExtraValueReturn returnValue = new CustomExtraValueReturn();
		
		Map <String,CustomExtraValue>extraValues = conditions.get(commandCondition);
		if (onlyOneExtra || extraVal == null || extraVal.equals("") ){
			CustomExtraValue theVal = extraValues.get("*");
			returnValue.setValue (theVal.getConfigValue());
			returnValue.setName(theVal.getName());
			return returnValue;
		}
		
		if (extraValues.containsKey("%NUMBER%") ){
			try {
				int intVal = Integer.parseInt(extraVal);
				returnValue.isNumber = true;
				CustomExtraValue theVal = extraValues.get("%NUMBER%");
				returnValue.setValue (theVal.getConfigValue());
				returnValue.setName(theVal.getName());
				return returnValue;
			} catch (NumberFormatException ex){}
		}
		
		if (extraValues.containsKey(extraVal)){
			CustomExtraValue theVal = extraValues.get(extraVal);
			returnValue.setValue (theVal.getConfigValue());
			returnValue.setName(theVal.getName());
			return returnValue;
		}
		
		if (extraValues.size() ==1){
			CustomExtraValue theVal = extraValues.get("*");
			returnValue.setValue (theVal.getConfigValue());
			returnValue.setName(theVal.getName());
			return returnValue;
		} 
		return null;
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
