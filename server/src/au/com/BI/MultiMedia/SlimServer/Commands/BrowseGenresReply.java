package au.com.BI.MultiMedia.SlimServer.Commands;

import java.util.LinkedList;

public class BrowseGenresReply extends SlimServerCommand {
	private int count;
	private boolean rescan;
	private LinkedList<Genre> genres;
	
	public BrowseGenresReply() {
		count = -1;
		rescan = false;
		genres = new LinkedList<Genre>();
	}
	
	public int getCount() {
		return count;
	}
	public void setCount(int count) {
		this.count = count;
	}
	public LinkedList<Genre> getGenres() {
		return genres;
	}
	public void setGenres(LinkedList<Genre> genres) {
		this.genres = genres;
	}
	public boolean isRescan() {
		return rescan;
	}
	public void setRescan(boolean rescan) {
		this.rescan = rescan;
	}
}
