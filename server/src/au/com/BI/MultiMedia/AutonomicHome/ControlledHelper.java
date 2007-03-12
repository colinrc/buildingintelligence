package au.com.BI.MultiMedia.AutonomicHome;

import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.AlarmLogging.AlarmLogging;
import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Command.CommandQueue;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.M1.Model;
import au.com.BI.MultiMedia.AutonomicHome.Commands.AutonomicHomeCommand;
import au.com.BI.MultiMedia.AutonomicHome.Commands.AutonomicHomeCommandFactory;
import au.com.BI.MultiMedia.AutonomicHome.Commands.SetInstanceReply;
import au.com.BI.MultiMedia.AutonomicHome.Commands.ReportState;
import au.com.BI.MultiMedia.AutonomicHome.Commands.SetInstance;
import au.com.BI.MultiMedia.AutonomicHome.Commands.StateType;
import au.com.BI.MultiMedia.AutonomicHome.Device.WindowsMediaExtender;

public class ControlledHelper {
	protected Logger logger;
	private AutonomicHomeCommand currentCommand;

	protected AlarmLogging alarmLogger;

	public ControlledHelper() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		alarmLogger = new AlarmLogging();
		currentCommand = null;
	}
	
	/**
	 * Parse commands from the Windows Media Center.
	 * @param command
	 * @param configHelper
	 * @param cache
	 * @param commandQueue
	 * @param m1
	 * @throws CommsFail
	 */
	public void doControlledItem(CommandInterface command,
			ConfigHelper configHelper, 
			Cache cache, 
			CommandQueue commandQueue,
			au.com.BI.MultiMedia.AutonomicHome.Model model) throws CommsFail {
		
		boolean commandFinished = false;
		
		AutonomicHomeCommand _command = 
			AutonomicHomeCommandFactory.getInstance().getCommand(command.getKey());
		
		if (_command == null) {
			return;
		}
		
		if (_command.getClass().equals(ReportState.class)) {
			ReportState state = (ReportState)_command;
			WindowsMediaExtender extender = (WindowsMediaExtender)configHelper.getControlledItem(state.getInstance());
			
			if (extender == null) {
				logger.log(Level.WARNING, "Attempting to report state on an extender that is not configured: " + state.getInstance());
				return;
			}
			if (state.getType() == StateType.VOLUME) {
				try {
					int volume = Integer.parseInt(state.getValue());
					extender.setVolume(volume);
					
					// TODO send the volume to the client
					logger.log(Level.INFO, "Setting volume for " + extender.getKey() + " to " + state.getValue());
				} catch (NumberFormatException e) {
					logger.log(Level.WARNING, "ReportState message received to set volume, but volume was not an integer: " + state.getValue());
				}
			} else if (state.getType() == StateType.RUNNING) {
				boolean running = Boolean.parseBoolean(state.getValue());
				extender.setRunning(running);
				
				// TODO send running to the client
				logger.log(Level.INFO, "Setting running for " + extender.getKey() + " to " + state.getValue() + ":" + running);
			} else if (state.getType() == StateType.SESSION_START) {
				extender.setSessionStart(state.getValue());
				
				// TODO send session start to the client
				logger.log(Level.INFO, "Setting session start for " + extender.getKey() + " to " + state.getValue());
			}
		} else if (_command.getClass().equals(SetInstanceReply.class)) {
			SetInstanceReply setInstanceReply = (SetInstanceReply)_command;
			
			WindowsMediaExtender extender = (WindowsMediaExtender)configHelper.getControlledItem(setInstanceReply.getInstance());
			if (extender == null) {
				logger.log(Level.WARNING, "Attempting to report instance on an extender that is not configured: " + setInstanceReply.getInstance());
				return;
			}
			
			logger.log(Level.INFO, "Setting current instance to " + extender.getKey());
			model.setCurrentInstance(extender);
			
			// TODO send current instance selected to the client.
		}
		
		if (commandFinished) {
			currentCommand = null;
		}
		return;
	}
}
