package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class ControlOutputOn extends M1Command {
	private String seconds = "0";
	private String outputNumber;
	
	public ControlOutputOn() {
		super();
		this.setCommand("cn");
	}

	public String getSeconds() {
		return seconds;
	}

	public void setSeconds(String seconds) {
		this.seconds = seconds;
	}
	
	public void setSeconds(int seconds) {
		this.seconds = Integer.toString(seconds);
	}
	
	public int getTime() {
		return(Integer.getInteger(seconds).intValue());
	}
	
	public String getOutputNumber() {
		return outputNumber;
	}

	public void setOutputNumber(String outputNumber) {
		this.outputNumber = outputNumber;
	}

	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("cn"+Utility.padString(this.getOutputNumber(),3)+Utility.padString(this.seconds,5)+"00");
		return returnString;
	}
}
