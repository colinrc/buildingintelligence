
package au.com.BI.M1;


/**
 * @author David Cummins
 * @author Explorative Sofwtare Pty Ltd
 *
*/

import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Vector;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Alert.AlertCommand;
import au.com.BI.M1.ControlledHelper;
import au.com.BI.CBUS.PollTemperatures;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Comms.CommsFail;
import au.com.BI.M1.Commands.ControlOutputOff;
import au.com.BI.M1.Commands.ControlOutputOn;
import au.com.BI.M1.Commands.ControlOutputStatusRequest;
import au.com.BI.M1.Commands.M1Command;
import au.com.BI.M1.Commands.M1CommandFactory;
import au.com.BI.M1.Commands.OutputChangeUpdate;
import au.com.BI.M1.Commands.ZoneChangeUpdate;
import au.com.BI.Sensors.SensorFascade;
import au.com.BI.ToggleSwitch.ToggleSwitch;
import au.com.BI.Util.BaseModel;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;
import au.com.BI.Util.Utility;

public class Model extends BaseModel implements DeviceModel {

	protected String outputM1Command = "";
	protected M1Helper m1Helper;
	protected ControlledHelper controlledHelper;
	protected LinkedList temperatureSensors;
	protected long tempPollValue = 0L;
	protected PollTemperatureSensors pollTemperatures;
	
	public Model () {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		m1Helper = new M1Helper();
		controlledHelper = new ControlledHelper();
		temperatureSensors = new LinkedList();
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
		String pollTempStr = (String)this.getParameter("POLL_SENSOR_INTERVAL", DeviceModel.MAIN_DEVICE_GROUP);

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
	}
	
	public void doOutputItem (CommandInterface command) throws CommsFail {
		String theWholeKey = command.getKey();
		boolean findingState = false;
		
		ArrayList deviceList = (ArrayList)configHelper.getOutputItem(theWholeKey);

		if (deviceList == null) {
			logger.log(Level.INFO, "Error in config, no output key for " + theWholeKey);
		}
		else {
			Iterator eachDev = deviceList.iterator();
			while (eachDev.hasNext()){
				 DeviceType device = (DeviceType)eachDev.next();
				 String retCode = "";
				 
				 if (device.getDeviceType() == DeviceType.TOGGLE_OUTPUT) {
					 retCode = buildToggleOutput ((DeviceType)device,command);
				 }	
				 
				 logger.log(Level.FINE,retCode);

				if (!retCode.equals ("")){
					comms.sendString(retCode);
				}
			}
		}
	}
	
	/**
	 * 
	 */
	public void addControlledItem (String key, DeviceType details, int controlType) {
		if (controlType == DeviceType.OUTPUT) {
			super.addControlledItem(Utility.padString(key,3),details,controlType);			
		} else if (controlType == DeviceType.SENSOR) {
			// only pad the string with 2 characters as this is the device that will be returned.
			super.addControlledItem(Utility.padString(key,2),details,controlType);
		} else {
			super.addControlledItem(Utility.padString(key,3),details,controlType);
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
				configHelper.setLastCommandType (DeviceType.MONITORED);
				// Anything coming over the serial port I want to process
				return true;
			}
		}
	}

	/**
	 * Builds the toggle output command based on the Control Output commands.
	 * cn - Control Output On, created when the command code is "on"
	 * ct - Control Output Toggle, created when the command code is pulse and there is a time element.
	 * cf - Control Output Off, created when the command code is "off"
	 * @param device
	 * @param command
	 * @return
	 */
	public String buildToggleOutput (DeviceType device, CommandInterface command) {
		String returnString = "";
				
		if (command.getCommandCode().equals ("on")){
			ControlOutputOn controlOutputOn = new ControlOutputOn();
			controlOutputOn.setKey(device.getKey());
			controlOutputOn.setOutputNumber(device.getKey());
			returnString = controlOutputOn.buildM1String() + "\r\n";
		} else if (command.getCommandCode().equals("pulse")) {
			ControlOutputOn controlOutputOn = new ControlOutputOn();
			controlOutputOn.setKey(device.getKey());
			controlOutputOn.setOutputNumber(device.getKey());
			controlOutputOn.setSeconds(command.getExtraInfo());
			returnString = controlOutputOn.buildM1String() + "\r\n";
		} else if (command.getCommandCode().equals("off")) {
			ControlOutputOff controlOutputOff = new ControlOutputOff();
			controlOutputOff.setKey(device.getKey());
			controlOutputOff.setOutputNumber(device.getKey());
			returnString = controlOutputOff.buildM1String() + "\r\n";
		}
		return(returnString);
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

}
