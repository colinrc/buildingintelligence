package au.com.BI.MultiMedia.SlimServer.Commands;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.MultiMedia.Album;
import au.com.BI.Util.StringUtils;

public class BrowseAlbums extends SlimServerCommand {
	int start;
	int itemsPerResponse;
	String search;
	int genre;
	int artist;
	int track;
	int year;
	boolean compilation;
	SortOrder sort;
	LinkedList<AlbumTag> tags;
	Logger logger;
	
	public BrowseAlbums() {
		start = -1;
		itemsPerResponse = -1;
		search = "";
		genre = -1;
		artist = -1;
		track = -1;
		year = -1;
		compilation = false;
		sort = SortOrder.NONE;
		tags = new LinkedList<AlbumTag>();
		
		// always get the artwork track id
		tags.add(AlbumTag.ALBUM);
		tags.add(AlbumTag.ARTWORK_TRACK_ID);
		tags.add(AlbumTag.COMPILATION);
		tags.add(AlbumTag.DISC);
		tags.add(AlbumTag.DISCCOUNT);
		tags.add(AlbumTag.TITLE);
		tags.add(AlbumTag.YEAR);
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
	public int getArtist() {
		return artist;
	}
	
	public void setArtist(int artist) {
		this.artist = artist;
	}
	
	public boolean isCompilation() {
		return compilation;
	}
	
	public void setCompilation(boolean compilation) {
		this.compilation = compilation;
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
	
	public SortOrder getSort() {
		return sort;
	}
	
	public void setSort(SortOrder sort) {
		this.sort = sort;
	}
	
	public int getStart() {
		return start;
	}
	
	public void setStart(int start) {
		this.start = start;
	}
	
	public LinkedList<AlbumTag> getTags() {
		return tags;
	}
	
	public void setTags(LinkedList<AlbumTag> tags) {
		this.tags = tags;
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
		String commandString = "albums " + start + " " + itemsPerResponse;
		
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
		
		if (artist != -1) {
			commandString += " artist_id:" + artist;
		}
		
		if (track != -1) {
			commandString += " track_id:" + track;
		}
		
		if (year != -1) {
			commandString += " year:" + year;
		}
		
		if (compilation) {
			commandString += " compliation:1";
		} else {
			commandString += " compilation:0";
		}
		
		if (sort != SortOrder.NONE) {
			commandString += " sort:" + sort.getValue();
		}
		
		if (tags.size() > 0) {
			commandString += " tags:";
			for (AlbumTag tag: tags) {
				commandString += tag.getValue();
			}
		}
		
		return commandString;
	}
}
