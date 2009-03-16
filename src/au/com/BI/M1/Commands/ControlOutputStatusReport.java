package au.com.BI.M1.Commands;

public class ControlOutputStatusReport extends M1Command {
	
	private boolean[] outputStatus;
	
	public ControlOutputStatusReport() {
		super();
		this.setCommand("CS");
	}

	public boolean[] getOutputStatus() {
		return outputStatus;
	}

	public void setOutputStatus(boolean[] outputStatus) {
		this.outputStatus = outputStatus;
	}
	
}
