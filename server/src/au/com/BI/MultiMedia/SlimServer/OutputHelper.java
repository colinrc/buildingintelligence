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
				// <CONTROL KEY="<extender>" COMMAND="BROWSE" EXTRA="<type>" EXTRA2="<start>" EXTRA3="<searchString>" EXTRA4="<artistId>" EXTRA5="<genre>" />
				// <CONTROL KEY="LAPTOP" COMMAND="BROWSE" EXTRA="ALBUMS" EXTRA2="0" EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="BROWSE" EXTRA="ALBUMS" EXTRA2="10" EXTRA3="trance" EXTRA4="" EXTRA5="" />
				// type can be
				// ALBUMS
				// ARTISTS
				// GENRES
				// NOWPLAYING
				// PLAYLISTS
				if (command.getExtraInfo().equalsIgnoreCase("ALBUMS")) {
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
					
				} else if (command.getExtraInfo().equalsIgnoreCase("GENRES")) {
					
				} else if (command.getExtraInfo().equalsIgnoreCase("PLAYLISTS")) {
					
				}
				
				// what are we browsing?
				
				// 
			} else if (command.getCommandCode().equalsIgnoreCase("PLAY")) {
				// <CONTROL KEY="<extender>" COMMAND="PLAY" EXTRA="<type>" EXTRA2="<id>" EXTRA3="" EXTRA4="" EXTRA5="" />
				// where type can be
				// ALBUM
				// SONG
				
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
