package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;

public class ControlOutputStatusRequest extends M1Command {
	
	public ControlOutputStatusRequest() {
		super();
		this.setCommand("cs");
	}
	
	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("cs00");
		return returnString;
	}
}
