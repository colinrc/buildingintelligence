package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class TasksChangeUpdate extends M1Command {
	private String task;
	
	public TasksChangeUpdate() {
		super();
		this.setCommand("TC");
	}
	
	public TasksChangeUpdate(String task) {
		super();
		this.setCommand("TC");
		this.task = task;
	}

	public String getTask() {
		return task;
	}

	public void setTask(String task) {
		this.task = task;
	}

	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("TC"+Utility.padString(this.getTask(),3)+"000");
		return returnString;
	}
}
