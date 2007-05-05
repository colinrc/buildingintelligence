/*
 * Created on Jan 27, 2004
 *
 */
package au.com.BI.Alert;
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
public class AlertCommand extends Command implements CommandInterface {
	
	public static int RawText = 1;
	
	public String port;
	
	
	public AlertCommand ()
	{
	    super();
	}

	public AlertCommand (String key,String commandCode, User user)
	{
		super (key,commandCode,user);

	}
	

	public AlertCommand (String key,String commandCode, User user, String extraInfo)
	{
		super (key, commandCode,user,extraInfo);
	}



	/** 
	 * Returns the XML representation of this command 
	 */
	public Element getXMLCommand () {
		if (displayName == null || commandCode == null){ 
			return null;
		}
		
		Element element = new Element ("CONTROL");
		element.setAttribute ("KEY", displayName);
		if (commandCode.equals(""))
		    element.setAttribute ("COMMAND", "on");
		else
		    element.setAttribute ("COMMAND", commandCode);
		if (extraInfo != null) {
			element.setAttribute ("EXTRA", extraInfo.toString());
		}
		else {
			element.setAttribute ("EXTRA", "An unknown error occured");
		}
		if (extra2Info != null) {
			element.setAttribute ("EXTRA2", extra2Info.toString());
		}
		else {
			element.setAttribute ("EXTRA2", "An unknown error occured");
		}
		if (extra3Info != null) {
			element.setAttribute ("EXTRA3", extra3Info.toString());
		}
		else {
			element.setAttribute ("EXTRA3", "An unknown error occured");
		}
		if (extra4Info != null) {
			element.setAttribute ("EXTRA4", extra4Info.toString());
		}
		else {
			element.setAttribute ("EXTRA4", "An unknown error occured");
		}
		if (extra5Info != null) {
			element.setAttribute ("EXTRA5", extra5Info.toString());
		}
		else {
			element.setAttribute ("EXTRA5", "An unknown error occured");
		}
			
		return element;
	}
	
}
