/*
 * Created on Jan 27, 2004
 *
 */
package au.com.BI.Camera;
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
public class CameraCommand extends Command implements CommandInterface {

	private Map keyList;
	
	public static int RawText = 1;
	
	public String port;
	
	
	public CameraCommand ()
	{
	    super();
	}

	public CameraCommand (String key,String commandCode, User user)
	{
		super (key,commandCode,user);

	}
	

	public CameraCommand (String key,String commandCode, User user, String extraInfo)
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
		element.setAttribute ("COMMAND", commandCode);
		if (extraInfo != null) {
			element.setAttribute ("EXTRA", extraInfo.toString());
		}
		else {
			element.setAttribute ("EXTRA", "");
		}
			
		return element;
	}
	
	public boolean cacheAllCommands () {
		return true;
	}

	
}
