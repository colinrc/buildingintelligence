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
		configHelper.addParameterBlock ("AV_INPUTS",DeviceModel.MAIN_DEVICE_GROUP,"Video Source");
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
		BuildReturnWrapper toSend = null;
		
		if (device == null) {
			logger.log(Level.SEVERE, "Error in config, no output key for " + theWholeKey);
		}
		else {
			cache.setCachedCommand(command.getKey(),command);
			
				switch (device.getDeviceType()) {
					case DeviceType.AV :
						AV avDevice = (AV)device;
						toSend = buildAVString (avDevice,command);
						if (toSend != null && !toSend.isError()) {

							logger.log(Level.FINER, "AV event for zone " + device.getKey() + " received from flash");
							byte[] theVal = new byte[1];
							
						    for(byte[] avOutputString : toSend.getCommOutputBytes()) {		
						    	sendToSerial(avOutputString, avDevice.getKey(), avDevice.getOutputKey(),DeviceType.SIGN_VIDEO_SWITCH,false);
							}
						    
							for (CommandInterface eachCommand: toSend.getOutputFlash()){
								this.sendToFlash(eachCommand, cache);
							}

						} else {
							if (toSend != null){
								logger.log (Level.WARNING,"Error processing SignAV message " + toSend.getErrorDescription());
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
		BuildReturnWrapper commandObject = interpretBytesFromSignVideo ((CommsCommand)command);
		for (CommandInterface eachCommand: commandObject.getOutputFlash()){
			this.sendToFlash(eachCommand, cache);
		}
		for (String eachCommand: commandObject.getCommOutputStrings()){
			this.sendToSerial(eachCommand);
		}
		for (byte[] eachCommand: commandObject.getCommOutputBytes()){
			this.sendToSerial(eachCommand);
		}
	}

	
	public BuildReturnWrapper interpretBytesFromSignVideo (CommsCommand command){
		BuildReturnWrapper result = new BuildReturnWrapper();
		boolean commandFound = false;
		
		byte[] signAVCmd = command.getCommandBytes();
		
		if (!commandFound && signAVCmd[0] == (byte)0xA4){
			commandFound = true;
			// power on
		    for(DeviceType avDevice : configHelper.getAllControlledDeviceObjects()) {
				result.addFlashCommand(this.buildCommandForFlash(avDevice, "on", "","","","","",0));
			}	
		}
		
		if (!commandFound && signAVCmd[0] == (byte)0xA5){
			commandFound = true;
			// power off
		    for(DeviceType avDevice : configHelper.getAllControlledDeviceObjects()) {
				result.addFlashCommand(this.buildCommandForFlash(avDevice, "off", "","","","","",0));
			}	
		}
	
		return result;
	}
	
	
	public BuildReturnWrapper  interpretZoneStatus (String zoneStatus,DeviceType avDevice) throws IndexOutOfBoundsException,NumberFormatException {
		BuildReturnWrapper returnCode = new BuildReturnWrapper();
		
		// #ZxxPWRppp,SRCs,GRPt,VOL-yy
		
		String[] bits = zoneStatus.split(",");
		
		String power =bits[0].substring(7);
		String srcStr = bits[1].substring(3);
		String grp = bits[2].substring(3);
		String volStr = bits[3].substring(4);


		String newSrc = findKeyForParameterValue(srcStr, "AV_INPUTS",avDevice);
		
		returnCode.getOutputFlash().add(this.buildCommandForFlash(avDevice, "src",newSrc,"","","","",0));

		
		return returnCode;
	}
	
	
	public BuildReturnWrapper buildAVString (AV device, CommandInterface command){
		BuildReturnWrapper returnVal = new BuildReturnWrapper();
		String key = device.getKey();
		boolean commandFound = false;


		String rawBuiltCommand = configHelper.doRawIfPresent (command, device);
		if (rawBuiltCommand != null)
		{
			returnVal.addCommOutput(rawBuiltCommand);
			commandFound = true;
		}
		String extra = command.getExtraInfo();
		String theCommand = command.getCommandCode();

		if (!commandFound && theCommand == "") {
			logger.log(Level.WARNING, "Empty command received from client "+ command.getCommandCode());
			return null;
		}
		if (!commandFound && theCommand.equals("on")) {
			commandFound = true;
			returnVal.setOutputCommandType (DeviceType.SIGN_VIDEO_SWITCH);
			byte[] returnLine = new byte[]{(byte)0xA4};
			returnVal.addCommOutput(returnLine);
		    for(DeviceType avDevice : configHelper.getAllOutputDeviceObjects()) {
				if (!avDevice.getKey().equals(Model.AllZones)) {
					returnVal.addFlashCommand(this.buildCommandForFlash(avDevice, "on", "","","","","",0));
				}
		    }

			logger.log (Level.FINEST,"Switching all zones off");
		}
		if (!commandFound && theCommand.equals("off")) {
			commandFound = true;
			returnVal.setOutputCommandType (DeviceType.SIGN_VIDEO_SWITCH);
			byte[] returnLine = new byte[]{(byte)0xA5};
			returnVal.addCommOutput(returnLine);
		    for(DeviceType avDevice : configHelper.getAllOutputDeviceObjects()) {
				if (!avDevice.getKey().equals(Model.AllZones)) {
					returnVal.addFlashCommand(this.buildCommandForFlash(avDevice, "off", "","","","","",0));
				}
		    }

			logger.log (Level.FINEST,"Switching all zones off");
		}
		
		if (!commandFound && theCommand.equals("preset")) {
			commandFound = true;
			returnVal.setOutputCommandType (DeviceType.SIGN_VIDEO_SWITCH);
			try { 
				int presetNumber = Integer.parseInt(extra);
				byte[] returnLine = new byte[]{(byte)(0x97+presetNumber)};
				returnVal.addCommOutput(returnLine);
				returnVal.addCommOutput(new byte[]{(byte)(0xA3)});

				logger.log (Level.FINEST,"Switching preset");
			} catch (NumberFormatException ex){
				logger.log (Level.WARNING,"The preset number was incorrectly formatted");
				
			}
		}

		if (!commandFound && theCommand.equals("preset_set")) {
			commandFound = true;
			returnVal.setOutputCommandType (DeviceType.SIGN_VIDEO_SWITCH);
			try { 
				int presetNumber = Integer.parseInt(extra);
				byte[] returnLine = new byte[]{(byte)(0x8F+presetNumber)};
				returnVal.addCommOutput(returnLine);

				logger.log (Level.FINEST,"Storing preset");
			} catch (NumberFormatException ex){
				logger.log (Level.WARNING,"The preset number was incorrectly formatted");
				
			}
		}

		if (!commandFound && theCommand.equals("src")) {
			String srcCode = "";
			commandFound = true;
			
			try {
				srcCode = configHelper.getCatalogueValue(extra, "AV_INPUTS",device);
				int src = Integer.parseInt(srcCode);
				byte []pre_mode = null;
				byte []av_mode = new byte[]{(byte)0xA0};
				
				if (command.getExtra3Info().equals("AUDIO_ONLY")){
					pre_mode = new byte[]{(byte)0xA2};
					returnVal.addCommOutput(pre_mode);
				}
				if (command.getExtra3Info().equals("VIDEO_ONLY")){
					pre_mode = new byte[]{(byte)0xA1};
					returnVal.addCommOutput(pre_mode);
				}
				if (key.equals(Model.AllZones)){
				    for(DeviceType avDevice : configHelper.getAllOutputDeviceObjects()) {
						if (!avDevice.getKey().equals(Model.AllZones)) {
							byte[] returnLine = new byte[1];
							try {
								returnLine[0] = (byte)(Integer.parseInt(avDevice.getKey()) * 16 + src - 1);  
								returnVal.addCommOutput(returnLine);
								
								returnVal.addFlashCommand(this.buildCommandForFlash(avDevice, "src", extra, "", "", "", "", 0));
								
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
						returnVal.addCommOutput(returnLine);
						logger.log (Level.FINEST,"Changing video source");
					} catch (NumberFormatException ex){
						logger.log (Level.WARNING,"An AV device key was incorrectly formatted: " + device.getName());
					}
				}
			    if(pre_mode != null){
			    	returnVal.addCommOutput(av_mode);
			    }
				returnVal.setOutputCommandType (Model.Select);
			} catch (NumberFormatException ex) {
				returnVal.addCommOutput("");
				returnVal.setError (true);
				returnVal.setErrorDescription ( "Input src does not decode to an integer");
			}
		}			
		
		if (commandFound) {
			return returnVal;
		}
		else {
			return null;
		}
	}
	

}
