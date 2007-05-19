/**
 * 
 */
package au.com.BI.Patterns;

import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Util.DeviceModel;

/**
 * @author colin
 *
 */
public interface IntegratorPattern {
	public void run ( CommandInterface command, Cache cache);

}
