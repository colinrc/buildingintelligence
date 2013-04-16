package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;

public class ArmingStatusRequest extends M1Command {

	public ArmingStatusRequest() {
		super();
		this.setCommand("as");

	}

	public ArmingStatusRequest(String sum, String use) {
		super(sum, use);
		this.setCommand("as");

	}
	
	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("as00");
		return returnString;
	}

}
