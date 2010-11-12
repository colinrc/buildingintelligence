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
import au.com.BI.Config.ParameterException;
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
	protected HashMap<String,String> previousValue;
	protected CommandQueue commandQueue = null;
	
	public DoActionHelper() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		previousValue = new HashMap<String,String>(16);
	}

	public void handleReturnCode (CommsCommand raSent, ComfortString comfortString, Cache cache ,ConfigHelper configHelper, DeviceModel comfort) {
		switch (raSent.getActionType()) {
			case CommDevice.MailboxQuery:
				Alert phoneAlert = (Alert)configHelper.getControlItem("AM17");

				if (phoneAlert == null) {
					logger.log (Level.WARNING, "No Alarm entry has been set for AM17, the phone message alarm");
					break;
				}
				if (phoneAlert.isActive()) {
					logger.log(Level.FINER,"Phone messages have been configured to be ignored.");
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
								
							try {
								String lookupValue = comfort.getCatalogueValue(realParam,"COMFORT_USERS",phoneAlert);
								phoneMessage.setExtraInfo(message + lookupValue);
							} catch (ParameterException ex){
								phoneMessage.setExtraInfo(message + "user ID " + realParam);
							} 
								
							sendToFlash (phoneMessage, cache);
						}
					}
				}
			break;

			case CommDevice.AnalogueQuery:
				String deviceKey = raSent.getSrcCommand().getKey();
				if(!comfortString.theParameter.equals ((String)previousValue.get(deviceKey))){
	
					AnalogCommand analogueCommand = new AnalogCommand ("CLIENT_SEND","on",null);
					analogueCommand.setDisplayName(raSent.getDisplayName());
					analogueCommand.setExtraInfo(comfortString.theParameter);
					previousValue.put (deviceKey,comfortString.theParameter);
				
					sendToFlash (analogueCommand, cache);
				}
			break;
	
		}
	}

	public void sendToFlash (CommandInterface command, Cache cache ) {
		cache.setCachedCommand(command.getDisplayName(),command);
		commandQueue.add(command);
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

	public CommandQueue getCommandQueue() {
		return commandQueue;
	}

	public void setCommandQueue(CommandQueue commandQueue) {
		this.commandQueue = commandQueue;
	}


}
