package au.com.BI.MultiMedia;

import org.jdom.Element;

public class Genre {
	private String id;
	private String genre;
	
	public Genre() {
		id = "";
		genre = "";
	}
	
	public String getGenre() {
		return genre;
	}
	
	public void setGenre(String genre) {
		this.genre = genre;
	}
	
	public String getId() {
		return id;
	}
	
	public void setId(String id) {
		this.id = id;
	}
	
	public Element getElement() {
		Element artist = new Element("item");
		artist.setAttribute("id", this.getId());
		artist.setAttribute("genre", this.getGenre());
		return(artist);
	}
}
