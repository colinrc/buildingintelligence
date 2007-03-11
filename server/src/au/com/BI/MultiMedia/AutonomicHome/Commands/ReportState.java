package au.com.BI.MultiMedia.AutonomicHome.Commands;

public class ReportState extends AutonomicHomeCommand {
	private String instance;
	private StateType type;
	private String value;
	
	public String getInstance() {
		return instance;
	}
	
	public void setInstance(String instance) {
		this.instance = instance;
	}

	public StateType getType() {
		return type;
	}

	public void setType(StateType type) {
		this.type = type;
	}

	public String getValue() {
		return value;
	}

	public void setValue(String value) {
		this.value = value;
	}
	
}
