package au.com.BI.MultiMedia.AutonomicHome;

/**
 * @author David Cummins
 * Implements the Autonomic Home device.
 */

import java.util.LinkedList;
import java.util.logging.Level;

import au.com.BI.Command.CommandInterface;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Device.DeviceType;
import au.com.BI.MultiMedia.MultiMediaInterface;
import au.com.BI.MultiMedia.AutonomicHome.Commands.GetStatus;
import au.com.BI.MultiMedia.AutonomicHome.Commands.StartMediaCenter;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;
import au.com.BI.Util.SimplifiedModel;

public class Model extends SimplifiedModel implements DeviceModel, MultiMediaInterface {

	private ControlledHelper controlledHelper;
	private OutputHelper outputHelper;
	
	/**
	 * Constructor for the model.
	 * Will add the following:
	 * <ul>
	 * 	<li>Windows Media Center device</li>
	 * </ul>
	 */
	public Model() {
		super();
		controlledHelper = new ControlledHelper();
		outputHelper = new OutputHelper();
	}
	
	/**
	 * Starts AutonomicHome model.
	 * <ul>
	 * 	<li>Start the MCE Media Center</li>
	 * </ul>
	 */
	public void doStartup() throws CommsFail {
		logger.log(Level.INFO,"Starting Autonomic Home");
		StartMediaCenter startMCE = new StartMediaCenter();
		comms.sendString(startMCE.buildCommandString() + "\r\n");
		GetStatus getStatus = new GetStatus();
		comms.sendString(getStatus.buildCommandString() + "\r\n");
		logger.log(Level.INFO,"Sent command " + getStatus.buildCommandString());
	}
	
	/**
	 * Handle output items.
	 */
	public void doOutputItem (CommandInterface command) throws CommsFail {
		logger.log(Level.INFO,"Output " + command.getKey());
		outputHelper.doOutputItem(command, configHelper, cache, comms, this);
	}
	
	/**
	 * Handle controlled items.
	 */
	public void doControlledItem (CommandInterface command) throws CommsFail
	{	
		logger.log(Level.INFO,"Controlled " + command.getKey());
		controlledHelper.doControlledItem(command, configHelper, cache, commandQueue, this);
	}
}
