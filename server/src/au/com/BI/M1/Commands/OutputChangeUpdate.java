package au.com.BI.M1.Commands;

import au.com.BI.Util.Utility;

public class OutputChangeUpdate extends M1Command {

	private String outputState;
	
	public OutputChangeUpdate() {
		super();
		this.setCommand("CC");
		// TODO Auto-generated constructor stub
	}

	public OutputChangeUpdate(String sum, String use) {
		super(sum, use);
		// TODO Auto-generated constructor stub
	}

	public OutputChangeUpdate(String outputNumber, String state, String futureUse) {
		super();
		// TODO Auto-generated constructor stub
		outputState = state;
		setKey(outputNumber);
		setFutureUse(futureUse);
	}

	public String getOutputState() {
		return outputState;
	}

	public void setOutputState(String outputState) {
		this.outputState = outputState;
	}
	
	public String toString() {
		return (super.toString() + ";outputState=" + outputState);
	}

}
