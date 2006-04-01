package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class ControlOutputOff extends M1Command {

	private String outputNumber;
	
	public ControlOutputOff() {
		super();
		this.setCommand("cf");
	}
	
	public String getOutputNumber() {
		return outputNumber;
	}
	
	public void setOutputNumber(String outputNumber) {
		this.outputNumber = outputNumber;
	}

	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("cf"+Utility.padString(this.getOutputNumber(),3)+"00");
		return returnString;
	}
}
