/*
 * Created on Jan 27, 2004
 *
 */
package au.com.BI.CustomConnect;
import au.com.BI.Command.Command;
import au.com.BI.Command.CommandInterface;
import au.com.BI.User.*;


/**
 * @author Colin Canfield
 * 
 * Encapsulates a command to a physical device
 *
 */
public class CustomConnectCommand extends Command implements CommandInterface{
	
	public static int RawText = 1;
	
	public String port;
	
	
	public CustomConnectCommand ()
	{
	    super();
	}

	public CustomConnectCommand (String key,String commandCode, User user)
	{
		super (key,commandCode,user);

	}
	

	public CustomConnectCommand (String key,String commandCode, User user, String extraInfo)
	{
		super (key, commandCode,user,extraInfo);
	}


	
}
