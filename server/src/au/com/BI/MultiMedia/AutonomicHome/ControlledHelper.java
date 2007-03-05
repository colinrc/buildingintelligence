package au.com.BI.MultiMedia.AutonomicHome;

import java.util.logging.Logger;

import au.com.BI.AlarmLogging.AlarmLogging;
import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Command.CommandQueue;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.M1.Model;

public class ControlledHelper {
	protected Logger logger;

	protected AlarmLogging alarmLogger;

	public ControlledHelper() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		alarmLogger = new AlarmLogging();
	}
	
	public void doControlledItem(CommandInterface command,
			ConfigHelper configHelper, 
			Cache cache, 
			CommandQueue commandQueue,
			au.com.BI.MultiMedia.AutonomicHome.Model m1) throws CommsFail {
		return;
	}
}
