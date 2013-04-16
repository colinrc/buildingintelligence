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
import au.com.BI.MultiMedia.SlimServer.Commands.GetTracks;
import au.com.BI.MultiMedia.SlimServer.Commands.Pause;
import au.com.BI.MultiMedia.SlimServer.Commands.Play;
import au.com.BI.MultiMedia.SlimServer.Commands.PlayListCommand;
import au.com.BI.MultiMedia.SlimServer.Commands.PlayListControl;
import au.com.BI.MultiMedia.SlimServer.Commands.PlayListDelete;
import au.com.BI.MultiMedia.SlimServer.Commands.PlayListIndex;
import au.com.BI.MultiMedia.SlimServer.Commands.PlayerStatus;
import au.com.BI.MultiMedia.SlimServer.Commands.Power;
import au.com.BI.MultiMedia.SlimServer.Commands.Stop;
import au.com.BI.MultiMedia.SlimServer.Commands.Volume;
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
				  <CONTROL KEY="lounge_music" COMMAND="getGenres" EXTRA="1" EXTRA2="10" EXTRA3="album:<album id>" EXTRA4="<search>" EXTRA5=""/>
					- extra = page
					- extra2 = items per page
					- extra3 = optional filter [artist/album/track/year] - separated by semi colons
					- extra4 = search string
					- extra5 = 
					
					<CONTROL KEY="LAPTOP" COMMAND="getGenres" EXTRA="0" EXTRA2="20" EXTRA3="artist:1" EXTRA4="" EXTRA5=""/>
					<CONTROL KEY="LAPTOP" COMMAND="getGenres" EXTRA="0" EXTRA2="20" EXTRA3="album:104" EXTRA4="" EXTRA5=""/>
					<CONTROL KEY="LAPTOP" COMMAND="getGenres" EXTRA="0" EXTRA2="1" EXTRA3="" EXTRA4="Love" EXTRA5=""/>
					<CONTROL KEY="LAPTOP" COMMAND="getGenres" EXTRA="0" EXTRA2="1" EXTRA3="" EXTRA4="" EXTRA5=""/>
					
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
				// <CONTROL KEY="LAPTOP" COMMAND="PLAY" EXTRA="" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				Play play = new Play();
				play.setPlayerId(device.getKey());
				retCode = play.buildCommandString() + "\r\n";
			} else if (command.getCommandCode().equalsIgnoreCase("STOP")) {
				// <CONTROL KEY="<extender>" COMMAND="STOP" EXTRA="<type>"
				// EXTRA2="<id>" EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="STOP" EXTRA="" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				Stop stop = new Stop();
				stop.setPlayerId(device.getKey());
				retCode = stop.buildCommandString() + "\r\n";
			} else if (command.getCommandCode().equalsIgnoreCase("PAUSE")) {
				// <CONTROL KEY="<extender>" COMMAND="PAUSE" EXTRA="<type>"
				// EXTRA2="<id>" EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="PAUSE" EXTRA="" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				Pause pause = new Pause();
				pause.setPlayerId(device.getKey());
				retCode = pause.buildCommandString() + "\r\n";
			} else if (command.getCommandCode().equalsIgnoreCase("ADD")
					|| command.getCommandCode().equalsIgnoreCase("DELETE")
					|| command.getCommandCode().equalsIgnoreCase("INSERT")
					|| command.getCommandCode().equalsIgnoreCase("LOAD")) {
				// <CONTROL KEY="<extender>" COMMAND="<command>" EXTRA="<ALBUM_ID>" EXTRA2="<YEAR_ID>" EXTRA3="<TRACK_ID>" EXTRA4="<GENRE_ID>" EXTRA5="<ARTIST_ID>" />
				// <CONTROL KEY="LAPTOP" COMMAND="ADD" EXTRA="324" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="DELETE" EXTRA="325" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="LOAD" EXTRA="325" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="LOAD" EXTRA="" EXTRA2="1999" EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="INSERT" EXTRA="325" EXTRA2=""
				// EXTRA3="" EXTRA4="" EXTRA5="" />
				// <CONTROL KEY="SQUEEZEBOX" COMMAND="ADD" EXTRA="" EXTRA2="" EXTRA3="" EXTRA4="18" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="ADD" EXTRA="" EXTRA2="" EXTRA3="" EXTRA4="18" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="LOAD" EXTRA="" EXTRA2="" EXTRA3="" EXTRA4="2" EXTRA5="" />
				// <CONTROL KEY="LAPTOP" COMMAND="DELETE" EXTRA="" EXTRA2="" EXTRA3="0" EXTRA4="" EXTRA5="" />
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
			} else if (command.getCommandCode().equalsIgnoreCase("queueItem")) {
				/*
				 * <control key="<squeeze box key>" command="queueItem" extra="<tag>:<item>" />
				 * Where tag can be:
				 *  - genre
				 *  - year
				 *  - album
				 *  - artist
				 *  - playlistname
				 *  - playlist
				 *  - track
				 * And the item is either an id (integer) for everything other than the playlist name
				 * 
				 * Will add to the current playlist
				 *  
				 *  <CONTROL KEY="LAPTOP" COMMAND="queueItem" EXTRA="artist:1" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5=""/>
				 *  <CONTROL KEY="LAPTOP" COMMAND="queueItem" EXTRA="album:1" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5=""/>
				 *  <CONTROL KEY="LAPTOP" COMMAND="queueItem" EXTRA="playlistname:Chillout" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5=""/>
				 */
				PlayListControl control = new PlayListControl();
				control.setPlayerId(device.getKey());
				control.setCommand(PlayListCommand.ADD);
				
				String filter = command.getExtraInfo();
				
				if (!StringUtils.isNullOrEmpty(filter)) {
					String[] filters = filter.split(";");
					int positionOfColon = -1;
					String tag = "";
					String value = "";
					
					for (int i=0;i<filters.length;i++) {
						positionOfColon = filters[i].indexOf(":");
						tag = filters[i].substring(0,positionOfColon);
						value = filters[i].substring(positionOfColon+1);
						
						if (tag.equalsIgnoreCase("year")) {
							try {
								control.setYear_id(Integer.parseInt(value));
							} catch (NumberFormatException e) {
								logger.log(Level.WARNING,
										"year found but is not an integer");
							}
						} else if (tag.equalsIgnoreCase("genre")) {
							try {
								control.setGenre_id(Integer.parseInt(value));
							} catch (NumberFormatException e) {
								logger.log(Level.WARNING,
										"genre found but is not an integer");
							}
						} else if (tag.equalsIgnoreCase("album")) {
							try {
								control.setAlbum_id(Integer.parseInt(value));
							} catch (NumberFormatException e) {
								logger.log(Level.WARNING,
										"album found but is not an integer");
							}
						} else if (tag.equalsIgnoreCase("artist")) {
							try {
								control.setArtist_id(Integer.parseInt(value));
							} catch (NumberFormatException e) {
								logger.log(Level.WARNING,
										"artist found but is not an integer");
							}
						} else if (tag.equalsIgnoreCase("playlist")) {
							try {
								control.setPlaylist_id(Integer.parseInt(value));
							} catch (NumberFormatException e) {
								logger.log(Level.WARNING,
										"playlist found but it is not an integer");
							}
						} else if (tag.equalsIgnoreCase("track")) {
							try {
								control.setTrack_id(Integer.parseInt(value));
							} catch (NumberFormatException e) {
								logger.log(Level.WARNING,
										"track found but it is not an integer");
							}
						} else if (tag.equalsIgnoreCase("playlistname")) {
							control.setPlaylist_name(value);
						}
					}
					
					retCode = control.buildCommandString() + "\r\n";
				} else {
					retCode = "";
				}
			} else if (command.getCommandCode().equalsIgnoreCase("nextItem")) {
				/*
				 * <control key="lounge_music" command="nextItem" />
				 * <CONTROL KEY="LAPTOP" COMMAND="nextItem" EXTRA="" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5=""/>
				 */
				PlayListIndex control = new PlayListIndex();
				control.setPlayerId(device.getKey());
				control.setPositiveIndex(1);
				retCode = control.buildCommandString() + "\r\n";
			} else if (command.getCommandCode().equalsIgnoreCase("previousItem")) {
				/*
				 * <control key="lounge_music" command="previousItem" />
				 * <CONTROL KEY="LAPTOP" COMMAND="previousItem" EXTRA="" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5=""/>
				 */
				PlayListIndex control = new PlayListIndex();
				control.setPlayerId(device.getKey());
				control.setNegativeIndex(1);
				retCode = control.buildCommandString() + "\r\n";
			} else if (command.getCommandCode().equalsIgnoreCase("jumpToPosition")) {
				/*
				 * <CONTROL KEY="LAPTOP" COMMAND="jumpToPosition" EXTRA="<position>" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				 */
				PlayListIndex control = new PlayListIndex();
				control.setPlayerId(device.getKey());
				try {
					control.setIndex(Integer.parseInt(command.getExtraInfo()));
				} catch (NumberFormatException e) {
					logger.log(Level.WARNING,
							"index found but it is not an integer");
				}
				if (control.getIndex() != -1) {
					retCode = control.buildCommandString() + "\r\n";
				}
			} else if (command.getCommandCode().equalsIgnoreCase("volume")) {
			
				/*
				 * <CONTROL KEY="LAPTOP" COMMAND="volume" EXTRA="up|down|<volume 0 .. 100>" EXTRA2"" EXTRA3="" EXTRA4="" EXTRA5="" />
				 * <CONTROL KEY="LAPTOP" COMMAND="volume" EXTRA="up" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				 * <CONTROL KEY="LAPTOP" COMMAND="volume" EXTRA="down" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				 * <CONTROL KEY="LAPTOP" COMMAND="volume" EXTRA="53.4" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				 */
				Volume control = new Volume();
				control.setPlayerId(device.getKey());
				
				// first try to get up down command
				if (command.getExtraInfo().equalsIgnoreCase("up")) {
					control.setVolumeUp(true);
				} else if (command.getExtraInfo().equalsIgnoreCase("down")) {
					control.setVolumeDown(true);
				} else {
					try {
						control.setVolume(Float.parseFloat(command.getExtraInfo()));
					} catch (NumberFormatException e) {
						logger.log(Level.WARNING,
								"index found but it is not an integer");
					}
				}
				
				retCode = control.buildCommandString() + "\r\n";
			} else if (command.getCommandCode().equalsIgnoreCase("power") || 
					   command.getCommandCode().equalsIgnoreCase("state")) {
			
				/*
				 * <CONTROL KEY="LAPTOP" COMMAND="power" EXTRA="on|off" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				 * <CONTROL KEY="LAPTOP" COMMAND="power" EXTRA="on" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				 * <CONTROL KEY="LAPTOP" COMMAND="power" EXTRA="off" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				 * <CONTROL KEY="LAPTOP" COMMAND="state" EXTRA="on|off" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				 * <CONTROL KEY="LAPTOP" COMMAND="state" EXTRA="on" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				 * <CONTROL KEY="LAPTOP" COMMAND="state" EXTRA="off" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				 */
				Power control = new Power();
				control.setPlayerId(device.getKey());
				
				// first try to get up down command
				if (command.getExtraInfo().equalsIgnoreCase("on")) {
					control.setPower(true);
				} else if (command.getExtraInfo().equalsIgnoreCase("off")) {
					control.setPower(false);
				}
				
				retCode = control.buildCommandString() + "\r\n";
			}  else if (command.getCommandCode().equalsIgnoreCase("on")) {
				/*
				 * <CONTROL KEY="LAPTOP" COMMAND="power" EXTRA="on" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				 */
				Power control = new Power();
				control.setPlayerId(device.getKey());
				control.setPower(true);
				
				retCode = control.buildCommandString() + "\r\n";
			}  else if (command.getCommandCode().equalsIgnoreCase("off")) {
				/*
				 * <CONTROL KEY="LAPTOP" COMMAND="off" EXTRA="" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				 */
				Power control = new Power();
				control.setPlayerId(device.getKey());

				control.setPower(false);
				
				retCode = control.buildCommandString() + "\r\n";
			} else if (command.getCommandCode().equalsIgnoreCase("getTracks")) {
				/*
				 * KEY is ignored
				 * EXTRA is the page to be displayed
				 * EXTRA2 is the number of items per page
				 * EXTRA3 can be one of the following:
				 *  - album
				 *  - artist
				 *  - genre
				 *  - year
				 * EXTRA4 is a search key
				 * EXTRA5 is a sort - either tracknum, title, artist, album, year or genre
				 * <CONTROL KEY="LAPTOP" COMMAND="getTracks" EXTRA="0" EXTRA2="20" EXTRA3="album:952" EXTRA4="" EXTRA5="" />
				 * <CONTROL KEY="LAPTOP" COMMAND="getTracks" EXTRA="0" EXTRA2="20" EXTRA3="" EXTRA4="al" EXTRA5="" />
				 * <CONTROL KEY="LAPTOP" COMMAND="getTracks" EXTRA="1" EXTRA2="20" EXTRA3="" EXTRA4="al" EXTRA5="" />
				 * <CONTROL KEY="LAPTOP" COMMAND="getTracks" EXTRA="0" EXTRA2="20" EXTRA3="album:659" EXTRA4="" EXTRA5="" />
				 * <CONTROL KEY="LAPTOP" COMMAND="getTracks" EXTRA="0" EXTRA2="20" EXTRA3="" EXTRA4="moby" EXTRA5="" />
				 * <CONTROL KEY="LAPTOP" COMMAND="getTracks" EXTRA="0" EXTRA2="20" EXTRA3="artist:1490" EXTRA4="" EXTRA5="" />
				 * 
				 * <CONTROL KEY="LAPTOP" COMMAND="getTracks" EXTRA="0" EXTRA2="20" EXTRA3="currentplaylist" EXTRA4="" EXTRA5="" />
				 * <CONTROL KEY="LAPTOP" COMMAND="getTracks" EXTRA="0" EXTRA2="20" EXTRA3="" EXTRA4="sandstorm" EXTRA5="" />
				 * <CONTROL KEY="LAPTOP" COMMAND="getTracks" EXTRA="0" EXTRA2="20" EXTRA3="" EXTRA4="genre:8" EXTRA5="" />
				 */
				GetTracks control = new GetTracks();
				
				if (!StringUtils.isNullOrEmpty(command.getExtra4Info())) {
					control.setSearch(command.getExtra4Info());
				}
				
				if (!StringUtils.isNullOrEmpty(command.getExtra2Info())) {
					try {
						control.setItemsPerResponse(Integer.parseInt(command.getExtra2Info()));
					} catch (NumberFormatException e) {
						logger.log(Level.WARNING,
								"items per response found but is not an integer");
					}
				}
				
				if (!StringUtils.isNullOrEmpty(command.getExtraInfo())) {
					try {
						control.setStart(Integer.parseInt(command.getExtraInfo()) * control.getItemsPerResponse());
					} catch (NumberFormatException e) {
						logger.log(Level.WARNING,
								"start found but is not an integer");
					}
				}
				
				String filter = command.getExtra3Info();
				boolean getCurrentTracks = false;
				
				if (!StringUtils.isNullOrEmpty(filter)) {
					String[] filters = filter.split(";");
					int positionOfColon = -1;
					String tag = "";
					String value = "";
					
					for (int i=0;i<filters.length;i++) {
						positionOfColon = filters[i].indexOf(":");
						
						if (positionOfColon != -1) {
							tag = filters[i].substring(0,positionOfColon);
							value = filters[i].substring(positionOfColon+1);
						} else {
							tag = filters[i];
							value = "";
						}
						
						if (tag.equalsIgnoreCase("year")) {
							try {
								control.setYear(Integer.parseInt(value));
							} catch (NumberFormatException e) {
								logger.log(Level.WARNING,
										"year found but is not an integer");
							}
						} else if (tag.equalsIgnoreCase("genre")) {
							try {
								control.setGenre(Integer.parseInt(value));
							} catch (NumberFormatException e) {
								logger.log(Level.WARNING,
										"genre found but is not an integer");
							}
						} else if (tag.equalsIgnoreCase("album")) {
							try {
								control.setAlbum(Integer.parseInt(value));
							} catch (NumberFormatException e) {
								logger.log(Level.WARNING,
										"album found but is not an integer");
							}
						} else if (tag.equalsIgnoreCase("artist")) {
							try {
								control.setArtist(Integer.parseInt(value));
							} catch (NumberFormatException e) {
								logger.log(Level.WARNING,
										"artist found but is not an integer");
							}
						} else if (tag.equalsIgnoreCase("currentplaylist")) {
							getCurrentTracks = true;
						}
					}
				}
				
				if (getCurrentTracks) {
					PlayerStatus getCurrentTracksControl = new PlayerStatus();
					getCurrentTracksControl.setSubscribe("");
					getCurrentTracksControl.setPlayerId(device.getKey());
					getCurrentTracksControl.setStart("0");
					getCurrentTracksControl.setItemsPerResponse(control.getItemsPerResponse());
					retCode = getCurrentTracksControl.buildCommandString() + "\r\n";
					
				} else {
					retCode = control.buildCommandString() + "\r\n";
				}
			} else if (command.getCommandCode().equalsIgnoreCase("currentplaylist")) {
				/*
				 * EXTRA is the current playlist command - currently only delete
				 * EXTRA2 is index of the song to be removed from the current playlist
				 * 
				 * <CONTROL KEY="LAPTOP" COMMAND="currentplaylist" EXTRA="delete" EXTRA2="1" EXTRA3="" EXTRA4="" EXTRA5="" />
				 * <CONTROL KEY="LAPTOP" COMMAND="currentplaylist" EXTRA="delete" EXTRA2="4" EXTRA3="" EXTRA4="" EXTRA5="" />
				 * <CONTROL KEY="LAPTOP" COMMAND="currentplaylist" EXTRA="delete" EXTRA2="0" EXTRA3="" EXTRA4="" EXTRA5="" />
				 */
				if (command.getExtraInfo().equalsIgnoreCase("delete")) {
					PlayListDelete control = new PlayListDelete();
					control.setPlayerId(device.getKey());
					
					try {
						control.setSongIndex(Integer.parseInt(command.getExtra2Info()));
					} catch (NumberFormatException e) {
						logger.log(Level.WARNING,
								"songIndex found but is not an integer");
					}
					
					if (control.getSongIndex() != -1) {
						retCode = control.buildCommandString() + "\r\n";
					} else {
						retCode = "";
					}
					
				} else {
					retCode = "";
				}
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
