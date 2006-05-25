/*
 * Created on Jan 25, 2004
 *
 */
package au.com.BI.HAL;

/**
 * @author Colin Canfield
 * @author Explorative Sofwtare Pty Ltd
 *
 */
import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Util.*;

import java.util.*;
import java.util.logging.*;

import au.com.BI.Audio.*;

public class Model extends AudioModel implements DeviceModel {

	protected String outputAudioCommand = "";
	protected HashMap inputs;
	protected HashMap state;
	protected char ETX = '\r';
	protected String intercom;
	protected HashMap HALMessages;
	protected PollDevice pollDevice;
	protected boolean intercomChanged = true;

	public Model() {
		super();

		state = new HashMap(64);
		intercom = "off";
		loadHALMessages();
	}

	public void loadHALMessages() {
		HALMessages = new HashMap(12);
		HALMessages.put("SYSTEM POWERSAVE EXECUTING", "W");
		HALMessages.put("INTERCOM EXECUTING", "W");
		HALMessages.put("IR MACRO SENDING - PLEASE WAIT", "W");
		HALMessages.put("IR SENDING - PLEASE WAIT", "W");
		HALMessages.put("MUTE SENDING - PLEASE WAIT", "W");
		HALMessages.put("PWR STATE SEND-PLEASE WAIT", "W");
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

	}

	public void sendStateOfAllDevices(List commandQueue, long targetFlashDeviceID) {

		Iterator audioDevices = configHelper.getAllControlledDevices();
		while (audioDevices.hasNext()) {
			Audio audioDevice = (Audio) (audioDevices.next());
			sendStateOfDevice(commandQueue, targetFlashDeviceID, audioDevice);
		}
		intercomChanged = false;
	}
	
	public boolean doIPHeartbeat() {
		return false;
	}

       public void sendStateOfDevice(List commandQueue, long targetFlashDeviceID,
			Audio audioDevice) {

		if (intercomChanged) this.sendIntercom(commandQueue, targetFlashDeviceID, audioDevice);

		if (this.hasState(audioDevice.getKey())) {

			StateOfZone currentState = this.getCurrentState(audioDevice
					.getKey());
			this.sendState(commandQueue, targetFlashDeviceID, audioDevice);
		}
	}

	public void sendDirty(List commandQueue, long targetFlashDeviceID) {
		Iterator audioDevices = configHelper.getAllControlledDevices();
		while (audioDevices.hasNext()) {
			sendDirty(commandQueue, targetFlashDeviceID, (Audio) (audioDevices
					.next()));
		}
		intercomChanged = false;
	}

	public void sendDirty(List commandQueue, long targetFlashDeviceID,
			Audio audioDevice) {
		if (intercomChanged) {
			this.sendIntercom(commandQueue, targetFlashDeviceID, audioDevice);
		}

		if (this.hasState(audioDevice.getKey())) {

			StateOfZone currentState = this.getCurrentState(audioDevice
					.getKey());
			if (!currentState.isIgnoreNextPower() && (currentState.getIsDirty()) || currentState.isSrcDirty()) {
				this.sendState(commandQueue, targetFlashDeviceID, audioDevice);
			}
		}
	}

	public void sendIntercom(List commandQueue, long targetFlashDeviceID,
			Audio audioDevice) {
		if (intercom.equals("on"))
			sendToFlash(commandQueue, targetFlashDeviceID, audioDevice
					, "intercom", "on");
		else
			sendToFlash(commandQueue, targetFlashDeviceID, audioDevice
					, "intercom", "off");
	}

	public void sendState(List commandQueue, long targetFlashDeviceID,
			Audio audioDevice) {

		if (this.hasState(audioDevice.getKey())) {

			StateOfZone currentState = this.getCurrentState(audioDevice
					.getKey());

			if (currentState.isDirty) {
				if (currentState.getPower().equals("on"))
					sendToFlash(commandQueue, targetFlashDeviceID, audioDevice
							, "on", "");
				else
					sendToFlash(commandQueue, targetFlashDeviceID, audioDevice
							, "off", "");

				currentState.setIsDirty(false);
				this.setCurrentState(audioDevice.getKey(),currentState);

			}

			if (currentState.isSrcDirty){
				sendToFlash(commandQueue, targetFlashDeviceID, audioDevice
					, "src", currentState.getSrcCode());
				currentState.setSrcDirty(false);
				this.setCurrentState(audioDevice.getKey(),currentState);
			}
		}
	}

	public void sendToFlash(List commandQueue, long targetFlashID, Audio audioDevice,
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
		synchronized (this.commandQueue) {
			commandQueue.add((displayStatus));
			commandQueue.notifyAll();
		}
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
		String inputsDef = (String) this.getParameterValue("INPUTS",
				DeviceModel.MAIN_DEVICE_GROUP);
		if (inputsDef == null)
			logger.log(Level.SEVERE,
							"No input catalogue was specifed for HAL in the configuration file");
		else
			inputs = (HashMap) this.getCatalogueDef(inputsDef);

		this.startPolling();
	}

	public void startPolling () {
		if (pollDevice != null)
			pollDevice.setRunning(false);

		pollDevice = new PollDevice();
		pollDevice.setCommandQueue(commandQueue);
		pollDevice.setDeviceNumber(this.InstanceID);
		pollDevice.setComms(comms);

		pollDevice.setETX(ETX);
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

		if (pollValue > 1000) {
			pollDevice.setPollValue(pollValue);
			pollDevice.setConfigHelper(configHelper);
			pollDevice.setHalState(state);
			logger.log(Level.FINE, "Starting HAL polling, interval = "
				+ pollValueStr);
			pollDevice.start();
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
				configHelper.setLastCommandType(DeviceType.MONITORED);
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
			logger.log(Level.SEVERE, "Error in config, no output key for "
					+ theWholeKey);
		} else {
			if (command.getCommandCode().equals("requestState"))
				findingState = true;


			outputAudioCommand = "";
			cache.setCachedCommand(command.getKey(), command);

			logger.log(Level.FINER,
					"Monitored audio event sending to zone "
							+ device.getKey());

			if (findingState
					&& ((Audio) device).getOutputKey().equals(
							command.getKey())) {
				logger.log(Level.FINER, "State requested for "
						+ command.getKey());
				sendStateOfDevice(commandQueue, command.getTargetDeviceID(),
						(Audio) device);
				return;
			}

			switch (device.getDeviceType()) {
				case DeviceType.AUDIO:
					if ((outputAudioCommand = buildAudioString((Audio) device,
							command)) != null)
						if (logger.isLoggable(Level.INFO)){
							if (!comms.isCommandSentQueueEmpty()) {
								logger.log(Level.FINER,"Sending new audio command while poll was active, clearing");
								pollDevice.setRunning(false);
								comms.clearCommandQueue();
							}
						}
						logger.log(Level.FINE,"Received autio command from client, sending it to HAL");
						sendToSerial(outputAudioCommand + ETX);
						pollDevice.setRunning(true);
					break;
				}

		}
	}

	/**
	 * Controlled item is the default item type. The system will call this
	 * function if it is not from flash. ie. It is from the serial port.
	 */
	public void doControlledItem(CommandInterface command) throws CommsFail {
		boolean didCommand = false;
		String HALReturn = command.getKey().trim();
		logger.log(Level.FINER, "Parsing : " + HALReturn);

		if (HALReturn.equals("E0")) {
			logger.log(Level.FINER, "Received E0, ignoring");
			didCommand = true;
		}
		if (!didCommand && HALReturn.equals("INTERCOM: OFF")) {
			if (!intercom.equals("OFF")) {
				logger.log(Level.FINE, "Intercom is off");
				intercom = "OFF";
				this.intercomChanged = true;
				didCommand = true;
				this.sendDirty(commandQueue, -1);
			}
		}
		if (!didCommand && HALReturn.equals("INTERCOM: ON")) {
			if (!intercom.equals("ON")) {
				intercom = "ON";
				logger.log(Level.FINE, "Intercom is on");
				didCommand = true;
				this.intercomChanged = true;
				this.sendDirty(commandQueue, -1);
			}
		}
		if (!didCommand && HALReturn.startsWith("SCAN COMPLETE - ")) {
			logger.log(Level.FINE, "Individual zone status line");
			String zone;
			CommsCommand lastSent;
			synchronized (comms) {
				lastSent = comms.getLastCommandSent();
			}
			if (lastSent != null) {
				zone = lastSent.getKey();
				if (HALReturn.length() < 16) {
					logger.log(Level.WARNING,"HAL SCAN Complete return was incorrectly formatted " + HALReturn);
					return;
				}
				String information = HALReturn.substring(16);

				logger.log(Level.FINEST, "Zone : " + zone + " Value from HAL : " + information);
			    parseEntry(zone, information);
				synchronized (comms) {
				    comms.acknowlegeCommand(CommDevice.HalState,zone);
				    logger.log (Level.FINEST,"acknowledging zone " + zone);
				    comms.sendNextCommand();
				}
				this.sendDirty(commandQueue, -1);
			} else {
				synchronized (comms) {
				    pollDevice.setFirstRun(true);
				    logger.log (Level.WARNING,"Handshaking failed with HAL, re-synchronizing. HAL Return="+HALReturn+".");
				}

			}

			didCommand = true;
		}
		/*
		00  PWR SAVE    16  NO DATA     32  NO DATA     48  NO DATA

		01  PWR SAVE    17  NO DATA     33  NO DATA     49  NO DATA

		02  NORMAL      18  NO DATA     34  NO DATA     50  NO DATA

		03  PWR SAVE    19  NO DATA     35  NO DATA     51  NO DATA

		04  PWR SAVE    20  NO DATA     36  NO DATA     52  NO DATA
		*/


		if (!didCommand && HALReturn.matches("^\\d.*")) {

			logger.log(Level.FINE, "Zone status line");
		    synchronized (pollDevice) {
		        pollDevice.pausing = true;
		    }

		    synchronized (comms) {
			    comms.acknowlegeCommand(CommDevice.HalStartup);
			}

		    try {
			    String zoneLine[] = HALReturn.split("\\s{2,}+");
				if (zoneLine.length == 8) {
					parseEntry(zoneLine[0], zoneLine[1]);
					parseEntry(zoneLine[2], zoneLine[3]);
					parseEntry(zoneLine[4], zoneLine[5]);
					parseEntry(zoneLine[6], zoneLine[7]);
				}else {
					logger.log (Level.WARNING,"HAL Zone response line was incorrect " + HALReturn);
				}
			} catch (ArrayIndexOutOfBoundsException ex) {
				logger.log (Level.WARNING,"HAL Zone status response was not correctly formed " + HALReturn);
		    	
		    }
			/*
			synchronized (inputs) {
		        pollDevice.setInputs(inputs);
			}
			*/
			synchronized (state) {
		        pollDevice.setHalState(state);
			}
		    synchronized (pollDevice) {
		        pollDevice.pausing = false;
			    pollDevice.notify();
		    }

			didCommand = true;
			this.sendStateOfAllDevices(commandQueue, -1);
		}

		if (!didCommand && HALReturn.startsWith("CC")) {
			logger.log(Level.FINER, "Line started with CC, ignoring");
			didCommand = true;
		}
		if (!didCommand && HALMessages.containsKey(HALReturn)) {
			String execState = (String) HALMessages.get(HALReturn);
			if (execState.equals("R")) {
				logger.log(Level.FINEST, "HAL command completed");
				didCommand = true;
			} else {
				logger.log(Level.FINEST, "HAL command executing");
				didCommand = true;
			}
		}
		if (!didCommand && HALReturn.equals("INVALID COMMAND")) {
			logger.log(Level.FINER, "HAL became confused, clearing command queue. Possibly from : " + this.outputAudioCommand);
			comms.clearCommandQueue();
			pollDevice.pause();
			didCommand = true;
		}		

		if (!didCommand) {
			logger.log(Level.WARNING,
					"HAL returned a code I do not understand : "
							+ HALReturn);
		}

	}

	public int parseEntry(String zone, String entry) {
		logger.log(Level.FINE, "Parsing zone " + zone + " entry " + entry);
		StateOfZone currentState = this.getCurrentState(zone);
		if (entry.equals("NO DATA")) {
		    deleteCurrentState (zone);
		} else {
			if (entry.equals("NORMAL")) {
				currentState.setPower("on");
			} else {
				currentState.setPower("off");
			}
			this.setCurrentState(zone, currentState);
		}
		return 0;
	}

	public String buildAudioString(Audio device, CommandInterface command) {
		String audioOutputString = "";
		boolean commandFound = false;

		String rawBuiltCommand = configHelper.doRawIfPresent(command, device);
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
		StateOfZone currentState = getCurrentState(device.getKey());
		if (theCommand.equals("volume")) {
			if (((String) command.getExtraInfo()).equals("up"))
				audioOutputString = "VR " + device.getKey() + " 1";
			else
				audioOutputString = "VR " + device.getKey() + " 0";
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
			currentState.setIgnoreNextPower(true);
			commandFound = true;
		}
		if (theCommand.equals("off") || theCommand.equals("standby")) {
			audioOutputString = "PW " + device.getKey() + " 0";
			currentState.setPower("off");
			currentState.setIgnoreNextPower(true);
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
				srcForCommand = (String)inputs.get(commandSrc);
				if (srcForCommand == null || srcForCommand.equals("")){
					logger.log (Level.WARNING,"A send audio command was sent to HAL specifying a source " + command.getExtra2Info() + 
							" which is not listed in the catalogue");
				}
			} else {
				srcForCommand = currentState.getSrc();
				if (srcForCommand == null)
					srcForCommand = "0";
			}
			
			String functionStr = (String) functions.get((String) command
					.getExtraInfo());
			if (functionStr == null || functionStr.equals("")) {
				logger
						.log(
								Level.WARNING,
								"A command "
										+ (String) command.getExtraInfo()
										+ " was sent to the HAL which is not configured in the server catalogue");
				commandFound = false;
			} else {
				try {
					int function = Integer.parseInt(functionStr);
					audioOutputString = "IR " + srcForCommand + " "
							+ functionStr;
					commandFound = true;
				} catch (NumberFormatException ex) {
					audioOutputString = null;
					commandFound = false;
				}
			}
			commandFound = true;
		}
		if (theCommand.equals("audio_macro")) {
			audioOutputString = "IM " + (String) command.getExtraInfo();
			commandFound = true;
		}
		if (theCommand.equals("src")) {
			String srcCode = (String) command.getExtraInfo();
			String srcNumber = (String) inputs.get(srcCode);
			if (srcCode == null) {
				logger.log(Level.SEVERE,
								"HAL source command from client did not set the parameter in the EXTRA field.");
				commandFound = true;
			} else {
				if (srcNumber == null) {
					logger.log(Level.SEVERE,
							"No HAL input device specified in catalogue \""
									+ this.getParameterValue("INPUTS",
											DeviceModel.MAIN_DEVICE_GROUP)
									+ "\" for source " + srcCode);
					commandFound = true;
				} else {
					logger.log (Level.FINE,"Selected new HAL input " + srcCode + ", input number " + srcNumber);
					audioOutputString = "SS " + device.getKey() + " "
							+ srcNumber;
					currentState.setSrc(srcNumber);
					currentState.setSrcCode(srcCode);
					currentState.setSrcDirty(true); // always force client actions through to the HAL

					commandFound = true;
				}
			}
		}

		if (commandFound && currentState.isSrcDirty()) {
			currentState.setSrcDirty(false);
			logger.log(Level.FINER, "Built HAL src string " + audioOutputString);
			this.setCurrentState(device.getKey(), currentState);
			return audioOutputString;
		}

		if (commandFound) {
			logger.log(Level.FINER, "Built HAL string " + audioOutputString);
			currentState.setIsDirty(true); // always force client actions through to the HAL
			this.setCurrentState(device.getKey(), currentState);
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
			if (currentState == null)
				currentState = new StateOfZone();
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
	    if (pollDevice != null) pollDevice.setRunning(false);
	    super.close();
	}
}
