package au.com.BI.Admin;
import au.com.BI.Command.*;
import au.com.BI.User.*;


public class AdminCommand extends Command {
	
	public AdminCommand (String command, String extra, User user){
		super (command,extra,user);
	}
	
	public boolean isAdminCommand () {
		return true;
	}
}
