package au.com.BI.MultiMedia.SlimServer.Commands;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.LinkedList;
import java.util.logging.Level;

import au.com.BI.Util.StringUtils;

public class GetTracks extends SlimServerCommand {
	private int start;
	private int itemsPerResponse;
	private String search;
	private int genre;
	private int album;
	private int artist;
	private int year;
	private LinkedList<SongInfoTag> tags;
	private String charset;
	private boolean sortByTitle;
	
	public GetTracks() {
		start = 0;
		itemsPerResponse = 20;
		search = "";
		genre = -1;
		album = -1;
		artist = -1;
		year = -1;
		tags = new LinkedList<SongInfoTag>();
		tags.add(SongInfoTag.GENRE);
		tags.add(SongInfoTag.ALBUM);
		tags.add(SongInfoTag.ARTIST);
		tags.add(SongInfoTag.DURATION);
		tags.add(SongInfoTag.ALBUM_ID);
		tags.add(SongInfoTag.TRACK_NUMBER);
		tags.add(SongInfoTag.COVERART);
		charset = "";
		sortByTitle = true;
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

	public int getArtist() {
		return artist;
	}

	public void setArtist(int artist) {
		this.artist = artist;
	}

	public String getCharset() {
		return charset;
	}

	public void setCharset(String charset) {
		this.charset = charset;
	}

	public boolean isSortByTitle() {
		return sortByTitle;
	}

	public void setSortByTitle(boolean sortByTitle) {
		this.sortByTitle = sortByTitle;
	}

	public LinkedList<SongInfoTag> getTags() {
		return tags;
	}

	public void setTags(LinkedList<SongInfoTag> tags) {
		this.tags = tags;
	}

	public int getYear() {
		return year;
	}

	public void setYear(int year) {
		this.year = year;
	}

	@Override
	public String buildCommandString() {
		String commandString = "tracks " + start + " " + itemsPerResponse;
		
		if (!StringUtils.isNullOrEmpty(search)) {
			commandString += " search:";
			try {
				commandString += URLEncoder.encode(search, "UTF-8");
			} catch (UnsupportedEncodingException e) {
				logger.log(Level.INFO, "UTF-8 not supported");
			}
		}
		
		if (year != -1) {
			commandString += " year:" + year;
		}
		
		if (genre != -1) {
			commandString += " genre_id:" + genre;
		}
		
		if (album != -1) {
			commandString += " album_id:" + album;
		}
		
		if (artist != -1) {
			commandString += " artist_id:" + album;
		}
		
		if (tags.size() > 0) {
			commandString += " tags:";
			for (SongInfoTag tag: tags) {
				commandString += tag.getValue();
			}
		}
		
		if (sortByTitle) {
			commandString += " sort:title";
		} else {
			commandString += " sort:tracknum";
		}
		
		return commandString;
	}
}
