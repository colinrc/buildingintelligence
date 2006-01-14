/*

 * Created on Jan 27, 2004

 *

 */

package au.com.BI.Dynalite;

import au.com.BI.Command.Command;

import au.com.BI.Command.CommandInterface;

import au.com.BI.User.*;

import org.jdom.*;


/**

 * @author Colin Canfield

 *

 * Encapsulates a command to a physical device

 *

 */

public class DynaliteCommand extends Command implements CommandInterface{


	public static int RawText = 1;
	public String port;
	
	public static final int REQUEST_LEVEL = 1;

	public DynaliteCommand ()
	{
	    super();
	}


	public DynaliteCommand (String key,String commandCode, User user,String extraInfo)
	{
		super (key, commandCode,user,extraInfo);
	}
	
	public DynaliteCommand (String key,String commandCode, User user,String extraInfo, String extra2, String extra3, String extra4, String extra5)
	{
		super (key, commandCode,user,extraInfo);
		super.setExtra2Info(extra2);
		super.setExtra3Info(extra3);
		super.setExtra4Info(extra4);
		super.setExtra5Info(extra5);
	}



}

