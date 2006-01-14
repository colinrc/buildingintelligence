/*
 * Created on Nov 8, 2004
 *
 * Author: Colin Canfield
 */
package au.com.BI.Admin;


import au.com.BI.Command.CommandInterface;
import au.com.BI.Util.*;


public class AdminDevice extends BaseDevice implements DeviceType {

    /* (non-Javadoc)
     * @see au.com.BI.Util.DeviceType#getCommand()
     */
    public String getCommand() {
        return null;
    }

    /* (non-Javadoc)
     * @see au.com.BI.Util.DeviceType#getDeviceType()
     */
    public int getDeviceType() {
        return DeviceType.ADMIN;
    }

     /* (non-Javadoc)
     * @see au.com.BI.Util.DeviceType#buildDisplayCommand()
     */
    public CommandInterface buildDisplayCommand() {
        return null;
    }

	public boolean keepStateForStartup () {
		return false;
	}
	
	public int getClientCommand ()
	{
		return DeviceType.NA;
	}


}
