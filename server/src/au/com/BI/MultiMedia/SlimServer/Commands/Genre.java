package au.com.BI.MultiMedia.SlimServer.Commands;

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
}
