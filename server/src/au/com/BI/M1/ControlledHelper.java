package au.com.BI.M1;

import java.util.Date;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.AlarmLogging.AlarmLogging;
import au.com.BI.Alert.AlertCommand;
import au.com.BI.Comfort.DoActionHelper;
import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Comms.CommDevice;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.M1.Model;
import au.com.BI.M1.Commands.M1Command;
import au.com.BI.M1.Commands.M1CommandFactory;
import au.com.BI.M1.Commands.OutputChangeUpdate;
import au.com.BI.M1.Commands.ZoneChangeUpdate;
import au.com.BI.M1.Commands.ZoneStatus;
import au.com.BI.ToggleSwitch.ToggleSwitch;
import au.com.BI.Util.BaseDevice;
import au.com.BI.Util.DeviceType;

public class ControlledHelper {
	
	protected Logger logger;
	protected AlarmLogging alarmLogger;
	
	public ControlledHelper() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		alarmLogger = new AlarmLogging();
	}
	
	/**
	 * Parse the command for a controlled item.
	 * @param command
	 * @param configHelper
	 * @param cache
	 * @param commandQueue
	 * @param m1
	 * @throws CommsFail
	 */
	public void doControlledItem (CommandInterface command, 
			ConfigHelper configHelper,
			Cache cache,
			List commandQueue, 
			Model m1) throws CommsFail {
		
		// Check to see if it is a comms command
		if (command.isCommsCommand()){	
			
			// create the command object and cache it
			String theKey = command.getKey();
			CommandInterface m1Command =  buildCommandForFlash(command, configHelper, m1);
			if (m1Command == null) return;
			
			cache.setCachedCommand(m1Command.getDisplayName(),m1Command);
			
			// Check the command class
			if (m1Command.getClass().equals(ZoneChangeUpdate.class)) {
				ZoneChangeUpdate zoneChangeUpdate = (ZoneChangeUpdate)m1Command;
				alarmLogger.setCache(cache);
				alarmLogger.setCommandQueue(commandQueue);
				
				if (zoneChangeUpdate.getZoneStatus() == ZoneStatus.NORMAL_UNCONFIGURED) {
					
					alarmLogger.addAlertLog("ALERT",
							"Normal - Unconfigured",
							AlarmLogging.GENERAL_MESSAGE,
							((BaseDevice)configHelper.getControlItem(zoneChangeUpdate.getZone())).getOutputKey(),
							zoneChangeUpdate.getZoneStatus().getDescription(),
							m1.currentUser,
							new Date());
				} else if (zoneChangeUpdate.getZoneStatus() == ZoneStatus.NORMAL_OPEN) {
					
					alarmLogger.addAlertLog("ALERT",
							"Normal - Unconfigured",
							AlarmLogging.GENERAL_MESSAGE,
							((BaseDevice)configHelper.getControlItem(zoneChangeUpdate.getZone())).getOutputKey(),
							zoneChangeUpdate.getZoneStatus().getDescription(),
							m1.currentUser,
							new Date());
				} else if (zoneChangeUpdate.getZoneStatus() == ZoneStatus.NORMAL_EOL) {
					/* Dave this is just normal PIR strigger 
					alarmLogger.addAlertLog("ALERT",
							"Normal - EOL",
							AlarmLogging.GENERAL_MESSAGE,
							((BaseDevice)configHelper.getControlItem(zoneChangeUpdate.getZone())).getOutputKey(),
							zoneChangeUpdate.getZoneStatus().getDescription(),
							m1.currentUser,
							new Date());
							*/
				} else if (zoneChangeUpdate.getZoneStatus() == ZoneStatus.NORMAL_SHORT) {
					
					alarmLogger.addAlertLog("ALERT",
							"Normal - Short",
							AlarmLogging.GENERAL_MESSAGE,
							((BaseDevice)configHelper.getControlItem(zoneChangeUpdate.getZone())).getOutputKey(),
							zoneChangeUpdate.getZoneStatus().getDescription(),
							m1.currentUser,
							new Date());
				} else if (zoneChangeUpdate.getZoneStatus() == ZoneStatus.TROUBLE_OPEN) {
					
					alarmLogger.addAlarmLog("ALARM",
							"Trouble - Open",
							AlarmLogging.TROUBLE,
							((BaseDevice)configHelper.getControlItem(zoneChangeUpdate.getZone())).getOutputKey(),
							zoneChangeUpdate.getZoneStatus().getDescription(),
							m1.currentUser,
							new Date());
				} else if (zoneChangeUpdate.getZoneStatus() == ZoneStatus.TROUBLE_EOL) {
					
					alarmLogger.addAlarmLog("ALARM",
							"Trouble - EOL",
							AlarmLogging.TROUBLE,
							((BaseDevice)configHelper.getControlItem(zoneChangeUpdate.getZone())).getOutputKey(),
							zoneChangeUpdate.getZoneStatus().getDescription(),
							m1.currentUser,
							new Date());
				} else if (zoneChangeUpdate.getZoneStatus() == ZoneStatus.TROUBLE_SHORT) {
					
					alarmLogger.addAlarmLog("ALARM",
							"Trouble - Short",
							AlarmLogging.TROUBLE,
							((BaseDevice)configHelper.getControlItem(zoneChangeUpdate.getZone())).getOutputKey(),
							zoneChangeUpdate.getZoneStatus().getDescription(),
							m1.currentUser,
							new Date());
				} else if (zoneChangeUpdate.getZoneStatus() == ZoneStatus.VIOLATED_OPEN) {
					
					alarmLogger.addAlarmLog("ALARM",
							"Violated - Open",
							AlarmLogging.VIOLATED,
							((BaseDevice)configHelper.getControlItem(zoneChangeUpdate.getZone())).getOutputKey(),
							zoneChangeUpdate.getZoneStatus().getDescription(),
							m1.currentUser,
							new Date());
				} else if (zoneChangeUpdate.getZoneStatus() == ZoneStatus.VIOLATED_EOL) {
					
					alarmLogger.addAlarmLog("ALARM",
							"Violated - EOL",
							AlarmLogging.VIOLATED,
							((BaseDevice)configHelper.getControlItem(zoneChangeUpdate.getZone())).getOutputKey(),
							zoneChangeUpdate.getZoneStatus().getDescription(),
							m1.currentUser,
							new Date());
				} else if (zoneChangeUpdate.getZoneStatus() == ZoneStatus.VIOLATED_SHORT) {
					/* Dave this is just normal PIR strigger 
					alarmLogger.addAlarmLog("ALARM",
							"Violated - Short",
							AlarmLogging.VIOLATED,
							((BaseDevice)configHelper.getControlItem(zoneChangeUpdate.getZone())).getOutputKey(),
							zoneChangeUpdate.getZoneStatus().getDescription(),
							m1.currentUser,
							new Date());
							*/
				} else if (zoneChangeUpdate.getZoneStatus() == ZoneStatus.BYPASSED_OPEN) {
					
					alarmLogger.addAlarmLog("ALARM",
							"Bypassed - Open",
							AlarmLogging.BYPASSED,
							((BaseDevice)configHelper.getControlItem(zoneChangeUpdate.getZone())).getOutputKey(),
							zoneChangeUpdate.getZoneStatus().getDescription(),
							m1.currentUser,
							new Date());
				} else if (zoneChangeUpdate.getZoneStatus() == ZoneStatus.BYPASSED_EOL) {
					
					alarmLogger.addAlarmLog("ALARM",
							"Bypassed - EOL",
							AlarmLogging.BYPASSED,
							((BaseDevice)configHelper.getControlItem(zoneChangeUpdate.getZone())).getOutputKey(),
							zoneChangeUpdate.getZoneStatus().getDescription(),
							m1.currentUser,
							new Date());
				} else if (zoneChangeUpdate.getZoneStatus() == ZoneStatus.BYPASSED_SHORT) {
					
					alarmLogger.addAlarmLog("ALARM",
							"Bypassed - Short",
							AlarmLogging.BYPASSED,
							((BaseDevice)configHelper.getControlItem(zoneChangeUpdate.getZone())).getOutputKey(),
							zoneChangeUpdate.getZoneStatus().getDescription(),
							m1.currentUser,
							new Date());
				}
			}
			
			this.sendToFlash(commandQueue,-1,m1Command);
		}
	}

	public void sendToFlash (List commandQueue,
			long targetFlashID,
			CommandInterface command) {

		/*
		 * todo change the PIR's to ToggleSwitches and the others to alarms
		 * todo check the device type - if toggle switch then send on/off signal and an alert
		 * todo if it is a alarm then send an alert
		 * todo only do an alert if the alarm is in trouble, violated or bypassed
		 */
		command.setTargetDeviceID(targetFlashID);
		synchronized (commandQueue){
			commandQueue.add(command);
			commandQueue.notifyAll();
		}
	}
	
	protected CommandInterface buildCommandForFlash (CommandInterface command,
			ConfigHelper configHelper,
			Model m1){
		M1Command m1Command = M1CommandFactory.getInstance().getM1Command(command.getKey());
		if (m1Command == null) return null;
		
		BaseDevice configDevice = ((BaseDevice)configHelper.getControlItem(m1Command.getKey()));

		if (configDevice != null){

			boolean commandFound = false;
			
			if (m1Command.getClass().equals(OutputChangeUpdate.class)) {
				commandFound = true;
				// Dave check this. the PIR triggers the Short, sort of makes sense, in other words the violate short means PIR on
				// violate EOL means off.  
			
				if (((OutputChangeUpdate)m1Command).getOutputState().equals("0")) {
					m1Command.setCommand("off");
				} else {
					m1Command.setCommand("on");
				}
					m1Command.setDisplayName(configDevice.getOutputKey());
				}
			
			if (m1Command.getClass().equals(ZoneChangeUpdate.class) ) {
				commandFound = true;
				// Dave check this. the PIR triggers the Short, sort of makes sense, in other words the violate short means PIR on
				// violate EOL means off.  
			
				if (((ZoneChangeUpdate)m1Command).getOutputState().equals("0")) {
					m1Command.setCommand("off");
				} else {
					m1Command.setCommand("on");
				}
					m1Command.setDisplayName(configDevice.getOutputKey());
				}

				 
	      if (!commandFound){
				m1Command.setDisplayName(configDevice.getOutputKey());
			}
			
			m1Command.setKey("CLIENT_SEND");
			m1Command.setUser(m1.currentUser);
			return m1Command;
		} else {
			return null;
		
		}
	}
}
