package au.com.BI.MultiMedia.AutonomicHome.Commands;

public class SetInstance extends AutonomicHomeCommand {
	private String instance;
	
	public String getInstance() {
		return instance;
	}

	public void setInstance(String instance) {
		this.instance = instance;
	}

	@Override
	public String buildCommandString() {
		return "SetInstance " + instance;
	}
}
