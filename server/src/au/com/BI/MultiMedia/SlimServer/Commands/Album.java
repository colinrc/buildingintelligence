package au.com.BI.MultiMedia.SlimServer.Commands;

public class Album {
	String id;
	String album;
	String artworkTrackId;
	boolean compilation;
	int disc;
	int disccount;
	
	public Album() {
		id = "";
		album = "";
		artworkTrackId = "";
		compilation = false;
		disc = -1;
		disccount = -1;
	}

	public String getAlbum() {
		return album;
	}

	public void setAlbum(String album) {
		this.album = album;
	}

	public String getArtworkTrackId() {
		return artworkTrackId;
	}

	public void setArtworkTrackId(String artworkTrackId) {
		this.artworkTrackId = artworkTrackId;
	}

	public boolean isCompilation() {
		return compilation;
	}

	public void setCompilation(boolean compilation) {
		this.compilation = compilation;
	}

	public int getDisc() {
		return disc;
	}

	public void setDisc(int disc) {
		this.disc = disc;
	}

	public int getDisccount() {
		return disccount;
	}

	public void setDisccount(int disccount) {
		this.disccount = disccount;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}
}
