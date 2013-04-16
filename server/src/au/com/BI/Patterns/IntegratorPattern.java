/**
 * 
 */
package au.com.BI.Patterns;

import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandInterface;

/**
 * @author colin
 *
 */
public interface IntegratorPattern {
	public void run ( CommandInterface command, Cache cache);

}
