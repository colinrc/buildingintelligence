package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class SpeakPhrase extends M1Command {
	private String phrase;
	
	public SpeakPhrase() {
		super();
		this.setCommand("sp");
		// TODO Auto-generated constructor stub
	}

	public SpeakPhrase(String sum, String use) {
		super(sum, use);
		this.setCommand("sp");
		// TODO Auto-generated constructor stub
	}
	
	public String getPhrase() {
		return phrase;
	}

	public void setPhrase(String phrase) {
		this.phrase = phrase;
	}

	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("sp" + Utility.padString(phrase,3) + "00");
		return returnString;
	}
}
