/*
 * Created on Jan 27, 2004
 *
 */
package au.com.BI.Auxiliary;
import au.com.BI.Command.*;
import au.com.BI.User.*;
import org.jdom.*;


/**
 * @author Colin Canfield
 * 
 * Encapsulates a command to a physical device
 *
 */
public class AuxiliaryCommand extends Command implements CommandInterface {
	
	public static int RawText = 1;
	
	public String port;
	
	
	public AuxiliaryCommand ()
	{
	    super();
	}

	public AuxiliaryCommand (String key,String commandCode, User user)
	{
		super (key,commandCode,user);

	}
	

	public AuxiliaryCommand (String key,String commandCode, User user, String extraInfo)
	{
		super (key, commandCode,user,extraInfo);
	}
	
	public boolean cacheAllCommands () {
		return true;
	}

	
}
