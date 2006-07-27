
package au.com.BI.Dynalite;


/**
 * @author Colin Canfield
 * @author Explorative Sofwtare Pty Ltd
 *
*/
import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Device.DeviceType;
import au.com.BI.Util.*;
import au.com.BI.User.*;

import java.util.*;
import java.util.logging.*;

import au.com.BI.AlarmLogging.*;
import au.com.BI.Lights.*;

public class Model extends BaseModel implements DeviceModel {

	protected String outputDynaliteCommand = "";
	protected HashMap state;
	protected DynaliteHelper dynaliteHelper;
	protected AreaCodes areaCodes = null;
	protected int protocol = DynaliteDevice.Linear;
	protected HashMap <String,Byte>areaOffset;
	
	public Model () {
		super();

		state = new HashMap(128);
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		dynaliteHelper = new DynaliteHelper();	
		areaCodes = new AreaCodes();
		areaCodes.setConfigHelper(configHelper);
		areaCodes.setDynaliteHelper(dynaliteHelper);
		areaOffset = new HashMap<String,Byte>();
		this.setInterCommandInterval(10); // Based on initial Dynalite docs.
	}



	public void clearItems () {
		state.clear();
		areaCodes.clear();
		super.clearItems();
	}


	public void attatchComms() 
	throws ConnectionFail { 
		super.setTransmitMessageOnBytes(8); // dynalite uses 8 byte packets
		super.attatchComms( );
	}

	public void doStartup () throws CommsFail{
		this.requestAllLevels();
		this.requestAllAreaLinks();
	}


    public void finishedReadingConfig() throws SetupException {
    	super.finishedReadingConfig();
    		String protocolStr = (String)this.getParameterValue("PROTOCOL","");
    		if (protocolStr.equals("CLASSIC")) {
    			this.protocol = DynaliteDevice.Classic;
    		}
    		if (protocolStr.equals("LINEAR")) {
    			this.protocol = DynaliteDevice.Linear;
    		}
    };

	public void sendToComms (byte vals[]) throws CommsFail{
		/*
		byte tester[] = new byte[1];
		for (int i = 0 ; i < 8; i ++) {
			tester [0] = vals[i];
			comms.sendString(tester);
		}
		*/
		comms.sendString( vals);
	}

	public void addControlledItem (String key, DeviceType details, MessageDirection controlType) {

		try {
			String theKey = key;
			int box=0;
			if (controlType == MessageDirection.FROM_HARDWARE )  {
				DynaliteDevice device = null;	
				
				if (details instanceof DynaliteInputDevice){
					DynaliteInputDevice deviceInput = (DynaliteInputDevice)details;
					box = deviceInput.getBox() ;
				} else {
					device = (DynaliteDevice)details;		
				}
				
				if (((DeviceType)details).getDeviceType() == DeviceType.LIGHT_DYNALITE ) {
					theKey = dynaliteHelper.buildKey('L',device.getAreaCode(),device.getChannel());
					areaCodes.add (device.getAreaCode(),device);
				}
				if (((DeviceType)details).getDeviceType() == DeviceType.LIGHT_DYNALITE_AREA) {
					theKey = dynaliteHelper.buildKey('L',device.getKey(),"00");
					areaCodes.add (device.getKey(),device);
				}
				if (((DeviceType)details).getDeviceType() == DeviceType.ALARM) {
					theKey = device.getKey();
				}
				
				if (((DeviceType)details).getDeviceType() == DeviceType.IR ) {
					theKey = dynaliteHelper.buildKey('I',box,key);
				}
				if (((DeviceType)details).getDeviceType() == DeviceType.CONTACT_CLOSURE) {
					theKey = dynaliteHelper.buildKey('C',box,key);
				}

				if (((DeviceType)details).getDeviceType() == DeviceType.SENSOR) {
					theKey = name;
				}
				
			}


			configHelper.addControlledItem (theKey, details, controlType);
		} catch (ClassCastException ex) {
			logger.log( Level.WARNING,"Attempted to add an incorrect device type to the Dynalite model");
		}catch (NullPointerException ex) {
			logger.log( Level.WARNING,"Attempted to add an incorrect device type to the Dynalite model");
		}
	}

		
	void requestAllLevels (int area,byte join) throws CommsFail{
		requestAllLevels (Utility.padStringTohex(area),join);
	}

	
	void requestLevel (String area, int channel ,String outputKey) throws CommsFail {
		String fullKey = dynaliteHelper.buildKey('L',area,channel);

		DynaliteOutput result = this.buildDynaliteLevelRequestCommand(area,channel,outputKey,255);
 		CommsCommand dynaliteCommsCommand = new CommsCommand();
		dynaliteCommsCommand.setKey (fullKey);
		dynaliteCommsCommand.setCommandBytes(result.outputCodes);
		dynaliteCommsCommand.setExtraInfo (outputKey);
		dynaliteCommsCommand.setKeepForHandshake(false);
		dynaliteCommsCommand.setActionType(DynaliteCommand.REQUEST_LEVEL);
		dynaliteCommsCommand.setActionCode(fullKey);
		comms.addCommandToQueue(dynaliteCommsCommand);	
	}
	
	void requestAllLevels (String area,byte join) throws CommsFail{
		List allLights = areaCodes.findDevicesInArea (area,false,join);
		Iterator eachLight = allLights.iterator();
		while (eachLight.hasNext()){
			DynaliteDevice nextItem = (DynaliteDevice)eachLight.next();
			requestLevel (nextItem.getAreaCode(),nextItem.getChannel(),nextItem.getOutputKey());				
		}
	}
	
	void requestAllLevels () throws CommsFail{
		Iterator eachLight = configHelper.getControlledItemsList();
		while (eachLight.hasNext()){
			String nextKey = (String)eachLight.next();
			try {
				Object tempDevice = configHelper.getControlledItem(nextKey);
				DeviceType nextDevice = (DeviceType)tempDevice;
				if (nextDevice.getDeviceType() == DeviceType.LIGHT_DYNALITE )  {
					DynaliteDevice nextItem = (DynaliteDevice)nextDevice;
					String fullKey = dynaliteHelper.buildKey('L',nextItem.getAreaCode(),nextItem.getChannel());
					if (nextItem.isAreaDevice()) continue; // cannot query level of an area
					DynaliteOutput result = this.buildDynaliteLevelRequestCommand(nextItem.getAreaCode(),nextItem.getChannel(),nextItem.getOutputKey(),255);
					CommsCommand dynaliteCommsCommand = new CommsCommand();
					dynaliteCommsCommand.setKey (fullKey);
					dynaliteCommsCommand.setCommandBytes(result.outputCodes);
					dynaliteCommsCommand.setExtraInfo (nextItem.getOutputKey());
					dynaliteCommsCommand.setKeepForHandshake(false);
					dynaliteCommsCommand.setActionType(DynaliteCommand.REQUEST_LEVEL);
					dynaliteCommsCommand.setActionCode(fullKey);
					comms.addCommandToQueue(dynaliteCommsCommand);		
				}
			} catch (ClassCastException ex){
				logger.log (Level.WARNING,"A device that is not a dynalite device had been added to dynalite "+ex.getMessage());
			}
		}
	}

	void requestAllAreaLinks () throws CommsFail{
		List areaDeviceList = areaCodes.findAllAreas();
		Iterator eachArea = areaDeviceList.iterator();
		while (eachArea.hasNext()){
			try {
				DynaliteDevice nextItem = (DynaliteDevice)eachArea.next();
				if (nextItem.getDeviceType() == DeviceType.LIGHT_DYNALITE_AREA )  {
					String fullKey = dynaliteHelper.buildKey('L',nextItem.getAreaCode(),nextItem.getChannel());
					if (	nextItem.isAreaDevice()) continue; 
					DynaliteOutput result = this.buildDynaliteLinkRequestCommand(nextItem.getAreaCode(),nextItem.getOutputKey(),255);
					CommsCommand dynaliteCommsCommand = new CommsCommand();
					dynaliteCommsCommand.setKey (fullKey);
					dynaliteCommsCommand.setCommandBytes(result.outputCodes);
					dynaliteCommsCommand.setExtraInfo (nextItem.getOutputKey());
					dynaliteCommsCommand.setKeepForHandshake(true);
					dynaliteCommsCommand.setActionType(DynaliteCommand.REQUEST_LEVEL);
					dynaliteCommsCommand.setActionCode(fullKey);
					comms.addCommandToQueue(dynaliteCommsCommand);		
				}
			} catch (ClassCastException ex){
				logger.log (Level.WARNING,"A device that is not a dynalite device had been added to dynalite "+ex.getMessage());
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
				configHelper.setLastCommandType (MessageDirection.FROM_HARDWARE);
				// Anything coming over the serial port I want to process
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
			DynaliteOutput outputDynaliteCommand = null;
			cache.setCachedCommand(command.getKey(),command);

			logger.log(Level.FINER, "Monitored Dynalite event, sending it to the channel " + device.getKey());

			switch (device.getDeviceType()) {
				case DeviceType.LIGHT_DYNALITE :
					//DynaliteDevice lightDevice = (DynaliteDevice)device;
					//String fullKey = this.dynaliteHelper.buildKey('L',lightDevice.getAreaCode(),lightDevice.getKey());

					if ((outputDynaliteCommand = buildDynaliteResult ((DynaliteDevice)device,command)) != null) {
						try {
							this.sendToComms(outputDynaliteCommand.outputCodes);
							if (outputDynaliteCommand.isRescanLevels()){
								this.requestAllLevels(outputDynaliteCommand.getRescanArea(), (byte)255);
							}

							logger.log (Level.FINER,"Sending dynalite command " + " for " + ((LightFascade)(device)).getOutputKey());

							Iterator li = outputDynaliteCommand.linkedDeviceCommands.iterator();
							while (li.hasNext()){
								CommandInterface nextCommand = (CommandInterface)li.next();
								cache.setCachedCommand(nextCommand.getKey(),nextCommand);
								this.sendToFlash(-1,nextCommand);
								logger.log (Level.FINER,"Sending dynalite linked command " + " for " + nextCommand.getKey());
							}
						} catch (CommsFail e1) {
							logger.log(Level.WARNING, "Communication failed communicating with Dynalite " + e1.getMessage());
							throw new CommsFail ("Error communicating with Dynalite");
						}



					}
					break;
					
				case DeviceType.LIGHT_DYNALITE_AREA :
					//DynaliteDevice lightArea = (DynaliteDevice)device;
					//String fullKeyStr = this.dynaliteHelper.buildKey('L',lightArea.getAreaCode(),lightArea.getKey());

					if ((outputDynaliteCommand = buildDynaliteResult ((DynaliteDevice)device,command)) != null) {
						try {

							this.sendToComms(outputDynaliteCommand.outputCodes);
							if (outputDynaliteCommand.isRescanLevels()){
								this.requestAllLevels(outputDynaliteCommand.getRescanArea(), (byte)255);
							}

							logger.log (Level.FINER,"Sending dynalite command " + " for " + ((LightFascade)(device)).getOutputKey());
							Iterator li = outputDynaliteCommand.linkedDeviceCommands.iterator();
							while (li.hasNext()){
								CommandInterface nextCommand = (CommandInterface)li.next();
								cache.setCachedCommand(nextCommand.getKey(),nextCommand);
								this.sendToFlash(-1,nextCommand);
								logger.log (Level.FINER,"Sending dynalite linked command " + " for " + nextCommand.getKey());
							}
						} catch (CommsFail e1) {
							logger.log(Level.WARNING, "Communication failed communicating with Dynalite " + e1.getMessage());
							throw new CommsFail ("Error communicating with Dynalite");
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
		InterpretResult results = null;
		if (command.isCommsCommand()){
			byte [] returnVal = ((CommsCommand)command).getCommandBytes();
			if (returnVal == null){
				logger.log (Level.WARNING,"Error in serial handler for dynalite.");
			} else {
				results = interperetDynaliteCode (returnVal);	
				Iterator i = results.decoded.iterator();
				while (i.hasNext()){
					CommandInterface nextCommand = (CommandInterface)i.next();
					if (nextCommand != null) {
					    cache.setCachedCommand(nextCommand.getKey(),nextCommand);
					    this.sendToFlash(-1,nextCommand);
					}
				}
				if (results.isRescanLevels()){
					this.requestAllLevels(results.getRescanArea(), (byte)255);
				}
				if (results.isRescanSingleChannel()){
					DynaliteDevice dev = findSingleDevice (DynaliteHelper.Light,results.getRescanArea(), results.getRescanChannel(),true);
					if (dev != null) {
						this.requestLevel(dev.getAreaCode(),dev.getChannel(),dev.getOutputKey());
					}
				}
				Iterator li = results.linkedDeviceCommands.iterator();
				while (li.hasNext()){
					CommandInterface nextCommand = (CommandInterface)li.next();
					cache.setCachedCommand(nextCommand.getKey(),nextCommand);
					this.sendToFlash(-1,nextCommand);
					logger.log (Level.FINER,"Sending dynalite linked command " + " for " + nextCommand.getDisplayName());
				}
			}
		}

	}

	DynaliteInputDevice findIRDevice ( int box, int channel){
		return findInputDevice (DynaliteHelper.IR,box,channel);
	}

	DynaliteInputDevice findButton ( int box, int channel){
		return findInputDevice (DynaliteHelper.Button,box,channel);
	}

	DynaliteInputDevice findInputDevice (char code, int box, int channel){
		DynaliteInputDevice result = null;
		try {
			String theKey = dynaliteHelper.buildKey(code,box,channel);
			result = (DynaliteInputDevice)configHelper.getControlledItem(theKey);
			return result;
		} catch (ClassCastException ex){
			logger.log(Level.WARNING,"A incorrect device was added to the dynalite control block " + ((DeviceType)result).getName());
			return null;
		}
	}

	DynaliteDevice findSingleDevice (char code,int areaKey, int channel,boolean origin0){
		DynaliteDevice result = null;
		try {
			if (origin0){
				result = (DynaliteDevice)configHelper.getControlledItem(dynaliteHelper.buildKey(code,areaKey,channel+1));
			} else {
				result = (DynaliteDevice)configHelper.getControlledItem(dynaliteHelper.buildKey(code,areaKey,channel));				
			}
			return result;
		} catch (ClassCastException ex){
			logger.log(Level.WARNING,"A incorrect device was added to the dynalite control block " + ((DeviceType)result).getName());
			return null;
		}
	}
	
	void interpretIR (InterpretResult result,byte msg[] ) {
		CommandInterface dynResult = null;
		// IR
		int irNumber = msg[4];
		int irBox = msg[2];
		if (msg[6] == 0) {
			DynaliteInputDevice irDevice = this.findIRDevice(irBox,irNumber);
			if (irDevice != null) {
				dynResult = buildCommandForFlash ((DeviceType)irDevice,"off",0,0,255,this.currentUser);
				result.decoded.add(dynResult);
			}
		}
		else {
			DynaliteInputDevice irDevice = this.findIRDevice(irBox,irNumber);
			if (irDevice != null) {
				dynResult= buildCommandForFlash ((DeviceType)irDevice,"on",100,0,255,this.currentUser);
				result.decoded.add(dynResult);
			}
		}
	}

	void interpretLinearPreset (InterpretResult result,byte msg[] ) {
		CommandInterface
		dynResult = null;
		// Switch
		int presetNumber = msg[2];
		int area = msg[1];

		DynaliteDevice areaDevice = this.findSingleDevice(DynaliteHelper.Light,area, 0, false);
		if (areaDevice != null) {
			dynResult = buildCommandForFlash ((DeviceType)areaDevice,"preset",presetNumber+1,0,255,this.currentUser);
			result.decoded.add(dynResult);
			result.setRescanLevels(true);
			result.setRescanArea ((byte)area);
		}
	}
	
	void interpretSwitch (InterpretResult result,byte msg[] ) {
		CommandInterface
		dynResult = null;
		// Switch
		int buttonNumber = msg[4];
		int switchKey = msg[2];
		if (msg[6] == 0) {
			DynaliteInputDevice switchDevice = this.findButton(switchKey,buttonNumber);
			if (switchDevice != null) {
				dynResult = buildCommandForFlash ((DeviceType)switchDevice,"off",0,0,255,this.currentUser);
				result.decoded.add(dynResult);
			}
		}
		else {
			DynaliteInputDevice switchDevice = this.findButton(switchKey,buttonNumber);
			if (switchDevice != null) {
				dynResult = buildCommandForFlash ((DeviceType)switchDevice,"on",100,0,255,this.currentUser);
				result.decoded.add(dynResult);
			}
		}
	}

	void interpretClassicAreaLevel (InterpretResult result, byte msg[]) {
		// Fade channel or area to level
		CommandInterface dynResult = null;
		int level = dynaliteHelper.scaleLevelForFlash(msg[2]);
		int area = msg[1];
		int rate = (int)((msg[5] * 256 + msg[4]) * 0.02);
		DynaliteDevice dev = null;
		String commandStr;
		if (level == 0) {
			commandStr = "off"; 
		} else { 
			commandStr = "on";
		}
		
		List devList = areaCodes.findDevicesInArea(area,true,msg[6]);
		Iterator eachDev = devList.iterator();
		while (eachDev.hasNext()){
			dev = (DynaliteDevice)eachDev.next();
			dynResult = buildCommandForFlash ((DeviceType)dev,commandStr,level,rate,msg[6],this.currentUser);			
			result.decoded.add(dynResult);
			addJoinedDeviceUpdates (result,(DynaliteDevice)dev,"on",level,"0",Byte.toString(msg[6]));
		}
	}

	void interpretClassicPresetOffset (InterpretResult result,byte msg[]) {
		// Fade channel or area to level
		CommandInterface dynResult = null;
		byte area = msg[1];
		byte offset = (byte)(msg[2] & 0xf);
		this.setOffset(area,offset);
		DynaliteDevice dev = this.findSingleDevice(DynaliteHelper.Light,area,0,false);
		if (dev != null) {
			dynResult = buildCommandForFlash ((DeviceType)dev,"offset",offset,-1,msg[6],this.currentUser);
			result.decoded.add(dynResult);
		}
	}
	
	
	void setOffset (byte area, byte offset) {
		String key = Byte.toString(area);
		this.areaOffset.put(key,new Byte(offset));
	}
	
	byte getOffset (byte area) {
		String key = Byte.toString(area);
		Byte offset = (Byte)this.areaOffset.get(key);
		return offset.byteValue();
	}
	
	void interpretClassicPreset (InterpretResult result, byte msg[]) {
			CommandInterface dynResult = null;
			int area = msg[1];
			int presetBase = msg[4];
			int presetOffset = 0;
			if (msg[3] < 4) presetOffset = msg[3];
			if (msg[3] >= 10) presetOffset = msg[3] - 6;
			int presetNumber = 0;
			switch (presetBase){
				case 0x00:
					presetNumber = 1 + presetOffset;
					break;
					
				case 0x01:
					presetNumber = 9 + presetOffset;
					break;

				case 0x02:
					presetNumber = 17 + presetOffset;
					break;
					
				case 0x03:
					presetNumber = 25 + presetOffset;
					break;
					
				default:
					result.isError = true;
					result.errorMessage =  "Received a dynalite classic preset message with an invalid bank " + msg[5];
					return;
			}
			
			DynaliteDevice dev = null;

						
			dev = findSingleDevice (DynaliteHelper.Light,area,0,false);
			if (dev != null){
				dynResult = buildCommandForFlash ((DeviceType)dev,"preset",presetNumber,0,255,this.currentUser);		
				result.decoded.add(dynResult);
				result.setRescanLevels(true);
				result.setRescanArea((byte)area);
			}
	}
	
	public void interpretClassicChannelLevel (InterpretResult result, byte msg[]) {
		// Fade channel or area to level , 1c is classic, others linear
			CommandInterface dynResult = null;
			int level = dynaliteHelper.scaleLevelForFlash(msg[2]);
			byte area = msg[1];
			byte channelBase = msg[4];
			byte channelOffset = (byte)((msg[3] & 0xff) - 0x80);
			int channel = 0;
			int rate = (int)(msg[5] * 0.02);
			switch (channelBase){
				case (byte)0xff:
					channel = 1 + channelOffset;
					break;
					
				case 0x00:
					channel = 5 + channelOffset;
					break;

				case 0x01:
					channel = 9 + channelOffset;
					break;
					
				case 0x02:
					channel = (13 + channelOffset);
					break;
					
				default:
					result.isError = true;
					result.errorMessage =  "Received a dynalite classic channel message with an invalid offset " + msg[4];
					return;
			}
			
			DynaliteDevice dev = null;
			String commandStr;
			if (level == 0) {
				commandStr = "off"; 
			} else { 
				commandStr = "on";
			}
						
			dev = findSingleDevice (DynaliteHelper.Light,area,channel,false);
			if (dev != null){
				dynResult = buildCommandForFlash ((DeviceType)dev,commandStr,level,rate,msg[6],this.currentUser);		
				result.decoded.add(dynResult);
				addJoinedDeviceUpdates (result,(DynaliteDevice)dev,"on",level,"0",Byte.toString(msg[6]));
			}
	}
	
	
	public void interpretFadeChannelOrArea (InterpretResult result, byte msg[]) {
		// Fade channel or area to level , 1c is classic, others linear
			CommandInterface dynResult = null;
			int level = dynaliteHelper.scaleLevelForFlash(msg[4]);
			int channel = msg[2];
			int area = msg[1];
			DynaliteDevice dev = null;
			int rate = 0;
			switch (msg[3]){
				case 0x71:
					rate = (int)(msg[5] * 0.1);
					break;
				case 0x72:
					rate = (int)(msg[5]);
					break;
				case 0x73:
					rate = (int)(msg[5]*60);
					break;

			}
			if (channel == 0xff){
				List devList = areaCodes.findDevicesInArea(area,true,msg[6]);
				Iterator eachDev = devList.iterator();
				while (eachDev.hasNext()){
					dev = (DynaliteDevice)eachDev.next();
					dynResult = buildCommandForFlash ((DeviceType)dev,"on",level,rate,msg[6],this.currentUser);			
					result.decoded.add(dynResult);
					addJoinedDeviceUpdates (result,(DynaliteDevice)dev,"on",level,"0",Byte.toString(msg[6]));
				}
				
			} else {
				dev = findSingleDevice (DynaliteHelper.Light,area,channel,true);
				if (dev != null){
					dynResult = buildCommandForFlash ((DeviceType)dev,"on",level,rate,msg[6],this.currentUser);		
					result.decoded.add(dynResult);
					addJoinedDeviceUpdates (result,(DynaliteDevice)dev,"on",level,"0",Byte.toString(msg[6]));
				}
			}
	}
	
	public void interpretRampStop (InterpretResult result, byte msg[]) {
	// Fade channel or area to level , 1c is classic, others linear
		CommandInterface dynResult = null;
		int level = dynaliteHelper.scaleLevelForFlash(msg[4]);
		byte channel = msg[2];
		byte area = msg[1];
		DynaliteDevice dev = null;
		if (channel == (byte)0xff){
			result.setRescanLevels(true);
			result.setRescanArea(area);
		} else {
			result.setRescanSingleChannel(true);
			result.setRescanArea(area);
			result.setRescanChannel(channel);
		}
	}

	public void interpretRampUp (InterpretResult result, byte msg[]) {
	// Fade channel or area to level , 1c is classic, others linear
		CommandInterface dynResult = null;
		int level = 100;
		byte channel = msg[2];
		byte area = msg[1];
		DynaliteDevice dev = null;
		if (channel == (byte)0xff){
			List devList = areaCodes.findDevicesInArea(area,true,msg[6]);
			Iterator eachDev = devList.iterator();
			while (eachDev.hasNext()){
				dev = (DynaliteDevice)eachDev.next();
				dynResult = buildCommandForFlash ((DeviceType)dev,"on",level,0,msg[6],this.currentUser);			
				result.decoded.add(dynResult);
				addJoinedDeviceUpdates (result,(DynaliteDevice)dev,"on",level,"0",Byte.toString(msg[6]));
			}
			
		} else {
			dev = findSingleDevice (DynaliteHelper.Light,area,channel,true);
			if (dev != null){
				dynResult = buildCommandForFlash ((DeviceType)dev,"on",level,0,msg[6],this.currentUser);		
				result.decoded.add(dynResult);
				addJoinedDeviceUpdates (result,(DynaliteDevice)dev,"on",level,"0",Byte.toString(msg[6]));
			}
		}
	}

	
	public void interpretRampDown (InterpretResult result, byte msg[]) {
		// Fade channel or area to level , 1c is classic, others linear
			CommandInterface dynResult = null;
			int level = 0;
			byte channel = msg[2];
			byte area = msg[1];
			DynaliteDevice dev = null;
			if (channel == 0xff){
				List devList = areaCodes.findDevicesInArea(area,true,msg[6]);
				Iterator eachDev = devList.iterator();
				while (eachDev.hasNext()){
					dev = (DynaliteDevice)eachDev.next();
					dynResult = buildCommandForFlash ((DeviceType)dev,"off",level,0,255,this.currentUser);			
					result.decoded.add(dynResult);
					addJoinedDeviceUpdates (result,(DynaliteDevice)dev,"off",0,"0",Byte.toString(msg[6]));
				}
				
			} else {
				dev = findSingleDevice (DynaliteHelper.Light,area,channel,true);
				if (dev != null){
					dynResult = buildCommandForFlash ((DeviceType)dev,"off",level,0,255,this.currentUser);		
					result.decoded.add(dynResult);
					addJoinedDeviceUpdates (result,(DynaliteDevice)dev,"off",0,"0",Byte.toString(msg[6]));
				}
			}
		}

	public void interpretAreaOff (InterpretResult result, byte msg[])
	// Area off, not often used, instead preset 4 is usually used
	{
		CommandInterface dynResult = null;
		int area = msg[1];
		DynaliteDevice dev = null;
		int rate = (int)((msg[4] * 256 + msg[2]) * .02);
		// CC complete
		
		List devList = areaCodes.findDevicesInArea(area,true,msg[6]);
		Iterator eachDev = devList.iterator();
		while (eachDev.hasNext()){
			dev = (DynaliteDevice)eachDev.next();
			dynResult = buildCommandForFlash ((DeviceType)dev,"off",0,rate,255,this.currentUser);		
			result.decoded.add(dynResult);
		}
	}

	void interpretPanicOn (InterpretResult result, byte msg[])
	// Area off, not often used, instead preset 4 is usually used
	{
		CommandInterface dynResult = null;
		byte area = msg[1];
		DeviceType dev = (DeviceType)configHelper.getControlledItem("ALARM");
		if (dev != null ) {
			DynaliteDevice areaDev = this.findSingleDevice(DynaliteHelper.Light,area,0,false);
			String areaName = "";
			if (areaDev != null) {
				areaName = areaDev.getOutputKey();
			} else {
				areaName = Byte.toString(area);
			}
			alarmLogging.addAlarmLog(dev.getKey(), "Panic Triggered for Area " + areaName, 
					AlarmLogging.PANIC, 
					areaName, "0", this.currentUser, new Date());

			result.decoded.add(dynResult);
			result.setRescanLevels(true);
			result.setRescanArea(area);
		}
	}

	void interpretPanicOff (InterpretResult result, byte msg[])
	// Area off, not often used, instead preset 4 is usually used
	{
		CommandInterface dynResult = null;
		byte area = msg[1];
		DeviceType dev = (DeviceType)configHelper.getControlledItem("ALARM");
		if (dev != null ) {
			DynaliteDevice areaDev = this.findSingleDevice(DynaliteHelper.Light,area,0,false);
			String areaName = "";
			if (areaDev != null) {
				areaName = areaDev.getOutputKey();
			} else {
				areaName = Byte.toString(area);
			}
			alarmLogging.addAlarmLog(dev.getKey(), "Panic Released for Area " + areaName, 
					AlarmLogging.PANIC_RELEASED, 
					areaName, "0", this.currentUser, new Date());
			result.decoded.add(dynResult);
			result.setRescanLevels(true);
			result.setRescanArea(area);
		}
	}

	void interpretLink (InterpretResult result, byte msg[])
	{
		byte area = msg[1];
		
		DynaliteDevice areaDev = this.findSingleDevice(DynaliteHelper.Light,area,0,false);
		if (areaDev != null) {
			decodeLinkByte (result,msg[2],msg[7],0,areaDev,true);
			decodeLinkByte (result,msg[4],msg[7],1,areaDev,true);
			decodeLinkByte (result,msg[5],msg[7],2,areaDev,true);
			
		}
	}

	void interpretUnLink (InterpretResult result, byte msg[])
	{
		byte area = msg[1];
		
		DynaliteDevice areaDev = this.findSingleDevice(DynaliteHelper.Light,area,0,false);
		if (areaDev != null) {
			decodeLinkByte (result,msg[2],msg[7],0,areaDev,false);
			decodeLinkByte (result,msg[4],msg[7],1,areaDev,false);
			decodeLinkByte (result,msg[5],msg[7],2,areaDev,false);
			
		}
	}

	void decodeLinkByte (InterpretResult result,byte theByte, byte join, int byteNumber,DynaliteDevice dev, boolean linkOrUnlink){
		String linkCommand = "unlink";
		if (linkOrUnlink)  linkCommand = "link";
		
		for (int i = 0; i < 8 ; i ++){
			if ((theByte | 2 ^ i) != 0){
				int linkToNumber = i + 1 + byteNumber * 8; 
				CommandInterface dynResult = buildCommandForFlash ((DeviceType)dev,linkCommand,linkToNumber,0,join,this.currentUser);		
				result.decoded.add(dynResult);
				if (linkOrUnlink) {
					areaCodes.addJoin(dev.getKey(), linkToNumber);
				}
				else {
					areaCodes.removeJoin(dev.getKey(), linkToNumber);					
				}
			}			
		}		
	}
	
	void interpretChannelLevel (InterpretResult result, byte msg[])
	{
		CommandInterface dynResult = null;
		int area = msg[1];
		DynaliteDevice lightDev = this.findSingleDevice(DynaliteHelper.Light,area,msg[2],true);
		if (lightDev != null) {
			int level = dynaliteHelper.scaleLevelForFlash(msg[4]);
			if (msg[4] == (byte)255 || level == 0){
				dynResult = buildCommandForFlash ((DeviceType)lightDev,"off",0,0,msg[6],this.currentUser);		
				result.decoded.add(dynResult);
				addJoinedDeviceUpdates (result,lightDev,"off",0,"0",Byte.toString(msg[6]));

			} else {
				dynResult = buildCommandForFlash ((DeviceType)lightDev,"on",level,0,msg[6],this.currentUser);		
				result.decoded.add(dynResult);
				addJoinedDeviceUpdates (result,lightDev,"on",level,"0",Byte.toString(msg[6]));
			}
		}
		// 28, 2, 1, 96, -4, -1, -1, -121, 0 comes from visibly off light
		// Interpret
		// 1 = area; 2 = channel ; 3 = 0x60; 4 = target, 5 = current
		
		// request level
		// 1 = area; 2 = channel ; 3 = 0x61; 4 = 00, 5 = 00
	}

	InterpretResult interperetDynaliteCode (byte msg[]) throws CommsFail {
		byte oppCode = msg[3];

		InterpretResult result = new InterpretResult();
		
		switch (oppCode){
			case (byte)0x60:
				interpretChannelLevel (result,msg);
				comms.acknowlegeCommand(DynaliteCommand.REQUEST_LEVEL,result.getFullKey());
				comms.sendNextCommand(DynaliteCommand.REQUEST_LEVEL);
				// process preset return value
				break;
			case (byte)0x49:
				interpretIR (result,msg);
				break;

			case (byte)0x76: 
				interpretRampStop (result,msg);
				break;

			case (byte)0x79: 
				interpretClassicAreaLevel(result,msg);
				break;

			case (byte)0x80: case (byte)0x81: case (byte)0x82: case (byte)0x83: 
				interpretClassicChannelLevel(result,msg);
				break;

			case (byte)0x43: 
				interpretSwitch (result,msg);
				break;
				
			case (byte)0x64: 
				this.interpretClassicPresetOffset(result,msg);
				break;

			case (byte)0x65: 
				interpretLinearPreset (result,msg);
				break;
				
			case (byte)0x68:
				this.interpretRampUp(result,msg);
				break;

			case (byte)0x69:
				this.interpretRampDown(result,msg);
				break;

			case 0x0: case 0x1: case 0x2: case 0x3: case 0xa:  case 0xb:  case 0xc:  case 0xd:
				interpretClassicPreset (result,msg);
				break;
			
			case (byte)0x71: case (byte)0x72: case (byte)0x73: case (byte)0x1c:
				interpretFadeChannelOrArea (result,msg);
				break;
	
			case 0x04:
				interpretAreaOff (result,msg);
				// Area off, not often used, instead preset 4 is usually used
				break;
				
			case 0x17:
				interpretPanicOn (result,msg);
				break;
				
			case 0x18:
				interpretPanicOff (result,msg);
				break;

			case 0x20:
				interpretLink (result,msg);
				break;
				
			case 0x21:
				interpretUnLink (result,msg);
				break;
		}
		return result;
	}
	

	CommandInterface buildCommandForFlash (DeviceType dynaliteDevice,String command,int level, int rate, int join,User currentUser){
		if (dynaliteDevice == null) {
			return null;
		} else {
			CommandInterface dynaliteCommand = (CommandInterface)(dynaliteDevice.buildDisplayCommand ());
			dynaliteCommand.setCommand (command);
			dynaliteCommand.setExtraInfo(Integer.toString(level & 255));
			if (rate < 0)
				dynaliteCommand.setExtra2Info("");
			else
				dynaliteCommand.setExtra2Info(Integer.toString(rate));
			dynaliteCommand.setExtra3Info(Integer.toString(join & 255));
			dynaliteCommand.setKey ("CLIENT_SEND");
			dynaliteCommand.setUser(currentUser);
			return dynaliteCommand;
		}
	}
	
		
	CommandInterface buildCommandForFlash (DeviceType dynaliteDevice,String command,String extra, String extra2, String extra3,User currentUser){
		if (dynaliteDevice == null) {
			return null;
		} else {
			CommandInterface dynaliteCommand = (CommandInterface)(dynaliteDevice.buildDisplayCommand ());
			dynaliteCommand.setCommand (command);
			dynaliteCommand.setExtraInfo(extra);
			dynaliteCommand.setExtra2Info(extra2);
			dynaliteCommand.setExtra3Info(extra3);
			dynaliteCommand.setKey ("CLIENT_SEND");
			dynaliteCommand.setUser(currentUser);
			return dynaliteCommand;
		}
	}
	
	
	DynaliteOutput buildDynaliteResult (DynaliteDevice device, CommandInterface command)  {
		DynaliteOutput dynaliteReturn = new DynaliteOutput ();
		boolean commandFound = false;

		String rawBuiltCommand = configHelper.doRawIfPresent (command, (DeviceType)device);
		if (rawBuiltCommand != null)
		{
			dynaliteReturn.outputCodes = rawBuiltCommand.getBytes();
			commandFound = true;
		}
		String theCommand = command.getCommandCode();
		if (!commandFound && theCommand == "") {
			logger.log(Level.WARNING, "Empty command received from client "+ command.getCommandCode());
			return null;
		}

		if (theCommand.equals("preset") ) {
			String presetNumber = command.getExtraInfo();
			DynaliteOutput result = new DynaliteOutput();
			byte join = dynaliteHelper.findJoin (command.getExtra3Info(),result);

			if (this.protocol == DynaliteDevice.Linear) {
				 dynaliteReturn =buildDynaliteLinearPresetCommand ( device.getKey(), 
						 presetNumber,command.getExtra2Info(),join);
			}
			else {
				 dynaliteReturn =buildDynaliteClassicPresetCommand ( device.getKey(),
						 presetNumber,command.getExtra2Info(),join);				
			}
			try {
				dynaliteReturn.setRescanArea(Integer.parseInt(device.getKey(),16));
				dynaliteReturn.setRescanLevels(true);
			} catch (NumberFormatException ex){
				logger.log (Level.WARNING,"A Dynalight device was configured with an invalid area number " + ex.getMessage());
			}
			//if (presetNumber.equals("4")) {
				
			//} else {

			//}
			//@TODO if preset = 4, and standard config, send off to client, otherwise scan for levels
			
			commandFound = true;
		}
		
		if (theCommand.equals("offset") ) {
			String offsetNumber = command.getExtraInfo();
			DynaliteOutput result = new DynaliteOutput();
			byte join = dynaliteHelper.findJoin (command.getExtra3Info(),result);

			 dynaliteReturn = buildDynalitePresetOffsetCommand ( device.getKey(),
					 offsetNumber,join);							
			commandFound = true;
		}
		
		if (theCommand.equals("on") ) {
			try {
				int level = 0;
				String levelStr = command.getExtraInfo();
				if (levelStr.equals("")){
					level = 1;
				} else {
					level = dynaliteHelper.scaleLevelFromFlash(levelStr);
				}
				if (device.isAreaDevice()) {
					try {
						dynaliteReturn =buildDynaliteRampToCommand ( device.getKey(), "0",
								level,command.getExtra2Info(),command.getExtra3Info());
						dynaliteReturn.setRescanArea(Integer.parseInt(device.getKey(),16));
						dynaliteReturn.setRescanLevels(true);
					} catch (NumberFormatException ex){
						logger.log (Level.WARNING,"A Dynalight device was configured with an invalid area number " + ex.getMessage());
					}
				} else {
					dynaliteReturn =buildDynaliteRampToCommand ( device.getAreaCode(), device.getKey(),
							level,command.getExtra2Info(),command.getExtra3Info());
					addJoinedDeviceUpdates (dynaliteReturn,device,"on",level,command.getExtra2Info(),command.getExtra3Info());
				}

			} catch (NumberFormatException ex){
				logger.log (Level.WARNING,"Level string for Dynalite is not numeric " + command.getExtraInfo());
			}
			commandFound = true;
		}

		if (theCommand.equals("off") ) {

			 int level = 255;

			 if (device.isAreaDevice()) {
					try {
						 dynaliteReturn =buildDynaliteRampToCommand ( device.getKey(),"0",
									level,command.getExtra2Info(),command.getExtra3Info());
						dynaliteReturn.setRescanArea(Integer.parseInt(device.getKey(),16));
						dynaliteReturn.setRescanLevels(true);
					} catch (NumberFormatException ex){
						logger.log (Level.WARNING,"A Dynalight device was configured with an invalid area number " + ex.getMessage());
					}
			 } else {
				 dynaliteReturn =buildDynaliteRampToCommand ( device.getAreaCode(), device.getKey(),
							level,command.getExtra2Info(),command.getExtra3Info());
				addJoinedDeviceUpdates (dynaliteReturn,device,"off",0,command.getExtra2Info(),command.getExtra3Info());
			 }
			commandFound = true;
		}

		if (theCommand.equals("link") ) {
			 if (device.isAreaDevice()) {
					dynaliteReturn =buildLinkToCommand ( device.getKey(),command.getExtraInfo(),command.getExtra3Info(),true);
			 }
			commandFound = true;
		}
		if (theCommand.equals("unlink") ) {
			 if (device.isAreaDevice()) {
					dynaliteReturn =buildLinkToCommand ( device.getKey(),command.getExtraInfo(),command.getExtra3Info(),false);
			 }
			commandFound = true;
		}

		if (commandFound && dynaliteReturn != null) {
			return dynaliteReturn;
		}
		else {
			return null;

		}
	}
	
	void addJoinedDeviceUpdates (GeneralDynaliteResult dynaliteReturn,
			DynaliteDevice device,String command,int level,String rate,String join){

		List devices = areaCodes.getAllEquivalentDevices(device);
		if (devices != null) {
			Iterator eachLinkedDevice = devices.iterator();
			while (eachLinkedDevice.hasNext()){
				Object nextDevice = eachLinkedDevice.next();
				CommandInterface linkedCommand = buildCommandForFlash ((DeviceType)nextDevice,command,Integer.toString(level),
						rate,join,this.currentUser);
				dynaliteReturn.addLinkedDeviceCommand(linkedCommand);
			}
		}
	}

	
	DynaliteOutput buildLinkToCommand ( String areaCodeStr, String blaOffsetStr, String joinStr, boolean linkOrUnlink) {
		
		DynaliteOutput returnVal = new DynaliteOutput();
		 
		try {
			
			byte areaVal = Byte.parseByte(areaCodeStr,16); 
			byte linkTo = Byte.parseByte(blaOffsetStr);
			byte join = dynaliteHelper.findJoin(joinStr,returnVal);
			if (linkOrUnlink) {
				this.areaCodes.addJoin (areaCodeStr, blaOffsetStr);
			} else {
				this.areaCodes.removeJoin(areaCodeStr, blaOffsetStr);				
			}
			if (linkTo >= 1 && linkTo <= 8 ) {
				returnVal.outputCodes[2] = (byte)(128 >> (linkTo -1));	
			} else {
				returnVal.outputCodes[2] = 0;
			}
			if (linkTo >= 9 && linkTo <= 16 ) {
				returnVal.outputCodes[4] = (byte)(128 >> (linkTo -9));	
			} else {
				returnVal.outputCodes[4] = 0;
			}
			if (linkTo >= 17 && linkTo <= 24 ) {
				returnVal.outputCodes[5] = (byte)(128 >> (linkTo -17));	
			} else {
				returnVal.outputCodes[5] = 0;
			}	
			if (linkTo > 24) {
				logger.log(Level.WARNING,"Dynalite link instructions must be within 24. Area = " + blaOffsetStr);
				returnVal.isError = true;
				return returnVal;
			}
	
			returnVal.outputCodes[0] = 0x1c;
			returnVal.outputCodes[1] = areaVal;
			
			if (linkOrUnlink)
				returnVal.outputCodes[3] = (byte)0x20; // link
			else
				returnVal.outputCodes[3] = (byte)0x21; // unlink
				
			returnVal.outputCodes[6] = (byte)join;
			this.dynaliteHelper.addChecksum(returnVal.outputCodes);
		} catch (NumberFormatException ex){
			logger.log(Level.WARNING,"Device parameters have been incorrectly formatted " + ex.getMessage());
			returnVal.isError = true;
			returnVal.ex = ex;
		}
		
		return returnVal;
	}

		
				
	DynaliteOutput buildDynaliteLinearPresetCommand ( String areaCodeStr, String presetStr,
				String rateStr, byte join) {
		byte preset = 0;
		
		DynaliteOutput returnVal = new DynaliteOutput();
		
		FadeRate rate = new FadeRate (rateStr,returnVal);

		
		try {
			preset = (byte)Integer.parseInt(presetStr);
		} catch (Exception ex) {
			logger.log( Level.WARNING,"Join is not correctly formatted");
			return null;
		}


		try {
			returnVal.outputCodes[0] = 0x1c;
			int areaVal = Integer.parseInt(areaCodeStr,16);
			returnVal.outputCodes[1] = (byte)areaVal;
			returnVal.outputCodes[2] = (byte)(preset -1);
			returnVal.outputCodes[3] = (byte)0x65;
			returnVal.outputCodes[4] = rate.lowByte;
			returnVal.outputCodes[5] = rate.highByte;
			returnVal.outputCodes[6] = (byte)join;
			this.dynaliteHelper.addChecksum(returnVal.outputCodes);
		} catch (NumberFormatException ex){
			logger.log(Level.WARNING,"Device parameters have been incorrectly formatted " + ex.getMessage());
			returnVal.isError = true;
			returnVal.ex = ex;
		}
		
		return returnVal;
	}

	DynaliteOutput buildDynalitePresetOffsetCommand ( String areaCode, String presetNumber,
			byte join) {
		DynaliteOutput result = new DynaliteOutput();
		try {
			byte area = Byte.parseByte(areaCode);
			byte preset = Byte.parseByte(presetNumber);
			result.outputCodes[0] = 0x1c;
			result.outputCodes[1] = area;
			result.outputCodes[2]= (byte)(preset | (byte)0x80);
			result.outputCodes[3] = 0x64;
			result.outputCodes[4]= 0;
			result.outputCodes[5] = 0;
			result.outputCodes[6]= join;
			dynaliteHelper.addChecksum(result.outputCodes);
		} catch (NumberFormatException ex) {
			result.isError = true;
			result.ex = ex;
		}
		
		return result;
	}
	
	DynaliteOutput buildDynaliteClassicPresetCommand ( String areaCode, String presetNumber,
			String fade, byte join) {
		DynaliteOutput result = new DynaliteOutput();
		FadeRate fadeRate = new FadeRate (fade,result);
		try {
			byte area = Byte.parseByte(areaCode);
			byte preset = Byte.parseByte(presetNumber);
			byte oppCode = (byte)((preset - 1) % 8);
			if (oppCode >= 4) oppCode += 6;
			result.outputCodes[0] = 0x1c;
			result.outputCodes[1] = area;
			result.outputCodes[3] = oppCode;
			result.outputCodes[2]= fadeRate.lowByte;
			result.outputCodes[4]= fadeRate.highByte;
			result.outputCodes[5] = (byte)((preset - 1 ) / 8);
			result.outputCodes[6]= join;
			dynaliteHelper.addChecksum(result.outputCodes);
		} catch (NumberFormatException ex) {
			result.isError = true;
			result.ex = ex;
		}
		
		return result;
	}
	
	DynaliteOutput buildDynaliteLevelRequestCommand (String areaCodeStr,  int channelNumber,String key, int join) {
		DynaliteOutput returnVal = new DynaliteOutput();
		try {
			returnVal.outputCodes[0] = 0x1c;
			int areaVal = Integer.parseInt(areaCodeStr,16);
			returnVal.outputCodes[1] = (byte)areaVal;
			returnVal.outputCodes[2] = (byte)(channelNumber - 1);
			returnVal.outputCodes[3] = (byte)0x61;
			returnVal.outputCodes[4] = 0;
			returnVal.outputCodes[5] = 0;
			returnVal.outputCodes[6] = (byte)join;
			this.dynaliteHelper.addChecksum(returnVal.outputCodes);
		} catch (NumberFormatException ex){
			logger.log(Level.WARNING,"Device parameters have been incorrectly formatted " + ex.getMessage());
			returnVal.isError = true;
			returnVal.ex = ex;
		}
		
		return returnVal;
	}
	
	DynaliteOutput buildDynaliteLinkRequestCommand (String areaCodeStr, String key, int join) {
		DynaliteOutput returnVal = new DynaliteOutput();
		try {
			returnVal.outputCodes[0] = 0x1c;
			int areaVal = Integer.parseInt(areaCodeStr,16);
			returnVal.outputCodes[1] = (byte)areaVal;
			returnVal.outputCodes[2] = 0;
			returnVal.outputCodes[3] = (byte)0x23;
			returnVal.outputCodes[4] = 0;
			returnVal.outputCodes[5] = 0;
			returnVal.outputCodes[6] = (byte)join;
			this.dynaliteHelper.addChecksum(returnVal.outputCodes);
		} catch (NumberFormatException ex){
			logger.log(Level.WARNING,"Device parameters have been incorrectly formatted " + ex.getMessage());
			returnVal.isError = true;
			returnVal.ex = ex;
		}
		
		return returnVal;
	}
	
	DynaliteOutput buildDynaliteRampToCommand (String areaStr, String channelStr,  int level, String rateStr,String joinStr)  {
		DynaliteOutput dynaliteOutput = new DynaliteOutput();
		int area;
		int channel;
		
		try {
			area = Integer.parseInt(areaStr,16);
		} catch (Exception ex) {
			logger.log( Level.WARNING,"Area is not correctly formatted " + ex.getMessage());
			return null;
		}
		
		try {
			channel = Integer.parseInt(channelStr,16);
		} catch (Exception ex) {
			logger.log( Level.WARNING,"Channel is not correctly formatted " + ex.getMessage());
			return null;
		}
		
		byte join = dynaliteHelper.findJoin (joinStr,dynaliteOutput);
		
		FadeRate rate = new FadeRate (rateStr,dynaliteOutput);
		
		if (this.protocol == DynaliteDevice.Classic) {
			
			if (channel == 0){
				// Area
				dynaliteOutput.outputCodes[0] = 0x1c;
				dynaliteOutput.outputCodes[1] = (byte)area;
				dynaliteOutput.outputCodes[2] = (byte)level;
				dynaliteOutput.outputCodes[3] = (byte)0x79;
				dynaliteOutput.outputCodes[4] = rate.lowByte;
				dynaliteOutput.outputCodes[5] = rate.highByte;
				dynaliteOutput.outputCodes[6] = join;
				dynaliteOutput.isArea = true;
			} else {
				// Channel
				byte opCode = (byte)(0x80 + ((channel - 1) % 4));
				byte offset = (byte)(((channel - 1) / 4) - 1);
				dynaliteOutput.outputCodes[0] = 0x1c;
				dynaliteOutput.outputCodes[1] = (byte)area;
				dynaliteOutput.outputCodes[2] = (byte)level;
				dynaliteOutput.outputCodes[3] = opCode;
				dynaliteOutput.outputCodes[4] = (byte)offset;
				dynaliteOutput.outputCodes[5] = (byte)rate.lowByte;
				dynaliteOutput.outputCodes[6] = join;		

			}			
		} else {
				
			if (channel != 0){
				// Channel
				dynaliteOutput.outputCodes[0] = 0x1c;
				dynaliteOutput.outputCodes[1] = (byte)area;
				dynaliteOutput.outputCodes[2] = (byte)(channel-1);
				dynaliteOutput.outputCodes[3] = rate.linearInstr;
				dynaliteOutput.outputCodes[4] = (byte)level;
				dynaliteOutput.outputCodes[5] = rate.linearFadeRate;
				dynaliteOutput.outputCodes[6] = join;
			} else {
				// Area
				dynaliteOutput.outputCodes[0] = 0x1c;
				dynaliteOutput.outputCodes[1] = (byte)area;
				dynaliteOutput.outputCodes[2] = (byte)255;
				dynaliteOutput.outputCodes[3] = rate.linearInstr;
				dynaliteOutput.outputCodes[4] = (byte)level;
				dynaliteOutput.outputCodes[5] = rate.linearFadeRate;
				dynaliteOutput.outputCodes[6] = join;		
				dynaliteOutput.isArea = true;
			}
		}
		
		this.dynaliteHelper.addChecksum((dynaliteOutput.outputCodes));
 		return dynaliteOutput;
	}


	public void setAllArea (byte area,String levelStr){
		
	}

	public boolean doIPHeartbeat () {
	    return false;
	}

	public DynaliteHelper getDynaliteHelper() {
		return dynaliteHelper;
	}
	
	public void setDynaliteHelper(DynaliteHelper dynaliteHelper) {
		this.dynaliteHelper = dynaliteHelper;
	}

	public int getProtocol() {
		return protocol;
	}

	public void setProtocol(int protocol) {
		this.protocol = protocol;
	}

}
