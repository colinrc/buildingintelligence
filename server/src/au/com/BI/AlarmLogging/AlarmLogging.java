package au.com.BI.AlarmLogging;

import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Command.*;
import au.com.BI.Alert.AlertCommand;
import au.com.BI.User.*;

public class AlarmLogging {

	public static final int GENERAL_MESSAGE = 0; 
	public static final int INTRUDER = 1;
	public static final int TAMPER = 2;
	public static final int PANIC = 3;
	public static final int SMOKE = 4;
	public static final int DOORBELL = 5;
	public static final int PHONE_MESSAGE = 6;
	public static final int TROUBLE = 7;
	public static final int VIOLATED = 8;
	public static final int BYPASSED = 9;
	public static final int PANIC_RELEASED = 10;
	
	protected Logger logger = null;
	protected CommandQueue commandQueue = null;
	protected Cache cache = null;
	
	public AlarmLogging () {
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
	public void setCommandQueue(CommandQueue commandQueue) {
		this.commandQueue = commandQueue;
	}
	
	public String reasonToStr (int reason){
		switch (reason) {
			case GENERAL_MESSAGE: return "GENERAL_MESSAGE";
			case INTRUDER: return "INTRUDER";
			case TAMPER: return "TAMPER";
			case PANIC: return "PANIC";
			case SMOKE: return "SMOKE";
			case DOORBELL: return "DOORBELL";
			case PHONE_MESSAGE: return "PHONE_MESSAGE";
			case TROUBLE: return "TROUBLE";
			case VIOLATED: return "VIOLATED";
			case BYPASSED: return "BYPASSED";
		}
		return "";
	}

	/**
	 * 
	 * @param displayName The display name is the target to send the message to.
	 * @param message Message to display.
	 * @param reason The cause of the alarm.
	 * @param triggerDevice The DISPLAY_NAME that created the alarm if applicable.   
	 * @param nativeAlarmCode The device code from the original alarm system if applicable.
	 * @param time The time the event occured, if the time is null it will be the current time.
	 */
	public void addAlarmLog (String displayName, String message, int reason, 
			String triggerDevice, String nativeAlarmCode, User user,
			Date time){
		
	
		CommandInterface _command = new AlertCommand();
		_command.setDisplayName(displayName);
		_command.setTargetDeviceID(-1);
		_command.setUser(user);
		_command.setExtraInfo(message);
		_command.setExtra2Info(triggerDevice);
		_command.setExtra3Info(reasonToStr(reason));
		_command.setKey ("CLIENT_SEND");

		cache.setCachedCommand(_command.getKey(),_command);

		logger.log (Level.INFO,"Sending alarm to flash " + displayName + ":" +  message);
			
		if (_command != null) {
			commandQueue.add(_command);
		}
	}
		
	/**
	 * 
	 * @param displayName The display name is the target to send the message to.
	 * @param message Message to display.
	 * @param reason The cause of the alarm.
	 * @param triggerDevice The DISPLAY_NAME that created the alarm if applicable.   
	 * @param nativeAlarmCode The device code from the original alarm system if applicable.
	 * @param time The time the event occured, if the time is null it will be the current time.
	 */
	public void addAlertLog (String displayName, String message, int reason, 
			String triggerDevice, String nativeAlarmCode, User user,
			Date time){
		
	
		CommandInterface _command = new AlertCommand();
		_command.setDisplayName(displayName);
		_command.setTargetDeviceID(-1);
		_command.setUser(user);
		_command.setExtraInfo(message);
		_command.setExtra2Info(triggerDevice);
		_command.setExtra3Info(reasonToStr(reason));
		_command.setKey ("CLIENT_SEND");

		cache.setCachedCommand(_command.getKey(),_command);

		logger.log (Level.INFO,"Sending alarm to flash " + displayName + ":" +  message);
		if (_command != null) {
			commandQueue.add(_command);
		}

	}
		
	public Cache getCache() {
		return cache;
	}

	public void setCache(Cache cache) {
		this.cache = cache;
	}
}
