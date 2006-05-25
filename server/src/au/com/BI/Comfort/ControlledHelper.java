/*
 * Created on May 9, 2004
 */
package au.com.BI.Comfort;

import java.util.logging.*;
import java.util.*;
import au.com.BI.Util.*;
import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.Lights.*;
import au.com.BI.ToggleSwitch.*;
import au.com.BI.Counter.*;
import au.com.BI.Alert.*;
import au.com.BI.Analog.*;
import au.com.BI.X10.*;
import au.com.BI.PulseOutput.*;

/**
 * @author colinc
 */
public class ControlledHelper {
	/**
	 * 
	 */
	protected Logger logger;
	protected String STX;
	protected String ETX;
	protected DoActionHelper doActionHelper;


	public ControlledHelper() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		doActionHelper = new DoActionHelper();

	}

	
	public void doControlledItem (CommandInterface command, boolean isStartupQuery,ComfortString comfortString, ConfigHelper configHelper, Cache cache, List commandQueue, CommDevice comms, au.com.BI.Comfort.Model comfort) throws CommsFail
	{
		if (comfortString.comfortKey.equals("LU")) {
			String comfortUser = comfortString.theParameter;
			if (comfortUser.equals ("00")) {

				logger.log(Level.WARNING,"Comfort no longer logged in, reconnecing");
				Command restCommand = new Command();
				restCommand.setCommand ("Attatch");
				restCommand.setKey("SYSTEM");
				restCommand.setExtraInfo (Integer.toString(comfort.getInstanceID()));

				synchronized (commandQueue){
					commandQueue.add(restCommand);
					commandQueue.notifyAll();
				}	
			}
			else {
				comfort.setLoggedIn (true);
				if (comfortString.theParameter.equals ("18")) {
					logger.info("Logged into Comfort system as engineer");					
				} else { 
					String userName = configHelper.getCatalogueValue(comfortUser,"COMFORT_USERS", null);
					if (userName == null) {
						logger.info("Logged into Comfort. User " + comfortString.theParameter + " (not specified in the Comfort users catalogue)");						
					}
					else {
						logger.info("Logged into Comfort system as " + userName);						
					}
				}
			}
			return;
		}
		if (comfortString.comfortKey.equals("RA")) {
			synchronized (comms) {
				if (!comms.isCommandSentQueueEmpty()){
					CommsCommand raSent = comms.getLastCommandSent();
					comms.acknowlegeCommand("");
					logger.log (Level.FINEST,"Received DA return code " + raSent.getActionCode());
					doActionHelper.handleReturnCode (raSent, comfortString,   cache , commandQueue,configHelper, comfort);
				}
			}
			return;
		}
		if (comfortString.comfortKey.equals("OK")) {
			logger.log (Level.FINEST,"Received command OK code");

			return;
		}
		if (comfortString.comfortKey.equals("NA")) {
			return;
		}
		DeviceType deviceType;
		if (isStartupQuery)
			deviceType = (DeviceType)configHelper.getStartupQueryItem(comfortString.comfortKey);
		else
			deviceType = (DeviceType)configHelper.getControlledItem(comfortString.comfortKey);
		int commandCode = DeviceType.UKNOWN_EVENT;
		
		if (deviceType == null) {
			return;
		}
		switch (deviceType.getDeviceType() ) {
			case DeviceType.TOGGLE_OUTPUT: 
			    CommandInterface toggleCommand = (CommandInterface)((ToggleSwitch)deviceType).buildDisplayCommand ();
				toggleCommand.setKey ("CLIENT_SEND");
				toggleCommand.setUser(command.getUser());
				
				if (comfortString.theParameter.equals("01")){
				    toggleCommand.setCommand ("on");
				    toggleCommand.setExtraInfo ("100");
			 	}					
				if (comfortString.theParameter.equals("00")){
				    toggleCommand.setCommand ("off");
				}			
				sendToFlash (toggleCommand,cache,commandQueue);
				break;

			case DeviceType.COUNTER:
				Counter counter = (Counter)deviceType;
				CommandInterface counterCommand = (CommandInterface)counter.buildDisplayCommand ();
				counterCommand.setKey ("CLIENT_SEND");
				counterCommand.setUser(command.getUser());
				
				if (comfortString.theParameter.equals("00")){
					counterCommand.setCommand ("off");
				} else {
					counterCommand.setCommand ("on");
					try {
						int value = Integer.parseInt (comfortString.theParameter,16); // parse the hex code
						if (counter.getMax() - value < 5) value = counter.getMax();
						if (value > 0 && value < 10 ) value = 10;
						counterCommand.setExtraInfo (String.valueOf(value));	
					}
					catch (NumberFormatException error){
						logger.log (Level.WARNING, "Comfort returned illegal hex string for counter level " + comfortString.theParameter);
						counterCommand.setExtraInfo ( String.valueOf(counter.getMax()));
					}
				}					
				sendToFlash (counterCommand,cache,commandQueue);
				break;

			case DeviceType.LIGHT_CBUS:
			    CommandInterface cbusLightCommand = (CommandInterface)((LightFascade)deviceType).buildDisplayCommand ();
				cbusLightCommand.setKey ("CLIENT_SEND");
				cbusLightCommand.setUser(command.getUser());
				
				
				if (comfortString.theParameter.equals("00")){
					cbusLightCommand.setCommand ("off");
				} else {
					cbusLightCommand.setCommand ("on");
					try {
						int value = Integer.parseInt (comfortString.theParameter,16); // parse the hex code
						if (value > 98) value = 100;
						if (value > 0 && value < 10 ) value = 10;
						cbusLightCommand.setExtraInfo (String.valueOf(value));	
					}
					catch (NumberFormatException error){
						logger.log (Level.WARNING, "Comfort returned illegal hex string for CBUS level " + comfortString.theParameter);
						cbusLightCommand.setExtraInfo ("100");
					}
				}					
				sendToFlash (cbusLightCommand,cache,commandQueue);
				break;

			case DeviceType.ANALOGUE:
			    CommandInterface analogueCommand = (CommandInterface)((Analog)deviceType).buildDisplayCommand ();
				analogueCommand.setKey ("CLIENT_SEND");
				analogueCommand.setUser(command.getUser());

				if (comfortString.theParameter.equals("00")){
					analogueCommand.setCommand ("off");
				} else {
					analogueCommand.setCommand ("on");
					try {
						int value = Integer.parseInt (comfortString.theParameter,16); // parse the hex code
						if (value > 98) value = 100;
						if (value > 0 && value < 10 ) value = 10;
						analogueCommand.setExtraInfo (String.valueOf(value));	
					}
					catch (NumberFormatException error){
						logger.log (Level.WARNING, "Comfort returned illegal hex string for analogue level " + comfortString.theParameter);
						analogueCommand.setExtraInfo ("100");
					}
				}					
				sendToFlash (analogueCommand,cache,commandQueue);
				break;

			case DeviceType.COMFORT_LIGHT_X10_UNITCODE:
				comfortString.setLastHouseCode();
				break;

			case DeviceType.COMFORT_LIGHT_X10:
				X10Command x10LightCommand = (X10Command)((LightFascade)deviceType).buildDisplayCommand ();
				x10LightCommand.setKey ("CLIENT_SEND");
				x10LightCommand.setUser(command.getUser());
								
				if (comfortString.theParameter.equals("07")){
					x10LightCommand.setCommand ("off");
				} 
				if (comfortString.theParameter.equals("05") || comfortString.theParameter.equals("03") || comfortString.theParameter.equals("01")){
					x10LightCommand.setCommand ("on");
				} 
				sendToFlash (x10LightCommand,cache,commandQueue);
				break;

			case DeviceType.TOGGLE_INPUT: case DeviceType.TOGGLE_OUTPUT_MONITOR:
					CommandInterface toggleSwitchCommand = (CommandInterface)((ToggleSwitch)deviceType).buildDisplayCommand ();
					toggleSwitchCommand.setUser(command.getUser());
					toggleSwitchCommand.setKey ("CLIENT_SEND");
					
					if (comfortString.theParameter.equals("01")){
						toggleSwitchCommand.setCommand ("on");
						toggleSwitchCommand.setExtraInfo ("100");
				 	}					
					if (comfortString.theParameter.equals("00")){
						toggleSwitchCommand.setCommand ("off");
					}					
					sendToFlash (toggleSwitchCommand,cache,commandQueue);
					break;
					

			case DeviceType.PULSE_OUTPUT:
			    		CommandInterface pulseOutputCommand = (CommandInterface)((PulseOutput)deviceType).buildDisplayCommand ("CLIENT");
					pulseOutputCommand.setUser(command.getUser());
					pulseOutputCommand.setKey ("CLIENT_SEND");
					
					if (comfortString.theParameter.equals("01")){
					    pulseOutputCommand.setCommand ("on");
					    pulseOutputCommand.setExtraInfo ("100");
				 	}					
					if (comfortString.theParameter.equals("00")){
					    pulseOutputCommand.setCommand ("off");
					}					
					sendToFlash (pulseOutputCommand,cache,commandQueue);
					break;
					
			case DeviceType.DOORBELL : case DeviceType.ALERT :
			{
				Alert alert = (Alert)deviceType;
				AlertCommand alertCommand = (AlertCommand)alert.buildDisplayCommand ();
				AlertCommand alertCommand2 = null;
				alertCommand.setUser(command.getUser());
				alertCommand.setKey ("CLIENT_SEND");
				
				if (!alert.isActive()) {
					logger.log(Level.FINE,"Comfort alarm " + comfortString.theParameter + " was received, but has been configured to not be reported.");
					break;
				}
				
				int alarmTypeCode = alert.getAlarmTypeCode(); 
				switch (alarmTypeCode) {
				case DeviceType.ALARM_USER :
					try {
						int theUser = Integer.parseInt (comfortString.theParameter,16);
						theUser &= 127; // for some reason comfort randomly sets the high bit on user alarms
						String realParam = Integer.toHexString(theUser);
						if (realParam.length() == 1) realParam = "0" + realParam;
						if (realParam.length() > 2) realParam = realParam.substring(0,2);
						
						String lookupValue = configHelper.getCatalogueValue(realParam,"COMFORT_USERS",alert);
						if (comfortString.theParameter.equals ("5A")) lookupValue = "(unknown) on keypad.";
						if (comfortString.theParameter.equals ("5B")) lookupValue = "(unkbown), set by comfort.";
						if (lookupValue == null)
							alertCommand.setExtraInfo((String)alert.getMessage() + " user ID " + realParam);
						else
							alertCommand.setExtraInfo((String)alert.getMessage() + " by " + lookupValue);
					} catch (NumberFormatException ex) {
						logger.log(Level.SEVERE,"Comfort alarm user was not a number : " + comfortString.theParameter);
					}
					break;

				case DeviceType.ALARM_ZONE :
					{
					String inputZone = comfortString.theParameter;
					DeviceType inputDevice = (DeviceType)configHelper.getInputItem(inputZone);
					String lookupValue = "";
					if (!alert.isActive()) {
						logger.log(Level.FINE,"Comfort alarm " + comfortString.theParameter + " was received, but has been configured to not be reported.");
						break;
					}					
					if (inputDevice == null) {
						logger.log (Level.WARNING,"No input has been defined for zone " + inputZone);
						lookupValue = "(unknown input)";
					}
					else {
						lookupValue = inputDevice.getName();
					}
					alertCommand.setExtraInfo((String)alert.getMessage() + lookupValue);
					}
					break;

				case DeviceType.ALERT_DOORBELL :
				{
				if (!alert.isActive()) {
					logger.log(Level.FINE,"Comfort alarm " + comfortString.theParameter + " was received, but has been configured to not be reported.");
					break;
				}
				String lookupValue = configHelper.getCatalogueValue(comfortString.theParameter,"DOOR_IDS",alert);
				if (lookupValue == null) {
					logger.log (Level.WARNING,"No Door description has been defined in the door IDS catalogue for " + 
							comfortString.theParameter);
					alertCommand.setExtraInfo((String)alert.getMessage());
				} else {
					alertCommand.setExtraInfo((String)alert.getMessage() + lookupValue);
				}
				}
				break;

			case DeviceType.ALERT_MODE_CHANGE :
				{
				String lookupValue = configHelper.getCatalogueValue(comfortString.theParameter2,"COMFORT_USERS",alert);
				if (comfortString.theParameter2.equals ("5A")) lookupValue = "(unknown) on keypad.";
				if (comfortString.theParameter2.equals ("5B")) lookupValue = "(unknown), set by comfort.";

				if (lookupValue == null)
					alertCommand.setExtraInfo(alert.getModeStr(comfortString.theParameter) + " " + (String)alert.getMessage() + " user ID " + comfortString.theParameter2);
				else
					alertCommand.setExtraInfo(alert.getModeStr(comfortString.theParameter) + " " + (String)alert.getMessage() + " " + lookupValue);
				}
				alertCommand2 = (AlertCommand)alert.buildDisplayCommand ();
				alertCommand2.setUser(command.getUser());
				alertCommand2.setKey ("CLIENT_SEND");
				alertCommand2.setCommand("ModeChange");
				alertCommand2.setExtraInfo(comfortString.theParameter);
				String showKeypad = (String)comfort.getParameterValue("SHOW_KEYPAD_MODES",DeviceModel.MAIN_DEVICE_GROUP);
				if (showKeypad == null || showKeypad.equals ("")){
					showKeypad = "01,04";
				}
				if (showKeypad.indexOf(comfortString.theParameter)  >= 0) {
					alertCommand2.setExtra2Info("SHOW_COMFORT_KEYPAD");
					logger.log (Level.INFO,"Security mode set, switching client to keypad mode");
					
				} else {
					alertCommand2.setExtra2Info("SHOW_SCREENLOCK");					
					logger.log (Level.INFO,"Security mode cleared, switching client to screenlock mode");
				}

				break;

			case DeviceType.ALERT_PHONE :
				alertCommand.setExtraInfo((String)alert.getMessage());			
				break;

			case DeviceType.ALARM_SYSTEM :
				alertCommand.setExtraInfo((String)alert.getMessage());			
				break;

			case DeviceType.ALARM_TYPE :
				alertCommand.setExtraInfo((String)alert.getMessage());			
				break;

			}
			sendToFlash (alertCommand,cache,commandQueue);
			if (alertCommand2 != null) sendToFlash (alertCommand2,cache,commandQueue);
	}

}		
}
	
	
	public void sendToFlash (CommandInterface command, Cache cache ,List commandQueue) {
		cache.setCachedCommand(command.getDisplayName(),command);
		synchronized (commandQueue){
			commandQueue.add(command);
			commandQueue.notifyAll();
		}		
	}
	/**
	 * @return Returns the eTX.
	 */
	public String getETX() {
		return ETX;
	}
	/**
	 * @param etx The eTX to set.
	 */
	public void setETX(String etx) {
		ETX = etx;
	}
	/**
	 * @return Returns the sTX.
	 */
	public String getSTX() {
		return STX;
	}
	/**
	 * @param stx The sTX to set.
	 */
	public void setSTX(String stx) {
		STX = stx;
	}

}
