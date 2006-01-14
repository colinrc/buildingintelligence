/*

 * Created on Jan 27, 2004

 *

 */

package au.com.BI.CBUS;

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

public class CBUSCommand extends Command implements CommandInterface {

	public static int RawText = 1;
	public String port;
	
	public CBUSCommand ()
	{
	    super();
	}



	public CBUSCommand (String key,String commandCode, User user)

	{
		super (key,commandCode,user);
	}





	public CBUSCommand (String key,String commandCode, User user, String extraInfo)

	{
		super (key, commandCode,user,extraInfo);
	}

	/**

	 * Returns the XML representation of this command

	 */

	public Element getXMLCommand () {

		Element element = super.getXMLCommand();
		element.setAttribute ("KEY", displayName);
		element.setAttribute ("COMMAND", commandCode);
		return element;

	}

}

