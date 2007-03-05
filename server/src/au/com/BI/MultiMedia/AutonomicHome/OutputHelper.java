package au.com.BI.MultiMedia.AutonomicHome;

import java.util.logging.Logger;

import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Comms.CommDevice;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Config.ConfigHelper;

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
		return;
	}
}
