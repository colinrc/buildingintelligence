/*
 * Created on Jan 27, 2004
 *
 */
package au.com.BI.Analog;
import au.com.BI.Command.Command;
import au.com.BI.Command.CommandInterface;
import au.com.BI.User.*;


/**
 * @author Colin Canfield
 * 
 * Encapsulates a command to a physical device
 *
 */
public class AnalogCommand extends Command implements CommandInterface {
	
	
	public AnalogCommand ()
	{
	    super();
	}

	public AnalogCommand (String key,String commandCode, User user)
	{
		super (key,commandCode,user);

	}
	

	public AnalogCommand (String key,String commandCode, User user, String extraInfo)
	{
		super (key, commandCode,user,extraInfo);
	}


	
}
