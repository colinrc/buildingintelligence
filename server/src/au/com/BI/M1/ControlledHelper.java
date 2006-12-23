package au.com.BI.M1;

import java.util.Date;
import java.util.Iterator;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.AlarmLogging.AlarmLogging;
import au.com.BI.Alert.AlertCommand;
import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Command.CommandQueue;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.Device.DeviceType;
import au.com.BI.Lights.LightFascade;
import au.com.BI.M1.Model;
import au.com.BI.M1.Commands.AreaAlarmState;
import au.com.BI.M1.Commands.ArmAndDisarmMessage;
import au.com.BI.M1.Commands.ArmToAway;
import au.com.BI.M1.Commands.ArmStepToNextAwayMode;
import au.com.BI.M1.Commands.ArmToNight;
import au.com.BI.M1.Commands.ArmStepToNextStayMode;
import au.com.BI.M1.Commands.ArmToNightInstant;
import au.com.BI.M1.Commands.ArmToStayHome;
import au.com.BI.M1.Commands.ArmToStayInstant;
import au.com.BI.M1.Commands.ArmToVacation;
import au.com.BI.M1.Commands.ArmUpState;
import au.com.BI.M1.Commands.ArmedStatus;
import au.com.BI.M1.Commands.ControlOutputStatusReport;
import au.com.BI.M1.Commands.Disarm;
import au.com.BI.M1.Commands.Group;
import au.com.BI.M1.Commands.M1Command;
import au.com.BI.M1.Commands.M1CommandFactory;
import au.com.BI.M1.Commands.OutputChangeUpdate;
import au.com.BI.M1.Commands.PLCChangeUpdate;
import au.com.BI.M1.Commands.PLCLevelStatus;
import au.com.BI.M1.Commands.PLCStatusReturned;
import au.com.BI.M1.Commands.ReplyAlarmByZoneReportData;
import au.com.BI.M1.Commands.ReplyArmingStatusReportData;
import au.com.BI.M1.Commands.RequestTemperatureReply;
import au.com.BI.M1.Commands.TasksChangeUpdate;
import au.com.BI.M1.Commands.ZoneChangeUpdate;
import au.com.BI.M1.Commands.ZoneDefinition;
import au.com.BI.M1.Commands.ZoneStatus;
import au.com.BI.M1.Commands.ZoneStatusReport;
import au.com.BI.Sensors.SensorFascade;
import au.com.BI.Util.BaseDevice;
import au.com.BI.Util.Utility;

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
	 * 
	 * @param command
	 * @param configHelper
	 * @param cache
	 * @param commandQueue
	 * @param m1
	 * @throws CommsFail
	 */
	public void doControlledItem(CommandInterface command,
			ConfigHelper configHelper, Cache cache, CommandQueue commandQueue,
			Model m1) throws CommsFail {

		boolean sendCommandToFlash = true;

		// Check to see if it is a comms command
		if (command.isCommsCommand()) {

			CommandInterface m1Command = buildCommandForFlash(command,
					configHelper, m1);
			if (m1Command == null)
				return;

			// Check the command class
			if (m1Command.getClass().equals(ZoneChangeUpdate.class)) {
				ZoneChangeUpdate zoneChangeUpdate = (ZoneChangeUpdate) m1Command;

				BaseDevice theDevice = (BaseDevice) configHelper.getControlledItem(zoneChangeUpdate.getZone() + "CC"); 
				if (theDevice == null) return;
				String outputKey = theDevice.getOutputKey();
				
				handleZoneState(cache, commandQueue, m1, zoneChangeUpdate.getZoneStatus(), theDevice);
				
			} else if (m1Command.getClass().equals(ZoneStatusReport.class)) {
				ZoneStatusReport zoneStatusReport = (ZoneStatusReport)m1Command;
				
				for (int i=0;i<zoneStatusReport.getZoneStatus().length; i++) {
					ZoneStatus zoneStatus = zoneStatusReport.getZoneStatus()[i];
					
					BaseDevice theDevice = (BaseDevice) configHelper.getControlledItem(Utility.padString(Integer.toString(i), 3) + "CC"); 
					
					// See if the input is a controlled device
					if (theDevice != null) {
						// if it is then send the command
						handleZoneState (cache, commandQueue, m1, zoneStatus, theDevice);
					}
				}
			} else if (m1Command.getClass().equals(
					RequestTemperatureReply.class)) {
				RequestTemperatureReply requestTemperatureReply = (RequestTemperatureReply) m1Command;

				int adjustedTemperature = Integer
						.parseInt(requestTemperatureReply.getTemperature());

				// adjust the temperatures for the probes and keypads. All temps
				// are in farenheit
				if (requestTemperatureReply.getGroup().equals(
						Group.TEMPERATURE_PROBE)) {
					adjustedTemperature = adjustedTemperature - 60;
				} else if (requestTemperatureReply.getGroup().equals(
						Group.KEYPAD)) {
					adjustedTemperature = adjustedTemperature - 40;
				}

				SensorFascade sensor = (SensorFascade) configHelper
						.getControlledItem(requestTemperatureReply.getDevice());

				// send the alert command.
				CommandInterface _command = new M1FlashCommand();
				_command.setDisplayName(sensor.getOutputKey());
				_command.setTargetDeviceID(-1);
				_command.setUser(m1.currentUser);
				_command.setExtraInfo(Integer.toString(adjustedTemperature));
				_command.setExtra2Info(requestTemperatureReply.getGroup()
						.getDescription());
				_command.setKey("CLIENT_SEND");
				_command.setCommand("on");

				// we need to store the current state of the temperature - it is
				// not getting cached properly

				if (sensor.getTemperature() == null
						|| !sensor.getTemperature().equals(
								_command.getExtraInfo())) {
					cache.setCachedCommand(_command.getDisplayName(), _command);

					logger.log(Level.FINER,
							"Sending temperature to flash for group:"
									+ requestTemperatureReply.getGroup()
											.toString() + ":device:"
									+ requestTemperatureReply.getDevice() + ":"
									+ adjustedTemperature);
					sensor.setTemperature(_command.getExtraInfo());

					sendToFlash(commandQueue, -1, _command);
				} else {
					sendCommandToFlash = false;
					logger.log(Level.FINER,
							"Did not send temperature to flash for group:"
									+ requestTemperatureReply.getGroup()
											.toString() + ":device:"
									+ requestTemperatureReply.getDevice()
									+ " as the temperature has not changed");
				}
			} else if (m1Command.getClass().equals(
					ControlOutputStatusReport.class)) {
				ControlOutputStatusReport statusReport = (ControlOutputStatusReport) m1Command;

				// send out output change updates
				for (int i = 0; i < statusReport.getOutputStatus().length; i++) {

					BaseDevice device = (BaseDevice) configHelper
							.getControlledItem(Utility.padString(Integer
									.toString(i), 3)
									+ "TOUT");

					if (device != null) {
						CommandInterface _command = new M1FlashCommand();
						_command.setDisplayName(device.getOutputKey());
						_command.setTargetDeviceID(-1);
						_command.setUser(m1.currentUser);
						if (statusReport.getOutputStatus()[i]) {
							_command.setCommand("on");
						} else {
							_command.setCommand("off");
						}
						_command.setKey("CLIENT_SEND");
						cache.setCachedCommand(_command.getDisplayName(), _command);

						logger.log(Level.FINER, "Sending "
								+ _command.getCommandCode() + " command to "
								+ device.getOutputKey());
						sendToFlash(commandQueue, -1, _command);
					}
				}
			} else if (m1Command.getClass().equals(
					ReplyArmingStatusReportData.class)) {
				ReplyArmingStatusReportData statusReport = (ReplyArmingStatusReportData) m1Command;

				for (int i = 0; i < statusReport.getAreaAlarmState().length; i++) {
					ArmedStatus armedStatus = statusReport.getArmedStatus()[i];
					ArmUpState armUpState = statusReport.getArmUpState()[i];
					AreaAlarmState areaAlarmState = statusReport
							.getAreaAlarmState()[i];
					ArmedStatus oldArmedStatus;
					ArmUpState oldArmUpState;
					
					Integer zone = new Integer(i);
					if (m1.getArmingStates().containsKey(zone)) {
						oldArmedStatus = (ArmedStatus)m1.getArmingStates().get(zone);
					} else {
						oldArmedStatus = (ArmedStatus)m1.getArmingStates().put(zone, armedStatus);
					}
					if (m1.getArmUpStates().containsKey(zone)) {
						oldArmUpState = (ArmUpState)m1.getArmUpStates().get(zone);
					} else {
						oldArmUpState = (ArmUpState)m1.getArmUpStates().put(zone, armUpState);
					}
					
					if (oldArmedStatus == null){
						logger.log (Level.INFO,"Old arm status is null");
					}
					if (armedStatus == null){
						logger.log (Level.INFO,"Armed status is null");
					}
					if ((oldArmedStatus != null && armedStatus == null )  && !oldArmedStatus.equals(armedStatus)) {
						CommandInterface _command = new AlertCommand();
						_command.setDisplayName("Arming Status");
						_command.setTargetDeviceID(-1);
						_command.setUser(m1.currentUser);
						_command.setCommand("ARMING STATUS");
						_command.setExtraInfo(Integer.toString(i));
						_command.setExtra2Info(armedStatus.getDescription());
						_command.setExtra3Info(armUpState.getDescription());
						_command.setExtra4Info(areaAlarmState.getDescription());
						_command.setKey("CLIENT_SEND");
						cache.setCachedCommand(_command.getDisplayName(), _command);

						logger.log(Level.FINER, "Sending "
								+ _command.getCommandCode() + " ArmedStatus="
								+ _command.getExtraInfo() + " ArmUpState="
								+ _command.getExtra2Info() + " AreaAlarmState="
								+ _command.getExtra3Info());
						sendToFlash(commandQueue, -1, _command);
					}
				}
			} else if (m1Command.getClass().equals(Disarm.class)
					|| m1Command.getClass().equals(ArmToAway.class)
					|| m1Command.getClass().equals(ArmToStayHome.class)
					|| m1Command.getClass().equals(ArmToStayInstant.class)
					|| m1Command.getClass().equals(ArmToNight.class)
					|| m1Command.getClass().equals(ArmToNightInstant.class)
					|| m1Command.getClass().equals(ArmToVacation.class)
					|| m1Command.getClass().equals(ArmStepToNextAwayMode.class)
					|| m1Command.getClass().equals(ArmStepToNextStayMode.class)) {

				ArmAndDisarmMessage armDisarm = (ArmAndDisarmMessage) m1Command;
				CommandInterface _command = new AlertCommand();
				_command.setDisplayName("Arm/Disarm");
				_command.setTargetDeviceID(-1);
				_command.setUser(m1.currentUser);

				if (m1Command.getClass().equals(Disarm.class)) {
					_command.setCommand("DISARM");
				} else if (m1Command.getClass().equals(ArmToAway.class)) {
					_command.setCommand("ARMED AWAY");
				} else if (m1Command.getClass().equals(ArmToStayHome.class)) {
					_command.setCommand("ARMED STAY");
				} else if (m1Command.getClass().equals(ArmToStayInstant.class)) {
					_command.setCommand("ARMED STAY INSTANT");
				} else if (m1Command.getClass().equals(ArmToNight.class)) {
					_command.setCommand("ARMED NIGHT");
				} else if (m1Command.getClass().equals(ArmToNightInstant.class)) {
					_command.setCommand("ARMED NIGHT INSTANT");
				} else if (m1Command.getClass().equals(ArmToVacation.class)) {
					_command.setCommand("ARMED VACATION");
				} else if (m1Command.getClass().equals(
						ArmStepToNextAwayMode.class)) {
					_command.setCommand("ARM TO NEXT AWAY MODE");
				} else if (m1Command.getClass().equals(
						ArmStepToNextStayMode.class)) {
					_command.setCommand("ARM TO NEXT STAY MODE");
				}
				_command.setExtraInfo(armDisarm.getPartition());
				_command.setKey("CLIENT_SEND");
				cache.setCachedCommand(_command.getDisplayName(), _command);

				logger.log(Level.FINER, "Sending " + _command.getCommandCode());
				sendToFlash(commandQueue, -1, _command);
			} else if (m1Command.getClass().equals(
					ReplyAlarmByZoneReportData.class)) {
				ReplyAlarmByZoneReportData zoneReport = (ReplyAlarmByZoneReportData) m1Command;

				for (int i = 0; i < zoneReport.getZoneDefinition().length; i++) {
					ZoneDefinition zoneDefinition = zoneReport
							.getZoneDefinition()[i];

					CommandInterface _command = new AlertCommand();
					_command.setDisplayName("Zone Definition");
					_command.setTargetDeviceID(-1);
					_command.setUser(m1.currentUser);
					_command.setCommand("ZONE DEFINITION");
					_command.setExtraInfo(Integer.toString(i));
					_command.setExtra2Info(zoneDefinition.getDescription());
					_command.setKey("CLIENT_SEND");
					cache.setCachedCommand(_command.getDisplayName(), _command);

					logger.log(Level.FINER, "Sending "
							+ _command.getCommandCode() + " ArmedStatus="
							+ _command.getExtraInfo() + " ArmUpState="
							+ _command.getExtra2Info() + " AreaAlarmState="
							+ _command.getExtra3Info());
					sendToFlash(commandQueue, -1, _command);
				}
			} else if (m1Command.getClass().equals(TasksChangeUpdate.class)) {
				TasksChangeUpdate tasksChangeUpdate = (TasksChangeUpdate) m1Command;
				CommandInterface _command = new AlertCommand();
				_command.setDisplayName("TASK_ACTIVATION_REQUEST");
				_command.setTargetDeviceID(-1);
				_command.setUser(m1.currentUser);
				_command.setCommand("TASK_ACTIVATION_REQUEST");
				_command.setExtraInfo(tasksChangeUpdate.getTask());
				_command.setKey("CLIENT_SEND");
				cache.setCachedCommand(_command.getDisplayName(), _command);

				logger.log(Level.FINER, "Sending " + _command.getCommandCode()
						+ " task=" + _command.getExtraInfo());
				sendToFlash(commandQueue, -1, _command);
			} else if (m1Command.getClass().equals(PLCChangeUpdate.class)) {

				PLCChangeUpdate plcChangeUpdate = (PLCChangeUpdate) m1Command;

				if (plcChangeUpdate.getLevelStatus() == PLCLevelStatus.X10_ALL_LIGHTS_OFF) {
					// turn all X10 lights off
					Iterator iterator = configHelper.getAllControlledDevices();

					while (iterator.hasNext()) {
						Object obj = iterator.next();

						if (obj.getClass().equals(LightFascade.class)) {
							LightFascade light = (LightFascade) obj;

							if (light.getDeviceType() == DeviceType.COMFORT_LIGHT_X10) {
								CommandInterface _command = new M1FlashCommand();
								_command.setDisplayName(light.getOutputKey());
								_command.setTargetDeviceID(-1);
								_command.setUser(m1.currentUser);
								_command.setCommand("off");
								_command.setExtraInfo("0");
								_command.setKey("CLIENT_SEND");
								cache.setCachedCommand(_command.getDisplayName(),
										_command);

								logger
										.log(Level.FINER, "Sending "
												+ _command.getCommandCode()
												+ " command to "
												+ light.getOutputKey());
								sendToFlash(commandQueue, -1, _command);
							}
						}
					}
				} else if (plcChangeUpdate.getLevelStatus() == PLCLevelStatus.X10_ALL_LIGHTS_ON) {
					// turn all X10 lights on
					Iterator iterator = configHelper.getAllControlledDevices();

					while (iterator.hasNext()) {
						Object obj = iterator.next();

						if (obj.getClass().equals(LightFascade.class)) {
							LightFascade light = (LightFascade) obj;

							if (light.getDeviceType() == DeviceType.COMFORT_LIGHT_X10) {
								CommandInterface _command = new M1FlashCommand();
								_command.setDisplayName(light.getOutputKey());
								_command.setTargetDeviceID(-1);
								_command.setUser(m1.currentUser);
								_command.setCommand("on");
								_command.setExtraInfo("100");
								_command.setKey("CLIENT_SEND");
								cache.setCachedCommand(_command.getDisplayName(),
										_command);

								logger
										.log(Level.FINER, "Sending "
												+ _command.getCommandCode()
												+ " command to "
												+ light.getOutputKey());
								sendToFlash(commandQueue, -1, _command);
							}
						}
					}
				} else if (plcChangeUpdate.getLevelStatus() == PLCLevelStatus.X10_ALL_UNITS_OFF) {
					// turn all X10 units off
					Iterator iterator = configHelper.getAllControlledDevices();

					while (iterator.hasNext()) {
						Object obj = iterator.next();

						if (obj.getClass().equals(LightFascade.class)) {
							LightFascade light = (LightFascade) obj;

							if (light.getDeviceType() == DeviceType.COMFORT_LIGHT_X10
									|| light.getDeviceType() == DeviceType.COMFORT_LIGHT_SWITCH_X10
									|| light.getDeviceType() == DeviceType.COMFORT_LIGHT_X10_UNITCODE) {
								CommandInterface _command = new M1FlashCommand();
								_command.setDisplayName(light.getOutputKey());
								_command.setTargetDeviceID(-1);
								_command.setUser(m1.currentUser);
								_command.setCommand("off");
								_command.setExtraInfo("0");
								_command.setKey("CLIENT_SEND");
								cache.setCachedCommand(_command.getDisplayName(),
										_command);

								logger
										.log(Level.FINER, "Sending "
												+ _command.getCommandCode()
												+ " command to "
												+ light.getOutputKey());
								sendToFlash(commandQueue, -1, _command);
							}
						}
					}
				} else {

					LightFascade theLight = (LightFascade) configHelper.getControlledItem(plcChangeUpdate.getUnitCode()
							+ "X10" + plcChangeUpdate.getHouseCode());
					if (theLight == null) {
						logger.log (Level.FINEST,"Received M1 event for a PLC light has not been configured");
						return;
					}
					String outputKey = theLight.getOutputKey();

					if (outputKey != null) {
						CommandInterface _command = new M1FlashCommand();
						_command.setDisplayName(outputKey);
						_command.setTargetDeviceID(-1);
						_command.setUser(m1.currentUser);
						if (plcChangeUpdate.getLevelStatus() == PLCLevelStatus.ON) {
							_command.setCommand("on");
							_command.setExtraInfo("100");
						} else if (plcChangeUpdate.getLevelStatus() == PLCLevelStatus.OFF) {
							_command.setCommand("off");
							_command.setExtraInfo("0");
						} else {
							_command.setCommand("on");
							_command.setExtraInfo(plcChangeUpdate
									.getLevelStatus().getValue());
						}
						_command.setKey("CLIENT_SEND");
						cache.setCachedCommand(_command.getDisplayName(), _command);

						logger.log(Level.FINER, "Sending "
								+ _command.getCommandCode() + " command to "
								+ outputKey);
						sendToFlash(commandQueue, -1, _command);
					}
				}

			} else if (m1Command.getClass().equals(PLCStatusReturned.class)) {
				PLCStatusReturned statusReport = (PLCStatusReturned) m1Command;

				// send out PLC change updates
				for (int i = 0; i < statusReport.getLevels().length; i++) {

					int bank = Integer.parseInt(statusReport.getBank());
					char[] houseCodeChar = new char[1];
					houseCodeChar[0] = (char) ((65+(bank*4)+(i / 16)));
					
					String houseCode = new String(houseCodeChar);
					String unitCode = Integer.toString(i%16+1);
					String level = Integer.toString(statusReport.getLevels()[i]);
					
					LightFascade light = ((LightFascade) configHelper
							.getControlledItem(Utility.padString(unitCode,2)
									+ "X10" + houseCode));

					if (light != null) {
						String outputKey = light.getOutputKey();
						CommandInterface _command = new M1FlashCommand();
						_command.setDisplayName(outputKey);
						_command.setTargetDeviceID(-1);
						_command.setUser(m1.currentUser);
						if (level.equals("1")) {
							_command.setCommand("on");
							_command.setExtraInfo("100");
						} else if (level.equals("0")) {
							_command.setCommand("off");
							_command.setExtraInfo("0");
						} else {
							_command.setCommand("on");
							_command.setExtraInfo(level);
						}
						_command.setKey("CLIENT_SEND");
						cache.setCachedCommand(_command.getDisplayName(), _command);

						logger.log(Level.FINER, "Sending "
								+ _command.getCommandCode() + " command to "
								+ outputKey);
						sendToFlash(commandQueue, -1, _command);
					}
				}
			}

			if (sendCommandToFlash) {
				cache.setCachedCommand(m1Command.getDisplayName(), m1Command);
				sendToFlash(commandQueue, -1, m1Command);
			}
		}
	}

	/**
	 * Handles the zone status of an input. 
	 * If an input is violated then it will send a "on" command for the device to the flash client. 
	 * If it is normal then it will send an "off" command for the device to the flash client.
	 * If the zone is unconfigured then it will do nothing.
	 * If the zone is bypassed or in trouble then it will send a message to the security log.
	 * Of the ZoneStatus defined the mapping is:
	 * NORMAL_UNCONFIGURED = do nothing
	 * NORMAL_EOL = off
	 * NORMAL_OPEN = off
	 * NORMAL_SHORT = off
	 * VIOLATED_EOL = on
	 * VIOLATED_OPEN = on
	 * VIOLATED_SHORT = off
	 * BYPASSED_EOL = security log
	 * BYPASSED_OPEN = security log
	 * BYPASSED_SHORT = security log
	 * TROUBLE_EOL = security log
	 * TROUBLE_OPEN = security log
	 * TROUBLE_SHORT = security log
	 * @param cache
	 * @param commandQueue
	 * @param m1
	 * @param zoneStatus
	 * @param theDevice
	 * @see au.com.BI.M1.Commands.ZoneStatus
	 */
	private void handleZoneState(Cache cache, 
			CommandQueue commandQueue, 
			Model m1, 
			ZoneStatus zoneStatus, 
			BaseDevice theDevice) {
		if (zoneStatus == ZoneStatus.NORMAL_EOL ||
				zoneStatus == ZoneStatus.NORMAL_OPEN ||
				zoneStatus == ZoneStatus.NORMAL_SHORT) {
			
			// send an off command
			CommandInterface _command = new M1FlashCommand();
			_command.setDisplayName(theDevice.getOutputKey());
			_command.setTargetDeviceID(-1);
			_command.setUser(m1.currentUser);
			_command.setCommand("off");
			_command.setKey("CLIENT_SEND");
			cache.setCachedCommand(_command.getDisplayName(), _command);

			logger.log(Level.FINER, "Sending "
					+ _command.getCommandCode() + " command to "
					+ theDevice.getOutputKey());
			sendToFlash(commandQueue, -1, _command);
			
		} else if (zoneStatus == ZoneStatus.VIOLATED_EOL ||
				zoneStatus == ZoneStatus.VIOLATED_OPEN ||
				zoneStatus == ZoneStatus.VIOLATED_SHORT) {
			// send an on command
			CommandInterface _command = new M1FlashCommand();
			_command.setDisplayName(theDevice.getOutputKey());
			_command.setTargetDeviceID(-1);
			_command.setUser(m1.currentUser);
			_command.setCommand("on");
			_command.setKey("CLIENT_SEND");
			cache.setCachedCommand(_command.getDisplayName(), _command);

			logger.log(Level.FINER, "Sending "
					+ _command.getCommandCode() + " command to "
					+ theDevice.getOutputKey());
			sendToFlash(commandQueue, -1, _command);
		} else if (zoneStatus == ZoneStatus.BYPASSED_EOL ||
				zoneStatus == ZoneStatus.BYPASSED_OPEN ||
				zoneStatus == ZoneStatus.BYPASSED_SHORT ||
				zoneStatus == ZoneStatus.TROUBLE_EOL ||
				zoneStatus == ZoneStatus.TROUBLE_OPEN ||
				zoneStatus == ZoneStatus.TROUBLE_SHORT) {
			// send an alarm message (fault)
			alarmLogger.setCache(cache);
			alarmLogger.setCommandQueue(commandQueue);
			alarmLogger.addAlertLog("FAULT", zoneStatus.getDescription(),
					AlarmLogging.GENERAL_MESSAGE, theDevice.getOutputKey(),
					zoneStatus.getDescription(),
					m1.currentUser, new Date());
		}
	}

	public void sendToFlash(CommandQueue commandQueue, long targetFlashID,
			CommandInterface command) {

		/*
		 * todo change the PIR's to ToggleSwitches and the others to alarms todo
		 * check the device type - if toggle switch then send on/off signal and
		 * an alert todo if it is a alarm then send an alert todo only do an
		 * alert if the alarm is in trouble, violated or bypassed
		 */
		command.setTargetDeviceID(targetFlashID);
		commandQueue.add(command);
	}

	protected CommandInterface buildCommandForFlash(CommandInterface command,
			ConfigHelper configHelper, Model m1) {
		M1Command m1Command = M1CommandFactory.getInstance().getM1Command(
				command.getKey());

		if (m1Command == null)
			return null;

		if (m1Command.getClass().equals(OutputChangeUpdate.class)
				&& configHelper.checkForControl(m1Command.getKey() + "TOUT")) {
			// Dave check this. the PIR triggers the Short, sort of makes
			// sense, in other words the violate short means PIR on
			// violate EOL means off.

			BaseDevice configDevice = (BaseDevice) configHelper
					.getControlledItem(m1Command.getKey() + "TOUT");
			if (configDevice == null){
				logger.log(Level.FINEST, "M1 command request was received for a device that has not been configured " + m1Command.getKey());
				return null;
			}
			if (((OutputChangeUpdate) m1Command).getOutputState().equals("0")) {
				m1Command.setCommand("off");
			} else {
				m1Command.setCommand("on");
			}
			m1Command
					.setDisplayName(((BaseDevice) configDevice).getOutputKey());

			m1Command.setKey("CLIENT_SEND");
			m1Command.setUser(m1.currentUser);
			return m1Command;
		} else if (m1Command.getClass().equals(RequestTemperatureReply.class)) {
			SensorFascade sensor = (SensorFascade) configHelper.getControlledItem(m1Command.getKey());
			if (sensor == null ){
				logger.log (Level.FINEST,"Received temperature request for a device that has not been configured ");
				return null;
			}
			m1Command.setDisplayName(sensor.getOutputKey());
			m1Command.setKey("CLIENT_SEND");
			m1Command.setUser(m1.currentUser);
			return m1Command;
		} else if (m1Command.getClass().equals(ControlOutputStatusReport.class)
				|| m1Command.getClass().equals(Disarm.class)
				|| m1Command.getClass().equals(ArmToAway.class)
				|| m1Command.getClass().equals(ArmToStayHome.class)
				|| m1Command.getClass().equals(ArmToStayInstant.class)
				|| m1Command.getClass().equals(ArmToNight.class)
				|| m1Command.getClass().equals(ArmToNightInstant.class)
				|| m1Command.getClass().equals(ArmToVacation.class)
				|| m1Command.getClass().equals(ArmStepToNextAwayMode.class)
				|| m1Command.getClass().equals(ArmStepToNextStayMode.class)
				|| m1Command.getClass().equals(
						ReplyArmingStatusReportData.class)
				|| m1Command.getClass().equals(ZoneChangeUpdate.class)
				|| m1Command.getClass()
						.equals(ReplyAlarmByZoneReportData.class)
				|| m1Command.getClass().equals(TasksChangeUpdate.class)
				|| m1Command.getClass().equals(PLCChangeUpdate.class)
				|| m1Command.getClass().equals(PLCStatusReturned.class)
				|| m1Command.getClass().equals(ZoneStatusReport.class)) {
			return m1Command;
		}  else {
			return null;
		}
	}
}
