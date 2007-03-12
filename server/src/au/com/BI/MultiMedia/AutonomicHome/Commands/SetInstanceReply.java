package au.com.BI.MultiMedia.AutonomicHome.Commands;

public class SetInstanceReply extends AutonomicHomeCommand {
	private String instance;

	public String getInstance() {
		return instance;
	}

	public void setInstance(String instance) {
		this.instance = instance;
	}
}
