package au.com.BI.MultiMedia.SlimServer.Commands;

import au.com.BI.Util.StringUtils;

public class Login extends SlimServerCommand {
	String user;
	String password;

	public void setPassword(String password) {
		this.password = password;
	}

	public void setUser(String user) {
		this.user = user;
	}

	@Override
	public String buildCommandString() {
		String commandString = "login";
		
		if (!StringUtils.isNullOrEmpty(user)) {
			commandString += " " + user + " " + password;
		}
		return commandString;
	}
}
