/*
 * Created on Mar 16, 2004
 *
 */
package au.com.BI.Config;

import java.util.*;

import java.util.logging.*;

import au.com.BI.Script.Script;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;
import au.com.BI.Config.ParameterBlock;
import au.com.BI.CustomConnect.CustomConnectInput;
import au.com.BI.Device.DeviceType;

public class ConfigHelper {
	protected HashMap <String,DeviceType> controlledItems;
	protected HashMap <String,DeviceType> outputItems;
	protected HashMap <String,DeviceType> inputItems;
	protected HashMap <String,DeviceType> startupQueryItems;
	protected List <CustomConnectInput>customConnectInputList;
	protected String lastChecked;
	protected Vector <ParameterBlock>parameterBlocks;
	protected DeviceModel deviceModel = null;

	
	protected MessageDirection itemList;
	Logger logger;

	public ConfigHelper (DeviceModel deviceModel) {
		this.deviceModel = deviceModel;
        parameterBlocks = new Vector<ParameterBlock>();
		clearItems ();
		lastChecked = "";
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		

	}


	/**
	 * Provides a simple method for models to specify parameters they expect to find in the configuration file
	 * @param catalogName
	 * @param group
	 * @param verboseName
	 */
    public void addParameterBlock (String catalogName,String group,String verboseName) {
    	ParameterBlock params = new ParameterBlock( catalogName, group, verboseName);
    	this.parameterBlocks.add(params);
    }
    
	/**
	 * Provides a simple method for models to speficy prameters they expect to find in the configuration file
	 * @param catalogName
	 * @param verboseName
	 */
    public void addParameterBlock (String catalogName, String verboseName) {
    	addParameterBlock (catalogName, DeviceModel.MAIN_DEVICE_GROUP, verboseName);
    }
    
	/**
	 * For some keys the entire key may be longer than the section tested; eg. if parameters are in a COMFORT string.
	 * @param lastChecked The entire string that was received.
	 */
	public void wholeKeyChecked (String lastChecked) {
		this.lastChecked = lastChecked;
	}
	
	/**
	 * Tests if the key is the stame string used to test control
	 * @param key
	 * @return true if it is the same
	 */
	public boolean equalsLastChecked(String key) {
		if (key.equals (lastChecked))
			return true;
		else
			return false;
	}
	

	public void clearItems () {
		controlledItems = new HashMap<String,DeviceType> (100);
		outputItems = new HashMap<String,DeviceType> (100);
		inputItems = new HashMap<String,DeviceType> (100);	
		startupQueryItems = new HashMap<String,DeviceType> (200);
		customConnectInputList = new LinkedList<CustomConnectInput>();
		parameterBlocks.clear();
	}
	
	/**
	 * Describes if the matching command is DeviceType.INPUT, DeviceType.OUTPUT or DeviceType.MONITORED
	 * @return list type
	 */
	public MessageDirection getLastCommandType () {
		return itemList;
	}

	public void setLastCommandType (MessageDirection type) {
		itemList = type;
	}
	

	/**
	 * @deprecated
	 */
	public Iterator <DeviceType>getAllControlledDevices(){
		return controlledItems.values().iterator();		
	}
	
	/**
	 * @deprecated
	 */
	public Iterator <String>getControlledItemsList (){
		return controlledItems.keySet().iterator();
	}
	
	/**
	 * @deprecated
	 */
	public Iterator <String>getStartupQueryItemsList (){
		return startupQueryItems.keySet().iterator();
	}

	public Collection<DeviceType> getAllControlledDeviceObjects(){
		return controlledItems.values();		
	}
	
	public Collection<DeviceType> getAllOutputDeviceObjects(){
		return outputItems.values();		
	}
	
	
	public Collection<DeviceType> getAllStartupDeviceObjects(){
		return startupQueryItems.values();		
	}

	public Collection<String> getAllControlledDeviceKeys(){
		return controlledItems.keySet();		
	}
	
	public Collection<String> getAllOutputDeviceKeyss(){
		return outputItems.keySet();		
	}
	
	
	public Collection<String> getAllStartupDeviceKeys(){
		return startupQueryItems.keySet();		
	}

	public void addControlledItem (String name, DeviceType details, MessageDirection controlType){
		if (controlType == MessageDirection.FROM_HARDWARE) {
			if (controlledItems.containsKey(name)){
				logger.log (Level.WARNING,"Attempted to add the device: " + name + " " + details.getName() + 
						" when a device with the same key already exists: " + controlledItems.get(name).getName());
				
			} else {
				controlledItems.put (name,details);
			}
			
		}
		else {
			if (controlType == MessageDirection.FROM_FLASH) {
				if (outputItems.containsKey(name) && !(details instanceof Script)){
					logger.log (Level.INFO,"Attempted to add the device: " + name + " " + details.getName() + 
							" when a device with the same key already exists: " + outputItems.get(name).getName());
					
				} else {
					outputItems.put(name,details);
				}

			} else {
				if (inputItems.containsKey(name)){
					logger.log (Level.WARNING,"Attempted to add the device: " + name + " " + details.getName() + 
							" when a device with the same key already exists: " + inputItems.get(name).getName());
					
				} else {
					inputItems.put (name,details);
				}
			}
		}
	}

	public void addStartupQueryItem (String name, DeviceType details, MessageDirection controlType){
		if (!startupQueryItems.containsKey(name))
			startupQueryItems.put (name,details);
	}

	public DeviceType getStartupQueryItem (String name){
		return startupQueryItems.get (name);
	}

	public boolean checkForControl (String theKey) {
		boolean returnCode = false;
		
		returnCode = checkForStartupItem (theKey);
		if (!returnCode) {
			returnCode = checkForInputItem (theKey);
		}
		if (!returnCode) {
			returnCode = checkForOutputItem (theKey);
		}
		if (!returnCode) {
				returnCode = checkForControlledItem (theKey);
		}
		
		return returnCode;
	}

	public boolean checkForStartupItem (String theKey) {
		boolean returnCode = false;
		
		if (startupQueryItems.containsKey(theKey)) {
			itemList = MessageDirection.STARTUP; 
			returnCode = true;
		}
		
		return returnCode;
	}
	
	private  boolean checkForInputItem (String theKey) {
		boolean returnCode = false;
		
		if (inputItems.containsKey(theKey)) {
			itemList = MessageDirection.INPUT;
			returnCode = true;
		}
		
		return returnCode;
	}
	
	public boolean checkForOutputItem (String theKey) {
		boolean returnCode = false;
		
		if (outputItems.containsKey(theKey)) {
			itemList = MessageDirection.FROM_FLASH;
			returnCode = true;
		}
		
		return returnCode;
	}

	public boolean checkForControlledItem (String theKey) {
		boolean returnCode = false;
		
		if (controlledItems.containsKey(theKey)) {
			itemList = MessageDirection.FROM_HARDWARE;
			returnCode = true;
		}
		
		return returnCode;
	}
	
	public DeviceType getControlItem (String theKey){
		if (!theKey.equals (lastChecked)){
			checkForControl (theKey);
		}
		if (itemList == MessageDirection.FROM_HARDWARE) {
			return this.getControlledItem(theKey);
		}
		if (itemList == MessageDirection.INPUT) {
			return this.getInputItem(theKey);
		}
		if (itemList == MessageDirection.FROM_FLASH) {
			return this.getOutputItem(theKey);
		}
		if (itemList == MessageDirection.STARTUP) {
			return this.getStartupQueryItem(theKey);
		}
		return null;
	}
	

	private final DeviceType getInputItem (String theKey) {
		return inputItems.get(theKey);
	}

	public final DeviceType getOutputItem (String theKey) {
		return outputItems.get(theKey);
	}
	
	public final DeviceType getControlledItem (String theKey) {
		return controlledItems.get(theKey);
	}

	public Vector<ParameterBlock> getParameterBlocks() {
		return parameterBlocks;
	}

	public void setParameterBlocks(Vector<ParameterBlock> parameterBlocks) {
		this.parameterBlocks = parameterBlocks;
	}

	public DeviceModel getDeviceModel() {
		return deviceModel;
	}

	public void setDeviceModel(DeviceModel deviceModel) {
		this.deviceModel = deviceModel;
	}


	public List<CustomConnectInput> getCustomConnectInputList() {
		return customConnectInputList;
	}


	public void setCustomConnectInputList(
			List<CustomConnectInput> customConnectInputList) {
		this.customConnectInputList = customConnectInputList;
	}
	
	public void addCustomConnectInput(CustomConnectInput customConnectInput) {
			customConnectInputList.add(customConnectInput);
	}
	

}
