package au.com.BI.M1.Commands;

public class RequestTemperatureReply extends M1Command {
	private Group group;
	private String temperature;
	private String device;
	
	public RequestTemperatureReply() {
		super();
		this.setCommand("ST");
	}

	public RequestTemperatureReply(String sum, String use) {
		super(sum, use);
		this.setCommand("ST");
	}

	public Group getGroup() {
		return group;
	}

	public void setGroup(Group group) {
		this.group = group;
	}

	public String getTemperature() {
		return temperature;
	}

	public void setTemperature(String temperature) {
		this.temperature = temperature;
	}

	public String getDevice() {
		return device;
	}

	public void setDevice(String device) {
		this.device = device;
	}
	
}
