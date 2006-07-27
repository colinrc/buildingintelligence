/*
 * Created on Jan 27, 2004
 *
 */
package au.com.BI.SMS;
import au.com.BI.Command.*;
import au.com.BI.User.*;
import java.util.*;
import org.jdom.*;


/**
 * @author Colin Canfield
 * 
 * Encapsulates a command to a physical device
 *
 */
public class SMSCommand extends Command implements CommandInterface {

	
	public SMSCommand ()
	{
	    super();
	}

	public SMSCommand (String key,String commandCode, User user)
	{
		super (key,commandCode,user);

	}
	

	public SMSCommand (String key,String commandCode, User user, String extraInfo)
	{
		super (key, commandCode,user,extraInfo);
	}

	
	public boolean cacheAllCommands () {
		return false;
	}

	
}
