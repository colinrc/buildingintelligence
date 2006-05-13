/*
 * Created on May 2, 2004
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
import au.com.BI.Flash.ClientCommand;
import au.com.BI.CustomInput.*;
import au.com.BI.Analog.*;
import au.com.BI.X10.*;

/**
 * @author colinc
 */
public class InputHelper {
	/**
	 * 
	 */
	protected Logger logger;
	protected String STX;
	protected String ETX;
	
	public InputHelper() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	public void doInputItem (CommandInterface command, ComfortString comfortString, ConfigHelper configHelper, Cache cache, List commandQueue) throws CommsFail
	{
		DeviceType deviceType = (DeviceType)configHelper.getInputItem(comfortString.comfortKey);
		int commandCode = DeviceType.UKNOWN_EVENT;
		
		switch (deviceType.getDeviceType() ) {
			case DeviceType.TOGGLE_INPUT : 
					CommandInterface toggleSwitchCommand = (CommandInterface)((ToggleSwitch)deviceType).buildDisplayCommand ();
					toggleSwitchCommand.setUser(command.getUser());
					toggleSwitchCommand.setKey ("CLIENT_SEND");
					
					if (comfortString.theParameter.equals("01")){
						toggleSwitchCommand.setCommand ("on");
						toggleSwitchCommand.setExtraInfo ("100");
				 	}					
					if (comfortString.theParameter.equals("00")){
						toggleSwitchCommand.setCommand ("off");
						toggleSwitchCommand.setExtraInfo ("0");
					}					
					sendToFlash (toggleSwitchCommand, cache,commandQueue);
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

					
			case DeviceType.CUSTOM_INPUT:
					logger.log(Level.FINEST, "Received custom command " + comfortString.comfortKey);
					CustomInput inputFascade = (CustomInput)deviceType;
					ClientCommand clientCommand = new ClientCommand ();
					clientCommand.setKey(inputFascade.getOutputKey());
					clientCommand.setCommand(inputFascade.getCommand());				
					if (inputFascade.getExtra() != null)
					    clientCommand.setExtraInfo(inputFascade.getExtra());
					else 
					    clientCommand.setExtraInfo(comfortString.getTheParameter());
					
					synchronized (commandQueue){
						commandQueue.add(clientCommand);
					}	
					
					CustomInputCommand flashCommand = new CustomInputCommand ();
					flashCommand.setKey ("CLIENT_SEND");
					flashCommand.setDisplayName(inputFascade.getOutputKey());
					flashCommand.setCommand(inputFascade.getCommand());
					if (inputFascade.getExtra() != null)
						flashCommand.setExtraInfo(inputFascade.getExtra());
					else 
						flashCommand.setExtraInfo(comfortString.getTheParameter());

					sendToFlash (clientCommand, cache,commandQueue);
					break;

		case DeviceType.	COMFORT_LIGHT_X10_UNITCODE:
			comfortString.setLastHouseCode();
			break;

		case DeviceType.COMFORT_LIGHT_X10:
			X10Command x10LightCommand = (X10Command)((LightFascade)deviceType).buildDisplayCommand ();
			x10LightCommand.setKey ("CLIENT_SEND");
			x10LightCommand.setUser(command.getUser());
							
			if (comfortString.theParameter.equals("07")){
				x10LightCommand.setCommand ("off");
				x10LightCommand.setExtraInfo ("0");
			} 
			if (comfortString.theParameter.equals("05") || comfortString.theParameter.equals("03") || comfortString.theParameter.equals("01")){
				x10LightCommand.setCommand ("on");
				x10LightCommand.setExtraInfo ("100");
			} 
			sendToFlash (x10LightCommand, cache, commandQueue);
			break;
		}
	}

	
	public void sendToFlash (CommandInterface command, Cache cache ,List commandQueue) {
		cache.setCachedCommand(command.getDisplayName(),command);
		synchronized (commandQueue){
			commandQueue.add(command);
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
