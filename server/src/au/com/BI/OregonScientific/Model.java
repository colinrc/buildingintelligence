/*
 * Created on Jan 25, 2004
 *
*/
package au.com.BI.OregonScientific;

/**
 * @author Colin Canfield
 * @author Explorative Sofwtare Pty Ltd
 *
*/

import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Util.*;

import java.util.*;
import java.util.regex.*;
import java.util.logging.*;


import au.com.BI.Sensors.*;

public class Model extends BaseModel implements DeviceModel {

	protected String parameter;
	protected SensorFascade deviceThatMatched;
	protected boolean matched;
	protected Matcher matcherResults;
	protected Poll pollReaders[];
	protected String STX;
	protected String ETX;
	protected Logger logger;
	protected HashMap weatherCache;

	protected int []penChars;
	protected int []etxChars;
	
	public Model () {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		pollReaders = new Poll[10];
		weatherCache = new HashMap(10);
		penChars = new int[] {0xff};
		etxChars = new int[] {0xff};
	}

    public void finishedReadingConfig () throws SetupException {
    	super.finishedReadingConfig();
		ETX = (String)this.getParameter("ETX",DeviceModel.MAIN_DEVICE_GROUP);
		STX = (String)this.getParameter("STX",DeviceModel.MAIN_DEVICE_GROUP);
		

		if (ETX == null) ETX = "";
		if (STX == null) STX = "";

	}


	public void attatchComms()
	throws ConnectionFail {

		super.setPenultimateArray(penChars);
		super.setETXArray (etxChars);
		super.attatchComms();
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

	public void addControlledItem (String name, DeviceType details, int controlType) {
		String theKey = name;
		byte secondKey = 0;

		if (details != null) {
			int deviceType = ((DeviceType)details).getDeviceType();

			if (controlType == DeviceType.MONITORED || controlType == DeviceType.INPUT) {

				try {
					secondKey = Byte.parseByte(((SensorFascade)details).getChannel(),16);
				} catch (NumberFormatException ex){
					logger.log (Level.WARNING,"Channel description for " + (((SensorFascade)details).getName()) + " should be a hex digit");
					secondKey = 0;
				}
 
                if (theKey.equals("In-Temp")) name = "0x06T" + secondKey;
                if (theKey.equals("In-Bar")) name = "0x06B" + secondKey;
                if (theKey.equals("In-Humidity")) name = "0x06H" + secondKey;
                if (theKey.equals("In-Dew-Point")) name = "x06D" + secondKey;
                if (theKey.equals("In-Bar-Tend")) name = "0x06F" + secondKey;
                if (theKey.equals("In-Sea-Lvl-Bar")) name = "0x06S" + secondKey;
 
                if (theKey.equals("Out-Temp")) name = "0x03T" + secondKey;
                if (theKey.equals("Out-Humidity")) name = "0x03H" + secondKey;
                if (theKey.equals("Out-Dew-Point")) name = "0x03D" + secondKey;
  
			    theKey = name;
			}
			configHelper.addControlledItem (theKey, details, controlType);
		}
	}

	public void doCommand (CommandInterface command) throws CommsFail
	{

		if ( configHelper.getLastCommandType() == DeviceType.OUTPUT) {
			doOutputItem (command);
		} else {
			if ( configHelper.getLastCommandType() == DeviceType.MONITORED) {
				byte message[] = null;
				if (!command.isCommsCommand()) return;
				try { 
					message = ((CommsCommand)command).getCommandBytes();
					if (message == null) return;
				} catch (ClassCastException ex){
					logger.log (Level.WARNING,"Oregen received a command that reported to be comms but is not.");
				}

				if (message.length < 7){
					logger.log(Level.WARNING,"Weather station returned an invalid string");
					return;					
				}
				doInputItem (command, message);
			}
		}
	}

	public void doOutputItem (CommandInterface command) throws CommsFail {
		String theWholeKey = command.getKey();
		ArrayList deviceList = (ArrayList)configHelper.getOutputItem(theWholeKey);

		if (deviceList == null) {
			logger.log(Level.SEVERE, "Error in config, no output key for " + theWholeKey);
		}
		else {
			Iterator devices = deviceList.iterator();
			String outputRawCommand = "";
			cache.setCachedCommand(command.getKey(),command);

                        while (devices.hasNext()) {
				DeviceType device = (DeviceType)devices.next();
				logger.log(Level.FINER, "Received flash event for RAW from " + theWholeKey);

				switch (device.getDeviceType()) {
					case DeviceType.RAW_INTERFACE :
						if ((outputRawCommand = buildDirectConnectString (device,command)) != null)
							sendToSerial (STX+outputRawCommand+ETX);
						break;
				}

			}
		}
	}

	public boolean cacheDiffers(Byte key, byte value[]){
		boolean returnVal = false;
		
		if (this.weatherCache.containsKey(key)){
			if (!value.equals ((String)weatherCache.get(key))){
				returnVal = true;
				weatherCache.put(key,value);
			}
		} else {
			weatherCache.put(key,value);
			returnVal = true;
		}
		return returnVal;
	}
	
	public void doInputItem (CommandInterface command, byte message[]) throws CommsFail
	{

		try {
			byte secondKey = message[1];
	
			if (message[0] == 6 || message[0] == 5) {
				if (!cacheDiffers(new Byte(message[0]),message)) {
					return;
				}
				readIntTemp (message,message[0],secondKey);
			}
			if (message[0] == 3) {
				if (!cacheDiffers(new Byte(message[0]),message)) {
					return;
				}
				readOutTemp (message,message[0],secondKey);
			}
		}
		catch (ArrayIndexOutOfBoundsException ex){
			logger.log (Level.WARNING,"Internal temperature sensor returned an invalid string " + command.getKey());			
		}
	}
	
	//TODO write battery check routine
	public void checkBattery (byte channelString, String description) {
		if (channelString >> 4  == '4'){
			logger.log(Level.WARNING,description + " weather sensor battery is low");
		}
	}

	
	public void readOutTemp ( byte parts[],byte key, byte secondKey) throws ArrayIndexOutOfBoundsException {
		String keyName = key + "T" + secondKey; // temperature
		checkBattery(parts[1],"Out. Temperature " + secondKey);
		if (logger.isLoggable(Level.FINEST)){
			logger.log(Level.FINEST, "Received outside temperature report, channel " + Byte.toString(secondKey));
		}
	
		SensorFascade sensor = (SensorFascade)configHelper.getControlledItem(keyName);
		if (sensor != null) {
	
			String value ="";
			if ((parts[3] & 128) == 128) 
				value = "-";
			//  temperature
	
			value = Integer.toHexString(parts[3] & 15)  + Integer.toHexString(parts[2] & 240 ) + "." + Integer.toHexString(parts[2] & 15 );
			sendToFlash (sensor.getOutputKey(), "on", value);
		}
		
		keyName = key + "H" + secondKey; // humidity
		sensor = (SensorFascade)configHelper.getControlledItem(keyName);
		if (sensor != null) {
			sendToFlash (sensor.getOutputKey(), "on", Integer.toHexString(parts[4]));
		}
		
		keyName = key + "D" + secondKey; // dew point
		sensor = (SensorFascade)configHelper.getControlledItem(keyName);
		if (sensor != null) {
			sendToFlash (sensor.getOutputKey(), "on", Integer.toHexString(parts[4]));
		}
	}

	public void readIntTemp ( byte parts[],byte key, byte secondKey) throws ArrayIndexOutOfBoundsException {
		String keyName = key + "T" + secondKey; // temperature
		checkBattery(parts[1],"Int. Temperature" + secondKey);
		logger.log(Level.FINEST, "Received internal temperature report, channel " + secondKey);
	
		SensorFascade sensor = (SensorFascade)configHelper.getControlledItem(keyName);
		if (sensor != null) {
			
			String value ="";
			if ((parts[3] & 128) == 128) 
				value = "-";
			//  temperature
	
			value = Integer.toHexString(parts[3] & 15)  + Integer.toHexString(parts[2] & 240 ) + "." + Integer.toHexString(parts[2] & 15 );
			sendToFlash (sensor.getOutputKey(), "on", value);
		}
		keyName = key + "H" + secondKey; // humidity
		sensor = (SensorFascade)configHelper.getControlledItem(keyName);
		if (sensor != null) {
			sendToFlash (sensor.getOutputKey(), "on", Integer.toHexString(parts[4]));
		}
		
		keyName = key + "D" + secondKey; // dew point
		sensor = (SensorFascade)configHelper.getControlledItem(keyName);
		if (sensor != null) {
			sendToFlash (sensor.getOutputKey(), "on", Integer.toHexString(parts[5]));
		}
		
		keyName = key + "B" + secondKey; // barometric pressure
		sensor = (SensorFascade)configHelper.getControlledItem(keyName);
		int bpValue = 0;
		if (sensor != null) {
			String value = "";
			try {
				value =  Integer.toHexString(parts[7] & 1) + Integer.toHexString(parts[6]);
				bpValue = Integer.parseInt(value);
				bpValue += 600;
				sendToFlash (sensor.getOutputKey(), "on", Integer.toString(bpValue));
			} catch (NumberFormatException ex){
				logger.log (Level.WARNING,"Barometric string was not a valid hex number " + value);
			}
		}
		
		keyName = key + "F" + secondKey; // barometric tendency
		sensor = (SensorFascade)configHelper.getControlledItem(keyName);
		if (sensor != null) {
			String value = "";
			int barTend = parts[7] & 240;
			switch (barTend) {
				case 192:
					value = "clear";
					break;
				case 96:
					value = "partially cloudy";
					break;
				case 32:
					value = "cloudy";
					break;
				case 48:
					value = "rain";
					break;
			} 
			if (!value.equals("")){
				sendToFlash (sensor.getOutputKey(), "on", value);
			}
		}
		
		keyName = key + "S" + secondKey; // barometric sea level reference
		sensor = (SensorFascade)configHelper.getControlledItem(keyName);
		if (sensor != null) {
			String value = "";
			try {
				value = parts[10] + parts[9] + "." + parts[8];
				double srValue = Double.parseDouble(value);
				srValue += bpValue;
				sendToFlash (sensor.getOutputKey(), "on", Double.toString(srValue));
			} catch (NumberFormatException ex){
				logger.log (Level.WARNING,"Barometric sea level reference was not a valid hex number " + value);
			}
		}
	}


	public String buildDirectConnectString (DeviceType device, CommandInterface command){
		boolean commandFound = false;

		String rawSerialCommand = configHelper.doRawIfPresent (command, device, this);
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
