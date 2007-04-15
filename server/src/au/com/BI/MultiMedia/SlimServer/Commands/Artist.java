package au.com.BI.MultiMedia.SlimServer.Commands;

public class Artist {
	private String id;
	private String artist;
	
	public Artist() {
		id = "";
		artist = "";
	}
	
	public String getArtist() {
		return artist;
	}
	public void setArtist(String artist) {
		this.artist = artist;
	}
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
}
