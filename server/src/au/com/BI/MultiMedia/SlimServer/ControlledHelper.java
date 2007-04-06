package au.com.BI.MultiMedia.SlimServer;

import java.util.Iterator;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.AlarmLogging.AlarmLogging;
import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Command.CommandQueue;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.MultiMedia.MultiMediaFlashCommand;
import au.com.BI.MultiMedia.SlimServer.Commands.Album;
import au.com.BI.MultiMedia.SlimServer.Commands.BrowseAlbumsReply;
import au.com.BI.MultiMedia.SlimServer.Commands.SlimServerCommand;
import au.com.BI.MultiMedia.SlimServer.Commands.SlimServerCommandException;
import au.com.BI.MultiMedia.SlimServer.Commands.SlimServerCommandFactory;

public class ControlledHelper {
	protected Logger logger;
	protected AlarmLogging alarmLogger;
	
	public ControlledHelper() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		alarmLogger = new AlarmLogging();
	}
	
	/**
	 * Parse commands from the Slim Server.
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
			au.com.BI.MultiMedia.SlimServer.Model model)
	throws CommsFail, SlimServerCommandException {
		logger.log(Level.INFO, command.getCommandCode());
		
		SlimServerCommand _command = 
			SlimServerCommandFactory.getInstance().getCommand(command.getKey());
		
		if (_command == null) {
			return;
		}
		
		if (_command.getClass().equals(BrowseAlbumsReply.class)) {
			BrowseAlbumsReply reply = (BrowseAlbumsReply)_command;
			
			Iterator<Album> it = reply.getAlbums().iterator();
			while (it.hasNext()) {
				Album album = (Album)it.next();
				CommandInterface flashCommand = new MultiMediaFlashCommand();
				flashCommand.setDisplayName(model.getCurrentPlayer().getOutputKey());
				flashCommand.setTargetDeviceID(-1);
				flashCommand.setUser(model.currentUser);
				flashCommand.setExtraInfo(album.getId());
				flashCommand.setExtra2Info(album.getAlbum());
				flashCommand.setKey("CLIENT_SEND");
				flashCommand.setCommand("ALBUM");
				sendCommand(cache, commandQueue, flashCommand);
			}
		}
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
