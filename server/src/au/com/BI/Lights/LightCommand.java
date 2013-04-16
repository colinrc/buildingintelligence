/*
 * Created on Jan 27, 2004
 *
 */
package au.com.BI.Lights;
import au.com.BI.Command.Command;
import au.com.BI.Command.CommandInterface;
import au.com.BI.User.*;
import java.util.*;
import org.jdom.*;


/**
 * @author Colin Canfield
 * 
 * Encapsulates a command to a physical device
 *
 */
public class LightCommand extends Command implements CommandInterface{

	public static int RawText = 1;
	
	public String port;
	
	
	public LightCommand ()
	{
	    super();
	}

	public LightCommand (String key,String commandCode, User user)
	{
		super (key,commandCode,user);

	}
	

	public LightCommand (String key,String commandCode, User user, String extraInfo)
	{
		super (key, commandCode,user,extraInfo);
	}



	/** 
	 * Returns the XML representation of this command 
	 */
	public Element getXMLCommand () {
		Element element = new Element ("CONTROL");
		element.setAttribute ("KEY", displayName);
		element.setAttribute ("COMMAND", commandCode);
		if (extraInfo != null) {
			element.setAttribute ("EXTRA", extraInfo.toString());
		}
		else {
			element.setAttribute ("EXTRA", "");
		}
			
		return element;
	}

}
