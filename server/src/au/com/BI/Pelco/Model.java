/*
 * Created on Jan 25, 2004
 *
*/
package au.com.BI.Pelco;

/**
 * @author Merik Karman
 * @author Building Intelligence Pty Ltd
 *
*/

import au.com.BI.Camera.Camera;
import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.User.User;
import au.com.BI.Util.*;

import java.util.*;
import java.util.regex.*;
import java.util.logging.*;



public class Model extends BaseModel implements DeviceModel {

	protected String parameter;
	protected boolean matched;
	protected Matcher matcherResults;
	protected String STX;
	protected String ETX;
	protected Logger logger;
	protected int protocol = ProtocolD;
	
	static final int ProtocolA = 0;
	static final int ProtocolP = 1;
	static final int ProtocolD = 2;
	static final int ProtocolG = 2;

	protected Map cameraState = null;
	
	public Model () {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		cameraState = new HashMap(10);
		setPadding(2);
	}
	public void finishedReadingConfig () throws SetupException {
		super.finishedReadingConfig();
		String protocol = (String)this.getParameterMapName("PROTOCOL", DeviceModel.MAIN_DEVICE_GROUP);
		this.setProtocol (protocol);

	}
	
	public void setProtocol(String protocolStr){
		if (protocolStr == null || protocolStr.equals (""))
			return;
		
		if (protocolStr.equals("D")) {
			protocol = ProtocolD;
		}
		if (protocolStr.equals("P")) {
			protocol = ProtocolP;
		}
		if (protocolStr.equals("G")) {
			protocol = ProtocolG;
		}
		if (protocolStr.equals("A")) {
			protocol = ProtocolA;
		}
	}
	
	public void attatchComms() 
	throws ConnectionFail {
	    if (protocol == ProtocolD) { 
			super.setTransmitMessageOnBytes(4); // tutondo only sends a single non CR terminated byte.
	    }
		super.attatchComms( );
	}
	


	public boolean doIControl (String keyName, boolean isClientCommand)
	{
		keyName = keyName.trim();
		configHelper.wholeKeyChecked(keyName);
		matched = false;

		if (configHelper.checkForOutputItem(keyName)) {
			logger.log (Level.FINER,"Flash sent command : " +keyName);
			return true;
		}
		else {
			if (isClientCommand)
				return false;
			else {
				configHelper.setLastCommandType (DeviceType.MONITORED);
				// Anything coming over the serial port I want to process
				return true;
			}
		}
	}



	public void doControlledItem (CommandInterface command) throws CommsFail
	{
		boolean didCommand=false;
		User currentUser = command.getUser();
		logger.log (Level.FINEST,"Received a Pelco ack");
		try {
			CommsCommand theCommand = (CommsCommand)command;
			byte resp[] = theCommand.getCommandBytes();
			if (resp != null) {
				if (comms.acknowlegeCommand(CommDevice.PelcoSend,makeKey(resp[1]))) {
					logger.log (Level.FINEST,"Acknowlegement was valid, sending next instruction");
					comms.sendNextCommand(CommDevice.PelcoSend,makeKey(resp[1]));
				}
			}
		} catch (ClassCastException ex){
			logger.log (Level.INFO,"An unknown command was received from the camera");
		}
	}
	
	public String makeKey (byte val) {
		String valStr = Byte.toString(val);
		if (valStr.length() ==1) {
			return "0"+valStr;
		} else {
			return valStr;
		}
	}
	
	public void doOutputItem (CommandInterface command) throws CommsFail {
		String theWholeKey = command.getKey();
		DeviceType device = configHelper.getOutputItem(theWholeKey);

		if (device == null) {
			logger.log(Level.SEVERE, "Error in config, no output key for " + theWholeKey);
		}
		else {
			String outputRawCommand = "";
			PelcoOutput  pelcoOutput = null;
			cache.setCachedCommand(command.getKey(),command);

			switch (device.getDeviceType()) {
				case DeviceType.RAW_INTERFACE :
					logger.log(Level.FINER, "Received event from flash for RAW item from " + theWholeKey);
					if ((outputRawCommand = buildDirectConnectString (device,command)) != null)
						sendToSerial (STX+outputRawCommand+ETX);
					break;
				case DeviceType.CAMERA :
					logger.log(Level.FINER, "Received event from flash for CAMERA item from " + theWholeKey);
					if ((pelcoOutput = buildCameraArray ((Camera)device,command)) != null) {
						// comms.clearCommandQueue();
						CommsCommand commsCommand = new CommsCommand ();
						commsCommand.setCommandBytes(pelcoOutput.outputCodes);
						commsCommand.setActionType(CommDevice.PelcoSend);
						commsCommand.setActionCode(device.getKey());
						commsCommand.setKeepForHandshake(false);
						commsCommand.setKey(device.getKey());
						comms.sendString(commsCommand.getCommandBytes());
					}
					break;
			}

		}
	}

	
	public void doInputItem (CommandInterface command, String parts[]) throws CommsFail
	{
	}

	public PelcoOutput buildOff (PelcoState pelcoState,byte address,String extra,String extra2) {
		PelcoOutput pelcoOutput = new PelcoOutput();
		switch (protocol){
			case ProtocolD:
					pelcoOutput = buildDCommand ((8+pelcoState.lastFarFocus+pelcoState.lastIris),
							calcByte2(pelcoState), 0, 0, address); 
					break;
	
		}
		return pelcoOutput;
	}

	public PelcoOutput buildOn (PelcoState pelcoState,byte address,String extra,String extra2) {
		boolean commandFound = false;
		PelcoOutput pelcoOutput = new PelcoOutput();
		
		String scanType;
		if (extra.equals("")) {
			if (pelcoState.lastAuto == 16)
				scanType = "auto";
			else
				scanType = "manual";
		}
		else
			scanType = extra;
		if (scanType.equals("auto")) {
			switch (protocol){
				case ProtocolD:
					pelcoOutput = buildDCommand ((128+16+8+pelcoState.lastFarFocus+pelcoState.lastIris),
							calcByte2(pelcoState), 0, 0, address); 
					pelcoState.lastAuto = 16;
					break;
			} 			

			commandFound = true;	
		}
		if (scanType.equals("manual")) {
			switch (protocol){
				case ProtocolD:
					pelcoOutput = buildDCommand ((128+8+pelcoState.lastFarFocus+pelcoState.lastIris),
							calcByte2(pelcoState), 0, 0, address); 
					pelcoState.lastAuto = 0;
					break;
				} 	

			commandFound = true;	
		}
		if (commandFound)
			return pelcoOutput;
		else 
			return null;
	}

	public PelcoOutput buildPan (PelcoState pelcoState,byte address,String extra,String extra2) {
		boolean commandFound = false;
		PelcoOutput pelcoOutput = new PelcoOutput();
	
		if (extra.equals("")) {
			logger.log(Level.WARNING,"Pan specified but no parameters given");
			return null;
		}
		byte panSpeed = 0;
		if (!extra2.equals("")){
			try {
				panSpeed = Byte.parseByte(extra2);
				if (panSpeed > 64) panSpeed = 64;
			} catch (NumberFormatException ex) {
				logger.log (Level.WARNING,"Pan speed (extra2) was not a valid digit " + extra2);
			}
		}
		pelcoState.lastPanSpeed = panSpeed;
		if (extra.equals("left")) {
			switch (protocol){
				case ProtocolD:
					pelcoState.lastPan = 4;
					pelcoOutput = buildDCommand (0,calcByte2(pelcoState),panSpeed,
							pelcoState.lastTiltSpeed, address);  
					break;
			} 			
	
			commandFound = true;	
		}
		if (!commandFound && extra.equals("right")) {
			switch (protocol){
				case ProtocolD:
					pelcoState.lastPan = 2;
					pelcoOutput = buildDCommand (0,calcByte2(pelcoState),panSpeed,
							pelcoState.lastTiltSpeed, address);  
					break;
				} 	
	
			commandFound = true;	
		}
		if (!commandFound && extra.equals("stop")) {
			switch (protocol){
				case ProtocolD:
					pelcoState.lastPan = 0;
					pelcoOutput = buildDCommand (0,calcByte2(pelcoState),panSpeed, 
							pelcoState.lastTiltSpeed, address);  
					break;
				} 	
	
			commandFound = true;	
		}
		if (!commandFound){
			try {
				int pos = Integer.parseInt(extra);
				pelcoState.lastPan = 0;
				commandFound = true;
				pelcoOutput = buildDCommand (0,0x4b,pos/256,pos%256, address);  					
			} catch (Exception ex) {
				logger.log (Level.WARNING,"Unknown parameter sent to PAN command " + extra);
			}
		}
		if (commandFound)
			return pelcoOutput;
		else 
			return null;
	}
	
	public PelcoOutput buildTilt (PelcoState pelcoState,byte address,String extra,String extra2) {
		boolean commandFound = false;
		PelcoOutput pelcoOutput = new PelcoOutput();
	
		byte tiltSpeed = 0;
		if (!extra2.equals ("")){

			try {
				tiltSpeed = Byte.parseByte(extra2);
				if (tiltSpeed > 63) tiltSpeed = 63;
			} catch (NumberFormatException ex) {
				logger.log (Level.WARNING,"Tilt speed (extra2) was not a valid digit " + extra2);
			}
		}
		pelcoState.lastTiltSpeed = tiltSpeed;
		if (extra.equals("up")) {
			switch (protocol){
				case ProtocolD:
					pelcoState.lastTilt = 8;
					pelcoOutput = buildDCommand (0,calcByte2(pelcoState),pelcoState.lastPanSpeed,
							tiltSpeed, address);  
					break;
			} 			

			commandFound = true;	
		}
		if (extra.equals("down")) {
			switch (protocol){
				case ProtocolD:
					pelcoState.lastTilt = 16;
					pelcoOutput = buildDCommand (0,calcByte2(pelcoState),pelcoState.lastPanSpeed,
							tiltSpeed, address);  
					break;
				} 	

			commandFound = true;	
		}
		if (extra.equals("stop")) {
			switch (protocol){
				case ProtocolD:
					pelcoState.lastTilt = 0;
					pelcoOutput = buildDCommand (0,calcByte2(pelcoState),pelcoState.lastPanSpeed,
							tiltSpeed, address);  
					break;
				} 	

			commandFound = true;	
		}
		if (!commandFound){
			try {
				int pos = Integer.parseInt(extra);
				pelcoState.lastTilt = 0;
				commandFound = true;
				pelcoOutput = buildDCommand (0,0x4d,pos/256,pos%256, address);  					
			} catch (Exception ex) {
				logger.log (Level.WARNING,"Unknown parameter sent to TILT command " + extra);
			}
		}

		if (commandFound)
			return pelcoOutput;
		else 
			return null;
	}
	
	public PelcoOutput buildZoom (PelcoState pelcoState,byte address,String extra,String extra2,Camera device) {
		boolean commandFound = false;
		PelcoOutput pelcoOutput = new PelcoOutput();	
		
		if (extra.equals("tele")) {
			switch (protocol){
				case ProtocolD:
					pelcoState.lastZoom = 32;
					pelcoOutput = buildDCommand (0,calcByte2(pelcoState),pelcoState.lastPanSpeed,
							pelcoState.lastTiltSpeed, address);  
					break;
			} 			

			commandFound = true;	
		}
		if (extra.equals("wide")) {
			switch (protocol){
				case ProtocolD:
					pelcoState.lastZoom = 64;
					pelcoOutput = buildDCommand (0,calcByte2(pelcoState),pelcoState.lastPanSpeed,
							pelcoState.lastTiltSpeed, address);  
					break;
				} 	

			commandFound = true;	
		}
		if (extra.equals("stop")) {
			switch (protocol){
				case ProtocolD:
					pelcoState.lastZoom = 0;
					pelcoOutput = buildDCommand (0,calcByte2(pelcoState),pelcoState.lastPanSpeed,
							pelcoState.lastTiltSpeed, address);  
					break;
				} 	

			commandFound = true;	
		}
		if (!commandFound){
			if(device.getZoomInt() == 0){
				logger.log (Level.WARNING,"Absolute zoom request received, but camera zoom capabilities were not specified in configuration");
				return null;
			}
				
			try {
				int pos = Integer.parseInt(extra);
				int scaledZoom = pos / device.getZoomInt() * 65535;
				
				pelcoState.lastZoom = 0;
				commandFound = true;
				pelcoOutput = buildDCommand (0,0x4f,scaledZoom/256,scaledZoom%256, address);  					
			} catch (Exception ex) {
				logger.log (Level.WARNING,"Unknown parameter sent to ZOOM command " + extra);
			}
		}
		if (commandFound)
			return pelcoOutput;
		else 
			return null;
	}
	
	public PelcoOutput buildFocus (PelcoState pelcoState,byte address,String extra,String extra2) {
		boolean commandFound = false;
		PelcoOutput pelcoOutput = new PelcoOutput();	
		if (extra.equals("near")) {
			switch (protocol){
				case ProtocolD:
					pelcoState.lastFarFocus = 0;
					pelcoState.lastNearFocus = 1;
					pelcoOutput = buildDCommand (0,calcByte2(pelcoState),pelcoState.lastPanSpeed,
							pelcoState.lastTiltSpeed, address);  
					break;
			} 			

			commandFound = true;	
		}
		if (extra.equals("far")) {
			switch (protocol){
				case ProtocolD:
					pelcoState.lastFarFocus = 128;
					pelcoState.lastNearFocus = 0;
					pelcoOutput = buildDCommand (0,calcByte2(pelcoState),pelcoState.lastPanSpeed,
							pelcoState.lastTiltSpeed, address);  
					break;
				} 	

			commandFound = true;	
		}
		if (extra.equals("stop")) {
			switch (protocol){
				case ProtocolD:
					pelcoState.lastFarFocus = 0;
					pelcoState.lastNearFocus = 0;
					pelcoOutput = buildDCommand (0,calcByte2(pelcoState),pelcoState.lastPanSpeed,
							pelcoState.lastTiltSpeed, address);  
					break;
				} 	

			commandFound = true;	
		}
		
		if (commandFound)
			return pelcoOutput;
		else 
			return null;
	}
	
	public PelcoOutput buildPreset (PelcoState pelcoState,byte address,String extra,String extra2) {
		boolean commandFound = false;
		PelcoOutput pelcoOutput = new PelcoOutput();	

		if (!extra.equals ("")){
			try {
				byte presetNumber = Byte.parseByte(extra2);
	
				switch (protocol){
					case ProtocolD:
						pelcoOutput = buildDCommand (0,7,0,presetNumber, address);  
						commandFound = true;	
						break;
				} 			
			} catch (NumberFormatException ex) {
				logger.log (Level.WARNING,"Preset number (extra) was not a valid digit " + extra2);
			}
		}
		
		if (commandFound)
			return pelcoOutput;
		else 
			return null;
	}
	
	
	public PelcoOutput buildCameraArray (Camera device, CommandInterface command){
		PelcoOutput pelcoOutput = null;
		boolean commandFound = false;
				
		String extra = ((String)command.getExtraInfo());
		String extra2 = ((String)command.getExtra2Info());

		byte address = 0;
		try {
			address = Byte.parseByte(device.getKey(),16);
		} catch (NumberFormatException ex) {
			logger.log (Level.WARNING,"Camera key was invalid: " + device.getKey());
			return null;
		}

		PelcoState pelcoState = (PelcoState)cameraState.get(device.getKey());
		if (pelcoState == null) pelcoState = new PelcoState();
		
		String theCommand = command.getCommandCode();

		if (theCommand.equals("")) {
			logger.log(Level.WARNING, "Empty command received from client "+ command.getCommandCode());
			return null;
		}
		if (theCommand.equals("on")) {	
			pelcoOutput = buildOn (pelcoState,address,extra,extra2);
			if (pelcoOutput != null) commandFound = true;
		}
		if (!commandFound && theCommand.equals("off")) {
			pelcoOutput = buildOff (pelcoState,address,extra,extra2);
			if (pelcoOutput != null) commandFound = true;
		}
		if (!commandFound && theCommand.equals("pan") ) {
			pelcoOutput = buildPan (pelcoState,address,extra,extra2);
			if (pelcoOutput != null) commandFound = true;
		}
		if (!commandFound && theCommand.equals("tilt")) {
			pelcoOutput = buildTilt (pelcoState,address,extra,extra2);
			if (pelcoOutput != null) commandFound = true;
		}
		if (!commandFound && theCommand.equals("zoom")) {
			pelcoOutput = buildZoom (pelcoState,address,extra,extra2,device);
			if (pelcoOutput != null) commandFound = true;
		}
		if (!commandFound && theCommand.equals("focus")) {
			pelcoOutput = buildFocus (pelcoState,address,extra,extra2);
			if (pelcoOutput != null) commandFound = true;
		}
		if (theCommand.equals("preset")) {
			pelcoOutput = buildPreset (pelcoState,address,extra,extra2);
			if (pelcoOutput != null) commandFound = true;

		}
		if (commandFound) {
			cameraState.put(device.getKey(),pelcoState);
			pelcoOutput.address = address;
			return pelcoOutput;
		} else {
			return null;
		}
	}

	public byte calcByte2 (PelcoState pelcoState){
		int total = pelcoState.lastPan|pelcoState.lastTilt| pelcoState.lastFarFocus| pelcoState.lastZoom;
		return (byte)(total);
	}

	public void addCheckSum( PelcoOutput camOut) {
		switch (protocol) {
			case ProtocolD:
				byte checksum = (byte)((camOut.outputCodes[1] + camOut.outputCodes[2] + camOut.outputCodes[3] + 
						camOut.outputCodes[4] + camOut.outputCodes[5]) % 256);
				camOut.outputCodes [6] = checksum;
				break;
				
			case ProtocolP:
				byte checksumP = (byte)(camOut.outputCodes[0] ^ camOut.outputCodes[1] ^ camOut.outputCodes[2] ^ 
						camOut.outputCodes[3] ^ camOut.outputCodes[4] ^ camOut.outputCodes[5] ^ camOut.outputCodes[6]);
				camOut.outputCodes [7] = checksumP;
				break;
		}
	}

	public PelcoOutput buildDCommand (int command1, int command2, int data1, int data2, int address) {
		PelcoOutput camOut = new PelcoOutput();
		camOut.outputCodes  [0] = (byte)0xFF;
		camOut.outputCodes  [1] = (byte)address;
		camOut.outputCodes  [2] = (byte)command1;
		camOut.outputCodes  [3] = (byte)command2;
		camOut.outputCodes  [4] = (byte)data1;
		camOut.outputCodes  [5] = (byte)data2;
		
		addCheckSum(camOut);
		return camOut;
	}
	
	public String buildDirectConnectString (DeviceType device, CommandInterface command){
		boolean commandFound = false;

		String rawSerialCommand = configHelper.doRawIfPresent (command, device);
		if (rawSerialCommand != null)
		{
			commandFound = true;
		}
		String theCommand = command.getCommandCode();
		if (!commandFound && theCommand == "") {
			logger.log(Level.WARNING, "Empty command received from client "+ command.getCommandCode());
			return null;
		}
		else {
			logger.log(Level.FINER, "Build comms string "+ rawSerialCommand);

			return rawSerialCommand;
		}
	}

}
