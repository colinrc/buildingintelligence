
package au.com.BI.M1;


/**
 * @author David Cummins
 * @author Explorative Sofwtare Pty Ltd
 *
*/

import java.util.LinkedList;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.M1.ControlledHelper;
import au.com.BI.Alert.Alarm;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Comms.CommsFail;
import au.com.BI.M1.Commands.ArmingStatusRequest;
import au.com.BI.M1.Commands.ControlOutputOff;
import au.com.BI.M1.Commands.ControlOutputOn;
import au.com.BI.M1.Commands.ControlOutputStatusRequest;
import au.com.BI.Sensors.SensorFascade;
import au.com.BI.Util.BaseModel;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;
import au.com.BI.Util.MessageDirection;
import au.com.BI.Util.Utility;

public class Model extends BaseModel implements DeviceModel {

	protected String outputM1Command = "";
	protected M1Helper m1Helper;
	protected ControlledHelper controlledHelper;
	protected LinkedList temperatureSensors;
	protected long tempPollValue = 0L;
	protected PollTemperatureSensors pollTemperatures;
	protected OutputHelper outputHelper;
	
	public Model() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		m1Helper = new M1Helper();
		controlledHelper = new ControlledHelper();
		temperatureSensors = new LinkedList();
		outputHelper = new OutputHelper();
		deviceKeysDecimal = true;
	}

	public void clearItems () {
		super.clearItems();
	}

	/**
	 * Adds the startup query items. This will add all the temperature sensors that have been specified in the config.
	 */
	public void addStartupQueryItem (String name, Object details, int controlType){
		try {
			if (((DeviceType)details).getDeviceType() == DeviceType.SENSOR ){
				temperatureSensors.add ((SensorFascade)details);
			}
		} catch (ClassCastException ex) {
			logger.log (Level.FINE,"A temperature sennssor was added that was not the expected type " + ex.getMessage());
		}
	}
	
	/**
	 * 
	 */
	public void doStartup() throws CommsFail {

		// create the temperature polling service
		String pollTempStr = (String)this.getParameterValue("POLL_SENSOR_INTERVAL", DeviceModel.MAIN_DEVICE_GROUP);

		try {
			tempPollValue = Long.parseLong(pollTempStr) * 1000;
		} catch (NumberFormatException ex) {
			tempPollValue = 0L;
		}

		if (!temperatureSensors.isEmpty() && tempPollValue != 0L) {
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
		
		// request the states of the contol output devices.
		ControlOutputStatusRequest statusRequest = new ControlOutputStatusRequest();
		comms.sendString(statusRequest.buildM1String()+"\r\n");
		
		// request the arming states
		ArmingStatusRequest armingStatusRequest = new ArmingStatusRequest();
		comms.sendString(armingStatusRequest.buildM1String()+"\r\n");
		
		// add a device to do arming messages
		super.addControlledItem("ARM",new Alarm("ARM",DeviceType.VIRTUAL_OUTPUT,"ARM"),MessageDirection.FROM_FLASH);
	}
	
	public void doOutputItem (CommandInterface command) throws CommsFail {
		outputHelper.doOutputItem(command, configHelper, cache, comms,this);
	}
	
	/**
	 * @TODO, this looks incorrect. I don't think you want from flash (previously output) here
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
			}
		}
		
		if (type == MessageDirection.FROM_FLASH) {
			super.addControlledItem(key,details,type);			
		} else if (details.getDeviceType() == DeviceType.SENSOR) {
			// only pad the string with 2 characters as this is the device that will be returned.
			super.addControlledItem(Utility.padString(key,2),details,type);
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

}
