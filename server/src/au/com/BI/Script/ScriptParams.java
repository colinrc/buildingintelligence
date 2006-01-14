package au.com.BI.Script;
import au.com.BI.User.*;

public class ScriptParams {
	String parameter;
	User user;
	
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
}
