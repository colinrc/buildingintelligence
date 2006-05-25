/*
 * Created on Jul 13, 2004
 *
*/
package au.com.BI.CBUS;


import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Util.*;
import au.com.BI.User.*;

import java.util.*;
import java.util.logging.*;
import au.com.BI.Sensors.*;

import au.com.BI.Lights.*;

public class Model extends BaseModel implements DeviceModel {

	protected String outputCBUSCommand = "";
	protected HashMap <String,StateOfGroup>state;
	protected HashMap <String,String>cachedMMI;
	protected char STX=' ';
	protected char ETX='\r';
	protected String applicationCode = "38";
	protected byte applicationCodeByte = 0x38;
	protected String rampCodes = ":02:0A:12:1A:22:2A:32:3A:42:4A:52:5A:62:6A:72:7A";
	protected HashSet <String>applicationCodes = null;
	protected CBUSHelper cBUSHelper;
	protected HashMap <String,ArrayList<Integer>>levelMMIQueues;
	protected HashMap <String,String>sendingExtended;
	protected boolean receivedLevelReturn = true;
	protected long lastSentTime = 0;
	protected char currentChar = 'g';
	protected LinkedList <SensorFascade>temperatureSensors = null;
	protected PollTemperatures pollTemperatures = null;
	protected long tempPollValue = 0L;

	int []etxChars;
	String etxString = "";

	public Model () {
		super();

		state = new HashMap<String,StateOfGroup>(128);
		applicationCodes = new HashSet<String>(10);
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		cachedMMI = new HashMap<String,String> (128);
		cBUSHelper = new CBUSHelper();
		sendingExtended = new HashMap<String,String> (256);
		levelMMIQueues = new HashMap<String,ArrayList<Integer>> (5);
		temperatureSensors = new LinkedList<SensorFascade>();
		etxChars = new int[] {'.','$','%','#','!','\''};

		etxString = new String(".$%#!\'");

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
		synchronized (temperatureSensors) {
			temperatureSensors.clear();
		}
		super.clearItems();
	}

	public void attatchComms()
	throws ConnectionFail {

		super.setETXArray (etxChars);
		super.attatchComms();
	}

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
	
			this.sendToFlash(commandQueue,-1,cbusCommand);
		} catch (ClassCastException ex){
			
		}

	}

	public void addControlledItem (String name, DeviceType details, int controlType) {

		try {
			CBUSDevice device = (CBUSDevice)details;

			String theKey = name;
			if (controlType == DeviceType.MONITORED)  {
				if (details.getDeviceType() == DeviceType.LIGHT_CBUS) {
					String appCode = device.getApplicationCode() ;
					theKey = cBUSHelper.buildKey(appCode,name);
					applicationCodes.add(appCode);
				}
				if (details.getDeviceType() == DeviceType.SENSOR) {
					theKey = name;
				}
			}

			configHelper.addControlledItem (theKey, details, controlType);
		} catch (ClassCastException ex) {
			logger.log( Level.WARNING,"Attempted to add an incorrect device type to the CBUS model");
		}
	}

	public int getStateLevel (String theKey) {
		if (!state.containsKey(theKey)) return 100;

		StateOfGroup  cBusState = (StateOfGroup)state.get(theKey);
		return cBusState.getLevel();

	}

	public boolean setState (CBUSDevice cbusDevice, String command, int extra){
		String theKey = cBUSHelper.buildKey(cbusDevice.getApplicationCode(),cbusDevice.getKey());
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
		String theKey = cBUSHelper.buildKey(cbusDevice.getApplicationCode(),cbusDevice.getKey());
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
		String theKey = cBUSHelper.buildKey(cbusDevice.getApplicationCode(),cbusDevice.getKey());
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
		String theKey = cBUSHelper.buildKey(cbusDevice.getApplicationCode(),cbusDevice.getKey());
		StateOfGroup cBusState = (StateOfGroup)state.get(theKey);
		if (cBusState != null) {
			return cBusState.isFromClient();
		}else {
			return false;
		}
	}

	public boolean setState (CBUSDevice cbusDevice, StateOfGroup cBusState){
		String theKey = cBUSHelper.buildKey(cbusDevice.getApplicationCode(),cbusDevice.getKey());

		state.put(theKey,cBusState);
		return cBusState.isDirty;
	}
	
	public boolean testState (CBUSDevice cbusDevice,String power, String level) {
		String theKey = cBUSHelper.buildKey(cbusDevice.getApplicationCode(),cbusDevice.getKey());
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
		String theKey = cBUSHelper.buildKey(cbusDevice.getApplicationCode(),cbusDevice.getKey());
		if (state.containsKey(theKey)) {
			StateOfGroup cBusState = (StateOfGroup)state.get(theKey);
			cBusState.isDirty = false;
			state.put( theKey,cBusState);
		}
	}

	public void addStartupQueryItem (String name, Object details, int controlType){
		try {
			if (((DeviceType)details).getDeviceType() == DeviceType.TEMPERATURE ){
				temperatureSensors.add ((SensorFascade)details);
			}
			
		} catch (ClassCastException ex) {
			logger.log (Level.FINE,"A temperature sennssor was added that was not the expected type " + ex.getMessage());
		}
	}

	public void doStartup() throws CommsFail {
		if (applicationCodes.isEmpty()) applicationCodes.add("38");

		String pollTempStr = (String)this.getParameterValue("POLL_TEMP_INTERVAL", DeviceModel.MAIN_DEVICE_GROUP);

		try {
			tempPollValue = Long.parseLong(pollTempStr) * 1000;
		} catch (NumberFormatException ex) {
			tempPollValue = 0L;
		}
		enableMMI (true);

		if (!temperatureSensors.isEmpty() && tempPollValue != 0L) {
			pollTemperatures = new PollTemperatures();
			pollTemperatures.setPollValue(tempPollValue);
			pollTemperatures.setTemperatureSensors(temperatureSensors);
			pollTemperatures.setCommandQueue(commandQueue);
			pollTemperatures.setDeviceNumber(InstanceID);
			pollTemperatures.setComms(comms);
			pollTemperatures.start();
		} else {
			logger.log(Level.INFO,"Not starting temperature polls");
		}
	}

	public void requestAllLevels () throws CommsFail{
		this.clearAllLevelMMIQueues();
		for (DeviceType eachDevice:configHelper.getAllControlledDeviceObjects()) {
			try {
				CBUSDevice nextDevice = (CBUSDevice)eachDevice;

				if (nextDevice.getDeviceType() == DeviceType.LIGHT_CBUS && nextDevice.supportsLevelMMI()) {
					this.sendExtendedQuery(nextDevice.getKey(),nextDevice.getApplicationCode(),null,false,"0");
				}
			}catch (ClassCastException ex) {
				logger.log (Level.WARNING,"A device has been configured in the CBUS configuration area that is not a CBUS device");
			}
		}
		this.sendAllLevelMMIQueues();
	}

	public boolean enableMMI (boolean enable) throws CommsFail{
		// Ensure MMI messages are switched on
		try {
			CommsCommand cbusCommsCommand = new CommsCommand();
			cbusCommsCommand.setCommand("~~~"+ETX);
			comms.addCommandToQueue (cbusCommsCommand);
	
			CommsCommand cbusCommsCommand1 = new CommsCommand();
			String toSend = "A32100FF";
			String checkSum = this.calcChecksum(toSend);
			cbusCommsCommand1.setCommand(toSend+checkSum +ETX);
			//new byte [] {(byte)0xA3,(byte)0x21,(byte)00, applicationCode,'g',(byte)ETX});
				comms.addCommandToQueue (cbusCommsCommand1);
	
			CommsCommand cbusCommsCommand2 = new CommsCommand();
			toSend = "A3420002";
			checkSum = this.calcChecksum(toSend);
			cbusCommsCommand2.setCommand(toSend+checkSum + ETX);
			//new byte [] {(byte)0xA3,(byte)0x42,(byte)00, (byte)02,'h',(byte)ETX});
			CommsCommand cbusCommsCommand3 = new CommsCommand();
			CommsCommand cbusCommsCommand4 = new CommsCommand();
			if (enable) {
				toSend = "A3300029";
				checkSum = this.calcChecksum(toSend);
				cbusCommsCommand3.setCommand(toSend+checkSum + ETX);
				toSend = "A3410029";
				checkSum = this.calcChecksum(toSend);
						//new byte [] {(byte)0xA3,(byte)0x30,(byte)00, (byte)0x59,'i',(byte)ETX});
				cbusCommsCommand4.setCommand(toSend+checkSum + ETX);
			}
			else {
				toSend = "A3300009";
				checkSum = this.calcChecksum(toSend);
				cbusCommsCommand3.setCommand(toSend+checkSum + ETX);
						//new byte [] {(byte)0xA3,(byte)0x30,(byte)00, (byte)0x79,'i',(byte)ETX});
				toSend = "A3410009";
				checkSum = this.calcChecksum(toSend);
				cbusCommsCommand4.setCommand(toSend+checkSum + ETX);
			}
	

			comms.addCommandToQueue (cbusCommsCommand2);
			comms.addCommandToQueue (cbusCommsCommand3);
			comms.addCommandToQueue (cbusCommsCommand4);
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
				configHelper.setLastCommandType (DeviceType.MONITORED);
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
					String fullKey = this.cBUSHelper.buildKey(lightDevice.getApplicationCode(),lightDevice.getKey());
					this.sendingExtended.remove(fullKey);  
					// the build cbusstring will add a new entry if a new ramp has been sent
					// ensure that Level CBUS returns will not be decoded, as the user has done an action since
					
					if ((outputCbusCommand = buildCBUSString ((LightFascade)device,command,currentChar)) != null) {

						
						CommsCommand cbusCommsCommand = new CommsCommand();
						cbusCommsCommand.setKey (currentChar);
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
				if (cBUSString.indexOf("~~") > 0 ) {
					this.cachedMMI.clear();
					this.levelMMIQueues.clear();
					this.sendingExtended.clear();
					didCommand = true;
					comms.sendNextCommand(); // I THINK!!!!
					// should be covered by next line     requestAllLevels();
					return;
				}
				if (cBUSString.startsWith("++")) {
					didCommand = true;
					comms.sendNextCommand();
					requestAllLevels();
					return;
				}

				if (cBUSString.startsWith("A34")) {
					logger.log (Level.FINER,"Received startup parameter");
					return;
				}
				if (cBUSString.startsWith("A32")) {
					logger.log (Level.FINER,"Received startup parameter");
					return;
				}
				char firstChar = cBUSString.charAt(0);
				if (cBUSString.startsWith("32")) {
					logger.log (Level.FINER,"Received confirmation, change parameter " + cBUSString.substring(2,4));
					return;
				}
				if (firstChar == '!')  {
					logger.log (Level.FINER,"CBUS buffer overflow or checksum failure");
					try {
						comms.resendAllSentCommands();
					} catch (CommsFail ex) {
						throw new CommsFail ("Communications failed with CBUS " + ex.getMessage());
					}
					return;
				}
				char lastChar = cBUSString.charAt(cBUSString.length()-1);
				if ( etxString.indexOf(lastChar) >= 0) {
					char secondLastChar = cBUSString.charAt(cBUSString.length()-2);
					if (lastChar == '.') {
						logger.log (Level.FINEST,"Received confirmation for command " + secondLastChar);
						comms.acknowlegeCommand(""+secondLastChar);
						comms.sendNextCommand();
					} else {
						logger.log (Level.FINER,"Command failed " + secondLastChar + ", resending");
						comms.repeatCommand(String.valueOf(secondLastChar));
					}
					return;
				}

				int cbusStartByte = 0;
				try {
					cbusStartByte = Integer.parseInt(cBUSString.substring(0,2),16);
				} catch (NumberFormatException ex) {
					logger.log (Level.FINEST,"First offset byte is not hex " + ex.getMessage());
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
						LightFascade cbusDevice = (LightFascade)configHelper.getControlledItem(cBUSHelper.buildKey(retApplicationCode , cBusGroup));
						if (cbusDevice != null) {
							this.setStateFromFlash(cbusDevice,false);
							this.setStateFromWallPanel(cbusDevice,true);
							if (cbusDevice.supportsLevelMMI()) {
								sendExtendedQuery (cBusGroup,retApplicationCode, currentUser, true,"");
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

						LightFascade cbusDevice = (LightFascade)configHelper.getControlledItem(cBUSHelper.buildKey(retApplicationCode , cBusGroup));
						if (cbusDevice == null) {
							didCommand = true;
						}
						else {
							this.setStateFromFlash(cbusDevice,false);
							this.setStateFromWallPanel(cbusDevice,true);
							sendCommandToFlash (cbusDevice,"on",100,currentUser);
							didCommand = true;
						}
					}
					if (!didCommand && commandCode.equals("01")) {
						LightFascade cbusDevice = (LightFascade)configHelper.getControlledItem(cBUSHelper.buildKey(retApplicationCode, cBusGroup));

						if (cbusDevice == null) {
							didCommand = true;
						}
						else {
							this.setStateFromFlash(cbusDevice,false);
							this.setStateFromWallPanel(cbusDevice,true);
							sendCommandToFlash (cbusDevice,"off",0,currentUser);
							didCommand = true;
						}
					}
					if (!didCommand && rampCodes.indexOf(commandCode) > -1) {
						try {
							LightFascade cbusDevice = (LightFascade)configHelper.getControlledItem(cBUSHelper.buildKey(retApplicationCode , cBusGroup));

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

								int percLevel = 100 * (x + 2) / cbusDevice.getMax();
								if (percLevel < DeviceModel.FLASH_SLIDER_RES) percLevel = FLASH_SLIDER_RES;

								if (this.setState (cbusDevice,"on",percLevel)) {
									sendCommandToFlash (cbusDevice,"on",percLevel,currentUser);
								}

								didCommand = true;
							}
						} catch (ClassCastException ex ) {
							logger.log (Level.WARNING,"CBUS level command received from a device that does not support it " + ex.getMessage());
						}
					}
				}


				if (!didCommand  && cbusStartByte >= 192 && cbusStartByte < 224 ) {
					processMMI (cBUSString, currentUser); 
					didCommand = true;
				}

				if (!didCommand  && cbusStartByte >= 224 && cbusStartByte < 255 ) {

					processLevelMMI (cBUSString,currentUser);
					didCommand = true;
				}


	
		} catch (IndexOutOfBoundsException inEx) {
		}
	}

	protected void sendCommandToFlash (SensorFascade cbusDevice,String command,int extra,User currentUser){
		this.setState ((CBUSDevice)cbusDevice,command,extra);
		CommandInterface cbusCommand = ((SensorFascade)cbusDevice).buildDisplayCommand ();
		cbusCommand.setCommand (command);
		cbusCommand.setExtraInfo(Integer.toString(extra));
		cbusCommand.setKey ("CLIENT_SEND");
		cbusCommand.setUser(currentUser);
		cache.setCachedCommand(cbusCommand.getDisplayName(),cbusCommand);
		this.setStateClean (cbusDevice);
		this.sendToFlash(commandQueue,-1,cbusCommand);
	}
	
	protected void sendCommandToFlash (LightFascade cbusDevice,String command,int extra,User currentUser){
		this.setState ((CBUSDevice)cbusDevice,command,extra);
		CBUSCommand cbusCommand = (CBUSCommand)((LightFascade)cbusDevice).buildDisplayCommand ();
		cbusCommand.setCommand (command);
		cbusCommand.setExtraInfo(Integer.toString(extra));
		cbusCommand.setKey ("CLIENT_SEND");
		cbusCommand.setUser(currentUser);
		cache.setCachedCommand(cbusCommand.getDisplayName(),cbusCommand);
		this.setStateClean (cbusDevice);
		this.sendToFlash(commandQueue,-1,cbusCommand);
	}
	
	protected void processMMI (String cBUSString, User currentUser ) throws CommsFail {
		String MMIKey = cBUSString.substring(0,6);
		String lastMMI = (String)cachedMMI.get (MMIKey);
		String numCharsStr = cBUSString.substring(0,2);
		int numPairs = 0;

		try {
			numPairs = Integer.parseInt(numCharsStr,16) - 192;
		} catch (NumberFormatException ex) {
			logger.log (Level.FINEST,"Received invalid pair count from Cbus MMI " + numCharsStr);
		}
		String appAddress = cBUSString.substring(2,4);
		int firstKey = 0;
		String firstKeyStr = cBUSString.substring(4,6);
		try {
			firstKey = Integer.parseInt(firstKeyStr,16);
		} catch (NumberFormatException ex) {
			logger.log (Level.FINEST,"Received invalid MMI group start address " + firstKeyStr);
		}
		if (firstKey == 0) {
			sendMMIQueue(appAddress);
			clearLevelMMIQueue(appAddress);
		}
		if (lastMMI == null || !lastMMI.equals(cBUSString) ) {
		    logger.log (Level.FINEST,"MMI command not cached, evaluating");

		    cachedMMI.put (MMIKey,cBUSString);

			if (numPairs >=  1) {


				String pairVal = "";
				int testValue1 = 0;
				int testValue2 = 0;
				int testValue3 = 0;
				int testValue4 = 0;

				// pair 0 is used to show the start group code.
				for (int i = 0; i < numPairs - 2; i ++ ) {
					pairVal = cBUSString.substring(6+i*2,8+i*2);
	
					int value = 0;
					try {
						value = Integer.parseInt(pairVal,16);
					} catch (NumberFormatException ex) {
						logger.log (Level.FINEST,"Received invalid MMI status byte " + pairVal);
					}
	
					testValue1 = value & 3;
					testValue2 = value & 12;
					testValue3 = value & 48;
					testValue4 = value & 192;
	
					if (testValue1 == 1) { 
						int key = firstKey + i * 4;
						String fullKey = cBUSHelper.buildKey(appAddress , key);
						LightFascade cbusDevice = (LightFascade)configHelper.getControlledItem(fullKey);
						if (cbusDevice != null) {
							if (cbusDevice.supportsLevelMMI()) {
								if (!this.hasState(fullKey)) {
									if (receivedLevelReturn && !this.sendingExtended.containsKey(fullKey)) 
										sendExtendedQuery(key,appAddress,currentUser,false);
								} else {
									updateMMIState (MMIKey, key,appAddress,"on",null,currentUser);
								}
							} else {									
								updateMMIState (MMIKey, key,appAddress,"on","100",currentUser);
							}
						}
					}
					if (testValue1 == 2) { 
						int key = firstKey + i * 4;
						String fullKey = cBUSHelper.buildKey(appAddress , key);
						if (!this.hasState(fullKey)) {
							sendOutput (key,appAddress,"off","0",currentUser);
						} else {
							updateMMIState (MMIKey,firstKey + i * 4,appAddress,"off","0",currentUser); 
						}
					}
	
					if (testValue2 == 4) {
						int key = firstKey + 1 + i * 4;
						String fullKey = cBUSHelper.buildKey(appAddress , key);
						LightFascade cbusDevice = (LightFascade)configHelper.getControlledItem(fullKey);
						if (cbusDevice != null) {
							if (cbusDevice.supportsLevelMMI()) {
								if (!this.hasState(fullKey)) {
									if (receivedLevelReturn && !this.sendingExtended.containsKey(fullKey)) 
										sendExtendedQuery(key,appAddress,currentUser,false);
								} else {
									updateMMIState (MMIKey, key,appAddress,"on",null,currentUser);
								}
							} else {									
								updateMMIState (MMIKey,key,appAddress,"on","100",currentUser); 
							}
						}
					}
					if (testValue2 == 8) { 
						int key = firstKey + 1 + i * 4;
						String fullKey = cBUSHelper.buildKey(appAddress , key);
						if (!this.hasState(fullKey)) {
							sendOutput (key,appAddress,"off","0",currentUser);
						} else {
							updateMMIState (MMIKey,firstKey + 1 + i * 4,appAddress,"off","0",currentUser); 
						}
					}
	
					if (testValue3 == 16) { 
						int key = firstKey + 2 + i * 4;
						String fullKey = cBUSHelper.buildKey(appAddress , key);
						LightFascade cbusDevice = (LightFascade)configHelper.getControlledItem(fullKey);
						if (cbusDevice != null) {
							if (cbusDevice.supportsLevelMMI()) {
								if (!this.hasState(fullKey)) {
									if (receivedLevelReturn&& !this.sendingExtended.containsKey(fullKey)) 
										sendExtendedQuery(key,appAddress,currentUser,false);
								} else {
									updateMMIState (MMIKey, key,appAddress,"on",null,currentUser);
								}
							} else {									
								updateMMIState (MMIKey,key,appAddress,"on","100",currentUser); 
							}
						}
					}
					if (testValue3 == 32) { 
						int key = firstKey + 2 + i * 4;
						String fullKey = cBUSHelper.buildKey(appAddress , key);
						if (!this.hasState(fullKey)) {
							sendOutput (key,appAddress,"off","0",currentUser);
						} else {
							updateMMIState (MMIKey,firstKey + 2 + i * 4,appAddress,"off","0",currentUser); 
						}
					}
	
					if (testValue4 == 64) { 
						int key = firstKey + 3 + i * 4;
						String fullKey = cBUSHelper.buildKey(appAddress , key);
						LightFascade cbusDevice = (LightFascade)configHelper.getControlledItem(fullKey);
						if (cbusDevice != null) {
							if (cbusDevice.supportsLevelMMI()) {
								if (!this.hasState(fullKey)) {
									if (receivedLevelReturn && !this.sendingExtended.containsKey(fullKey)) 
										sendExtendedQuery(key,appAddress,currentUser,false);
								} else {
									updateMMIState (MMIKey, key,appAddress,"on",null,currentUser);
								}

							} else {									
								updateMMIState (MMIKey,key,appAddress,"on","100",currentUser); 
							}
						}
					}
					if (testValue4 == 128) { 
						int key = firstKey + 3 + i * 4;
						String fullKey = cBUSHelper.buildKey(appAddress , key);
						if (!this.hasState(fullKey)) {
							sendOutput (key,appAddress,"off","0",currentUser);
						} else {
							updateMMIState (MMIKey,firstKey + 3 + i * 4,appAddress,"off","0",currentUser);
						}
					}
				}
			}
		}
	}
		
	protected void processLevelMMI (String cBUSString,User currentUser) throws CommsFail {
		String numCharsStr = cBUSString.substring(0,2);
		int numPairs = 0;

		try {
			numPairs = ((Integer.parseInt(numCharsStr,16) - 224) - 4) / 2;
		} catch (NumberFormatException ex) {
			logger.log (Level.FINER,"Received invalid pair count from Cbus MMI " + numCharsStr);
		}

		if (numPairs >=  1) {
			String appAddress = cBUSString.substring(4,6);
			int firstKey = 0;
			String firstKeyStr = cBUSString.substring(6,8);
			try {
				firstKey = Integer.parseInt(firstKeyStr,16);
			} catch (NumberFormatException ex) {
				logger.log (Level.WARNING,"Received invalid MMI group start address " + firstKeyStr);
			}
			logger.log (Level.FINEST,"Received Level MMI request. Start key="+firstKeyStr + " #pairs=" + numPairs + " Str:"+ cBUSString);
			if (!receivedLevelReturn) {
				receivedLevelReturn = true;
				logger.log (Level.FINER,"Received Level return string, will now start processing MMI");
			}

			char nibbleVal1 = ' ';
			char nibbleVal2 = ' ';
			char nibbleVal3 = ' ';
			char nibbleVal4 = ' ';


			// pair 0 is used to show the start group code. 
			for (int i = 0; i <= numPairs ; i ++ ) {
				int keyVal = firstKey + i;
				String fullKey = cBUSHelper.buildKey(appAddress , keyVal);
				
				if (!this.sendingExtended.containsKey(fullKey))
					continue;

				nibbleVal1 = cBUSString.charAt(8+i*4);
				nibbleVal2 = cBUSString.charAt(9+i*4);
				nibbleVal3 = cBUSString.charAt(10+i*4);
				nibbleVal4 = cBUSString.charAt(11+i*4);

				if (nibbleVal1 == '0' && nibbleVal2 == '0' && nibbleVal3 == '0' && nibbleVal4 == '0') {
					continue; //group address not present so skip processing
				}

				String realValue1 = findVal (nibbleVal1);
				String realValue2 = findVal (nibbleVal2);
				String realValue3 = findVal (nibbleVal3);
				String realValue4 = findVal (nibbleVal4);


				if (realValue1 == null || realValue2 == null || realValue3 == null || realValue4 == null) {
					logger.log (Level.FINER,"Noise was present in level request, polling again");
					this.sendExtendedQuery(firstKey + i,appAddress, currentUser,true);
					continue;
				}

				String fullBoolean = realValue3 + realValue4 + realValue1 + realValue2;
				int value = Integer.parseInt (fullBoolean,2);
				int normValue = (int)((double)value / 255.0 * 100.0);
				if (value == 255) normValue = 100;
				if (normValue == 0) normValue =1;
				String valStr = Integer.toString(normValue);
				CBUSDevice cBUSDevice = (CBUSDevice)configHelper.getControlledItem(fullKey);
				if (cBUSDevice == null || cBUSDevice.getRelay().equals ("Y")){
					continue;
				}
				if (value == 0) {
					if (logger.isLoggable(Level.FINEST)){
						logger.log (Level.FINEST,"Sending CBUS off to flash for key "+keyVal + "(0x"+Integer.toHexString(keyVal)+")");
					}
					sendOutput (firstKey + i ,appAddress,"off","00",currentUser);
					this.sendingExtended.remove(fullKey);
				} else {
					if (!this.testState(fullKey,"on",valStr)) {
						if (logger.isLoggable(Level.FINEST)) {
								logger.log (Level.FINEST,"Sending CBUS on to flash for key "+keyVal + "(0x"+Integer.toHexString(keyVal)+") Lvl=" + valStr + " boolean="+fullBoolean);
						}
						sendOutput (firstKey + i ,appAddress,"on",valStr,currentUser);
					}
					this.sendingExtended.remove(fullKey);
				}
			}
		}
	}
	
	protected void updateMMIState (String MMIKey, int key , String appAddress,String command ,String extra,User currentUser) throws CommsFail {
		String fullKey = this.cBUSHelper.buildKey(appAddress,key);
		StateOfGroup currentState = this.getCurrentState(fullKey);
		boolean fromMMI = currentState.isFromMMI();
		currentState.setPower(command,true);
		try {
			if (extra != null) {
				int level = Integer.parseInt(extra);
				currentState.setLevel(level,true);
			}

			if (currentState.getIsDirty() &&   currentState.countConflict == 0) {
				currentState.countConflict++;
				this.cachedMMI.remove(MMIKey);					
				currentState.setIsDirty(false);
				this.setCurrentState(fullKey,currentState);
			} else {
				if (!currentState.getIsDirty() && fromMMI &&  currentState.countConflict > 0) {
					currentState.countConflict++;
					if (currentState.countConflict >= 3) {
						currentState.setIsDirty(false);
						currentState.countConflict = 0;
						this.setCurrentState(fullKey,currentState);
						if (extra == null){
							sendExtendedQuery(key,appAddress,currentUser,true);
						} else {
							this.sendOutput(key,appAddress,command,extra,currentUser);
						}
					} else {
						this.cachedMMI.remove(MMIKey);
						currentState.setIsDirty(false);
						this.setCurrentState(fullKey,currentState);
					}
				}
			}
		} catch (NumberFormatException ex) {
			
		} catch (NullPointerException ex) {}
	}

	public String findVal (char value) {
		if (value == '5') return "11";
		if (value == '6') return "10";
		if (value == '9') return "01";
		if (value == 'A') return "00";
		return null;
	}


	public void sendExtendedQuery (String key, String appCode, User user, boolean immediate,String targetLevel) throws CommsFail{
		try {
			sendExtendedQuery (Integer.parseInt(key,16),appCode, user,immediate,targetLevel);
		} catch (NumberFormatException ex) {}
	}

	public void sendExtendedQuery (int key, String appCode, User user, boolean immediate) throws CommsFail{
		try {
			sendExtendedQuery (key,appCode, user,immediate,"");
		} catch (NumberFormatException ex) {}
	}


	public void sendMMIQueue (String appNumber) throws CommsFail {
		List items = (List)this.levelMMIQueues.get(appNumber);
		if (items != null) {
			Iterator eachItem = items.iterator();
			while (eachItem.hasNext()) {
				Integer nextItem = (Integer)eachItem.next();
				sendLevelMMIQuery (appNumber,nextItem.intValue());
			}
		}
	}

	public void sendExtendedQuery (int key, String appCode, User user, boolean immediate,String targetLevel) throws CommsFail {
		
		String keyStr = cBUSHelper.buildKey(appCode,key);
		//logger.log (Level.FINEST,"Sending MMI output App Code : "  + appCode + " command " + command + " group " + keyStr);
		try {
			CBUSDevice cbusDevice = (CBUSDevice)configHelper.getControlledItem(keyStr);
			if (cbusDevice != null) {
				if (cbusDevice.supportsLevelMMI()) { 
					int startNumber = (int)(key / 32) * 32;
					Integer startNumberInt = new Integer (startNumber);
					
					if (!targetLevel.equals("")) {
						this.sendingExtended.put(keyStr,targetLevel);
					} else {
						if (!this.sendingExtended.containsKey(keyStr) )
							this.sendingExtended.put(keyStr,"");
					}
					//if (immediate && ((new Date().getTime() - lastSentTime ) > 3000)) {
					if (immediate) {
						sendLevelMMIQuery(appCode,startNumber);
						logger.log (Level.FINEST,"Sending level MMI query for App="+appCode + " Start=" + startNumber);
					} else {
						addToLevelMMIQueue(appCode,startNumberInt);
					}
				}
				else {
					sendOutput (key,appCode,"on","100",user);
				}
			}
		} catch (ClassCastException ex) {
			logger.log (Level.WARNING,"Cbus extended Level MMI requested for a non-bus object. Key:" + keyStr + " App:" + appCode + " " + ex.getMessage());
		}

	}

	public void clearLevelMMIQueue (String appNumber){
		this.levelMMIQueues.remove (appNumber);
	}

	public void clearAllLevelMMIQueues () {
		this.levelMMIQueues.clear();
	}

	public void sendAllLevelMMIQueues () throws CommsFail  {

		Iterator eachQueue = levelMMIQueues.keySet().iterator();
		while (eachQueue.hasNext()) {
			this.sendMMIQueue((String)eachQueue.next());
		}
	}

	public void sendLevelMMIQuery (String appNumber, int number) throws CommsFail {
		// code is 7308 + app Code + 00 ; 20 ; 40 ;60 ;80 ; A0 ;C0 ; E0 (ie. each start of groups to return)
		
		String currentChar = this.nextKey();
		
		String outputCbusCommand = this.buildCBUSLevelRequestCommand(appNumber, number,currentChar);

		
		if (outputCbusCommand == null || outputCbusCommand.trim().equals("")){
			logger.log (Level.FINE,"Build CBUS Level request returned an empty string for App " + appNumber + " key " + number);
		} else {
			logger.log (Level.FINEST,"Sending Level CBUS request handshake key " + currentChar + " " + outputCbusCommand);
			CommsCommand cbusCommsCommand = new CommsCommand();
			cbusCommsCommand.setCommand(outputCbusCommand);
			cbusCommsCommand.setKey(currentChar);
			cbusCommsCommand.setKeepForHandshake(true);


			try {
				comms.addCommandToQueue (cbusCommsCommand);
				
				lastSentTime = new Date().getTime();
			} catch (CommsFail e1) {
				throw new CommsFail ("Communication failed communicating with CBUS " + e1.getMessage());
			}
		
			logger.log (Level.FINEST,"Queueing cbus command " + currentChar + " for " + outputCbusCommand);
		}
	}
	
	public void addToLevelMMIQueue (String appNumber, Integer startNumber) {
		ArrayList <Integer> appList;
		if (this.levelMMIQueues.containsKey(appNumber)) {
			appList = (ArrayList <Integer>)levelMMIQueues.get(appNumber);
		} else {
			appList = new ArrayList <Integer>(10);
		}
		if (!appList.contains(startNumber)) {
			appList.add(startNumber);
		}
		levelMMIQueues.put(appNumber,appList);
	}

	public void sendOutput (int key, String appCode, String command, String extra,User user) {

		String keyStr = cBUSHelper.buildKey(appCode,key);
		//logger.log (Level.FINEST,"Sending MMI output App Code : "  + appCode + " command " + command + " group " + keyStr);
		try {
			CBUSDevice cbusDevice = (CBUSDevice)configHelper.getControlledItem(keyStr);

			if (cbusDevice != null) {
				int newLevel;
				try {
					newLevel = Integer.parseInt(extra);
					this.setState (cbusDevice,command, newLevel);
						CBUSCommand cbusCommand = (CBUSCommand)((LightFascade)cbusDevice).buildDisplayCommand ();
						cbusCommand.setCommand (command);
						cbusCommand.setExtraInfo(Integer.toString(newLevel));
						cbusCommand.setKey ("CLIENT_SEND");
						cbusCommand.setUser(user);
						cache.setCachedCommand(cbusCommand.getDisplayName(),cbusCommand);
						this.sendToFlash(commandQueue,-1,cbusCommand);
						this.setStateClean (cbusDevice);
						//logger.log (Level.FINEST,"Sending to flash " + cbusCommand.getDisplayName() + " " + command + " level " + Integer.toString(newLevel));
				} catch (NumberFormatException ex) {
				}
			}
		} catch (ClassCastException ex) {
			logger.log (Level.WARNING,"Non CBUS device reported a CBUS level " + ex.getMessage());
		}

	}

	public String buildCBUSString (LightFascade device, CommandInterface command,String currentChar) throws CommsFail {
		String cBUSOutputString = null;
		boolean commandFound = false;

		String rawBuiltCommand = configHelper.doRawIfPresent (command, device);
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

		StateOfGroup stateOfGroup =this.getCurrentState(device.getApplicationCode(),device.getKey());

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
	
	protected String calcChecksum (String toCalc) {
		int total = 0;
		for (int i = 0; i < toCalc.length(); i+=2) {
			String nextPart = toCalc.substring(i,i+1);
			int val = Integer.parseInt(nextPart,16);
			total += val;
		}
		byte remainder = (byte)(total % 256);
		byte twosComp = (byte)-remainder;
		String hexCheck = Integer.toHexString(twosComp); 
		if (hexCheck.length() == 1) hexCheck = "0" + hexCheck;
		if (hexCheck.length() > 2) hexCheck = hexCheck.substring(hexCheck.length() - 2);
		return hexCheck;
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


	public boolean hasState (String appCode, String group) {
		return hasState(cBUSHelper.buildKey(appCode,group));
	}
	
	public boolean hasState (String fullKey) {
		return state.containsKey(fullKey);		
	}

	public StateOfGroup getCurrentState (String appCode, String group) {
		return getCurrentState (cBUSHelper.buildKey(appCode,group));
	}

	public StateOfGroup getCurrentState (String fullKey) {
		StateOfGroup currentState = (StateOfGroup)state.get(fullKey);
		if (currentState == null) currentState = new StateOfGroup();
		return currentState;
	}


	public void setCurrentState (String appCode, String group, StateOfGroup currentState) {
		setCurrentState (cBUSHelper.buildKey(appCode,group),currentState);
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

}
