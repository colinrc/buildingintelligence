/*
 * Created on Jan 25, 2004
 *
*/
package au.com.BI.Nuvo;

/**
 * @author Colin Canfield
 * @author Explorative Sofwtare Pty Ltd
 *
*/
import au.com.BI.Audio.*;
import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Util.*;

import java.util.*;
import java.util.logging.*;


public class Model extends BaseModel implements DeviceModel {
	

	
	protected String outputAudioCommand = "";
	protected HashMap state;
	protected HashMap currentSrc;
	protected NuvoHelper nuvoHelper;
	protected List commandQueue;
	protected HashMap audioInputs;
	protected Logger logger = null;
	
	public Model () {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		nuvoHelper = new NuvoHelper();
		state = new HashMap();
		currentSrc = new HashMap();
		setPadding (2); // device requires 2 character keys that are 0 padded.
	}

	public void clearItems () {
		state.clear();
		currentSrc.clear();
		audioInputs.clear();
		super.clearItems();
	}

	
	public void finishedReadingConfig () throws SetupException {
		super.finishedReadingConfig();
		
		String audioInputsDef = (String)this.getParameter("AUDIO_INPUTS",DeviceModel.MAIN_DEVICE_GROUP);
		if (audioInputsDef == null || audioInputsDef.equals ("")) {
			throw new SetupException ("The audio source input catalogue was not specified in the device Parameter block");
		}

		audioInputs = (HashMap)this.getCatalogueDef(audioInputsDef);
		if (audioInputs == null) {
			throw new SetupException ("The audio Source input catgalogue was not specifed in the  device Parameter block");
		}
	}
	
	
	public void doStartup(List commandQueue) {
		
		synchronized (comms) {
			comms.clearCommandQueue();
		
			this.commandQueue = commandQueue;
		
		}
		Iterator avDevices = configHelper.getAllControlledDevices();
		while (avDevices.hasNext()) {
			Audio avDevice = (Audio)avDevices.next();
		}

	}
		
	public void doClientStartup (List commandQueue, long targetFlashDeviceID) {
		Iterator audioDevices = configHelper.getAllControlledDevices();
		while (audioDevices.hasNext()){
			Audio audioDevice =(Audio)(audioDevices.next());
			doClientStartup (commandQueue, targetFlashDeviceID, audioDevice);
			
		}
	}

	public void doClientStartup (List commandQueue, long targetFlashDeviceID, Audio audioDevice) {
	}

	
	public void sendSrc (List commandQueue, long targetFlashDeviceID, Audio audioDevice, String src) {
		AudioCommand audioCommand = (AudioCommand)audioDevice.buildDisplayCommand ();
		audioCommand.setKey ("CLIENT_SEND");
		audioCommand.setTargetDeviceID(targetFlashDeviceID);
		audioCommand.setCommand ("src");
		audioCommand.setExtraInfo (src);
		sendToFlash (audioCommand,cache,commandQueue);	
	}
	
	public void sendVolume (List commandQueue, long targetFlashDeviceID, Audio audioDevice, String volume) {
		AudioCommand audioCommand = (AudioCommand)audioDevice.buildDisplayCommand ();
		audioCommand.setKey ("CLIENT_SEND");
		audioCommand.setTargetDeviceID(targetFlashDeviceID);
		audioCommand.setCommand ("volume");
		audioCommand.setExtraInfo (volume);
		sendToFlash (audioCommand,cache,commandQueue);	
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
		ArrayList deviceList = (ArrayList)configHelper.getOutputItem(theWholeKey);
		NuvoCommands toSend = null;
		
		if (deviceList == null) {
			logger.log(Level.SEVERE, "Error in config, no output key for " + theWholeKey);
		}
		else {
			Iterator devices = deviceList.iterator();
			cache.setCachedCommand(command.getKey(),command);
			
			while (devices.hasNext()) {
				DeviceType device = (DeviceType)devices.next();

				
				switch (device.getDeviceType()) {
					case DeviceType.AUDIO :
						toSend = buildAudioString ((Audio)device,command);
						if (toSend != null && !toSend.error) {

							logger.log(Level.FINER, "Audio event for zone " + device.getKey() + " received from flash");

			
							if (toSend.avOutputString != null) {
	
								CommsCommand avCommsCommand = new CommsCommand();
								avCommsCommand.setKey (device.getKey());
								avCommsCommand.setCommand(toSend.avOutputString);
								avCommsCommand.setActionType(toSend.outputCommandType);
								avCommsCommand.setExtraInfo (((Audio)(device)).getOutputKey());
								avCommsCommand.setKeepForHandshake(true);
								synchronized (comms){
									try { 
										comms.addCommandToQueue (avCommsCommand);
									} catch (CommsFail e1) {
										throw new CommsFail ("Communication failed communitating with Nuvo " + e1.getMessage());
									} 
								}
							}

						} else {
							if (toSend != null){
								logger.log (Level.WARNING,"Error processing Nuvo video message " + toSend.errorDescription);
							}
						}
				

						break;						
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
		comms.acknowlegeCommand("");
		comms.sendNextCommand();
	}

	public void sendToFlash (CommandInterface command, Cache cache ,List commandQueue) {
		cache.setCachedCommand(command.getDisplayName(),command);
		synchronized (commandQueue){
			commandQueue.add(command);
		}
	}

	
	public String findAVSrc(String srcCode) {
		String returnVal = "1";
		Iterator inputItems = audioInputs.keySet().iterator();
		int srcVal = Integer.parseInt(srcCode); 
		while (inputItems.hasNext()) {
			String inputKey = (String)inputItems.next();
			int programVal = Integer.parseInt((String)audioInputs.get(inputKey));
			if (programVal == srcVal) {
				returnVal = inputKey;
			}
		}
		return returnVal;
	}
	
	public NuvoCommands buildAudioString (Audio device, CommandInterface command){
		NuvoCommands returnVal = new NuvoCommands();
		
		boolean commandFound = false;

		
		String rawBuiltCommand = configHelper.doRawIfPresent (command, device, this);
		if (rawBuiltCommand != null)
		{
			returnVal.avOutputString = rawBuiltCommand;
			commandFound = true;
		}
		String extra = ((String)command.getExtraInfo());

		String theCommand = command.getCommandCode();
		if (!commandFound && theCommand == "") {
			logger.log(Level.WARNING, "Empty command received from client "+ command.getCommandCode());
			return null;
		}

		if (theCommand.equals("src")) {
			// @ TODO Complete src
			String srcCode = "";
			try {


				srcCode = (String)audioInputs.get(command.getExtraInfo());
				int src = Integer.parseInt(srcCode);
				setCurrentSrc(device.getKey(),srcCode);
				returnVal.avOutputString =nuvoHelper.buildSwitchCommand (2,device.getKey(),srcCode, command.getExtra2Info()); 
				logger.log (Level.FINEST,"Changing audio source");
				commandFound = true;
				returnVal.outputCommandType = DeviceType.NUVO_SWITCH;
			} catch (NumberFormatException ex) {
				returnVal.avOutputString = null;
				returnVal.error = true;
				returnVal.errorDescription = "Input src does not decode to an integer";
				commandFound = false;
			}
		}			
		if (theCommand.equals("vol")) {
			// @ TODO Complete volume
			String srcCode = "";
			try {


				srcCode = (String)audioInputs.get(command.getExtraInfo());
				int src = Integer.parseInt(srcCode);
				setCurrentSrc(device.getKey(),srcCode);
				returnVal.avOutputString =nuvoHelper.buildSwitchCommand (2,device.getKey(),srcCode, command.getExtra2Info()); 
				logger.log (Level.FINEST,"Changing audio source");
				commandFound = true;
				returnVal.outputCommandType = DeviceType.NUVO_SWITCH;
			} catch (NumberFormatException ex) {
				returnVal.avOutputString = null;
				returnVal.error = true;
				returnVal.errorDescription = "Input src does not decode to an integer";
				commandFound = false;
			}
		}	
		if (theCommand.equals("on")) {
			String key = device.getKey();
			returnVal.avOutputString = "*Z"+key+"ON";
			logger.log (Level.FINEST,"Switching on zone "+ key);
			commandFound = true;
			returnVal.outputCommandType = DeviceType.NUVO_SWITCH;

		}
		if (theCommand.equals("off")) {
			String key = device.getKey();
			returnVal.avOutputString = "*Z"+key+"OFF";
			logger.log (Level.FINEST,"Switching off zone " + key);
			commandFound = true;
			returnVal.outputCommandType = DeviceType.NUVO_SWITCH;

		}
		if (commandFound) {
			return returnVal;
		}
		else {
			return null;
		
		}
	}


	public boolean hasState (String zone) {
		return state.containsKey(zone);
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
	
}
