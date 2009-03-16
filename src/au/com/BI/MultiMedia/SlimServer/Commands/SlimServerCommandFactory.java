package au.com.BI.MultiMedia.SlimServer.Commands;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.MultiMedia.Album;
import au.com.BI.MultiMedia.Artist;
import au.com.BI.MultiMedia.Genre;
import au.com.BI.MultiMedia.Track;
import au.com.BI.Util.StringUtils;

public class SlimServerCommandFactory {

	private static SlimServerCommandFactory _singleton;
	private Logger logger;
	
	private SlimServerCommandFactory() {
		logger = Logger.getLogger(SlimServerCommandFactory.class.getPackage().getName());
	}
	
	public static SlimServerCommandFactory getInstance() {
		if (_singleton == null) {
			_singleton = new SlimServerCommandFactory();
		}
		return (_singleton);
	}
	
	public SlimServerCommand getCommand(String unparsedCommand) {
		SlimServerCommand command = null;
		
		try {
			unparsedCommand = unparsedCommand.trim();
			
			String[] words = unparsedCommand.split(" ");
			
			if (!StringUtils.isNullOrEmpty(words[0])) {
				if (words[0].equals("albums")) {
					command = parseBrowseAlbumsReply(words);
				} else if (words[0].equals("artists")) {
					command = parseBrowseArtistsReply(words);
				} else if (words[0].equals("genres")) {
					command = parseBrowseGenresReply(words);
				} else if (words[0].equals("login")) {
					command = new SlimServerCommand(); // empty command
				} else if (words[1].equals("status")) {
					command = parsePlayerStatusReply(words);
				} else if (words[0].equals("tracks")) {
					command = parseGetTracksReply(words);
				} else if (words[1].equals("power")) {
					command = parsePowerReply(words);
				}
			}
			
			if (command == null) {
				logger.log(Level.INFO, "Command cannot be parsed :" + unparsedCommand);
				return null;
			} else {
				return command;
			}
		} catch (SlimServerCommandException e) {
			logger.log(Level.WARNING, "Command not found : " + e.getMessage());
			return null;
		}
	}
	
	public SlimServerCommand parseBrowseAlbumsReply(String[] words)
		throws SlimServerCommandException {
		BrowseAlbumsReply command = new BrowseAlbumsReply();
		int positionOfColon = 0;
		String tag = "";
		String value = "";

		// first should be the start
		try {
			Integer.parseInt(words[1]);
		} catch (NumberFormatException e) {
			throw new SlimServerCommandException("Expected an integer",e);
		}
		
		int expectedCount = 0;
		// second should be the how many is returned
		try {
			expectedCount = Integer.parseInt(words[2]);
		} catch (NumberFormatException e) {
			throw new SlimServerCommandException("Expected an integer",e);
		}
		
		Album album = null;
		for (int i=3; i< words.length; i++) {
			String word = words[i];
			try {
				word = URLDecoder.decode(word,"UTF-8");
			} catch (UnsupportedEncodingException e) {
				throw new SlimServerCommandException("Cannot use UTF-8 encoding", e);
			}
			
			positionOfColon = word.indexOf(":");
			tag = word.substring(0,positionOfColon);
			value = word.substring(positionOfColon+1); 
			
			if (tag.equals("id")) {
				if (album != null) {
					command.getAlbums().add(album);
				}
				album = new Album();
				album.setId(value);
			} else if (tag.equals("album")) {
				if (album == null) {
					throw new SlimServerCommandException("Expected id tag first but got " + tag + " instead");
				}
				album.setAlbum(value);
			} else if (tag.equals("compilation")) {
				// todo: do something with the compilation flag
				if (value.equals("0")) {
					command.setCompilation(false);
				} else if (value.equals("1")) {
					command.setCompilation(true);
				} else {
					throw new SlimServerCommandException("Tried to set compilation flag but could not parse " + value + " to a boolean.");
				}
			} else if (tag.equals("count")) {
				try {
					command.setCount(Integer.parseInt(value));
				} catch (NumberFormatException e) {
					throw new SlimServerCommandException("Tried to set the total count of albums but could not parse " + value + " to an integer.");
				}
			} else if (tag.equals("rescan")) {
				
				if (value.equals("1")) {
					command.setRescan(true);
				} else {
					command.setRescan(false);
				}
			} else if (tag.equals("artwork_track_id")) {
				album.setArtworkTrackId(value);
			} else if (tag.equals("disccount")) {
				try {
					album.setDisccount(Integer.parseInt(value));
				} catch (NumberFormatException e) {
					throw new SlimServerCommandException("Tried to set the disccount of albums but could not parse " + value + " to an integer.");
				}
			} else if (tag.equals("disc")) {
				try {
					album.setDisc(Integer.parseInt(value));
				} catch (NumberFormatException e) {
					throw new SlimServerCommandException("Tried to set the disc of albums but could not parse " + value + " to an integer.");
				}
			} else if (tag.equals("year")) {
				try {
					album.setYear(Integer.parseInt(value));
				} catch (NumberFormatException e) {
					throw new SlimServerCommandException("Tried to set the year of album but could not parse " + value + " to an integer.");
				}
			} else if (tag.equals("title")) {
				album.setTitle(value);
			}
		}
		
		if (album != null) {
			command.getAlbums().add(album);
		}
		
		return command;
	}
	
	public SlimServerCommand parseBrowseArtistsReply(String[] words)
		throws SlimServerCommandException {
		BrowseArtistsReply command = new BrowseArtistsReply();
		int positionOfColon = 0;
		String tag = "";
		String value = "";
	
		// first should be the start
		try {
			Integer.parseInt(words[1]);
		} catch (NumberFormatException e) {
			throw new SlimServerCommandException("Expected an integer",e);
		}
		
		int expectedCount = 0;
		// second should be the how many is returned
		try {
			expectedCount = Integer.parseInt(words[2]);
		} catch (NumberFormatException e) {
			throw new SlimServerCommandException("Expected an integer",e);
		}
		
		Artist artist = null;
		for (int i=3; i< words.length; i++) {
			String word = words[i];
			try {
				word = URLDecoder.decode(word,"UTF-8");
			} catch (UnsupportedEncodingException e) {
				throw new SlimServerCommandException("Cannot use UTF-8 encoding", e);
			}
			
			positionOfColon = word.indexOf(":");
			tag = word.substring(0,positionOfColon);
			value = word.substring(positionOfColon+1);
			
			if (tag.equals("id")) {
				if (artist != null) {
					command.getArtists().add(artist);
				}
				artist = new Artist();
				artist.setId(value);
			} else if (tag.equals("artist")) {
				if (artist == null) {
					throw new SlimServerCommandException("Expected id tag first but got " + tag + " instead");
				}
				artist.setArtist(value);
			} else if (tag.equals("rescan")) {
				
				if (value.equals("1")) {
					command.setRescan(true);
				} else {
					command.setRescan(false);
				}
			}  else if (tag.equals("count")) {
				try {
					command.setCount(Integer.parseInt(value));
				} catch (NumberFormatException e) {
					throw new SlimServerCommandException("Tried to set the total count of artists but could not parse " + value + " to an integer.");
				}
			}
		}
		
		if (artist != null) {
			command.getArtists().add(artist);
		}
		
		return command;
	}
	
	public SlimServerCommand parseBrowseGenresReply(String[] words)
		throws SlimServerCommandException {
		BrowseGenresReply command = new BrowseGenresReply();
		int positionOfColon = 0;
		String tag = "";
		String value = "";
	
		// first should be the start
		try {
			Integer.parseInt(words[1]);
		} catch (NumberFormatException e) {
			throw new SlimServerCommandException("Expected an integer",e);
		}
		
		int expectedCount = 0;
		// second should be the how many is returned
		try {
			expectedCount = Integer.parseInt(words[2]);
		} catch (NumberFormatException e) {
			throw new SlimServerCommandException("Expected an integer",e);
		}
		
		Genre genre = null;
		for (int i=3; i< words.length; i++) {
			String word = words[i];
			try {
				word = URLDecoder.decode(word,"UTF-8");
			} catch (UnsupportedEncodingException e) {
				throw new SlimServerCommandException("Cannot use UTF-8 encoding", e);
			}
			
			positionOfColon = word.indexOf(":");
			tag = word.substring(0,positionOfColon);
			value = word.substring(positionOfColon+1);
			
			if (tag.equals("id")) {
				if (genre != null) {
					command.getGenres().add(genre);
				}
				genre = new Genre();
				genre.setId(value);
			} else if (tag.equals("genre")) {
				if (genre == null) {
					throw new SlimServerCommandException("Expected id tag first but got " + tag + " instead");
				}
				genre.setGenre(value);
			} else if (tag.equals("rescan")) {
				
				if (value.equals("1")) {
					command.setRescan(true);
				} else {
					command.setRescan(false);
				}
			}  else if (tag.equals("count")) {
				try {
					command.setCount(Integer.parseInt(value));
				} catch (NumberFormatException e) {
					throw new SlimServerCommandException("Tried to set the total count of artists but could not parse " + value + " to an integer.");
				}
			}
		}
		
		if (genre != null) {
			command.getGenres().add(genre);
		}
		
		return command;
	}
	
	/**
	 * Parse a player status message.
	 * @param words
	 * @return
	 * @throws SlimServerCommandException
	 */
	public SlimServerCommand parsePlayerStatusReply(String[] words)
		throws SlimServerCommandException {
		PlayerStatusReply command = new PlayerStatusReply();
		
		int positionOfColon = 0;
		String tag = "";
		String value = "";
		
		try {
			command.setPlayerId(URLDecoder.decode(words[0], "UTF-8"));
		} catch (UnsupportedEncodingException e) {
			logger.log(Level.INFO, "UTF-8 not supported");
		}
		
		int expectedCount = 0;
		// second should be the how many is returned
		try {
			expectedCount = Integer.parseInt(words[3]);
		} catch (NumberFormatException e) {
			throw new SlimServerCommandException("Expected an integer",e);
		}
		
		// get the start
		command.setStart(words[2]);
		
		Track track = null;
		for (int i=4; i < words.length; i++) {
			String word = words[i];
			try {
				word = URLDecoder.decode(word,"UTF-8");
			} catch (UnsupportedEncodingException e) {
				throw new SlimServerCommandException("Cannot use UTF-8 encoding", e);
			}
			
			positionOfColon = word.indexOf(":");
			tag = word.substring(0,positionOfColon);
			value = word.substring(positionOfColon+1);
			
			if (tag.equals("tag")) {
				// ignore - this tells whomever is subscribed what tags to expect in the tracks
			} else if (tag.equals("rescan")) {
				if (value.equals("1")) {
					command.setRescan(true);
				} else {
					command.setRescan(false);
				}
			} else if (tag.equals("subscribe")) {
				command.setSubscribe(value);
			} else if (tag.equals("player_name")) {
				command.setPlayerName(value);
			} else if (tag.equals("player_connected")) {
				command.setPlayerConnected(value);
			} else if (tag.equals("power")) {
				command.setPower(value);
			} else if (tag.equals("signalstrength")) {
				command.setSignalStrength(value);
			} else if (tag.equals("mode")) {
				command.setMode(value);
			} else if (tag.equals("remote")) {
				command.setRemote(value);
			} else if (tag.equals("current_title")) {
				command.setCurrentTitle(value);
			} else if (tag.equals("time")) {
				command.setTime(value);
			} else if (tag.equals("rate")) {
				command.setRate(value);
			} else if (tag.equals("duration")) {
				if (track == null) {
					command.setDuration(value);
				} else {
					track.setDuration(value);
				}
			} else if (tag.equals("sleep")) {
				command.setSleep(value);
			} else if (tag.equals("will_sleep_in")) {
				command.setWillSleepIn(value);
			} else if (tag.equals("mixer volume")) {
				command.setMixerVolume(value);
			} else if (tag.equals("mixer treble")) {
				command.setMixerTreble(value);
			} else if (tag.equals("mixer bass")) {
				command.setMixerBass(value);
			} else if (tag.equals("mixer pitch")) {
				command.setMixerPitch(value);
			} else if (tag.equals("playlist repeat")) {
				command.setPlaylistRepeat(value);
			} else if (tag.equals("playlist shuffle")) {
				command.setPlaylistShuffle(value);
			} else if (tag.equals("playlist_id")) {
				command.setPlaylistId(value);
			} else if (tag.equals("playlist_name")) {
				command.setPlaylistName(value);
			} else if (tag.equals("playlist_modified")) {
				command.setPlaylistModified(value);
			} else if (tag.equals("playlist_cur_index")) {
				command.setPlaylistCurrentIndex(value);
			} else if (tag.equals("playlist_tracks")) {
				command.setPlaylistTracks(value);
			} else if (tag.equals("playlist index")) {
				if (track != null) {
					command.getTracks().add(track);
				}
				track = new Track();
				track.setPlaylistIndex(value);
			} else if (tag.equals("id")) {
				track.setId(value);
			} else if (tag.equals("genre")) {
				track.setGenre(value);
			} else if (tag.equals("genre_id")) {
				track.setGenreId(value);
			} else if (tag.equals("artist")) {
				track.setArtist(value);
			} else if (tag.equals("artist_id")) {
				track.setArtistId(value);
			} else if (tag.equals("composer")) {
				track.setComposer(value);
			} else if (tag.equals("composer")) {
				track.setComposer(value);
			} else if (tag.equals("band")) {
				track.setBand(value);
			} else if (tag.equals("conductor")) {
				track.setConductor(value);
			} else if (tag.equals("album")) {
				track.setAlbum(value);
			} else if (tag.equals("album_id")) {
				track.setAlbumId(value);
			} else if (tag.equals("disc_number")) {
				track.setDiscNumber(value);
			} else if (tag.equals("disccount")) {
				track.setDiscCount(value);
			} else if (tag.equals("tracknum")) {
				track.setTrackNumber(value);
			} else if (tag.equals("year")) {
				track.setYear(value);
			} else if (tag.equals("bpm")) {
				track.setBpm(value);
			} else if (tag.equals("comment")) {
				track.setComment(value);
			} else if (tag.equals("type")) {
				track.setType(value);
			} else if (tag.equals("tagversion")) {
				track.setTagVersion(value);
			} else if (tag.equals("bitrate")) {
				track.setBitRate(value);
			} else if (tag.equals("filesize")) {
				track.setFileSize(value);
			} else if (tag.equals("drm")) {
				track.setDrm(value);
			} else if (tag.equals("coverart")) {
				track.setCoverArt(value);
			} else if (tag.equals("modificationTime")) {
				track.setModificationTime(value);
			} else if (tag.equals("url")) {
				track.setUrl(value);
			} else if (tag.equals("lyrics")) {
				track.setLyrics(value);
			} else if (tag.equals("remote")) {
				track.setRemote(value);
			} else if (tag.equals("title")) {
				track.setTitle(value);
			}
		}
		
		if (track != null) {
			command.getTracks().add(track);
		}
		
		if (command.getTracks().size() != expectedCount) {
			logger.log(Level.INFO,"Subscribe command expected " + expectedCount + " records but only received " + command.getTracks().size());
		}
		
		return command;
	}
	
	/**
	 * Parse a player status message.
	 * @param words
	 * @return
	 * @throws SlimServerCommandException
	 */
	public SlimServerCommand parseGetTracksReply(String[] words)
		throws SlimServerCommandException {
		GetTracksReply command = new GetTracksReply();
		
		int positionOfColon = 0;
		String tag = "";
		String value = "";
		
//		int expectedCount = 0;
		// second should be the how many is returned
//		try {
//			expectedCount = Integer.parseInt(words[2]);
//		} catch (NumberFormatException e) {
//			throw new SlimServerCommandException("Expected an integer",e);
//		}
		
		Track track = null;
		for (int i=3; i < words.length; i++) {
			String word = words[i];
			try {
				word = URLDecoder.decode(word,"UTF-8");
			} catch (UnsupportedEncodingException e) {
				throw new SlimServerCommandException("Cannot use UTF-8 encoding", e);
			}
			
			positionOfColon = word.indexOf(":");
			tag = word.substring(0,positionOfColon);
			value = word.substring(positionOfColon+1);
			
			if (tag.equals("tag")) {
				// ignore - this tells whomever is subscribed what tags to expect in the tracks
			} else if (tag.equals("rescan")) {
				if (value.equals("1")) {
					command.setRescan(true);
				} else {
					command.setRescan(false);
				}
			} else if (tag.equals("search")) {
				command.setSearch(value);
			} else if (tag.equals("id")) {
				if (track != null) {
					command.getTracks().add(track);
				}
				track = new Track();
				track.setId(value);
			} else if (tag.equals("genre")) {
				track.setGenre(value);
			} else if (tag.equals("genre_id")) {
				if (track != null) {
					track.setGenreId(value);
				}
			} else if (tag.equals("artist")) {
				track.setArtist(value);
			} else if (tag.equals("artist_id")) {
				if (track != null) {
					track.setArtistId(value);
				}
			} else if (tag.equals("composer")) {
				track.setComposer(value);
			} else if (tag.equals("composer")) {
				track.setComposer(value);
			} else if (tag.equals("band")) {
				track.setBand(value);
			} else if (tag.equals("conductor")) {
				track.setConductor(value);
			} else if (tag.equals("album")) {
				track.setAlbum(value);
			} else if (tag.equals("album_id")) {
				if (track != null) {
					track.setAlbumId(value);
				}
			} else if (tag.equals("disc_number")) {
				track.setDiscNumber(value);
			} else if (tag.equals("disccount")) {
				track.setDiscCount(value);
			} else if (tag.equals("tracknum")) {
				track.setTrackNumber(value);
			} else if (tag.equals("year")) {
				if (track != null) {
					track.setYear(value);
				}
			} else if (tag.equals("bpm")) {
				track.setBpm(value);
			} else if (tag.equals("comment")) {
				track.setComment(value);
			} else if (tag.equals("type")) {
				track.setType(value);
			} else if (tag.equals("tagversion")) {
				track.setTagVersion(value);
			} else if (tag.equals("bitrate")) {
				track.setBitRate(value);
			} else if (tag.equals("filesize")) {
				track.setFileSize(value);
			} else if (tag.equals("drm")) {
				track.setDrm(value);
			} else if (tag.equals("coverart")) {
				track.setCoverArt(value);
			} else if (tag.equals("modificationTime")) {
				track.setModificationTime(value);
			} else if (tag.equals("url")) {
				track.setUrl(value);
			} else if (tag.equals("lyrics")) {
				track.setLyrics(value);
			} else if (tag.equals("remote")) {
				track.setRemote(value);
			} else if (tag.equals("title")) {
				track.setTitle(value);
			}
		}
		
		if (track != null) {
			command.getTracks().add(track);
		}
		
//		if (command.getTracks().size() != expectedCount) {
//			logger.log(Level.INFO,"Subscribe command expected " + expectedCount + " records but only received " + command.getTracks().size());
//		}
		
		return command;
	}
	
	/**
	 * Parse a player status message.
	 * @param words
	 * @return
	 * @throws SlimServerCommandException
	 */
	public SlimServerCommand parsePowerReply(String[] words)
		throws SlimServerCommandException {
		PowerReply command = new PowerReply();
		
		try {
			command.setPlayerId(URLDecoder.decode(words[0], "UTF-8"));
		} catch (UnsupportedEncodingException e) {
			logger.log(Level.INFO, "UTF-8 not supported");
		}
		
		if (!StringUtils.isNullOrEmpty(words[2])) {
			if (words[2].equals("0")) {
				command.setPower(false);
			} else if (words[2].equals("1")) {
				command.setPower(true);
			} else {
				throw new SlimServerCommandException("power command did not specify a 0 or 1 value");
			}
		} else {
			throw new SlimServerCommandException("power command did not specify a 0 or 1 value");
		}
		
		return command;
	}
}
