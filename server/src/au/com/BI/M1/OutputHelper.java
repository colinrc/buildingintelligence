package au.com.BI.M1;

import java.util.logging.Level;
import java.util.logging.Logger;
import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Comms.CommDevice;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.Device.DeviceType;
import au.com.BI.M1.Commands.ArmToAway;
import au.com.BI.M1.Commands.ArmToNight;
import au.com.BI.M1.Commands.ArmToNightInstant;
import au.com.BI.M1.Commands.ArmToStayHome;
import au.com.BI.M1.Commands.ArmToStayInstant;
import au.com.BI.M1.Commands.ArmStepToNextAwayMode;
import au.com.BI.M1.Commands.ArmStepToNextStayMode;
import au.com.BI.M1.Commands.ArmToVacation;
import au.com.BI.M1.Commands.ControlOutputOff;
import au.com.BI.M1.Commands.ControlOutputOn;
import au.com.BI.Util.DeviceModel;


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
			} else if (command.getKey().equals("ARM") && (device.getDeviceType() == DeviceType.VIRTUAL_OUTPUT)) {
				if (command.getCommandCode().equals("ARM_TO_AWAY")) {
					ArmToAway m1Command = new ArmToAway();
					m1Command.setPartition(command.getExtraInfo());
					m1Command.setUserCode(configHelper.getDeviceModel().getParameterValue("Password", DeviceModel.MAIN_DEVICE_GROUP));
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equals("ARM_TO_STAY_HOME")) {
					ArmToStayHome m1Command = new ArmToStayHome();
					m1Command.setPartition(command.getExtraInfo());
					m1Command.setUserCode(configHelper.getDeviceModel().getParameterValue("Password", DeviceModel.MAIN_DEVICE_GROUP));
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equals(
						"ARM_TO_STAY_INSTANT")) {
					ArmToStayInstant m1Command = new ArmToStayInstant();
					m1Command.setPartition(command.getExtraInfo());
					m1Command.setUserCode(configHelper.getDeviceModel().getParameterValue("Password", DeviceModel.MAIN_DEVICE_GROUP));
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equals("ARM_TO_NIGHT")) {
					ArmToNight m1Command = new ArmToNight();
					m1Command.setPartition(command.getExtraInfo());
					m1Command.setUserCode(configHelper.getDeviceModel().getParameterValue("Password", DeviceModel.MAIN_DEVICE_GROUP));
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equals("ARM_TO_VACATION")) {
					ArmToVacation m1Command = new ArmToVacation();
					m1Command.setPartition(command.getExtraInfo());
					m1Command.setUserCode(configHelper.getDeviceModel().getParameterValue("Password", DeviceModel.MAIN_DEVICE_GROUP));
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equals(
						"ARM_STEP_TO_NEXT_AWAY_MODE")) {
					ArmStepToNextAwayMode m1Command = new ArmStepToNextAwayMode();
					m1Command.setPartition(command.getExtraInfo());
					m1Command.setUserCode(configHelper.getDeviceModel().getParameterValue("Password", DeviceModel.MAIN_DEVICE_GROUP));
					retCode = m1Command.buildM1String() + "\r\n";
				} else if (command.getCommandCode().equals(
						"ARM_STEP_TO_NEXT_STAY_MODE")) {
					ArmStepToNextStayMode m1Command = new ArmStepToNextStayMode();
					m1Command.setPartition(command.getExtraInfo());
					m1Command.setUserCode(configHelper.getDeviceModel().getParameterValue("Password", DeviceModel.MAIN_DEVICE_GROUP));
					retCode = m1Command.buildM1String() + "\r\n";
				}
			}

			logger.log(Level.FINE, retCode);

			if (!retCode.equals("")) {
				comms.sendString(retCode);
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

		if (command.getCommandCode().equals("on")) {
			ControlOutputOn controlOutputOn = new ControlOutputOn();
			controlOutputOn.setKey(device.getKey());
			controlOutputOn.setOutputNumber(device.getKey());
			returnString = controlOutputOn.buildM1String() + "\r\n";
		} else if (command.getCommandCode().equals("pulse")) {
			ControlOutputOn controlOutputOn = new ControlOutputOn();
			controlOutputOn.setKey(device.getKey());
			controlOutputOn.setOutputNumber(device.getKey());
			controlOutputOn.setSeconds(command.getExtraInfo());
			returnString = controlOutputOn.buildM1String() + "\r\n";
		} else if (command.getCommandCode().equals("off")) {
			ControlOutputOff controlOutputOff = new ControlOutputOff();
			controlOutputOff.setKey(device.getKey());
			controlOutputOff.setOutputNumber(device.getKey());
			returnString = controlOutputOff.buildM1String() + "\r\n";
		}
		return (returnString);
	}
}
