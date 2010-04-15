/**
 * 
 */
package au.com.BI.Integra;

import au.com.BI.Util.Utility;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.apache.log4j.lf5.LogLevel;

/**
 * @author richardlemon
 * Helper class to encapsulate the Integra protocol specific code.
 * Use to create and interpret the data from the Integra
 */
public class IntegraHelper {

	protected String deviceModel = null;	// the model number of the hardware
	protected String commsLine = null;		// the type of comms, serial or ip
	protected final String STX = "!";		// start of TX
	protected final String ETX = "\n";		// end of TX
	protected final String ERX = "\0x1A";	// end of RX
	protected final String UnitType = "1";	// the unit type always 1 for receiver
	protected Logger logger = null;
	
	/**
	 * Enumeration  allows us to map commands to and from device
	 * @author richardlemon
	 */
	public enum commandMap 
	{
		// enum elements
		power ("PWR","ZPW","PW3"), 
		mute("AMT", "ZMT", "MT3"),
		volume("MVL", "ZVL", "VL3"),
		src ("SLI", "SLZ", "SLZ"),
		preset("LMD","LMZ",null);
		// member variables
		private final String zone1;
		private final String zone2;
		private final String zone3;
		// constructor
		commandMap(String zone1, String zone2, String zone3)
		{
			this.zone1 = zone1;
			this.zone2 = zone2;
			this.zone3 = zone3;
		}
		/**
		 * Get the flash command for the given Integra command
		 * @param cmd	The Integra command received on the serial port
		 * @return	string value of the flash command, null if not found
		 */
		public String getFlashString(String cmd)
		{
			if (zone1.equals(cmd) || zone2.equals(cmd) || zone3.equals(cmd)){
				return  toString();
			}
			return null;
		}
		/**
		 * Get the Integra command for the given flash command
		 * @param cmd	The Flash command received from the client
		 * @param zone	The zone that we are working on
		 * @return 		value of the Integra command, null if not found
		 */
		public String getIntegraCommand(int zone){
			switch(zone)
			{
			case 1:
				return zone1;
			case 2:
				return zone2;
			case 3:
				return zone3;
			}
			return null;
		}
	};
	/**
	 * Standard constructor
	 * @param modelName - the model name of the device we are controlling
	 * @param lineOut - string either IP or SERIAL
	 */
	public IntegraHelper(Logger logger, String modelName, String lineOut) {
		this.logger = logger;
		deviceModel = modelName;
		commsLine = lineOut;
	}
	/**
	 * tests the comm line type
	 * @return true if the comms are serial
	 */
	public boolean isSerial(){
		// TODO decide if we would be better off optimizing the string comms test to bool or int 
		return commsLine.equals("SERIAL");
	}
	/**
	 * Tests the comm line type
	 * @return true if the comms are tcp/ip
	 */
	public boolean isIP(){
		return commsLine.equals("IP");
	}
	/**
	 * gets the start of transmission character
	 * @return either STX for serial or null for TCP/IP
	 */
	public String getSTX(){
		String retStr = null;
		if (isSerial())
			retStr = STX;
		return retStr;
	}
	/**
	 * gets the end of transmission character
	 * @return either STX for serial or null for TCP/IP
	 */
	public String getETX(){
		return ETX;
	}
	/**
	 * Get the source device from the received serial string
	 * @param inCommand	The received serial string
	 * @return boolean the true if source == UnitType constant
	 */
	public boolean validSourceDevice(String inCommand){
		try
		{
			if (isSerial())
				return inCommand.substring(1, 2).equals(UnitType );
			
			return inCommand.substring(0,1).equals(UnitType);
		}
		catch(IndexOutOfBoundsException ex)
		{
			logger.log (Level.WARNING, "Received command to short for Integra, cant get source device");
		}
		return false;
	}
	/**
	 * Get the input parameter for a command
	 * @param inCommand the received serial string from the device
	 * @return	string the action part of command (on / off / qstn) etc, empty on fail
	 */
	public String getInputValue(String inCommand){
		try
		{
		if (isSerial())
			return inCommand.substring(5);
		
		return inCommand.substring(4);
		}
		catch(IndexOutOfBoundsException ex)
		{
			logger.log (Level.WARNING, "Received command to short for Integra, couldn't read command data");			
		}
		return "";
	}
	/**
	 * Get the 3 character command code 
	 * @param inCommand	the received serial string from the device
	 * @return	string the command code, empty on fail
	 */
	public String getInputCommand(String inCommand){
		try
		{
			if (isSerial())
				return inCommand.substring(2,5);
			
			return inCommand.substring(1,4);
		}
		catch(IndexOutOfBoundsException ex)
		{
			logger.log (Level.WARNING, "Received command to short for Integra, couldn't read command code");
		}
		return "";
	}
	/**
	 * Using the format of the command figure out which device we are looking at
	 * If the last character of the command is a 3 (zone 3)
	 * if the first or last is a Z (Zone 2)
	 * else default (Zone 1)
	 * @param command	Input command string
	 * @return	Device of interest
	 */
	String getDeviceKey(String command){
		try
		{
			String key = new String("01");
			String cmd = getInputCommand(command);
			if (cmd.charAt(0) == 'Z' || cmd.charAt(2) == 'Z')
				key = "02";
			if (cmd.charAt(2) == '3')
				key = "03";
			
			return key;
		}
		catch(IndexOutOfBoundsException ex)
		{
			logger.log (Level.WARNING, "Received command to short for Integra, cant get device key");			
		}
		return "";
	}
	/**
	 * Given the hex volume value scale to 0..100
	 * @param volume hex volume string from device
	 * @return scaled volume value 0..100
	 */
	String scaleVolumeForFlash(String volume)
	{
		int retVal = -1;
		try
		{
			int nVal = Integer.parseInt(volume, 16);
			// if type == dtr5.2 or dtr6.2 then 0..80 is full scale
			// else 0..100 is full scale
			if (deviceModel.equals("DTR5.2") || deviceModel.equals("DTR6.2")){
				// scale 0..80 to 0..100
				 retVal = Utility.scaleForFlash(String.valueOf(nVal), 0, 80,false);
			}
			else 
				retVal = Utility.scaleForFlash(String.valueOf(nVal), 0, 100,false);
			}
		catch(NumberFormatException ex)
		{
			logger.log (Level.WARNING,"Volume value invalid " + ex.getMessage());
		}
		if ( retVal > 100) 
			return ""; 
		
		return String.valueOf(retVal);
	}
	/**
	 * Given the hex volume value scale to 0..100
	 * @param volume hex volume string from device
	 * @return scaled volume value 0..100
	 */
	String scaleVolumeFromFlash(String volume)
	{
		int retVal = -1;
		try
		{
			// if type == dtr5.2 or dtr6.2 then 0..80 is full scale
			// else 0..100 is full scale
			if (deviceModel == "DTR5.2" || deviceModel == "DTR6.2"){
				// scale 0..80 to 0..100
				 retVal = Utility.scaleFromFlash(volume, 0, 80,false);
			}
			else 
				retVal = Utility.scaleFromFlash(volume, 0, 100,false);
			}
		catch(NumberFormatException ex)
		{
			logger.log (Level.WARNING,"Volume value invalid " + ex.getMessage());
		}
		if ( retVal > 100) 
			return "";
		
		return Integer.toHexString(retVal);
	}
	/**
	 * creates output volume string to send to the device
	 * @param zone	integer value for zone [1,2,3]
	 * @param action	either volume up or down	
	 * @return
	 */
	public String outVolume(int zone, String action){
		String outCommand = new String();
		// TODO test is probably unnecessary string + null = string?
		if (isSerial())
			outCommand += getSTX();
		outCommand += UnitType;

		String integraCmd = commandMap.volume.getIntegraCommand(zone);
		if (integraCmd == null)
			return null;
		outCommand += integraCmd;
		if (action.equals("up"))
		{
			outCommand += "UP" + getETX();
		}
		else if (action.equals("down"))
		{
			outCommand += "DOWN" + getETX();
		}
		else if (action.equals("query"))
		{
			outCommand += "QSTN" + getETX();
		}
		else 
		{
			// we have a number for the volume level...
			String volLevel = scaleVolumeFromFlash(action);
			// number didn't interpret... 
			if (volLevel.equals(""))
				return null;

			outCommand += volLevel + getETX();
		}
		return outCommand;
	}
	/**
	 * Creates an output mute string to send to the device
	 * @param zone	integer value for zone [1,2,3]
	 * @param action	either mute on or off	
	 * @return
	 */
	public String outMute(int zone, String action)
	{
		String outCommand = new String();
		// TODO test is probably unnecessary string + null = string?
		if (isSerial())
			outCommand += getSTX();
		outCommand += UnitType;

		String integraCmd = commandMap.mute.getIntegraCommand(zone);
		if (integraCmd == null)
			return null;
		
		outCommand += integraCmd;
		if (action.equals("on"))
		{
			outCommand += "01" + getETX();
		}
		else if (action.equals("off"))
		{
			outCommand += "00" + getETX();
		}
		else if (action.equals("query"))
		{
			outCommand += "QSTN" + getETX();
		}
		else 
			outCommand = null;
		
		return outCommand;
		
	}
	/**
	 * Creates an output mute string to send to the device
	 * @param zone	integer value for zone [1,2,3]
	 * @param action	either mute on or off	
	 * @return
	 */
	public String outPower(int zone, String action)
	{
		String outCommand = new String();
		// TODO test is probably unnecessary string + null = string?
		if (isSerial())
			outCommand += getSTX();
		outCommand += UnitType;

		String integraCmd = commandMap.power.getIntegraCommand(zone);
		if (integraCmd == null)
			return null;
		
		outCommand += integraCmd;
		if (action.equals("on"))
		{
			outCommand += "01" + getETX();
		}
		else if (action.equals("off") || action.equals("standby"))
		{
			outCommand += "00" + getETX();
		}
		else if (action.equals("query"))
		{
			outCommand += "QSTN" + getETX();
		}
		else 
			outCommand = null;
		
		return outCommand;
		
	}
	/**
	 * Creates an output select source string to send to the device
	 * @param zone	integer value for zone [1,2,3]
	 * @param action the code for the source to select (see config_integra.xml)	
	 * @return
	 */
	public String outSource(int zone, String action)
	{
		String outCommand = new String();
		// TODO test is probably unnecessary string + null = string?
		if (isSerial())
			outCommand += getSTX();
		outCommand += UnitType;

		String integraCmd = commandMap.src.getIntegraCommand(zone);
		if (integraCmd == null)
			return null;
		
		outCommand += integraCmd + action + getETX();
		return outCommand;
	}
	/**
	 * Creates an output select listening mode string
	 * @param zone	integer value for zone [1,2,3]
	 * @param action the code for the listening mode to select (see config_integra.xml)
	 * @return
	 */
	public String outPreset(int zone, String action)
	{
		String outCommand = new String();
		// TODO test is probably unnecessary string + null = string?
		if (isSerial())
			outCommand += getSTX();
		outCommand += UnitType;

		String integraCmd = commandMap.preset.getIntegraCommand(zone);
		if (integraCmd == null)
			return null;
		
		outCommand += integraCmd + action + getETX();
		return outCommand;
	}
}
