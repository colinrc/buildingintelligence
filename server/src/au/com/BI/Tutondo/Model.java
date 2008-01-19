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
import au.com.BI.Config.ParameterException;
import au.com.BI.Device.DeviceType;
import au.com.BI.Util.*;

import java.util.*;
import java.util.logging.*;

import au.com.BI.Audio.*;

public class Model extends SimplifiedModel implements DeviceModel {
	
	protected String outputAudioCommand = "";
	protected HashMap <String,StateOfZone>state;
	protected HashMap <String,String>currentSrc;
	protected TutondoHelper tutondoHelper;
	protected PollDevice pollDevice;
	protected CommandQueue commandQueue;
	protected boolean protocolB;
	
	public Model () {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		tutondoHelper = new TutondoHelper();
		pollDevice = null;
		protocolB = true;
		configHelper.addParameterBlock ("INPUTS",DeviceModel.MAIN_DEVICE_GROUP,"Source inputs");
		configHelper.addParameterBlock ("FUNCTIONS",DeviceModel.MAIN_DEVICE_GROUP,"Audio functions");
		state = new HashMap<String,StateOfZone>(12); // zones
		currentSrc = new HashMap<String,String>(40); // maximum tutondo zones		
	}

	public void clearItems () {
		state.clear();
		currentSrc.clear();
		super.clearItems();
	}
	
	public void finishedReadingConfig () throws SetupException {
		super.finishedReadingConfig();
		protocolB = false;
		String protocol = (String)this.getParameterValue("PROTOCOL", DeviceModel.MAIN_DEVICE_GROUP);
		if (protocol != null && protocol.equals("B")) {
				protocolB = true;
		}

	}
	
	public void prepareToAttatchComms() {
		state.clear();
		currentSrc.clear();
	}
	
	public void attatchComms() 
	throws ConnectionFail {
	    if (!protocolB) { 
			setTransmitMessageOnBytes(1); // tutondo A only sends a single non CR terminated byte.
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
		for (DeviceType audioDevice: configHelper.getAllControlledDeviceObjects()){
			try {
				pollDevice.addAudioDevice((Audio)audioDevice);
			} catch (ClassCastException ex){
				logger.log(Level.WARNING,"A non-audio device was added to the Tutondo model " + audioDevice.getName());
			}
		}
			
		if (!protocolB) {
			pollDevice.setSTX(tutondoHelper.getSTX());
			pollDevice.setETX(tutondoHelper.getETX());
		}
		String pollValueStr = (String)this.getParameterValue("POLL_INTERVAL",DeviceModel.MAIN_DEVICE_GROUP);
		long pollValue = 3000;
		if (pollValueStr != null && !pollValueStr.equals( (""))){
			try {
				pollValue = Long.parseLong(pollValueStr) * 1000;
			} catch (NumberFormatException ex) {
				pollValue = 3000;
			}
		}
		if (pollValue == 0) pollValue = 1000; // 1 seconds minimum to make sure we don't flood tutondo. 
		pollDevice.setPollValue(pollValue);
		logger.log (Level.FINE,"Starting tutondo polling, interval = " + pollValueStr);
		pollDevice.start();
		
	}
	
	
	public void updateClient(Audio device,StateOfZone currentState) {
		sendStatus (currentState, commandQueue, -1, device);
	}
	
	public void updateClientVolume(Audio device,StateOfZone currentState) {
		sendVolume (commandQueue, -1, device, currentState.getVolume());	
	}
	
	public void updateClientSrc(Audio device,StateOfZone currentState) {
		sendSrc (commandQueue, -1, device, currentState.getSrc());	
	}
	
	public void doClientStartup (CommandQueue commandQueue, long targetFlashDeviceID) {
		for (DeviceType audioDevice: configHelper.getAllControlledDeviceObjects()){
			try {
				doClientStartup (commandQueue, targetFlashDeviceID, (Audio)audioDevice);
			} catch (ClassCastException ex){
				logger.log(Level.WARNING,"A non-audio device was added to the Tutondo model " + audioDevice.getName());
			}
			
		}
	}

	public void doClientStartup (CommandQueue commandQueue, long targetFlashDeviceID, Audio audioDevice) {
		if (this.hasState (audioDevice.getKey())) {
	
			StateOfZone currentState = this.getCurrentState(audioDevice.getKey());
			sendStatus (currentState, commandQueue,  targetFlashDeviceID,  audioDevice);
			sendSrc ( commandQueue,  targetFlashDeviceID,  audioDevice, currentState.getSrc());
		}
	}

	public void sendStatus (StateOfZone currentState, CommandQueue commandQueue, long targetFlashDeviceID, Audio audioDevice) {
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
	
	public void sendSrc (CommandQueue commandQueue, long targetFlashDeviceID, Audio audioDevice, String src) {
		AudioCommand audioCommand = (AudioCommand)audioDevice.buildDisplayCommand ();
		audioCommand.setKey ("CLIENT_SEND");
		audioCommand.setTargetDeviceID(targetFlashDeviceID);
		audioCommand.setCommand ("src");
		audioCommand.setExtraInfo (src);
		sendToFlash (audioCommand,cache);	
	}
	
	public void sendVolume (CommandQueue commandQueue, long targetFlashDeviceID, Audio audioDevice, String volume) {
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
				configHelper.setLastCommandType (MessageDirection.FROM_HARDWARE);
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
							logger.log(Level.FINER, "Message from flash generated audio command " + outputAudioCommand + " for zone " + device.getKey());
							comms.sendString(outputAudioCommand);
						} else {
							logger.log(Level.FINER, "Message from flash generated audio command for zone " + device.getKey());
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
		Audio audioDevice = null;
		
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
					audioDevice = (Audio)configHelper.getControlledItem(zone);
					if (audioDevice == null) return;
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
				audioDevice = (Audio)configHelper.getControlledItem(zone);
				if (audioDevice == null) return;
			}

			StateOfZone currentState;
			
			if (this.hasState(zone)) 
				currentState = this.getCurrentState(zone);
			else
				currentState = new StateOfZone();
			
			if (lastActionType == CommDevice.TutondoState ) {
				comms.acknowledgeCommand(CommDevice.TutondoState,zone, true);
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
				comms.acknowledgeCommand(CommDevice.TutondoVolume,zone,true);
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
				comms.acknowledgeCommand(CommDevice.TutondoPrograms,zone, true);
				comms.gotFeedback();
				if (!protocolB) comms.sendNextCommand();
				logger.log(Level.FINEST,"Received feedback for tutondo src");
				commandMatched = true;
				String srcCode = String.valueOf(tutondoCode);
				this.setCurrentSrc(zone,srcCode);
				currentState.setSrcCode(srcCode);
				String src;
				try {
					src = findKeyForParameterValue(srcCode, "INPUTS",audioDevice);
					currentState.setSrc(src);
					this.setCurrentState(zone, currentState);
				} catch (NumberFormatException e) {
					logger.log (Level.WARNING,"An incorrect response was received from the Tutondo for the source");
				} catch (ParameterException e) {
					logger.log (Level.WARNING,"An input was selected from Tutondo that was not configured.");
				} 

			}
			
			if (!commandMatched && !protocolB){
				comms.acknowledgeCommand("", true);
				comms.gotFeedback();
				comms.sendNextCommand();
			}
			if (currentState.getIsDirty()) {
				currentState.setIsDirty(false);
				logger.log (Level.FINER,"Updating Tutondo information for zone " + zone);
				updateClient (audioDevice,currentState);
			}
			if (currentState.isVolumeDirty()) {
				currentState.setVolumeDirty(false);
				logger.log (Level.FINER,"Updating Tutondo volume for zone " + zone);
				updateClientVolume (audioDevice,currentState);
			}
			if (currentState.isSrcDirty()) {
				currentState.setSrcDirty(false);
				logger.log (Level.FINER,"Updating Tutondo src information for zone " + zone);
				updateClientSrc (audioDevice,currentState);
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

	
	public byte[] buildAudioString (Audio device, CommandInterface command){
		byte[] audioOutputString = null;
		boolean commandFound = false;
		
		StateOfZone currentState;
		
		if (this.hasState(device.getKey())) 
			currentState = this.getCurrentState(device.getKey());
		else
			currentState = new StateOfZone();
		
		String rawBuiltCommand = doRawIfPresent (command, device);
		if (rawBuiltCommand != null)
		{
			audioOutputString = rawBuiltCommand.getBytes();
			commandFound = true;
		}
		String extra = ((String)command.getExtraInfo());
		int scaledVal = -1;
		try {
			double val = Double.parseDouble(extra);
			//if (val >= 0.0 && val <= 48.0) {
				scaledVal = (new Double(val / 100.0 * 48.0)).intValue();
			//}
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
					audioOutputString =tutondoHelper.buildTutondoCommand (15, scaledVal, device.getKey(),protocolB); 
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
			String functionStr;
			try {
				functionStr = getCatalogueValue(command.getExtraInfo(), "FUNCTIONS",device);
				String commandSrc = command.getExtra2Info();
				if (commandSrc != null && !commandSrc.equals("")){
					try {
						commandSrc = getCatalogueValue(command.getExtraInfo(), "INPUTS",device);
					} catch (ParameterException e) {
						logger.log (Level.WARNING,e.getMessage());
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
			} catch (ParameterException e1) {
				logger.log(Level.WARNING,"A command " +  (String)command.getExtraInfo() + " was sent to the tutondo which is not configured in the server catalogue");
				commandFound = false;
			}
		}
		if (theCommand.equals("src")) {

			try {
				String srcCode = getCatalogueValue(command.getExtraInfo(), "INPUTS",device);
				int src = Integer.parseInt(srcCode);
				setCurrentSrc(device.getKey(),srcCode);
				currentState.setSrc(srcCode);
				audioOutputString = tutondoHelper.buildTutondoCommand (19, src, device.getKey(),protocolB);
				logger.log (Level.FINEST,"Changing audio source");
				commandFound = true;
			} catch (NumberFormatException ex) {
				audioOutputString = null;
				commandFound = false;
			} catch (ParameterException ex){
				logger.log (Level.WARNING,ex.getMessage());
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
