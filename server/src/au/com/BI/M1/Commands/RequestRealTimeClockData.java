package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;

public class RequestRealTimeClockData extends M1Command {

	public RequestRealTimeClockData() {
		super();
		this.setCommand("rr");
	}

	public RequestRealTimeClockData(String sum, String use) {
		super(sum, use);
		this.setCommand("rr");
	}

	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("rr"+"00");
		return returnString;
	}
}
