/*
 * Created on Mar 16, 2004
 *
 */
package au.com.BI.Config;

import java.util.*;
import au.com.BI.Command.*;
import java.util.logging.*;

import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;
public class ConfigHelper {
	protected HashMap controlledItems;
	protected HashMap outputItems;
	protected HashMap inputItems;
	protected HashMap startupQueryItems;
	protected String lastChecked;

	
	protected int itemList;
	Logger logger;

	public ConfigHelper () {
		clearItems ();
		lastChecked = "";
		logger = Logger.getLogger(this.getClass().getPackage().getName());
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
		controlledItems = new HashMap (100);
		outputItems = new HashMap (100);
		inputItems = new HashMap (100);	
		startupQueryItems = new HashMap (200);
	}
	
	/**
	 * Describes if the matching command is DeviceType.INPUT, DeviceType.OUTPUT or DeviceType.MONITORED
	 * @return list type
	 */
	public int getLastCommandType () {
		return itemList;
	}

	public void setLastCommandType (int type) {
		itemList = type;
	}
	

	public Iterator getAllControlledDevices(){
		return controlledItems.values().iterator();		
	}
	
	public Iterator getControlledItemsList (){
		return controlledItems.keySet().iterator();
	}
	public Iterator getStartupQueryItemsList (){
		return startupQueryItems.keySet().iterator();
	}
		
	public Iterator getInputItemsList (){
		return inputItems.keySet().iterator();
	}
	

	public Iterator getAllInputDevices(){
		return inputItems.values().iterator();		
	}

	/**
	 * If a raw code has been specified for this command on this device. It will be returned.
	 * @param command
	 * @param device
	 * @return
	 */
	public String doRawIfPresent (CommandInterface command, DeviceType targetDevice, DeviceModel device) { 
		Map rawCodes = targetDevice.getRawCodes(); // the list specified in the config for this device line.

		if (rawCodes!= null){
			String commandName = command.getCommandCode();
			String extraFromClient = (String)command.getExtraInfo();
			RawItemDetails rawCode = (RawItemDetails)rawCodes.get(commandName+":"+extraFromClient); // pull up details for the line
			
			if (rawCode == null) 
				rawCode = (RawItemDetails)rawCodes.get(commandName); // pull up details for the line				

			if (rawCode != null){
				Map rawCatalogue = (Map)device.getCatalogueDef(rawCode.getCatalogue());
				if (rawCatalogue == null ) {
					logger.log (Level.WARNING ,"Specified raw catalogue is not defined : "+rawCatalogue);	
					return null;
				}
				else {
					String catalogueValue = (String)rawCatalogue.get(rawCode.getCode());
					return rawCode.populateVariables (catalogueValue,command);
				}
			}
		}
		return null;
	}

	public String getCatalogueValue (String ID, String rawCatalogueName, DeviceModel device) {
		String value = "";
		Map rawCatalogue = (Map)device.getCatalogueDef(rawCatalogueName);
		if (rawCatalogue == null ) {
			logger.log (Level.WARNING ,"Catalogue " + rawCatalogueName + " not specified.");	
			return null;
		}
		else {
			value = (String)rawCatalogue.get(ID);
			return value;
		}
	}

	public void addControlledItem (String name, Object details, int controlType){
		if (controlType == DeviceType.MONITORED) {
			controlledItems.put (name,details);
			
			
		}
		else {
			if (controlType == DeviceType.OUTPUT) {
				ArrayList namedItems = (ArrayList)outputItems.get(name);
			
				if (namedItems == null){
					ArrayList newNamedItems = new ArrayList (5);
					newNamedItems.add(details);
					outputItems.put (name,newNamedItems);
				}
				else {
					namedItems.add (details);
					outputItems.put(name,namedItems);
				}
			} else {
				inputItems.put (name,details);
			}
		}
	}

	public void addStartupQueryItem (String name, Object details, int controlType){
		if (!startupQueryItems.containsKey(name))
			startupQueryItems.put (name,details);
	}

	public Object getStartupQueryItem (String name){
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
			itemList = DeviceType.STARTUP;
			returnCode = true;
		}
		
		return returnCode;
	}
	
	public boolean checkForInputItem (String theKey) {
		boolean returnCode = false;
		
		if (inputItems.containsKey(theKey)) {
			itemList = DeviceType.INPUT;
			returnCode = true;
		}
		
		return returnCode;
	}
	
	public boolean checkForOutputItem (String theKey) {
		boolean returnCode = false;
		
		if (outputItems.containsKey(theKey)) {
			itemList = DeviceType.OUTPUT;
			returnCode = true;
		}
		
		return returnCode;
	}

	public boolean checkForControlledItem (String theKey) {
		boolean returnCode = false;
		
		if (controlledItems.containsKey(theKey)) {
			itemList = DeviceType.MONITORED;
			returnCode = true;
		}
		
		return returnCode;
	}
	
	public Object getControlItem (String theKey){
		if (!theKey.equals (lastChecked)){
			checkForControl (theKey);
		}
		if (itemList == DeviceType.MONITORED) {
			return this.getControlledItem(theKey);
		}
		if (itemList == DeviceType.INPUT) {
			return this.getInputItem(theKey);
		}
		if (itemList == DeviceType.OUTPUT) {
			return this.getOutputItem(theKey);
		}
		if (itemList == DeviceType.STARTUP) {
			return this.getStartupQueryItem(theKey);
		}
		return null;
	}
	
	public final Object getInputItem (String theKey) {
		return inputItems.get(theKey);
	}

	public final Object getOutputItem (String theKey) {
		return outputItems.get(theKey);
	}
	
	public final Object getControlledItem (String theKey) {
		return controlledItems.get(theKey);
	}

}
