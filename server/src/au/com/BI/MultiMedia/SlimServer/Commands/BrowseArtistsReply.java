package au.com.BI.MultiMedia.SlimServer.Commands;

import java.util.LinkedList;

public class BrowseArtistsReply extends SlimServerCommand {
	private int count;
	private boolean rescan;
	private LinkedList<Artist> artists;
	
	public BrowseArtistsReply() {
		count = -1;
		rescan = false;
		artists = new LinkedList<Artist>();
	}
	
	public LinkedList<Artist> getArtists() {
		return artists;
	}
	public void setArtists(LinkedList<Artist> artists) {
		this.artists = artists;
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
	
	
}
