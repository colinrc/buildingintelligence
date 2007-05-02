package au.com.BI.MultiMedia;

import org.jdom.Element;

public class Album {
	String id;
	String album;
	String artworkTrackId;
	boolean compilation;
	int disc;
	int disccount;
	String urlPath;
	int year;
	String title;
	
	public Album() {
		id = "";
		album = "";
		artworkTrackId = "-1";
		compilation = false;
		disc = -1;
		disccount = -1;
		urlPath = "";
		year = -1;
		title = "";
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
	
	public String getUrlPath() {
		return urlPath;
	}

	public void setUrlPath(String urlPath) {
		this.urlPath = urlPath;
	}

	public int getYear() {
		return year;
	}

	public void setYear(int year) {
		this.year = year;
	}
	
	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public Element getElement() {
		Element album = new Element("item");
		album.setAttribute("id", this.getId());
		album.setAttribute("album", this.getAlbum());
		album.setAttribute("title", this.getTitle());
		album.setAttribute("coverArt", this.getUrlPath() + this.getArtworkTrackId() + "/cover.jpg");
		album.setAttribute("thumbCoverArt", this.getUrlPath() + this.getArtworkTrackId() + "/thumb.jpg");
		album.setAttribute("disc",Integer.toString(this.getDisc()));
		album.setAttribute("disccount",Integer.toString(this.getDisccount()));
		album.setAttribute("compilation", Boolean.toString(this.isCompilation()));
		album.setAttribute("year", Integer.toString(this.getYear()));
		return(album);
	}
}
