package au.com.BI.MultiMedia.SlimServer.Commands;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.logging.Level;

import au.com.BI.Util.StringUtils;

public class BrowseGenres extends SlimServerCommand {
	int start;
	int itemsPerResponse;
	String search;
	int artist;
	int album;
	int track;
	int year;
	
	public BrowseGenres() {
		start = -1;
		itemsPerResponse = -1;
		search = "";
		artist = -1;
		album = -1;
		track = -1;
		year = -1;
	}

	public int getAlbum() {
		return album;
	}

	public void setAlbum(int album) {
		this.album = album;
	}

	public int getArtist() {
		return artist;
	}

	public void setArtist(int artist) {
		this.artist = artist;
	}

	public int getItemsPerResponse() {
		return itemsPerResponse;
	}

	public void setItemsPerResponse(int itemsPerResponse) {
		this.itemsPerResponse = itemsPerResponse;
	}

	public String getSearch() {
		return search;
	}

	public void setSearch(String search) {
		this.search = search;
	}

	public int getStart() {
		return start;
	}

	public void setStart(int start) {
		this.start = start;
	}

	public int getTrack() {
		return track;
	}

	public void setTrack(int track) {
		this.track = track;
	}

	public int getYear() {
		return year;
	}

	public void setYear(int year) {
		this.year = year;
	}

	@Override
	public String buildCommandString() {
		String commandString = "genres " + start + " " + itemsPerResponse;
		
		if (!StringUtils.isNullOrEmpty(search)) {
			commandString += " search:";
			try {
				commandString += URLEncoder.encode(search, "UTF-8");
			} catch (UnsupportedEncodingException e) {
				logger.log(Level.INFO, "UTF-8 not supported");
			}
		}
		
		if (artist != -1) {
			commandString += " artist_id:" + artist;
		}
		
		if (album != -1) {
			commandString += " album_id:" + album;
		}
		
		if (track != -1) {
			commandString += " track_id:" + track;
		}
		
		if (year != -1) {
			commandString += " year:" + year;
		}
		
		return commandString;
	}
}
