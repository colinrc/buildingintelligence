package au.com.BI.MultiMedia.SlimServer.Commands;

import au.com.BI.Util.StringUtils;

public class Login extends SlimServerCommand {
	String userName;
	String password;

	public void setPassword(String password) {
		this.password = password;
	}

	public void setUser(String user) {
		this.userName = user;
	}

	@Override
	public String buildCommandString() {
		String commandString = "login";
		
		if (!StringUtils.isNullOrEmpty(userName)) {
			commandString += " " + userName + " " + password;
		}
		return commandString;
	}
}
