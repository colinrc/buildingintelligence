/*
 * Created on Apr 12, 2004
 *
 * To change the template for this generated file go to
 * Window - Preferences - Java - Code Generation - Code and Comments
 */
package au.com.BI.Comfort;
import au.com.BI.Util.*;
import java.util.*;

import au.com.BI.Command.CommandQueue;
import au.com.BI.Comms.*;
import au.com.BI.Config.ConfigHelper;

import java.util.logging.*;

/**
 * @author colinc
 *
 * To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Generation - Code and Comments
 */
public class Startup {
	/**
	 * 
	 */
	protected String STX;
	protected String ETX;
	protected Logger logger;
	protected CommandQueue commandQueue = null;
	
	public Startup() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}

	public void setSTX (String STX){
		this.STX = STX;
	}

	public void doStartup(ConfigHelper configHelper, CommDevice comms) throws CommsFail {
		synchronized (comms) {
			doInitialCommands (comms); // Commands which have startup but do not have commands listed in the config
			Iterator startupQueryItemList = configHelper.getStartupQueryItemsList();
			while (startupQueryItemList.hasNext()) {
				String key = (String)startupQueryItemList.next();
				DeviceType deviceLine = (DeviceType)configHelper.getStartupQueryItem(key); 
				if (deviceLine != null){
					startupDevice (key,deviceLine.getName(),comms);
				}
			}
			try {
				comms.sendNextCommand(); // force the first command out
			} catch (CommsFail e) {
				logger.log (Level.WARNING,"Startup failed communicating with comfort " + e.getMessage());
				throw new CommsFail ("Startup failed communicating with comfort " + e.getMessage());
			} 
		}
	}

	public void doInitialCommands (CommDevice comms) {
		
		for (int i = 1; i <= 8; i++) {
			String queryLine = "DA6E0" + i;
			CommsCommand mailBox = new CommsCommand("",STX+queryLine + ETX,null,"Phone Messages");
			mailBox.setActionType(CommDevice.MailboxQuery);
			mailBox.setActionCode("MAILBOX_QUERY");
			mailBox.setKeepForHandshake(true);
			//mailBox.setActionParameter(String.valueOf(i));

			logger.log (Level.FINEST,"Queuing startup query " + queryLine);

			try {
				comms.addCommandToQueue(mailBox);
			} catch (CommsFail e) {
				logger.log (Level.WARNING, "Communication failed starting up comfort "+e.getMessage());
			}
		}
	}

	public void startupDevice (String key, String name, CommDevice comms){
		if (key == null) return ;
		String queryLine = "";
		queryLine = key;

		
		if (!queryLine.equals ("") ) {
			logger.log (Level.FINEST,"Queuing startup query " + queryLine);
			try {
				synchronized (comms) {
					comms.addCommandToQueue(new CommsCommand ("",STX+queryLine+ETX,null, name));
				}
			} catch (CommsFail e) {
				logger.log (Level.WARNING, "Communication failed starting up comfort "+e.getMessage());
			}
		}
	}
	

	public void addStartupQueryItem (ConfigHelper configHelper, String name, DeviceType details, int controlType) {
		String theKey = name;
		String keyToSend = "";

		if (name == null) return;
		
		if (details != null) {
			int deviceType = ((DeviceType)details).getDeviceType();

			if (controlType == DeviceType.INPUT) {
				switch (deviceType) {
					case DeviceType.TOGGLE_INPUT:
						keyToSend = "I?" + theKey;
						break;

					case DeviceType.LIGHT_CBUS: case DeviceType.COUNTER:
						keyToSend = "C?" + theKey;
					break;

					case DeviceType.ALERT:
						int alarmTypeCode =((au.com.BI.Alert.Alert)details).getAlarmTypeCode();
						switch (alarmTypeCode) {
							case DeviceType.ALERT_MODE_CHANGE :
								keyToSend = "M?";
								break;
							case DeviceType.ALARM_TYPE:
								keyToSend = "a?";
								break;
						}
						break;	
				}
			}

			if (controlType == DeviceType.OUTPUT) {
				switch (deviceType) {
					case DeviceType.TOGGLE_OUTPUT: case DeviceType.TOGGLE_OUTPUT_MONITOR : case DeviceType.PULSE_OUTPUT :
						keyToSend = "O?" + theKey;
						break;
						
					case DeviceType.LIGHT_CBUS: case DeviceType.COUNTER : 
						keyToSend = "C?" + theKey;
					break;

				}
			}
			
			if (controlType == DeviceType.MONITORED) {
				switch (deviceType) {
					
					case DeviceType.TOGGLE_OUTPUT: case DeviceType.TOGGLE_OUTPUT_MONITOR : case DeviceType.PULSE_OUTPUT :
						keyToSend = "O?" + theKey;
						break;
						
					case DeviceType.LIGHT_CBUS: case DeviceType.COUNTER: 
						keyToSend = "C?" + theKey;
					break;

					case DeviceType.TOGGLE_INPUT:
						keyToSend = "I?" + theKey;
					break;

					case DeviceType.ALERT:
						int alarmTypeCode =((au.com.BI.Alert.Alert)details).getAlarmTypeCode();
						switch (alarmTypeCode) {
						case DeviceType.ALERT_MODE_CHANGE :
							keyToSend = "M?";
							break;
						case DeviceType.ALARM_TYPE : 
							keyToSend = "a?";
							break;
						}
						
					break;	
				}
			}
	
		}

		if (!keyToSend.equals ("")) {
			configHelper.addStartupQueryItem(keyToSend, details, controlType);
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

	public CommandQueue getCommandQueue() {
		return commandQueue;
	}

	public void setCommandQueue(CommandQueue commandQueue) {
		this.commandQueue = commandQueue;
	}
}
