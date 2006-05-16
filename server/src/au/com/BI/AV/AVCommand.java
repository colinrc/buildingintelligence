/*
 * Created on Jan 27, 2004
 *
 */
package au.com.BI.AV;
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
public class AVCommand extends Command implements CommandInterface {

	
	public AVCommand ()
	{
	    super();
	}

	public AVCommand (String key,String commandCode, User user)
	{
		super (key,commandCode,user);

	}
	

	public AVCommand (String key,String commandCode, User user, String extraInfo)
	{
		super (key, commandCode,user,extraInfo);
	}

	
}
