/*
 * Created on Jan 25, 2004
 *
*/
package au.com.BI.SignVideo;

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
	

	
	protected String outputAVCommand = "";
	protected HashMap <String,String>avInputs;
	protected Logger logger = null;
	protected Vector <String>srcGroup;
	
	public static final String AllZones = "0";
	
	public static final int Switch = 0;
	public static final int Select = 1;
	public static final int Zone_Status_Request = 2;
	
	
	public Model () {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		this.setPadding(1);
		setInterCommandInterval(250);
		setTransmitMessageOnBytes(1); 
	}

	public void clearItems () {
		avInputs.clear();
		super.clearItems();
	}

	
	public void setupAVInputs() throws SetupException {
		String avInputsDef = (String)this.getParameter("AV_INPUTS",DeviceModel.MAIN_DEVICE_GROUP);
		if (avInputsDef == null || avInputsDef.equals ("")) {
			throw new SetupException ("The video source input catalogue was not specified in the device Parameter block");
		}
	
		avInputs = this.getCatalogueDef(avInputsDef);
		if (avInputs == null) {
			throw new SetupException ("The video Source input catgalogue was not specifed in the  device Parameter block");
		}
	}

	
	public void finishedReadingConfig () throws SetupException {
		super.finishedReadingConfig();
		
		setupAVInputs();
	}
	
	
	public void doStartup() throws CommsFail {
		
		synchronized (comms){
			comms.clearCommandQueue();
			try { 
		    	this.sendToSerial(new byte[]{(byte)0xA3},"","",Model.Zone_Status_Request,false);
			} catch (CommsFail e1) {
				throw new CommsFail ("Communication failed communitating with SignAV " + e1.getMessage());
			} 
		}				
	}

	
	public void doOutputItem (CommandInterface command) throws CommsFail {	
		String theWholeKey = command.getKey();
		DeviceType device  = configHelper.getOutputItem(theWholeKey);
		SignVideoCommand toSend = null;
		
		if (device == null) {
			logger.log(Level.SEVERE, "Error in config, no output key for " + theWholeKey);
		}
		else {
			cache.setCachedCommand(command.getKey(),command);
			
				switch (device.getDeviceType()) {
					case DeviceType.AV :
						AV avDevice = (AV)device;
						toSend = buildAVString (avDevice,command);
						if (toSend != null && !toSend.error) {

							logger.log(Level.FINER, "AV event for zone " + device.getKey() + " received from flash");
							byte[] theVal = new byte[1];
							
						    for(byte[] avOutputString : toSend.avOutputBytes) {		
						    	theVal[0]=avOutputString[0];
						    	sendToSerial(theVal, avDevice.getKey(), avDevice.getOutputKey(),toSend.outputCommandType,false);
							}
						    
							for (CommandInterface eachCommand: toSend.avOutputFlash){
								this.sendToFlash(eachCommand, cache);
							}

						} else {
							if (toSend != null){
								logger.log (Level.WARNING,"Error processing SignAV message " + toSend.errorDescription);
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
		SignVideoCommand commandObject = interpretStringFromSignVideo (command);
		for (CommandInterface eachCommand: commandObject.avOutputFlash){
			this.sendToFlash(eachCommand, cache);
		}
		for (String eachCommand: commandObject.avOutputStrings){
			this.sendToSerial(eachCommand);
		}
		for (byte[] eachCommand: commandObject.avOutputBytes){
			this.sendToSerial(eachCommand);
		}
	}

	
	public SignVideoCommand interpretStringFromSignVideo (CommandInterface command){
		SignVideoCommand result = new SignVideoCommand();
		boolean commandFound = false;
		
		String signAVCmd = command.getKey();
		
		try {
			String key = signAVCmd.substring(2, 4);
			
			DeviceType avDevice = configHelper.getControlledItem(key);
			
			if (avDevice == null){
				commandFound = true;
				// The zone is not configured
			}
			
			if (!commandFound && signAVCmd.contains("PWR")){
				// #ZxxPWRppp,SRCs,GRPt,VOL-yy
				result = interpretZoneStatus (signAVCmd,avDevice);			

			}
	
		} catch (IndexOutOfBoundsException ex){
			logger.log (Level.INFO,"SignAV returned an incorrectly formatted string " + signAVCmd);
		} catch ( NumberFormatException ex2) {
			logger.log (Level.INFO,"SignAV returned incorrectly formatted numbers " + signAVCmd);			
		}
	
		return result;
	}
	
	
	public SignVideoCommand  interpretZoneStatus (String zoneStatus,DeviceType avDevice) throws IndexOutOfBoundsException,NumberFormatException {
		SignVideoCommand returnCode = new SignVideoCommand();
		
		// #ZxxPWRppp,SRCs,GRPt,VOL-yy
		
		String[] bits = zoneStatus.split(",");
		
		String power =bits[0].substring(7);
		String srcStr = bits[1].substring(3);
		String grp = bits[2].substring(3);
		String volStr = bits[3].substring(4);


		String newSrc = findKeyForParameterValue(srcStr, avInputs);
		returnCode.avOutputFlash.add((buildCommand ( avDevice, "src",newSrc)));

		
		return returnCode;
	}
	
	public SignVideoCommand buildAVString (AV device, CommandInterface command){
		SignVideoCommand returnVal = new SignVideoCommand();
		String key = device.getKey();
		boolean commandFound = false;


		String rawBuiltCommand = configHelper.doRawIfPresent (command, device, this);
		if (rawBuiltCommand != null)
		{
			returnVal.addAvOutputString(rawBuiltCommand);
			commandFound = true;
		}
		String extra = command.getExtraInfo();
		String theCommand = command.getCommandCode();

		if (!commandFound && theCommand == "") {
			logger.log(Level.WARNING, "Empty command received from client "+ command.getCommandCode());
			return null;
		}

		if (!commandFound && theCommand.equals("src")) {
			String srcCode = "";
			commandFound = true;
			
			try {
				srcCode = avInputs.get(extra);
				int src = Integer.parseInt(srcCode);
				byte []pre_mode = null;
				byte []av_mode = new byte[]{(byte)0xA0};
				
				if (command.getExtra3Info().equals("AUDIO_ONLY")){
					pre_mode = new byte[]{(byte)0xA2};
					returnVal.addAvOutputBytes(pre_mode);
				}
				if (command.getExtra3Info().equals("VIDEO_ONLY")){
					pre_mode = new byte[]{(byte)0xA1};
					returnVal.addAvOutputBytes(pre_mode);
				}
				if (key.equals(Model.AllZones)){
				    for(DeviceType avDevice : configHelper.getAllOutputDeviceObjects()) {
						if (!avDevice.getKey().equals(Model.AllZones)) {
							byte[] returnLine = new byte[1];
							try {
								returnLine[0] = (byte)(Integer.parseInt(avDevice.getKey()) * 16 + src - 1);  
								returnVal.addAvOutputBytes(returnLine);
							} catch (NumberFormatException ex){
								logger.log (Level.WARNING,"An AV device key was incorrectly formatted: " + avDevice.getName());
							}
						}
				    }

					logger.log (Level.FINEST,"Changing video source for all zones");
				} else {
					byte[] returnLine = new byte[1];
					try {
						int intKey = Integer.parseInt(key);
						returnLine[0] = (byte)(intKey * 16 + src - 1);  
						returnVal.addAvOutputBytes(returnLine);
					} catch (NumberFormatException ex){
						logger.log (Level.WARNING,"An AV device key was incorrectly formatted: " + device.getName());
					}
					logger.log (Level.FINEST,"Changing video source");

				}
			    if(pre_mode != null){
			    	returnVal.addAvOutputBytes(av_mode);
			    }
				returnVal.outputCommandType = Model.Select;
			} catch (NumberFormatException ex) {
				returnVal.addAvOutputString("");
				returnVal.error = true;
				returnVal.errorDescription = "Input src does not decode to an integer";
			}
		}			
				
		if (!commandFound &&  theCommand.equals("on")) {
			returnVal.addAvOutputString("*Z"+key+"ON");
			logger.log (Level.FINEST,"Switching on zone "+ key);
			commandFound = true;
			returnVal.outputCommandType = DeviceType.SIGN_VIDEO_SWITCH;
		}
		
		if (!commandFound && theCommand.equals("off")) {
			if (key.equals(Model.AllZones)) {

				returnVal.addAvOutputString("*ALLOFF");
			} else {
				returnVal.addAvOutputString("*Z"+key+"OFF");
			}
			logger.log (Level.FINEST,"Switching off zone " + key);
			commandFound = true;
			returnVal.outputCommandType = Model.Switch;
		}

		
		if (commandFound) {
			return returnVal;
		}
		else {
			return null;
		}
	}
	
	public CommandInterface buildCommand (DeviceType avDevice , String command, String extra){
		AVCommand videoCommand = (AVCommand)avDevice.buildDisplayCommand ();
		videoCommand.setKey ("CLIENT_SEND");
		videoCommand.setTargetDeviceID(0);
		videoCommand.setCommand (command);
		videoCommand.setExtraInfo (extra);
		return videoCommand;
	}
}
