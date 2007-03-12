package au.com.BI.MultiMedia.AutonomicHome;

import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Comms.CommDevice;
import au.com.BI.Comms.CommsCommand;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.Device.DeviceType;
import au.com.BI.MultiMedia.AutonomicHome.Commands.SetInstance;
import au.com.BI.MultiMedia.AutonomicHome.Device.WindowsMediaExtender;

/**
 * Helper class with outputs from the Autonomic Home to the MCE.
 * @author David Cummins
 *
 */
public class OutputHelper {

	protected Logger logger;

	public OutputHelper() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
	public void doOutputItem(CommandInterface command,
			ConfigHelper configHelper, 
			Cache cache, 
			CommDevice comms,
			au.com.BI.MultiMedia.AutonomicHome.Model model) throws CommsFail {
		
		String key = command.getKey();
		String retCode = "";
		
		DeviceType device = configHelper.getControlledItem(key);
		
		if (device != null) {
			if (device.getDeviceType() == DeviceType.WINDOWS_MEDIA_EXTENDER) {
				WindowsMediaExtender extender = (WindowsMediaExtender)device;
				
				if (command.getCommandCode().equals("SET_INSTANCE")) {
					SetInstance setInstance = new SetInstance();
					setInstance.setInstance(extender.getKey());
					retCode = setInstance.buildCommandString() + "\r\n";
				}
			}
		}
		
		if (!retCode.equals("")) {
			// comms.sendString(retCode); When using the queue you should not also explicitly send the string. CC 
			logger.log(Level.FINER, "Sending command to Autonomic Home: " + retCode);
			CommsCommand _commsCommand = new CommsCommand(key,retCode,null);
			comms.addCommandToQueue(_commsCommand);
			
			if (!comms.sendNextCommand()) {
				throw new CommsFail("Failed to send command:" + retCode);
			}
		}
	}
}
