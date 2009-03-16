package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;

public class ZonePartitionRequest extends M1Command {

	public ZonePartitionRequest() {
		super();
		this.setCommand("zp");

	}

	public ZonePartitionRequest(String sum, String use) {
		super(sum, use);
		this.setCommand("zp");

	}
	
	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("zp00");
		return returnString;
	}

}
