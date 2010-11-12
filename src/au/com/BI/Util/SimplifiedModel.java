/*
 * Created on Jan 25, 2004
 *
 */
package au.com.BI.Util;

/**
 * @author Colin Canfield
 *
 */

import au.com.BI.Camera.Camera;
import au.com.BI.Pump.Pump;
import au.com.BI.Heater.Heater;
import au.com.BI.Command.*;
import au.com.BI.Comms.CommsCommand;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Comms.ConnectionFail;
import au.com.BI.Comms.IP;
import au.com.BI.Comms.Serial;
import au.com.BI.Comms.SerialParameters;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.Config.ParameterBlock;
import au.com.BI.Config.ParameterException;
import au.com.BI.Config.RawItemDetails;
import au.com.BI.Flash.ClientCommand;
import au.com.BI.PulseOutput.PulseOutput;
import au.com.BI.SMS.SMS;
import au.com.BI.Sensors.Sensor;
import au.com.BI.Sensors.SensorFascade;
import au.com.BI.ToggleSwitch.ToggleSwitch;
import au.com.BI.Thermostat.Thermostat;
import au.com.BI.Unit.Unit;
import au.com.BI.User.User;

import java.util.HashMap;
import java.util.Map;
import java.util.logging.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import au.com.BI.Lights.LightFascade;
import au.com.BI.Messaging.MessageCommand;
import au.com.BI.CustomConnect.*;
import au.com.BI.CustomInput.CustomInput;
import au.com.BI.Device.DeviceType;
import au.com.BI.AV.AV;
import au.com.BI.Alert.Alarm;
import au.com.BI.Alert.Alert;
import au.com.BI.Analog.Analog;
import au.com.BI.Audio.Audio;
import au.com.BI.Auxiliary.Auxiliary;

public class SimplifiedModel extends ModelParameters implements DeviceModel {

	protected Pattern customScanLookupString = null;
	protected Pattern customInputLookupString = null;
	protected Pattern customScaleString = null;
	protected Pattern customInputScaleString = null;
	protected Pattern customScanCommandString = null;
	protected ConfigHelper configHelper;
	protected boolean queueCommands  = false;
	protected SimplifiedModelPoll simplifiedModelPoll = null;
    
	public SimplifiedModel () {
        configHelper = new ConfigHelper(this);
   		customScanLookupString = Pattern.compile("%LOOKUP\\s+(\\w+)\\s+COMMAND\\.(\\w+)\\s*%");
   		customInputLookupString = Pattern.compile("%LOOKUP\\s+(\\w+)\\s+(\\w+)\\s*%");
   		customScaleString = Pattern.compile("%SCALE\\s+(\\d+)\\s+(\\d+)\\s*%");
   		customInputScaleString = Pattern.compile("%SCALE\\s+(\\S+)\\s+(\\d+)\\s+(\\d+)\\s*%");
   		customScanCommandString = Pattern.compile("%COMMAND\\.(\\w+)%");
	}
	
	/*
	 * A stub hook to which will be overwritten by actual models
	 */
	protected void doStartup (ReturnWrapper returnWrapper){}
	
	/*
	 * This function is called when the system starts up
	 * @see au.com.BI.Util.BaseModel#doStartup()
	 */
	public void doStartup() throws CommsFail {
		ReturnWrapper returnWrapper = new ReturnWrapper();
		returnWrapper.setQueueCommands(this.isQueueCommands());


		try {
			doStartup( returnWrapper);
			addCheckSums(returnWrapper);
			sendWrapperItems(returnWrapper);

		} catch (ClassCastException ex) {
			logger.log(Level.WARNING, "An class cast error occured in " + this.getName()
					+ " support " + ex.getMessage());
		}

	}
	
	/*
	 * A stub hook to which will be overwritten by actual models
	 */
	protected void doPoll (ReturnWrapper returnWrapper){}
	
	/*
	 * This function is called when the system runs a poll
	 */
	public void doPoll() throws CommsFail {
		ReturnWrapper returnWrapper = new ReturnWrapper();
		returnWrapper.setQueueCommands(this.isQueueCommands());


		try {
			doPoll( returnWrapper);
			addCheckSums(returnWrapper);
			sendWrapperItems(returnWrapper);

		} catch (ClassCastException ex) {
			logger.log(Level.WARNING, "An class cast error occured in " + this.getName()
					+ " support " + ex.getMessage());
		}

	}

	/*
	 * Activate the polling system (remember to set IPHeartbeat(false) as well
	 */
	public void enablePoll (int pollSeconds) {
		if (simplifiedModelPoll == null){
			simplifiedModelPoll = new SimplifiedModelPoll();
			simplifiedModelPoll.setModel (this);
		} else {
			simplifiedModelPoll.setPolling(false);
		}
		simplifiedModelPoll.setDelay (pollSeconds * 1000L);
		simplifiedModelPoll.start();
		
	}
	
	/*
	 * Disables the polling system
	 */
	public void disablePoll() {
		if (simplifiedModelPoll != null){
			simplifiedModelPoll.setPolling(false);
		}
	}
	
	/*
	 * This function is called when instructions are received from flash.
	 * @see au.com.BI.Util.BaseModel#doOutputItem()
	 */
	public void doOutputItem(CommandInterface command) throws CommsFail {
		ReturnWrapper returnWrapper = new ReturnWrapper();
		returnWrapper.setQueueCommands(this.isQueueCommands());

		cache.setCachedCommand(command.getKey(),command);
		
		try {
			decodeOutputItem(command, returnWrapper);
			addCheckSums(returnWrapper);
			sendWrapperItems(returnWrapper);

		} catch (ModelException ex) {
			logger.log(Level.WARNING, "An error occured in " + this.getName()
					+ " support " + ex.getMessage());
		}

	}

	public void setupParameterBlocks() throws SetupException {
		for (ParameterBlock block : configHelper.getParameterBlocks()) {

			String paramDef = (String) this.getParameterValue(block
					.getCatalogName(), block.getGroup());
			if (paramDef == null || paramDef.equals("")) {
				throw new SetupException(
						"The "
								+ block.getVerboseName()
								+ " input catalogue name was not specified in the device Parameter block");
			}

			Map inputs = this.getCatalogueDef(paramDef);
			if (inputs == null) {
				throw new SetupException(
						"The "
								+ block.getVerboseName()
								+ " input catgalogue was not specifed in the device Parameter block");
			}
		}
	}

	public void finishedReadingConfig() throws SetupException {
		setupParameterBlocks();
	}

	/** 
	 * A hook which occurs after the configuration parser has read the to level parameters 
	 *	but has not yet begun the individual device entries. 
	 */
	public void finishedReadingParameters() {
		if (getParameterValue("DECIMAL_KEYS", DeviceModel.MAIN_DEVICE_GROUP)
				.equals("Y")) {
			this.setConfigKeysInDecimal(true);
		} else {
			this.setConfigKeysInDecimal(false);
		}

		if (!getParameterValue("APPEND_TO_SENT_STRINGS",
				DeviceModel.MAIN_DEVICE_GROUP).equals("")) {
			this.setAppendToSentStrings(getParameterValue(
					"APPEND_TO_SENT_STRINGS", DeviceModel.MAIN_DEVICE_GROUP));
		}
		
	}
	
	/** 
	 * A hook which occurs before the system starts reading any model parameter details.
	 * Use this to set any values that require the model to have been setup , eg. with the label hander, macro handler etc. but before parsing the details.
	 */
	public void aboutToReadModelDetails() {
		
	}
	
    public void addStartupQueryItem(String name, Object details, MessageDirection controlType) {};
    
	public void clearItems() {
		configHelper.clearItems();
		parameters.clear();
		topMap = new HashMap<String, String>(DeviceModel.NUMBER_PARAMETERS);

		parameters.put(DeviceModel.MAIN_DEVICE_GROUP, topMap);
	}

	/**
	 * @return Returns the value stored in variable.
	 * @param key The key to get the value for.
	 */
	public String getVariable(String key) {
		synchronized (variableCache) {
			if (variableCache.containsKey(key) == true) {
				return (String) variableCache.get(key);
			}
		}
		return "None";
	}

	public void sendWrapperItems(ReturnWrapper returnWrapper) {
		if (!returnWrapper.isError()) {
			if (returnWrapper.isMessageIsBytes()) {
				for (byte[] avOutputString : returnWrapper.getCommOutputBytes()) {
					if (returnWrapper.isQueueCommands()) {
						this.sendToSerialQueue (avOutputString);
					} else {
						this.sendToSerial(avOutputString);
					}
				}
			} else {
				for (String avOutputString : returnWrapper.getCommOutputStrings()) {
					if ( returnWrapper.isQueueCommands()) {
						this.sendToSerialQueue(avOutputString + this.getAppendToSentStrings());
					} else {
						this.sendToSerial(avOutputString + this.getAppendToSentStrings());						
					}
					if (logger.isLoggable(Level.FINE)) {
						logger
								.log(Level.FINE,
										"Sending a command to the device controlled by "
												+ this.getName() + " "
												+ avOutputString);
					}
				}
			}

			for (CommandInterface eachCommand : returnWrapper.getOutputFlash()) {
				this.sendToFlash(eachCommand, cache);
			}

		} else {
			if (returnWrapper != null) {
				logger.log(Level.WARNING,
						"There was error processing the message in the "
								+ this.getName() + " support module."
								+ returnWrapper.getErrorDescription());
			}
		}

	}

	/**
	 * @return Returns the value stored in variable.
	 * @param key The key to get the value for.
	 */
	public Long getLongVariable(String key) {
		synchronized (variableCache) {
			if (variableCache.containsKey(key) == true) {
				return (Long) variableCache.get(key);
			}
		}
		return null;
	}

	/**
	 * @return Returns the value stored in variable.
	 * @param key The key to get the value for.
	 */
	public Double getDoubleVariable(String key) {
		synchronized (variableCache) {
			if (variableCache.containsKey(key) == true) {
				return (Double) variableCache.get(key);
			}
		}
		return null;
	}

	/**
	 * Set the varaible Key,Value
	 * @param key The key to store the value for.
	 * @param @value The value to store.
	 */
	public void setVariable(String key, String value) {
		synchronized (variableCache) {
			if (variableCache.containsKey(key) == true) {
				variableCache.remove(key);
				variableCache.put(key, value);
				return;
			}
			variableCache.put(key, value);
		}
		return;
	}

	/**
	 * Set the varaible Key,Value where value is a double, but stored as a string.
	 * @param key The key to store the value for.
	 * @param @value The value to store as a double.
	 */
	public void setVariable(String key, double value) {
		synchronized (variableCache) {
			if (variableCache.containsKey(key) == true) {
				variableCache.remove(key);
				variableCache.put(key, new Double(value));
				return;
			}
			variableCache.put(key, new Double(value));
		}
		return;
	}

	/**
	 * Set the varaible Key,Value where value is a long, but stored as a string.
	 * @param key The key to store the value for.
	 * @param @value The value to store as a long.
	 */
	public void setVariable(String key, long value) {
		synchronized (variableCache) {
			if (variableCache.containsKey(key) == true) {
				variableCache.remove(key);
				variableCache.put(key, new Long(value));
				return;
			}
			variableCache.put(key, new Long(value));
		}
		return;
	}

	/**
	 * Set the varaible Key,Value where value is a double, but stored as a string.
	 * @param key The key to store the value for.
	 * @param @value The value to store as a boolean.
	 */
	public void setVariable(String key, Boolean value) {
		synchronized (variableCache) {
			if (variableCache.containsKey(key) == true) {
				variableCache.remove(key);
				variableCache.put(key, value);
				return;
			}
			variableCache.put(key, value);
		}
		return;
	}
	

	/**
	 * @return Returns the value stored in variable.
	 * @param key The key to get the value for.
	 */
	public Boolean getBooleanVariable(String key) {
		synchronized (variableCache) {
			if (variableCache.containsKey(key) == true) {
				return (Boolean) variableCache.get(key);
			}
		}
		return null;
	}
	
	/**
	 * Increment the variable Value
	 * @param key The key to store the value for.
	 */
	public void incrementVariable(String key) {
		Double value;
		double numValue;
		Object hold;
		Long longValue;
		long numLong;

		synchronized (variableCache) {
			if (variableCache.containsKey(key) == true) {
				hold = variableCache.get(key);
				if (hold.getClass().getName() == "java.lang.Double") {
					value = (Double) variableCache.get(key);
					numValue = value.doubleValue();
					numValue = numValue + 1d;
					value = new Double(numValue);
					variableCache.remove(key);
					variableCache.put(key, value);
					return;
				} else if (hold.getClass().getName() == "java.lang.Long") {
					longValue = (Long) variableCache.get(key);
					numLong = longValue.longValue();
					numLong = numLong + 1;
					longValue = new Long(numLong);
					variableCache.remove(key);
					variableCache.put(key, longValue);
					return;
				}
				return;

			}

			variableCache.put(key, new Double(1d));
			return;
		}
	}

	/**
	 * Decrement the variable Value
	 * @param key The key to store the value for.
	 */
	public void decrementVariable(String key) {
		Double value;
		double numValue;
		Object hold;
		Long longValue;
		long numLong;

		synchronized (variableCache) {
			if (variableCache.containsKey(key) == true) {
				hold = variableCache.get(key);
				if (hold.getClass().getName() == "java.lang.Double") {
					value = (Double) variableCache.get(key);
					numValue = value.doubleValue();
					numValue = numValue - 1d;
					value = new Double(numValue);
					variableCache.remove(key);
					variableCache.put(key, value);
					return;
				} else if (hold.getClass().getName() == "java.lang.Long") {
					longValue = (Long) variableCache.get(key);
					numLong = longValue.longValue();
					numLong = numLong - 1;
					longValue = new Long(numLong);
					variableCache.remove(key);
					variableCache.put(key, longValue);
					return;
				}
				return;
			}
			variableCache.put(key, new Double(-1d));
			return;
		}
	}

	public void addControlledItem(String name, DeviceType details,
			MessageDirection controlType) {
		String theKey = name;

		configHelper.addControlledItem(theKey, details, controlType);
	}

	public boolean doIControl(String keyName, boolean isClientCommand) {

		configHelper.wholeKeyChecked(keyName);

		if (configHelper.checkForOutputItem(keyName)) {
			logger.log(Level.FINER, "Flash sent command : " + keyName);
			return true;
		}
		if (isClientCommand)
			return false; // only are about output for client commands
		else {
			configHelper.setLastCommandType(MessageDirection.FROM_HARDWARE);
			logger.log(Level.FINER, "Controls : " + keyName);
			return true; // anything come through comms we want to look at
		}

	}

	public void doCommand(CommandInterface command) throws CommsFail {

		if (configHelper.getLastCommandType() == MessageDirection.FROM_FLASH) {
			doOutputItem(command);
		} else {
			if (configHelper.getLastCommandType() == MessageDirection.INPUT) {
				doInputItem(command);
			} else {
				if (command.isCommsCommand())  {
					doControlledItem(command);
				} else {
					logger.log (Level.WARNING,"A command of an unknown type is being processed : " + command.getCommandCode() + ":" + 
							command.getDisplayName() + ":" + command.getKey() + ":" + command.toString());
				}
			}
		}
	}

    
	/**
	 * Called by the configuration reader
	 * user interaction on the item. At this stage only the flash client generates these
	 * @param customConnectInput non unique key name for physical device
	 */
	public void addCustomConnectInput (CustomConnectInput customConnectInput){
		configHelper.addCustomConnectInput(customConnectInput);
	}
	
	public int login(User user) throws CommsFail {
		logged_in = true;
		return DeviceModel.SUCCESS;
	}

	public int logout(User user) throws CommsFail {
		return DeviceModel.SUCCESS;
	}

	public boolean isLoggedIn() {
		return logged_in;
	}

	public void sendToSerial(String outputRawCommand) throws CommsFail {
		if (this.connected == true) {
			synchronized (comms) {
				comms.sendString(outputRawCommand);
			}
		}
	}

	public void sendToSerialQueue(String outputRawCommand) throws CommsFail {
		if (this.connected == true) {
			CommsCommand command = new CommsCommand();
			command.setKey("");
			command.setCommand(outputRawCommand);
			command.setKeepForHandshake(true);
			comms.addCommandToQueue(command);
		}
	}
	
	public void sendToSerial(byte[] outputRawCommand) throws CommsFail {
		if (this.connected == true) {
			synchronized (comms) {
				comms.sendString(outputRawCommand);
			}
		}
	}

	public void sendToSerialQueue(byte[] outputRawCommand) throws CommsFail {
		if (this.connected == true) {
			CommsCommand command = new CommsCommand();
			command.setKey("");
			command.setKeepForHandshake(true);
			command.setCommandBytes(outputRawCommand);
			comms.addCommandToQueue(command);
			}
	}

    /**
     Finishes operations, closing down any other threads it is responsible for
     */
    public void close() throws ConnectionFail {
            closeComms();
    }
    
	public void sendToSerial(byte avOutputString[], String deviceKey,
			String outputKey, int outputCommandType, boolean keyForHandshake)
			throws CommsFail {
		CommsCommand avCommsCommand = new CommsCommand();
		avCommsCommand.setKey(deviceKey);
		avCommsCommand.setCommandBytes(avOutputString);
		avCommsCommand.setActionType(outputCommandType);
		avCommsCommand.setExtraInfo(outputKey);
		avCommsCommand.setKeepForHandshake(keyForHandshake);
		synchronized (comms) {
			try {
				comms.addCommandToQueue(avCommsCommand);
			} catch (CommsFail e1) {
				throw new CommsFail(
						"Communication failed with the device "
								+ e1.getMessage());
			}
		}
	}

	public void sendToSerial(String avOutputString, String deviceKey,
			String outputKey, int outputCommandType, boolean keyForHandshake)
			throws CommsFail {
		CommsCommand avCommsCommand = new CommsCommand();
		avCommsCommand.setKey(deviceKey);
		avCommsCommand.setCommand(avOutputString);
		avCommsCommand.setActionType(outputCommandType);
		avCommsCommand.setExtraInfo(outputKey);
		avCommsCommand.setKeepForHandshake(keyForHandshake);
		synchronized (comms) {
			try {
				comms.addCommandToQueue(avCommsCommand);
			} catch (CommsFail e1) {
				throw new CommsFail(
						"Communication failed with the device "
								+ e1.getMessage());
			}
		}
	}

	/**
	 * Attatch to a port
	 * @param port
	 * @param commandList The list object to place ReceiveEvent messages
	 * @param handlerThread The thread to be notified when messages are added to the queue
	 * @throws ConnectionFail
	 * @see au.com.BI.Comms.CommsCommand;
	 */
	public void attatchComms() throws ConnectionFail {
		SerialParameters parameters = null;
		if (((String) this.getParameterValue("Connection_Type",
				DeviceModel.MAIN_DEVICE_GROUP)).equals("SERIAL")) {

			if (comms != null) {
				synchronized (comms) {
					comms.close();
				}
			} else
				comms = new Serial();
			comms.setModelName(this.getName());

			if (this.transmitOnBytes > 0) {
				comms.setTransmitMessageOnBytes(transmitOnBytes);
			}
			if (this.naturalPackets){
				comms.setNaturalPackets(true);
			}
			if (etxArray != null)
				comms.setETXArray(etxArray);
			if (penultimateArray != null)
				comms.setPenultimateArray(penultimateArray);
			if (stxArray != null)
				comms.setSTXArray(stxArray);
			if (interCommandInterval != 0)
				comms.setInterCommandInterval(interCommandInterval);
			parameters = new SerialParameters();
			parameters.buildFromDevice(this);
			synchronized (comms) {
				((Serial) comms).connect((String) this.getParameterValue(
						"Device_Port", DeviceModel.MAIN_DEVICE_GROUP),
						parameters, commandQueue, this.getInstanceID(), this
								.getName());
				comms.clearCommandQueue();
			}
		} 
		
		if (((String) this.getParameterValue("Connection_Type",
				DeviceModel.MAIN_DEVICE_GROUP)).equals("IP")) {

			if (comms != null) {
				synchronized (comms) {
					comms.close();
					comms = null;
				}
			}

			comms = new IP();
			comms.setModelName(this.getName());
			if (this.transmitOnBytes > 0) {
				comms.setTransmitMessageOnBytes(transmitOnBytes);
			}
			if (this.naturalPackets){
				comms.setNaturalPackets(true);
			}
			if (etxArray != null)
				comms.setETXArray(etxArray);
			if (stxArray != null)
				comms.setSTXArray(stxArray);
			if (interCommandInterval != 0)
				comms.setInterCommandInterval(interCommandInterval);
			if (penultimateArray != null)
				comms.setPenultimateArray(penultimateArray);

			synchronized (comms) {
				((IP) comms).connect((String) this.getParameterValue(
						"IP_Address", DeviceModel.MAIN_DEVICE_GROUP),
						(String) this.getParameterValue("Device_Port",
								DeviceModel.MAIN_DEVICE_GROUP), commandQueue,
						this.getInstanceID(), doIPHeartbeat(),
						getHeartbeatString(), this.getName());
				comms.clearCommandQueue();
			}
		}
		//connected = true;
	}

	/**
	 Closes the connection	 */
	public void closeComms() throws ConnectionFail {
		if (comms != null) {
			synchronized (comms) {
				comms.close();
			}
		}
	}

	public String getParameterValue(String name, String groupName) {
		HashMap<String, String> theMap;
		if (groupName == null || groupName.equals(""))
			groupName = DeviceModel.MAIN_DEVICE_GROUP;

		if (!groupName.equals(DeviceModel.MAIN_DEVICE_GROUP)
				&& parameters.containsKey(groupName)) {
			theMap = parameters.get(groupName);
			String item = theMap.get(name);
			if (item == null)
				return "";
			else
				return item;
		} else {
			String item = topMap.get(name);
			if (item == null)
				return "";
			else
				return item;
		}
	}

	public void setParameter(String name, String value, String groupName) {
		HashMap<String, String> theMap;
		if (groupName.equals(DeviceModel.MAIN_DEVICE_GROUP))
			theMap = topMap;
		else {
			if (parameters.containsKey(groupName))
				theMap = parameters.get(groupName);
			else
				theMap = new HashMap<String, String>(
						DeviceModel.NUMBER_PARAMETERS);
		}

		theMap.put(name, value);
		parameters.put(groupName, theMap);
	}


	public int paramToInt(CommandInterface command, Fields commandField,
			int minVal, int maxVal, String errorMessage)
			throws ParameterException {
		String value = command.getValue(commandField);
		String exceptionMessage = errorMessage + " " + value;
		try {
			Integer intVal = Integer.parseInt(value);
			if (intVal < minVal || intVal > maxVal) {
				throw new ParameterException(exceptionMessage);
			}
			return intVal;

		} catch (NullPointerException ex) {
			logger.log(Level.FINER, exceptionMessage);
			throw new ParameterException(exceptionMessage);
		} catch (NumberFormatException ex) {
			logger.log(Level.FINER, exceptionMessage);
			throw new ParameterException(exceptionMessage);
		}
	}

	public void sendToFlash(long targetFlashID, CommandInterface command) {
		command.setTargetDeviceID(targetFlashID);
		String theKey = command.getDisplayName();
		logger.log(Level.FINEST, "Sending to flash " + theKey + ":"
				+ command.getCommandCode() + ":" + command.getExtraInfo());
		sendToFlash(command, cache);
	}

	public void sendToFlash(CommandInterface command, Cache cache) {
		if (!(command instanceof MessageCommand)){
			cache.setCachedCommand(command.getDisplayName(), command);
			logger.log(Level.FINE, "Sending to flash " + command.getDisplayName() + ":"
				+ command.getCommandCode() + ":" + command.getExtraInfo());
		}
		commandQueue.add(command);
	}

	public void sendToFlash(String displayName, String command, String value) {
		Command flashCommand = new Command();
		flashCommand.setKey("CLIENT_SEND");
		flashCommand.setDisplayName(displayName);
		flashCommand.setCommand(command);
		flashCommand.setExtraInfo(value);
		sendToFlash(flashCommand, cache);
	}

	public void sendToFlash(String displayName, String command, String value,
			String extra2, String extra3, String extra4, String extra5,
			long targetDeviceID) {
		Command flashCommand = new Command();
		flashCommand.setKey("CLIENT_SEND");
		flashCommand.setDisplayName(displayName);
		flashCommand.setCommand(command);
		flashCommand.setExtraInfo(value);
		flashCommand.setExtra2Info(extra2);
		flashCommand.setExtra3Info(extra3);
		flashCommand.setExtra4Info(extra4);
		flashCommand.setExtra5Info(extra5);
		flashCommand.setTargetDeviceID(targetDeviceID);

		sendToFlash(flashCommand, cache);
	}

	public void sendMessage(String title, String content, String autoclose,
			String icon, String hideclose, String targetUser, String target,
			long targetDeviceID) {
		ClientCommand flashMessage = new ClientCommand();
		flashMessage.setMessageType(ClientCommand.Message);
		flashMessage.setTitle(title);
		flashMessage.setAutoclose(autoclose);
		flashMessage.setIcon(icon);
		flashMessage.setHideclose(hideclose);
		flashMessage.setTargetUser(targetUser);
		flashMessage.setContent(content);
		flashMessage.setTarget(target);
		flashMessage.setKey("MESSAGE");
		flashMessage.setDisplayName("MESSAGE");
		flashMessage.setOriginatingID(this.getInstanceID());
		commandQueue.add(flashMessage);
	}

	public CommandInterface buildCommandForFlash(DeviceType device,
			String command, String extra, String extra2, String extra3,
			String extra4, String extra5, long targetDeviceID) {
		CommandInterface videoCommand = device.buildDisplayCommand();
		videoCommand.setKey("CLIENT_SEND");
		videoCommand.setTargetDeviceID(targetDeviceID);
		videoCommand.setCommand(command);
		videoCommand.setExtraInfo(extra);
		videoCommand.setExtra2Info(extra2);
		videoCommand.setExtra3Info(extra3);
		videoCommand.setExtra4Info(extra4);
		videoCommand.setExtra5Info(extra5);

		return videoCommand;
	}

	public CommandInterface buildOffCommandForFlash(DeviceType device) {
		return buildCommandForFlash(device, "off", "", "", "", "", "", 0);
	}

	public CommandInterface buildCommandForFlash(DeviceType device,
			String command) {
		return buildCommandForFlash(device, command, "", "", "", "", "", 0);
	}
	
	public CommandInterface buildCommandForFlash(DeviceType device,
			String command, String extra) {
		return buildCommandForFlash(device, command, extra, "", "", "", "", 0);
	}

	public CommandInterface buildCommandForFlash(DeviceType device,
			String command, Integer extra) {
		return buildCommandForFlash(device, command, extra.toString(), "", "", "", "", 0);
	}
	
	public CommandInterface buildCommandForFlash(DeviceType device,
			String command, String extra, String extra2) {
		return buildCommandForFlash(device, command, extra, extra2, "", "", "",
				0);
	}

	public CommandInterface buildCommandForFlash(DeviceType device,
			String command, String extra, String extra2, String extra3) {
		return buildCommandForFlash(device, command, extra, extra2, extra3, "",
				"", 0);
	}

	public CommandInterface buildCommandForFlash(DeviceType device,
			String command, String extra, String extra2, String extra3,
			String extra4) {
		return buildCommandForFlash(device, command, extra, extra2, extra3,
				extra4, "", 0);
	}

	public CommandInterface buildCommandForFlash(DeviceType device,
			String command, String extra, String extra2, String extra3,
			String extra4, String extra5) {
		return buildCommandForFlash(device, command, extra, extra2, extra3,
				extra4, extra5, 0);
	}

	/**
	 * Formats a key into the appropriate format for interacting with the config file.
	 * @return Formatted key
	 */
	public String formatKey(int key, DeviceType device)
			throws NumberFormatException {

		int padding = getPadding();
		String formatSpec = "%0";
		formatSpec += padding;

		if (isDeviceKeysString()){
			return new Integer(key).toString();
		}
		if (!this.isDeviceKeysDecimal()) {
			formatSpec += "X";
		} else {
			formatSpec += "d";
		}

		return String.format(formatSpec, key);
	}

	/**
	 * Formats a key into the appropriate format for interacting with the config file.
	 * @return Formatted key
	 */
	public String formatKey(String key, DeviceType device)
			throws NumberFormatException {
		int keyInt = 0;
		if (isDeviceKeysString()){
			return key;
		}
		if (isConfigKeysInDecimal()) {
			keyInt = Integer.parseInt(key);
		} else {
			keyInt = Integer.parseInt(key, 16);
		}
		return formatKey(keyInt, device);
	}

	public void decodeOutputItem(CommandInterface command,
			ReturnWrapper returnWrapper) throws ModelException {

		DeviceType device = configHelper.getOutputItem(command.getKey());
		String rawStr = this.doRawIfPresent(command, device);
		if (rawStr != null) {
			returnWrapper.addCommOutput(rawStr);
		} else {
			try {
				switch (device.getDeviceType()) {
				case DeviceType.ANALOG:
					logger.log(Level.FINE,
							"A command for an analog device was issued from "
									+ device.getName());
					buildAnalogControlString((Analog) device, command,
							returnWrapper);
					break;

				case DeviceType.AUDIO:
					logger.log(Level.FINE,
							"A command for an Audio device was issued from "
									+ device.getName());
					buildAudioControlString((Audio) device, command,
							returnWrapper);
					break;
					
				case DeviceType.THERMOSTAT:
					logger.log(Level.FINE,
							"A command for an Audio device was issued from "
									+ device.getName());
					buildThermostatControlString((Thermostat) device, command,
							returnWrapper);
					break;

				case DeviceType.AV:
					logger.log(Level.FINE,
							"A command for an AV device was issued from "
									+ device.getName());
					buildAVControlString((AV) device, command, returnWrapper);
					break;

				case DeviceType.LIGHT:
					logger.log(Level.FINE,
							"A command for a Lighting device was issued from "
									+ device.getName() + " for the model "
									+ this.getName());
					buildLightControlString((LightFascade) device, command,
							returnWrapper);
					break;

				case DeviceType.SENSOR:
					logger.log(Level.FINE,
							"A command for a Sensor device was issued from "
									+ device.getName());
					buildSensorControlString((SensorFascade) device, command,
							returnWrapper);
					break;

				case DeviceType.ALARM:
					logger.log(Level.FINE,
							"A command for an Alarm  was issued from "
									+ device.getName());
					buildAlarmControlString((Alarm) device, command,
							returnWrapper);
					break;

				case DeviceType.PUMP:
					logger.log(Level.FINE,
							"A command for a pump  was issued from "
									+ device.getName());
					buildPumpControlString((Pump) device, command,
							returnWrapper);
					break;
					
				case DeviceType.HEATER:
					logger.log(Level.FINE,
							"A command for a heater  was issued from "
									+ device.getName());
					buildHeaterControlString((Heater) device, command,
							returnWrapper);
					break;
					
				case DeviceType.AUXILIARY:
					logger.log(Level.FINE,
							"A command for an auxiliary device  was issued from "
									+ device.getName());
					buildAuxiliaryControlString((Auxiliary) device, command,
							returnWrapper);
					break;
					
				case DeviceType.ALERT:
					logger.log(Level.FINE,
							"A command for an Alert device was issued from "
									+ device.getName());
					buildAlertControlString((Alert) device, command,
							returnWrapper);
					break;

				case DeviceType.PULSE_OUTPUT:
					logger.log(Level.FINE,
							"A command for a Pulse Output  was issued from "
									+ device.getName());
					buildPulseOutputControlString((PulseOutput) device,
							command, returnWrapper);
					break;

				case DeviceType.CAMERA:
					logger.log(Level.FINE,
							"A command for a Camera device was issued from "
									+ device.getName() + " for the model "
									+ this.getName());
					buildCameraControlString((Camera) device, command,
							returnWrapper);
					break;

				case DeviceType.TOGGLE_OUTPUT:
					logger.log(Level.FINE,
							"A command for an Output Toggle device was issued from "
									+ device.getName() + " for the model "
									+ this.getName());
					buildToggleOutputControlString((ToggleSwitch) device,
							command, returnWrapper);
					break;

				case DeviceType.SMS:
					logger.log(Level.FINE,
							"A command for an SMS device was issued from "
									+ device.getName() + " for the model "
									+ this.getName());
					buildSMSControlString((SMS) device, command, returnWrapper);
					break;

				case DeviceType.RAW_INTERFACE:
					logger.log(Level.FINE,
							"A command for an Custom device was issued from "
									+ device.getName() + " for the model "
									+ this.getName());
					buildRAWControlString(device, command, returnWrapper);
					break;
					
				case DeviceType.CUSTOM_CONNECT:
					logger.log(Level.FINE,
							"A command for an Custom device was issued from "
									+ device.getName() + " for the model "
									+ this.getName());
					buildCustomConnectControlString((CustomConnect) device,
							command, returnWrapper);
					break;
					
				case DeviceType.UNIT:
					logger.log(Level.FINE,
							"A command for an unit device was issued from "
									+ device.getName() + " for the model "
									+ this.getName());
					buildUnitControlString((Unit) device, command, returnWrapper);
					break;
				}

			} catch (ClassCastException ex) {
				logger.log(Level.SEVERE,
						"An internal error has occured in support for "
								+ this.getName()
								+ " ,please contact your integrator "
								+ ex.getMessage());
			}
		}

	}

	public void doControlledItem(CommandInterface command) throws CommsFail {
		ReturnWrapper returnWrapper = new ReturnWrapper();
		returnWrapper.setQueueCommands(this.isQueueCommands());


		try {
			this.doCustomConnectInputIfPresent((CommsCommand)command,returnWrapper);
			if (!returnWrapper.isPopulated()){
				processStringFromComms(command.getKey(), returnWrapper);
			}
			addCheckSums(returnWrapper);
			sendWrapperItems(returnWrapper);

		} catch (CommsProcessException ex) {
			logger.log(Level.WARNING, "An error occured in " + this.getName()
					+ " support " + ex.getMessage());
		} catch (ClassCastException ex) {
			logger.log(Level.WARNING, "An class cast error occured in " + this.getName()
					+ " support " + ex.getMessage());
		}

	}

	/**
	 * @param command
	 * @throws CommsFail
	 */
	public void doInputItem(CommandInterface command) throws CommsFail {
		ReturnWrapper returnWrapper = new ReturnWrapper();
		returnWrapper.setQueueCommands(this.isQueueCommands());

		try {
			this.doCustomConnectInputIfPresent((CommsCommand)command,returnWrapper);
			if (!returnWrapper.isPopulated()){
				processStringFromComms(command.getCommandCode(), returnWrapper);
			}
			addCheckSums(returnWrapper);
			sendWrapperItems(returnWrapper);

		} catch (CommsProcessException ex) {
			logger.log(Level.WARNING, "An error occured in " + this.getName()
					+ " support " + ex.getMessage());
		} catch (ClassCastException ex) {
			logger.log(Level.WARNING, "An class cast error occured in " + this.getName()
					+ " support " + ex.getMessage());
		}

	}
	
	public void  processStringFromComms(String command,
			ReturnWrapper returnWrapper) throws CommsProcessException {

	}

	public void addCheckSums(ReturnWrapper returnWrapper) {
		if (this.isChecksumRequired()){
			if (returnWrapper.isMessageIsBytes()) {
				for (int i = 0; i <  returnWrapper.getCommOutputBytes().size(); i++) {
					byte [] arrayToCheck = returnWrapper.getCommOutputBytes().elementAt(i);
					Byte returnCheck = addCheckSum(arrayToCheck);
					if (returnCheck != null) {
						byte []newArray = new byte[arrayToCheck.length+1];
						System.arraycopy(arrayToCheck, 0, newArray, 0, arrayToCheck.length);
						newArray [arrayToCheck.length ] = returnCheck;
						returnWrapper.getCommOutputBytes().setElementAt(newArray,i);
					}
				}
			} else {
				for (int i = 0; i <  returnWrapper.getCommOutputStrings().size();i++) {
					byte [] arrayToCheck = returnWrapper.getCommOutputStrings().elementAt(i).getBytes();
					Byte returnCheck = addCheckSum(arrayToCheck);
					if (returnCheck != null) {
						byte []newArray = new byte[arrayToCheck.length+1];
						System.arraycopy(arrayToCheck, 0, newArray, 0, arrayToCheck.length);
						newArray [arrayToCheck.length ] = returnCheck;
						returnWrapper.getCommOutputStrings().setElementAt(new String(newArray),i);
					}
				}
			}
		}
	}

		/**
		 * This method should be implemented if the model needs to calculate a checksum value
		 * @param returnVal The array of bytes to calculcate the checksum over
		 * @param checksumValue The caclulcated byte value of the checksum if needed
		 * @return True if checksum is needed, false if not. The default is false if the method has not been overwritten
		 */
	public Byte addCheckSum(byte returnVal[]) {
		return null;
		
	}


	public String getCatalogueValue (String ID, String parameterName, DeviceType device) throws ParameterException {
		String value = "";
		String catalogueGroupName = "";
		if (device == null) {
			catalogueGroupName = "Group01";
		} else {
			catalogueGroupName = device.getGroupName();
		}
		Map rawCatalogue = getCatalogueDef(getParameterValue(parameterName,catalogueGroupName));
		if (rawCatalogue == null ) {
			throw new ParameterException ("Catalogue " + parameterName + " is not present in the configuration file.");
		}
		else {
			if (rawCatalogue.containsKey(ID)){
					value = (String)rawCatalogue.get(ID);
					return value;
			} else {
				throw new ParameterException ("The requested value " + ID + " is not present in the required catalogue " + parameterName + " for " + this.getName());
			}
		}
	}

	public String findKeyForParameterValue(String srcCode, String catalogName,
			DeviceType device) throws NumberFormatException, ParameterException {
		return findKeyForParameterValue(Integer.parseInt(srcCode), catalogName,
				device);
	}

	public String findKeyForParameterValue(int srcVal, String catalogName,
			DeviceType device) throws ParameterException {
		String groupName = device.getGroupName();
		String paramMapName = getParameterValue(catalogName, groupName);
		Map<String, String> inputParameters = getCatalogueDef(paramMapName);

		String returnVal = "";

		for (String eachItem : inputParameters.keySet()) {
			int programVal = Integer.parseInt(inputParameters.get(eachItem));
			if (programVal == srcVal) {
				returnVal = eachItem;
			}
		}
		if (returnVal.equals(""))
			throw new ParameterException(
					"An input device has been selected which has not been configured, please contact your integrator");
		return returnVal;
	}
	
	/**
	 * If a raw code has been specified for this command on this device. It will be returned.
	 * @param command
	 * @param device
	 * @return
	 */
	public String doRawIfPresent(CommandInterface command,
			DeviceType targetDevice) {


		Map rawCodes = targetDevice.getRawCodes(); // the list specified in the config for this device line.

		if (rawCodes != null) {
			String commandName = command.getCommandCode();
			String extraFromClient = (String) command.getExtraInfo();
			RawItemDetails rawCode = (RawItemDetails) rawCodes.get(commandName
					+ ":" + extraFromClient); // pull up details for the line

			if (rawCode == null)
				rawCode = (RawItemDetails) rawCodes.get(commandName); // pull up details for the line				

			if (rawCode != null) {
				Map rawCatalogue = getCatalogueDef(rawCode.getCatalogue());
				if (rawCatalogue == null) {
					logger.log(Level.WARNING,
							"Specified raw catalogue is not defined : "
									+ rawCatalogue);
					return null;
				} else {
					String catalogueValue = (String) rawCatalogue.get(rawCode
							.getCode());
					return rawCode.populateVariables(catalogueValue, command);
				}
			}
		}

		return null;
	}

	/**
	 * If a raw code has been specified for this command on this device. It will be returned.
	 * @param command
	 * @param device
	 * @return
	 */
	public void doCustomConnectOutputIfPresent(CommandInterface command,
			DeviceType device, ReturnWrapper returnWrapper) throws ModelException  {
		
		if (device == null
				|| device.getDeviceType() != DeviceType.CUSTOM_CONNECT)
			return ;

		CustomConnect customConnect = (CustomConnect) device;
		Boolean isNumber = false;

		try {
				CustomOutputExtraValueReturn outValue = customConnect.getValue(command
						.getCommandCode(), command.getExtraInfo());
				String finalStr = scanCustomOutputString(command, outValue.getValue(),
						device, outValue.isNumber);
				returnWrapper.addCommOutput(finalStr);
		} catch (CustomConnectException ex){
			logger.log(Level.WARNING, ex.getMessage());
			returnWrapper.setException( ex);
			returnWrapper.setError(true);
			return;
		}
	}

	/**
	 * If a raw code has been specified for this command on this device. It will be returned.
	 * @param command
	 * @param device
	 * @return
	 */
	public void doCustomConnectInputIfPresent(CommsCommand  command, ReturnWrapper returnWrapper) throws CommsProcessException  {

	    for (CustomConnectInput customInput: configHelper.getCustomConnectInputList()) {
	    	for (CustomConnectInputDetails customInputDetails: customInput.getCustomConnectInputDetails()){
		    	try {
			    	String inputListKey = "";
				    boolean matched = false;
			        
			    	Matcher matcherResults;
			    	if (command.hasByteArray()){
			    		matcherResults = customInputDetails.getMatcher(command.getKey().toString());			    		
			    	} else {
			    		matcherResults = customInputDetails.getMatcher(command.getKey());
			    	}
		            if (matcherResults.matches()) {
						configHelper.setLastCommandType(MessageDirection.FROM_HARDWARE);
						String deviceKey = replacePattern (customInputDetails.getKey(), matcherResults);
						CustomConnect deviceMatched =  (CustomConnect)configHelper.getControlItem(deviceKey);
						if (deviceMatched != null) {
							String commandStr = this.scanCustomInputString(replacePattern (customInputDetails.getCommand(),matcherResults),deviceMatched);
							String extra = this.scanCustomInputString(replacePattern (customInputDetails.getExtra(),matcherResults),deviceMatched);
							String extra2 = this.scanCustomInputString(replacePattern (customInputDetails.getExtra2(),matcherResults),deviceMatched);
							String extra3 = this.scanCustomInputString(replacePattern (customInputDetails.getExtra3(),matcherResults),deviceMatched);
							String extra4 = this.scanCustomInputString(replacePattern (customInputDetails.getExtra4(),matcherResults),deviceMatched);
							String extra5 = this.scanCustomInputString(replacePattern (customInputDetails.getExtra5(),matcherResults),deviceMatched);
	
							CommandInterface displayCommand = this.buildCommandForFlash(deviceMatched, commandStr, extra, extra2, extra3,extra4,extra5);
							returnWrapper.addFlashCommand(displayCommand);
							return ;	
						}
			        } 
				} catch (ClassCastException ex) {
					logger.log(Level.WARNING, "An internal error has occured, please contact your integrator");
				}
		    }
	    }
	}
	
	protected String scanCustomOutputString(CommandInterface command, String stringToBeScanned,
			DeviceType device, boolean isNumber) {
		try {
			StringBuffer sb;

			if (isNumber) {
				sb = new StringBuffer();
				// extra is a number so look for a scale command

				Matcher scaleLookup = customScaleString.matcher(stringToBeScanned);
				while (scaleLookup.find()) {
					// Lookup the parameter value from the catalogue
					String minVal = scaleLookup.group(1);
					String maxVal = scaleLookup.group(2);
					String scaledVal;
					scaledVal = String.valueOf(Utility.scaleFromFlash(
							command.getExtraInfo(), minVal, maxVal));					

					scaleLookup.appendReplacement(sb, scaledVal);

				}
				scaleLookup.appendTail(sb);
				stringToBeScanned = sb.toString();
			}
			sb = new StringBuffer();
			Matcher resultLookup = customScanLookupString.matcher(stringToBeScanned);
			while (resultLookup.find()) {
				// Lookup the parameter value from the catalogue
				String theCatalog = resultLookup.group(1);
				Fields theCommandFieldField = Fields.valueOf(resultLookup
						.group(2));
				String srcVal;
				srcVal = this.getCatalogueValue(command.getValue(theCommandFieldField), theCatalog, device);
				resultLookup.appendReplacement(sb, srcVal);
	
				resultLookup.appendTail(sb);
				stringToBeScanned = sb.toString();
			}

			sb = new StringBuffer();

			Matcher resultCmd = customScanCommandString.matcher(stringToBeScanned);
			while (resultCmd.find()) {
				resultCmd.appendReplacement(sb, command.getValue(Fields
						.valueOf(resultCmd.group(1))));
			}
			resultCmd.appendTail(sb);

			return sb.toString();
		} catch (IllegalArgumentException ex) {
			logger.log(Level.WARNING,
					"There was a problem processing the custom instruction for "
							+ device.getName() + " in the model "
							+ this.getName() + " " + ex.getMessage());
			return "";
		} catch (ParameterException ex){
			logger.log(Level.WARNING,ex.getMessage());
			return "";
		}
	}

	protected String scanCustomInputString(String stringToBeScanned, DeviceType device) {
		if (stringToBeScanned == null || stringToBeScanned.equals ("")) return "";
		
		try {
			StringBuffer sb;

			sb = new StringBuffer();
			// extra is a number so look for a scale command

			Matcher scaleLookup = customInputScaleString.matcher(stringToBeScanned);
			while (scaleLookup.find()) {
				// Lookup the parameter value from the catalogue
				String valToScale = scaleLookup.group(1);
				String minVal = scaleLookup.group(2);
				String maxVal = scaleLookup.group(3);
				String scaledVal;
				scaledVal = String.valueOf(Utility.scaleForFlash(
						valToScale, minVal, maxVal));

				scaleLookup.appendReplacement(sb, scaledVal);

			}
			scaleLookup.appendTail(sb);
			stringToBeScanned = sb.toString();

			sb = new StringBuffer();
			Matcher resultLookup = customInputLookupString.matcher(stringToBeScanned);
			while (resultLookup.find()) {
				// Lookup the parameter value from the catalogue
				String theCatalog = resultLookup.group(1);
				String srcVal;

				srcVal = this.findKeyForParameterValue(resultLookup.group(2), theCatalog, device);
				
				resultLookup.appendReplacement(sb, srcVal);

			}
			resultLookup.appendTail(sb);

			return sb.toString();
		} catch (IllegalArgumentException ex) {
			logger.log(Level.WARNING,
					"There was a problem processing the custom instruction for "
							+ device.getName() + " in the model "
							+ this.getName() + " " + ex.getMessage());
			return "";
		} catch (ParameterException ex){
			logger.log(Level.WARNING,ex.getMessage());
			return "";
		}
	}

	
	public String replacePattern (String str,Matcher matcher) {
		if (str == null) return "";
		int numberPatterns = matcher.groupCount();
		if (numberPatterns > 9) numberPatterns = 0;
		for (int i = 0; i <= numberPatterns ; i ++ ) {
			String pattern = "@" + i;
			str = str.replaceAll(pattern,matcher.group(i));
		}
		return str;
	}
	
    /**
     * @return Returns the current value for a device from a specified key.
     */
    public Object getValue(String key) {
            CacheWrapper cachedValue = cache.getCachedObject(key);
            if (cachedValue == null) {
                    return "None";
            }
            if (cachedValue.isSet() == false) {
                    Command retCommand;
                    retCommand = (Command) cachedValue.getCommand();
                    return retCommand.getExtraInfo();
            }else {
            	return "isSet";
            }
    }

    /**
     * @return Returns the current value for a device from a specified key.
     */
    public Object getValue(int extraVal, String key) {
        CacheWrapper cachedValue = cache.getCachedObject(key);
            if (cachedValue == null) {
                    return "None";
            }
            if (cachedValue.isSet() == false) {
                    Command retCommand;
                    retCommand = (Command) cachedValue.getCommand();
                    switch (extraVal) {
                            case 1:
                                    return retCommand.getExtraInfo();
                            case 2:
                                    return retCommand.getExtra2Info();
                            case 3:
                                    return retCommand.getExtra3Info();
                            case 4:
                                    return retCommand.getExtra4Info();
                            case 5:
                                    return retCommand.getExtra5Info();
                    }
                    return retCommand.getExtraInfo();
            }else {
            	return "isSet";
            }
    }

    
    /**
     * @return Returns the last accessed time of a device.
     */
    public Long getLastAccessTime(String key)throws ValueNotUpdatedException {
            Long cachedValue;
            cachedValue = cache.getCachedTime(key);
            if (cachedValue == null || cachedValue.equals(new Long(0))) {
                throw new ValueNotUpdatedException ("Could not find " + key);
            }
            return cachedValue;
    }

    /**
     * @return Returns the number of minutes since the device was last used.
     */
    public Long getLastAccessTimeDuration(String key, String interval) throws ValueNotUpdatedException {
            Long cachedLongValue, retValue;
            Object cachedValue;
            long duration;
            long cachedTime = 0;
            java.lang.Double doubleValue;
            cachedValue = cache.getCachedTime(key);
            if (cachedValue == null || cachedValue.equals(new Long(0))) {
                    throw new ValueNotUpdatedException ("Could not find " + key);
            }
            cachedLongValue = (Long) cachedValue;
            cachedTime = cachedLongValue.longValue();
            duration = System.currentTimeMillis() - cachedTime;
            if (interval.equals("minute")) {
                    duration = duration / 60000;
            }
            else if (interval.equals("hour")) {
                    duration = duration / 3600000;
            }
            else if (interval.equals("day")) {
                    duration = duration / 86400000;
            }

            return  Long.valueOf(duration);
    }
    
    /**
     * @return Returns the system Command for a given key.
     */
    public Object getCommand(String key) {
        CacheWrapper cachedValue = cache.getCachedObject(key);
            if (cachedValue == null) {
                    return "None";
            }
            if (cachedValue.isSet() == false) {
                    Command retCommand;
                    retCommand = (Command) cachedValue.getCommand();
                    return retCommand.getCommandCode();
            } else {
            	return "isSet";
            }
    }
    
	public void buildAnalogControlString(Analog device,
			CommandInterface command, ReturnWrapper returnWrapper)
			throws ModelException {
	}

	public void buildAudioControlString(Audio device, CommandInterface command,
			ReturnWrapper returnWrapper) throws ModelException {
	}
	
	public void buildThermostatControlString(Thermostat  device, CommandInterface command,
			ReturnWrapper returnWrapper) throws ModelException {
	}

	public void buildCustomInputString(CustomInput device,
			CommandInterface command, ReturnWrapper returnWrapper)
			throws ModelException {
	}

	public void buildAVControlString(AV device, CommandInterface command,
			ReturnWrapper returnWrapper) throws ModelException {
	}
	
	public void buildPumpControlString(Pump device, CommandInterface command,
			ReturnWrapper returnWrapper) throws ModelException {
	}

	public void buildHeaterControlString(Heater device, CommandInterface command,
			ReturnWrapper returnWrapper) throws ModelException {
	}

	public void buildAuxiliaryControlString(Auxiliary device, CommandInterface command,
			ReturnWrapper returnWrapper) throws ModelException {
	}
	
	public void buildLightControlString(LightFascade device, CommandInterface command,
			ReturnWrapper returnWrapper) throws ModelException {
	}

	public void buildSensorControlString(SensorFascade device,
			CommandInterface command, ReturnWrapper returnWrapper)
			throws ModelException {
	}

	public void buildAlarmControlString(Alarm device, CommandInterface command,
			ReturnWrapper returnWrapper) throws ModelException {
	}

	public void buildAlertControlString(Alert device, CommandInterface command,
			ReturnWrapper returnWrapper) throws ModelException {
	}

	public void buildPulseOutputControlString(PulseOutput device,
			CommandInterface command, ReturnWrapper returnWrapper)
			throws ModelException {
	}

	public void buildCameraControlString(Camera device,
			CommandInterface command, ReturnWrapper returnWrapper)
			throws ModelException {
	}

	public void buildToggleOutputControlString(ToggleSwitch device,
			CommandInterface command, ReturnWrapper returnWrapper)
			throws ModelException {
	}

	public void buildSMSControlString(SMS device, CommandInterface command,
			ReturnWrapper returnWrapper) throws ModelException {
	}
	
	public void buildUnitControlString(Unit device, CommandInterface command,
			ReturnWrapper returnWrapper) throws ModelException {
	}

	public void buildRAWControlString(DeviceType device, CommandInterface command,
			ReturnWrapper returnWrapper) throws ModelException {
	}
	
	public void buildCustomConnectControlString(CustomConnect device,
			CommandInterface command, ReturnWrapper returnWrapper)
			throws ModelException {
		
			this.doCustomConnectOutputIfPresent(command, device, returnWrapper);
	}
	

    /**
     * @return Returns the configHelper.
     */
    public ConfigHelper getConfigHelper() {
            return configHelper;
    }

    /**
     * @param configHelper The configHelper to set.
     */
    public void setConfigHelper(ConfigHelper configHelper) {
            this.configHelper = configHelper;
    }

	/**
	 * Called every time a model disconnects, just before the comms layer is attatched.
	 */
	public void prepareToAttatchComms(){}

	public boolean isQueueCommands() {
		return queueCommands;
	}

	public void setQueueCommands(boolean queueCommands) {
		this.queueCommands = queueCommands;
	};
	
	public void addStringAttribute (int deviceType, String name, boolean mandatory){
		deviceFactories.addStringAttribute (this,deviceType,name, mandatory);
	}
	
	public void addStringAttribute (Object object, String name, boolean mandatory){
		deviceFactories.addStringAttribute (this,((au.com.BI.Device.Device)object).getDeviceType(), name, mandatory);
	}
	
}
