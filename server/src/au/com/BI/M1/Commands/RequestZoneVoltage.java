package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class RequestZoneVoltage extends M1Command {
	
	private String zone;
	
	public RequestZoneVoltage() {
		super();
		this.setCommand("zv");
		// TODO Auto-generated constructor stub
	}

	public RequestZoneVoltage(String sum, String use) {
		super(sum, use);
		this.setCommand("zv");
		// TODO Auto-generated constructor stub
	}
	
	public String getZone() {
		return zone;
	}

	public void setZone(String zone) {
		this.zone = zone;
	}

	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("zv" + Utility.padString(zone,3) + "00");
		return returnString;
	}
}
