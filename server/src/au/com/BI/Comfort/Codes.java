/*
 * Created on Jan 10, 2004
 *
*/
package au.com.BI.Comfort;

import java.util.Hashtable;

/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:53 PM
 */
public class Codes{
	public Hashtable <String,String>alarmTypes;
	public Hashtable <String,String>commandCodes;
	public Hashtable <String,String>commandReturns;
			
	public  Codes ()
	{
		alarmTypes = new Hashtable <String,String>(32); // default alarm types
		commandCodes = new Hashtable <String,String>(41); // command codes
		commandReturns = new Hashtable<String,String> (37); // default alarm returns

		setAlarmTypes (alarmTypes);
		setCommandCodes (commandCodes);
		setCommandReturns (commandReturns);
	}
	
	public void setAlarmTypes (Hashtable <String,String>alarmTypes) 
	{
		alarmTypes.put("00", "No Alarm");
		alarmTypes.put("01", "Intruder Alarm");
		alarmTypes.put("02", "Duress");
		alarmTypes.put("03", "Phone Line Trouble");
		alarmTypes.put("04", "Arm Fail");
		alarmTypes.put("05", "Zone Trouble");
		alarmTypes.put("06", "Zone Alert");
		alarmTypes.put("07", "Low Battery");
		alarmTypes.put("08", "Power Fail");
		alarmTypes.put("09", "Panic");
		alarmTypes.put("10", "Entry Alert");
		alarmTypes.put("11", "Tamper");
		alarmTypes.put("12", "Fire");
		alarmTypes.put("13", "Gas");
		alarmTypes.put("14", "Family Care (spare)");
		alarmTypes.put("15", "Perimeter Alert");
		alarmTypes.put("16", "Bypass Zone");
		alarmTypes.put("17", "System Disarmed");	 
		alarmTypes.put("18", "CMS Test");
		alarmTypes.put("19", "System Armed");
		alarmTypes.put("20", "Alarm Abort");
		alarmTypes.put("21", "Entry Warning");
		alarmTypes.put("22", "Siren Trouble");
		alarmTypes.put("23", "Unused");
		alarmTypes.put("24", "RS485 Comms Fail");
		alarmTypes.put("25", "Doorbell (Away)");
		alarmTypes.put("26", "Homesage (Spare)");
		alarmTypes.put("27", "Dial Test");
		alarmTypes.put("28", "Spare");
		alarmTypes.put("29", "New Message");
		alarmTypes.put("30", "Engineer Sign in");
		alarmTypes.put("31", "Sign-in Tamper");
	}
	
	public void setCommandCodes (Hashtable<String,String> commandCodes) 
	{
		commandCodes.put("a?", "Get Current Alarm");
		commandCodes.put("A?", "Get Analog Input Value");
		commandCodes.put("C!", "Set Counter");
		commandCodes.put("C?", "Read Counter");
		commandCodes.put("CI", "Learn IR Mode");
		commandCodes.put("DA", "Do actions");
		commandCodes.put("DT", "Set Date and Time");
		commandCodes.put("DL", "Download to Comfort");
		commandCodes.put("DP", "Download to UCM EEPROM");
		commandCodes.put("E?", "Event Log Request");
		commandCodes.put("I?", "Input Status Request");
		commandCodes.put("IR", "IR activation Command/Report");
		commandCodes.put("IL", "IR Code download");
		commandCodes.put("I!", "Virtual Input Command");
		commandCodes.put("KD", "Keypad digit");
		commandCodes.put("LI", "Log In");
		commandCodes.put("M!", "Security Mode Change command - Autoarm");
		commandCodes.put("m!", "Security Mode Change - Local Arm");
		commandCodes.put("M?", "Security Mode status Request");
		commandCodes.put("MO", "Monitor Mode");
		commandCodes.put("MS", "Mic/Speaker control");
		commandCodes.put("O!", "Output Activation");
		commandCodes.put("O?", "Output status request");
		commandCodes.put("P!", "Pulse Output");
		commandCodes.put("PS", "Engineer Code Enable/disable");
		commandCodes.put("RM", "Set Reminder Message");
		commandCodes.put("RS", "Reset Command");
		commandCodes.put("R!", "Do Response");
		commandCodes.put("S?", "get alarm state");
		commandCodes.put("SP", "Speaker broadcast control");
		commandCodes.put("SR", "Status Reports ON/OFF");
		commandCodes.put("TP", "Set Time Program");
		commandCodes.put("U?", "Get UCM type/version");
		commandCodes.put("UL", "Upload from Comfort");
		commandCodes.put("UP", "Upload from UCM COPY EEPROM");
		commandCodes.put("V?", "get version and FS");
		commandCodes.put("VP", "Download new Vocabulary");
		commandCodes.put("X!", "X10 Command");
		commandCodes.put("Y?", "request all output status");
		commandCodes.put("Z?", "request all zones");	
	}
	
	public void setCommandReturns (Hashtable <String,String>commandReturns)
	{
		commandReturns.put("a?", "Current Alarm Type Reply");
		commandReturns.put("AL", "Alarm Type Report");
		commandReturns.put("AM", "System (Non-detector) Alarm Report");
		commandReturns.put("AR", "System (Non-detector) Alarm Restored Report");
		commandReturns.put("BP", "beep on Speaker");
		commandReturns.put("C?", "Counter value Reply to C? Request");
		commandReturns.put("CI", "Learned IR code data");
		commandReturns.put("CT", "Counter Changed Report");
		commandReturns.put("DB", "Doorbell pressed");
		commandReturns.put("DT", "Date and time");
		commandReturns.put("DI", "Dial up");
		commandReturns.put("E?", "Event Log report");
		commandReturns.put("EX", "Entry/Exit Delay Started");
		commandReturns.put("IP", "Input Activation report");
		commandReturns.put("IR", "IR Activation Report");
		commandReturns.put("IX", "IR Code received");
		commandReturns.put("LU", "User Logged in");
		commandReturns.put("NA", "Command Not Available (Invalid command or parameter)");
		commandReturns.put("OK", "Command Acknowledged");
		commandReturns.put("OP", "Output activation report");
		commandReturns.put("OV", "Virtual output command");
		commandReturns.put("OQ", "Virtual Output status request");
		commandReturns.put("MD", "Mode Change report");
		commandReturns.put("PT", "Pulse activation report");
		commandReturns.put("RA", "Return value from DA (Do Action)");
		commandReturns.put("RP", "Phone Ring");
		commandReturns.put("SM", "Speaker/Microphone command from Comfort");
		commandReturns.put("T+", "Trouble Alarm");
		commandReturns.put("T-", "Trouble Alarm Restore");
		commandReturns.put("XF", "X10 House/Function code received");
		commandReturns.put("XR", "X10 Received Report (replaced by XF and XU)");
		commandReturns.put("XT", "X10 Transmitted report");
		commandReturns.put("XU", "X10 house/Unit code received");
		commandReturns.put("Y?", "request all output status");
		commandReturns.put("Z?", "Report all zones");
		commandReturns.put("??", "Checksum error or error in message format");
	}

}

