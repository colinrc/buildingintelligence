package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class PLCDeviceControl extends M1Command {
	private String houseCode;
	private String unitCode;
	private PLCFunction functionCode;
	private String extendedCode;
	private String time;
	
	public PLCDeviceControl() {
		super();
		this.setCommand("pc");
	}

	public String getExtendedCode() {
		return extendedCode;
	}

	public void setExtendedCode(String extendedCode) {
		this.extendedCode = extendedCode;
	}

	public PLCFunction getFunctionCode() {
		return functionCode;
	}

	public void setFunctionCode(PLCFunction functionCode) {
		this.functionCode = functionCode;
	}

	public String getHouseCode() {
		return houseCode;
	}

	public void setHouseCode(String houseCode) {
		this.houseCode = houseCode;
	}

	public String getTime() {
		return time;
	}

	public void setTime(String time) {
		this.time = time;
	}

	public String getUnitCode() {
		return unitCode;
	}

	public void setUnitCode(String unitCode) {
		this.unitCode = unitCode;
	}
	
	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("pc"
				+ Utility.padString(this.getHouseCode(), 1)
				+ Utility.padString(this.getUnitCode(), 2)
				+ Utility.padString(this.getFunctionCode().getValue(),2)
				+ Utility.padString(this.getExtendedCode(),2)
				+ Utility.padString(this.getTime(),4)
				+ "00");
		return returnString;
	}

}