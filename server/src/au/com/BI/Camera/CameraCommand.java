/*
 * Created on Jan 27, 2004
 *
 */
package au.com.BI.Camera;
import au.com.BI.Command.*;
import au.com.BI.User.*;
import org.jdom.*;


/**
 * @author Colin Canfield
 * 
 * Encapsulates a command to a physical device
 *
 */
public class CameraCommand extends Command implements CommandInterface {
	
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

	
	public boolean cacheAllCommands () {
		return true;
	}
	
	/** 
	 * Returns the XML representation of this command 
	 */
	public Element getXMLCommand () {
		if (displayName == null || commandCode == null){ 
			return null;
		}
		
		Element element = super.getXMLCommand();
		
		element.setAttribute ("KEY", displayName);
			
		return element;
	}
	
}
