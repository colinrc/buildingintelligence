package au.com.BI.MultiMedia.SlimServer.Commands;

import java.util.LinkedList;

import org.jdom.Element;

import au.com.BI.MultiMedia.Artist;
import au.com.BI.MultiMedia.Track;
import au.com.BI.Util.StringUtils;

public class GetTracksReply extends SlimServerCommand {
	private int count;
	private boolean rescan;
	private String search;
	private LinkedList<Track> tracks;
	private String coverArtUrl;
	private int genre;
	private int album;
	private int artist;
	private int year;
	private boolean forCurrentPlaylist;
	private boolean forCurrentlyPlaying;
	
	public GetTracksReply() {
		count = -1;
		genre = -1;
		album = -1;
		artist = -1;
		year = -1;
		rescan = false;
		forCurrentPlaylist = false;
		forCurrentlyPlaying = false;
		tracks = new LinkedList<Track>();
	}
	
	public LinkedList<Track> getTracks() {
		return tracks;
	}
	public void setTracks(LinkedList<Track> tracks) {
		this.tracks = tracks;
	}
	public int getCount() {
		return count;
	}
	public void setCount(int count) {
		this.count = count;
	}
	public boolean isRescan() {
		return rescan;
	}
	public void setRescan(boolean rescan) {
		this.rescan = rescan;
	}

	public String getCoverArtUrl() {
		return coverArtUrl;
	}

	public void setCoverArtUrl(String coverArtUrl) {
		this.coverArtUrl = coverArtUrl;
	}
	
	public String getSearch() {
		return search;
	}

	public void setSearch(String search) {
		this.search = search;
	}
	
	public boolean isForCurrentPlaylist() {
		return forCurrentPlaylist;
	}

	public void setForCurrentPlaylist(boolean currentPlaylist) {
		forCurrentPlaylist = currentPlaylist;
	}

	public boolean isForCurrentlyPlaying() {
		return forCurrentlyPlaying;
	}

	public void setForCurrentlyPlaying(boolean forCurrentlyPlaying) {
		this.forCurrentlyPlaying = forCurrentlyPlaying;
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

	public int getGenre() {
		return genre;
	}

	public void setGenre(int genre) {
		this.genre = genre;
	}

	public int getYear() {
		return year;
	}

	public void setYear(int year) {
		this.year = year;
	}

	public String getFor() {
		String _for = "";
		if (!forCurrentPlaylist && !forCurrentlyPlaying) {
			if (!StringUtils.isNullOrEmpty(search)) {
				_for += "search:" + search + ";";
			} else if (genre != -1) {
				_for += "genre:" + genre + ";";
			} else if (album != -1) {
				_for += "album:" + album + ";";
			} else if (artist != -1) {
				_for += "artist:" + artist + ";";
			} else if (year != -1) {
				_for += "year:" + year + ";";
			}
			year = -1;
		} else if (forCurrentPlaylist) {
			_for = "currentplaylist";
		} else {
			_for = "currentlyplaying";
		}
		
		return _for;
	}

	public Element getElement() {

		Element tracksElement = new Element("tracks");
		tracksElement.setAttribute("for", getFor());

		LinkedList trackElements = new LinkedList();
		
		for (Track track: this.getTracks()) {
			track.setCoverArtUrl(getCoverArtUrl());
			trackElements.add(track.getElement());
		}
		
		tracksElement.addContent(trackElements);
		
		return tracksElement;
	}
	
}
