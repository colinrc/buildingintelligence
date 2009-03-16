package au.com.BI.MultiMedia.SlimServer.Commands;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Util.StringUtils;

public class PlayListControl extends SlimServerCommand {

	private String playerId;
	private PlayListCommand command;
	private int genre_id;
	private int artist_id;
	private int album_id;
	private int track_id;
	private int year_id;
	private int playlist_id;
	private String playlist_name;
	Logger logger;
	
	public PlayListControl() {
		command = PlayListCommand.ADD;
		genre_id = -1;
		artist_id = -1;
		album_id = -1;
		track_id = -1;
		year_id = -1;
		playlist_id = -1;
		playlist_name = "";
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}

	public String getPlayerId() {
		return playerId;
	}
	
	public void setPlayerId(String playerId) {
		this.playerId = playerId;
	}

	public int getAlbum_id() {
		return album_id;
	}

	public void setAlbum_id(int album_id) {
		this.album_id = album_id;
	}

	public int getArtist_id() {
		return artist_id;
	}

	public void setArtist_id(int artist_id) {
		this.artist_id = artist_id;
	}

	public PlayListCommand getCommand() {
		return command;
	}

	public void setCommand(PlayListCommand command) {
		this.command = command;
	}

	public int getGenre_id() {
		return genre_id;
	}

	public void setGenre_id(int genre_id) {
		this.genre_id = genre_id;
	}

	public int getPlaylist_id() {
		return playlist_id;
	}

	public void setPlaylist_id(int playlist_id) {
		this.playlist_id = playlist_id;
	}

	public String getPlaylist_name() {
		return playlist_name;
	}

	public void setPlaylist_name(String playlist_name) {
		this.playlist_name = playlist_name;
	}

	public int getTrack_id() {
		return track_id;
	}

	public void setTrack_id(int track_id) {
		this.track_id = track_id;
	}

	public int getYear_id() {
		return year_id;
	}

	public void setYear_id(int year_id) {
		this.year_id = year_id;
	}

	@Override
	public String buildCommandString() {
		String commandString = "";
		
		try {
			commandString += URLEncoder.encode(playerId, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			logger.log(Level.INFO, "UTF-8 not supported");
		}
		
		commandString += " playlistcontrol";
		
		commandString += " cmd:" + command.getValue();
		
		if (album_id != -1) {
			commandString += " album_id:" + album_id;
		}
		
		if (artist_id != -1) {
			commandString += " artist_id:" + artist_id;
		}
		
		if (genre_id != -1) {
			commandString += " genre_id:" + genre_id;
		}
		
		if (playlist_id != -1) {
			commandString += " playlist_id:" + playlist_id;
		}
		
		if (track_id != -1) {
			commandString += " track_id:" + track_id;
		}
		
		if (year_id != -1) {
			commandString += " year_id:" + year_id;
		}
		
		if (!StringUtils.isNullOrEmpty(playlist_name)) {
			try {
				commandString += " playlist_name:" + URLEncoder.encode(playlist_name, "UTF-8");
			} catch (UnsupportedEncodingException e) {
				logger.log(Level.INFO, "UTF-8 not supported");
			}
		}
		return commandString;
	}
}
