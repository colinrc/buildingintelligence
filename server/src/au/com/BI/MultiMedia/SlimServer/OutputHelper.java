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
			ConfigHelper configHelper, Cache cache, CommDevice comms,
			au.com.BI.MultiMedia.SlimServer.Model model) throws CommsFail {

		String key = command.getKey();
		String retCode = "";

		DeviceType device = configHelper.getOutputItem(key);

		if (device != null) {
			model.setCurrentPlayer((Audio) device);

			if (command.getCommandCode().equalsIgnoreCase("getAlbums")) {
				/*
				  <CONTROL KEY="lounge_music" COMMAND="getAlbums" EXTRA="1" EXTRA2="10" EXTRA3="genre:<genre id>" EXTRA4="<search>" EXTRA5=""/>
					- extra = page
					- extra2 = items per page
					- extra3 = optional filter [genre/artist/year etc] - separated by semi colons
					- extra4 = search string
					- extra5 = 
					
					<CONTROL KEY="LAPTOP" COMMAND="getAlbums" EXTRA="0" EXTRA2="20" EXTRA3="genre:1" EXTRA4="" EXTRA5=""/>
					<CONTROL KEY="LAPTOP" COMMAND="getAlbums" EXTRA="0" EXTRA2="20" EXTRA3="genre:1;year:2000" EXTRA4="" EXTRA5=""/>
					<CONTROL KEY="LAPTOP" COMMAND="getAlbums" EXTRA="0" EXTRA2="20" EXTRA3="artist:104" EXTRA4="" EXTRA5=""/>
					<CONTROL KEY="LAPTOP" COMMAND="getAlbums" EXTRA="0" EXTRA2="1" EXTRA3="" EXTRA4="Love" EXTRA5=""/>
					
					returns
					<albums KEY="LAPTOP">
						<item id="84" album="Dangerously In Love" title="Dangerously In Love" 
						coverArt="http://192.168.0.3:9000/music/230/cover.jpg" 
						thumbCoverArt="http://192.168.0.3:9000/music/230/thumb.jpg" 
						disc="-1" disccount="-1" compilation="false" year="2003" />
					</albums>

					returns:
					<albums>
						<item album="" coverArt="" />
					</albums>
				 */
				BrowseAlbums browseAlbums = new BrowseAlbums();
				int start = 0;
				int numberOfResults = 0;
				String filter = command.getExtra3Info();
				String searchString = command.getExtra4Info();

				try {
					start = Integer.parseInt(command.getExtraInfo());
				} catch (NumberFormatException e) {
					logger.log(Level.WARNING,
							"Start parameter was not a number for command: "
									+ command.toString());
				}
				browseAlbums.setStart(start);
				
				try {
					numberOfResults = Integer.parseInt(command.getExtra2Info());
				} catch (NumberFormatException e) {
					logger.log(Level.WARNING,
							"number of results parameter was not a number for command: "
									+ command.toString());
				}
				browseAlbums.setItemsPerResponse(numberOfResults);

				if (!StringUtils.isNullOrEmpty(searchString)) {
					browseAlbums.setSearch(searchString);
				}
				
				if (!StringUtils.isNullOrEmpty(filter)) {
					String[] filters = filter.split(";");
					int positionOfColon = -1;
					String tag = "";
					String value = "";
					
					for (int i=0;i<filters.length;i++) {
						positionOfColon = filters[i].indexOf(":");
						tag = filters[i].substring(0,positionOfColon);
						value = filters[i].substring(positionOfColon+1);
						
						if (tag.equalsIgnoreCase("genre")) {
							try {
								browseAlbums.setGenre(Integer.parseInt(value));
							} catch (NumberFormatException e) {
								logger.log(Level.WARNING,
										"genre found but is not an integer");
							}
						} else if (tag.equalsIgnoreCase("artist")) {
							try {
								browseAlbums.setArtist(Integer.parseInt(value));
							} catch (NumberFormatException e) {
								logger.log(Level.WARNING,
										"artist found but is not an integer");
							}
						} else if (tag.equalsIgnoreCase("year")) {
							try {
								browseAlbums.setYear(Integer.parseInt(value));
							} catch (NumberFormatException e) {
								logger.log(Level.WARNING,
										"year found but is not an integer");
							}
						}
					}
				}

				retCode = browseAlbums.buildCommandString() + "\r\n";
			} else if (command.getCommandCode().equalsIgnoreCase("getArtists")) {
				
				/*
				  <CONTROL KEY="lounge_music" COMMAND="getArtists" EXTRA="1" EXTRA2="10" EXTRA3="genre:<genre id>" EXTRA4="<search>" EXTRA5=""/>
					- extra = page
					- extra2 = items per page
					- extra3 = optional filter [genre/album] - separated by semi colons
					- extra4 = search string
					- extra5 = 
					
					<CONTROL KEY="LAPTOP" COMMAND="getArtists" EXTRA="0" EXTRA2="20" EXTRA3="genre:1" EXTRA4="" EXTRA5=""/>
					<CONTROL KEY="LAPTOP" COMMAND="getArtists" EXTRA="0" EXTRA2="20" EXTRA3="album:104" EXTRA4="" EXTRA5=""/>
					<CONTROL KEY="LAPTOP" COMMAND="getArtists" EXTRA="0" EXTRA2="1" EXTRA3="" EXTRA4="Love" EXTRA5=""/>
					
					returns
					<artists KEY="LAPTOP">
						<item id="15" artist="50 cents" />
					</artists>

					returns:
					<albums>
						<item album="" coverArt="" />
					</albums>
				 */
				BrowseArtists browseArtists = new BrowseArtists();
				
				int start = 0;
				int numberOfResults = 0;
				String filter = command.getExtra3Info();
				String searchString = command.getExtra4Info();

				try {
					start = Integer.parseInt(command.getExtraInfo());
				} catch (NumberFormatException e) {
					logger.log(Level.WARNING,
							"Start parameter was not a number for command: "
									+ command.toString());
				}
				browseArtists.setStart(start);
				
				try {
					numberOfResults = Integer.parseInt(command.getExtra2Info());
				} catch (NumberFormatException e) {
					logger.log(Level.WARNING,
							"number of results parameter was not a number for command: "
									+ command.toString());
				}
				browseArtists.setItemsPerResponse(numberOfResults);

				if (!StringUtils.isNullOrEmpty(searchString)) {
					browseArtists.setSearch(searchString);
				}
				
				if (!StringUtils.isNullOrEmpty(filter)) {
					String[] filters = filter.split(";");
					int positionOfColon = -1;
					String tag = "";
					String value = "";
					
					for (int i=0;i<filters.length;i++) {
						positionOfColon = filters[i].indexOf(":");
						tag = filters[i].substring(0,positionOfColon);
						value = filters[i].substring(positionOfColon+1);
						
						if (tag.equalsIgnoreCase("genre")) {
							try {
								browseArtists.setGenre(Integer.parseInt(value));
							} catch (NumberFormatException e) {
								logger.log(Level.WARNING,
										"genre found but is not an integer");
							}
						} else if (tag.equalsIgnoreCase("album")) {
							try {
								browseArtists.setAlbum(Integer.parseInt(value));
							} catch (NumberFormatException e) {
								logger.log(Level.WARNING,
										"album found but is not an integer");
							}
						}
					}
				}

				retCode = browseArtists.buildCommandString() + "\r\n";

			} else if (command.getCommandCode().equalsIgnoreCase("getGenres")) {				
				/*
				  <CONTROL KEY="lounge_music" COMMAND="getArtists" EXTRA="1" EXTRA2="10" EXTRA3="album:<album id>" EXTRA4="<search>" EXTRA5=""/>
					- extra = page
					- extra2 = items per page
					- extra3 = optional filter [artist/album/track/year] - separated by semi colons
					- extra4 = search string
					- extra5 = 
					
					<CONTROL KEY="LAPTOP" COMMAND="getGenres" EXTRA="0" EXTRA2="20" EXTRA3="artist:1" EXTRA4="" EXTRA5=""/>
					<CONTROL KEY="LAPTOP" COMMAND="getGenres" EXTRA="0" EXTRA2="20" EXTRA3="album:104" EXTRA4="" EXTRA5=""/>
					<CONTROL KEY="LAPTOP" COMMAND="getGenres" EXTRA="0" EXTRA2="1" EXTRA3="" EXTRA4="Love" EXTRA5=""/>
					
					returns
					<genres KEY="LAPTOP">
						<item id="13" genre="Electronica" />
					</genres>
				 */
				BrowseGenres browseGenres = new BrowseGenres();
				int start = 0;
				int numberOfResults = 0;
				String filter = command.getExtra3Info();
				String searchString = command.getExtra4Info();

				try {
					start = Integer.parseInt(command.getExtraInfo());
				} catch (NumberFormatException e) {
					logger.log(Level.WARNING,
							"Start parameter was not a number for command: "
									+ command.toString());
				}
				browseGenres.setStart(start);
				
				try {
					numberOfResults = Integer.parseInt(command.getExtra2Info());
				} catch (NumberFormatException e) {
					logger.log(Level.WARNING,
							"number of results parameter was not a number for command: "
									+ command.toString());
				}
				browseGenres.setItemsPerResponse(numberOfResults);

				if (!StringUtils.isNullOrEmpty(searchString)) {
					browseGenres.setSearch(searchString);
				}
				
				if (!StringUtils.isNullOrEmpty(filter)) {
					String[] filters = filter.split(";");
					int positionOfColon = -1;
					String tag = "";
					String value = "";
					
					for (int i=0;i<filters.length;i++) {
						positionOfColon = filters[i].indexOf(":");
						tag = filters[i].substring(0,positionOfColon);
						value = filters[i].substring(positionOfColon+1);
						
						if (tag.equalsIgnoreCase("album")) {
							try {
								browseGenres.setAlbum(Integer.parseInt(value));
							} catch (NumberFormatException e) {
								logger.log(Level.WARNING,
										"album found but is not an integer");
							}
						} else if (tag.equalsIgnoreCase("year")) {
							try {
								browseGenres.setYear(Integer.parseInt(value));
							} catch (NumberFormatException e) {
								logger.log(Level.WARNING,
										"year found but is not an integer");
							}
						} else if (tag.equalsIgnoreCase("artist")) {
							try {
								browseGenres.setArtist(Integer.parseInt(value));
							} catch (NumberFormatException e) {
								logger.log(Level.WARNING,
										"artist found but is not an integer");
							}
						} else if (tag.equalsIgnoreCase("track")) {
							try {
								browseGenres.setTrack(Integer.parseInt(value));
							} catch (NumberFormatException e) {
								logger.log(Level.WARNING,
										"track found but is not an integer");
							}
						}
					}
				}

				retCode = browseGenres.buildCommandString() + "\r\n";
			} else if (command.getCommandCode()
					.equalsIgnoreCase("getPlaylists")) {

			} else if (command.getCommandCode().equalsIgnoreCase("PLAY")) {
				// <CONTROL KEY="<extender>" COMMAND="PLAY" EXTRA="<type>"
				// EXTRA2="<id>" EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="PLAY" EXTRA="" EXTRA2=""
				// EXTRA3="" EXTRA4="" EXTRA5="" />
				Play play = new Play();
				play.setPlayerId(device.getKey());
				retCode = play.buildCommandString() + "\r\n";
			} else if (command.getCommandCode().equalsIgnoreCase("STOP")) {
				// <CONTROL KEY="<extender>" COMMAND="STOP" EXTRA="<type>"
				// EXTRA2="<id>" EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="STOP" EXTRA="" EXTRA2=""
				// EXTRA3="" EXTRA4="" EXTRA5="" />
				Pause pause = new Pause();
				pause.setPlayerId(device.getKey());
				retCode = pause.buildCommandString() + "\r\n";
			} else if (command.getCommandCode().equalsIgnoreCase("PAUSE")) {
				// <CONTROL KEY="<extender>" COMMAND="PAUSE" EXTRA="<type>"
				// EXTRA2="<id>" EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="PAUSE" EXTRA="" EXTRA2=""
				// EXTRA3="" EXTRA4="" EXTRA5="" />
				Stop stop = new Stop();
				stop.setPlayerId(device.getKey());
				retCode = stop.buildCommandString() + "\r\n";
			} else if (command.getCommandCode().equalsIgnoreCase("ADD")
					|| command.getCommandCode().equalsIgnoreCase("DELETE")
					|| command.getCommandCode().equalsIgnoreCase("INSERT")
					|| command.getCommandCode().equalsIgnoreCase("LOAD")) {
				// <CONTROL KEY="<extender>" COMMAND="<command>"
				// EXTRA="<ALBUM_ID>" EXTRA2="<YEAR_ID>" EXTRA3="<TRACK_ID>"
				// EXTRA4="<GENRE_ID>" EXTRA5="<ARTIST_ID>" />
				// <CONTROL KEY="LAPTOP" COMMAND="ADD" EXTRA="325" EXTRA2=""
				// EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="DELETE" EXTRA="325" EXTRA2=""
				// EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="LOAD" EXTRA="325" EXTRA2=""
				// EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="LOAD" EXTRA="" EXTRA2="1999"
				// EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="INSERT" EXTRA="325" EXTRA2=""
				// EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="SQUEEZEBOX" COMMAND="ADD" EXTRA="" EXTRA2=""
				// EXTRA3="" EXTRA4="18" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="ADD" EXTRA="" EXTRA2=""
				// EXTRA3="" EXTRA4="18" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="LOAD" EXTRA="" EXTRA2="" EXTRA3="" EXTRA4="2" EXTRA5="" />
				int album_id = -1;
				int year_id = -1;
				int track_id = -1;
				int genre_id = -1;
				int artist_id = -1;

				PlayListControl control = new PlayListControl();
				control.setPlayerId(device.getKey());
				control.setCommand(PlayListCommand.getByDescription(command
						.getCommandCode()));

				try {
					if (!StringUtils.isNullOrEmpty(command.getExtraInfo())) {
						album_id = Integer.parseInt(command.getExtraInfo());
					}
				} catch (NumberFormatException e) {
					logger.log(Level.WARNING,
							"album parameter was not a number for command: "
									+ command.toString());
				}
				if (album_id != -1) {
					control.setAlbum_id(album_id);
				}

				try {
					if (!StringUtils.isNullOrEmpty(command.getExtra2Info())) {
						year_id = Integer.parseInt(command.getExtra2Info());
					}
				} catch (NumberFormatException e) {
					logger.log(Level.WARNING,
							"year parameter was not a number for command: "
									+ command.toString());
				}
				if (year_id != -1) {
					control.setYear_id(year_id);
				}

				try {
					if (!StringUtils.isNullOrEmpty(command.getExtra3Info())) {
						track_id = Integer.parseInt(command.getExtra3Info());
					}
				} catch (NumberFormatException e) {
					logger.log(Level.WARNING,
							"track parameter was not a number for command: "
									+ command.toString());
				}
				if (track_id != -1) {
					control.setTrack_id(track_id);
				}

				try {
					if (!StringUtils.isNullOrEmpty(command.getExtra4Info())) {
						genre_id = Integer.parseInt(command.getExtra4Info());
					}
				} catch (NumberFormatException e) {
					logger.log(Level.WARNING,
							"genre parameter was not a number for command: "
									+ command.toString());
				}
				if (genre_id != -1) {
					control.setGenre_id(genre_id);
				}

				try {
					if (!StringUtils.isNullOrEmpty(command.getExtra5Info())) {
						artist_id = Integer.parseInt(command.getExtra5Info());
					}
				} catch (NumberFormatException e) {
					logger.log(Level.WARNING,
							"artist parameter was not a number for command: "
									+ command.toString());
				}
				if (artist_id != -1) {
					control.setArtist_id(artist_id);
				}

				retCode = control.buildCommandString() + "\r\n";
			}
		}

		if (!StringUtils.isNullOrEmpty(retCode)) {
			logger
					.log(Level.INFO, "Sending command to Slim Server: "
							+ retCode);
			CommsCommand _commsCommand = new CommsCommand(key, retCode, null);
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
