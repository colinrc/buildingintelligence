package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

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
	
	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("ST"+Utility.padString(this.getGroup().getValue(),1)+Utility.padString(this.getDevice(),2)+Utility.padString(this.getTemperature(),3)+"00");
		return returnString;
	}
	
}
