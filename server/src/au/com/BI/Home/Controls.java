/*
 * Created on Jan 29, 2005
 * @Author Colin Canfield
 */
package au.com.BI.Home;

import au.com.BI.Command.*;
import java.util.*;

public class Controls {
	private Cache cache;
	private HashMap variables;
	
	public Controls (Cache cache) {
		variables = new HashMap (20);
		this.cache = cache;
	}
	
	public void setCache (Cache cache) {
		this.cache = cache;
	}
	
	public void doCommand (CommandInterface command) {
		if (command.isClient()) {
			if (variables.containsKey(command.getKey())) {
				synchronized (cache) {
					cache.setCachedCommand(command.getKey(),command);
				}
			}
		}
	}
	
	public void clearVariables () {
		variables.clear();
	}
	public void addVariable (String key,CommandInterface command) {
		variables.put(key,command.getDisplayName());
		synchronized (cache) {
			cache.setCachedCommand(command.getKey(),command);
		}
	}
	
}
