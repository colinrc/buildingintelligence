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
import au.com.BI.Alert.*;
import au.com.BI.Analog.*;


/**
 * @author colinc
 */
public class DoActionHelper {
	/**
	 * 
	 */
	protected Logger logger;
	protected String STX;
	protected String ETX;
	protected HashMap previousValue;
	protected String comfort_users;
	
	public DoActionHelper() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		previousValue = new HashMap(16);
	}

	public void handleReturnCode (CommsCommand raSent, ComfortString comfortString, Cache cache ,List commandQueue, ConfigHelper configHelper, DeviceModel comfort) {
		switch (raSent.getActionType()) {
			case CommDevice.MailboxQuery:
				Alert phoneAlert = (Alert)configHelper.getControlItem("AM17");

				if (!phoneAlert.isActive()) {
					logger.log(Level.FINE,"Phone messages have been configured to not be ignored.");
					break;
				}
				if (phoneAlert == null) {
					logger.log (Level.WARNING, "No Alarm entry has been set for AM17, the phone message alarm");
				}
				else {
					String message = phoneAlert.getMessage();
					byte returnParam = new Integer(comfortString.theParameter).byteValue();
					for (int i=1; i <= 8; i++) {
						if ((returnParam & (1 << (i-1))) != 0) {
							logger.log (Level.FINE,"Phone message received for user " + i);
							AlertCommand phoneMessage = new AlertCommand ("CLIENT_SEND","on",null);
							phoneMessage.setDisplayName(phoneAlert.getOutputKey());
							
							String realParam = "0" + i ;
								
							String lookupValue = configHelper.getCatalogueValue(realParam,comfort_users,comfort);
							if (lookupValue == null)
								phoneMessage.setExtraInfo(message + "user ID " + realParam);
							else
								phoneMessage.setExtraInfo(message + lookupValue);
								
							sendToFlash (phoneMessage, cache, commandQueue);
						}
					}
				}
			break;

			case CommDevice.AnalogueQuery:
				String deviceKey = raSent.getSrcCommand().getKey();
				if(!comfortString.theParameter.equals ((String)previousValue.get(deviceKey))){
					int returnParam = new Integer(comfortString.theParameter).byteValue();
	
					AnalogCommand analogueCommand = new AnalogCommand ("CLIENT_SEND","on",null);
					analogueCommand.setDisplayName(raSent.getDisplayName());
					analogueCommand.setExtraInfo(comfortString.theParameter);
					previousValue.put (deviceKey,comfortString.theParameter);
				
					sendToFlash (analogueCommand, cache, commandQueue);
				}
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
	/**
	 * @return Returns the comfort_users.
	 */
	public String getComfort_users() {
		return comfort_users;
	}
	/**
	 * @param comfort_users The comfort_users to set.
	 */
	public void setComfort_users(String comfort_users) {
		this.comfort_users = comfort_users;
	}
}
