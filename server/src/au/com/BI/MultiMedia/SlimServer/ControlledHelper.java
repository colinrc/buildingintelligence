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
import au.com.BI.MultiMedia.Album;
import au.com.BI.MultiMedia.AlbumCommand;
import au.com.BI.MultiMedia.SlimServer.Commands.Artist;
import au.com.BI.MultiMedia.SlimServer.Commands.BrowseAlbumsReply;
import au.com.BI.MultiMedia.SlimServer.Commands.BrowseArtistsReply;
import au.com.BI.MultiMedia.SlimServer.Commands.BrowseGenresReply;
import au.com.BI.MultiMedia.SlimServer.Commands.Genre;
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
			
			AlbumCommand flashCommand = new AlbumCommand();
			
			Iterator<Album> it = reply.getAlbums().iterator();
			while (it.hasNext()) {
				Album album = (Album)it.next();
				album.setUrlPath(model.getURLPath());
				
				flashCommand.getAlbums().add(album);
			}
			flashCommand.setDisplayName(model.getCurrentPlayer().getOutputKey());
			flashCommand.setTargetDeviceID(-1);
			flashCommand.setUser(model.currentUser);
			flashCommand.setKey("CLIENT_SEND");
			flashCommand.setCommand("ALBUM");
			sendCommand(cache, commandQueue, flashCommand);
		} else if (_command.getClass().equals(BrowseArtistsReply.class)) {
			BrowseArtistsReply reply = (BrowseArtistsReply)_command;
			
			Iterator<Artist> it = reply.getArtists().iterator();
			while (it.hasNext()) {
				Artist artist = (Artist)it.next();
				CommandInterface flashCommand = new AlbumCommand();
				flashCommand.setDisplayName(model.getCurrentPlayer().getOutputKey());
				flashCommand.setTargetDeviceID(-1);
				flashCommand.setUser(model.currentUser);
				flashCommand.setExtraInfo(artist.getId());
				flashCommand.setExtra2Info(artist.getArtist());
				flashCommand.setKey("CLIENT_SEND");
				flashCommand.setCommand("ARTIST");
				sendCommand(cache, commandQueue, flashCommand);
			}
		} else if (_command.getClass().equals(BrowseGenresReply.class)) {
			BrowseGenresReply reply = (BrowseGenresReply)_command;
			
			Iterator<Genre> it = reply.getGenres().iterator();
			while (it.hasNext()) {
				Genre genre = (Genre)it.next();
				CommandInterface flashCommand = new AlbumCommand();
				flashCommand.setDisplayName(model.getCurrentPlayer().getOutputKey());
				flashCommand.setTargetDeviceID(-1);
				flashCommand.setUser(model.currentUser);
				flashCommand.setExtraInfo(genre.getId());
				flashCommand.setExtra2Info(genre.getGenre());
				flashCommand.setKey("CLIENT_SEND");
				flashCommand.setCommand("GENRE");
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
		logger.log(Level.FINER, "Sending " + command.getXMLCommand().toString());
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
