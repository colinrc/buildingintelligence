/*
 * Created on Jan 27, 2004
 *
 */
package au.com.BI.CustomInput;
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
public class CustomInputCommand extends Command implements CommandInterface{

	private Map keyList;
	
	public static int RawText = 1;
	
	public String port;
	
	
	public CustomInputCommand ()
	{
	    super();
	}

	public CustomInputCommand (String key,String commandCode, User user)
	{
		super (key,commandCode,user);

	}
	

	public CustomInputCommand (String key,String commandCode, User user, String extraInfo)
	{
		super (key, commandCode,user,extraInfo);
	}



	/** 
	 * Returns the XML representation of this command 
	 */
	public Element getXMLCommand () {
		Element elm = super.getXMLCommand();
		elm.setAttribute ("KEY", displayName);
		elm.setAttribute ("COMMAND", commandCode);
		return elm;
	}
	
}
