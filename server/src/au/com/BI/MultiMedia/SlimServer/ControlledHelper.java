package au.com.BI.MultiMedia.SlimServer;

import java.util.Iterator;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.AlarmLogging.AlarmLogging;
import au.com.BI.Alert.AlertCommand;
import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Command.CommandQueue;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.Device.DeviceType;
import au.com.BI.MultiMedia.Album;
import au.com.BI.MultiMedia.AlbumCommand;
import au.com.BI.MultiMedia.Artist;
import au.com.BI.MultiMedia.ArtistCommand;
import au.com.BI.MultiMedia.Genre;
import au.com.BI.MultiMedia.GenreCommand;
import au.com.BI.MultiMedia.PlayerStatusCommand;
import au.com.BI.MultiMedia.TrackCommand;
import au.com.BI.MultiMedia.SlimServer.Commands.BrowseAlbumsReply;
import au.com.BI.MultiMedia.SlimServer.Commands.BrowseArtistsReply;
import au.com.BI.MultiMedia.SlimServer.Commands.BrowseGenresReply;
import au.com.BI.MultiMedia.SlimServer.Commands.GetTracksReply;
import au.com.BI.MultiMedia.SlimServer.Commands.PlayerStatusReply;
import au.com.BI.MultiMedia.SlimServer.Commands.PowerReply;
import au.com.BI.MultiMedia.SlimServer.Commands.SlimServerCommand;
import au.com.BI.MultiMedia.SlimServer.Commands.SlimServerCommandException;
import au.com.BI.MultiMedia.SlimServer.Commands.SlimServerCommandFactory;
import au.com.BI.Util.StringUtils;

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
			
			// albums want coverart.
			BrowseAlbumsReply reply = (BrowseAlbumsReply)_command;
			
			AlbumCommand flashCommand = new AlbumCommand();
			
			Iterator<Album> it = reply.getAlbums().iterator();
			while (it.hasNext()) {
				Album album = (Album)it.next();
				album.setUrlPath(model.getCoverArtUrl());
				
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
			
			ArtistCommand flashCommand = new ArtistCommand();
			Iterator<Artist> it = reply.getArtists().iterator();
			while (it.hasNext()) {
				Artist artist = (Artist)it.next();
				
				flashCommand.getArtists().add(artist);
			}
			flashCommand.setDisplayName(model.getCurrentPlayer().getOutputKey());
			flashCommand.setTargetDeviceID(-1);
			flashCommand.setUser(model.currentUser);
			flashCommand.setKey("CLIENT_SEND");
			flashCommand.setCommand("ARTIST");
			sendCommand(cache, commandQueue, flashCommand);
			
		} else if (_command.getClass().equals(BrowseGenresReply.class)) {
			BrowseGenresReply reply = (BrowseGenresReply)_command;
			
			GenreCommand flashCommand = new GenreCommand();
			Iterator<Genre> it = reply.getGenres().iterator();
			while (it.hasNext()) {
				Genre genre = (Genre)it.next();
				
				flashCommand.getGenres().add(genre);
			}
			flashCommand.setDisplayName(model.getCurrentPlayer().getOutputKey());
			flashCommand.setTargetDeviceID(-1);
			flashCommand.setUser(model.currentUser);
			flashCommand.setKey("CLIENT_SEND");
			flashCommand.setCommand("GENRE");
			sendCommand(cache, commandQueue, flashCommand);
		} else if (_command.getClass().equals(PlayerStatusReply.class)) {
			PlayerStatusReply reply = (PlayerStatusReply)_command;
			DeviceType device = model.getConfigHelper().getControlledItem(reply.getPlayerId()); 
			reply.setPlayerKey(device.getOutputKey());
			reply.setCoverArtUrl(model.getCoverArtUrl());
			String powerString = "";
			
			if (!StringUtils.isNullOrEmpty(reply.getPower())) {
				if (reply.getPower().equals("0")) {
					powerString = "OFF";
				} else {
					powerString = "ON";
				}
			}
			
			PlayerStatusCommand flashCommand = new PlayerStatusCommand();
			flashCommand.setPlayerstatus(reply);
			flashCommand.setDisplayName(device.getOutputKey());
			flashCommand.setTargetDeviceID(-1);
			flashCommand.setUser(model.currentUser);
			flashCommand.setKey("CLIENT_SEND");
			flashCommand.setCommand("PLAYER_STATUS");
			sendCommand(cache,commandQueue,flashCommand);
			
			GetTracksReply getTracksReply = new GetTracksReply();
			getTracksReply.setForCurrentPlaylist(true);
			getTracksReply.setTracks(reply.getTracks());
			// getTracksReply.setCoverArtUrl(model.getCoverArtUrl());
			TrackCommand trackCommand = new TrackCommand();
			trackCommand.setGetTracksReply(getTracksReply);
			trackCommand.setDisplayName(device.getOutputKey());
			trackCommand.setTargetDeviceID(-1);
			trackCommand.setUser(model.currentUser);
			trackCommand.setKey("CLIENT_SEND");
			trackCommand.setCommand("PLAYER_STATUS");
			sendCommand(cache,commandQueue,trackCommand);
			
			/* CommandInterface flashCommand2 = new AlertCommand();
			flashCommand2.setDisplayName(device.getOutputKey());
			flashCommand2.setCommand(powerString);
			flashCommand2.setTargetDeviceID(-1);
			flashCommand2.setUser(model.currentUser);
			flashCommand2.setKey ("CLIENT_SEND");
			sendCommand(cache, commandQueue, flashCommand2); */
			
		} else if (_command.getClass().equals(GetTracksReply.class)) {
			GetTracksReply reply = (GetTracksReply)_command;
			
			reply.setCoverArtUrl(model.getCoverArtUrl());
			TrackCommand flashCommand = new TrackCommand();
			flashCommand.setGetTracksReply(reply);
			flashCommand.setDisplayName(model.getCurrentPlayer().getOutputKey());
			flashCommand.setTargetDeviceID(-1);
			flashCommand.setUser(model.currentUser);
			flashCommand.setKey("CLIENT_SEND");
			flashCommand.setCommand("PLAYER_STATUS");
			sendCommand(cache,commandQueue,flashCommand);
		} else if (_command.getClass().equals(PowerReply.class)) {
			PowerReply reply = (PowerReply)_command;
			DeviceType device = model.getConfigHelper().getControlledItem(reply.getPlayerId());
			
			CommandInterface flashCommand = new AlertCommand();
			flashCommand.setDisplayName(device.getOutputKey());
			flashCommand.setCommand(reply.getPowerString());
			flashCommand.setTargetDeviceID(-1);
			flashCommand.setUser(model.currentUser);
			flashCommand.setKey ("CLIENT_SEND");
			sendCommand(cache, commandQueue, flashCommand);
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
