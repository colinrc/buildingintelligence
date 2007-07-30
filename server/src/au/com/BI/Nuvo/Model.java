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
import au.com.BI.Config.ParameterException;
import au.com.BI.AV.AVState;
import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Util.*;
import au.com.BI.Command.ReturnWrapper;
import au.com.BI.Device.DeviceType;
import au.com.BI.Nuvo.Protocols;

import java.util.*;
import java.util.logging.*;



public class Model extends SimplifiedModel implements DeviceModel {
	

	
	protected String outputAudioCommand = "";
	protected HashMap <String,AVState>state;
	protected NuvoHelper nuvoHelper;
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
	public static final int Control = 7;	
	
	public Protocols protocol = Protocols.Standard;
	
	
	public Model () {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		nuvoHelper = new NuvoHelper();
		state = new HashMap<String,AVState>();
		setPadding (2); // device requires 2 character keys that are 0 padded.
		setInterCommandInterval(50);
		srcGroup = new Vector<String>();
		configHelper.addParameterBlock ("AUDIO_INPUTS",DeviceModel.MAIN_DEVICE_GROUP,"Audio Source");
	}

	public void clearItems () {
		state.clear();
		super.clearItems();
	}

	
	public void prepareToAttatchComms() {
		initState ();
	}
	
	public boolean doIPHeartbeat () { 
		return false; 
	}
	
	public void initState () {
	    for(DeviceType audioDevice : configHelper.getAllOutputDeviceObjects()) {
	    	String key = audioDevice.getKey(); 
			if (!key.equals(Model.AllZones)) {
				state.put(key, new AVState());
			}
	    }	
	}
	
	public void finishedReadingParameters () {
		super.finishedReadingParameters();
		String protocolStr = getParameterValue ("PROTOCOL", DeviceModel.MAIN_DEVICE_GROUP);
		if (protocolStr.equals ("GC")){
			protocol = Protocols.GrandConcerto;
			nuvoHelper.setProtocol (Protocols.GrandConcerto);
		}

	}
	
	public void doStartup() throws CommsFail {
		
		synchronized (comms) {
			comms.clearCommandQueue();
		}
		
	    for(DeviceType audioDevice : configHelper.getAllOutputDeviceObjects()) {
	    	String key = audioDevice.getKey();
			if (!key.equals(Model.AllZones)) {

				String toneRequest = "";
				
				if (protocol == Protocols.GrandConcerto){ 
					toneRequest = "*ZCFG"+ audioDevice.getKey()+ "EQ\r";
				} else {
					toneRequest = "*Z"+ audioDevice.getKey()+ "SETSR\r";					
				}
				
				synchronized (comms){
					try { 
				    	this.sendToSerial(toneRequest,key,((Audio)(audioDevice)).getOutputKey(),Model.Zone_Tone_Request,false);
					} catch (CommsFail e1) {
						throw new CommsFail ("Communication failed communitating with Nuvo " + e1.getMessage());
					} 
				}
				
			}
	    }
	    
	    for(DeviceType audioDevice : configHelper.getAllOutputDeviceObjects()) {
	    	String key = audioDevice.getKey();
			if (!key.equals(Model.AllZones)) {
				String zoneRequest = "";
				if (protocol == Protocols.Standard){
					 zoneRequest = "*Z"+ audioDevice.getKey()+ "CONSR\r";
				} else {
					 zoneRequest = "*Z"+ audioDevice.getKey()+ "STATUS?\r";					
				}

				synchronized (comms){
					try { 
				    	this.sendToSerial(zoneRequest,key,((Audio)(audioDevice)).getOutputKey(),Model.Zone_Status_Request,false);
					} catch (CommsFail e1) {
						throw new CommsFail ("Communication failed communitating with Nuvo " + e1.getMessage());
					} 
				}				
			}
	    }
	}
		
	
	public void doOutputItem (CommandInterface command) throws CommsFail {	
		String theWholeKey = command.getKey();
		DeviceType device  = configHelper.getOutputItem(theWholeKey);
		ReturnWrapper toSend = null;
		
		if (device == null) {
			logger.log(Level.SEVERE, "Error in config, no output key for " + theWholeKey);
		}
		else {
			cache.setCachedCommand(command.getKey(),command);
			
				switch (device.getDeviceType()) {
					case DeviceType.AUDIO :
						Audio audioDevice = (Audio)device;
						toSend = buildAudioString (audioDevice,command);
						if (toSend != null && !toSend.isError()) {

							logger.log(Level.FINER, "Audio event for zone " + device.getKey() + " received from flash");

						    for(String avOutputString : toSend.getCommOutputStrings()) {			
						    	this.sendToSerial(avOutputString+"\r",device.getKey(),audioDevice.getOutputKey(),toSend.getOutputCommandType(),false);
							}
						    
							for (CommandInterface eachCommand: toSend.getOutputFlash()){
								this.sendToFlash(eachCommand, cache);
							}

						} else {
							if (toSend != null){
								logger.log (Level.WARNING,"Error processing Nuvo message " + toSend.getErrorDescription());
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
		ReturnWrapper commandObject = interpretStringFromNuvo (command);
		for (CommandInterface eachCommand: commandObject.getOutputFlash()){
			this.sendToFlash(eachCommand, cache);
		}
		for (String eachCommand: commandObject.getCommOutputStrings()){
			this.sendToSerial(eachCommand+"\r");
		}
	}

	
	public ReturnWrapper interpretStringFromNuvo (CommandInterface command){
		ReturnWrapper result = new ReturnWrapper();
		boolean commandFound = false;
			
		String nuvoCmd = command.getKey();
		if (nuvoCmd.equals ("#?")) {
			logger.log (Level.FINER,"Nuvo was sent a command it did not understand");
			return result;
		}
		
		try {

			
			if (!commandFound && nuvoCmd.contains("PWR")  ){
				// standard = #ZxxPWRppp,SRCs,GRPt,VOL-yy
				 String key = nuvoCmd.substring(2, 4);
			
				 DeviceType audioDevice = configHelper.getControlledItem(formatKey(key,null));
					commandFound = true;
				if (audioDevice == null){
					logger.log (Level.INFO,"A command was issued from NuVo for a zone that has not been configured " + key);
						// The zone is not configured
					} else {					

						result = interpretZoneStatus (nuvoCmd,audioDevice);			
					}
			}
			
			if (!commandFound && protocol == Protocols.GrandConcerto && ( nuvoCmd.contains("LOCK")  || nuvoCmd.contains(",OFF" ))){
				// gc= RSP #Z1,ON,SRC4,VOL60,DND0,LOCK0 � POWER ON   or 
				//                 #Z1,OFF                      - POWER OFF 
				String []partsOfCmd = nuvoCmd.split (",");
				String key = partsOfCmd[0].substring(2);
					
				 DeviceType audioDevice = configHelper.getControlledItem(formatKey(key,null));
				if (audioDevice != null){
					result = interpretGCZoneStatus (partsOfCmd, audioDevice);					
				} else {
					logger.log (Level.INFO,"A command was issued from NuVo for a zone that has not been configured " + key);					
				}
			}
			
			if (!commandFound && protocol == Protocols.Standard && nuvoCmd.contains("BASS")){
				// standard =  #ZxxORp,BASSyy,TREByy,GRPq,VRSTr
				
				 String key = nuvoCmd.substring(2, 4);
					
				 DeviceType audioDevice = configHelper.getControlledItem(formatKey(key,null));
				commandFound = true;
				if (audioDevice == null){
						logger.log (Level.INFO,"A command was issued from NuVo for a zone that has not been configured " + key);
						// The zone is not configured
					} else {					

							result = interpretZoneSetStatus (nuvoCmd,audioDevice);			
					}
			}

			if (!commandFound && protocol == Protocols.GrandConcerto && nuvoCmd.contains("BASS")){
				// gc = #ZCFG1,BASS0,TREB0,BALC,LOUDCMP0 
				
				String []partsOfCmd = nuvoCmd.split (",");
				String key = partsOfCmd[0].substring(5);
					
				 DeviceType audioDevice = configHelper.getControlledItem(formatKey(key,null));
				if (audioDevice == null){
					logger.log (Level.INFO,"A command was issued from NuVo for a zone that has not been configured " + key);
						// The zone is not configured
				} else {					

							result = interpretGCEQStatus (partsOfCmd,audioDevice);			
				}
				commandFound = true;
			}
			
		} catch (IndexOutOfBoundsException ex){
			logger.log (Level.INFO,"Nuvo returned an incorrectly formatted string " + nuvoCmd);
		} catch ( NumberFormatException ex2) {
			logger.log (Level.INFO,"Nuvo returned incorrectly formatted numbers " + nuvoCmd);			
		}
	
		return result;
	}
	
	public void addToGroup (String newKey){
		srcGroup.add(newKey);
		for (String eachkey: srcGroup){
			AVState stateOfGroupItem = getState(eachkey);
			if (stateOfGroupItem != null){
				stateOfGroupItem.setSrc(0); 
				// Ensure the entire group has state nulled, so that any new source selection will be sent to the new group member
			} else {
				logger.log (Level.WARNING,"AVState was not recorded correctly for zone " + eachkey);
			}
		}
	}

	public void removeFromGroup (String newKey){
		srcGroup.remove(newKey);
	}


	public boolean isInGroup (String testKey){
		if (srcGroup.contains(testKey)){
			return true;
		} else {
			return false;
		}
	}
	
	public ReturnWrapper  interpretZoneStatus (String zoneStatus,DeviceType audioDevice) throws IndexOutOfBoundsException,NumberFormatException {
		ReturnWrapper returnCode = new ReturnWrapper();
		
		// standard = #ZxxPWRppp,SRCs,GRPt,VOL-yy
		String[] bits = zoneStatus.split(",");
		
		String power =bits[0].substring(7);
		AVState currentState = getState (audioDevice.getKey());
		if (power.equals("ON") && !currentState.isPower()) {
			returnCode.addFlashCommand(buildCommandForFlash ( audioDevice, "on","","","","","",0));
			currentState.setPower(true);
		}
		if (power.equals("OFF") && currentState.isPower()) {
			returnCode.addFlashCommand(buildCommandForFlash (audioDevice, "off","","","","","",0));
			currentState.setPower (false);
		}
		
		if (bits.length >1) {
			String srcStr = bits[1].substring(3);
			String grp = bits[2].substring(3);
			String volStr = bits[3].substring(3);
		
	
	
			int src = Integer.parseInt(srcStr);
			
	
	
			if (grp.equals("1") && !currentState.isGroup_on(0)) {
				returnCode.addFlashCommand(buildCommandForFlash ( audioDevice, "group","on","","","","",0));
				addToGroup (audioDevice.getKey());
				currentState.setGroup_on(true,0);
			}
			if (power.equals("0") && currentState.isGroup_on(0)) {
				returnCode.addFlashCommand(buildCommandForFlash (audioDevice, "group","off","","","","",0));
				removeFromGroup (audioDevice.getKey());
				currentState.setGroup_on(false,0);
			}
	
			if (!currentState.testSrc( src)) {
				try {
					String newSrc = findKeyForParameterValue(srcStr, "AUDIO_INPUTS",audioDevice);
					returnCode.addFlashCommand(buildCommandForFlash ( audioDevice, "src",newSrc,"","","","",0));
					currentState.setSrc(src);
					if (currentState.isGroup_on(0))setGroupKeys ( audioDevice, srcStr,  src,  returnCode);
				} catch (ParameterException ex){
					logger.log (Level.WARNING,ex.getMessage());
				}
			}
			
			if (volStr.equals ("-MT")){
				returnCode.addFlashCommand(buildCommandForFlash ( audioDevice, "mute","on","","","","",0));
				currentState.setMute(true);
				if (currentState.isExt_mute()){
					currentState.setExt_mute(false);
					returnCode.addFlashCommand(buildCommandForFlash ( audioDevice, "ext-mute","off","","","","",0));					
				}
			} else {
				if (volStr.equals ("-XM")){
					returnCode.addFlashCommand(buildCommandForFlash ( audioDevice, "ext-mute","on","","","","",0));
					currentState.setExt_mute(true);
					if (currentState.isMute()){
						currentState.setMute(false);
						returnCode.addFlashCommand(buildCommandForFlash ( audioDevice, "mute","off","","","","",0));					
					}
				} else {
					if (currentState.isMute()){
						currentState.setMute(false);
						returnCode.addFlashCommand(buildCommandForFlash ( audioDevice, "mute","off","","","","",0));					
					}
					if (currentState.isExt_mute()){
						currentState.setExt_mute(false);
						returnCode.addFlashCommand(buildCommandForFlash ( audioDevice, "ext-mute","off","","","","",0));					
					}
					int volForFlash = Utility.scaleForFlash(volStr, -79,0, false);
					if (!currentState.testVolume(volForFlash)){				
						String volForFlashStr = String.valueOf(volForFlash);
						currentState.setVolume (String.valueOf(volForFlashStr));
						returnCode.addFlashCommand(buildCommandForFlash ( audioDevice, "volume",volForFlashStr,"","","","",0));					
					}				
				}
				
			}
		}

		
		return returnCode;
	}

	
	public ReturnWrapper  interpretGCZoneStatus (String zoneStatus[],DeviceType audioDevice) throws IndexOutOfBoundsException,NumberFormatException {
		ReturnWrapper returnCode = new ReturnWrapper();
		
		// gc = #Z1,ON,SRC4,VOL60,DND0,LOCK0 ,  #Z1,OFF 
		
		
		String power =zoneStatus[1];
		AVState currentState = getState (audioDevice.getKey());
		if (power.equals("OFF")) {
			if (!currentState.testPower(false)) {
				returnCode.addFlashCommand(buildCommandForFlash (audioDevice, "off","","","","","",0));
				currentState.setPower (false);
			}
		} else {
			if (power.equals("ON") && !currentState.testPower(true)) {
				returnCode.addFlashCommand(buildCommandForFlash ( audioDevice, "on","","","","","",0));
				currentState.setPower(true);
			}
	
			
			if (zoneStatus.length >1) {
				String srcStr = zoneStatus[2].substring(3);
				String volStr = zoneStatus[3].substring(3);
		
				int src = Integer.parseInt(srcStr);
					
				if (!currentState.testSrc( src)){
					try {
						String newSrc = findKeyForParameterValue(srcStr, "AUDIO_INPUTS",audioDevice);
						returnCode.addFlashCommand(buildCommandForFlash ( audioDevice, "src",newSrc,"","","","",0));
						currentState.setSrc(src);
					} catch (ParameterException ex){
						logger.log (Level.WARNING,ex.getMessage());
					}
				}
				if (volStr.equals ("MUTE")){
					returnCode.addFlashCommand(buildCommandForFlash ( audioDevice, "mute","on","","","","",0));
					currentState.setMute(true);
				} else {
						if (currentState.isMute()){
							currentState.setMute(false);
							returnCode.addFlashCommand(buildCommandForFlash ( audioDevice, "mute","off","","","","",0));					
						}
						int volForFlash = Utility.scaleForFlash(volStr, 0,79, true);
						if (!currentState.testVolume(volForFlash)){				
							String volForFlashStr = String.valueOf(volForFlash);
							currentState.setVolume (String.valueOf(volForFlashStr));
							returnCode.addFlashCommand(buildCommandForFlash ( audioDevice, "volume",volForFlashStr,"","","","",0));					
						}				
				}				
			}
		}
		
		return returnCode;
	}
	
	
	public ReturnWrapper  interpretZoneSetStatus (String zoneStatus,DeviceType audioDevice) throws IndexOutOfBoundsException,NumberFormatException {
		ReturnWrapper returnCode = new ReturnWrapper();
		
		// #ZxxORp,BASSyy,TREByy,GRPq,VRSTr
		
		String[] bits = zoneStatus.split(",");
	
		String bass = bits[1].substring(5);
		String treble = bits[2].substring(5);

		int trebForFlash = Utility.scaleForFlash(treble, 0, 8, true);
		String trebForFlashStr = String.valueOf(trebForFlash);
		returnCode.addFlashCommand(buildCommandForFlash( audioDevice, "treble",trebForFlashStr,"","","","",0));					
		
		int bassForFlash = Utility.scaleForFlash(bass, 0, 8, true);
		String bassForFlashStr = String.valueOf(bassForFlash);
		returnCode.addFlashCommand(buildCommandForFlash ( audioDevice, "bass",bassForFlashStr,"","","","",0));
		
		return returnCode;
	}

	public ReturnWrapper  interpretGCEQStatus (String zoneStatus[],DeviceType audioDevice) throws IndexOutOfBoundsException,NumberFormatException {
		ReturnWrapper returnCode = new ReturnWrapper();
		
		// #ZCFG1,BASS0,TREB0,BALC,LOUDCMP0 

		String bass = zoneStatus[1].substring(4);
		String treble = zoneStatus[2].substring(4);
		String loud = zoneStatus[4].substring(7);
		
		AVState currentState = getState (audioDevice.getKey()); 

		int trebForFlash = Utility.scaleForFlash(treble, -18, 18, false);
		if (!currentState.testTreble(trebForFlash)) {
			String trebForFlashStr = String.valueOf(trebForFlash);
			returnCode.addFlashCommand(buildCommandForFlash( audioDevice, "treble",trebForFlashStr,"","","","",0));					
			currentState.setTreble(trebForFlash);
		}

		int bassForFlash = Utility.scaleForFlash(bass, -18, 18, false);
		if (!currentState.testBass(bassForFlash)) {
			String bassForFlashStr = String.valueOf(bassForFlash);
			currentState.setBass(bassForFlash);
			returnCode.addFlashCommand(buildCommandForFlash ( audioDevice, "bass",bassForFlashStr,"","","","",0));
		}

		if (loud.equals ("0") && !currentState.testLoudness (false)){
			currentState.setLoudness(false);
			returnCode.addFlashCommand(buildCommandForFlash ( audioDevice, "loud","off","","","","",0));			
		}
		if (loud.equals ("1") && !currentState.testLoudness(true)){
			currentState.setLoudness(true);
			returnCode.addFlashCommand(buildCommandForFlash ( audioDevice, "loud","on","","","","",0));			
		}
		return returnCode;
	}

	public AVState getState(String key) {
		AVState currentState = state.get(key);
		boolean alwaysUpdateState = false;
		if (currentState == null){
			currentState = new AVState();
			state.put(key, currentState);
		}
		return currentState;
	}
	
	public ReturnWrapper buildAudioString (Audio device, CommandInterface command){
		ReturnWrapper returnVal = new ReturnWrapper();
		String key = device.getKey();
		boolean commandFound = false;

		AVState currentState = getState(key);
		if (currentState == null){
			currentState = new AVState();
			state.put(key, currentState);
		}
		
		String rawBuiltCommand = doRawIfPresent (command, device);
		if (rawBuiltCommand != null)
		{
			returnVal.addCommOutput(rawBuiltCommand);
			commandFound = true;
		}
		String extra = ((String)command.getExtraInfo());

		String theCommand = command.getCommandCode();
		if (!commandFound && theCommand == "") {
			logger.log(Level.WARNING, "Empty command received from client "+ command.getCommandCode());
			return null;
		}

		if (!commandFound && theCommand.equals("src")) {
			// functionality is the same for both protocols
			String srcCode = "";
			commandFound = true;
			
			try {
				srcCode = getCatalogueValue(extra, "AUDIO_INPUTS",device);
				int src = Integer.parseInt(srcCode);
				
				if (key.equals(Model.AllZones)){
				    for(DeviceType audioDevice : configHelper.getAllOutputDeviceObjects()) {
						if (!audioDevice.getKey().equals(Model.AllZones)) {
							AVState stateForItem = getState(audioDevice.getKey());
							if (stateForItem != null) 
								stateForItem.setSrc(src);
							else
								logger.log (Level.WARNING,"AVState was not correctly set up within the Nuvo system, please contact your integrator ");
							returnVal.addCommOutput(String.format("*Z"+audioDevice.getKey()+"SRC"+src));
						}
				    }	
					logger.log (Level.FINEST,"Changing audio source for all zones");
				} else {
					currentState.setSrc(src);
					returnVal.addCommOutput(String.format("*Z"+key+"SRC"+src));
					logger.log (Level.FINEST,"Changing audio source");
					if (currentState.isGroup_on(0)){
						setGroupKeys (device,extra,src,returnVal);
					}
				}
				returnVal.setOutputCommandType (Model.Select);
			} catch (NumberFormatException ex) {
				returnVal.addCommOutput("");
				returnVal.setError( true);
				returnVal.setErrorDescription ( "Input src does not decode to an integer");
			} catch (ParameterException e) {
				returnVal.addCommOutput("");
				returnVal.setError( true);
				returnVal.setErrorDescription ( e.getMessage());
			}
		}			
		
		if (!commandFound && theCommand.equals("group")) {
			commandFound = true;
			if (extra.equals ("on")){
				currentState.setGroup_on(true,0);
				this.addToGroup(key);
				logger.log (Level.FINE,"Zone " + key + " added to the source group");	
			}  else {
				currentState.setGroup_on(false,0);
				this.removeFromGroup(key);
				logger.log (Level.FINE,"Zone " + key + " removed from the source group");	
			}
		}
		
		
		if (!commandFound && theCommand.equals("loud")) {
			commandFound = true;
			if (extra.equals ("on")){
				currentState.setLoudness(true);
				returnVal.addCommOutput(String.format("*ZCFG"+key+"LOUDCMP1"));				
				logger.log (Level.FINE,"Zone " + key + " had loudness set on");	
			}  else {
				currentState.setLoudness(false);
				returnVal.addCommOutput(String.format("*ZCFG"+key+"LOUDCMP0"));				
				logger.log (Level.FINE,"Zone " + key + " had loudness set on");	
			}
		}
			
		if (!commandFound && theCommand.equals("volume")) {

			if (!commandFound && extra.equals ("up")){
				commandFound = true;
				if (!key.equals (Model.AllZones)){
					if (protocol == Protocols.Standard){
						String newVol = currentState.volumeUp();
						int newVal = Utility.scaleFromFlash(newVol,0,79,true);
						
						returnVal.addCommOutput(String.format("*Z"+key+"VOL%02d",newVal));
						returnVal.addFlashCommand(buildCommandForFlash(device,"volume",newVol,"","","","",0));
					} else {
						returnVal.addCommOutput(String.format("*Z"+key+"VOL+"));						
					}
					logger.log (Level.FINEST,"Volump up in zone " + key);					
				} else {
				    for(DeviceType audioDevice : configHelper.getAllOutputDeviceObjects()) {
				    	if (!audioDevice.getKey().equals(Model.AllZones)) {
							if (protocol == Protocols.Standard){
								AVState stateForItem = getState(audioDevice.getKey());
								if (stateForItem != null){ 
									String newVol = currentState.volumeUp();
									int newVal = Utility.scaleFromFlash(newVol,0,79,true);
									stateForItem.setVolume(newVol);
								}
								else{
									logger.log (Level.WARNING,"AVState was not correctly set up within the Nuvo system, please contact your integrator ");
								}
								String newVol = currentState.volumeUp();
								int newVal = Utility.scaleFromFlash(newVol,0,79,true);
								stateForItem.setVolume(newVol);
	
								returnVal.addCommOutput("*Z"+audioDevice.getKey()+"VOL"+newVol);
							} else {
								returnVal.addCommOutput(String.format("*Z"+audioDevice.getKey()+"VOL+"));														
							}
						}
				    }	

					logger.log (Level.FINEST,"All volume up");	
				}
			}

			if (!commandFound && extra.equals ("down")){
				commandFound = true;
				if (!key.equals (Model.AllZones)){
					if (protocol == Protocols.Standard){
						String newVol = currentState.volumeDown();
						int newVal = Utility.scaleFromFlash(newVol,0,79,true);
						returnVal.addCommOutput(String.format("*Z"+key+"VOL%02d",newVal));
						returnVal.addFlashCommand(buildCommandForFlash(device,"volume",newVol,"","","","",0));
					} else {
						returnVal.addCommOutput(String.format("*Z"+key+"VOL-"));												
					}
					logger.log (Level.FINEST,"Volume down in zone " + key);					
				} else {
				    for(DeviceType audioDevice : configHelper.getAllOutputDeviceObjects()) {
						if (!audioDevice.getKey().equals(Model.AllZones)) {
							if (protocol == Protocols.Standard){
								String newVol = currentState.volumeDown();
								int newVal = Utility.scaleFromFlash(newVol,0,79,true);
								AVState stateForItem = getState(audioDevice.getKey());
								if (stateForItem != null) 
									stateForItem.setVolume(newVol);
								else
									logger.log (Level.WARNING,"AVState was not correctly set up within the Nuvo system, please contact your integrator ");
								returnVal.addCommOutput("*Z"+audioDevice.getKey()+"VOL"+newVol);
							} else {
								returnVal.addCommOutput(String.format("*Z"+audioDevice.getKey()+"VOL-"));																				
							}
						}
				    }	

					logger.log (Level.FINEST,"All volume down");	
				}
			}
			if (!commandFound && extra.equals ("rampup")){
				// functionality was removed from Grand concerto.	
				commandFound = true;
				if (protocol == Protocols.Standard){
					if (!key.equals (Model.AllZones)){
						currentState.setVolume("");
						returnVal.addCommOutput(String.format("*Z"+key+"VOL+"));
						logger.log (Level.FINEST,"Volump ramp up in zone " + key);					
					} else {
	
						returnVal.addCommOutput("*ZALLV+");
						for(AVState eachState : state.values()){
							eachState.setVolume("");					
						}
						logger.log (Level.FINEST,"All volume ramp up");	
					}
				} 				
			}

			if (!commandFound && extra.equals ("rampdown")){
				// functionality was removed from Grand concerto.
				commandFound = true;
				if (protocol == Protocols.Standard){
					if (!key.equals (Model.AllZones)){
						for(AVState eachState : state.values()){
							eachState.setVolume("");					
						}
						returnVal.addCommOutput(String.format("*Z"+key+"VOL-"));
						logger.log (Level.FINEST,"Volump ramp down in zone " + key);					
					} else {
						currentState.setVolume("");
						returnVal.addCommOutput("*ZALLV-");
						logger.log (Level.FINEST,"All volume ramp down");	
					}
				} 
			}
			if (!commandFound && extra.equals ("stop")){
				 // functionality was removed from Grand concerto.
				commandFound = true;
				if (protocol == Protocols.Standard){
					if (key.equals (Model.AllZones)){
						returnVal.addCommOutput(String.format("*ZALLHLD"));
						logger.log (Level.FINEST,"Volump ramp stop in all zones");					
					} else {
						returnVal.addCommOutput("*Z"+key+"VHLD");
						logger.log (Level.FINEST,"All volume ramp stop in zone " + key);	
					}
				}
			}
			if (!commandFound){
				try {
					int newVal = Utility.scaleFromFlash(extra,0,79,true);
					String volString = String.format("%02d",newVal);
					currentState.setVolume(extra);
					returnVal.addCommOutput("*Z"+key+"VOL"+volString);
					commandFound = true;
					logger.log (Level.FINEST,"Changing tone in zone " + key);
				} catch (NumberFormatException ex){
					logger.log (Level.WARNING,"Illegal value for tone change " + ex.getMessage());				
				}
			}

		}	
		
		if (!commandFound &&  theCommand.equals("on")) {
			// ON is the same for both protocols
			currentState.setPower(true);
			returnVal.addCommOutput("*Z"+key+"ON");
			logger.log (Level.FINEST,"Switching on zone "+ key);
			commandFound = true;
			returnVal.setOutputCommandType ( DeviceType.NUVO_SWITCH);
		}
		
		if (!commandFound && theCommand.equals("off")) {
	    	// Zone off is the same for both protocols
			if (key.equals(Model.AllZones)) {
				for(AVState eachState : state.values()){
					eachState.setPower(false);					
				}
			    for(DeviceType audioDevice : configHelper.getAllOutputDeviceObjects()) {
					if (!audioDevice.getKey().equals(Model.AllZones)) {
							returnVal.addFlashCommand(this.buildCommandForFlash(audioDevice, "off", "", "", "", "", "", 0));
					}
			    }
		    	returnVal.addCommOutput("*ALLOFF");

			} else {
				currentState.setPower(false);
		    	returnVal.addCommOutput("*Z"+key+"OFF");
			}
			logger.log (Level.FINEST,"Switching off zone " + key);
			commandFound = true;
			returnVal.setOutputCommandType (Model.Switch);
		}

		if (!commandFound && theCommand.equals("mute")) {
			if (command.getExtraInfo().equals ("on")){
				if (key.equals(Model.AllZones)) {
					for(AVState eachState : state.values()){
						eachState.setMute(true);			
					}
				    for(DeviceType audioDevice : configHelper.getAllOutputDeviceObjects()) {
						if (!audioDevice.getKey().equals(Model.AllZones)) {
								returnVal.addFlashCommand(this.buildCommandForFlash(audioDevice, "mute", "on", "", "", "", "", 0));
						}
				    }
				    if (protocol == Protocols.Standard) {
				    	returnVal.addCommOutput("*ALLMON");
				    } else {
				    	returnVal.addCommOutput("*MUTE1");				    	
				    }
				} else {
					currentState.setMute(true);
				    if (protocol == Protocols.Standard) {
				    	returnVal.addCommOutput("*Z"+key+"MTON");
				    } else {
				    	returnVal.addCommOutput("*Z"+key+"MUTEON");				    	
				    }
				} 
			} else {
				if (key.equals(Model.AllZones)) {
					for(AVState eachState : state.values()){
						eachState.setMute(false);					
					}
				    for(DeviceType audioDevice : configHelper.getAllOutputDeviceObjects()) {
						if (!audioDevice.getKey().equals(Model.AllZones)) {
								returnVal.addFlashCommand(this.buildCommandForFlash(audioDevice, "mute", "off", "", "", "", "", 0));
						}
				    }
				    if (protocol == Protocols.Standard) {
				    	returnVal.addCommOutput("*ALLMOFF");
				    } else {
				    	returnVal.addCommOutput("*MUTE0");				    					    	
				    }
				} else {
					currentState.setMute(false);
				    if (protocol == Protocols.Standard) {
				    	returnVal.addCommOutput("*Z"+key+"MTOFF");
				    } else {
				    	returnVal.addCommOutput("*Z"+key+"MUTEOFF");				    	
				    }
				} 
			}
			logger.log (Level.FINEST,"Muting zone " + key);
			commandFound = true;
			returnVal.setOutputCommandType ( Model.Mute);
		}
		
		if (!commandFound && theCommand.equals("bass")) {
			try {
			    if (protocol == Protocols.Standard) {
					int newVal = Utility.scaleFromFlash(extra,-12,12,false);
					returnVal.addCommOutput(String.format("*Z"+key+"BASS%+03d",newVal));
			    } else {
					int newVal = Utility.scaleFromFlash(extra,-18,18,false);
					returnVal.addCommOutput(String.format("*ZCFG"+key+"BASS%d",newVal));			    	
			    }
				logger.log (Level.FINEST,"Changing tone in zone " + key);
			} catch (NumberFormatException ex){
				logger.log (Level.WARNING,"Illegal value for tone change " + ex.getMessage());				
			}
			commandFound = true;
			returnVal.setOutputCommandType ( Model.Tone);
		}
		
		if (!commandFound && theCommand.equals("treble")) {
			try {
			    if (protocol == Protocols.Standard) {
					int newVal = Utility.scaleFromFlash(extra,-12,12,false);
					returnVal.addCommOutput(String.format("*Z"+key+"TREB%+03d",newVal));
			    } else {
					int newVal = Utility.scaleFromFlash(extra,-18,18,false);
					returnVal.addCommOutput(String.format("*ZCFG"+key+"TREB%d",newVal));			    				    	
			    }
				logger.log (Level.FINEST,"Changing tone in zone " + key);
			} catch (NumberFormatException ex){
				logger.log (Level.WARNING,"Illegal value for tone change " + ex.getMessage());				
			}
			commandFound = true;
			returnVal.setOutputCommandType ( Model.Tone);
		}
		
		if (!commandFound && theCommand.equals("play/pause")) {
			commandFound = true;
		    if (protocol == Protocols.GrandConcerto) {

				returnVal.addCommOutput(String.format("*Z"+key+"PLAYPAUSE"));
				logger.log (Level.FINEST,"Simulating play/pause in zone " + key);
				returnVal.setOutputCommandType ( Model.Control);
		    }
		}
		if (!commandFound && theCommand.equals("prev")) {
			commandFound = true;
		    if (protocol == Protocols.GrandConcerto) {

				returnVal.addCommOutput(String.format("*Z"+key+"PREV"));
				logger.log (Level.FINEST,"Simulating previous in zone " + key);
				returnVal.setOutputCommandType ( Model.Control);
		    }
		}
		if (!commandFound && theCommand.equals("next")) {
			commandFound = true;
		    if (protocol == Protocols.GrandConcerto) {

				returnVal.addCommOutput(String.format("*Z"+key+"NEXT"));
				logger.log (Level.FINEST,"Simulating next in zone " + key);
				returnVal.setOutputCommandType ( Model.Control);
		    }
		}
		
		if (commandFound) {
			return returnVal;
		}
		else {
			return null;
		}
		

	}
	
	public void setGroupKeys (DeviceType audioDevice,String srcStr, int src, ReturnWrapper returnVal) {
		String keyToTest = audioDevice.getKey();
		// Member of source group so switch any other devices in the group to the same source
		for (String eachKey : this.srcGroup){
			try {
				if (!eachKey.equals (keyToTest)){
					AVState stateOfLinkedDevice= getState(eachKey);
					if (!stateOfLinkedDevice.testSrc(src)){
						DeviceType linkedDevice = (DeviceType)configHelper.getControlItem(eachKey);					
						returnVal.addFlashCommand(buildCommandForFlash ( linkedDevice, "src",srcStr,"","","","",0));
						stateOfLinkedDevice.setSrc(src);
						logger.log (Level.FINE,"Updating source of zone " + keyToTest + " due to source linkage");
					}
				}
			} catch (ClassCastException ex){
				logger.log (Level.WARNING, "A non-audio Nuvo device has been incorrectly added to the source group. Key " + keyToTest);
			}
		}
	}

	public NuvoHelper getNuvoHelper() {
		return nuvoHelper;
	}

	public void setNuvoHelper(NuvoHelper nuvoHelper) {
		this.nuvoHelper = nuvoHelper;
	}
	
}
