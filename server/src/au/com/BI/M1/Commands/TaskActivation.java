package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class TaskActivation extends M1Command {
	
	private String task;
	
	public TaskActivation() {
		super();
		this.setCommand("tn");
	}
	
	public TaskActivation(String task) {
		super();
		this.task = task;
		this.setCommand("tn");
	}

	public String getTask() {
		return task;
	}

	public void setTask(String task) {
		this.task = task;
	}
	
	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("tn"+Utility.padString(this.getTask(),3)+"00");
		return returnString;
	}
}
