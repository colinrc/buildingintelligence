
package au.com.BI.M1;


/**
 * @author David Cummins
 * @author Explorative Sofwtare Pty Ltd
 *
*/

import java.util.HashMap;
import java.util.LinkedList;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Lights.Light;
import au.com.BI.Lights.LightFascade;
import au.com.BI.M1.ControlledHelper;
import au.com.BI.Alert.Alarm;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Device.DeviceType;
import au.com.BI.M1.Commands.ArmingStatusRequest;
import au.com.BI.M1.Commands.ControlOutputStatusRequest;
import au.com.BI.M1.Commands.PLCStatusRequest;
import au.com.BI.M1.Commands.ZoneStatusRequest;
import au.com.BI.Sensors.SensorFascade;
import au.com.BI.Util.SimplifiedModel;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;
import au.com.BI.Util.Utility;

public class Model extends SimplifiedModel implements DeviceModel {

	protected String outputM1Command = "";
	protected M1Helper m1Helper;
	protected ControlledHelper controlledHelper;
	protected LinkedList temperatureSensors;
	protected long tempPollValue = 0L;
	protected long outputPollValue = 0L;
	protected PollTemperatureSensors pollTemperatures;
	protected PollOutputs pollOutputs;
	protected OutputHelper outputHelper;
	protected HashMap armingStates;
	protected HashMap armUpStates;
	
	/**
	 * M1 Model. 
	 *
	 */
	public Model() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		m1Helper = new M1Helper();
		controlledHelper = new ControlledHelper();
		temperatureSensors = new LinkedList();
		outputHelper = new OutputHelper();
		deviceKeysDecimal = true;
		armingStates = new HashMap();
		armUpStates = new HashMap();
	}

	/**
	 * Clears items.
	 */
	public void clearItems () {
		super.clearItems();
	}

	/**
	 * Adds the startup query items. This will add all the temperature sensors that have been specified in the config.
	 */
	public void addStartupQueryItem (String name, Object details, MessageDirection controlType){
		try {
			if (((DeviceType)details).getDeviceType() == DeviceType.SENSOR ){
				temperatureSensors.add ((SensorFascade)details);
			}
		} catch (ClassCastException ex) {
			logger.log (Level.FINE,"A temperature sensor was added that was not the expected type " + ex.getMessage());
		}
	}
	
	/**
	 * Performs the startup commands. This will:
	 * <ul>
	 * <li>Create the polling class to monitor the named temperature sensors.</li>
	 * <li>Request the status of all the control outputs.</li>
	 * <li>Request the arming states of all monitored devices.</li>
	 * <li>Create an ARM virtual device to handle requests from the client to arm the M1.</li>
	 * <li>Create a REQUEST virtual device to handle various requests for reports from the M1.</li>
	 * </ul>
	 */
	public void doStartup() throws CommsFail {

		logger.log(Level.INFO, "Starting M1");
		// create the temperature polling service
		String pollTempStr = (String)this.getParameterValue("POLL_SENSOR_INTERVAL", DeviceModel.MAIN_DEVICE_GROUP);
		String outputTempStr = (String)this.getParameterValue("POLL_OUTPUT_INTERVAL", DeviceModel.MAIN_DEVICE_GROUP);

		try {
			tempPollValue = Long.parseLong(pollTempStr) * 1000;
		} catch (NumberFormatException ex) {
			tempPollValue = 0L;
		}
		
		try {
			outputPollValue = Long.parseLong(outputTempStr) * 1000;
		} catch (NumberFormatException ex) {
			outputPollValue = 0L;
		}

		if (!temperatureSensors.isEmpty() && tempPollValue != 0L) {
			logger.log(Level.INFO,"Starting temperature polls");
			pollTemperatures = new PollTemperatureSensors();
			pollTemperatures.setPollValue(tempPollValue);
			pollTemperatures.setTemperatureSensors(temperatureSensors);
			pollTemperatures.setCommandQueue(commandQueue);
			pollTemperatures.setDeviceNumber(InstanceID);
			pollTemperatures.setComms(comms);
			pollTemperatures.start();
		} else {
			logger.log(Level.INFO,"Not starting temperature polls");
		}
		
		if (outputPollValue != 0L) {
			logger.log(Level.INFO,"Starting output polls");
			pollOutputs = new PollOutputs();
			pollOutputs.setPollValue(outputPollValue);
			pollOutputs.setCommandQueue(commandQueue);
			pollOutputs.setDeviceNumber(InstanceID);
			pollOutputs.setComms(comms);
			pollOutputs.start();
		} else {
			logger.log(Level.INFO,"Not starting output polls");
		}
		
		// request the states of the contol output devices.
		ControlOutputStatusRequest statusRequest = new ControlOutputStatusRequest();
		comms.sendString(statusRequest.buildM1String()+"\r\n");
		
		// request the arming states
		ArmingStatusRequest armingStatusRequest = new ArmingStatusRequest();
		comms.sendString(armingStatusRequest.buildM1String()+"\r\n");
		
		// request PLC states
		PLCStatusRequest plcStatusRequest = new PLCStatusRequest();
		comms.sendString(plcStatusRequest.buildM1String()+"\r\n");
		
		// request the status of the zones
		ZoneStatusRequest zoneRequest = new ZoneStatusRequest();
		comms.sendString(zoneRequest.buildM1String() + "\r\n");
		
		// add a device to do arming messages
		addControlledItem("ARM",new Alarm("ARM",DeviceType.VIRTUAL_OUTPUT,"ARM"),MessageDirection.FROM_FLASH);
		
		// add a device to do request messages
		addControlledItem("REQUEST",new Alarm("REQUEST",DeviceType.VIRTUAL_OUTPUT,"REQUEST"),MessageDirection.FROM_FLASH);
		
		// generic X10 device to capture requests - 
		// @todo Need to check that using a generic X10 device with no house or unit code will actually work with a real M1.
		addControlledItem("ALL", new LightFascade("ALL",DeviceType.COMFORT_LIGHT_X10, "ALL"), MessageDirection.FROM_FLASH);
	}
	
	public void doOutputItem (CommandInterface command) throws CommsFail {
		outputHelper.doOutputItem(command, configHelper, cache, comms,this);
	}
	


	
	/**
	 * @see au.com.BI.Util.ModelParameters#addControlledItem(java.lang.String, au.com.BI.Util.DeviceType, au.com.BI.Util.MessageDirection)
	 */
	public void addControlledItem (String key, DeviceType details, MessageDirection type) {
		
		String deviceKeyAddition = "";
		if (type != MessageDirection.FROM_FLASH) {
			if (details.getDeviceType() == DeviceType.TOGGLE_INPUT) {
				deviceKeyAddition = "TIN";
			} else if (details.getDeviceType() == DeviceType.TOGGLE_OUTPUT) {
				deviceKeyAddition = "TOUT";
			} else if (details.getDeviceType() == DeviceType.CONTACT_CLOSURE) {
				deviceKeyAddition = "CC";
			} else if (details.getDeviceType() == DeviceType.COMFORT_LIGHT_X10) {
				LightFascade light = (LightFascade)details;
				deviceKeyAddition = "X10" + light.getX10HouseCode();
			}
		}
		
		if (type == MessageDirection.FROM_FLASH) {
			super.addControlledItem(key,details,type);			
		} else if (details.getDeviceType() == DeviceType.SENSOR) {
			// only pad the string with 2 characters as this is the device that will be returned.
			super.addControlledItem(Utility.padString(key,2),details,type);
		} else if (details.getDeviceType() == DeviceType.COMFORT_LIGHT_X10) {
			super.addControlledItem(Utility.padString(key, 2) + deviceKeyAddition,details,type);
		} else {
			super.addControlledItem(Utility.padString(key,3)+deviceKeyAddition,details,type);
		}
	}

	/**
	 * Controlled item is the default item type.
	 * The system will call this function if it is not from flash.
	 * ie. It is from the serial port.
	 */
	public void doControlledItem (CommandInterface command) throws CommsFail
	{
		controlledHelper.doControlledItem(command, configHelper, cache, commandQueue, this);
	}
	
	public boolean doIControl (String keyName, boolean isClientCommand)
	{
		configHelper.wholeKeyChecked(keyName);

		if (configHelper.checkForOutputItem(keyName)) {
			logger.log (Level.FINER,"Flash sent command : " +keyName);
			return true;
		}
		else {
			if (isClientCommand)
				return false;
			else {
				configHelper.setLastCommandType (MessageDirection.FROM_HARDWARE);
				// Anything coming over the serial port I want to process
				return true;
			}
		}
	}

	public boolean doIPHeartbeat () {
	    return false;
	}



	public M1Helper getM1Helper() {
		return m1Helper;
	}



	public void setM1Helper(M1Helper m1Helper) {
		this.m1Helper = m1Helper;
	}
	
	/**
	 * Formats a key into the appropriate format for interacting with the config file.
	 * @return Formatted key
	 */
    public String formatKey(int key,DeviceType device) throws NumberFormatException {
    	
		int padding = 3;
    	if (device.getDeviceType() == DeviceType.SENSOR) {
    		padding = 2;
    	}
		String formatSpec = "%0";
		formatSpec += padding;
		formatSpec += "d";			
			
		return String.format(formatSpec,key);
    }

	/**
	 * Formats a key into the appropriate format for interacting with the config file.
	 * @return Formatted key
	 */
    public String formatKey(String key,DeviceType device) throws NumberFormatException {
		int keyInt = 0;
		keyInt = Integer.parseInt(key);
    	return formatKey(keyInt,device);
    }

	public HashMap getArmingStates() {
		return armingStates;
	}

	public void setArmingStates(HashMap armingStates) {
		this.armingStates = armingStates;
	}

	public HashMap getArmUpStates() {
		return armUpStates;
	}

	public void setArmUpStates(HashMap armUpStates) {
		this.armUpStates = armUpStates;
	}
    
    

}
