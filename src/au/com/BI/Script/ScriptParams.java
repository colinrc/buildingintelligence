package au.com.BI.Script;
import au.com.BI.Command.CommandInterface;
import au.com.BI.User.*;

public class ScriptParams {
	String parameter;
	User user;
	CommandInterface triggeringCommand;

	
	public ScriptParams (String parameter,User user){
		this.parameter = parameter;
		this.user = user;
	}
	
	public String getParameter() {
		return parameter;
	}
	public void setParameter(String parameter) {
		this.parameter = parameter;
	}
	public User getUser() {
		return user;
	}
	public void setUser(User user) {
		this.user = user;
	}

	public CommandInterface getTriggeringCommand() {
		return triggeringCommand;
	}

	public void setTriggeringCommand(CommandInterface triggeringCommand) {
		this.triggeringCommand = triggeringCommand;
	}
}
