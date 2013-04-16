package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;


public class OutputChangeUpdate extends M1Command {

	private String outputState;
	
	public OutputChangeUpdate() {
		super();
		this.setCommand("CC");

	}

	public OutputChangeUpdate(String sum, String use) {
		super(sum, use);

	}

	public OutputChangeUpdate(String outputNumber, String state, String futureUse) {
		super();

		outputState = state;
		setKey(outputNumber);
		setFutureUse(futureUse);
	}

	public String getOutputState() {
		return outputState;
	}
	
	public boolean isOn() {
		if (outputState.equals("1")) {
			return(true);
		} else {
			return(false);
		}
	}

	public void setOutputState(String outputState) {
		this.outputState = outputState;
	}
	
	public String toString() {
		return (super.toString() + ";outputState=" + outputState);
	}
	
	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("CC"+Utility.padString(this.getKey(),3)+outputState+"00");
		return returnString;
	}

}
