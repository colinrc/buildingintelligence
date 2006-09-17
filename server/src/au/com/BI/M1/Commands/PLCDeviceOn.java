package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.M1.Commands.M1Command;
import au.com.BI.Util.Utility;

public class PLCDeviceOn extends M1Command {
	
	private String houseCode;
	private String unitCode;
	
	public PLCDeviceOn() {
		super();
		this.setCommand("pn");
	}
	
	public String getHouseCode() {
		return houseCode;
	}

	public void setHouseCode(String houseCode) {
		this.houseCode = houseCode;
	}

	public String getUnitCode() {
		return unitCode;
	}

	public void setUnitCode(String unitCode) {
		this.unitCode = unitCode;
	}

	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("pn"
				+ Utility.padString(this.getHouseCode(), 1)
				+ Utility.padString(this.getUnitCode(), 2)
				+ "00");
		return returnString;
	}
}
