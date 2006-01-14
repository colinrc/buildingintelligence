/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.Alert;
import au.com.BI.Util.*;
import au.com.BI.Command.*;



/**
 * @author Colin Canfield
 *
 **/
public class Alarm extends BaseDevice implements DeviceType 
{


	public Alarm (String name, int deviceType, String outputKey){
		this.name = name;
		this.deviceType = deviceType;
		this.outputKey = outputKey;

	}
	public boolean keepStateForStartup () {
		return false;
	}
	public String getModeStr (String modeCode) {
		if (modeCode.equals("00")) return "Security Off.";
		if (modeCode.equals("01")) return "Away Mode.";
		if (modeCode.equals("02")) return "Night Mode.";
		if (modeCode.equals("03")) return "Day Mode.";
		if (modeCode.equals("04")) return "Vacation Mode.";
		return "";
	}

	public String getModeCode (String modeStr) {
		if (modeStr.equals("Security Off")) return "00";
		if (modeStr.equals("Away Mode")) return "01";
		if (modeStr.equals("Night Mode")) return "02";
		if (modeStr.equals("Day Mode")) return "03";
		if (modeStr.equals("Vacation Mode")) return "04";
		return "";
	}
	
	/**
	 * Return the client display command for the alarm.
	 * For a alarm this is the same as the interpretted command
	 */
	public int getClientCommand ()
	{
		return DeviceType.NA;
	}
	
	/**
	 * Returns a display command represented by the Alarm object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		AlarmCommand alarmCommand = new AlarmCommand ();
		alarmCommand.setCommand("on");
		alarmCommand.setDisplayName(this.getOutputKey());
		return alarmCommand;
	}
	
}
