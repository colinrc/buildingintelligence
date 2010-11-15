/*
 * Created on Feb 16, 2005
 * @Author Colin Canfield
 */
package au.com.BI.CBUS;

import java.util.Vector;
import java.util.logging.*;

import au.com.BI.Label.Label;


/**
 * @author colinc
 *
 */
public class CBUSHelper {

	Logger logger;
	protected char STX=' ';
	protected char ETX='\r';
	protected String rampCodes = ":02:0A:12:1A:22:2A:32:3A:42:4A:52:5A:62:6A:72:7A";

	public CBUSHelper() {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
	public String buildKey (String appCode, String groupCode, int deviceType) {
		if (groupCode.length() == 1 ) groupCode = "0" + groupCode;
		String resultKey = appCode + ":" + groupCode;
		// if (deviceType == DeviceType.LABEL) resultKey = "L:" + resultKey;
		return resultKey.toUpperCase();
	}
	
	public String buildKey (String appCode, int groupCode, int deviceType) {
		return buildKey (appCode,Integer.toHexString(groupCode), deviceType);
	}
	/**
	 * Pads a hex value with leading zeros till the string is padding long
	 * @param hexVal	The hex value to pad
	 * @param padding	The number of chars required
	 * @return	The string representing the padded value
	 */
	protected String hexPad(String hexVal, int padding) {
		int missing = padding - hexVal.length();
		String retVal = hexVal;
		
		for (int i = 0 ; i < missing ; i++) {
			retVal = "0" + retVal;
		}
		return retVal;
	}
	/**
	 * 
	 * @param rampRate
	 * @return
	 */
	public String findRampCode (String rampRate) {
		String retCode = "";
		if (rampRate.equals("0")) retCode = "02";
		if (rampRate.equals("4")) retCode = "0A";
		if (rampRate.equals("8")) retCode = "12";
		if (rampRate.equals("12")) retCode = "1A";
		if (rampRate.equals("20")) retCode = "22";
		if (rampRate.equals("30")) retCode = "2A";
		if (rampRate.equals("40")) retCode = "32";
		if (rampRate.equals("1m")) retCode = "3A";
		if (rampRate.equals("1.5m")) retCode = "42";
		if (rampRate.equals("2m")) retCode = "4A";
		if (rampRate.equals("3m")) retCode = "52";
		if (rampRate.equals("5m")) retCode = "5A";
		if (rampRate.equals("7m")) retCode = "62";
		if (rampRate.equals("10m")) retCode = "6A";
		if (rampRate.equals("15m")) retCode = "72";
		if (rampRate.equals("17m")) retCode = "7A";
		return retCode;
	}
	/**
	 * 
	 * @param toCalc
	 * @return
	 */
	public String calcChecksum (String toCalc) {
		int total = 0;
		logger.log(Level.FINE, "calculate checksum for: " + toCalc);
		for (int i = 0; i < toCalc.length(); i+=2) {
			String nextPart = toCalc.substring(i,i+2);
			int val = Integer.parseInt(nextPart,16);
			total += val;
		}
		byte remainder = (byte)(total % 256);
		byte twosComp = (byte)-remainder;
		String hexCheck = Integer.toHexString(twosComp); 
		if (hexCheck.length() == 1) hexCheck = "0" + hexCheck;
		if (hexCheck.length() > 2) hexCheck = hexCheck.substring(hexCheck.length() - 2);
		return hexCheck.toUpperCase();
	}
	/**
	 * 
	 * @param vals
	 * @return
	 */
	public byte calcChecksum(Vector<Byte> vals) {
		int total = 0;

		for (int i: vals){
			total += i;
		}
		int remainder = total % 256;
		byte twosComp = (byte)((~remainder + 1)&0xff);
		return twosComp;			
	}
	/**
	 * Creates an on or off command to send to CBUS
	 * @param cBUSCommand	either 0x01 or 0x79
	 * @param appCodeStr	the application ID
	 * @param group			the group ID
	 * @param key			the command sequence key 
	 * @return the command string to send
	 */
	protected String buildCBUSOnOffCommand (String cBUSCommand, String appCodeStr,  String group, String key) {
		try {
			int appCode = Integer.parseInt(appCodeStr,16);
			byte remainder = (byte)(((byte)5 + appCode + Byte.parseByte(cBUSCommand,16) + Integer.parseInt(group,16)) % 256);
			byte twosComp = (byte)-remainder;

			String hexCheck = Integer.toHexString(twosComp);
			if (hexCheck.length() == 1) hexCheck = "0" + hexCheck;
			if (hexCheck.length() > 2) hexCheck = hexCheck.substring(hexCheck.length() - 2);

			String returnString = "\\05" + appCodeStr + "00" + cBUSCommand + group + hexCheck;
			returnString = returnString.toUpperCase();
			returnString = returnString + key + ETX;
			return returnString;
		} catch (NumberFormatException er) {
			logger.log (Level.FINE, "Zone entry for CBUS is malformed. Command : " + cBUSCommand + " Group : " + group);
			logger.log (Level.FINEST, "Error: " + er.getMessage());
			return null;
		}
	}
	/**
	 * build an air-conditioning string command 0x2F or 0x47
	 * @param cBUSCommand	The command byte
	 * @param appCodeStr	The application byte
	 * @param group			The group byte
	 * @param key			The sequence key
	 * @return	The command string or null if the string can't be built
	 */
	protected String buildCBUSAirconCommand (String cBUSCommand, String appCodeStr,  String group, String groupList, String mode, String type, String level, String auxLevel, String key) {
		try
		{
			String returnString = "05" + appCodeStr + "00" + cBUSCommand + group + groupList + mode + type + level + auxLevel;	// create the string
			returnString += calcChecksum(returnString);	// add the checksum
			returnString = returnString.toUpperCase();	// make it upper-case?
			returnString = "\\" + returnString + key + ETX;	// add the sequence character and the end of message
			return returnString;
		}
		catch (NumberFormatException er) {
			logger.log (Level.FINE, "Zone entry for CBUS is malformed. Command : " + cBUSCommand + " Group : " + group);
			logger.log (Level.FINEST, "Error: " + er.getMessage());
			return null;
		}
	}
	/**
	 * 
	 * @param rampCodeStr
	 * @param appCodeStr
	 * @param levelStr
	 * @param group
	 * @param key
	 * @return
	 */
	protected String buildCBUSRampToCommand (String rampCodeStr, String appCodeStr, String levelStr, String group, String key)  {
		try {
			int level = Integer.parseInt(levelStr);
			//byte levelPerc = ((byte)((level / 100 ) * 255));
			int normValue = (int)((double)level / 100.0 * 255.0);
			if (level == 255) normValue = 100;

			String rampRateStr = findRampCode (rampCodeStr);
			if (rampRateStr.equals ("")){
				logger.log (Level.WARNING, "A ramp rate that CBUS cannot support was specified");
				return null;
			}
			byte rampRate = Byte.parseByte(rampRateStr,16);

			byte appCode = Byte.parseByte(appCodeStr,16);

			byte remainder = (byte)(((byte)5 + appCode + rampRate + normValue + Integer.parseInt(group,16)) % 256);
			byte twosComp = (byte)-remainder;
			String hexCheck = Integer.toHexString(twosComp);
			if (hexCheck.length() == 1) hexCheck = "0" + hexCheck;
			if (hexCheck.length() > 2) hexCheck = hexCheck.substring(hexCheck.length() - 2);

			String hexLevel = Integer.toHexString(normValue);
			if (hexLevel.length() == 1) hexLevel = "0" + hexLevel;
			if (hexLevel.length() > 2) hexLevel = hexLevel.substring(hexLevel.length() - 2);

			String returnString = "\\05" + appCodeStr + "00" + rampRateStr + group + hexLevel + hexCheck;
			returnString = returnString.toUpperCase();
			return returnString + key + ETX;
		} catch (NumberFormatException er) {
			logger.log (Level.SEVERE, "Zone entry for CBUS is malformed : " + group);
			return null;
		}
	}
	/**
	 * 
	 * @param appCodeStr
	 * @param startGroup
	 * @param key
	 * @return
	 */
	protected String buildCBUSLevelRequestCommand (String appCodeStr,  int startGroup,String key) {
		try {
			byte appCode = Byte.parseByte(appCodeStr,16);
			byte remainder = (byte)((5+255+115 + 7 + appCode + startGroup ) % 256);
			byte twosComp = (byte)-remainder;
			String numStr = Integer.toHexString(startGroup);
			if (numStr.length() == 1) numStr = "0" + numStr;

			String hexCheck = Integer.toHexString(twosComp);
			if (hexCheck.length() == 1) hexCheck = "0" + hexCheck;
			if (hexCheck.length() > 2) hexCheck = hexCheck.substring(hexCheck.length() - 2);

			String returnString = "\\05FF007307" + appCodeStr + numStr + hexCheck ;
			returnString = returnString.toUpperCase();
			return returnString + key + ETX;
		} catch (NumberFormatException er) {
			logger.log (Level.FINE, "Application code is in error for level request : " + appCodeStr);
			return null;
		}
	}
	/**
	 * 	
	 * @param appCodeStr
	 * @param key
	 * @param catalogueStr
	 * @param flavour
	 * @param currentChar
	 * @param device
	 * @return
	 */
	protected String buildCBUSLabelCommand (String appCodeStr, String key, String theLabel, String flavour, String currentChar, Label device) {
		String returnString = "";
		try {
			logger.log(Level.FINEST,"Building a CBUS label string " + theLabel + " for device "+ device.getOutputKey());
			Vector <Byte> retCodes = new Vector<Byte>();
			retCodes.add( (byte)5);
			retCodes.add(Byte.parseByte(appCodeStr,16));
			retCodes.add((byte)0); // options

			int  theCommand = 160 +3 + theLabel.length();
			retCodes.add((byte)theCommand);
			int intGroup = Integer.parseInt(key,16);
			retCodes.add((byte)intGroup); // group address
			retCodes.add((byte)0); 
			retCodes.add((byte)1); // language english

			for (int i = 0; i < theLabel.length(); i ++){
				char eachChar = theLabel.charAt(i);
				retCodes.add((byte)eachChar);
			}
			byte checkSum = calcChecksum(retCodes);
			boolean firstChar = true; // first is different
			for (int i:retCodes){
				if (firstChar) {
					returnString = "\\05";
					firstChar = false;
				}
				else
					returnString += String.format("%02X", i&0xff);
			}
			returnString += String.format("%02X",checkSum);
			returnString += currentChar + ETX;

			return returnString;

		} catch (NumberFormatException er) {
			logger.log (Level.INFO, "Group address is in error for CBUS Label command : "+ er.getMessage());
			return null;
		}
	}
	/**
	 * Handles a scene command 
	 * @param restOfString
	 * @return
	 */
	protected boolean handleScene(String restOfString) {
		// trigger control (scene command)
		// command code is as below (02 == trigger) (01 == trigger min) (79 == trigger max) (09 == trigger kill) (101LLLLL = trigger label (LLLLL = label number in binary))
		try {
			String commandCode = restOfString.substring(0,2); // the command byte
			String cBusGroup = restOfString.substring(2,4); // which cbus group the command is for
			String actionSelector = restOfString.substring(4,6);

			logger.log(Level.FINER,"received scene trigger" );
			logger.log(Level.FINEST,"command:" + commandCode + " trigger group:" + cBusGroup + " action selector:" + actionSelector);
		}
		catch (IndexOutOfBoundsException ex) {
			logger.log(Level.WARNING,"scene trigger not enough arguments...");			
		}

		return true;
	}

}
