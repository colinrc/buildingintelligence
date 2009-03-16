package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class PLCStatusRequest extends M1Command {
	
	private String bank;
	
	public PLCStatusRequest() {
		super();
		this.setCommand("ps");
	}

	public String getBank() {
		return bank;
	}

	public void setBank(String bank) {
		this.bank = bank;
	}
	
	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("ps"
				+ Utility.padString(this.getBank(), 1)
				+ "00");
		return returnString;
	}

}
