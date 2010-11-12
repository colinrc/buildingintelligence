/*
 * Created on Jan 27, 2004
 *
 */
package au.com.BI.Pump;
import au.com.BI.Command.*;
import au.com.BI.User.*;

/**
 * @author Colin Canfield
 * 
 * Encapsulates a command to a physical device
 *
 */
public class PumpCommand extends Command implements CommandInterface {
	
	public static int RawText = 1;

	
	
	public PumpCommand ()
	{
	    super();
	}

	public PumpCommand (String key,String commandCode, User user)
	{
		super (key,commandCode,user);

	}
	

	public PumpCommand (String key,String commandCode, User user, String extraInfo)
	{
		super (key, commandCode,user,extraInfo);
	}


	
	public boolean cacheAllCommands () {
		return true;
	}

	
}
