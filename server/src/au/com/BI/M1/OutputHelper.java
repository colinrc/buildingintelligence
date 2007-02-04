package au.com.BI.M1;

import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Comms.CommDevice;
import au.com.BI.Comms.CommsCommand;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.Device.DeviceType;
import au.com.BI.Lights.LightFascade;
import au.com.BI.M1.Commands.AlarmByZoneRequest;
import au.com.BI.M1.Commands.ArmStepToNextAwayMode;
import au.com.BI.M1.Commands.ArmStepToNextStayMode;
import au.com.BI.M1.Commands.ArmToAway;
import au.com.BI.M1.Commands.ArmToNight;
import au.com.BI.M1.Commands.ArmToStayHome;
import au.com.BI.M1.Commands.ArmToStayInstant;
import au.com.BI.M1.Commands.ArmToVacation;
import au.com.BI.M1.Commands.ArmingStatusRequest;
import au.com.BI.M1.Commands.ControlOutputOff;
import au.com.BI.M1.Commands.ControlOutputOn;
import au.com.BI.M1.Commands.ControlOutputStatusRequest;
import au.com.BI.M1.Commands.ControlOutputToggle;
import au.com.BI.M1.Commands.Group;
import au.com.BI.M1.Commands.PLCDeviceControl;
import au.com.BI.M1.Commands.PLCDeviceOff;
import au.com.BI.M1.Commands.PLCDeviceOn;
import au.com.BI.M1.Commands.PLCDeviceToggle;
import au.com.BI.M1.Commands.PLCFunction;
import au.com.BI.M1.Commands.PLCStatusRequest;
import au.com.BI.M1.Commands.RequestTemperature;
import au.com.BI.M1.Commands.RequestZoneVoltage;
import au.com.BI.M1.Commands.SpeakPhrase;
import au.com.BI.M1.Commands.SpeakWord;
import au.com.BI.M1.Commands.TaskActivation;
import au.com.BI.M1.Commands.ZoneBypassRequest;
import au.com.BI.M1.Commands.ZoneStatusRequest;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.Utility;

public class OutputHelper {

	protected Logger logger;

	public OutputHelper() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}

	public void doOutputItem(CommandInterface command,
			ConfigHelper configHelper, Cache cache, CommDevice comms,
			au.com.BI.M1.Model m1) throws CommsFail {

		String theWholeKey = command.getKey();

		DeviceType device = configHelper.getOutputItem(theWholeKey);

		if (device != null) {

			String retCode = "";

			if (device.getDeviceType() == DeviceType.TOGGLE_OUTPUT) {
				retCode = buildToggleOutput((DeviceType) device, command);
			} else if (command.getKey().equals(m1.getDescription())
					&& (device.getDeviceType() == DeviceType.VIRTUAL_OUTPUT)) {
				if (command.getCommandCode().equalsIgnoreCase("ALL_X10_ON")) {
					if (command.getExtraInfo() == null || command.getExtraInfo() == "") {
						logger.log(Level.WARNING,"For ALL_X10_ON command the extra info (for house code) cannot be null");
					}
					PLCDeviceControl plcDeviceControl = new PLCDeviceControl();
					plcDeviceControl.setFunctionCode(PLCFunction.X10_ALL_LIGHTS_OFF);
					plcDeviceControl.setHouseCode(command.getExtraInfo());
					plcDeviceControl.setUnitCode("");
					plcDeviceControl.setTime(command.getExtra2Info());
					retCode = plcDeviceControl.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equalsIgnoreCase("ALL_X10_OFF")) {
					if (command.getExtraInfo() == null || command.getExtraInfo() == "") {
						logger.log(Level.WARNING,"For ALL_X10_OFF command the extra info (for house code) cannot be null");
					}
					PLCDeviceControl plcDeviceControl = new PLCDeviceControl();
					plcDeviceControl.setFunctionCode(PLCFunction.X10_ALL_LIGHTS_OFF);
					plcDeviceControl.setHouseCode(command.getExtraInfo());
					plcDeviceControl.setUnitCode("");
					plcDeviceControl.setTime(command.getExtra2Info());
					retCode = plcDeviceControl.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equalsIgnoreCase("ARMING_STATUS_REQUEST")) {
					ArmingStatusRequest m1Command = new ArmingStatusRequest();
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equalsIgnoreCase(
						"ALARM_BY_ZONE_REQUEST")) {
					AlarmByZoneRequest m1Command = new AlarmByZoneRequest();
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equalsIgnoreCase(
						"CONTROL_OUTPUT_STATUS_REQUEST")) {
					ControlOutputStatusRequest m1Command = new ControlOutputStatusRequest();
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equalsIgnoreCase(
						"REQUEST_TEMPERATURE")) {
					RequestTemperature m1Command = new RequestTemperature();
					Group group = Group.getByValue(command.getExtraInfo());
					if (group == null) {

						logger.log(Level.WARNING,
								"A command to request temperature was sent with an unknown group code of "
										+ command.getExtraInfo());
						return;
					}
					m1Command.setGroup(group);
					m1Command.setDevice(command.getExtra2Info());
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equalsIgnoreCase("TASK_ACTIVATION")) {
					TaskActivation m1Command = new TaskActivation();
					
					if (command.getExtraInfo() == null || command.getExtraInfo() == "") {
						logger.log(Level.WARNING, "Task activation command received with no extra information");
						return;
					}
					
					String taskValue = (String)m1.getCatalogueDef("TASKS").get(command.getExtraInfo());
					
					if (taskValue == null || taskValue == "") {
						try {
							Integer value = Integer.valueOf(command.getExtraInfo());
							m1Command.setTask(command.getExtraInfo());
						} catch (NumberFormatException e) {
							return;
						}
					} else {
						m1Command.setTask(taskValue);
					}
					
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equalsIgnoreCase("PLC_STATUS")) {
					PLCStatusRequest m1Command = new PLCStatusRequest();
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equalsIgnoreCase("REQUEST_ZONE_VOLTAGE")) {
					RequestZoneVoltage m1Command = new RequestZoneVoltage();
					m1Command.setZone(Utility.padString(command.getExtraInfo(),3));
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equalsIgnoreCase("ZONE_STATUS_REQUEST")) {
					ZoneStatusRequest m1Command = new ZoneStatusRequest();
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equalsIgnoreCase("SPEAK_WORD")) {
					SpeakWord m1Command = new SpeakWord();
					
					if (command.getExtraInfo() == null || command.getExtraInfo() == "") {
						logger.log(Level.WARNING, "Speak word command received with no extra information");
						return;
					}
					
					String wordValue = (String)m1.getCatalogueDef("WORDS").get(command.getExtraInfo());
					
					if (wordValue == null || wordValue == "") {
						try {
							Integer value = Integer.valueOf(command.getExtraInfo());
							m1Command.setWord(command.getExtraInfo());
						} catch (NumberFormatException e) {
							return;
						}
					} else {
						m1Command.setWord(wordValue);
					}
					
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equalsIgnoreCase("SPEAK_PHRASE")) {
					SpeakPhrase m1Command = new SpeakPhrase();
					
					if (command.getExtraInfo() == null || command.getExtraInfo() == "") {
						logger.log(Level.WARNING, "Speak phrase command received with no extra information");
						return;
					}
					
					String phraseValue = (String)m1.getCatalogueDef("PHRASES").get(command.getExtraInfo());
					
					if (phraseValue == null || phraseValue == "") {
						try {
							Integer value = Integer.valueOf(command.getExtraInfo());
							m1Command.setPhrase(command.getExtraInfo());
						} catch (NumberFormatException e) {
							return;
						}
					} else {
						m1Command.setPhrase(phraseValue);
					}
					
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equalsIgnoreCase("ZONE_BYPASS")) {
					ZoneBypassRequest m1Command = new ZoneBypassRequest();
					
					m1Command.setPinCode(command.getExtraInfo());
					m1Command.setZone(command.getExtra2Info());
					m1Command.setArea(command.getExtra3Info());
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equals("ARM_TO_AWAY")) {
					ArmToAway m1Command = new ArmToAway();
					m1Command.setPartition(command.getExtraInfo());
					m1Command.setUserCode(configHelper.getDeviceModel()
							.getParameterValue("Password",
									DeviceModel.MAIN_DEVICE_GROUP));
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equals("ARM_TO_STAY_HOME")) {
					ArmToStayHome m1Command = new ArmToStayHome();
					m1Command.setPartition(command.getExtraInfo());
					m1Command.setUserCode(configHelper.getDeviceModel()
							.getParameterValue("Password",
									DeviceModel.MAIN_DEVICE_GROUP));
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equals(
						"ARM_TO_STAY_INSTANT")) {
					ArmToStayInstant m1Command = new ArmToStayInstant();
					m1Command.setPartition(command.getExtraInfo());
					m1Command.setUserCode(configHelper.getDeviceModel()
							.getParameterValue("Password",
									DeviceModel.MAIN_DEVICE_GROUP));
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equals("ARM_TO_NIGHT")) {
					ArmToNight m1Command = new ArmToNight();
					m1Command.setPartition(command.getExtraInfo());
					m1Command.setUserCode(configHelper.getDeviceModel()
							.getParameterValue("Password",
									DeviceModel.MAIN_DEVICE_GROUP));
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equals("ARM_TO_VACATION")) {
					ArmToVacation m1Command = new ArmToVacation();
					m1Command.setPartition(command.getExtraInfo());
					m1Command.setUserCode(configHelper.getDeviceModel()
							.getParameterValue("Password",
									DeviceModel.MAIN_DEVICE_GROUP));
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equals(
						"ARM_STEP_TO_NEXT_AWAY_MODE")) {
					ArmStepToNextAwayMode m1Command = new ArmStepToNextAwayMode();
					m1Command.setPartition(command.getExtraInfo());
					m1Command.setUserCode(configHelper.getDeviceModel()
							.getParameterValue("Password",
									DeviceModel.MAIN_DEVICE_GROUP));
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equals(
						"ARM_STEP_TO_NEXT_STAY_MODE")) {
					ArmStepToNextStayMode m1Command = new ArmStepToNextStayMode();
					m1Command.setPartition(command.getExtraInfo());
					m1Command.setUserCode(configHelper.getDeviceModel()
							.getParameterValue("Password",
									DeviceModel.MAIN_DEVICE_GROUP));
					retCode = m1Command.buildM1String() + "\r\n";
				}
			} else if (device.getDeviceType() == DeviceType.COMFORT_LIGHT_X10) {
				retCode = buildX10Light((LightFascade) device, command);
			}

			if (!retCode.equals("")) {
				// comms.sendString(retCode); When using the queue you should not also explicitly send the string. CC 
				logger.log(Level.FINER, "Sending command to M1: " + retCode);
				CommsCommand _commsCommand = new CommsCommand(theWholeKey,retCode,null);
				comms.addCommandToQueue(_commsCommand);
				
				if (!comms.sendNextCommand()) {
					throw new CommsFail("Failed to send command:" + retCode);
				}
			}
		}

	}

	/**
	 * Builds the toggle output command based on the Control Output commands. cn -
	 * Control Output On, created when the command code is "on" ct - Control
	 * Output Toggle, created when the command code is pulse and there is a time
	 * element. cf - Control Output Off, created when the command code is "off"
	 * 
	 * @param device
	 * @param command
	 * @return
	 */
	public String buildToggleOutput(DeviceType device, CommandInterface command) {
		String returnString = "";

		if (command.getCommandCode().equalsIgnoreCase("on")) {
			ControlOutputOn controlOutputOn = new ControlOutputOn();
			controlOutputOn.setKey(device.getKey());
			controlOutputOn.setOutputNumber(device.getKey());
			controlOutputOn.setSeconds(command.getExtraInfo());			
			returnString = controlOutputOn.buildM1String() + "\r\n";
		} else if (command.getCommandCode().equalsIgnoreCase("toggle")) {
			ControlOutputToggle controlOutputToggle = new ControlOutputToggle();
			controlOutputToggle.setKey(device.getKey());
			controlOutputToggle.setOutputNumber(device.getKey());
			returnString = controlOutputToggle.buildM1String() + "\r\n";
		} else if (command.getCommandCode().equalsIgnoreCase("off")) {
			ControlOutputOff controlOutputOff = new ControlOutputOff();
			controlOutputOff.setKey(device.getKey());
			controlOutputOff.setOutputNumber(device.getKey());
			returnString = controlOutputOff.buildM1String() + "\r\n";
		}
		return (returnString);
	}
	
	/**
	 * 
	 * @param device
	 * @param command
	 * @return
	 */
	public String buildX10Light(LightFascade device, CommandInterface command) {
		String returnString = "";

		if (command.getCommandCode().equalsIgnoreCase("on")) {
			PLCDeviceOn plcDeviceOn = new PLCDeviceOn();
			plcDeviceOn.setUnitCode(device.getKey());
			plcDeviceOn.setHouseCode(device.getX10HouseCode());
			returnString = plcDeviceOn.buildM1String() + "\r\n";
		} else if (command.getCommandCode().equalsIgnoreCase("toggle")) {
			PLCDeviceToggle plcDeviceToggle = new PLCDeviceToggle();
			plcDeviceToggle.setUnitCode(device.getKey());
			plcDeviceToggle.setHouseCode(device.getX10HouseCode());
			returnString = plcDeviceToggle.buildM1String() + "\r\n";
		} else if (command.getCommandCode().equalsIgnoreCase("off")) {
			PLCDeviceOff plcDeviceOff = new PLCDeviceOff();
			plcDeviceOff.setUnitCode(device.getKey());
			plcDeviceOff.setHouseCode(device.getX10HouseCode());
			returnString = plcDeviceOff.buildM1String() + "\r\n";
		} else if (command.getCommandCode().equalsIgnoreCase("dim")) {
			PLCDeviceControl plcDeviceControl = new PLCDeviceControl();
			plcDeviceControl.setUnitCode(device.getKey());
			plcDeviceControl.setHouseCode(device.getX10HouseCode());
			plcDeviceControl.setFunctionCode(PLCFunction.X10_DIM);
			plcDeviceControl.setExtendedCode(command.getExtraInfo());
			plcDeviceControl.setTime(command.getExtra2Info());
			returnString = plcDeviceControl.buildM1String() + "\r\n";
		} else if (command.getCommandCode().equalsIgnoreCase("bright")) {
			PLCDeviceControl plcDeviceControl = new PLCDeviceControl();
			plcDeviceControl.setUnitCode(device.getKey());
			plcDeviceControl.setHouseCode(device.getX10HouseCode());
			plcDeviceControl.setFunctionCode(PLCFunction.X10_BRIGHT);
			plcDeviceControl.setExtendedCode(command.getExtraInfo());
			plcDeviceControl.setTime(command.getExtra2Info());
			returnString = plcDeviceControl.buildM1String() + "\r\n";
		}
		return (returnString);
	}
}
