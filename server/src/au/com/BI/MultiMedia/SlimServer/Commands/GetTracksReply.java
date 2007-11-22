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
	
	public GetTracksReply() {
		count = -1;
		rescan = false;
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

	public Element getElement() {

		Element tracksElement = new Element("tracks");

		LinkedList trackElements = new LinkedList();
		
		for (Track track: this.getTracks()) {
			track.setCoverArtUrl(getCoverArtUrl());
			trackElements.add(track.getElement());
		}
		
		tracksElement.addContent(trackElements);
		
		return tracksElement;
	}
	
}
