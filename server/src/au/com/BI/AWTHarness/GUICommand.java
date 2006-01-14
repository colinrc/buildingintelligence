/*
 * Created on Jan 27, 2004
 *
 */
package au.com.BI.AWTHarness;
import au.com.BI.Command.Command;
import au.com.BI.Command.CommandInterface;
import au.com.BI.User.*;

/**
 * @author Colin Canfield
 * 
 * Encapsulates a command to a physical device
 *
 */
public class GUICommand extends Command implements CommandInterface {

	public static final int GUIControlActivate = 3;

	
	public GUICommand ()
	{
	    super();
	}

	public GUICommand (String key,String commandCode,User user)
	{
		super (key,commandCode, user);
	}
	

	public GUICommand (String key,String commandCode, User user,String extraInfo)
	{
		super (key, commandCode,user,extraInfo);
	}
	
	public boolean isClient() {
		return true;
	}
}
