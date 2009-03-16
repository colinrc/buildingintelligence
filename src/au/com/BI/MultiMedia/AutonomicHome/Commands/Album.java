package au.com.BI.MultiMedia.AutonomicHome.Commands;

public class Album extends AutonomicHomeCommand {
	private String guid;
	private String name;
	
	public Album(String guid, String name) {
		super();
		this.guid = guid;
		this.name = name;
	}

	public String getGuid() {
		return guid;
	}

	public void setGuid(String guid) {
		this.guid = guid;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
	
}
