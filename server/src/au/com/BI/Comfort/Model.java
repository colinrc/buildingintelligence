/*
 * Created on Jan 25, 2004
 *
*/
package au.com.BI.Comfort;

/**
 * @author Colin Canfield
 * @author Explorative Sofwtare Pty Ltd
 *
*/
import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Device.DeviceType;
import au.com.BI.Util.*;
import au.com.BI.User.User;
import java.util.logging.*;
import au.com.BI.Lights.*;
import au.com.BI.Alert.*;
import au.com.BI.Analog.*;

// TODO set up security properly

public class Model extends SimplifiedModel implements DeviceModel  {

	protected String STX = "\003";
	protected String ETX = "\r";
	protected Startup startup;
	protected boolean isStartupQuery = false;

	protected ComfortString comfortString = null;
	protected OutputHelper outputHelper;
	protected ControlledHelper controlledHelper;
	protected AnalogReader analogueReader;
	protected String applicationCode = "38";
	protected String alert_zones = "";

	public Model () {
		super();
		comfortString = new ComfortString ();
		startup = new Startup();
		outputHelper = new OutputHelper(this);
		controlledHelper = new ControlledHelper();
		analogueReader = new AnalogReader();
		this.setSTX (STX);
		this.setETX (ETX);

		this.addControlledItem ("LU",null,MessageDirection.FROM_HARDWARE); // special item
		this.addControlledItem  ("SERIAL",null,MessageDirection.FROM_HARDWARE);
		this.addControlledItem ("RA",null,MessageDirection.FROM_HARDWARE); // special item
		this.addControlledItem ("NA",null,MessageDirection.FROM_HARDWARE); // special item
		this.addControlledItem ("OK",null,MessageDirection.FROM_HARDWARE); // special item
		this.addControlledItem ("EV",null,MessageDirection.FROM_HARDWARE); // special item
		
		configHelper.addParameterBlock ("AV_INPUTS",DeviceModel.MAIN_DEVICE_GROUP,"Comfort Users");
		configHelper.addParameterBlock ("DOOR_IDS",DeviceModel.MAIN_DEVICE_GROUP,"Door IDS");

		}

	public void setCommandQueue (CommandQueue commandQueue){
		super.setCommandQueue(commandQueue);
		outputHelper.setCommandQueue(commandQueue);
		controlledHelper.setCommandQueue(commandQueue);		
		startup.setCommandQueue(commandQueue);		
	}

	/**
	 * Name is used by the config reader to tie a particular device to configuration
	 * @param fileName The identifying string for this device handler
	 */
	public void clearItems () {
		configHelper.clearItems();
		comfortString.clear();
		cache.clear();
		analogueReader.clearItems();
		this.addControlledItem ("LU",null,MessageDirection.FROM_HARDWARE); // special item
		this.addControlledItem ("RA",null,MessageDirection.FROM_HARDWARE); // special item
		this.addControlledItem ("OK",null,MessageDirection.FROM_HARDWARE); // special item
		this.addControlledItem ("NA",null,MessageDirection.FROM_HARDWARE); // special item
		this.addControlledItem ("EV",null,MessageDirection.FROM_HARDWARE); // special item
		this.addControlledItem  ("SERIAL",null,MessageDirection.FROM_HARDWARE);

	}

	public void addControlledItem (String name, DeviceType details, MessageDirection controlType) {
		String theKey = name;
		String secondKey = "";
		boolean doNotAddToControlledList = false;

		if (details != null) {
			int deviceType = ((DeviceType)details).getDeviceType();

			if (controlType == MessageDirection.FROM_HARDWARE ) {
			    secondKey = "";

				switch (deviceType) {
					case DeviceType.TOGGLE_INPUT:
					    theKey = "IP" + theKey;
						break;

					case DeviceType.TOGGLE_OUTPUT: case DeviceType.TOGGLE_OUTPUT_MONITOR:
						theKey = "OP" + theKey;
						break;

					case DeviceType.LIGHT_CBUS:
						if (((LightFascade)details).getApplicationCode().equals("38"))
						    theKey = "CT" + theKey;
					break;

					case DeviceType.PULSE_OUTPUT:
						secondKey = "OP" + theKey;
						theKey = "PT" + theKey;
					break;

					case DeviceType.COUNTER:
						theKey = "CT" + theKey;
					break;

					case DeviceType.COMFORT_LIGHT_X10_UNITCODE:
						theKey = "XU" + ((LightFascade)details).getX10HouseCode() + theKey;
					break;

					case DeviceType.COMFORT_LIGHT_X10:
						theKey = "XF" + ((LightFascade)details).getX10HouseCode() + theKey;
					break;

					case DeviceType.ANALOGUE :
						doNotAddToControlledList = true; // handled by a seperate thread
						analogueReader.addAnalogueInput((Analog)details);
					break;

					case DeviceType.ALERT: 
						AlarmTypeCode alarmTypeCode =((Alert)details).getAlarmTypeCode();
						switch (alarmTypeCode) {
							case ALERT_DOORBELL :
								theKey = "DB";
								break;
							case ALERT_PHONE :
								theKey = "RP";
								break;
							case ALERT_MODE_CHANGE :
								theKey = "MD";
								break;
							case ALARM_ID : case ALARM_ZONE : case ALARM_USER : case ALARM_SYSTEM :
								theKey = "AM" + ((Alert)details).getKey();//
								break;
							case ALARM_TYPE :
								theKey = "AL" + ((Alert)details).getKey();
								break;
						}
					break;

				}
			}

			if (controlType == MessageDirection.FROM_FLASH ) {

			    switch (deviceType) {
					case DeviceType.TOGGLE_OUTPUT : case DeviceType.TOGGLE_OUTPUT_MONITOR:
						theKey = name;
						break;
				}
			}
		}

		if (!doNotAddToControlledList) configHelper.addControlledItem (theKey, details, controlType);
		if (!doNotAddToControlledList && !secondKey.equals("")) configHelper.addControlledItem (secondKey, details, controlType);
	}


	public void addStartupQueryItem (String name, Object  details, MessageDirection controlType) {

		startup.addStartupQueryItem (configHelper,name, (DeviceType)details, controlType);
	}

	public boolean doIControl (String keyName, boolean isClientCommand)
	{
		isStartupQuery = false;
		configHelper.wholeKeyChecked(keyName);

		if (configHelper.checkForOutputItem(keyName)) {
			logger.log (Level.FINER,"Flash sends command : " +keyName);
			comfortString.setOutputKey (keyName);
			return true;
		}
		if (isClientCommand) return false; // only are about output for client commands

		if (comfortString.splitString (keyName)) {

			if (configHelper.checkForStartupItem(comfortString.comfortKey)){
				logger.log (Level.FINER,"Comfort controls : " +comfortString.comfortKey);
				isStartupQuery = true;
				return true;
			}
			if (configHelper.checkForControlledItem(comfortString.comfortKey)){
				logger.log (Level.FINER,"Comfort controls : " +comfortString.comfortKey);
				return true;
			}
			configHelper.setLastCommandType(MessageDirection.NOT_CONTROLLED);
			return true;
		}
		return false;
	}

	public void doCommand (CommandInterface command) throws CommsFail
	{
		String theWholeKey = command.getKey();

		if (configHelper.getLastCommandType() == MessageDirection.NOT_CONTROLLED) {
			sendNextCommandInQueue();
			return;
		}

		if ( configHelper.getLastCommandType() == MessageDirection.FROM_FLASH && this.connected == true) {
			outputHelper.doOutputItem (command,comfortString, configHelper, cache, comms,this);

		} else {

					// For monitored and startup query items
				controlledHelper.doControlledItem (command, isStartupQuery,comfortString, configHelper, cache, comms, this);
			}
			sendNextCommandInQueue();
	}


	public void sendNextCommandInQueue () throws CommsFail {
		synchronized (comms) {
			comms.gotFeedback();
			comms.acknowledgeCommand("");
			comms.sendNextCommand();
		}
	}

	public void sendToFlash (CommandInterface command) {
		cache.setCachedCommand(command.getDisplayName(),command);
		commandQueue.add(command);
	}


	public void sendKeypress (CommandInterface command) throws CommsFail {
		synchronized (comms) {
			if (connected) outputHelper.sendKeypress(command,comms);
		}
	}

	public int login(User user)
		throws CommsFail {
		String LoginString = STX+"LI"+user.getPassword()+ETX ;
		synchronized (comms) {
			if (comms.isConnected()){
				outputHelper.sendToComfort (LoginString,"Login", comms);
				return DeviceModel.SUCCESS;
			}
			else{
				return DeviceModel.FAIL;
			}
		}
	}

	public void doStartup() throws CommsFail  {
		startup.doStartup(configHelper, comms);
		analogueReader.setComms(comms);
		long analoguePoll = 30000; //default to every 30 seconds
		String analoguePollValue = (String)this.getParameterValue("ANALOGUE_POLL_VALUE",DeviceModel.MAIN_DEVICE_GROUP);
		if (analoguePollValue != null && !analoguePollValue.equals( (""))){
			try {
				analoguePoll = Long.parseLong(analoguePollValue);
			} catch (NumberFormatException ex) {
				analoguePoll = 5000;
			}
		}
		if (analoguePoll < 5000) analoguePoll = 5000; // 5 seconds minimum to make sure we don't flood comfort.
		analogueReader.setPollValue(analoguePoll);
		analogueReader.start();

		String applicationCodeParam = ((String)this.getParameterValue("CBUS_APPLICATION",DeviceModel.MAIN_DEVICE_GROUP));
		if (applicationCodeParam == null || applicationCodeParam.equals (""))
			applicationCode = "38";
		else {
			applicationCode = applicationCodeParam;
		}
		outputHelper.setApplicationCode(applicationCode);

		String cbus_ucm = (String)this.getParameterValue("CBUS_UCM",DeviceModel.MAIN_DEVICE_GROUP);
		this.outputHelper.setCBUS_UCM(cbus_ucm);
	}

	public int logout(User user)
		throws CommsFail {
		logged_in = false;
		String LogoutString = STX+"LI00"+ETX;
		synchronized (comms) {
			if (comms.isConnected()){
				outputHelper.sendToComfort (LogoutString,"Logout", comms);
				return DeviceModel.SUCCESS;
			}
			else{
				return DeviceModel.FAIL;
			}
		}
	}

	public boolean isLoggedIn () {
		return logged_in;
	}

	public void setLoggedIn (boolean logged_in) {
		this.logged_in = logged_in;
	}


	public boolean reEstablishConnection () {

		return false;
	}

	public void setSTX (String STX)
	{
		this.STX = STX;
		startup.setSTX(STX);
		outputHelper.setSTX (STX);
		controlledHelper.setSTX (STX);
		analogueReader.setSTX (STX);
	}

	public void setETX (String ETX)
	{
		this.ETX = ETX;
		startup.setETX(ETX);
		outputHelper.setETX (ETX);
		controlledHelper.setETX (ETX);
		analogueReader.setETX (ETX);
	}


	public void close() throws ConnectionFail {
	    if (analogueReader != null)
	        analogueReader.setRunning(false);
	    super.close();
	}

}
