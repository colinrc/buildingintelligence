package au.com.BI.MultiMedia.SlimServer;

import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Audio.Audio;
import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Comms.CommDevice;
import au.com.BI.Comms.CommsCommand;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.Device.DeviceType;
import au.com.BI.MultiMedia.SlimServer.Commands.BrowseAlbums;
import au.com.BI.MultiMedia.SlimServer.Commands.BrowseArtists;
import au.com.BI.MultiMedia.SlimServer.Commands.BrowseGenres;
import au.com.BI.MultiMedia.SlimServer.Commands.Pause;
import au.com.BI.MultiMedia.SlimServer.Commands.Play;
import au.com.BI.MultiMedia.SlimServer.Commands.PlayListCommand;
import au.com.BI.MultiMedia.SlimServer.Commands.PlayListControl;
import au.com.BI.MultiMedia.SlimServer.Commands.Stop;
import au.com.BI.Util.StringUtils;

public class OutputHelper {
	
	protected Logger logger;
	private int defaultSearchResults;
	
	public OutputHelper() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
	public void doOutputItem(CommandInterface command,
			ConfigHelper configHelper, 
			Cache cache, 
			CommDevice comms,
			au.com.BI.MultiMedia.SlimServer.Model model) throws CommsFail {
		
		String key = command.getKey();
		String retCode = "";
		
		DeviceType device = configHelper.getOutputItem(key);
		
		if (device != null) {
			model.setCurrentPlayer((Audio)device);
			
			if (command.getCommandCode().equalsIgnoreCase("BROWSE")) {
				// <CONTROL KEY="<extender>" COMMAND="BROWSE" EXTRA="<type>" EXTRA2="<start>" EXTRA3="<searchString>" EXTRA4="<extra>" EXTRA5="<extra>" />
				// type can be
				// ALBUMS
				// ARTISTS
				// GENRES
				// NOWPLAYING
				// PLAYLISTS
				if (command.getExtraInfo().equalsIgnoreCase("ALBUMS")) {
					// <CONTROL KEY="<extender>" COMMAND="BROWSE" EXTRA="ALBUMS" EXTRA2="<start>" EXTRA3="<searchString>" EXTRA4="<artistId>" EXTRA5="<genre>" />
					// <CONTROL KEY="LAPTOP" COMMAND="BROWSE" EXTRA="ALBUMS" EXTRA2="0" EXTRA3="" EXTRA4="" EXTRA5="" />
					// <CONTROL KEY="LAPTOP" COMMAND="BROWSE" EXTRA="ALBUMS" EXTRA2="10" EXTRA3="trance" EXTRA4="" EXTRA5="" />
					BrowseAlbums browseAlbums = new BrowseAlbums();
					int start = 0;
					String searchString = command.getExtra3Info();
					int artistId = -1;
					int genreId = -1;
					
					browseAlbums.setItemsPerResponse(this.getDefaultSearchResults());
					
					try {
						start = Integer.parseInt(command.getExtra2Info());
					} catch (NumberFormatException e) {
						logger.log(Level.WARNING, "Start parameter was not a number for command: " + command.toString());
					}
					browseAlbums.setStart(start);
					
					if (!StringUtils.isNullOrEmpty(searchString)) {
						browseAlbums.setSearch(searchString);
					}
					
					try {
						if (!StringUtils.isNullOrEmpty(command.getExtra4Info())) {
							artistId = Integer.parseInt(command.getExtra4Info());
						}
					} catch (NumberFormatException e) {
						logger.log(Level.INFO, "artistId parameter was not a number for command: " + command.toString());
					}
					
					if (artistId != -1) {
						browseAlbums.setArtist(artistId);
					}
					
					try {
						if (!StringUtils.isNullOrEmpty(command.getExtra5Info())) {
							genreId = Integer.parseInt(command.getExtra5Info());
						}
					} catch (NumberFormatException e) {
						logger.log(Level.INFO, "genreId parameter was not a number for command: " + command.toString());
					}
					if (genreId != -1) {
						browseAlbums.setGenre(genreId);
					}
					
					retCode = browseAlbums.buildCommandString() + "\r\n";
				} else if (command.getExtraInfo().equalsIgnoreCase("ARTISTS")) {
					// <CONTROL KEY="<extender>" COMMAND="BROWSE" EXTRA="ARTISTS" EXTRA2="<start>" EXTRA3="<searchString>" EXTRA4="<genreId>" EXTRA5="<albumId>" />
					// <CONTROL KEY="LAPTOP" COMMAND="BROWSE" EXTRA="ARTISTS" EXTRA2="0" EXTRA3="" EXTRA4="1" EXTRA5="" />
					// <CONTROL KEY="LAPTOP" COMMAND="BROWSE" EXTRA="ARTISTS" EXTRA2="10" EXTRA3="trance" EXTRA4="" EXTRA5="" />
					BrowseArtists browseArtists = new BrowseArtists();
					
					int start = 0;
					String searchString = command.getExtra3Info();
					int albumId = -1;
					int genreId = -1;
					
					browseArtists.setItemsPerResponse(this.getDefaultSearchResults());
					
					try {
						start = Integer.parseInt(command.getExtra2Info());
					} catch (NumberFormatException e) {
						logger.log(Level.WARNING, "Start parameter was not a number for command: " + command.toString());
					}
					browseArtists.setStart(start);
					
					if (!StringUtils.isNullOrEmpty(searchString)) {
						browseArtists.setSearch(searchString);
					}
					
					try {
						if (!StringUtils.isNullOrEmpty(command.getExtra4Info())) {
							genreId = Integer.parseInt(command.getExtra4Info());
						}
					} catch (NumberFormatException e) {
						logger.log(Level.INFO, "artistId parameter was not a number for command: " + command.toString());
					}
					
					if (genreId != -1) {
						browseArtists.setGenre(genreId);
					}
					
					try {
						if (!StringUtils.isNullOrEmpty(command.getExtra5Info())) {
							albumId = Integer.parseInt(command.getExtra5Info());
						}
					} catch (NumberFormatException e) {
						logger.log(Level.INFO, "albumId parameter was not a number for command: " + command.toString());
					}
					if (albumId != -1) {
						browseArtists.setAlbum(albumId);
					}
					
					retCode = browseArtists.buildCommandString() + "\r\n";
					
				} else if (command.getExtraInfo().equalsIgnoreCase("GENRES")) {
					// <CONTROL KEY="<extender>" COMMAND="BROWSE" EXTRA="GENRES" EXTRA2="<start>" EXTRA3="<searchString>" EXTRA4="<artistId>" EXTRA5="<albumId>" />
					// <CONTROL KEY="LAPTOP" COMMAND="BROWSE" EXTRA="GENRES" EXTRA2="0" EXTRA3="" EXTRA4="" EXTRA5="" />
					// <CONTROL KEY="LAPTOP" COMMAND="BROWSE" EXTRA="GENRES" EXTRA2="10" EXTRA3="trance" EXTRA4="" EXTRA5="" />
					BrowseGenres browseGenres = new BrowseGenres();
					int start = 0;
					String searchString = command.getExtra3Info();
					int artistId = -1;
					int albumId = -1;
					
					browseGenres.setItemsPerResponse(this.getDefaultSearchResults());
					
					try {
						start = Integer.parseInt(command.getExtra2Info());
					} catch (NumberFormatException e) {
						logger.log(Level.WARNING, "Start parameter was not a number for command: " + command.toString());
					}
					browseGenres.setStart(start);
					
					if (!StringUtils.isNullOrEmpty(searchString)) {
						browseGenres.setSearch(searchString);
					}
					
					try {
						if (!StringUtils.isNullOrEmpty(command.getExtra4Info())) {
							artistId = Integer.parseInt(command.getExtra4Info());
						}
					} catch (NumberFormatException e) {
						logger.log(Level.INFO, "artistId parameter was not a number for command: " + command.toString());
					}
					
					if (artistId != -1) {
						browseGenres.setArtist(artistId);
					}
					
					try {
						if (!StringUtils.isNullOrEmpty(command.getExtra5Info())) {
							albumId = Integer.parseInt(command.getExtra5Info());
						}
					} catch (NumberFormatException e) {
						logger.log(Level.INFO, "albumId parameter was not a number for command: " + command.toString());
					}
					if (albumId != -1) {
						browseGenres.setAlbum(albumId);
					}
					
					retCode = browseGenres.buildCommandString() + "\r\n";
				} else if (command.getExtraInfo().equalsIgnoreCase("PLAYLISTS")) {
					
				}
			} else if (command.getCommandCode().equalsIgnoreCase("PLAY")) {
				// <CONTROL KEY="<extender>" COMMAND="PLAY" EXTRA="<type>" EXTRA2="<id>" EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="PLAY" EXTRA="" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				Play play = new Play();
				play.setPlayerId(device.getKey());
				retCode = play.buildCommandString() + "\r\n";
			} else if (command.getCommandCode().equalsIgnoreCase("STOP")) {
				// <CONTROL KEY="<extender>" COMMAND="STOP" EXTRA="<type>" EXTRA2="<id>" EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="STOP" EXTRA="" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				Pause pause = new Pause();
				pause.setPlayerId(device.getKey());
				retCode = pause.buildCommandString() + "\r\n";
			} else if (command.getCommandCode().equalsIgnoreCase("PAUSE")) {
				// <CONTROL KEY="<extender>" COMMAND="PAUSE" EXTRA="<type>" EXTRA2="<id>" EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="PAUSE" EXTRA="" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				Stop stop = new Stop();
				stop.setPlayerId(device.getKey());
				retCode = stop.buildCommandString() + "\r\n";
			} else if (command.getCommandCode().equalsIgnoreCase("ADD") ||
					command.getCommandCode().equalsIgnoreCase("DELETE") ||
					command.getCommandCode().equalsIgnoreCase("INSERT") ||
					command.getCommandCode().equalsIgnoreCase("LOAD")) {
				// <CONTROL KEY="<extender>" COMMAND="<command>" EXTRA="<ALBUM_ID>" EXTRA2="<YEAR_ID>" EXTRA3="<TRACK_ID>" EXTRA4="<GENRE_ID>" EXTRA5="<ARTIST_ID>" />
				// <CONTROL KEY="LAPTOP" COMMAND="ADD" EXTRA="325" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="DELETE" EXTRA="325" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="LOAD" EXTRA="325" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="LOAD" EXTRA="" EXTRA2="1999" EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="INSERT" EXTRA="325" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="SQUEEZEBOX" COMMAND="ADD" EXTRA="" EXTRA2="" EXTRA3="" EXTRA4="18" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="ADD" EXTRA="" EXTRA2="" EXTRA3="" EXTRA4="18" EXTRA5="" />
				int album_id = -1;
				int year_id = -1;
				int track_id = -1;
				int genre_id = -1;
				int artist_id = -1;
				
				PlayListControl control = new PlayListControl();
				control.setPlayerId(device.getKey());
				control.setCommand(PlayListCommand.getByDescription(command.getCommandCode()));
				
				try {
					if (!StringUtils.isNullOrEmpty(command.getExtraInfo())) {
						album_id = Integer.parseInt(command.getExtraInfo());
					}
				} catch (NumberFormatException e) {
					logger.log(Level.WARNING, "album parameter was not a number for command: " + command.toString());
				}
				if (album_id != -1) {
					control.setAlbum_id(album_id);
				}
				
				try {
					if (!StringUtils.isNullOrEmpty(command.getExtra2Info())) {
						year_id = Integer.parseInt(command.getExtra2Info());
					}
				} catch (NumberFormatException e) {
					logger.log(Level.WARNING, "year parameter was not a number for command: " + command.toString());
				}
				if (year_id != -1) {
					control.setYear_id(year_id);
				}
				
				try {
					if (!StringUtils.isNullOrEmpty(command.getExtra3Info())) {
						track_id = Integer.parseInt(command.getExtra3Info());
					}
				} catch (NumberFormatException e) {
					logger.log(Level.WARNING, "track parameter was not a number for command: " + command.toString());
				}
				if (track_id != -1) {
					control.setTrack_id(track_id);
				}
				
				try {
					if (!StringUtils.isNullOrEmpty(command.getExtra4Info())) {
						genre_id = Integer.parseInt(command.getExtra4Info());
					}
				} catch (NumberFormatException e) {
					logger.log(Level.WARNING, "genre parameter was not a number for command: " + command.toString());
				}
				if (genre_id != -1) {
					control.setGenre_id(genre_id);
				}
				
				try {
					if (!StringUtils.isNullOrEmpty(command.getExtra5Info())) {
						artist_id = Integer.parseInt(command.getExtra5Info());
					}
				} catch (NumberFormatException e) {
					logger.log(Level.WARNING, "artist parameter was not a number for command: " + command.toString());
				}
				if (artist_id != -1) {
					control.setArtist_id(artist_id);
				}
				
				retCode = control.buildCommandString() + "\r\n";
			}
		}
		
		if (!StringUtils.isNullOrEmpty(retCode)) { 
			logger.log(Level.INFO, "Sending command to Slim Server: " + retCode);
			CommsCommand _commsCommand = new CommsCommand(key,retCode,null);
			comms.addCommandToQueue(_commsCommand);
			
			if (!comms.sendNextCommand()) {
				throw new CommsFail("Failed to send command:" + retCode);
			}
		}
	}

	public int getDefaultSearchResults() {
		return defaultSearchResults;
	}

	public void setDefaultSearchResults(int defaultSearchResults) {
		this.defaultSearchResults = defaultSearchResults;
	}

}
