/*
 * Created on Jan 25, 2004
 *
*/
package au.com.BI.Kramer;

/**
 * @author Colin Canfield
 * @author Explorative Sofwtare Pty Ltd
 *
*/
import au.com.BI.AV.*;
import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Util.*;

import java.util.*;
import java.util.logging.*;


public class Model extends BaseModel implements DeviceModel {
	
	private class KramerCommands { 
		byte[] avOutputSuffix = null;
		byte[] avOutputString = null;
		byte[] avOutputParam = null;
		boolean error = false;
		String errorDescription = "";
		
		int outputCommandType;
		int paramCommandType;
	}
	
	protected String outputVideoCommand = "";
	protected HashMap state;
	protected HashMap <String,String>currentSrc;
	protected KramerHelper kramerHelper;
	
	public Model () {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		kramerHelper = new KramerHelper();
		state = new HashMap();
		currentSrc = new HashMap<String,String>();
		super.setTransmitMessageOnBytes(4); // kramer only sends a single non CR terminated byte.
		configHelper.addParameterBlock ("AUDIO_INPUTS",DeviceModel.MAIN_DEVICE_GROUP,"Audio Source");
		configHelper.addParameterBlock ("AV_INPUTS",DeviceModel.MAIN_DEVICE_GROUP,"AV Source");
	}

	public void clearItems () {
		state.clear();
		currentSrc.clear();
		super.clearItems();
	}
	
	/*
	 * @todo Write kramer startup
	 * @see au.com.BI.Util.BaseModel#doStartup()
	 */
	public void doStartup() {
		
		synchronized (comms) {
			comms.clearCommandQueue();
		
		}
		Iterator avDevices = configHelper.getAllControlledDevices();
		while (avDevices.hasNext()) {
			AV avDevice = (AV)avDevices.next();
		}

	}

	
	public void sendSrc (List commandQueue, long targetFlashDeviceID, AV audioDevice, String src) {
		AVCommand audioCommand = (AVCommand)audioDevice.buildDisplayCommand ();
		audioCommand.setKey ("CLIENT_SEND");
		audioCommand.setTargetDeviceID(targetFlashDeviceID);
		audioCommand.setCommand ("src");
		audioCommand.setExtraInfo (src);
		sendToFlash (audioCommand,cache);	
	}
	
	public void sendVolume (List commandQueue, long targetFlashDeviceID, AV audioDevice, String volume) {
		AVCommand audioCommand = (AVCommand)audioDevice.buildDisplayCommand ();
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
		KramerCommands toSend = null;
		
		if (device == null) {
			logger.log(Level.SEVERE, "Error in config, no output key for " + theWholeKey);
		}
		else {
			cache.setCachedCommand(command.getKey(),command);
			
			switch (device.getDeviceType()) {
				case DeviceType.AV :
					toSend = buildVideoString ((AV)device,command);
					if (toSend != null && !toSend.error) {

						logger.log(Level.FINER, "Video event for zone " + device.getKey() + " received from flash");

						if (toSend.avOutputParam != null) {
							CommsCommand paramCommand = new CommsCommand();
							paramCommand.setKey (device.getKey());
							paramCommand.setCommandBytes(toSend.avOutputParam);
							paramCommand.setExtraInfo (((AV)(device)).getOutputKey());
							paramCommand.setActionType(toSend.paramCommandType);
							paramCommand.setKeepForHandshake(true);
							synchronized (comms){
								try { 
									comms.addCommandToQueue (paramCommand);
								} catch (CommsFail e1) {
									throw new CommsFail ("Communication failed communitating with Kramer " + e1.getMessage());
								} 
							}
						}
		
						if (toSend.avOutputString != null) {

							CommsCommand avCommsCommand = new CommsCommand();
							avCommsCommand.setKey (device.getKey());
							avCommsCommand.setCommandBytes(toSend.avOutputString);
							avCommsCommand.setActionType(toSend.outputCommandType);
							avCommsCommand.setExtraInfo (((AV)(device)).getOutputKey());
							avCommsCommand.setKeepForHandshake(true);
							synchronized (comms){
								try { 
									comms.addCommandToQueue (avCommsCommand);
								} catch (CommsFail e1) {
									throw new CommsFail ("Communication failed communitating with Kramer " + e1.getMessage());
								} 
							}
						}
						if (toSend.avOutputSuffix != null) {
							
							CommsCommand avCommsCommand = new CommsCommand();
							avCommsCommand.setKey (device.getKey());
							avCommsCommand.setCommandBytes(toSend.avOutputSuffix);
							avCommsCommand.setActionType(toSend.outputCommandType);
							avCommsCommand.setExtraInfo (((AV)(device)).getOutputKey());
							avCommsCommand.setKeepForHandshake(true);
							synchronized (comms){
								try { 
									comms.addCommandToQueue (avCommsCommand);
								} catch (CommsFail e1) {
									throw new CommsFail ("Communication failed communitating with Kramer " + e1.getMessage());
								} 
							}
						}
					} else {
						if (toSend != null){
							logger.log (Level.WARNING,"Error processing Kramer video message " + toSend.errorDescription);
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
		comms.acknowlegeCommand("");
		comms.sendNextCommand();
	}

	
	public KramerCommands buildVideoString (AV device, CommandInterface command){
		KramerCommands returnVal = new KramerCommands();
		
		boolean commandFound = false;

		
		String rawBuiltCommand = configHelper.doRawIfPresent (command, device);
		if (rawBuiltCommand != null)
		{
			returnVal.avOutputString = rawBuiltCommand.getBytes();
			commandFound = true;
		}
		String extra = ((String)command.getExtraInfo());

		String theCommand = command.getCommandCode();
		if (!commandFound && theCommand == "") {
			logger.log(Level.WARNING, "Empty command received from client "+ command.getCommandCode());
			return null;
		}

		if (theCommand.equals("preset")) {
			try {
				int presetCode = Integer.parseInt(command.getExtraInfo());
				returnVal.avOutputString =kramerHelper.buildKramerCommand (20,presetCode,0, command.getExtra2Info()); 
				logger.log (Level.FINEST,"Changing kramer preset");
				commandFound = true;
				returnVal.outputCommandType = DeviceType.KRAMER_PRESET;
			} catch (NumberFormatException ex) {
				returnVal.avOutputString = null;
				returnVal.error = true;
				returnVal.errorDescription = "Preset value in EXTRA does not decode to an integer";
				commandFound = false;
			}
		}	
		if (theCommand.equals("src")) {
			String srcCode = "";
			try {

				if (command.getExtra3Info().equals("VIDEO_ONLY")){
					srcCode = configHelper.getCatalogueValue(extra, "AV_INPUTS",device);
					int src = Integer.parseInt(srcCode);
					setCurrentSrc(device.getKey(),srcCode);
					returnVal.avOutputParam = kramerHelper.buildKramerCommand(8,1,1,command.getExtra2Info());
					//returnVal.avOutputSuffix = kramerHelper.buildKramerCommand(8,1,0,command.getExtra2Info());
					returnVal.avOutputString =kramerHelper.buildSwitchCommand (1,device.getKey(),srcCode, command.getExtra2Info()); 
				}
				if (command.getExtra3Info().equals("AUDIO_ONLY")){
					srcCode = configHelper.getCatalogueValue(extra, "AUDIO_INPUTS",device);
					int src = Integer.parseInt(srcCode);
					setCurrentSrc(device.getKey(),srcCode);
					returnVal.avOutputParam = kramerHelper.buildKramerCommand(8,1,1,command.getExtra2Info());
					//returnVal.avOutputSuffix = kramerHelper.buildKramerCommand(8,0,0,command.getExtra2Info());
					returnVal.avOutputString =kramerHelper.buildSwitchCommand (2,device.getKey(),srcCode, command.getExtra2Info()); 
				}
				if (command.getExtra3Info().equals("AV") ||command.getExtra3Info().equals("") ){
					srcCode = configHelper.getCatalogueValue(extra, "AV_INPUTS",device);
					int src = Integer.parseInt(srcCode);
					
					String audioSrcCode = configHelper.getCatalogueValue(extra, "AUDIO_INPUTS",device);
					int audioSrc = Integer.parseInt(srcCode);
					
					setCurrentSrc(device.getKey(),srcCode);
					returnVal.avOutputString =kramerHelper.buildSwitchCommand (1,device.getKey(),srcCode, command.getExtra2Info()); 
					returnVal.avOutputSuffix =kramerHelper.buildSwitchCommand (2,device.getKey(),audioSrcCode, command.getExtra2Info());

				}
				logger.log (Level.FINEST,"Changing video source");
				commandFound = true;
				returnVal.outputCommandType = DeviceType.KRAMER_SWITCH;
			} catch (NumberFormatException ex) {
				returnVal.avOutputString = null;
				returnVal.error = true;
				returnVal.errorDescription = "Input src does not decode to an integer";
				commandFound = false;
			}
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
		return currentSrc.get(zone);
	}
	/**
	 * @param currentSrc The currentSrc for the zone is set
	 */
	public void setCurrentSrc(String zone, String currentSrcStr) {
		currentSrc.put(zone, currentSrcStr);
	}
	
}
