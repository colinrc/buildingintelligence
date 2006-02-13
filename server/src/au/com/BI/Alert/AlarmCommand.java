/*
 * Created on Jan 27, 2004
 *
 */
package au.com.BI.Alert;
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
public class AlarmCommand extends Command implements CommandInterface {

	private Map keyList;
	
	public static int RawText = 1;
	
	public String port;
	
	
	public AlarmCommand ()
	{
	    super();
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
		element.setAttribute ("COMMAND", "on");
			
		return element;
	}
	
}
