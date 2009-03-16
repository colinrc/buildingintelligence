package au.com.BI.MultiMedia.AutonomicHome;

import java.util.Iterator;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.AlarmLogging.AlarmLogging;
import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Command.CommandQueue;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.M1.M1FlashCommand;
import au.com.BI.M1.Model;
import au.com.BI.MultiMedia.AlbumCommand;
import au.com.BI.MultiMedia.AutonomicHome.Commands.Album;
import au.com.BI.MultiMedia.AutonomicHome.Commands.AutonomicHomeCommand;
import au.com.BI.MultiMedia.AutonomicHome.Commands.AutonomicHomeCommandException;
import au.com.BI.MultiMedia.AutonomicHome.Commands.AutonomicHomeCommandFactory;
import au.com.BI.MultiMedia.AutonomicHome.Commands.BeginAlbumsReply;
import au.com.BI.MultiMedia.AutonomicHome.Commands.EndAlbumsReply;
import au.com.BI.MultiMedia.AutonomicHome.Commands.ReportState;
import au.com.BI.MultiMedia.AutonomicHome.Commands.SetInstance;
import au.com.BI.MultiMedia.AutonomicHome.Commands.SetInstanceReply;
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
	 * @param model
	 * @throws CommsFail
	 */
	public void doControlledItem(CommandInterface command,
			ConfigHelper configHelper, 
			Cache cache, 
			CommandQueue commandQueue,
			au.com.BI.MultiMedia.AutonomicHome.Model model)
	throws CommsFail, AutonomicHomeCommandException {
		
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
				
				logger.log(Level.INFO, "Setting running for " + extender.getKey() + " to " + state.getValue() + ":" + running);
			} else if (state.getType() == StateType.SESSION_START) {
				extender.setSessionStart(state.getValue());
				
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
		} else if (_command.getClass().equals(BeginAlbumsReply.class)) {
			currentCommand = (BeginAlbumsReply)_command;
		} else if (_command.getClass().equals(Album.class)) {
			Album album = (Album)_command;
			
			/*
			 * Assumes that the current command is browsing for albums
			 */
			if (!currentCommand.getClass().equals(BeginAlbumsReply.class)) {
				logger.log(Level.WARNING, "Current command is " + currentCommand.getClass().getName() + " but was expecting " + BeginAlbumsReply.class.getName());
				throw new AutonomicHomeCommandException("Current command is " + currentCommand.getClass().getName() + " but was expecting " + BeginAlbumsReply.class.getName());
			}
			
			// add the album to the currentCommand
			((BeginAlbumsReply)currentCommand).getAlbums().add(album);

			/*
			 * Assumes that we have a current instance
			 */
			if (model.getCurrentInstance() == null) {
				logger.log(Level.WARNING, "No currently set instance");
				throw new AutonomicHomeCommandException("No currently set instance");
			}
		} else if (_command.getClass().equals(EndAlbumsReply.class)) {
			/*
			 * Assumes that the current command is browsing for albums
			 */
			if (currentCommand.getClass().equals(EndAlbumsReply.class)) {
				logger.log(Level.WARNING, "Current command is " + currentCommand.getClass().getName() + " but was expecting " + EndAlbumsReply.class.getName());
				throw new AutonomicHomeCommandException("Current command is " + currentCommand.getClass().getName() + " but was expecting " + EndAlbumsReply.class.getName());
			}
			
			// Check that the number of albums matches what it was reported originally
			BeginAlbumsReply albums = (BeginAlbumsReply)currentCommand;
			if (albums.getAlbums().size() != albums.getCount()) {
				logger.log(Level.WARNING, "Albums received did not equal the count");
				throw new AutonomicHomeCommandException("Albums received did not equal the count");
			}
			
			Iterator<Album> it = albums.getAlbums().iterator();
			while (it.hasNext()) {
				Album album = (Album)it.next();
				CommandInterface flashCommand = new AlbumCommand();
				flashCommand.setDisplayName(model.getCurrentInstance().getKey());
				flashCommand.setTargetDeviceID(-1);
				flashCommand.setUser(model.currentUser);
				flashCommand.setExtraInfo(album.getGuid());
				flashCommand.setExtra2Info(album.getName());
				flashCommand.setKey("CLIENT_SEND");
				flashCommand.setCommand("ALBUM");
				sendCommand(cache, commandQueue, flashCommand);
			}
			
			commandFinished = true;
		}
		
		if (commandFinished) {
			currentCommand = null;
		}
		return;
	}
	
	/**
	 * Send the command. First cache the command and then send to flash.
	 * @param cache
	 * @param commandQueue
	 * @param command
	 */
	public void sendCommand (Cache cache, 
			CommandQueue commandQueue, 
			CommandInterface command) {
		logger.log(Level.FINER, "Sending " + command.getCommandCode() + " command for " +
				command.getDisplayName() + "; extraInfo=" + 
				command.getExtraInfo() + "; extra2Info=" + 
				command.getExtra2Info() + "; extra3Info=" + 
				command.getExtra3Info() + "; extra4Info=" + 
				command.getExtra4Info() + "; extra5Info=" + 
				command.getExtra5Info());
		cache.setCachedCommand(command.getDisplayName(), command);
		sendToFlash(commandQueue, -1, command);
	}
	
	/**
	 * 
	 * @param commandQueue
	 * @param targetFlashID
	 * @param command
	 */
	public void sendToFlash(CommandQueue commandQueue, 
			long targetFlashID,
			CommandInterface command) {

		command.setTargetDeviceID(targetFlashID);
		commandQueue.add(command);
	}
}
