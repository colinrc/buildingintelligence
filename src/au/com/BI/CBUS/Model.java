/*
 * Created on Jul 13, 2004
 *
 */
package au.com.BI.CBUS;


import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Device.DeviceType;
import au.com.BI.Flash.ClientCommand;
import au.com.BI.Util.*;
import au.com.BI.User.*;

import java.text.DecimalFormat;
import java.util.*;
import java.util.logging.*;
import au.com.BI.Sensors.*;

import au.com.BI.Label.Label;
import au.com.BI.Lights.*;

public class Model extends SimplifiedModel implements DeviceModel {

	protected String outputCBUSCommand = "";
	protected HashMap <String,StateOfGroup>state;
	protected char STX=' ';
	protected char ETX='\r';
	protected String applicationCode = "38";
	protected byte applicationCodeByte = 0x38;
	protected HashSet <String>applicationCodes = null;
	protected CBUSHelper cBUSHelper;

	protected long lastSentTime = 0;
	protected char currentChar = 'g';
	protected LinkedList <SensorFascade>temperatureSensors = null;
	protected LinkedList <Label>labels = null;
	protected PollTemperatures pollTemperatures = null;
	protected long tempPollValue = 0L;
	protected int tildeCount = 0;
	protected boolean finishedStartup = false;
	protected MMIHelpers mMIHelpers;
	protected char  lastCharOfHandshake = 'a';
	protected SliderPulse sliderPulse = null;

	int []etxChars;
	String etxString = "";

	public Model () {
		super();

		state = new HashMap<String,StateOfGroup>(128);
		applicationCodes = new HashSet<String>(10);
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		cBUSHelper = new CBUSHelper();

		temperatureSensors = new LinkedList<SensorFascade>();
		labels = new LinkedList<Label>();
		mMIHelpers = new MMIHelpers(cBUSHelper, configHelper, comms, state, this);
		etxChars = new int[] {'.','$','%','#','!','\''};

		etxString = new String(".$%#!\'");
		this.setPadding(2);
		this.setInterCommandInterval(0);

	}


	/**
	 * @return Returns the eTX.
	 */
	public char getETX() {
		return ETX;
	}

	/**
	 * @param etx The eTX to set.
	 */
	public void setETX(char etx) {
		ETX = etx;
	}

	public void clearItems () {
		state.clear();
		applicationCodes.clear();
		mMIHelpers.clearAllLevelMMIQueues();
		synchronized (temperatureSensors) {
			temperatureSensors.clear();
		}
		synchronized (labels) {
			labels.clear();
		}
		super.clearItems();
	}

	public void attatchComms()
	throws ConnectionFail {

		super.setETXArray (etxChars);
		super.attatchComms();
	}
	/*
	public void doClientStartup (List commandQueue, long targetFlashDeviceID) {

		Iterator cBUSDevices = configHelper.getAllControlledDevices();
		while (cBUSDevices.hasNext()){
			CBUSDevice cBUSDevice = (CBUSDevice)(cBUSDevices.next());
			doClientStartup (commandQueue, targetFlashDeviceID, cBUSDevice);

		}
	}

	public void doClientStartup (List commandQueue, long targetFlashDeviceID, CBUSDevice cBUS) {
		StateOfGroup theState = (StateOfGroup)state.get(cBUSHelper.buildKey(cBUS.getApplicationCode(), cBUS.getKey()));
		try {
			CBUSCommand cbusCommand = (CBUSCommand)((CBUS)cBUS).buildDisplayCommand ();
			cbusCommand.setCommand (theState.getPower());
			cbusCommand.setExtraInfo(String.valueOf(theState.getLevel()));
			cbusCommand.setKey ("CLIENT_SEND");

			this.sendToFlash(-1,cbusCommand);
		} catch (ClassCastException ex){

		}

	}
	 */


	public void addControlledItem (String name, DeviceType details, MessageDirection controlType) {

		try {
			CBUSDevice device = (CBUSDevice)details;

			String theKey = name;
			if (controlType == MessageDirection.FROM_HARDWARE)  {
				if (details.getDeviceType() == DeviceType.LIGHT_CBUS) {
					String appCode = device.getApplicationCode() ;
					theKey = cBUSHelper.buildKey(appCode,name, details.getDeviceType() );
					applicationCodes.add(appCode);
				}
				if (details.getDeviceType() == DeviceType.SENSOR) {
					theKey = name;
				}
				if (details.getDeviceType() == DeviceType.THERMOSTAT_CBUS) {
					String appCode = device.getApplicationCode() ;
					theKey = cBUSHelper.buildKey(appCode,name, details.getDeviceType() );;
				}
				if (details.getDeviceType() == DeviceType.LABEL) {
					String appCode = device.getApplicationCode() ;
					theKey = cBUSHelper.buildKey(appCode,name,DeviceType.LABEL);
					applicationCodes.add(appCode);
				}
			}

			configHelper.addControlledItem (theKey, details, controlType);
		} catch (ClassCastException ex) {
			logger.log( Level.WARNING,"Attempted to add an incorrect device type to the CBUS model");
		}
	}
	/**
	 * 
	 * @param cbusDevice
	 * @return
	 */
	public int getStateLevel (CBUSDevice cbusDevice) {
		String theKey = cBUSHelper.buildKey(cbusDevice.getApplicationCode(),cbusDevice.getKey(),cbusDevice.getDeviceType());
		if (!state.containsKey(theKey)) return 100;

		StateOfGroup  cBusState = (StateOfGroup)state.get(theKey);
		return cBusState.getLevel();
	}
	/**
	 * Called by sendOutput to update the state model
	 * @param cbusDevice
	 * @param command
	 * @param extra
	 * @return
	 */
	public boolean setState (CBUSDevice cbusDevice, String command, int extra){
		String theKey = cBUSHelper.buildKey(cbusDevice.getApplicationCode(),cbusDevice.getKey(),cbusDevice.getDeviceType());
		StateOfGroup cBusState = null;
		if (state.containsKey(theKey)) {
			cBusState = (StateOfGroup)state.get(theKey);
		} else {
			cBusState = new StateOfGroup();
		}

		cBusState.setPower(command,false);
		cBusState.setLevel(extra,false);
		cBusState.setCountConflict(0);

		state.put(theKey,cBusState);
		return cBusState.isDirty;
	}
	/**
	 * 
	 * @param theKey
	 * @param command
	 * @param extra
	 * @return
	 */
	public boolean setState (String theKey, String command, int extra){
		StateOfGroup cBusState = null;
		if (state.containsKey(theKey)) {
			cBusState = (StateOfGroup)state.get(theKey);
		} else {
			cBusState = new StateOfGroup();
		}

		cBusState.setPower(command,false);
		cBusState.setLevel(extra,false);
		cBusState.setCountConflict(0);

		state.put(theKey,cBusState);
		return cBusState.isDirty;
	}
	/**
	 * Not actually called when setting the state from flash, is called when setting the 
	 * state from the wall to set the setfromclient to false.
	 * TODO can we remove this and add the negation to the from wall method?
	 * @param cbusDevice
	 * @param flashControl
	 * @return true if we have changed the cbus state
	 */
	public boolean setStateFromFlash (CBUSDevice cbusDevice, boolean flashControl){
		String theKey = cBUSHelper.buildKey(cbusDevice.getApplicationCode(),cbusDevice.getKey(),cbusDevice.getDeviceType());
		StateOfGroup cBusState = null;
		if (state.containsKey(theKey)) {
			cBusState = (StateOfGroup)state.get(theKey);
		} else {
			cBusState = new StateOfGroup();
		}
		cBusState.setFromClient(flashControl);

		state.put(theKey,cBusState);
		return cBusState.isDirty;
	}
	/**
	 * Called by doControlledItem when a Command comes in from the wall controller,
	 * sets the cbus state to handle the command
	 * @param cbusDevice 
	 * @param wallControl
	 * @return true if we have changed the cbus state
	 */
	public boolean setStateFromWallPanel(CBUSDevice cbusDevice, boolean wallControl){
		String theKey = cBUSHelper.buildKey(cbusDevice.getApplicationCode(),cbusDevice.getKey(), cbusDevice.getDeviceType());
		StateOfGroup cBusState = null;
		if (state.containsKey(theKey)) {
			cBusState = (StateOfGroup)state.get(theKey);
		} else {
			cBusState = new StateOfGroup();
		}
		cBusState.setFromWall(wallControl);

		state.put(theKey,cBusState);
		return cBusState.isDirty;
	}
	/**
	 * 
	 * @param cbusDevice
	 * @return
	 */
	public boolean getStateFromFlash (CBUSDevice cbusDevice){
		String theKey = cBUSHelper.buildKey(cbusDevice.getApplicationCode(),cbusDevice.getKey(), cbusDevice.getDeviceType());
		StateOfGroup cBusState = (StateOfGroup)state.get(theKey);
		if (cBusState != null) {
			return cBusState.isFromClient();
		}else {
			return false;
		}
	}
	/**
	 * Called when script or flash changes state of a cbus device
	 * @param cbusDevice
	 * @param cBusState
	 * @return
	 */
	public boolean setState (CBUSDevice cbusDevice, StateOfGroup cBusState){
		String theKey = cBUSHelper.buildKey(cbusDevice.getApplicationCode(),cbusDevice.getKey(),cbusDevice.getDeviceType());

		state.put(theKey,cBusState);
		return cBusState.isDirty;
	}
	/**
	 * 
	 * @param cbusDevice
	 * @param power
	 * @param level
	 * @return
	 */
	public boolean testState (CBUSDevice cbusDevice,String power, String level) {
		String theKey = cBUSHelper.buildKey(cbusDevice.getApplicationCode(),cbusDevice.getKey(), cbusDevice.getDeviceType());
		return testState (theKey,power,level);
	}
	/**
	 * Called by MMI when we are initializing the system to the current cbus state
	 * @param theKey
	 * @param power
	 * @param levelStr
	 * @return
	 */
	public boolean testState (String theKey,String power, String levelStr) {

		try{
			int level = Integer.parseInt(levelStr);
			return testState (theKey,power,level);
		} catch (NumberFormatException ex) {
			return false;
		}
	}
	/**
	 * Called by MMI when we are initializing the system to the current cbus state
	 * @param theKey
	 * @param power
	 * @param level
	 * @return
	 */
	public boolean testState (String theKey,String power, int level) {
		StateOfGroup stateOfGroup = this.getCurrentState(theKey);
		if (stateOfGroup == null) return false;
		if (!stateOfGroup.getPower().equals(power)) return false;

		if (stateOfGroup.getLevel() != level) return false;
		return true;
	}
	/**
	 * 
	 * @param cbusDevice
	 */
	public void setStateClean (CBUSDevice cbusDevice) {
		String theKey = cBUSHelper.buildKey(cbusDevice.getApplicationCode(),cbusDevice.getKey(),cbusDevice.getDeviceType());
		if (state.containsKey(theKey)) {
			StateOfGroup cBusState = (StateOfGroup)state.get(theKey);
			cBusState.isDirty = false;
			state.put( theKey,cBusState);
		}
	}
	/**
	 * 
	 */
	public void addStartupQueryItem (String name, Object details, MessageDirection controlType) {
		try {
			if (((DeviceType)details).getDeviceType() == DeviceType.TEMPERATURE ){
				temperatureSensors.add ((SensorFascade)details);
			}

		} catch (ClassCastException ex) {
			logger.log (Level.FINE,"A temperature sensor was added that was not the expected type " + ex.getMessage());
		}

		try {
			if (((DeviceType)details).getDeviceType() == DeviceType.LABEL ){
				labels.add ((Label)details);
			}

		} catch (ClassCastException ex) {
			logger.log (Level.FINE,"A label was added that was not the expected type " + ex.getMessage());
		}
	}
	/**
	 * 
	 */
	public void doStartup() throws CommsFail {
		tildeCount = 0;
		this.mMIHelpers.comms = comms; //just to be sure.
		sliderPulse = new SliderPulse();
		super.doStartup();

		if (applicationCodes.isEmpty()) applicationCodes.add("38");
		// CommsCommand cbusCommsCommand = new CommsCommand();
		//   cbusCommsCommand.setCommand("~~"+ETX);
		// set basic at first , don't bother queueing for this.
		comms.sendString("~~"+ETX);
	}
	/**
	 * 
	 * @throws CommsFail
	 */
	public void doRestOfStartup () throws CommsFail {

		String pollTempStr = (String)this.getParameterValue("POLL_TEMP_INTERVAL", DeviceModel.MAIN_DEVICE_GROUP);

		if (sliderPulse != null) {
			sliderPulse.setRunning (false);
			sliderPulse = new SliderPulse();
		}

		String completeDimTimeStr = this.getParameterValue("COMPLETE_DIM_TIME", DeviceModel.MAIN_DEVICE_GROUP);

		if (completeDimTimeStr != null ){
			try {
				int completeDimTime = Integer.parseInt(completeDimTimeStr);
				sliderPulse.setDelayInterval(completeDimTime);
			} catch (NumberFormatException ex){
				logger.log (Level.WARNING,"The complete dim time (parameter COMPLETE_DIM_TIME was incorrectly specified, a default of 5 seconds will be used. " + ex.getMessage());
			}
		}

		sliderPulse.setCommandQueue(commandQueue);
		sliderPulse.setDeviceNumber(InstanceID);
		sliderPulse.setCBUSModel(this);
		sliderPulse.setCache(cache);
		sliderPulse.start();

		try {
			tempPollValue = Long.parseLong(pollTempStr) * 1000;
		} catch (NumberFormatException ex) {
			tempPollValue = 0L;
		}
		setCBUSParameters ();

		if (!temperatureSensors.isEmpty() && tempPollValue != 0L) {
			if  (pollTemperatures != null) pollTemperatures.setRunning(false); // switch off any which may have already existed
			pollTemperatures = new PollTemperatures();
			pollTemperatures.setPollValue(tempPollValue);
			pollTemperatures.setTemperatureSensors(temperatureSensors);
			pollTemperatures.setCommandQueue(commandQueue);
			pollTemperatures.setDeviceNumber(InstanceID);
			pollTemperatures.setComms(comms);
			pollTemperatures.start();
		} else {
			logger.log(Level.FINE,"Not starting temperature polls");
		}

		for (Label label: labels){
			String currentChar = this.nextKey();
			String toSend = this.buildCBUSLabelString(label, new ClientCommand(label.getOutputKey(),"label",null,label.getDefaultLabel(),"","","",""), currentChar);
			logger.log (Level.FINER, "Setting default label for " + label.getOutputKey() + ":" + label.getDefaultLabel());

			CommsCommand cbusCommsCommand = new CommsCommand();
			cbusCommsCommand.setActionCode (currentChar);
			cbusCommsCommand.setKeepForHandshake(true);
			cbusCommsCommand.setCommand(toSend);
			cbusCommsCommand.setExtraInfo (label.getOutputKey());

			comms.addCommandToQueue (cbusCommsCommand);
		}
	}
	/**
	 * 
	 * @throws CommsFail
	 */
	public void requestAllLevels () throws CommsFail{
		mMIHelpers.clearAllLevelMMIQueues();
		for (DeviceType eachDevice:configHelper.getAllControlledDeviceObjects()) {
			try {
				CBUSDevice nextDevice = (CBUSDevice)eachDevice;

				if (nextDevice.getDeviceType() == DeviceType.LIGHT_CBUS && nextDevice.supportsLevelMMI()) {
					mMIHelpers.sendExtendedQuery(nextDevice.getKey(),nextDevice.getApplicationCode(),null,false,"0");
				}
			}catch (ClassCastException ex) {
				logger.log (Level.WARNING,"A device has been configured in the CBUS configuration area that is not a CBUS device");
			}
		}
		mMIHelpers.sendAllLevelMMIQueues();
	}
	/**
	 * 
	 * @return
	 * @throws CommsFail
	 */
	public boolean setCBUSParameters () throws CommsFail{
		// Ensure MMI messages are switched on
		try {

			CommsCommand cbusCommsCommand1 = new CommsCommand();
			String toSend = "A32100FF"; // param 21 = FF = control all app numbers
			// String checkSum = this.calcChecksum(toSend);
			String actionCode = this.nextKey();
			cbusCommsCommand1.setActionCode(actionCode);
			cbusCommsCommand1.setKeepForHandshake(true);
			cbusCommsCommand1.setCommand("@"+toSend + actionCode +ETX);  // interface should be in basic mode at this stage, so no checksum should be sent.
			//new byte [] {(byte)0xA3,(byte)0x21,(byte)00, applicationCode,'g',(byte)ETX});

			CommsCommand cbusCommsCommand2 = new CommsCommand();
			String toSend2 = "A32200FF"; // param 22 = FF = unused
			cbusCommsCommand2.setKeepForHandshake(true);
			actionCode = this.nextKey();
			cbusCommsCommand2.setActionCode(actionCode);
			// String checkSum = this.calcChecksum(toSend);
			cbusCommsCommand2.setCommand("@"+toSend2 + actionCode+ETX);  // interface should be in basic mode at this stage, so no checksum should be sent.

			CommsCommand cbusCommsCommand3 = new CommsCommand();
			String toSend3 = "A3300029"; // 30 = option 1; CONNECT|SRCHK|MONITOR
			actionCode = this.nextKey();
			cbusCommsCommand3.setActionCode(actionCode);
			cbusCommsCommand3.setCommand("@"+toSend3 + actionCode+ ETX);
			cbusCommsCommand3.setKeepForHandshake(true);

			CommsCommand cbusCommsCommand4 = new CommsCommand();
			String toSend4 = "A3410029";  // Set power up mode to teh same as current operation mode
			String checkSum = cBUSHelper.calcChecksum(toSend4);
			actionCode = this.nextKey();
			cbusCommsCommand4.setActionCode(actionCode);
			cbusCommsCommand4.setCommand("@"+toSend4 + checkSum+  actionCode+ETX);
			cbusCommsCommand4.setKeepForHandshake(true);

			CommsCommand cbusCommsCommand5 = new CommsCommand();
			String toSend5 = "A3420006"; // power up notification on , LOCAL_SAL on
			checkSum = cBUSHelper.calcChecksum(toSend5);
			actionCode = this.nextKey();
			cbusCommsCommand5.setActionCode(actionCode);
			cbusCommsCommand5.setCommand("@"+ toSend5  +checkSum + actionCode+ ETX);
			cbusCommsCommand5.setKeepForHandshake(true);
			lastCharOfHandshake = actionCode.charAt(0);

			comms.addCommandToQueue (cbusCommsCommand1);
			comms.addCommandToQueue (cbusCommsCommand2);
			comms.addCommandToQueue (cbusCommsCommand3);
			comms.addCommandToQueue (cbusCommsCommand4);
			comms.addCommandToQueue (cbusCommsCommand5);
			return true;
		} catch (CommsFail e1) {
			throw new CommsFail ("Communication failed communicating with CBUS " + e1.getMessage());
		}

	}
	/**
	 * 
	 */
	public int logout(User user) throws CommsFail {
		pollTemperatures.setRunning(false);
		return DeviceModel.SUCCESS;
	}
	/**
	 * 
	 */
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
	/**
	 * Sends a command to the CBUS device specified in the command parameter, 
	 * used by scripts and clients to send commands to the devices attached 
	 * to the cbus
	 * 
	 * @param command	The command to send, encapsulates all of the info	
	 */
	public void doOutputItem (CommandInterface command) throws CommsFail {
		String theWholeKey = command.getKey();
		DeviceType device = configHelper.getOutputItem(theWholeKey);

		if (device == null) {
			logger.log(Level.SEVERE, "Error in config, no output key for " + theWholeKey);
		}
		else {

			String outputCbusCommand = null;
			cache.setCachedCommand(command.getKey(),command);

			logger.log(Level.FINER, "Monitored CBUS event sending to group " + device.getKey());

			switch (device.getDeviceType()) {
			case DeviceType.LIGHT_CBUS :
				String currentChar = this.nextKey();
				LightFascade lightDevice = (LightFascade)device;
				String fullKey = this.cBUSHelper.buildKey(lightDevice.getApplicationCode(),lightDevice.getKey(),lightDevice.getDeviceType());
				mMIHelpers.sendingExtended.remove(fullKey);  
				// the build cbusstring will add a new entry if a new ramp has been sent
				// ensure that Level CBUS returns will not be decoded, as the user has done an action since

				if ((outputCbusCommand = buildCBUSLightString ((LightFascade)device,command,currentChar)) != null) {


					CommsCommand cbusCommsCommand = new CommsCommand();
					cbusCommsCommand.setActionCode (currentChar);
					cbusCommsCommand.setKeepForHandshake(true);
					cbusCommsCommand.setCommand(outputCbusCommand);
					cbusCommsCommand.setExtraInfo (((LightFascade)(device)).getOutputKey());

					try {
						//comms.sendCommandAndKeepInSentQueue (cbusCommsCommand);
						comms.addCommandToQueue (cbusCommsCommand);
					} catch (CommsFail e1) {
						logger.log(Level.WARNING, "Communication failed communicating with CBUS " + e1.getMessage());
						throw new CommsFail ("Error communicating with CBUS");
					}
					logger.log (Level.FINEST,"Queueing cbus command " + currentChar + " for " + (String)cbusCommsCommand.getExtraInfo());

				}

				break;

			case DeviceType.LABEL: 
			{
				String currentCbusKey = this.nextKey();
				Label label = (Label)device;
				String fullKeyLabel = this.cBUSHelper.buildKey(label.getApplicationCode(),label.getKey(),device.getDeviceType());
				String commandCode = command.getCommandCode();
				if (commandCode.equals ("label")) {
					if ((outputCbusCommand = buildCBUSLabelString (label,command,currentCbusKey)) != null) {


						CommsCommand cbusCommsCommand = new CommsCommand();
						cbusCommsCommand.setActionCode (currentCbusKey);
						cbusCommsCommand.setKeepForHandshake(true);
						cbusCommsCommand.setCommand(outputCbusCommand);
						cbusCommsCommand.setExtraInfo (label.getOutputKey());

						try {
							//comms.sendCommandAndKeepInSentQueue (cbusCommsCommand);
							comms.addCommandToQueue (cbusCommsCommand);
						} catch (CommsFail e1) {
							logger.log(Level.WARNING, "Communication failed communicating with CBUS " + e1.getMessage());
							throw new CommsFail ("Error communicating with CBUS");
						}
						logger.log (Level.FINEST,"Queueing cbus command " + currentCbusKey + " for " + (String)cbusCommsCommand.getExtraInfo());
					}
				} 
				if (commandCode.equals ("on") || commandCode.equals("off")) {
					mMIHelpers.sendingExtended.remove(fullKeyLabel);  
					// the build cbusstring will add a new entry if a new ramp has been sent
					// ensure that Level CBUS returns will not be decoded, as the user has done an action since

					if ((outputCbusCommand = buildCBUSLightString (label,command,currentCbusKey)) != null) {


						CommsCommand cbusCommsCommand = new CommsCommand();
						cbusCommsCommand.setActionCode (currentCbusKey);
						cbusCommsCommand.setKeepForHandshake(true);
						cbusCommsCommand.setCommand(outputCbusCommand);
						cbusCommsCommand.setExtraInfo (label.getOutputKey());

						try {
							//comms.sendCommandAndKeepInSentQueue (cbusCommsCommand);
							comms.addCommandToQueue (cbusCommsCommand);
						} catch (CommsFail e1) {
							logger.log(Level.WARNING, "Communication failed communicating with CBUS " + e1.getMessage());
							throw new CommsFail ("Error communicating with CBUS");
						}
						logger.log (Level.FINEST,"Queueing cbus command " + currentCbusKey + " for " + (String)cbusCommsCommand.getExtraInfo());
					}
				}
				break;
			}
			case DeviceType.THERMOSTAT_CBUS:
			{
				String currentCbusKey = this.nextKey();
				SensorFascade sensor = (SensorFascade) device;
				String fullKeySensor = this.cBUSHelper.buildKey(sensor.getApplicationCode(),sensor.getKey(),device.getDeviceType());
				String commandCode = command.getCommandCode();
				// on - off - set-point - cool - heat
				if (commandCode.equals ("on") || commandCode.equals("off")) {
					mMIHelpers.sendingExtended.remove(fullKeySensor);

					// if command is on or off build a light string for relay
					if ((outputCbusCommand = buildCBUSLightString (sensor,command,currentCbusKey)) != null) {

						CommsCommand cbusCommsCommand = new CommsCommand();
						cbusCommsCommand.setActionCode (currentCbusKey);
						cbusCommsCommand.setKeepForHandshake(true);
						cbusCommsCommand.setCommand(outputCbusCommand);
						cbusCommsCommand.setExtraInfo (sensor.getOutputKey());

						try {
							//comms.sendCommandAndKeepInSentQueue (cbusCommsCommand);
							comms.addCommandToQueue (cbusCommsCommand);
						} catch (CommsFail e1) {
							logger.log(Level.WARNING, "Communication failed communicating with CBUS " + e1.getMessage());
							throw new CommsFail ("Error communicating with CBUS");
						}
						logger.log (Level.FINEST,"Queueing cbus command " + currentCbusKey + " for " + (String)cbusCommsCommand.getExtraInfo());
					}
				}				
				else {
					// if it is any other command we need to build an aircon command
					if ((outputCbusCommand = buildCBUSAirconString (sensor,command,currentCbusKey)) != null) {

						CommsCommand cbusCommsCommand = new CommsCommand();
						cbusCommsCommand.setActionCode (currentCbusKey);
						cbusCommsCommand.setKeepForHandshake(true);
						cbusCommsCommand.setCommand(outputCbusCommand);
						cbusCommsCommand.setExtraInfo (sensor.getOutputKey());

						try {
							//comms.sendCommandAndKeepInSentQueue (cbusCommsCommand);
							comms.addCommandToQueue (cbusCommsCommand);
						} catch (CommsFail e1) {
							logger.log(Level.WARNING, "Communication failed communicating with CBUS " + e1.getMessage());
							throw new CommsFail ("Error communicating with CBUS");
						}
						logger.log (Level.FINEST,"Queueing cbus command " + currentCbusKey + " for " + (String)cbusCommsCommand.getExtraInfo());
					}
				}
				break;
			}
			default:
				logger.log(Level.FINE, "CBUS: message not handled:"+ theWholeKey);
				break;
			}
		}
	}
	/**
	 * Controlled item is the default item type.
	 * The system will call this function if the command is not from flash.
	 * ie. the command is from the serial port.
	 * @param command	The command to handle, encapsulates all of the data
	 */
	public void doControlledItem (CommandInterface command) throws CommsFail
	{
		String cBUSString = command.getKey().trim();
		logger.log(Level.FINER, "Parsing : " + cBUSString );
		User currentUser = command.getUser();

		try 
		{
			// first handle the odd commands, either error or startup
			if (exceptionCommands(cBUSString))
				return; // shortcut for processing of exception commands, ensure they don't flow into the normal command handling.

			// now do the normal commands
			normalCommands(cBUSString, currentUser);

		} catch (IndexOutOfBoundsException inEx) {
		}
	}
	/**
	 * Handle normal command processing
	 * refer to Clipsal Serial Interface User Guide (firmware version 4)
	 * document number: CBUS-SIUG
	 */
	private void normalCommands(String cBUSString, User currentUser) {
		// normal command processing
		int cbusStartByte = 0;
		try 
		{
			// get the command header byte
			cbusStartByte = Integer.parseInt(cBUSString.substring(0,2),16);
		} 
		catch (NumberFormatException ex) {
			logger.log (Level.FINEST,"Trying to parse MMI message but the first byte is not hex " + ex.getMessage());
			return;
		}

		int prioritylevel  = cbusStartByte & 0xC0; 	// top 2 bits of command byte
		int commandType = cbusStartByte & 0x3F; 	// last 3 bits of command byte + other status

		// if the priority bits are 0xC0 (11xxxxxx), then we are an MMI
		if (prioritylevel == 0xC0)
		{
			// we have a status reply, either standard or extended
			// the commandType == number of bytes following (max seems to be 0x1F..?)
			if (finishedStartup && commandType < 32) {
				logger.log(Level.FINER, "STATUS command received");
				mMIHelpers.processMMI (cBUSString, currentUser);
			}
			else if (commandType  >= 32){
				logger.log(Level.FINER, "EXTENDED STATUS command received");
				mMIHelpers.processLevelMMI (cBUSString,currentUser);
			}
			// shortcut out we have dealt with the command
			return;
		}

		// now the priority levels are very interesting and somewhat overloaded..
		// 00 and 01 are user space normal SAL replies
		// 10 and 11 are 'special' and are used for CAL replies and other fancies
		switch (commandType)
		{
		case 0x03: // PtPtMP (SAL)
			logger.log(Level.FINER, "CBUS: PtPtMP command received");
			handlePointToPointToMultiPoint(cBUSString,	currentUser, cbusStartByte);
			break;
		case 0x05: // PtMP (SAL)
			logger.log(Level.FINER, "CBUS: PtMP command received");
			handlePointToMultipoint(cBUSString, currentUser);
			break;
			// CAL commands from here on down...
		case 0x06: // PtP, always CAL
			if (prioritylevel != 0x80) {
				logger.log(Level.FINER, "CBUS: PtP command received");
				handlePointToPoint(cBUSString,	currentUser);
			}
			else {
				// CAL reply always command 0x86
				logger.log(Level.FINER, "CBUS: CAL reply received");
				handleCALReply(cBUSString, currentUser);
			}
			break;
		case 0x08:
			logger.log(Level.FINER, "RESET command received");
			break;
		case 0x1A:
			logger.log(Level.FINER, "RECALL command received");			
			break;
		case 0x21:
			logger.log(Level.FINER, "IDENTIFY command received");
			break;
		case 0x2A:
			logger.log(Level.FINER, "GETSTATUS command received");			
			break;
		case 0x32:
			logger.log(Level.FINER, "ACKNOWLEDGE command received");
			break;
		default: 
			logger.log(Level.FINER, "CBUS: UNKNOWN command received");
			break;
		}
	}
	/**
	 * Handles the CBUS start-up and CBUS error code commands
	 * @param cBUSString - the command string
	 * @return true if there were any commands processed
	 */
	private boolean exceptionCommands(String cBUSString) {
		boolean didCommand = false;

		if (cBUSString.indexOf("~") >= 0 )
		{
			tildeCount ++;
			if (tildeCount > 0) {
				clearAllQueues();
				this.state.clear();
				didCommand = true;
				logger.log (Level.FINE,"Received confirmation of CBUS ~~~ init, sending initial parameters");
				doRestOfStartup();
			}
			// should be covered by next line     requestAllLevels();
			return didCommand;
		}
		if (cBUSString.endsWith("+")) 
		{
			// Power up notification received so reset all parameters.
			clearAllQueues();
			this.state.clear();
			didCommand = true;
			comms.sendString("~~"+ETX); // force the interface back into basic mode
			return didCommand;
		}

		if (cBUSString.contains("!"))
		{

			logger.log (Level.FINER,"CBUS buffer overflow or checksum failure");
			try {
				comms.resendAllSentCommands();
			} catch (CommsFail ex) {
				throw new CommsFail ("Communications failed with CBUS " + ex.getMessage());
			}
			return didCommand;
		}

		if (cBUSString.startsWith("@A3420"))
		{
			logger.log (Level.FINER,"CBUS startup complete, starting normal MMI processing.");
			finishedStartup = true;
			didCommand = true;
		}

		if (cBUSString.startsWith("@A32")) 
		{
			logger.log (Level.FINER,"Received confirmation, change parameter " + cBUSString.substring(3,5));
			didCommand = true;
		}

		if (cBUSString.startsWith("@A34")) 
		{
			logger.log (Level.FINER,"Received confirmation, change parameter " + cBUSString.substring(3,5));
			didCommand = true;
		}

		char lastChar = cBUSString.charAt(cBUSString.length()-1);
		if ( etxString.indexOf(lastChar) >= 0) 
		{
			char secondLastChar = cBUSString.charAt(cBUSString.length()-2);
			if (lastChar == '.')
			{
				logger.log (Level.FINEST,"Received confirmation for command " + secondLastChar);
				if (!finishedStartup && secondLastChar == lastCharOfHandshake)
				{
					logger.log (Level.FINER,"CBUS startup complete, starting normal MMI processing.");
					finishedStartup = true;
				}

				comms.acknowledgeCommand(""+secondLastChar,false);
				comms.sendNextCommand();
			}
			else
			{
				logger.log (Level.FINER,"Command failed " + secondLastChar + ", resending");
				comms.repeatCommand(String.valueOf(secondLastChar));
			}
			return didCommand;
		}
		return didCommand;
	}
	/**
	 * point to point command 0x06 
	 * @return
	 */
	private boolean handlePointToPoint( String cBUSString, User currentUser)
	{
		boolean didCommand = false;
		String commandString = "";
		if (cBUSString.substring(4,6).equals("00"))
			commandString = cBUSString.substring(2);
		else {
			commandString = stripNetwork(cBUSString);
		}

		String cBusGroup = commandString.substring (0,2);
		commandString = commandString.substring(2); // remove the group address now

		// have the group address now figure out what it is
		DeviceType deviceType = configHelper.getControlledItem(cBusGroup);
		if (deviceType == null)
		{
			logger.log(Level.WARNING, "CBUS: No Device defined for group:" + cBusGroup);
		}
		else {
			int deviceInt = deviceType.getDeviceType();
			switch(deviceInt) {
			case DeviceType.LIGHT_CBUS:
				break;
			case DeviceType.SENSOR:
				// we are a temperature device
				didCommand = handleTemperature(commandString, cBusGroup);
				break;
			}
		}
		return didCommand;
	}
	/**
	 * CAL reply command 0x86 
	 * @return
	 */
	private boolean handleCALReply( String cBUSString, User currentUser)
	{
		boolean didCommand = false;
		String commandString = "";
		String cBusGroup = "";
		if (cBUSString.substring(6,8).equals("00")) {
			commandString = cBUSString.substring(8);
			cBusGroup = cBUSString.substring (2,4);
		}
		else {
			commandString = stripNetwork(cBUSString);
			cBusGroup = commandString.substring (2,4);
			commandString = commandString.substring(4); // need to take an extra 4 off for CAL
		}

		DeviceType deviceType = configHelper.getControlledItem(cBusGroup);
		if (deviceType == null)
		{
			logger.log(Level.WARNING, "CBUS: No Device defined for group:" + cBusGroup);
		}
		else {
			int deviceInt = deviceType.getDeviceType();
			switch(deviceInt) {
			case DeviceType.LIGHT_CBUS:
				break;
			case DeviceType.TEMPERATURE:
				// we are a temperature device
				didCommand = handleTemperature(commandString, cBusGroup);
				break;
			}
		}
		return didCommand;
	}
	/**
	 * Strips the network route information from a PtP or PtPMP command
	 * @param cBUSString
	 * @return the string minus the route info
	 */
	private String stripNetwork(String cBUSString) {
		int netHops = 0xFF;
		String retString;
		try {
			netHops = Integer.parseInt(cBUSString.substring(4,6),16);
			switch(netHops) {
			case 0x01: // 1 hop
			case 0x09: // 1 hop
				retString = cBUSString.substring(6);
				break;
			case 0x02: // 2 hops
			case 0x12: // 2 hops
				retString = cBUSString.substring(8);
				break; 
			case 0x03: // 3 hops
			case 0x1B: // 3 hops
				retString = cBUSString.substring(12);
				break; 
			case 0x04: // 4 hops
			case 0x24: // 4 hops
				retString = cBUSString.substring(14);
				break;			
			case 0x05: // 5 hops
			case 0x2D: // 5 hops
				retString = cBUSString.substring(16);
				break; 
			case 0x06: // 6 hops
			case 0x36: // 6 hops
				retString = cBUSString.substring(18);
				break; 
			default:
				logger.log(Level.WARNING, "CBUS: Network path invalid for:" + cBUSString);		
				retString = "";
				break;
			}
		} catch (NumberFormatException ex) {
			retString = "";
		}
		return retString;
	}
	/**
	 * handle a point to point CBUS temperature command
	 * @param	cBUSString The full command
	 * @return	true
	 */
	private boolean handleTemperature(String cBUSString, String cBusGroup) {

		// temperature readings do not have checksum
		SensorFascade cbusDevice = (SensorFascade)configHelper.getControlledItem(cBusGroup);
		if (cbusDevice == null) {
			logger.log(Level.WARNING, "CBUS: No Temperature Device defined for group:" + cBusGroup);
			return false;
		}
		else {
			try {
				this.setStateFromWallPanel(cbusDevice, true);

				logger.log(Level.FINER, "TEMPERATURE command string:" + cBUSString);				
				byte temperature = Byte.parseByte(cBUSString.substring(4, 6),16);
				double exactTemperature =  temperature + ((double)Integer.parseInt(cBUSString.substring(6,8),16)) / 256.0;
				cbusDevice.setLevel(Integer.toString((int)(10*exactTemperature)));
				cbusDevice.setScale(0.1);
				DecimalFormat onePlace = new DecimalFormat("0.0");
				logger.log(Level.FINER, "TEMPERATURE value:" + exactTemperature + " corrected:" + onePlace.format(cbusDevice.getAdjustedLevel()));				
				sendCommandToFlash (cbusDevice,"on",onePlace.format(cbusDevice.getAdjustedLevel()),currentUser);
				this.setState(cBusGroup, "on",temperature);

			} catch (IndexOutOfBoundsException ex){
				logger.log (Level.INFO,"Cbus temperature command is not correctly formatted " + cBUSString);
			}catch (NumberFormatException ex){
				logger.log (Level.INFO,"Cbus temperature command is not correctly formatted " + cBUSString);
			}
		}
		return true;
	}
	/**
	 * Removes the network part and handles the SAL reply
	 * @return true if we handled the command
	 */
	private boolean handlePointToPointToMultiPoint(String cBUSString, User currentUser, int cbusStartByte) {
		boolean didCommand = false;
		try {
			String applicationCode = cBUSString.substring(4,6); // which application group the command is from 
			String commandString = stripNetwork(cBUSString);
			String srcDevice = commandString.substring(0,2); // where the command came from
			logger.log(Level.FINEST, "source device:" + srcDevice + "application: " + applicationCode);

			String restOfString = commandString.substring(2);

			didCommand = handleSALCommand(applicationCode, restOfString);
		}
		catch (IndexOutOfBoundsException ex) {
			logger.log(Level.WARNING, "CBUS point to point to multipoint command, too short");
		}
		catch (NumberFormatException ex) {
			logger.log(Level.WARNING, "CBUS point to point to multipoint command, application ID not a number");
		}
		return didCommand;
	}
	/**
	 * Handle CBUS command 0x05 point to multi-point commands at all command levels
	 * @return true if we handled the command
	 */
	private boolean handlePointToMultipoint(String cBUSString, User currentUser)
	{
		boolean didCommand = false;
		try {

			String srcDevice = cBUSString.substring(2,4); // where the command came from
			String applicationCode = cBUSString.substring(4,6); // which application group the command is for 
			logger.log(Level.FINEST, "source device:" + srcDevice + "application: " + applicationCode);

			String restOfString = "";
			if ((cBUSString.substring(6,8)).equals("00"))
			{
				restOfString = cBUSString.substring(8);
			}
			else if ((cBUSString.substring(6,8)).equals("01") &&
					(cBUSString.substring(8,10)).equals("00"))
			{
				restOfString = cBUSString.substring(10);
			}
			else
				return false;

			didCommand = handleSALCommand(applicationCode, restOfString);
		}
		catch (IndexOutOfBoundsException ex) {
			logger.log(Level.WARNING, "CBUS multipoint command, too short");
		}
		catch (NumberFormatException ex) {
			logger.log(Level.WARNING, "CBUS multipoint command, application ID not a number");
		}

		return didCommand;
	}
	/**
	 * handles a SAL command
	 * @param applicationCode
	 * @param restOfString
	 * @return true if we handled the command
	 */
	private boolean handleSALCommand(String applicationCode, String restOfString) {
		boolean didCommand = false;
		int applicationInt = Integer.parseInt(applicationCode,16);
		switch(applicationInt) {
		case 0xFF:
			// network management
			logger.log(Level.FINER, "CBUS multipoint command, network management");
			break;
		case 0xCA:
			// triggering (scenes)
			didCommand = cBUSHelper.handleScene(restOfString);
			break;
		case 0x19:
			// temperature broadcast
			logger.log(Level.FINER, "CBUS multipoint command, temperature broadcast");
			break;
		case 0xE4:
			// measurement
			didCommand = handleMeasurement(restOfString);
			break;
		case 0x71:
			// irrigation control
			logger.log(Level.FINER, "CBUS multipoint command, irrigation control");
			break;
		case 0xAC:
			// handle air-conditioning
			logger.log(Level.FINER, "CBUS multipoint command, HVAC control");
			didCommand = handleAirCon(restOfString);
			break;
		case 0x73:
		case 0x74:
			// handle air-conditioning actuators
			logger.log(Level.FINER, "CBUS multipoint command, HVAC actuators");
			break;
		default:
			// lighting probably, has the biggest range
			if ((applicationInt >= 0x30) && (applicationInt <= 0x5F)) {
				// handle a lighting command
				didCommand = handleLighting(applicationCode,restOfString);
			}
			else {
				// handle an unknown type command, print a warning...
				logger.log(Level.WARNING, "CBUS multipoint command, unknown application:" + applicationCode);
			}
			break;
		}
		return didCommand;
	}
	/**
	 * Handle measurement group commands, loops through the string
	 * @param 	restOfString	The command string 
	 * @return	false - we are not handling this yet
	 */
	private boolean handleMeasurement(String restOfString) {
		boolean didCommand = false;

		do {
			String commandCode = restOfString.substring(0,2); // the command byte
			int commandInt = Integer.parseInt(commandCode,16);
			int argc = commandInt & 0x07;
			commandInt = commandInt & 0x78;
			String currentCommand = restOfString.substring(0, 2 + argc*2);
			// handle current command
			logger.log(Level.FINER, "command code:" + commandInt +",arguments: " + argc + ",current command:" + currentCommand);
			// trim the command to the next one
			try {
				restOfString = restOfString.substring(2 + argc*2);
			} catch (IndexOutOfBoundsException e)
			{
				restOfString = "";
			}
		} while (restOfString.length() >= 4);

		return didCommand;
	}
	/**
	 * Handle measurement group commands, loops through the string
	 * @param 	restOfString	The command string 
	 * @return	false - we are not handling this yet
	 */
	private boolean handleAirCon(String restOfString) {
		boolean didCommand = false;

		do {
			String commandCode = restOfString.substring(0,2); // the command byte
			int commandInt = Integer.parseInt(commandCode,16);
			int argc = commandInt & 0x07;
			commandInt = commandInt & 0x78;
			String currentCommand = restOfString.substring(0, 2 + argc*2);
			// handle current command
			logger.log(Level.FINE, "command code:" + commandInt +",arguments: " + argc + ",current command:" + currentCommand);
			handleSingleAirCon(currentCommand);
			// trim the command to the next one
			try {
				restOfString = restOfString.substring(2 + argc*2);
			} catch (IndexOutOfBoundsException e)
			{
				restOfString = "";
			}
		} while (restOfString.length() >= 4);

		return didCommand;
	}
	/**
	 * Handles a single aircon command out of the possibly multi-part command string
	 * @param currentCommand
	 * @return
	 * TODO Should look at writing helpers for each of the applications LightingHelper / AirconHelper etc
	 */
	private boolean handleSingleAirCon(String currentCommand) {

		boolean didCommand = false;

		try {
			String applicationCode = "AC"; 
			String commandCode = currentCommand.substring(0,2); // the command byte
			int commandInt = Integer.parseInt(commandCode, 16);
			String zoneGroup;
			String zoneList;

			switch (commandInt)
			{
			case 0x05:
				// HVAC plant status
				logger.log(Level.FINE, "CBUS: HVAC: check plant status");			
				didCommand =  true;
				break;
			case 0x0D:
				// humidity plant status
				logger.log(Level.FINE, "CBUS: HVAC: Humidity check plant status");			
				break;
			case 0x15:
			{
				zoneGroup = currentCommand.substring(2,4);
				zoneList = currentCommand.substring(4,6);
				String sensorStatus = currentCommand.substring(10);
				double temperature = (double)Short.parseShort(currentCommand.substring(6,10),16) / 256.0;
				logger.log(Level.FINE, "CBUS: HVAC: temperature:" + temperature + " sensor status:" + sensorStatus);
				
				CBUSDevice cbusDevice = (CBUSDevice)configHelper.getControlledItem(cBUSHelper.buildKey(applicationCode , zoneGroup,DeviceType.THERMOSTAT_CBUS));
				if (cbusDevice == null) {
					logger.log(Level.WARNING, "CBUS: No Air-conditioning Device defined for application:" + applicationCode + " group:" + zoneGroup);
				}
				else {
					// current temperature
					DecimalFormat onePlace = new DecimalFormat("0.0");
					sendCommandToFlash (cbusDevice,"temperature", onePlace.format(temperature),currentUser);
				}
				didCommand =  true;
				break;
			}
			case 0x1D:
			{
				// humidity
				zoneGroup = currentCommand.substring(2,4);
				zoneList = currentCommand.substring(4,6);
				String sensorStatus = currentCommand.substring(10);
				double humidity = (double)Integer.parseInt(currentCommand.substring(6,10),16) / 655.35;

				logger.log(Level.FINE, "CBUS: HVAC: humidity:" + humidity + " sensor status:" + sensorStatus);			
				didCommand = true;
				break;
			}
			case 0x89:
				// HVAC schedule entry
				logger.log(Level.FINE, "CBUS: HVAC: schedule entry");
				break;
			case 0xA9:
				// Humidity schedule entry
				logger.log(Level.FINE, "CBUS: HVAC: Humidity schedule entry");
				break;
			case 0x21:
				// refresh
				logger.log(Level.FINE, "CBUS: HVAC: refresh");
				break;
			case 0x01:
				// set zone off
				zoneGroup = currentCommand.substring(2,4);
				logger.log(Level.FINE, "CBUS: HVAC: set zone off zone:" + zoneGroup);
				break;
			case 0x79:
				// set zone on
				zoneGroup = currentCommand.substring(2,4);
				logger.log(Level.FINE, "CBUS: HVAC: set zone on zone:" + zoneGroup);
				break;
			case 0x2F:
			{
				// set mode 2F010140FF000000
				//          2F01014202160000
				zoneGroup = currentCommand.substring(2,4);
				zoneList = currentCommand.substring(4,6);
				int hvacMode = Integer.parseInt(currentCommand.substring(6,8), 16);
				int hvacType = Integer.parseInt(currentCommand.substring(8,10),16);
				short level = Short.parseShort(currentCommand.substring(10,14),16);
				int auxLevel = Integer.parseInt(currentCommand.substring(14,16),16);
				double levelActual;
				if ((hvacMode & 0x08) == 0x08) {
					// we are in raw mode 
					levelActual = level / 327.67; 
				} else {
					levelActual = level / 256.0;
					CBUSDevice cbusDevice = (CBUSDevice)configHelper.getControlledItem(cBUSHelper.buildKey(applicationCode , zoneGroup,DeviceType.THERMOSTAT_CBUS));
					if (cbusDevice == null) {
						logger.log(Level.WARNING, "CBUS: No Air-conditioning Device defined for application:" + applicationCode + " group:" + zoneGroup);
					}
					else {
						// setpoint temperature
						DecimalFormat onePlace = new DecimalFormat("0.0");
						sendCommandToFlash (cbusDevice,"value", onePlace.format(levelActual),currentUser);
					}
				}

				logger.log(Level.FINE, "CBUS: HVAC: set zone hvac mode zone:" + zoneGroup + " zonelist:" + zoneList + " mode:" + hvacMode + " type:" + hvacType + " level:" + levelActual + " auxLevel:" + auxLevel);
				
				break;
			}
			case 0x36:
			{
				// set plant level (plant level changed)
				zoneGroup = currentCommand.substring(2,4);
				zoneList = currentCommand.substring(4,6);
				int hvacMode = Integer.parseInt(currentCommand.substring(6,8), 16);
				int hvacType = Integer.parseInt(currentCommand.substring(8,10),16);
				byte level = Byte.parseByte(currentCommand.substring(10,12),16);
				int auxLevel = Integer.parseInt(currentCommand.substring(12,14),16);

				logger.log(Level.FINE, "CBUS: HVAC: set plant hvac level zone:" + zoneGroup + " zonelist:" + zoneList + " mode:" + hvacMode + " type:" + hvacType + " level:" + level + " auxLevel:" + auxLevel);
				didCommand = true;
				break;
			}
			case 0x47:
				// set humidity mode
				logger.log(Level.FINE, "CBUS: HVAC: set humidity mode");
				break;
			case 0x4E:
				// set humidity level
				logger.log(Level.FINE, "CBUS: HVAC: set humidity level");
				break;
			case 0x55:
				// set HVAC upper guard limit
				logger.log(Level.FINE, "CBUS: HVAC: upper guard limit");
				break;
			case 0x5D:
				// set HVAC lower guard limit
				logger.log(Level.FINE, "CBUS: HVAC: lower guard limit");
				break;
			case 0x65:
				// set HVAC setback limit
				logger.log(Level.FINE, "CBUS: HVAC: setback limit");
				break;
			case 0x6D:
				// set Humidity upper guard limit
				logger.log(Level.FINE, "CBUS: HVAC: Humidity upper guard limit");
				break;
			case 0x75:
				// set Humidity lower guard limit
				logger.log(Level.FINE, "CBUS: HVAC: Humidity lower guard limit");
				break;
			case 0x7D:
				// set Humidity setback limit
				logger.log(Level.FINE, "CBUS: HVAC: Humidity setback limit");
				break;
			}
		}
		catch (NumberFormatException ex) {}
		catch (IndexOutOfBoundsException ex) {}

		return didCommand;
	}
	/**
	 * Handle lighting group commands, loops through the string handling multi-part commands
	 * @param	applicationCode The received application ID
	 * @param	restOfString The command string with the front trimmed
	 * @return	true if we can process the command
	 */
	private boolean handleLighting(String applicationCode,String restOfString) {

		boolean didCommand = false;

		do {
			String commandCode = restOfString.substring(0,2); // the command byte
			int commandInt = Integer.parseInt(commandCode,16);
			int argc = commandInt & 0x07;
			commandInt = commandInt & 0x78;
			String currentCommand = restOfString.substring(0, 2 + argc*2);
			logger.log(Level.FINER, "command code:" + commandInt +",arguments: " + argc + ",current command:" + currentCommand);
			// handle current command
			didCommand = handleSingleLighting(currentCommand,applicationCode);
			// trim the command to the next one
			try {
				restOfString = restOfString.substring(2 + argc*2);
			} catch (IndexOutOfBoundsException e)
			{
				restOfString = "";
			}
		} while (restOfString.length() >= 4);

		return didCommand;
	}
	/**
	 * Handles a single lighting command out of the possibly multi-part command string
	 * @param currentCommand
	 * @return
	 * TODO Should look at writing helpers for each of the applications LightingHelper / AirconHelper etc
	 */
	private boolean handleSingleLighting(String currentCommand, String applicationCode) {

		String commandCode = currentCommand.substring(0,2); // the command byte
		String cBusGroup = currentCommand.substring(2,4);

		if (commandCode.equals ("09")) {
			CBUSDevice cbusDevice = (CBUSDevice)configHelper.getControlledItem(cBUSHelper.buildKey(applicationCode , cBusGroup,DeviceType.LIGHT_CBUS));
			if (cbusDevice != null) {
				this.setStateFromWallPanel(cbusDevice,true);
				if (!cbusDevice.isRelay())sliderPulse.removeFromQueues(cbusDevice.getOutputKey());
				if (cbusDevice.supportsLevelMMI()) {
					mMIHelpers.sendExtendedQuery (cBusGroup,applicationCode, currentUser, true,"");
					// Main point to trigger a ramp up sequence from a cbus button press
					// Test this to see if it stops sending once 0 or 255 has been reached.
				} else {
					this.setState (cbusDevice,"on",100); 
					sendCommandToFlash (cbusDevice,"on","100",currentUser);
				}
			}
			return true;
		}

		if (commandCode.equals("79")) {

			CBUSDevice cbusDevice = (CBUSDevice)configHelper.getControlledItem(cBUSHelper.buildKey(applicationCode , cBusGroup,DeviceType.LIGHT_CBUS));
			if (cbusDevice == null) {
				logger.log(Level.WARNING, "CBUS: No Lighting Device defined for application:" + applicationCode + " group:" + cBusGroup);
			}
			else {
				this.setStateFromWallPanel(cbusDevice,true);
				if (!cbusDevice.isRelay())sliderPulse.removeFromQueues(cbusDevice.getOutputKey());
				this.setState (cbusDevice,"on",100); 
				sendCommandToFlash (cbusDevice,"on","100",currentUser);
			}
			return true;
		}

		if (commandCode.equals("01")) {
			CBUSDevice cbusDevice = (CBUSDevice)configHelper.getControlledItem(cBUSHelper.buildKey(applicationCode, cBusGroup,DeviceType.LIGHT_CBUS));

			if (cbusDevice == null) {
				logger.log(Level.WARNING, "CBUS: No Lighting Device defined for application:" + applicationCode + " group:" + cBusGroup);
			}
			else {
				this.setStateFromWallPanel(cbusDevice,true);
				if (!cbusDevice.isRelay())sliderPulse.removeFromQueues(cbusDevice.getOutputKey());
				this.setState (cbusDevice,"off",0); 
				sendCommandToFlash (cbusDevice,"off","0",currentUser);
			}
			return true;
		}

		if (cBUSHelper.rampCodes.indexOf(commandCode) > -1) {
			// need to be able to loop the remaining string ramping each of the lights
			String rampLevel = currentCommand.substring(4,6);
			try {
				CBUSDevice cbusDevice = (CBUSDevice)configHelper.getControlledItem(cBUSHelper.buildKey(applicationCode , cBusGroup,DeviceType.LIGHT_CBUS));

				if (cbusDevice == null ) {
					logger.log(Level.WARNING, "CBUS: No Lighting Device defined for application:" + applicationCode + " group:" + cBusGroup);
				}
				else {
					this.setStateFromWallPanel(cbusDevice,true);
					int x = 0;
					try {
						x = Integer.parseInt(rampLevel,16);
					} catch (NumberFormatException ex) {
						logger.log (Level.FINEST,"Received invalid ramp level for Cbus " + rampLevel);
					}
					if (cbusDevice.isRelay()){
						if (x == 0){
							this.setState (cbusDevice,"off",0); 
							sendCommandToFlash (cbusDevice,"off","0",currentUser);
						} else {
							this.setState (cbusDevice,"on",100); 
							sendCommandToFlash (cbusDevice,"on","100",currentUser);									
						}
					}
					else {
						int percLevel = 100 * (x + 2) / cbusDevice.getMax();
						if (percLevel < DeviceModel.FLASH_SLIDER_RES) percLevel = FLASH_SLIDER_RES;

						if (x == 1 || x == cbusDevice.getMax()  && cbusDevice.isGenerateDimmerVals()){
							// indicates start of a fade  while the button is pressed.
							int oldLevel = this.getStateLevel(cbusDevice);

							if (x == 1) 	
								sliderPulse.addToDecreasingQueue(cbusDevice.getOutputKey(), oldLevel);
							else
								sliderPulse.addToIncreasingQueue(cbusDevice.getOutputKey(), oldLevel);

							this.setState (cbusDevice,"on",percLevel); 
							// set the state, but don't send the level to the user, this will occur from sliderPulse

						} else {
							sliderPulse.removeFromQueues(cbusDevice.getOutputKey());

							if (this.setState (cbusDevice,"on",percLevel)) {
								sendCommandToFlash (cbusDevice,"on",String.valueOf(percLevel),currentUser);
							}
						}
					}

				}
			} catch (ClassCastException ex ) {
				logger.log (Level.WARNING,"CBUS level command received from a device that does not support it " + ex.getMessage());
			}
			return true;
		}
		return false;
	}
	/**
	 * 
	 */
	public void clearAllQueues(){
		comms.clearCommandQueue();
		mMIHelpers.cachedMMI.clear();
		mMIHelpers.levelMMIQueues.clear();
		mMIHelpers.sendingExtended.clear();
		mMIHelpers.clearAllLevelMMIQueues();
	}
	/**
	 * 
	 * @param cbusDevice	The cbus device that has changed state
	 * @param command		the command to send (on/off)	
	 * @param extra			Any extra info for the command
	 * @param currentUser	The user sending the command
	 */
	protected void sendCommandToFlash (CBUSDevice cbusDevice,String command,String extra,User currentUser){
		//		this.setState ((CBUSDevice)cbusDevice,command,extra);
		CommandInterface cbusCommand = null;
		if (cbusDevice  instanceof SensorFascade){
			cbusCommand = ((SensorFascade)cbusDevice).buildDisplayCommand ();
		}
		if (cbusDevice instanceof LightFascade){
			cbusCommand = (CBUSCommand)((LightFascade)cbusDevice).buildDisplayCommand ();
		}
		if (cbusDevice instanceof Label){
			cbusCommand = ((Label)cbusDevice).buildDisplayCommand ();
		}
		cbusCommand.setCommand (command);
		cbusCommand.setExtraInfo(extra);
		cbusCommand.setKey ("CLIENT_SEND");
		cbusCommand.setUser(currentUser);
		cache.setCachedCommand(cbusCommand.getDisplayName(),cbusCommand);
		this.setStateClean (cbusDevice);
		this.sendToFlash(-1,cbusCommand);
	}
	/**
	 * Used to send the states received from cbus mmi to the controller command handler  
	 * @param keyStr	The CBUS id of the attached device
	 * @param command	The command to send (on/off)
	 * @param extra		Extra info for the command
	 * @param user		The user sending the command
	 */
	public void sendOutput (String keyStr, String command, String extra,User user) {

		//logger.log (Level.FINEST,"Sending MMI output App Code : "  + appCode + " command " + command + " group " + keyStr);
		DeviceType rawDevice = configHelper.getControlledItem(keyStr);
		try {
			CBUSDevice cbusDevice = (CBUSDevice)rawDevice;

			if (cbusDevice != null) {
				int newLevel;
				try {
					newLevel = Integer.parseInt(extra);
					this.setState (cbusDevice,command, newLevel);
					CommandInterface cbusCommand = null;
					if (command.equals ("off") && !cbusDevice.isRelay())  sliderPulse.removeFromQueues(((DeviceType)cbusDevice).getOutputKey());
					if (cbusDevice  instanceof SensorFascade){
						cbusCommand = ((SensorFascade)cbusDevice).buildDisplayCommand ();
					}
					if (cbusDevice instanceof LightFascade){
						cbusCommand = ((LightFascade)cbusDevice).buildDisplayCommand ();
					}
					if (cbusDevice instanceof Label){
						cbusCommand = ((Label)cbusDevice).buildDisplayCommand ();
					}
					cbusCommand.setCommand (command);
					cbusCommand.setExtraInfo(Integer.toString(newLevel));
					cbusCommand.setKey ("CLIENT_SEND");
					cbusCommand.setUser(user);
					cache.setCachedCommand(cbusCommand.getDisplayName(),cbusCommand);
					this.sendToFlash(-1,cbusCommand);
					this.setStateClean (cbusDevice);
					//logger.log (Level.FINEST,"Sending to flash " + cbusCommand.getDisplayName() + " " + command + " level " + Integer.toString(newLevel));
				} catch (NumberFormatException ex) {
				}
			}
		} catch (ClassCastException ex) {
			logger.log (Level.WARNING,"Non CBUS device reported a CBUS level " +rawDevice.getName() + " " +  ex.getMessage());
		}

	}
	/**
	 * 
	 * @param device
	 * @param command
	 * @param currentChar
	 * @return
	 * @throws CommsFail
	 */
	public String buildCBUSLabelString (Label device, CommandInterface command,String currentChar) throws CommsFail {
		String cBUSOutputString = null;
		boolean commandFound = false;

		String theCommand = command.getCommandCode();
		if (!commandFound && theCommand == "") {
			logger.log(Level.WARNING, "Empty command received from client "+ command.getCommandCode());
			return null;
		}


		if (theCommand.equals("label") ) {
			String catalogueStr = command.getExtraInfo();
			String flavour = command.getExtra2Info();
			if (flavour.equals("")) flavour = "0";
			labelMgr.setLabelState(device.getOutputKey(), catalogueStr);

			String theLabel = labelMgr.getLabelText(catalogueStr);
			cBUSOutputString = cBUSHelper.buildCBUSLabelCommand (device.getApplicationCode(), device.getKey(), theLabel, flavour, currentChar,device);
			// labelState.set (device.getOutputKey(),command.getExtra2Info());
		}
		return cBUSOutputString;
	}
	/**
	 * 
	 * @param device
	 * @param command
	 * @param currentChar
	 * @return
	 * @throws CommsFail
	 */
	public String buildCBUSLightString (CBUSDevice device, CommandInterface command,String currentChar) throws CommsFail {
		String cBUSOutputString = null;
		boolean commandFound = false;

		String rawBuiltCommand = doRawIfPresent (command, (DeviceType)device);
		if (rawBuiltCommand != null)
		{
			cBUSOutputString = rawBuiltCommand;
			commandFound = true;
		}
		String theCommand = command.getCommandCode();
		if (!commandFound && theCommand == "") {
			logger.log(Level.WARNING, "Empty command received from client "+ command.getCommandCode());
			return null;
		}

		StateOfGroup stateOfGroup =this.getCurrentState(device.getApplicationCode(),device.getKey(), device.getDeviceType());

		if (theCommand.equals("on") ) {
			String levelStr = command.getExtraInfo();
			if (levelStr.equals("")) {
				cBUSOutputString = cBUSHelper.buildCBUSOnOffCommand ("79", device.getApplicationCode(), device.getKey(),currentChar);
				stateOfGroup.setPower("on",false);
				stateOfGroup.setLevel(100,false);
			}
			else {
				String rampRate = command.getExtra2Info();
				if (rampRate.equals("")) rampRate = "0";
				cBUSOutputString = cBUSHelper.buildCBUSRampToCommand (rampRate,device.getApplicationCode(),levelStr, device.getKey(),currentChar);
				stateOfGroup.setPower("on",false);
				stateOfGroup.setLevel(Integer.parseInt(levelStr),false);
			}
			commandFound = true;
		}
		// down used on shutter blind controls set level to 0%
		if (theCommand.equals("off") || theCommand.equals("down") ) {
			String rampRate = command.getExtra2Info();
			if (!rampRate.equals("")) {
				cBUSOutputString = cBUSHelper.buildCBUSRampToCommand (rampRate,device.getApplicationCode(),"0", device.getKey(),currentChar);
				stateOfGroup.setPower("on",false);
				stateOfGroup.setLevel(0,false);
				commandFound = true;
			} else {

				cBUSOutputString = cBUSHelper.buildCBUSOnOffCommand ("01", device.getApplicationCode(),device.getKey(),currentChar);
				stateOfGroup.setPower("off",false);
				stateOfGroup.setLevel(0,false);
				commandFound = true;
			}
		}
		// stop used on shutter / blind controls set level == 1% to stop them
		if (theCommand.equals("stop") ) { 
			String rampRate = "0";
			cBUSOutputString = cBUSHelper.buildCBUSRampToCommand (rampRate,device.getApplicationCode(),"1", device.getKey(),currentChar);
			stateOfGroup.setPower("on",false);
			stateOfGroup.setLevel(1,false);
			commandFound = true;
		}
		// up used on shutter / blind controls set level == 99% to raise them
		if (theCommand.equals("up") ) { 
			String rampRate = "0";
			cBUSOutputString = cBUSHelper.buildCBUSRampToCommand (rampRate,device.getApplicationCode(),"99", device.getKey(),currentChar);
			stateOfGroup.setPower("on",false);
			stateOfGroup.setLevel(99,false);
			commandFound = true;
		}

		if (commandFound) {
			try {
				stateOfGroup.setFromClient(true);
				stateOfGroup.setIsDirty(false);
				stateOfGroup.setCountConflict(0);
				this.setState((CBUSDevice)device,stateOfGroup);
			} catch (ClassCastException ex) {
				logger.log (Level.WARNING,"Error in configuration, non cbus device present in cbus configuration");
			};
			return cBUSOutputString;
		}
		else {
			return null;
		}
	}
	/**
	 * Handles the CBUS thermostat, don't need to deal with on/off these are
	 * done above as lighting commands
	 * There are some assumptions made at this early stage of the code
	 * 1. We are not targeting a specific aircon or heater, just sending a FF device
	 * 2. We are only handling the first zone in the group
	 * 3. We are not handling the auxiliary level
	 * 4. We are only sending the mode part of the HVAC status
	 * 5. We are not dealing with humidity control just yet
 	 */
	public String buildCBUSAirconString (CBUSDevice device, CommandInterface command,String currentChar) throws CommsFail {
		String cBUSOutputString = null;
		boolean commandFound = false;

		String rawBuiltCommand = doRawIfPresent (command, (DeviceType)device);
		if (rawBuiltCommand != null)
		{
			cBUSOutputString = rawBuiltCommand;
			commandFound = true;
		}
		String theCommand = command.getCommandCode();
		if (!commandFound && theCommand == "") {
			logger.log(Level.WARNING, "Empty command received from client "+ command.getCommandCode());
			return null;
		}

		// HVAC type  FF (let anyone deal with it)
		String type = "FF";
		// group list will be only zone 1 for now
		String groupList = "01";
		// auxLevel will be 0 for now
		String auxLevel = "00";
		// The set point level we are after
		String hexLevel = "";
		// mode bytes 000 == off
		String mode = "00";
		// sets the unit to heat
		if (theCommand.equals("heat") ) {
			String levelStr = command.getExtraInfo();
			// mode bytes 001
			mode = "01";
			short rawLevel = (short) (Integer.parseInt(levelStr) * 256);
			 hexLevel = cBUSHelper.hexPad(Integer.toString(rawLevel,16),4);
		}
		// sets the unit to cool
		if (theCommand.equals("cool") ) {
			String levelStr = command.getExtraInfo();
			// mode bytes 010
			mode = "02";
			// HVAC type  FF (let anyone deal with it)
			short rawLevel = (short) (Integer.parseInt(levelStr) * 256);
			hexLevel = cBUSHelper.hexPad(Integer.toString(rawLevel,16),4);
		}
		// changes the set-point on the thermostat 
		if (theCommand.equals("auto") ) {
			String levelStr = command.getExtraInfo();
			// mode bytes 011
			mode = "03";
			short rawLevel = (short) (Integer.parseInt(levelStr) * 256);
			hexLevel = cBUSHelper.hexPad(Integer.toString(rawLevel,16),4);
			if (hexLevel.equals("")) {
				logger.log(Level.WARNING, "Set command without level received from client " + command.getCommandCode());
			}
		}
		// sets the fan/vent only
		if (theCommand.equals("fan") ) { 
			String levelStr = command.getExtraInfo();
			// mode bytes 100
			mode = "04";
			// HVAC type  FF (let anyone deal with it)
			short rawLevel = (short) (Integer.parseInt(levelStr) * 327.67);
			hexLevel = cBUSHelper.hexPad(Integer.toString(rawLevel,16),4);
		}

		if (hexLevel.length() > 0) {
			cBUSOutputString = cBUSHelper.buildCBUSAirconCommand("2F", device.getApplicationCode(), device.getKey(), groupList, mode, type, hexLevel, auxLevel,  currentChar);	
			return cBUSOutputString;
		}
		else {
			return null;
		}
	}
	/**
	 * 
	 * @param appCode
	 * @param group
	 * @param deviceType
	 * @return
	 */
	public boolean hasState (String appCode, String group,int deviceType) {
		return hasState(cBUSHelper.buildKey(appCode,group, deviceType));
	}
	/**
	 * 
	 * @param fullKey
	 * @return
	 */
	public boolean hasState (String fullKey) {
		return state.containsKey(fullKey);		
	}
	/**
	 * 
	 * @param appCode
	 * @param group
	 * @param deviceType
	 * @return
	 */
	public StateOfGroup getCurrentState (String appCode, String group, int deviceType) {
		return getCurrentState (cBUSHelper.buildKey(appCode,group,deviceType));
	}
	/**
	 * 
	 * @param fullKey
	 * @return
	 */
	public StateOfGroup getCurrentState (String fullKey) {
		StateOfGroup currentState = (StateOfGroup)state.get(fullKey);
		if (currentState == null) currentState = new StateOfGroup();
		return currentState;
	}
	/**
	 * 
	 * @param appCode
	 * @param group
	 * @param currentState
	 * @param deviceType
	 */
	public void setCurrentState (String appCode, String group, StateOfGroup currentState,int deviceType) {
		setCurrentState (cBUSHelper.buildKey(appCode,group, deviceType),currentState);
	}
	/**
	 * 
	 * @param fullKey
	 * @param currentState
	 */
	public void setCurrentState (String fullKey, StateOfGroup currentState) {
		state.put(fullKey, currentState);
	}	
	/**
	 * 
	 */
	public boolean doIPHeartbeat () {
		return false;
	}
	/**
	 * 
	 * @return
	 */
	public String nextKey () {
		if (currentChar == 'z') {
			currentChar = 'g';
		}else {
			currentChar ++;			
		}
		return String.valueOf(currentChar);
	}
	/**
	 * 
	 * @return
	 */
	public long getLastSentTime() {
		return lastSentTime;
	}
	/**
	 * 
	 * @param lastSentTime
	 */
	public void setLastSentTime(long lastSentTime) {
		this.lastSentTime = lastSentTime;
	}
}
