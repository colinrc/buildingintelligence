package au.com.BI.M1.Commands;

public class RequestTemperature extends M1Command {

	private Group group;
	private String device;
	
	public RequestTemperature() {
		super();
		this.setCommand("st");
	}

	public RequestTemperature(String sum, String use) {
		super(sum, use);
		this.setCommand("st");
	}

	public Group getGroup() {
		return group;
	}

	public void setGroup(Group group) {
		this.group = group;
	}

	public String getDevice() {
		return device;
	}

	public void setDevice(String device) {
		this.device = device;
	}
	
}
