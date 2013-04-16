/*
 * Created on Jan 27, 2004
 *
 */
package au.com.BI.Audio;
import au.com.BI.Command.*;
import au.com.BI.User.*;


/**
 * @author Colin Canfield
 * 
 * Encapsulates a command to a physical device
 *
 */
public class AudioCommand extends Command implements CommandInterface {
	
	public static int RawText = 1;
	
	public String port;
	
	
	public AudioCommand ()
	{
	    super();
	}

	public AudioCommand (String key,String commandCode, User user)
	{
		super (key,commandCode,user);

	}
	

	public AudioCommand (String key,String commandCode, User user, String extraInfo)
	{
		super (key, commandCode,user,extraInfo);
	}
	
	public boolean cacheAllCommands () {
		return true;
	}

	
}
