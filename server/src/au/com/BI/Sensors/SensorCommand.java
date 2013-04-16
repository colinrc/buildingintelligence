/*
 * Created on Jan 27, 2004
 *
 */
package au.com.BI.Sensors;
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
public class SensorCommand extends Command implements CommandInterface{

	
	public static int RawText = 1;
	
	public String port;
	
	
	public SensorCommand ()
	{
	    super();
	}

	public SensorCommand (String key,String commandCode, User user)
	{
		super (key,commandCode,user);

	}
	

	public SensorCommand (String key,String commandCode, User user, String extraInfo)
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
