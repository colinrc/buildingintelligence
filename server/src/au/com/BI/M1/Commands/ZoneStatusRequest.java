package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class ZoneStatusRequest extends M1Command {

	public ZoneStatusRequest() {
		super();
		this.setCommand("zs");

	}

	public ZoneStatusRequest(String sum, String use) {
		super(sum, use);
		this.setCommand("zs");

	}
	
	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("zs"
				+ "00");
		return returnString;
	}

}
