/*
 * Created on Feb 12, 2004
 *
 */
package au.com.BI.Alert;
import au.com.BI.Util.*;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;



/**
 * @author Colin Canfield
 *
 **/
public class Alert extends BaseDevice implements DeviceType 
{

	protected String active="";
	protected String alarmType = "";
	protected String message = "";

	public Alert (String name, int deviceType, String outputKey,String alarmType,String message,String active){
		this.name = name;
		this.deviceType = deviceType;
		this.outputKey = outputKey;
		this.alarmType = alarmType;
		this.message = message;
		this.active = active;

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

	/**
	 * Return the client display command for the alarm.
	 * For a alarm this is the same as the interpretted command
	 */
	public int getClientCommand ()
	{
		return DeviceType.NA;
	}
	
	/**
	 * Returns a display command represented by the alert object
	 * @return
	 */
	public CommandInterface buildDisplayCommand () {
		AlertCommand alertCommand = new AlertCommand ();
		if (command.equals("")) 
		    setCommand("on");
		else
		    alertCommand.setCommand(this.command);
		alertCommand.setDisplayName(this.getOutputKey());
		return alertCommand;
	}
	
	/**
	 * @return Returns the alarmType.
	 */
	public String getAlarmType() {
		return alarmType;
	}
	/**
	 * @param alarmType The alarmType to set.
	 */
	public void setAlarmType(String alarmType) {
		this.alarmType = alarmType;
	}
	/**
	 * Returns the Alarm type as a constant.
	 * @return
	 */
	public AlarmTypeCode getAlarmTypeCode() {
		if (alarmType == null) {
			return AlarmTypeCode.NA;
		}
		if (alarmType.equals ("User")) return AlarmTypeCode.ALARM_USER;
		if (alarmType.equals ("ID")) return AlarmTypeCode.ALARM_ID;
		if (alarmType.equals ("Zone")) return AlarmTypeCode.ALARM_ZONE;
		if (alarmType.equals ("System")) return AlarmTypeCode.ALARM_SYSTEM;
		if (alarmType.equals ("DoorBell")) return AlarmTypeCode.ALERT_DOORBELL;
		if (alarmType.equals ("Phone")) return AlarmTypeCode.ALERT_PHONE;
		if (alarmType.equals ("ModeChange")) return AlarmTypeCode.ALERT_MODE_CHANGE;
		if (alarmType.equals ("Alarm Type")) return AlarmTypeCode.ALARM_TYPE;
		return AlarmTypeCode.NA;
	}
	/**
	 * @return Returns the message.
	 */
	public String getMessage() {
		return message;
	}
	/**
	 * @param message The message to set.
	 */
	public void setMessage(String message) {
		this.message = message;
	}
	/**
	 * @return Returns the active.
	 */
	public String getActive() {
		return active;
	}
	/**
	 * @param active The active to set.
	 */
	public void setActive(String active) {
		this.active = active;
	}
	
	public boolean isActive () {
		if (active == null) return true;
		if (active.equals ("N"))
			return false;
		else
			return true;
	}
}
