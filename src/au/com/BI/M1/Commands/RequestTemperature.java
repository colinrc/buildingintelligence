package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

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
	
	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("st"+Utility.padString(this.group.getValue(),1)+Utility.padString(this.device,2)+"00");
		return returnString;
	}
}
