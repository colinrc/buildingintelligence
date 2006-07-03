/**
 * 
 */
package au.com.BI.Util;

/**
 * @author colin
 *
 */
public enum MessageDirection {
	;

	// input items are physical devices connected to a controller
	public static final int INPUT = 3;
	// output items are controlled by the device 
	public static final int FROM_FLASH = 2;
	// monitored items have the state monitored and changes are reflected
	// in the client
	public static final int FROM_HARDWARE = 1;

}
