/*
 * Created on Mar 18, 2004
 *
 * To change the template for this generated file go to
 * Window - Preferences - Java - Code Generation - Code and Comments
 */
package au.com.BI.simulator.conf;

/**
 * @author colinc
 *
 * To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Generation - Code and Comments
 */
public class ConfigError extends Exception {
	/**
	 * 
	 */
	public ConfigError() {
		super();
	}
	
	/**
	 * @param arg0
	 */
	public ConfigError(String arg0) {
		super(arg0);
	}
	
	/**
	 * @param arg0
	 * @param arg1
	 */
	public ConfigError(String arg0, Throwable arg1) {
		super(arg0, arg1);
	}
	
	/**
	 * @param arg0
	 */
	
	public ConfigError(Throwable arg0) {
		super(arg0);
	}
}
