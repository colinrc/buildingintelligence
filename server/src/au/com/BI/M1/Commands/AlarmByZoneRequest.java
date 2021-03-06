package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;

public class AlarmByZoneRequest extends M1Command {
	public AlarmByZoneRequest() {
		super();
		this.setCommand("az");

	}

	public AlarmByZoneRequest(String sum, String use) {
		super(sum, use);
		this.setCommand("az");
	}
	
	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("az00");
		return returnString;
	}

}
