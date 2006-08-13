/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.CustomConnect;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;

import au.com.BI.Util.*;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.logging.*;



/**
 * @author Colin Canfield
 *
 **/
public class CustomConnect extends BaseDevice implements DeviceType
{
	protected Logger logger;
	protected Map <String,Map<String,CustomOutputExtraValue>>outConditions;
	protected List <CustomInputDetails>inputDetails;
	private boolean onlyOneExtra = true;

	public CustomConnect (){
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		outConditions = new HashMap <String,Map<String,CustomOutputExtraValue>>();
		inputDetails = new LinkedList<CustomInputDetails>();
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
		
	public Map <String,Map<String,CustomOutputExtraValue>>getOutConditions() {
		return outConditions;
	}
	
	public void addInputCondition(  String toMatch, String name, String command, String key, String extra, String extra2, String extra3, String extra4, String extra5) {
		CustomInputDetails condition = new CustomInputDetails();
		condition.setCommand(command);
		condition.setExtra(extra);
		condition.setExtra2(extra2);
		condition.setExtra3(extra3);
		condition.setExtra4(extra4);
		condition.setExtra5(extra5);
		condition.setName(name);
		condition.setToMatch(toMatch);
		inputDetails.add(condition);
		
	}
	
	public void 	addOutputCondition (String commandCondition, String extraVal, String value, String eachLineName) {
		if (extraVal == null || extraVal.equals("")){
			Map <String,CustomOutputExtraValue>extraValues = new HashMap<String,CustomOutputExtraValue>();
			
			extraValues.put("*", new CustomOutputExtraValue (value,eachLineName));
			outConditions.put(commandCondition, extraValues);
		} else {
			Map <String,CustomOutputExtraValue>extraValues;
			if (outConditions.containsKey(commandCondition)){
				extraValues = outConditions.get(commandCondition);
				onlyOneExtra = false;
			} else {
				extraValues = new HashMap<String,CustomOutputExtraValue>();
			}
			extraValues.put(extraVal, new CustomOutputExtraValue (value,eachLineName));
			outConditions.put(commandCondition, extraValues);			
		}
	}
	
	public CustomOutputExtraValueReturn getValue (String commandCondition, String extraVal) {
		CustomOutputExtraValueReturn returnValue = new CustomOutputExtraValueReturn();
		
		Map <String,CustomOutputExtraValue>extraValues = outConditions.get(commandCondition);
		if (onlyOneExtra || extraVal == null || extraVal.equals("") ){
			CustomOutputExtraValue theVal = extraValues.get("*");
			returnValue.setValue (theVal.getConfigValue());
			returnValue.setName(theVal.getName());
			return returnValue;
		}
		
		if (extraValues.containsKey("%NUMBER%") ){
			try {
				int intVal = Integer.parseInt(extraVal);
				returnValue.isNumber = true;
				CustomOutputExtraValue theVal = extraValues.get("%NUMBER%");
				returnValue.setValue (theVal.getConfigValue());
				returnValue.setName(theVal.getName());
				return returnValue;
			} catch (NumberFormatException ex){}
		}
		
		if (extraValues.containsKey(extraVal)){
			CustomOutputExtraValue theVal = extraValues.get(extraVal);
			returnValue.setValue (theVal.getConfigValue());
			returnValue.setName(theVal.getName());
			return returnValue;
		}
		
		if (extraValues.size() ==1){
			CustomOutputExtraValue theVal = extraValues.get("*");
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
