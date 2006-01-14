package au.com.BI.Command;

import java.util.*;

public class CacheWrapper {
	boolean isSet = false;
	CommandInterface command = null;
	Map map = null;
	String key;
	long creationTime = 0;
	
	public CacheWrapper (String key, CommandInterface command) {
		isSet = false;
		this.command = command;
		this.key = key;
		Date now = new Date();
		creationTime = now.getTime();
	}
	
	public CacheWrapper (String key, Map map) {
		isSet = true;
		this.key = key;
		this.map = map;
		Date now = new Date();
		creationTime = now.getTime();
	}
	
	
	public CacheWrapper (boolean isSet) {
		this.isSet = isSet;
		Date now = new Date();
		creationTime = now.getTime();
		if (isSet) {
			map = new HashMap();
		}
	}
	
	public boolean isSet() {
		return isSet;
	}

	public void setSet(boolean isSet) {
		this.isSet = isSet;
	}
	
	public CommandInterface getCommand() {
		if (!isSet) {
			return command;
		} else { 
			return null;
		}
	}
	
	public Map getMap () {
		if (isSet) {
			return map;
		} else { 
			return null;
		}		
	}
	
	private void makeNewMap () {
		map = new HashMap();
		this.creationTime = new Date().getTime();
		this.isSet = true;
	}
	
	public Collection getMapValues() {
		return this.map.values();
	}
	
	public void addToMap (String newKey, CommandInterface newCommand){
		if (!isSet) {
			makeNewMap();
			map.put(key,command);
		}
		String newCode =newCommand.getCommandCode(); 
		map.put(newCode, newCommand);
        if (newCode.equals("on")) {
            map.remove("off");
		}
		if (newCode.equals("off")) {
            map.remove("on");
		}
	
		this.creationTime = new Date().getTime();

	}
	
	public void setCommand (String key, CommandInterface command) {
		this.creationTime = new Date().getTime();
		this.key = key;
		this.command = command;
	}
	
	public void setMap (String key, Map map) {
		this.key = key;
		this.creationTime = new Date().getTime();
		this.map = map;
	}
	
	public Long getCreationDate() {
		return new Long (this.creationTime);
	}

}
