package au.com.BI.MultiMedia.AutonomicHome.Commands;

import java.util.HashMap;
import java.util.LinkedList;

public class BeginAlbumsReply extends AutonomicHomeCommand {
	private int count;
	private LinkedList<Album> albums;

	public BeginAlbumsReply() {
		super();
		albums = new LinkedList<Album>();
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public LinkedList getAlbums() {
		return albums;
	}
	
	public void setAlbums(LinkedList albums) {
		this.albums = albums;
	}

	@Override
	public String buildCommandString() {
		return super.buildCommandString();
	}
}
