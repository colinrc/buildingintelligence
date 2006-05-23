/*
 * Created on Jan 25, 2004
 *
*/
package au.com.BI.Tutondo;

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
	protected HashMap state;
	protected HashMap currentSrc;
	protected TutondoHelper tutondoHelper;
	protected PollDevice pollDevice;
	protected List commandQueue;
	protected boolean protocolB;
	
	public Model () {
		super();
		tutondoHelper = new TutondoHelper();
		pollDevice = null;
		protocolB = true;
	}

	public void clearItems () {
		state.clear();
		currentSrc.clear();
		super.clearItems();
	}
	
	public void finishedReadingConfig () throws SetupException {
		super.finishedReadingConfig();
		protocolB = false;
		String protocol = (String)this.getParameterMapName("PROTOCOL", DeviceModel.MAIN_DEVICE_GROUP);
		if (protocol != null && protocol.equals("B")) {
				protocolB = true;
		}
		state = new HashMap(12); // zones
		currentSrc = new HashMap(40); // maximum tutondo zones		
	}
	
	public void attatchComms() 
	throws ConnectionFail {
	    if (!protocolB) { 
			setTransmitMessageOnBytes(1); // tutondo only sends a single non CR terminated byte.
	    }
		super.attatchComms( );
	}
	
	public void doStartup() {
		
		synchronized (comms) {
			comms.clearCommandQueue();

		
			if (pollDevice != null) pollDevice.setRunning(false);
	
			pollDevice = new PollDevice ();
			pollDevice.setComms(comms);
			pollDevice.setProtocol(protocolB);
		}
		Iterator audioDevices = configHelper.getAllControlledDevices();
		while (audioDevices.hasNext()) {
			Audio audioDevice = (Audio)audioDevices.next();
			pollDevice.addAudioDevice(audioDevice);
		}
		if (!protocolB) {
			pollDevice.setSTX(tutondoHelper.getSTX());
			pollDevice.setETX(tutondoHelper.getETX());
		}
		String pollValueStr = (String)this.getParameterMapName("POLL_INTERVAL",DeviceModel.MAIN_DEVICE_GROUP);
		long pollValue = 3000;
		if (pollValueStr != null && !pollValueStr.equals( (""))){
			try {
				pollValue = Long.parseLong(pollValueStr) * 1000;
			} catch (NumberFormatException ex) {
				pollValue = 3000;
			}
		}
		if (pollValue == 0) pollValue = 1000; // 1 seconds minimum to make sure we don't flood comfort. 
		pollDevice.setPollValue(pollValue);
		logger.log (Level.FINE,"Starting tutondo polling, interval = " + pollValueStr);
		pollDevice.start();
		

	}
	
	
	public void updateClient(String zone,StateOfZone currentState) {
		Audio audioDevice = (Audio)configHelper.getControlledItem(zone);
		if (audioDevice == null) return;
		sendStatus (currentState, commandQueue, -1, audioDevice);
	}
	
	public void updateClientVolume(String zone,StateOfZone currentState) {
		Audio audioDevice = (Audio)configHelper.getControlledItem(zone);
		if (audioDevice == null) return;
		sendVolume (commandQueue, -1, audioDevice, currentState.getVolume());	
	}
	
	public void updateClientSrc(String zone,StateOfZone currentState) {
		Audio audioDevice = (Audio)configHelper.getControlledItem(zone);
		if (audioDevice == null) return;
		sendSrc (commandQueue, -1, audioDevice, currentState.getSrc());	
	}
	
	public void doClientStartup (List commandQueue, long targetFlashDeviceID) {
		Iterator audioDevices = configHelper.getAllControlledDevices();
		while (audioDevices.hasNext()){
			Audio audioDevice =(Audio)(audioDevices.next());
			doClientStartup (commandQueue, targetFlashDeviceID, audioDevice);
			
		}
	}

	public void doClientStartup (List commandQueue, long targetFlashDeviceID, Audio audioDevice) {
		if (this.hasState (audioDevice.getKey())) {
	
			StateOfZone currentState = this.getCurrentState(audioDevice.getKey());
			sendStatus (currentState, commandQueue,  targetFlashDeviceID,  audioDevice);
			sendSrc ( commandQueue,  targetFlashDeviceID,  audioDevice, currentState.getSrc());
		}
	}

	public void sendStatus (StateOfZone currentState, List commandQueue, long targetFlashDeviceID, Audio audioDevice) {
		if (audioDevice == null) return;
		AudioCommand audioCommand = (AudioCommand)audioDevice.buildDisplayCommand ();
		audioCommand.setKey ("CLIENT_SEND");
		audioCommand.setTargetDeviceID(targetFlashDeviceID);
		
		if (currentState.getPower().equals ("on")) {
			audioCommand.setCommand ("on");
			audioCommand.setExtraInfo ("");
		}			
		else {
			audioCommand.setCommand ("off");
			audioCommand.setExtraInfo ("");
		}
		sendToFlash (audioCommand,cache);

		AudioCommand audioMuteCommand = (AudioCommand)audioDevice.buildDisplayCommand ();
		audioMuteCommand.setKey ("CLIENT_SEND");
		audioMuteCommand.setTargetDeviceID(targetFlashDeviceID);
		
		if (currentState.getMute().equals ("on")) {
			audioMuteCommand.setCommand ("mute");
			audioMuteCommand.setExtraInfo ("on");
		}
		else {
			audioMuteCommand.setCommand ("mute");
			audioMuteCommand.setExtraInfo ("off");
		}
		sendToFlash (audioMuteCommand,cache);
	}
	
	public void sendSrc (List commandQueue, long targetFlashDeviceID, Audio audioDevice, String src) {
		AudioCommand audioCommand = (AudioCommand)audioDevice.buildDisplayCommand ();
		audioCommand.setKey ("CLIENT_SEND");
		audioCommand.setTargetDeviceID(targetFlashDeviceID);
		audioCommand.setCommand ("src");
		audioCommand.setExtraInfo (src);
		sendToFlash (audioCommand,cache);	
	}
	
	public void sendVolume (List commandQueue, long targetFlashDeviceID, Audio audioDevice, String volume) {
		AudioCommand audioCommand = (AudioCommand)audioDevice.buildDisplayCommand ();
		audioCommand.setKey ("CLIENT_SEND");
		audioCommand.setTargetDeviceID(targetFlashDeviceID);
		audioCommand.setCommand ("volume");
		audioCommand.setExtraInfo (volume);
		sendToFlash (audioCommand,cache);	
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
			byte[] outputAudioCommand = null;
			cache.setCachedCommand(command.getKey(),command);
			
				
			switch (device.getDeviceType()) {
				case DeviceType.AUDIO :
					if ((outputAudioCommand = buildAudioString ((Audio)device,command)) != null) {
						if (protocolB) {
							logger.log(Level.FINER, "Message from flash generated audio event " + outputAudioCommand + " for zone " + device.getKey());
							comms.sendString(outputAudioCommand);
						} else {
							logger.log(Level.FINER, "Message from flash generated audio event for zone " + device.getKey());
							CommsCommand audioCommsCommand = new CommsCommand();
							audioCommsCommand.setKey (device.getKey());
							audioCommsCommand.setCommandBytes(outputAudioCommand);
							audioCommsCommand.setExtraInfo (((Audio)(device)).getOutputKey());
							synchronized (comms){
								try { 
									comms.addCommandToQueue (audioCommsCommand);
								} catch (CommsFail e1) {
									throw new CommsFail ("Communication failed communitating with Tutondo " + e1.getMessage());
								} 
							}
							logger.log (Level.FINEST,"Queueing audio command for " + (String)audioCommsCommand.getExtraInfo());
							}
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
		boolean commandMatched = false;
		String tutondoResponse = command.getKey();
		CommsCommand lastCommandSent ;
		
		synchronized (comms) {

			int tutondoCode = 0;
			String responseParts[] = new String[6];
			int respCommand = -1;
			int respParam = -1;
			String zone = "";
			int lastActionType = CommDevice.UnkownCommand;
			
			if (protocolB) {
				responseParts = tutondoResponse.split(",");
				try {
					tutondoCode = Integer.parseInt(responseParts[4]);
					int tmpZone = Integer.parseInt(responseParts[2]);
					zone = Integer.toString(tmpZone);
					logger.log(Level.FINEST, "Received byte " + responseParts[4] + " from tutondo for zone " + zone);
					respCommand = Integer.parseInt(responseParts[1]);
					respParam = Integer.parseInt(responseParts[3]);
					if (respCommand == 50) lastActionType = CommDevice.TutondoState;
					if (respCommand == 51) lastActionType = CommDevice.TutondoVolume;
					if (respCommand == 52) lastActionType = CommDevice.TutondoPrograms;

				} catch (NumberFormatException ex) {
					tutondoCode = 0;
					logger.log(Level.FINEST, "Tutondo response code was malformed " + tutondoResponse + " from tutondo");
				} catch (ArrayIndexOutOfBoundsException ex) {
					logger.log(Level.FINEST, "Tutondo response was malformed " + tutondoResponse + " from tutondo");
				}
			} else {

				if (comms.isCommandSentQueueEmpty()) return;

					// For tutondo this will always be a single byte status code.
				lastCommandSent = (CommsCommand)comms.getLastCommandSent();
				lastActionType = lastCommandSent.getActionType();

				if (tutondoResponse.length() == 0) {
					logger.log(Level.WARNING,"Received zero length string from tutondo " + lastCommandSent.getKey());
					comms.gotFeedback();
					comms.sendNextCommand();
					return;
				}
				tutondoCode = (byte)tutondoResponse.charAt(0);
				logger.log(Level.FINEST, "Received byte " + String.valueOf(tutondoCode) + " from tutondo for zone " + lastCommandSent.getKey());
				zone = lastCommandSent.getKey();				
			}

			StateOfZone currentState;
			
			if (this.hasState(zone)) 
				currentState = this.getCurrentState(zone);
			else
				currentState = new StateOfZone();
			
			if (lastActionType == CommDevice.TutondoState ) {
				comms.acknowlegeCommand(CommDevice.TutondoState,zone);
				comms.gotFeedback();
				if (!protocolB) comms.sendNextCommand();
				commandMatched = true;
				if ((tutondoCode & 2) == 2) {
					currentState.setPower("on");
				}
				if ((tutondoCode & 2) == 0) {
					currentState.setPower("off");
				}
				if ((tutondoCode & 8) == 8) {
					currentState.setMute("on");
				}
				if ((tutondoCode & 8) == 0) {
					currentState.setMute("off");
				}
				this.setCurrentState(zone, currentState);
			}
			
			if (lastActionType == CommDevice.TutondoVolume) {
				comms.acknowlegeCommand(CommDevice.TutondoVolume,zone);
				comms.gotFeedback();
				if (!protocolB) comms.sendNextCommand();
				logger.log(Level.FINEST,"Received feedback for tutondo volume");
				commandMatched = true;
				String volume = String.valueOf(tutondoCode);
				currentState.setVolume(scaleVol(volume));
				this.setCurrentState(zone, currentState);
			}
			
			if (protocolB && (respCommand == 5 || respCommand == 6)) {
				logger.log(Level.FINEST,"Adjusting tutondo volume");
				commandMatched = true;
				String volume = String.valueOf(tutondoCode);
				currentState.setVolume(scaleVol(volume));
				this.setCurrentState(zone, currentState);
			}

			if (lastActionType == CommDevice.TutondoPrograms) {
				comms.acknowlegeCommand(CommDevice.TutondoPrograms,zone);
				comms.gotFeedback();
				if (!protocolB) comms.sendNextCommand();
				logger.log(Level.FINEST,"Received feedback for tutondo src");
				commandMatched = true;
				String srcCode = String.valueOf(tutondoCode);
				this.setCurrentSrc(zone,srcCode);
				currentState.setSrcCode(srcCode);
				String src = findSrc (srcCode);
				currentState.setSrc(src);
				this.setCurrentState(zone, currentState);
			}
			
			if (!commandMatched && !protocolB){
				comms.acknowlegeCommand("");
				comms.gotFeedback();
				comms.sendNextCommand();
			}
			if (currentState.getIsDirty()) {
				currentState.setIsDirty(false);
				logger.log (Level.FINER,"Updating Tutondo information for zone " + zone);
				updateClient (zone,currentState);
			}
			if (currentState.isVolumeDirty()) {
				currentState.setVolumeDirty(false);
				logger.log (Level.FINER,"Updating Tutondo volume for zone " + zone);
				updateClientVolume (zone,currentState);
			}
			if (currentState.isSrcDirty()) {
				currentState.setSrcDirty(false);
				logger.log (Level.FINER,"Updating Tutondo src information for zone " + zone);
				updateClientSrc (zone,currentState);
			}
		}
	}


	public String scaleVol (String volume){
		try {
			double intVol = Double.parseDouble(volume);
			Double scaledVol = new Double(intVol/48.0 * 100.0);
			int scaledVolInt = scaledVol.intValue();
			return String.valueOf(scaledVolInt);
		}catch (NumberFormatException ex) {
			logger.log (Level.FINE,"Received invalid tutondo volume " + volume);
			return "";
		}
	}
	
	public String findSrc(String srcCode) {
		String returnVal = "1";
		Iterator inputItems = inputs.keySet().iterator();
		int srcVal = Integer.parseInt(srcCode); 
		while (inputItems.hasNext()) {
			String inputKey = (String)inputItems.next();
			int programVal = Integer.parseInt((String)inputs.get(inputKey));
			if (programVal == srcVal) {
				returnVal = inputKey;
			}
		}
		return returnVal;
	}
	
	public byte[] buildAudioString (Audio device, CommandInterface command){
		byte[] audioOutputString = null;
		boolean commandFound = false;
		
		StateOfZone currentState;
		
		if (this.hasState(device.getKey())) 
			currentState = this.getCurrentState(device.getKey());
		else
			currentState = new StateOfZone();
		
		String rawBuiltCommand = configHelper.doRawIfPresent (command, device);
		if (rawBuiltCommand != null)
		{
			audioOutputString = rawBuiltCommand.getBytes();
			commandFound = true;
		}
		String extra = ((String)command.getExtraInfo());
		int scaledVal = -1;
		try {
			double val = Double.parseDouble(extra);
			if (val >= 0.0 && val <= 48.0) {
				scaledVal = (new Double(val / 48.0 * 100.0)).intValue();
			}
		} catch (NumberFormatException ex){
			
		}
		String theCommand = command.getCommandCode();
		if (!commandFound && theCommand == "") {
			logger.log(Level.WARNING, "Empty command received from client "+ command.getCommandCode());
			return null;
		}
		if (theCommand.equals("volume")) {
			if (extra.equals("up")) {
				audioOutputString =tutondoHelper.buildTutondoCommand (5, 0, device.getKey(),protocolB);
				commandFound = true;	
			}
			if (extra.equals("down")) {
				audioOutputString =tutondoHelper.buildTutondoCommand (6, 0, device.getKey(),protocolB); 
				commandFound = true;	
			}
			if (!commandFound ) {
				if (scaledVal >= 0 ) {
					audioOutputString =tutondoHelper.buildTutondoCommand (7, scaledVal, device.getKey(),protocolB); 
					currentState.setVolume(scaledVal);
					commandFound = true;
				}
			}
		}
		if (theCommand.equals("balance")) {
			if (extra.equals("up")) {
				audioOutputString =tutondoHelper.buildTutondoCommand (11, 0, device.getKey(),protocolB);
				commandFound = true;
			}
			if (extra.equals("down")) {
				audioOutputString =tutondoHelper.buildTutondoCommand (12, 0, device.getKey(),protocolB); 
				commandFound = true;
			}
			if (!commandFound ) {
				if (scaledVal >= 0 ) {
					audioOutputString =tutondoHelper.buildTutondoCommand (18, scaledVal, device.getKey(),protocolB); 
					commandFound = true;
				}
			}
		}
		if (theCommand.equals("bass")) {
			if (extra.equals("up")) {
				audioOutputString =tutondoHelper.buildTutondoCommand (7, 0, device.getKey(),protocolB);
				commandFound = true;
			}
			if (extra.equals("down")) {
				audioOutputString =tutondoHelper.buildTutondoCommand (8, 0, device.getKey(),protocolB); 
				commandFound = true;
			}
			if (!commandFound ) {
				if (scaledVal >= 0 ) {
					audioOutputString =tutondoHelper.buildTutondoCommand (16, scaledVal, device.getKey(),protocolB); 
					commandFound = true;
				}
			}
		}
		if (theCommand.equals("treble")){
			if (extra.equals("up")) {
				audioOutputString =tutondoHelper.buildTutondoCommand (9, 0, device.getKey(),protocolB); 
				commandFound = true;
			}
			if (extra.equals("down")) {
				audioOutputString =tutondoHelper.buildTutondoCommand (10, 0, device.getKey(),protocolB); 
				commandFound = true;
			}
			if (!commandFound ) {
				if (scaledVal >= 0 ) {
					audioOutputString =tutondoHelper.buildTutondoCommand (17, scaledVal, device.getKey(),protocolB); 
					commandFound = true;
				}
			}
		}

		if (theCommand.equals("left")) {
			audioOutputString =tutondoHelper.buildTutondoCommand (14, 0, device.getKey(),protocolB); 
			commandFound = true;
			}
		if (theCommand.equals("right")) {
			audioOutputString =tutondoHelper.buildTutondoCommand (13, 0, device.getKey(),protocolB); 
			commandFound = true;
			}
		if (theCommand.equals("mute")) {
			currentState.setMute(extra);
			if (extra.equals("on")) {
				audioOutputString =tutondoHelper.buildTutondoCommand (21, 0, device.getKey(),protocolB);
			}
			else {
				audioOutputString =tutondoHelper.buildTutondoCommand (22, 0, device.getKey(),protocolB);
			}
			commandFound = true;
			}
		if (theCommand.equals("on")) {
			currentState.setPower("on");
			audioOutputString =tutondoHelper.buildTutondoCommand (3, 0, device.getKey(),protocolB); 
			commandFound = true;
			}
		if (theCommand.equals("off")) {
			currentState.setMute("off");
			audioOutputString =tutondoHelper.buildTutondoCommand (4, 0, device.getKey(),protocolB); 
			commandFound = true;
			}
		if (theCommand.equals("power")) {
		    if (extra.equals ("on")) {
		        audioOutputString =tutondoHelper.buildTutondoCommand (3, 0, device.getKey(),protocolB);
		    		commandFound = true;
		    }
		    if (extra.equals ("off")) {
		        audioOutputString =tutondoHelper.buildTutondoCommand (2, 0, device.getKey(),protocolB);
		    		commandFound = true;
		    }
		    if (extra.equals ("standby")) {
		        audioOutputString =tutondoHelper.buildTutondoCommand (4, 0, device.getKey(),protocolB);
		    		commandFound = true;
		    }
		}
		if (theCommand.equals("send_audio_command")) {
			String functionStr = (String)functions.get((String)command.getExtraInfo());
			if (functionStr == null || functionStr.equals ("")) {
				logger.log(Level.WARNING,"A command " +  (String)command.getExtraInfo() + " was sent to the tutondo which is not configured in the server catalogue");
				commandFound = false;
			}
			else {
				String commandSrc = command.getExtra2Info();
				if (commandSrc != null && !commandSrc.equals("")){
					commandSrc = (String)inputs.get(commandSrc);
					if (commandSrc == null || commandSrc.equals("")){
						logger.log (Level.WARNING,"A send audio command was sent to tutondo specifying a program (source) " + command.getExtra2Info() + 
								" which is not listed in the catalogue");
					}
				} else {
					commandSrc = getCurrentSrc(device.getKey());
				}
				try {
					int function = Integer.parseInt(functionStr);
					audioOutputString =tutondoHelper.buildTutondoCommand (20, function,commandSrc,protocolB); 
					commandFound = true;			
				} catch (NumberFormatException ex) {
					audioOutputString = null;
					commandFound = false;
				}
			}
		}
		if (theCommand.equals("src")) {
			String srcCode = (String)inputs.get((String)command.getExtraInfo());
			try {
				int src = Integer.parseInt(srcCode);
				setCurrentSrc(device.getKey(),srcCode);
				currentState.setSrc(srcCode);
				audioOutputString = tutondoHelper.buildTutondoCommand (19, src, device.getKey(),protocolB);
				logger.log (Level.FINEST,"Changing audio source");
				commandFound = true;
			} catch (NumberFormatException ex) {
				audioOutputString = null;
				commandFound = false;
			}
		}			
			
		if (commandFound) {
			currentState.setIsDirty(false);
			currentState.setSrcDirty(false);
			currentState.setVolumeDirty(false);
			this.setCurrentState(device.getKey(),currentState);
			return audioOutputString;
		}
		else {
			return null;
		
		}
	}


	public boolean hasState (String zone) {
		return state.containsKey(zone);
	}
	
	public StateOfZone getCurrentState (String zone) {
		StateOfZone currentState = (StateOfZone)state.get(zone);
		if (currentState == null) currentState = new StateOfZone();
		return currentState;
	}

	public void setCurrentState (String zone, StateOfZone currentState) {
		state.put(zone, currentState);
	}
	
	/**
	 * @return Returns the STX.
	 */
	public char getSTX() {
		return tutondoHelper.getSTX();
	}
	/**
	 * @param stx The STX to set.
	 */
	public void setSTX(char stx) {
		tutondoHelper.setSTX(stx);
		if (pollDevice != null) pollDevice.setSTX(stx);
	}

	/**
	 * @return Returns the ETX.
	 */
	public char getETX() {
		return tutondoHelper.getETX();
	}
	/**
	 * @param stx The sTX to set.
	 */
	public void setETX(char etx) {
		tutondoHelper.setETX(etx);
		if (pollDevice != null) pollDevice.setETX(etx);
	}
	
	/**
	 * @return Returns the currentSrc for a zone
	 */
	public String getCurrentSrc(String zone) {
		return (String)currentSrc.get(zone);
	}
	/**
	 * @param currentSrc The currentSrc for the zone is set
	 */
	public void setCurrentSrc(String zone, String currentSrcStr) {
		currentSrc.put(zone, currentSrcStr);
	}
	
	public void close() throws ConnectionFail {
	    if (pollDevice != null) pollDevice.setRunning(false);
	    super.close();
	}
}
