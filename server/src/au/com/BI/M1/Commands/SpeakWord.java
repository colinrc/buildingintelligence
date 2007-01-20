package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class SpeakWord extends M1Command {
	private String word;
	
	public SpeakWord() {
		super();
		this.setCommand("sw");
		// TODO Auto-generated constructor stub
	}

	public SpeakWord(String sum, String use) {
		super(sum, use);
		this.setCommand("sw");
		// TODO Auto-generated constructor stub
	}
	
	public String getWord() {
		return word;
	}

	public void setWord(String word) {
		this.word = word;
	}

	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("sw" + Utility.padString(word,3) + "00");
		return returnString;
	}
}
