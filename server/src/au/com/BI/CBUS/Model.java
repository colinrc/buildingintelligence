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
	protected String rampCodes = ":02:0A:12:1A:22:2A:32:3A:42:4A:52:5A:62:6A:72:7A";
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

	public int getStateLevel (CBUSDevice cbusDevice) {
		String theKey = cBUSHelper.buildKey(cbusDevice.getApplicationCode(),cbusDevice.getKey(),cbusDevice.getDeviceType());
		if (!state.containsKey(theKey)) return 100;

		StateOfGroup  cBusState = (StateOfGroup)state.get(theKey);
		return cBusState.getLevel();

	}

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
	
	public boolean getStateFromFlash (CBUSDevice cbusDevice){
		String theKey = cBUSHelper.buildKey(cbusDevice.getApplicationCode(),cbusDevice.getKey(), cbusDevice.getDeviceType());
		StateOfGroup cBusState = (StateOfGroup)state.get(theKey);
		if (cBusState != null) {
			return cBusState.isFromClient();
		}else {
			return false;
		}
	}

	public boolean setState (CBUSDevice cbusDevice, StateOfGroup cBusState){
		String theKey = cBUSHelper.buildKey(cbusDevice.getApplicationCode(),cbusDevice.getKey(),cbusDevice.getDeviceType());

		state.put(theKey,cBusState);
		return cBusState.isDirty;
	}
	
	public boolean testState (CBUSDevice cbusDevice,String power, String level) {
		String theKey = cBUSHelper.buildKey(cbusDevice.getApplicationCode(),cbusDevice.getKey(), cbusDevice.getDeviceType());
		return testState (theKey,power,level);
	}
		
	public boolean testState (String theKey,String power, String levelStr) {

		try{
			int level = Integer.parseInt(levelStr);
			return testState (theKey,power,level);
		} catch (NumberFormatException ex) {
			return false;
		}
	}
		 

	public boolean testState (String theKey,String power, int level) {
		StateOfGroup stateOfGroup = this.getCurrentState(theKey);
		if (stateOfGroup == null) return false;
		if (!stateOfGroup.getPower().equals(power)) return false;

		if (stateOfGroup.getLevel() != level) return false;
		return true;
	}
		 

	public void setStateClean (CBUSDevice cbusDevice) {
		String theKey = cBUSHelper.buildKey(cbusDevice.getApplicationCode(),cbusDevice.getKey(),cbusDevice.getDeviceType());
		if (state.containsKey(theKey)) {
			StateOfGroup cBusState = (StateOfGroup)state.get(theKey);
			cBusState.isDirty = false;
			state.put( theKey,cBusState);
		}
	}

	public void addStartupQueryItem (String name, Object details, MessageDirection controlType){
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

	public void doStartup() throws CommsFail {
		tildeCount = 0;
		this.mMIHelpers.comms = comms; //just to be sure.
		super.doStartup();
		
		if (applicationCodes.isEmpty()) applicationCodes.add("38");
		// CommsCommand cbusCommsCommand = new CommsCommand();
		//   cbusCommsCommand.setCommand("~~"+ETX);
		// set basic at first , don't bother queueing for this.
		comms.sendString("~~"+ETX);

	}

	public void doRestOfStartup () throws CommsFail {

		String pollTempStr = (String)this.getParameterValue("POLL_TEMP_INTERVAL", DeviceModel.MAIN_DEVICE_GROUP);

		if (sliderPulse != null) {
			sliderPulse.setRunning (false);
		}
		sliderPulse = new SliderPulse();

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
			String checkSum = this.calcChecksum(toSend4);
			actionCode = this.nextKey();
			cbusCommsCommand4.setActionCode(actionCode);
			cbusCommsCommand4.setCommand("@"+toSend4 + checkSum+  actionCode+ETX);
			cbusCommsCommand4.setKeepForHandshake(true);
				
			CommsCommand cbusCommsCommand5 = new CommsCommand();
			String toSend5 = "A3420006"; // power up notification on , LOCAL_SAL on
			checkSum = this.calcChecksum(toSend5);
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

    public int logout(User user) throws CommsFail {
    	pollTemperatures.setRunning(false);
        return DeviceModel.SUCCESS;
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

			}
		}
	}

	/**
	 * Controlled item is the default item type.
	 * The system will call this function if it is not from flash.
	 * ie. It is from the serial port.
	 */

	
	public void doControlledItem (CommandInterface command) throws CommsFail
	{
		boolean didCommand=false;
		String cBUSString = command.getKey().trim();
			//logger.log(Level.FINER, "Parsing : " + cBUSString );
		User currentUser = command.getUser();
		
			try {
				if (cBUSString.indexOf("~") >= 0 ) {
					tildeCount ++;
					if (tildeCount > 0) {
						clearAllQueues();
						this.state.clear();
						didCommand = true;
						logger.log (Level.FINE,"Received confirmation of CBUS ~~~ init, sending initial parameters");
						doRestOfStartup();
					}
					// should be covered by next line     requestAllLevels();
					return;
				}
				if (cBUSString.endsWith("+")) {
					// Power up notification received so reset all parameters.
					clearAllQueues();
					this.state.clear();
					didCommand = true;
					comms.sendString("~~"+ETX); // force the interface back into basic mode
					return;
				}

				if (cBUSString.contains("!")) {
					
					logger.log (Level.FINER,"CBUS buffer overflow or checksum failure");
					try {
						comms.resendAllSentCommands();
					} catch (CommsFail ex) {
						throw new CommsFail ("Communications failed with CBUS " + ex.getMessage());
					}
					return;
				}

				if (cBUSString.startsWith("@A3420")  ) {
					logger.log (Level.FINER,"CBUS startup complete, starting normal MMI processing.");
					finishedStartup = true;
					didCommand = true;
				}
				if (cBUSString.startsWith("@A32")) {
					logger.log (Level.FINER,"Received confirmation, change parameter " + cBUSString.substring(3,5));
					didCommand = true;
				}
				if (cBUSString.startsWith("@A34")) {
					logger.log (Level.FINER,"Received confirmation, change parameter " + cBUSString.substring(3,5));
					didCommand = true;
				}
				
				char lastChar = cBUSString.charAt(cBUSString.length()-1);
				if ( etxString.indexOf(lastChar) >= 0) {
					char secondLastChar = cBUSString.charAt(cBUSString.length()-2);
					if (lastChar == '.') {
						logger.log (Level.FINEST,"Received confirmation for command " + secondLastChar);
						if (!finishedStartup && secondLastChar == lastCharOfHandshake) {
							logger.log (Level.FINER,"CBUS startup complete, starting normal MMI processing.");
							finishedStartup = true;
						}

						comms.acknowledgeCommand(""+secondLastChar,false);
						comms.sendNextCommand();
					} else {
						logger.log (Level.FINER,"Command failed " + secondLastChar + ", resending");
						comms.repeatCommand(String.valueOf(secondLastChar));
					}
					return;
				}
				if (didCommand)return ; // shortcut for processing of startup parameter changes, ensure they don't flow into the normal command handling.

				int cbusStartByte = 0;
				try {
					cbusStartByte = Integer.parseInt(cBUSString.substring(0,2),16);
				} catch (NumberFormatException ex) {
					logger.log (Level.FINEST,"Trying to parse MMI message but the first byte is not hex " + ex.getMessage());
					return;
				}
				if (!didCommand && cbusStartByte == 134) {
					// temperature readings do not have checksum

					String deviceID = cBUSString.substring (2,4);
					SensorFascade cbusDevice = (SensorFascade)configHelper.getControlledItem(deviceID);
					if (cbusDevice == null) {
						didCommand = true;
					}
					else {
						try {
							String temperatureStr = cBUSString.substring(12, 14);
							byte temperature = Byte.parseByte(temperatureStr,16);
							if (!this.testState(deviceID, "on", temperature)){
								logger.log(Level.FINE,"Received a change in temperature");
								sendCommandToFlash (cbusDevice,"on",temperature,currentUser);	
								this.setState(deviceID, "on",temperature);
							}
						} catch (ArrayIndexOutOfBoundsException ex){
							logger.log (Level.INFO,"Cbus temperature command is not correctly formatted " + cBUSString);
						}catch (NumberFormatException ex){
							logger.log (Level.INFO,"Cbus temperature command is not correctly formatted " + cBUSString);
						}
						didCommand = true;
					}
				}

				/*
				 * Theoretically redo a level request if there has been checksum failure, but causes a race condition on startup
				 * a CBUS produces a large number of checksum errors when requesting levels
				 * 
				if (!didCommand && !passChecksum(cBUSString)){
					logger.log (Level.FINEST,"Resending level request");
					comms.clearCommandQueue();
					comms.resendAllSentCommands();
					this.requestAllLevels();
					return;
				}
				*/

				if (!didCommand && ((cbusStartByte & 120) == 8)) {
					// Measurement command
					/*
					logger.log (Level.FINE,"Received measurement command " + cBUSString);
					String deviceID = cBUSString.substring (2,4);
					logger.log (Level.FINE,"For device ID " + deviceID);
					try {
						SensorFascade sensor = (SensorFascade)configHelper.getControlledItem(deviceID);
					} catch (ClassCastException ex) {
						logger.log (Level.WARNING,"Measurement Device ID matched a CBUS device that was not a Sensor");
					}
					*/

				}
				if (!didCommand && cbusStartByte == 5) {
					String retApplicationCode = cBUSString.substring(4,6);
					String restOfString = "";
					if ((cBUSString.substring(6,8)).equals("00")) {
						restOfString = cBUSString.substring(8);
					}
					else {
						restOfString = cBUSString.substring(10);
					}


					String commandCode = restOfString.substring(0,2);
					String restOfCommand = restOfString.substring(2);
					String cBusGroup = restOfCommand.substring(0,2);

					
					if (!didCommand && commandCode.equals ("09")) {
						CBUSDevice cbusDevice = (CBUSDevice)configHelper.getControlledItem(cBUSHelper.buildKey(retApplicationCode , cBusGroup,DeviceType.LIGHT_CBUS));
						if (cbusDevice != null) {
							this.setStateFromFlash(cbusDevice,false);
							this.setStateFromWallPanel(cbusDevice,true);
							if (!cbusDevice.isRelay())sliderPulse.removeFromQueues(cbusDevice.getOutputKey());
							if (cbusDevice.supportsLevelMMI()) {
								mMIHelpers.sendExtendedQuery (cBusGroup,retApplicationCode, currentUser, true,"");
								// Main point to trigger a ramp up sequence from a cbus button press
								// Test this to see if it stops sending once 0 or 255 has been reached.
							} else {
								sendCommandToFlash (cbusDevice,"on",100,currentUser);
								didCommand = true;
							}
						}
						didCommand = true;
					}

					if (!didCommand && commandCode.equals("79") ) {

						CBUSDevice cbusDevice = (CBUSDevice)configHelper.getControlledItem(cBUSHelper.buildKey(retApplicationCode , cBusGroup,DeviceType.LIGHT_CBUS));
						if (cbusDevice == null) {
							didCommand = true;
						}
						else {
							this.setStateFromFlash(cbusDevice,false);
							this.setStateFromWallPanel(cbusDevice,true);
							if (!cbusDevice.isRelay())sliderPulse.removeFromQueues(cbusDevice.getOutputKey());
							sendCommandToFlash (cbusDevice,"on",100,currentUser);
							didCommand = true;
						}
					}
					if (!didCommand && commandCode.equals("01")) {
						CBUSDevice cbusDevice = (CBUSDevice)configHelper.getControlledItem(cBUSHelper.buildKey(retApplicationCode, cBusGroup,DeviceType.LIGHT_CBUS));

						if (cbusDevice == null) {
							didCommand = true;
						}
						else {
							this.setStateFromFlash(cbusDevice,false);
							this.setStateFromWallPanel(cbusDevice,true);
							if (!cbusDevice.isRelay())sliderPulse.removeFromQueues(cbusDevice.getOutputKey());
							sendCommandToFlash (cbusDevice,"off",0,currentUser);
							didCommand = true;
						}
					}
					if (!didCommand && rampCodes.indexOf(commandCode) > -1) {
						try {
							CBUSDevice cbusDevice = (CBUSDevice)configHelper.getControlledItem(cBUSHelper.buildKey(retApplicationCode , cBusGroup,DeviceType.LIGHT_CBUS));

							if (cbusDevice == null ) {
								didCommand = true;
							}
							else {
								this.setStateFromFlash(cbusDevice,false);
								this.setStateFromWallPanel(cbusDevice,true);
								String rampLevel = restOfCommand.substring(2,4);
								int x = 0;
								try {
									x = Integer.parseInt(rampLevel,16);
								} catch (NumberFormatException ex) {
									logger.log (Level.FINEST,"Received invalid ramp level for Cbus " + rampLevel);
								}
								if (cbusDevice.isRelay()){
									if (x == 0){
										this.setState (cbusDevice,"off",0); 
										sendCommandToFlash (cbusDevice,"off",0,currentUser);
									} else {
										this.setState (cbusDevice,"on",100); 
										sendCommandToFlash (cbusDevice,"on",100,currentUser);									
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
											sendCommandToFlash (cbusDevice,"on",percLevel,currentUser);
										}
									}
								}

								didCommand = true;
							}
						} catch (ClassCastException ex ) {
							logger.log (Level.WARNING,"CBUS level command received from a device that does not support it " + ex.getMessage());
						}
					}
				}


				if (!didCommand  && cbusStartByte >= 192 && cbusStartByte < 224 && finishedStartup ) {
					mMIHelpers.processMMI (cBUSString, currentUser); 
					didCommand = true;
				}

				if (!didCommand  && cbusStartByte >= 224 && cbusStartByte < 255 ) {

					mMIHelpers.processLevelMMI (cBUSString,currentUser);
					didCommand = true;
				}


	
		} catch (IndexOutOfBoundsException inEx) {
		}
	}


	public void clearAllQueues(){
		comms.clearCommandQueue();
		mMIHelpers.cachedMMI.clear();
		mMIHelpers.levelMMIQueues.clear();
		mMIHelpers.sendingExtended.clear();
		mMIHelpers.clearAllLevelMMIQueues();
	}
	
	protected void sendCommandToFlash (CBUSDevice cbusDevice,String command,int extra,User currentUser){
		this.setState ((CBUSDevice)cbusDevice,command,extra);
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
		cbusCommand.setExtraInfo(Integer.toString(extra));
		cbusCommand.setKey ("CLIENT_SEND");
		cbusCommand.setUser(currentUser);
		cache.setCachedCommand(cbusCommand.getDisplayName(),cbusCommand);
		this.setStateClean (cbusDevice);
		this.sendToFlash(-1,cbusCommand);
	}
	

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

			cBUSOutputString =buildCBUSLabelCommand (device.getApplicationCode(), device.getKey(), catalogueStr, flavour, currentChar,device);
			// labelState.set (device.getOutputKey(),command.getExtra2Info());
		}
		return cBUSOutputString;
	}
			
	protected String buildCBUSLabelCommand (String appCodeStr, String key, String catalogueStr, String flavour, String currentChar, Label device) {
		String returnString = "";
		try {
			String theLabel = labelMgr.getLabelText(catalogueStr);
			logger.log(Level.FINEST,"Building a CBUS label string " + theLabel + " for device "+ device.getOutputKey());
			Vector <Byte> retCodes = new Vector<Byte>();
			retCodes.add( (byte)5);
			retCodes.add(Byte.parseByte(appCodeStr,16));
			retCodes.add((byte)0); // options
			
			int  theCommand = 160 +3 + theLabel.length();
			byte tCommand = (byte)theCommand;
			retCodes.add((byte)theCommand);
			int intGroup = Integer.parseInt(key,16);
			retCodes.add((byte)intGroup); // group address
			retCodes.add((byte)0); 
			retCodes.add((byte)1); // language english

			for (int i = 0; i < theLabel.length(); i ++){
				char eachChar = theLabel.charAt(i);
				retCodes.add((byte)eachChar);
			}
			byte checkSum = calcChecksum(retCodes);
			boolean firstChar = true; // first is different
			for (int i:retCodes){
				if (firstChar) {
					returnString = "\\05";
					firstChar = false;
				}
				else
					returnString += String.format("%02X", i&0xff);
			}
			returnString += String.format("%02X",checkSum);
			returnString += currentChar + ETX;

			return returnString;

		} catch (NumberFormatException er) {
			logger.log (Level.INFO, "Group address is in error for CBUS Label command : "+ er.getMessage());
			return null;
		}
	}
	
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
				cBUSOutputString =buildCBUSOnOffCommand ("79", device.getApplicationCode(), device.getKey(),currentChar);
				stateOfGroup.setPower("on",false);
				stateOfGroup.setLevel(100,false);
			}
			else {
				String rampRate = command.getExtra2Info();
				if (rampRate.equals("")) rampRate = "0";
				cBUSOutputString = buildCBUSRampToCommand (rampRate,device.getApplicationCode(),levelStr, device.getKey(),currentChar);
				stateOfGroup.setPower("on",false);
				stateOfGroup.setLevel(Integer.parseInt(levelStr),false);
		

			}
			commandFound = true;
		}
		if (theCommand.equals("off")) {
			String rampRate = command.getExtra2Info();
			if (!rampRate.equals("")) {
				cBUSOutputString = buildCBUSRampToCommand (rampRate,device.getApplicationCode(),"0", device.getKey(),currentChar);
				stateOfGroup.setPower("on",false);
				stateOfGroup.setLevel(0,false);
				commandFound = true;
			} else {
	
				cBUSOutputString =buildCBUSOnOffCommand ("01", device.getApplicationCode(),device.getKey(),currentChar);
				stateOfGroup.setPower("off",false);
				stateOfGroup.setLevel(0,false);
				commandFound = true;
			}
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
	
	
	public byte calcChecksum(Vector<Byte> vals) {
		int total = 0;

		for (int i: vals){
			total += i;
		}
		int remainder = total % 256;
		byte twosComp = (byte)((~remainder + 1)&0xff);
		return twosComp;			
	}
	
	protected String calcChecksum (String toCalc) {
		int total = 0;
		for (int i = 0; i < toCalc.length(); i+=2) {
			String nextPart = toCalc.substring(i,i+2);
			int val = Integer.parseInt(nextPart,16);
			total += val;
		}
		byte remainder = (byte)(total % 256);
		byte twosComp = (byte)-remainder;
		String hexCheck = Integer.toHexString(twosComp); 
		if (hexCheck.length() == 1) hexCheck = "0" + hexCheck;
		if (hexCheck.length() > 2) hexCheck = hexCheck.substring(hexCheck.length() - 2);
		return hexCheck.toUpperCase();
	}

	protected String buildCBUSOnOffCommand (String cBUSCommand, String appCodeStr,  String group, String key) {
		try {
			int appCode = Integer.parseInt(appCodeStr,16);
			byte remainder = (byte)(((byte)5 + appCode + Byte.parseByte(cBUSCommand,16) + Integer.parseInt(group,16)) % 256);
			byte twosComp = (byte)-remainder;

			String hexCheck = Integer.toHexString(twosComp);
			if (hexCheck.length() == 1) hexCheck = "0" + hexCheck;
			if (hexCheck.length() > 2) hexCheck = hexCheck.substring(hexCheck.length() - 2);

			String returnString = "\\05" + appCodeStr + "00" + cBUSCommand + group + hexCheck;
			returnString = returnString.toUpperCase();
			returnString = returnString + key + ETX;
			return returnString;
		} catch (NumberFormatException er) {
			logger.log (Level.FINE, "Zone entry for CBUS is malformed. Command : " + cBUSCommand + "Group : " + group);
			logger.log (Level.FINEST, "Error: " + er.getMessage());
			return null;
		}
	}

	protected String buildCBUSLevelRequestCommand (String appCodeStr,  int startGroup,String key) {
		try {
			byte appCode = Byte.parseByte(appCodeStr,16);
			byte remainder = (byte)((5+255+115 + 7 + appCode + startGroup ) % 256);
			byte twosComp = (byte)-remainder;
			String numStr = Integer.toHexString(startGroup);
			if (numStr.length() == 1) numStr = "0" + numStr;

			String hexCheck = Integer.toHexString(twosComp);
			if (hexCheck.length() == 1) hexCheck = "0" + hexCheck;
			if (hexCheck.length() > 2) hexCheck = hexCheck.substring(hexCheck.length() - 2);

			String returnString = "\\05FF007307" + appCodeStr + numStr + hexCheck ;
			returnString = returnString.toUpperCase();
			return returnString + key + ETX;
		} catch (NumberFormatException er) {
			logger.log (Level.FINE, "Application code is in error for level request : " + appCodeStr);
			return null;
		}
	}


	protected String buildCBUSRampToCommand (String rampCodeStr, String appCodeStr, String levelStr, String group, String key)  {
		try {
			int level = Integer.parseInt(levelStr);
			//byte levelPerc = ((byte)((level / 100 ) * 255));
			int normValue = (int)((double)level / 100.0 * 255.0);
			if (level == 255) normValue = 100;
			
			String rampRateStr = findRampCode (rampCodeStr);
			if (rampRateStr.equals ("")){
				logger.log (Level.WARNING, "A ramp rate that CBUS cannot support was specified");
				return null;
			}
			byte rampRate = Byte.parseByte(rampRateStr,16);

			byte appCode = Byte.parseByte(appCodeStr,16);

			byte remainder = (byte)(((byte)5 + appCode + rampRate + normValue + Integer.parseInt(group,16)) % 256);
			byte twosComp = (byte)-remainder;
			String hexCheck = Integer.toHexString(twosComp);
			if (hexCheck.length() == 1) hexCheck = "0" + hexCheck;
			if (hexCheck.length() > 2) hexCheck = hexCheck.substring(hexCheck.length() - 2);

			String hexLevel = Integer.toHexString(normValue);
			if (hexLevel.length() == 1) hexLevel = "0" + hexLevel;
			if (hexLevel.length() > 2) hexLevel = hexLevel.substring(hexLevel.length() - 2);

			String returnString = "\\05" + appCodeStr + "00" + rampRateStr + group + hexLevel + hexCheck;
			returnString = returnString.toUpperCase();
			return returnString + key + ETX;
		} catch (NumberFormatException er) {
			logger.log (Level.SEVERE, "Zone entry for CBUS is malformed : " + group);
			return null;
		}
	}

	public boolean passChecksum(String buffer) {
		int l = buffer.length();
		if (l < 2) return false;
		try {
			int total = 0;
			byte checksum = (byte)Integer.parseInt(buffer.substring(l-2),16);

			for (int i = 0; i < l-2 ; i+= 2){
				total += Integer.parseInt(buffer.substring(i,i+2),16);
			}
			byte remainder = (byte)(total % 256);
			byte twosComp = (byte)-remainder;
			if (twosComp != checksum){
				logger.log (Level.FINE,"CBUS String failed checksum. 2s cmp = " + twosComp + " chk = " + checksum + " Buffer was " + buffer );
				return false;
			} else {
				return true;
			}
		} catch (NumberFormatException ex){
			logger.log (Level.WARNING,"CBUS string contained a non-hex character. " + ex.getMessage() + " Buffer was "+ buffer);;
			return false;
		}
	}

	

	public String findRampCode (String rampRate) {
		String retCode = "";
		if (rampRate.equals("0")) retCode = "02";
		if (rampRate.equals("4")) retCode = "0A";
		if (rampRate.equals("8")) retCode = "12";
		if (rampRate.equals("12")) retCode = "1A";
		if (rampRate.equals("20")) retCode = "22";
		if (rampRate.equals("30")) retCode = "2A";
		if (rampRate.equals("40")) retCode = "32";
		if (rampRate.equals("1m")) retCode = "3A";
		if (rampRate.equals("1.5m")) retCode = "42";
		if (rampRate.equals("2m")) retCode = "4A";
		if (rampRate.equals("3m")) retCode = "52";
		if (rampRate.equals("5m")) retCode = "5A";
		if (rampRate.equals("7m")) retCode = "62";
		if (rampRate.equals("10m")) retCode = "6A";
		if (rampRate.equals("15m")) retCode = "72";
		if (rampRate.equals("17m")) retCode = "7A";
		return retCode;
	}


	public boolean hasState (String appCode, String group,int deviceType) {
		return hasState(cBUSHelper.buildKey(appCode,group, deviceType));
	}
	
	public boolean hasState (String fullKey) {
		return state.containsKey(fullKey);		
	}

	public StateOfGroup getCurrentState (String appCode, String group, int deviceType) {
		return getCurrentState (cBUSHelper.buildKey(appCode,group,deviceType));
	}

	public StateOfGroup getCurrentState (String fullKey) {
		StateOfGroup currentState = (StateOfGroup)state.get(fullKey);
		if (currentState == null) currentState = new StateOfGroup();
		return currentState;
	}


	public void setCurrentState (String appCode, String group, StateOfGroup currentState,int deviceType) {
		setCurrentState (cBUSHelper.buildKey(appCode,group, deviceType),currentState);
	}
	
	public void setCurrentState (String fullKey, StateOfGroup currentState) {
		state.put(fullKey, currentState);
	}	
	
	/**
	 * @return Returns the applicationCode.
	 */
	public String getApplicationCode() {
		return applicationCode;
	}
	/**
	 * @param applicationCode The applicationCode to set.
	 */
	public void setApplicationCode(String applicationCode) {
		this.applicationCode = applicationCode;
		this.applicationCodeByte = Byte.parseByte(applicationCode,16);
	}

	public boolean doIPHeartbeat () {
	    return false;
	}
	
	public String nextKey () {
		if (currentChar == 'z') {
			currentChar = 'g';
		}else {
			currentChar ++;			
		}
		return String.valueOf(currentChar);
	}


	public long getLastSentTime() {
		return lastSentTime;
	}


	public void setLastSentTime(long lastSentTime) {
		this.lastSentTime = lastSentTime;
	}
	

}
