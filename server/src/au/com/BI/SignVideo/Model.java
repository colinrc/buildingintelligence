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
import au.com.BI.Audio.*;
import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Util.*;

import java.util.*;
import java.util.logging.*;



public class Model extends BaseModel implements DeviceModel {
	

	
	protected String outputAudioCommand = "";
	protected HashMap <String,State>state;
	protected SignVideoHelper signVideoHelper;
	protected List commandQueue;
	protected HashMap audioInputs;
	protected Logger logger = null;
	protected Vector <String>srcGroup;
	
	public static final String AllZones = "00";
	
	public static final int Switch = 0;
	public static final int Select = 1;
	public static final int Tone = 2;
	public static final int Volume = 3;
	public static final int Mute = 4;	
	public static final int Zone_Status_Request = 5;
	public static final int Zone_Tone_Request = 6;
	
	
	public Model () {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		signVideoHelper = new SignVideoHelper();
		state = new HashMap<String,State>();
		setPadding (2); // device requires 2 character keys that are 0 padded.
		srcGroup = new Vector<String>();
	}

	public void clearItems () {
		state.clear();
		audioInputs.clear();
		super.clearItems();
	}

	public void setupAudioInputs() throws SetupException {
		String audioInputsDef = (String)this.getParameter("AUDIO_INPUTS",DeviceModel.MAIN_DEVICE_GROUP);
		if (audioInputsDef == null || audioInputsDef.equals ("")) {
			throw new SetupException ("The audio source input catalogue was not specified in the device Parameter block");
		}
	
		audioInputs = (HashMap)this.getCatalogueDef(audioInputsDef);
		if (audioInputs == null) {
			throw new SetupException ("The audio Source input catgalogue was not specifed in the  device Parameter block");
		}
	}

	
	public void finishedReadingConfig () throws SetupException {
		super.finishedReadingConfig();
		
		setupAudioInputs();
		initState();
	}
	
	public void initState () {
	    for(DeviceType audioDevice : configHelper.getAllOutputDeviceObjects()) {
	    	String key = audioDevice.getKey();
			if (!key.equals(Model.AllZones)) {
				state.put(key, new State());
			}
	    }	
	}
	
	public void attatchComms(List commandList) throws ConnectionFail {
		setInterCommandInterval(50);
		super.attatchComms(commandList);
		}
	
	
	public void doStartup(List commandQueue) throws CommsFail {
		
		synchronized (comms) {
			comms.clearCommandQueue();
			this.commandQueue = commandQueue;
		}
		
	    for(DeviceType audioDevice : configHelper.getAllOutputDeviceObjects()) {
	    	String key = audioDevice.getKey();
			if (!key.equals(Model.AllZones)) {

				String toneRequest = "*Z"+ audioDevice.getKey()+ "SETSR\n";
				
				CommsCommand avCommsCommand2 = new CommsCommand();
				avCommsCommand2.setKey (key);
				avCommsCommand2.setCommand(toneRequest);
				avCommsCommand2.setActionType(Model.Zone_Tone_Request);
				avCommsCommand2.setExtraInfo (((Audio)(audioDevice)).getOutputKey());
				avCommsCommand2.setKeepForHandshake(false);
				synchronized (comms){
					try { 
						comms.addCommandToQueue (avCommsCommand2);
					} catch (CommsFail e1) {
						throw new CommsFail ("Communication failed communitating with SignVideo " + e1.getMessage());
					} 
				}
				
			}
	    }
	    
	    for(DeviceType audioDevice : configHelper.getAllOutputDeviceObjects()) {
	    	String key = audioDevice.getKey();
			if (!key.equals(Model.AllZones)) {
				String zoneRequest = "*Z"+ audioDevice.getKey()+ "CONSR\n";
				
				CommsCommand avCommsCommand = new CommsCommand();
				avCommsCommand.setKey (key);
				avCommsCommand.setCommand(zoneRequest);
				avCommsCommand.setActionType(Model.Zone_Status_Request);
				avCommsCommand.setExtraInfo (((Audio)(audioDevice)).getOutputKey());
				avCommsCommand.setKeepForHandshake(false);
				synchronized (comms){
					try { 
						comms.addCommandToQueue (avCommsCommand);
					} catch (CommsFail e1) {
						throw new CommsFail ("Communication failed communitating with SignVideo " + e1.getMessage());
					} 
				}				
			}
	    }
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
		DeviceType device  = configHelper.getOutputItem(theWholeKey);
		SignVideoCommands toSend = null;
		
		if (device == null) {
			logger.log(Level.SEVERE, "Error in config, no output key for " + theWholeKey);
		}
		else {
			cache.setCachedCommand(command.getKey(),command);
			
				switch (device.getDeviceType()) {
					case DeviceType.AUDIO :
						Audio audioDevice = (Audio)device;
						toSend = buildAudioString (audioDevice,command);
						if (toSend != null && !toSend.error) {

							logger.log(Level.FINER, "Audio event for zone " + device.getKey() + " received from flash");

						    for(String avOutputString : toSend.avOutputStrings) {			
						    	this.sendToSerial(avOutputString,audioDevice, audioDevice.getOutputKey(),toSend.outputCommandType);

							}
						    
							for (CommandInterface eachCommand: toSend.avOutputFlash){
								this.sendToFlash(eachCommand, cache, commandQueue);
							}

						} else {
							if (toSend != null){
								logger.log (Level.WARNING,"Error processing SignVideo message " + toSend.errorDescription);
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
		SignVideoCommands commandObject = interpretStringFromSignVideo (command);
		for (CommandInterface eachCommand: commandObject.avOutputFlash){
			this.sendToFlash(eachCommand, cache, commandQueue);
		}
		for (String eachCommand: commandObject.avOutputStrings){
			this.sendToSerial(eachCommand+"\n");
		}
	}

	public void sendToSerial (String avOutputString,Audio device, String outputKey, int outputCommandType) throws CommsFail{
		CommsCommand avCommsCommand = new CommsCommand();
		avCommsCommand.setKey (device.getKey());
		avCommsCommand.setCommand(avOutputString+"\n");
		avCommsCommand.setActionType(outputCommandType);
		avCommsCommand.setExtraInfo (((Audio)(device)).getOutputKey());
		avCommsCommand.setKeepForHandshake(false);
		synchronized (comms){
			try { 
				comms.addCommandToQueue (avCommsCommand);
			} catch (CommsFail e1) {
				throw new CommsFail ("Communication failed communitating with SignVideo " + e1.getMessage());
			} 
		}
	}
	
	public SignVideoCommands interpretStringFromSignVideo (CommandInterface command){
		SignVideoCommands result = new SignVideoCommands();
		boolean commandFound = false;
		
		String signVideoCmd = command.getKey();
		
		try {
			String key = signVideoCmd.substring(2, 4);
			
			DeviceType audioDevice = configHelper.getControlledItem(key);
			
			if (audioDevice == null){
				commandFound = true;
				// The zone is not configured
			}
			
			if (!commandFound && signVideoCmd.contains("PWR")){
				// #ZxxPWRppp,SRCs,GRPt,VOL-yy
				result = interpretZoneStatus (signVideoCmd,audioDevice);			

			}
			if (!commandFound && signVideoCmd.contains("BASS")){
				// #ZxxORp,BASSyy,TREByy,GRPq,VRSTr
				result = interpretZoneSetStatus (signVideoCmd,audioDevice);			
			}
	
		} catch (IndexOutOfBoundsException ex){
			logger.log (Level.INFO,"SignVideo returned an incorrectly formatted string " + signVideoCmd);
		} catch ( NumberFormatException ex2) {
			logger.log (Level.INFO,"SignVideo returned incorrectly formatted numbers " + signVideoCmd);			
		}
	
		return result;
	}
	
	public void addToGroup (String newKey){
		srcGroup.add(newKey);
		for (String eachkey: srcGroup){
			State stateOfGroupItem = state.get(eachkey);
			if (stateOfGroupItem != null){
				stateOfGroupItem.setSrc(0); 
				// Ensure the entire group has state nulled, so that any new source selection will be sent to the new group member
			} else {
				logger.log (Level.WARNING,"State was not recorded correctly for zone " + eachkey);
			}
		}
	}

	public void removeFromGroup (String newKey){
		srcGroup.remove(newKey);
	}


	public boolean isInGroup (String testKey){
		boolean returnCode = false;
		return returnCode;
	}
	
	public SignVideoCommands  interpretZoneStatus (String zoneStatus,DeviceType audioDevice) throws IndexOutOfBoundsException,NumberFormatException {
		SignVideoCommands returnCode = new SignVideoCommands();
		
		// #ZxxPWRppp,SRCs,GRPt,VOL-yy
		
		String[] bits = zoneStatus.split(",");
		
		String power =bits[0].substring(7);
		String srcStr = bits[1].substring(3);
		String grp = bits[2].substring(3);
		String volStr = bits[3].substring(4);

		State currentState = state.get (audioDevice.getKey());
		int src = Integer.parseInt(srcStr);
		
		if (power.equals("ON") && !currentState.isPower()) {
			returnCode.avOutputFlash.add((buildCommand ( audioDevice, "on","")));
			currentState.setPower(true);
		}
		if (power.equals("OFF") && currentState.isPower()) {
			returnCode.avOutputFlash.add((buildCommand (audioDevice, "off","")));
			currentState.setPower (false);
		}

		if (grp.equals("1") && !currentState.isGroup_on()) {
			returnCode.avOutputFlash.add((buildCommand ( audioDevice, "group","on")));
			addToGroup (audioDevice.getKey());
			currentState.setGroup_on(true);
		}
		if (power.equals("0") && currentState.isGroup_on()) {
			returnCode.avOutputFlash.add((buildCommand (audioDevice, "group","off")));
			removeFromGroup (audioDevice.getKey());
			currentState.setGroup_on(false);
		}

		if (src != currentState.getSrc()){
			String newSrc = this.findAVSrc(srcStr);
			returnCode.avOutputFlash.add((buildCommand ( audioDevice, "src",newSrc)));
			currentState.setSrc(src);
			if (currentState.group_on)setGroupKeys ( audioDevice, srcStr,  src,  returnCode);
		}
		
		if (volStr.equals ("MT")){
			returnCode.avOutputFlash.add((buildCommand ( audioDevice, "mute","on")));
			currentState.setMute(true);
			if (currentState.isExt_mute()){
				currentState.setExt_mute(false);
				returnCode.avOutputFlash.add((buildCommand ( audioDevice, "ext-mute","off")));					
			}
		} else {
			if (volStr.equals ("XM")){
				returnCode.avOutputFlash.add((buildCommand ( audioDevice, "ext-mute","on")));
				currentState.setExt_mute(true);
				if (currentState.isMute()){
					currentState.setMute(false);
					returnCode.avOutputFlash.add((buildCommand ( audioDevice, "mute","off")));					
				}
			} else {
				if (currentState.isMute()){
					currentState.setMute(false);
					returnCode.avOutputFlash.add((buildCommand ( audioDevice, "mute","off")));					
				}
				if (currentState.isExt_mute()){
					currentState.setExt_mute(false);
					returnCode.avOutputFlash.add((buildCommand ( audioDevice, "ext-mute","off")));					
				}
				if (!currentState.testVolume(volStr)){
					int volForFlash = Utility.scaleForFlash(volStr, 0, 79, true);
					String volForFlashStr = String.valueOf(volForFlash);
					currentState.setVolume (String.valueOf(volForFlashStr));
					returnCode.avOutputFlash.add((buildCommand ( audioDevice, "volume",volForFlashStr)));					
				}				
			}
			
		}

		
		return returnCode;
	}

	public SignVideoCommands  interpretZoneSetStatus (String zoneStatus,DeviceType audioDevice) throws IndexOutOfBoundsException,NumberFormatException {
		SignVideoCommands returnCode = new SignVideoCommands();
		
		// #ZxxORp,BASSyy,TREByy,GRPq,VRSTr
		
		String[] bits = zoneStatus.split(",");
	
		String bass = bits[1].substring(5);
		String treble = bits[2].substring(5);

		int trebForFlash = Utility.scaleForFlash(treble, 0, 8, true);
		String trebForFlashStr = String.valueOf(trebForFlash);
		returnCode.avOutputFlash.add((buildCommand ( audioDevice, "treble",trebForFlashStr)));					
		
		int bassForFlash = Utility.scaleForFlash(bass, 0, 8, true);
		String bassForFlashStr = String.valueOf(bassForFlash);
		returnCode.avOutputFlash.add((buildCommand ( audioDevice, "bass",bassForFlashStr)));
		
		return returnCode;
	}

	public CommandInterface buildCommand (DeviceType audioDevice , String command, String extra){
			AudioCommand audioCommand = (AudioCommand)audioDevice.buildDisplayCommand ();
			audioCommand.setKey ("CLIENT_SEND");
			audioCommand.setTargetDeviceID(0);
			audioCommand.setCommand (command);
			audioCommand.setExtraInfo (extra);
			return audioCommand;
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
	
	public SignVideoCommands buildAudioString (Audio device, CommandInterface command){
		SignVideoCommands returnVal = new SignVideoCommands();
		String key = device.getKey();
		boolean commandFound = false;

		State currentState = state.get(key);

		String rawBuiltCommand = configHelper.doRawIfPresent (command, device, this);
		if (rawBuiltCommand != null)
		{
			returnVal.addAvOutputString(rawBuiltCommand);
			commandFound = true;
		}
		String extra = ((String)command.getExtraInfo());

		String theCommand = command.getCommandCode();
		if (!commandFound && theCommand == "") {
			logger.log(Level.WARNING, "Empty command received from client "+ command.getCommandCode());
			return null;
		}

		if (!commandFound && theCommand.equals("src")) {
			String srcCode = "";
			commandFound = true;
			
			try {
				srcCode = (String)audioInputs.get(extra);
				int src = Integer.parseInt(srcCode);
				if (key.equals(Model.AllZones)){
				    for(DeviceType audioDevice : configHelper.getAllOutputDeviceObjects()) {
						if (!audioDevice.getKey().equals(Model.AllZones)) {
							State stateForItem = state.get(audioDevice.getKey());
							if (stateForItem != null) 
								stateForItem.setSrc(src);
							else
								logger.log (Level.WARNING,"State was not correctly set up within the SignVideo system, please contact your integrator ");
							returnVal.addAvOutputString(String.format("*Z"+audioDevice.getKey()+"SRC"+src));
						}
				    }	
					logger.log (Level.FINEST,"Changing audio source for all zones");
				} else {
					currentState.setSrc(src);
					returnVal.addAvOutputString(String.format("*Z"+key+"SRC"+src));
					logger.log (Level.FINEST,"Changing audio source");
					if (currentState.isGroup_on()){
						setGroupKeys (device,extra,src,returnVal);
					}
				}
				returnVal.outputCommandType = Model.Select;
			} catch (NumberFormatException ex) {
				returnVal.addAvOutputString("");
				returnVal.error = true;
				returnVal.errorDescription = "Input src does not decode to an integer";
			}
		}			
		
		if (!commandFound && theCommand.equals("group")) {
			commandFound = true;
			if (extra.equals ("on")){
				currentState.setGroup_on(true);
				this.addToGroup(key);
				logger.log (Level.FINE,"Zone " + key + " added to the source group");	
			}  else {
				currentState.setGroup_on(false);
				this.removeFromGroup(key);
				logger.log (Level.FINE,"Zone " + key + " removed from the source group");	
			}
		}
			
		if (!commandFound && theCommand.equals("volume")) {

			if (!commandFound && extra.equals ("up")){
				commandFound = true;
				if (!key.equals (Model.AllZones)){
					currentState.setVolume("");
					returnVal.addAvOutputString(String.format("*Z"+key+"VOL+"));
					logger.log (Level.FINEST,"Volump ramp up in zone " + key);					
				} else {

					returnVal.addAvOutputString("*ZALLV+");
					for(State eachState : state.values()){
						eachState.setVolume("");					
					}
					logger.log (Level.FINEST,"All volume ramp up");	
				}
			}

			if (!commandFound && extra.equals ("down")){
				commandFound = true;
				if (!key.equals (Model.AllZones)){
					for(State eachState : state.values()){
						eachState.setVolume("");					
					}
					returnVal.addAvOutputString(String.format("*Z"+key+"VOL-"));
					logger.log (Level.FINEST,"Volump ramp down in zone " + key);					
				} else {
					currentState.setVolume("");
					returnVal.addAvOutputString("*ZALLV-");
					logger.log (Level.FINEST,"All volume ramp down");	
				}
			}
			
			if (!commandFound && extra.equals ("stop")){
				commandFound = true;
				if (key.equals (Model.AllZones)){
					returnVal.addAvOutputString(String.format("*ZALLHLD"));
					logger.log (Level.FINEST,"Volump ramp stop in all zones");					
				} else {
					returnVal.addAvOutputString("*Z"+key+"VHLD");
					logger.log (Level.FINEST,"All volume ramp stop in zone " + key);	
				}
			}
			if (!commandFound){
				try {
					int newVal = Utility.scaleFromFlash(extra,0,78,true);
					String volString = String.format("%02d",newVal);
					currentState.setVolume(volString);
					returnVal.addAvOutputString("*Z"+key+"VOL"+volString);
					commandFound = true;
					logger.log (Level.FINEST,"Changing tone in zone " + key);
				} catch (NumberFormatException ex){
					logger.log (Level.WARNING,"Illegal value for tone change " + ex.getMessage());				
				}
			}
			commandFound = true;
			returnVal.outputCommandType = Model.Tone;
		}	
		
		if (!commandFound &&  theCommand.equals("on")) {
			currentState.setPower(true);
			returnVal.addAvOutputString("*Z"+key+"ON");
			logger.log (Level.FINEST,"Switching on zone "+ key);
			commandFound = true;
			returnVal.outputCommandType = DeviceType.NUVO_SWITCH;
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

		if (!commandFound && theCommand.equals("mute")) {
			if (command.getExtraInfo().equals ("on")){
				if (key.equals(Model.AllZones)) {
					for(State eachState : state.values()){
						eachState.setMute(true);			
					}
					returnVal.addAvOutputString("*ALLMON");
				} else {
					currentState.setMute(true);
					returnVal.addAvOutputString("*Z"+key+"MTON");
				} 
			} else {
				if (key.equals(Model.AllZones)) {
					for(State eachState : state.values()){
						eachState.setMute(false);					
					}
					returnVal.addAvOutputString("*ALLMOFF");
				} else {
					currentState.setMute(false);
					returnVal.addAvOutputString("*Z"+key+"MTOFF");
				} 
			}
			logger.log (Level.FINEST,"Muting zone " + key);
			commandFound = true;
			returnVal.outputCommandType = Model.Mute;
		}
		
		if (!commandFound && theCommand.equals("bass")) {
			try {
				int newVal = Utility.scaleFromFlash(extra,-12,12,false);
				returnVal.addAvOutputString(String.format("*Z"+key+"BASS%+03d",newVal));
				logger.log (Level.FINEST,"Changing tone in zone " + key);
			} catch (NumberFormatException ex){
				logger.log (Level.WARNING,"Illegal value for tone change " + ex.getMessage());				
			}
			commandFound = true;
			returnVal.outputCommandType = Model.Tone;
		}
		
		if (!commandFound && theCommand.equals("treble")) {
			try {
				int newVal = Utility.scaleFromFlash(extra,-12,12,false);
				returnVal.addAvOutputString(String.format("*Z"+key+"TREB%+03d",newVal));
				logger.log (Level.FINEST,"Changing tone in zone " + key);
			} catch (NumberFormatException ex){
				logger.log (Level.WARNING,"Illegal value for tone change " + ex.getMessage());				
			}
			commandFound = true;
			returnVal.outputCommandType = Model.Tone;
		}
		
		if (commandFound) {
			return returnVal;
		}
		else {
			return null;
		}
	}
	
	public void setGroupKeys (DeviceType audioDevice,String srcStr, int src, SignVideoCommands returnVal) {
		String keyToTest = audioDevice.getKey();
		// Member of source group so switch any other devices in the group to the same source
		for (String eachKey : this.srcGroup){
			try {
				if (!eachKey.equals (keyToTest)){
					State stateOfLinkedDevice= state.get(eachKey);
					if (!stateOfLinkedDevice.testSrc(src)){
						DeviceType linkedDevice = (DeviceType)configHelper.getControlItem(eachKey);					
						returnVal.avOutputFlash.add(buildCommand ( linkedDevice, "src",srcStr));
						stateOfLinkedDevice.setSrc(src);
						logger.log (Level.FINE,"Updating source of zone " + keyToTest + " due to source linkage");
					}
				}
			} catch (ClassCastException ex){
				logger.log (Level.WARNING, "A non-audio SignVideo device has been incorrectly added to the source group. Key " + keyToTest);
			}
		}
	}

	public SignVideoHelper getSignVideoHelper() {
		return signVideoHelper;
	}

	public void setSignVideoHelper(SignVideoHelper signVideoHelper) {
		this.signVideoHelper = signVideoHelper;
	}
	
}
