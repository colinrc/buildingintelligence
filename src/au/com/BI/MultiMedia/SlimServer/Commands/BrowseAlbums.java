package au.com.BI.MultiMedia.SlimServer.Commands;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.LinkedList;
import java.util.logging.Level;
import java.util.logging.Logger;

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
		StringBuffer commandString = new StringBuffer("albums " + start + " " + itemsPerResponse);
		
		if (!StringUtils.isNullOrEmpty(search)) {
			commandString.append(" search:");
			try {
				commandString.append(URLEncoder.encode(search, "UTF-8"));
			} catch (UnsupportedEncodingException e) {
				logger.log(Level.INFO, "UTF-8 not supported");
			}
		}
		
		if (genre != -1) {
			commandString.append(" genre_id:" + genre);
		}
		
		if (artist != -1) {
			commandString.append(" artist_id:" + artist);
		}
		
		if (track != -1) {
			commandString.append(" track_id:" + track);
		}
		
		if (year != -1) {
			commandString.append(" year:" + year);
		}
		
		if (compilation) {
			commandString.append(" compliation:1");
		} else {
			commandString.append(" compilation:0");
		}
		
		if (sort != SortOrder.NONE) {
			commandString.append(" sort:" + sort.getValue());
		}
		
		if (tags.size() > 0) {
			commandString.append(" tags:");
			for (AlbumTag tag: tags) {
				commandString.append(tag.getValue());
			}
		}
		
		return commandString.toString();
	}
}
