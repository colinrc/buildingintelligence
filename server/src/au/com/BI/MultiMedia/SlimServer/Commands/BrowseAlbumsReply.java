package au.com.BI.MultiMedia.SlimServer.Commands;

import java.util.LinkedList;

public class BrowseAlbumsReply extends SlimServerCommand {
	int count;
	boolean rescan;
	LinkedList<Album> albums;
	boolean compilation;
	
	public BrowseAlbumsReply() {
		count = -1;
		rescan = false;
		albums = new LinkedList<Album>();
	}

	public LinkedList<Album> getAlbums() {
		return albums;
	}

	public void setAlbums(LinkedList<Album> albums) {
		this.albums = albums;
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

	public boolean isCompilation() {
		return compilation;
	}

	public void setCompilation(boolean compilation) {
		this.compilation = compilation;
	}
	
}
