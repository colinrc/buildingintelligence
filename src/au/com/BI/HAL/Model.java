/*
 * Created on Jan 25, 2004
 *
 */
package au.com.BI.HAL;

/**
 * @author Colin Canfield
 * @author Explorative Sofwtare Pty Ltd
 */
import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Config.ParameterException;
import au.com.BI.Device.DeviceType;
import au.com.BI.Util.*;

import java.util.*;
import java.util.logging.*;

import au.com.BI.Audio.*;

public class Model extends SimplifiedModel implements DeviceModel {

	protected String outputAudioCommand = "";
	protected HashMap <String,StateOfZone>state = null;
	protected String ETX = "\r";
	protected String intercom;
	protected HashMap <String,String>HALMessages;
	protected PollDevice pollDevice = null;
	protected boolean intercomChanged = true;
	protected boolean protocolB = true;
	private String leftOverBuffer = "";
	protected Vector <String> poweredOnAtStartup;
	
	public Model() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		intercom = "off";
		loadHALMessages();
		configHelper.addParameterBlock ("INPUTS",DeviceModel.MAIN_DEVICE_GROUP,"Source inputs");
		configHelper.addParameterBlock ("FUNCTIONS",DeviceModel.MAIN_DEVICE_GROUP,"Audio functions");
		poweredOnAtStartup =new Vector <String>();
	}

	
	public void finishedReadingConfig () throws SetupException {
		super.finishedReadingConfig();
		protocolB = true;

		String protocol = (String)this.getParameterValue("PROTOCOL", DeviceModel.MAIN_DEVICE_GROUP);
		state = new HashMap<String,StateOfZone>(64);
		if (protocol != null && protocol.equals("A")) {
				protocolB = false;


				String pollValueStr = (String) this.getParameterValue("POLL_INTERVAL",
						DeviceModel.MAIN_DEVICE_GROUP);
				long pollValue = 3000;
				if (pollValueStr != null && !pollValueStr.equals((""))) {
					try {
						pollValue = Long.parseLong(pollValueStr) * 1000;
					} catch (NumberFormatException ex) {
						pollValue = 3000;
					}
				}
				pollDevice = new PollDevice();
				pollDevice.setCommandQueue(commandQueue);
				pollDevice.setDeviceNumber(this.InstanceID);
				pollDevice.setComms(comms);

				pollDevice.setETX(ETX);
				
				if (pollValue > 1000) {
					pollDevice.setPollValue(pollValue);
					pollDevice.setConfigHelper(configHelper);
					pollDevice.setHalState(state);
					logger.log(Level.FINE, "Starting HAL polling, interval = "
						+ pollValueStr);
		
				}
		}
	    if (protocolB) { 
	    	this.setNaturalPackets(true);
	    }
	}
	
	public void loadHALMessages() {
		HALMessages = new HashMap<String,String>(12);
		HALMessages.put("SYSTEM POWERSAVE EXECUTING", "W");
		HALMessages.put("INTERCOM EXECUTING", "W");
		HALMessages.put("IR MACRO SENDING - PLEASE WAIT", "W");
		HALMessages.put("IR SENDING - PLEASE WAIT", "W");
		HALMessages.put("MUTE SENDING - PLEASE WAIT", "W");
		HALMessages.put("PWR STATE SEND-PLEASE WAIT", "W");
		HALMessages.put("POWER STATE SEND-PLEASE WAIT", "W");
		HALMessages.put("SOURCE SEND - PLEASE WAIT", "W");
		HALMessages.put("VOLUME SEND - PLEASE WAIT", "W");
		HALMessages.put("SCANNING NODES - PLEASE WAIT", "W");
		HALMessages.put("SCANNING NODE - PLEASE WAIT", "W");

		HALMessages.put("SCAN COMPLETE - NORMAL", "R");
		HALMessages.put("SCAN COMPLETE - PWR SAVE", "R");
		HALMessages.put("SCAN COMPLETE - NO DATA", "R");
		HALMessages.put("SOURCE SEND COMPLETE", "R");
		HALMessages.put("VOLUME SEND COMPLETE", "R");
		HALMessages.put("COMMAND SENT", "R");
		HALMessages.put("POWER STATE SEND COMPLETE", "R");
		HALMessages.put("MUTE SEND COMPLETE", "R");
		HALMessages.put("IR SEND COMPLETE", "R");
		HALMessages.put("IR MACRO SEND COMPLETE", "R");
		HALMessages.put("EXITED INTERCOM MODE", "R");
		HALMessages.put("INTERCOM EXECUTED", "R");
		HALMessages.put("SYSTEM POWERSAVE EXECUTED", "R");
		HALMessages.put("MASTER MODE", "R");
		HALMessages.put("SLAVE MODE", "R");

	}

	public void sendStateOfAllDevices(long targetFlashDeviceID) {

		for (DeviceType audio: configHelper.getAllControlledDeviceObjects()){
			sendStateOfDevice( targetFlashDeviceID, (Audio)audio);
		}
		intercomChanged = false;
	}
	
	public boolean doIPHeartbeat() {
		if (protocolB){
			return true;
		} else {
			return false;
		}
	}

       public void sendStateOfDevice(long targetFlashDeviceID,
			Audio audioDevice) {

		if (intercomChanged) this.sendIntercom( targetFlashDeviceID, audioDevice);

		if (this.hasState(audioDevice.getKey())) {

			StateOfZone currentState = this.getCurrentState(audioDevice
					.getKey());
			this.sendState( targetFlashDeviceID, audioDevice);
		}
	}

	public void sendDirty(long targetFlashDeviceID) {

		for (DeviceType audio:configHelper.getAllControlledDeviceObjects()){
			sendDirty( targetFlashDeviceID, (Audio)audio);
		}
		intercomChanged = false;
	}
	
	public int getPadding() {
		return 2;
	}
	
	public void sendDirty(long targetFlashDeviceID,
			Audio audioDevice) {
		
		if (intercomChanged) {
			this.sendIntercom( targetFlashDeviceID, audioDevice);
		}

		if (this.hasState(audioDevice.getKey())) {

			StateOfZone currentState = this.getCurrentState(audioDevice
					.getKey());
			if (!currentState.isIgnoreNextPower() && (currentState.getDirty()) || currentState.isSrcDirty() || currentState.isVolumeDirty()) {
				this.sendState( targetFlashDeviceID, audioDevice);
			}
		}
	}

	public void sendIntercom (long targetFlashID) {
		for (DeviceType audio:configHelper.getAllControlledDeviceObjects()){
			sendDirty( targetFlashID, (Audio)audio);
		}		
	}
	
	public void sendIntercom( long targetFlashDeviceID,
			Audio audioDevice) {
		if (intercom.equals("on"))
			sendToFlash( targetFlashDeviceID, audioDevice
					, "intercom", "on");
		else
			sendToFlash( targetFlashDeviceID, audioDevice
					, "intercom", "off");
	}

	public void sendState(long targetFlashDeviceID,
			Audio audioDevice) {


		if (this.hasState(audioDevice.getKey())) {

			StateOfZone currentState = this.getCurrentState(audioDevice
					.getKey());

			if (currentState.dirty) {
				if (currentState.getPower().equals("on"))
					sendToFlash( targetFlashDeviceID, audioDevice
							, "on", "");
				else
					sendToFlash( targetFlashDeviceID, audioDevice
							, "off", "");

				currentState.setDirty(false);

			}

			if (currentState.srcDirty){
				sendToFlash( targetFlashDeviceID, audioDevice
					, "src", currentState.getSrcCode());
				currentState.setSrcDirty(false);
			}
			
			if (currentState.volumeDirty){
				sendToFlash( targetFlashDeviceID, audioDevice
					, "volume", String.valueOf(currentState.getVolume()));
				currentState.setVolumeDirty(false);
			}

			if (currentState.muteDirty){
				sendToFlash( targetFlashDeviceID, audioDevice
					, "mute", currentState.getMute());
				currentState.setMuteDirty(false);
			}
		}
	}

	public void sendToFlash( long targetFlashID, DeviceType audioDevice,
			String command, String extra) {
		AudioCommand displayStatus = (AudioCommand)audioDevice.buildDisplayCommand ();
		displayStatus.setKey("CLIENT_SEND");
		displayStatus.setCommand(command);
		displayStatus.setExtraInfo(extra);
		displayStatus.setTargetDeviceID(targetFlashID);
		logger.log(Level.FINEST, "Sending to flash " + displayStatus.getDisplayName()
				+ ":" + displayStatus.getCommandCode() + ":"
				+ displayStatus.getExtraInfo());
		cache.setCachedCommand(displayStatus.getDisplayName(),displayStatus);
		commandQueue.add((displayStatus));

	}

	public void clearItems() {
		synchronized (state){
			state.clear();
		}
		super.clearItems();
	}

	public void doStartup() {
		String startupCommand = "";

		comms.clearCommandQueue();

		synchronized (state){
			state.clear();
		}

		this.leftOverBuffer = "";
		this.sendStartupCommand(true);
	}

	
	public void sendStartupCommand(boolean rescan) throws CommsFail {
		try {

		    comms.clearCommandQueue();
			comms.sendString("E0" + ETX); //switch off echo
			if (rescan)comms.sendString("SC" + ETX); //reset tutondo
			CommsCommand startupCommsCommand = new CommsCommand();
			startupCommsCommand.setKey("");
			startupCommsCommand.setCommand("ST"+ETX );
			
			startupCommsCommand.setExtraInfo("HAL startup");
			startupCommsCommand.setActionType(CommDevice.HalStartup);
			startupCommsCommand.setKeepForHandshake(true);
	
			comms.addCommandToQueue (startupCommsCommand);
		} catch (CommsFail e1) {
			logger.log(Level.WARNING, "Communication failed polling HAL " + e1.getMessage());
			throw new CommsFail ("Communication failed polling HAL " + e1.getMessage());
		} 
	}
	
	public void startPolling () {
		if (pollDevice != null)
			pollDevice.setRunning(false);

		try {
			pollDevice.start();
		} catch (IllegalStateException ex){
			logger.log(Level.WARNING,"Unable to start device poll, HAL may not function correctly");
		}
	}

	public boolean doIControl(String keyName, boolean isClientCommand) {
		configHelper.wholeKeyChecked(keyName);

		if (configHelper.checkForOutputItem(keyName)) {
			logger.log(Level.FINER, "Flash sent command : " + keyName);
			return true;
		} else {
			if (isClientCommand)
				return false;
			else {
				configHelper.setLastCommandType(MessageDirection.FROM_HARDWARE);
				// Anything coming over the serial port I want to process
				return true;
			}
		}
	}

	public void doOutputItem(CommandInterface command) throws CommsFail {
		String theWholeKey = command.getKey();
		boolean findingState = false;
		DeviceType device = configHelper.getOutputItem(theWholeKey);

		if (device == null) {
			logger.log(Level.SEVERE, "Error in config, no Audio device is present for "
					+ theWholeKey);
		} else {
			if (command.getCommandCode().equals("requestState")) {
				findingState = true;
			}

			outputAudioCommand = "";
			cache.setCachedCommand(command.getKey(), command);

			if ( findingState
					&& ((Audio) device).getOutputKey().equals(
							command.getKey())) {
				logger.log(Level.FINER, "State requested for "
						+ command.getKey());
				sendStateOfDevice( command.getTargetDeviceID(),
						(Audio) device);
				return;
			}
			
			if (!protocolB) {
	
				switch (device.getDeviceType()) {
					case DeviceType.AUDIO:
						if ((outputAudioCommand = buildAudioString((Audio) device,
								command)) != null)
							if (logger.isLoggable(Level.INFO)){
								if (!comms.isCommandSentQueueEmpty() && pollDevice != null) {
									logger.log(Level.FINER,"Sending new audio command while poll was active, clearing");
									pollDevice.setRunning(false);
									comms.clearCommandQueue();
								}
							}
							logger.log(Level.FINE,"Received audio command from client, sending it to HAL");
							sendToSerial(outputAudioCommand + ETX);
							if (pollDevice != null ) pollDevice.setRunning(true);
						break;
					}
			} else {
				
				// Protocol B
				
				switch (device.getDeviceType()) {
				case DeviceType.AUDIO:
					if ((outputAudioCommand = buildAudioString((Audio) device,
							command)) != null)

						logger.log(Level.FINE,"Received audio command from client, sending it to HAL");
						sendToSerial(outputAudioCommand + ETX);
					break;
				}
			}

		}
	}

	/**
	 * Controlled item is the default item type. The system will call this
	 * function if it is not from flash. ie. It is from the serial port.
	 */
	public void doControlledItem(CommandInterface command) throws CommsFail {
		String HALReturn = command.getKey(); // don't trim as trailing and leading space can be important
		logger.log(Level.FINEST, "HAL Raw Buffer : " + HALReturn);

		String items[] = HALReturn.split("\n|\r");
		int numItems = items.length;

		for (int i = 0; i < numItems; i ++){
			if (i == 0){
				String tmpBuffer = leftOverBuffer + items[0]; // process anything left over from the previous call if only half a data packet was sent
				leftOverBuffer = "";
				
				if (!tmpBuffer.equals ("")){
					logger.log (Level.FINEST, "Processing Buffer " + tmpBuffer);
					processBuffer (tmpBuffer,(i ==  (numItems - 1)) ?  true : false, (i == 0) ?  true : false);
				}
			} else {

				if (!items[i].equals("")){
					logger.log (Level.FINEST, "Processing Buffer " + items[i]);
					processBuffer (items[i],(i ==  (numItems - 1)) ?  true : false,(i == 0) ?  true : false);
				}
			}
		}
	}

	
	public void processBuffer(String HALReturn,boolean lastStringFromSplit, boolean firstStringFromSplit) throws CommsFail {
			boolean foundCommand = false;
			boolean 	processingFailed = false; 

		if (!foundCommand && HALReturn.equals("E0")) {
			logger.log(Level.FINER, "Received E0, ignoring");
			foundCommand = true;
		}
		if (!foundCommand && HALReturn.startsWith("IR")) {
			logger.log(Level.FINER, "Received IR, ignoring");
			foundCommand = true;
		}
		if (!foundCommand && HALReturn.equals("SCANNING NODES - PLEASE WAIT")) {
			logger.log(Level.FINE, "HAL is scanning nodes");
			foundCommand = true;
		}

		if (!foundCommand && HALReturn.equals("INTERCOM: OFF")) {
			if (!intercom.equals("OFF")) {
				logger.log(Level.FINE, "Intercom is off");
				intercom = "OFF";
				this.intercomChanged = true;
				foundCommand = true;
				if (this.protocolB){
					this.sendIntercom(-1);
				} else {
					this.sendDirty( -1);
				}
			} else  {
				foundCommand = true; // no change in intercom
			}
		}
		if (!foundCommand && HALReturn.equals("INTERCOM: ON")) {
			if (!intercom.equals("ON")) {
				intercom = "ON";
				logger.log(Level.FINE, "Intercom is on");
				foundCommand = true;
				this.intercomChanged = true;
				if (this.protocolB){
					this.sendIntercom(-1);
				} else {
					this.sendDirty( -1);
				}
			} else  {
				foundCommand = true; // no change in intercom
			}
		}
		if (!foundCommand && HALReturn.startsWith("SCAN COMPLETE - ") && !protocolB) {
			// This occurs as a result of the protocol A scan, it should not occur from protocol B
			
			logger.log(Level.FINE, "Individual zone status line");
			String zone;
			CommsCommand lastSent;
			synchronized (comms) {
				lastSent = comms.getLastCommandSent();
			}
			if (lastSent != null) {
				zone = lastSent.getKey();
				if (HALReturn.length() < 16) {
					if (!lastStringFromSplit){
						logger.log(Level.WARNING,"HAL SCAN Complete return was incorrectly formatted " + HALReturn);
					}
					processingFailed = true;
				} else  {
					String information = HALReturn.substring(16);
	
					logger.log(Level.FINEST, "Zone : " + zone + " Value from HAL : " + information);
					try {
						parseEntry(zone, information);
					} catch (HALZoneStatusException ex) {
						logger.log (Level.INFO,"An incorrect HAL status line was received, some startup synchronisation may have been missed");
					}
					synchronized (comms) {
					    comms.acknowledgeCommand(CommDevice.HalState,zone,true);
					    logger.log (Level.FINEST,"acknowledging zone " + zone);
					    comms.sendNextCommand();
					}
					this.sendDirty( -1);
				}
			} else {
				   if (!protocolB) {
						synchronized (comms) {
							pollDevice.setFirstRun(true);
						    logger.log (Level.WARNING,"Handshaking failed with HAL, re-synchronizing. HAL Return="+HALReturn+".");

						}
				   }
			}

			foundCommand = true;
		}
		

		if (!foundCommand && (HALReturn.equals("SCAN COMPLETE") || HALReturn.equals("POWER STATE SEND COMPLETE"))) {
			// Scan complete

			if (!protocolB) {
				comms.acknowledgeCommand(CommDevice.HalStartup,false);
			    logger.log (Level.FINEST,"Received startup status, acknowleding and starting poll ");
			    this.startPolling();
				foundCommand = true; // means HAL has processed the startup instruction and is about to send the following block.
			}
			else {
				comms.acknowledgeCommand(CommDevice.HalStartup,false);
				logger.log (Level.FINEST,"Received startup status ");

				foundCommand = true; // means HAL has processed the startup instruction and is about to send the following block.
			
			}
		}
		if (!foundCommand && HALReturn.startsWith("SE ")) {
			// This occurs as a result of the user carrying at an action with a HAL capable of the newer protocol
			
			logger.log(Level.FINE, "Zone activity has occured");
			try {
				Audio audio = parseHALAction(HALReturn);
				if ( audio != null) {
				
					this.sendStateOfDevice( -1,audio);
				} 
			} catch (HALActionException ex){
				processingFailed = true;
			}
			foundCommand = true;
		}
		/*
		00  PWR SAVE    16  NO DATA     32  NO DATA     48  NO DATA

		01  PWR SAVE    17  NO DATA     33  NO DATA     49  NO DATA

		02  NORMAL      18  NO DATA     34  NO DATA     50  NO DATA

		03  PWR SAVE    19  NO DATA     35  NO DATA     51  NO DATA

		04  PWR SAVE    20  NO DATA     36  NO DATA     52  NO DATA
		*/

		if (pollDevice != null && !protocolB){
		    synchronized (pollDevice) {
		        pollDevice.pausing = true;
		    }
		}

		synchronized (comms) {
		    comms.acknowledgeCommand(CommDevice.HalStartup,false );
		}
		if (!foundCommand && HALReturn.matches("^\\d.*")) {
		    try {
			    String zoneLine[] = HALReturn.split("\\s{2,}+");
				if (zoneLine.length == 8) {
					logger.log(Level.FINE, "Zone status line");

					parseEntry(zoneLine[0], zoneLine[1]);
					parseEntry(zoneLine[2], zoneLine[3]);
					parseEntry(zoneLine[4], zoneLine[5]);
					parseEntry(zoneLine[6], zoneLine[7]);
					
					for (String eachKey: poweredOnAtStartup){
						comms.sendString("PW " + eachKey + " 1"+ETX); 
						// each input that is already on, switch it on again to fool the HAL into sending a status string including current source
					}
					poweredOnAtStartup.clear();
				}else {
					// may not have the full line yet.
					throw new HALZoneStatusException();
					
				}
			} catch (ArrayIndexOutOfBoundsException ex) {
				logger.log (Level.WARNING,"HAL Zone status response was not correctly formed " + HALReturn);
		    	
		    } catch (HALZoneStatusException ex) {
				if (!lastStringFromSplit) {
					logger.log (Level.WARNING,"HAL Zone response line was incorrect " + HALReturn);						
				} else {
					processingFailed = true;
				}
		    	
		    }
			/*
			synchronized (inputs) {
		        pollDevice.setInputs(inputs);
			}
			*/

			if (!protocolB){
				synchronized (state) {
			        pollDevice.setHalState(state);
				}
			    synchronized (pollDevice) {
			        pollDevice.pausing = false;
				    pollDevice.notify();
			    }

			} 
		    this.sendStateOfAllDevices( -1);
			foundCommand = true;
		}

		if (!foundCommand && HALReturn.startsWith("CC")) {
			logger.log(Level.FINER, "Line started with CC, ignoring");
			foundCommand = true;
		}
		if (!foundCommand && HALMessages.containsKey(HALReturn)) {
			String execState = (String) HALMessages.get(HALReturn);
			if (execState.equals("R")) {
				logger.log(Level.FINEST, "HAL command completed");
				foundCommand = true;
			} else {
				logger.log(Level.FINEST, "HAL command executing");
				foundCommand = true;
			}
		}
		if (!foundCommand && HALReturn.equals("INVALID COMMAND")) {
			logger.log(Level.FINER, "HAL became confused, clearing command queue. Possibly from : " + this.outputAudioCommand);
			comms.clearCommandQueue();
			if (!protocolB) pollDevice.pause();
			foundCommand = true;
		}		
		if (!foundCommand && HALReturn.startsWith("AM6")) {

			foundCommand = true;
		}
		if (!foundCommand && HALReturn.trim().equals ("")){
			if (lastStringFromSplit) {
				processingFailed = true;
				foundCommand = true;
			} else {
				return;
			}

		}
		if (processingFailed  || (foundCommand == false && lastStringFromSplit)) {			
			leftOverBuffer = HALReturn;
			return;
		}

		if (!foundCommand) {
			logger.log(Level.INFO,
					"HAL returned a code I do not understand : "
							+ HALReturn + ":" + HALReturn);
		}

	}

	public int parseEntry(String zone, String entry) throws HALZoneStatusException {
		logger.log(Level.FINE, "Parsing zone " + zone + " entry " + entry);
		if (!protocolB){
			// protocol A
			StateOfZone currentState = this.getCurrentState(zone);
			if (entry.equals("NO DATA")) {
			    deleteCurrentState (zone);
			} else {
				if (entry.equals("NORMAL")) {
					currentState.setPower("on");
				} else {
					if (entry.equals("PWR SAVE")){
						currentState.setPower("off");
					} else {
						throw new HALZoneStatusException ();
					}
				}
			}
		}
		else {
			
			// protocol B
			DeviceType audio = configHelper.getControlledItem(zone);

			if (entry.equals("NORMAL")) {
				if (audio != null ) {
					this.sendToFlash(-1,audio,"on","");
					poweredOnAtStartup.add(audio.getKey());
				}
			} 
			else {
				if (entry.equals("NO DATA")){
					if (audio != null) this.sendToFlash(-1,audio,"off","");
				} else {
					
					if (entry.equals("PWR SAVE")){

						if (audio != null) this.sendToFlash(-1,audio,"off","");
					} else {

						throw new HALZoneStatusException ();
					}
				}
			}

		}
		return 0;
	}
	
	public Audio parseHALAction(String HALReturn) throws HALActionException {
		String parts[] = HALReturn.split(" ");
		if (parts.length != 6){
			logger.log(Level.INFO,"Did not receive a full buffer " + HALReturn);
			throw new HALActionException();
		}
		String zone = parts[1]; 
		String power = parts[2];
		String src = parts[3];
		String vol = parts[4];
		String mute = parts[5];

		logger.log(Level.FINE, "Parsing zone " + zone );
			
		try {
			// protocol B
			DeviceType device = configHelper.getControlledItem(zone);
			Audio audio = (Audio)device; 
				
			
			StateOfZone currentState = getCurrentState(audio.getKey()); 
			if (audio != null){
				if (power.equals ("0")) {
					currentState.setPower("off");
				} else {
					currentState.setPower("on");
				}

				try {
					String srcText = findKeyForParameterValue(src, "INPUTS", audio);
					currentState.setSrcCode(srcText);
					currentState.setSrc(src);
				} catch (ParameterException ex){
					logger.log(Level.WARNING,"A source was selected for HAL that has not been configured, please contact your integrator " + ex.getMessage());
				}
				
				try {
					int volume = Utility.scaleForFlash(vol, 0, 31,false);
					currentState.setVolume(volume);

				} catch (NumberFormatException e) {
					logger.log(Level.WARNING,"HAL did not return a correct volume " + e.getMessage());
					currentState.setVolume(StateOfZone.VOL_INVALID);
					 
				 }
				if (mute.equals ("0")) {
					currentState.setMute("off");
				} else {
					currentState.setMute("on");
				}
				return audio;
			} else {
				return null;
			}
		} catch (ClassCastException ex){
			logger.log (Level.WARNING,"A non-audio device was configured for the HAL, please contact your integrator");
			return null;
		}
	}

	public String buildAudioString(Audio device, CommandInterface command) {
		String audioOutputString = "";
		boolean commandFound = false;

		String rawBuiltCommand = doRawIfPresent(command, device);
		if (rawBuiltCommand != null) {
			audioOutputString = rawBuiltCommand;
			commandFound = true;
		}
		String theCommand = command.getCommandCode();
		if (!commandFound && theCommand == "") {
			logger.log(Level.WARNING, "Empty command received from client "
					+ command.getCommandCode());
			return null;
		}
		StateOfZone currentState = null;
		currentState = getCurrentState(device.getKey());
		if (theCommand.equals("volume")) {
			if ( command.getExtraInfo().equals("up")){
				audioOutputString = "VR " + device.getKey() + " 1";
				currentState.setVolume(StateOfZone.VOL_INVALID);
			}
			else { 
				if (command.getExtraInfo().equals("down")){
					audioOutputString = "VR " + device.getKey() + " 0";
					currentState.setVolume(StateOfZone.VOL_INVALID);
				} else {
					try {
						int scaledVal = Utility.scaleFromFlash(command.getExtraInfo(), 0, 31, false);

						currentState.setVolume(scaledVal);
						audioOutputString = "VA " + device.getKey() + " " + String.valueOf(scaledVal);
					} catch (NumberFormatException ex){
						logger.log (Level.INFO,"An invalid volume command was sent to HAL " + ex.getMessage());
					}
				}
			}
			
			commandFound = true;
		}

		if (theCommand.equals("mute")) {
			if (((String) command.getExtraInfo()).equals("on")) {
				audioOutputString = "MU " + device.getKey() + " 1";
				currentState.setMute("on");
			} else {
				audioOutputString = "MU " + device.getKey() + " 0";
				currentState.setMute("off");
			}
			commandFound = true;
		}

		if (theCommand.equals("on")) {
			audioOutputString = "PW " + device.getKey() + " 1";
				currentState.setPower("on");
				if (!protocolB) {
					currentState.setIgnoreNextPower(true);
				}	
			commandFound = true;
		}
		if (theCommand.equals("off") || theCommand.equals("standby")) {
			audioOutputString = "PW " + device.getKey() + " 0";
			currentState.setPower("off");
			if (!protocolB) {
				currentState.setIgnoreNextPower(true);
			}
			commandFound = true;
		}
		if (theCommand.equals("intercom")) {
			if (((String) command.getExtraInfo()).equals("on")) {
				audioOutputString = "IE";
				intercom = "on";
			} else {
				audioOutputString = "ID";
				intercom = "off";
			}
			commandFound = true;
		}
		if (theCommand.equals("send_audio_command")) {
			String srcForCommand = "";
			String commandSrc = command.getExtra2Info();
			if (commandSrc != null && !commandSrc.equals("")){
				try {
					srcForCommand = getCatalogueValue(commandSrc, "INPUTS",device);
				} catch (ParameterException e) {
					srcForCommand = currentState.getSrc();
					if (srcForCommand == null)
						srcForCommand = "0";
				}
			} 			String functionStr = "";
			try {
				functionStr = getCatalogueValue(command.getExtraInfo(), "FUNCTIONS",device);
				int function = Integer.parseInt(functionStr);
				audioOutputString = "IR " + srcForCommand + " "
						+ functionStr;
				commandFound = true;
			} catch (ParameterException e) {
				logger.log(Level.WARNING,e.getMessage());
				commandFound = false;
			} catch (NumberFormatException ex) {
				logger.log(Level.WARNING,"The Comfort function was incorrectly formatted " + ex.getMessage() + "  a number is expected");
				audioOutputString = null;
				commandFound = false;
			}
			commandFound = true;
		}
		if (theCommand.equals("audio_macro")) {
			audioOutputString = "IM " + (String) command.getExtraInfo();
			commandFound = true;
		}
		if (theCommand.equals("src")) {
			String srcCode = command.getExtraInfo();
			if (srcCode == null) {
				logger.log (Level.WARNING,"The command from the Flash client has been incorrectly formatted. No src selection was passed");
			}  else {
				String srcNumber= "";
				try {
					srcNumber = getCatalogueValue(srcCode, "INPUTS",device);
					logger.log (Level.FINE,"Selected new HAL input " + srcCode + ", input number " + srcNumber);
					audioOutputString = "SS " + device.getKey() + " "
							+ srcNumber;

					currentState.setSrc(srcNumber);
					currentState.setSrcCode(srcCode);
					currentState.setSrcDirty(true); // always force client actions through to the HAL

				} catch (ParameterException e) {
					logger.log (Level.WARNING,e.getMessage());
				}
			}
			commandFound = true;
			
		}

		if (commandFound && currentState.isAnyDirty()) {
			currentState.setAllDirty(false);
			logger.log(Level.FINER, "Built HAL string " + audioOutputString);
			return audioOutputString;
		}

		if (commandFound) {
			logger.log(Level.FINER, "Built HAL string " + audioOutputString);
			currentState.setDirty(true); // always force client actions through to the HAL
			return audioOutputString;
		} else {
			return null;
		}

	}

	public boolean hasState(String zone) {
		return state.containsKey(zone);
	}

	public StateOfZone getCurrentState(String zone) {
		synchronized (state){
			StateOfZone currentState = (StateOfZone) state.get(zone);
			if (currentState == null){
				currentState = new StateOfZone();
				state.put (zone,currentState);
			}
			return currentState;
		}
	}

	public void setCurrentState(String zone, StateOfZone currentState) {
		synchronized (state){
			state.put(zone, currentState);
		}
	}

	public void deleteCurrentState(String zone) {
		synchronized (state){
			state.remove(zone);
		}
	}

	public void close() throws ConnectionFail {
	    if (!protocolB && pollDevice != null) pollDevice.setRunning(false);
	    super.close();
	}
}
