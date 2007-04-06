package au.com.BI.MultiMedia.SlimServer.Commands;

import java.util.Iterator;
import java.util.LinkedList;

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
			commandString += " search:" + search;
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
		
		Iterator<AlbumTag> albumTagsIter = tags.iterator();
		while(albumTagsIter.hasNext()) {
			commandString += " tags:" + albumTagsIter.next().getValue();
		}
		
		return commandString;
	}
}
