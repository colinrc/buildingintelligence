/*
 * Created on Jan 27, 2004
 *
 */
package au.com.BI.DynamicDevice;
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
public class DynamicDeviceCommand extends Command implements CommandInterface {

	private Map keyList;
	
	public static int RawText = 1;
	
	public String port;
	
	
	public DynamicDeviceCommand ()
	{
	    super();
	}

	public DynamicDeviceCommand (String key,String commandCode, User user)
	{
		super (key,commandCode,user);

	}
	

	public DynamicDeviceCommand (String key,String commandCode, User user, String extraInfo)
	{
		super (key, commandCode,user,extraInfo);
	}
	
	public DynamicDeviceCommand (String key,String commandCode, User user, String extraInfo,String extra2Info)
	{
		super (key, commandCode,user,extraInfo);
		super.setExtra2Info(extra2Info);
	}

}
