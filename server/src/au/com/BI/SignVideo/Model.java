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
	protected HashMap <String,State>state;
	protected SignVideoHelper signVideoHelper;
	protected HashMap <String,String>avInputs;
	protected Logger logger = null;
	protected Vector <String>srcGroup;
	
	public static final String AllZones = "00";
	
	public static final int Switch = 0;
	public static final int Select = 1;
	public static final int Zone_Status_Request = 2;
	
	
	public Model () {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		signVideoHelper = new SignVideoHelper();
		setInterCommandInterval(250);
		setTransmitMessageOnBytes(1); // tutondo only sends a single non CR terminated byte.
		state = new HashMap<String,State>();
	}

	public void clearItems () {
		state.clear();
		avInputs.clear();
		super.clearItems();
	}

	
	public void initState () {
	    for(DeviceType audioDevice : configHelper.getAllOutputDeviceObjects()) {
	    	String key = audioDevice.getKey();
			if (!key.equals(Model.AllZones)) {
				state.put(key, new State());
			}
	    }	
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

						    for(byte[] avOutputString : toSend.avOutputBytes) {			
						    	sendToSerial(avOutputString,avDevice.getKey(), avDevice.getOutputKey(),toSend.outputCommandType,false);

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

		State currentState = state.get (avDevice.getKey());
		int src = Integer.parseInt(srcStr);
		
		if (power.equals("ON") && !currentState.isPower()) {
			returnCode.avOutputFlash.add((buildCommand ( avDevice, "on","")));
			currentState.setPower(true);
		}
		if (power.equals("OFF") && currentState.isPower()) {
			returnCode.avOutputFlash.add((buildCommand (avDevice, "off","")));
			currentState.setPower (false);
		}

		if (src != currentState.getSrc()){
			String newSrc = findKeyForParameterValue(srcStr, avInputs);
			returnCode.avOutputFlash.add((buildCommand ( avDevice, "src",newSrc)));
			currentState.setSrc(src);
		}

		
		return returnCode;
	}


	public CommandInterface buildCommand (DeviceType avDevice , String command, String extra){
			AVCommand videoCommand = (AVCommand)avDevice.buildDisplayCommand ();
			videoCommand.setKey ("CLIENT_SEND");
			videoCommand.setTargetDeviceID(0);
			videoCommand.setCommand (command);
			videoCommand.setExtraInfo (extra);
			return videoCommand;
	}


	
	public SignVideoCommand buildAVString (AV device, CommandInterface command){
		SignVideoCommand returnVal = new SignVideoCommand();
		String key = device.getKey();
		boolean commandFound = false;

		State currentState = state.get(key);

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
				if (key.equals(Model.AllZones)){
				    for(DeviceType avDevice : configHelper.getAllOutputDeviceObjects()) {
						if (!avDevice.getKey().equals(Model.AllZones)) {
							State stateForItem = state.get(avDevice.getKey());
							if (stateForItem != null) 
								stateForItem.setSrc(src);
							else
								logger.log (Level.WARNING,"State was not correctly set up within the SignAV system, please contact your integrator ");
							returnVal.addAvOutputString(String.format("*Z"+avDevice.getKey()+"SRC"+src));
						}
				    }	
					logger.log (Level.FINEST,"Changing video source for all zones");
				} else {
					currentState.setSrc(src);
					returnVal.addAvOutputString(String.format("*Z"+key+"SRC"+src));
					logger.log (Level.FINEST,"Changing video source");

				}
				returnVal.outputCommandType = Model.Select;
			} catch (NumberFormatException ex) {
				returnVal.addAvOutputString("");
				returnVal.error = true;
				returnVal.errorDescription = "Input src does not decode to an integer";
			}
		}			
				
		if (!commandFound &&  theCommand.equals("on")) {
			currentState.setPower(true);
			returnVal.addAvOutputString("*Z"+key+"ON");
			logger.log (Level.FINEST,"Switching on zone "+ key);
			commandFound = true;
			returnVal.outputCommandType = DeviceType.SIGN_VIDEO_SWITCH;
		}
		
		if (!commandFound && theCommand.equals("off")) {
			if (key.equals(Model.AllZones)) {
				for(State eachState : state.values()){
					eachState.setPower(false);					
				}
				returnVal.addAvOutputString("*ALLOFF");
			} else {
				currentState.setPower(false);
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
	
	public SignVideoHelper getSignVideoHelper() {
		return signVideoHelper;
	}

	public void setSignVideoHelper(SignVideoHelper signVideoHelper) {
		this.signVideoHelper = signVideoHelper;
	}
	
}
