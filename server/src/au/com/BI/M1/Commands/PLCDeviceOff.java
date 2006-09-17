package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class PLCDeviceOff extends M1Command {
	private String houseCode;
	private String unitCode;
	
	public PLCDeviceOff() {
		super();
		this.setCommand("pf");
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
		returnString = new M1Helper().buildCompleteM1String("pf"
				+ Utility.padString(this.getHouseCode(), 1)
				+ Utility.padString(this.getUnitCode(), 2)
				+ "00");
		return returnString;
	}
}
