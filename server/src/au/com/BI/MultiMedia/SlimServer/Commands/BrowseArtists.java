package au.com.BI.MultiMedia.SlimServer.Commands;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.logging.Level;

import au.com.BI.Util.StringUtils;

public class BrowseArtists extends SlimServerCommand {
	int start;
	int itemsPerResponse;
	String search;
	int genre;
	int album;
	
	public BrowseArtists() {
		start = -1;
		itemsPerResponse = -1;
		search = "";
		genre = -1;
		album = -1;
	}

	public int getAlbum() {
		return album;
	}

	public void setAlbum(int album) {
		this.album = album;
	}

	public int getGenre() {
		return genre;
	}

	public void setGenre(int genre) {
		this.genre = genre;
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

	@Override
	public String buildCommandString() {
		String commandString = "artists " + start + " " + itemsPerResponse;
		
		if (!StringUtils.isNullOrEmpty(search)) {
			commandString += " search:";
			try {
				commandString += URLEncoder.encode(search, "UTF-8");
			} catch (UnsupportedEncodingException e) {
				logger.log(Level.INFO, "UTF-8 not supported");
			}
		}
		
		if (genre != -1) {
			commandString += " genre_id:" + genre;
		}
		
		if (album != -1) {
			commandString += " album_id:" + album;
		}
		
		return commandString;
	}
}
