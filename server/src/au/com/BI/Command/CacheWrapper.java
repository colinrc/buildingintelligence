package au.com.BI.Command;

import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CacheWrapper {
	boolean isSet = false;
	CommandInterface command = null;
	Map<String, CommandInterface> map = null;
	String key;
	long creationTime = 0;
	boolean sendWithStartup = true;
	protected Logger logger = null;
	protected long targetID = 0;
	
	public CacheWrapper (String key, CommandInterface command) {
		isSet = false;
		this.command = command;
		this.key = key;
		Date now = new Date();
		creationTime = now.getTime();
        logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
	public CacheWrapper (String key, Map<String,CommandInterface> map) {
		isSet = true;
		this.key = key;
		this.map = map;
		Date now = new Date();
		creationTime = now.getTime();
        logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
	
	public CacheWrapper (boolean isSet) {
		this.isSet = isSet;
		Date now = new Date();
		creationTime = now.getTime();
		if (isSet) {
			map = new HashMap<String, CommandInterface>();
		}
        logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	

    public CacheWrapper clone () {
    		try {
    			return (CacheWrapper)super.clone();
    		} catch (CloneNotSupportedException ex){
    			logger.log (Level.SEVERE,"Command object cannot be copied, web clients will not function.");
    			return null;
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
		map = new HashMap<String, CommandInterface>();
		this.creationTime = new Date().getTime();
		this.isSet = true;
	}
	
	public Collection<CommandInterface> getMapValues() {
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
	
	public void setMap (String key, Map <String,CommandInterface>map) {
		this.key = key;
		this.creationTime = new Date().getTime();
		this.map = map;
	}
	
	public Long getCreationDate() {
		return new Long (this.creationTime);
	}

	public String getKey() {
		return key;
	}

	public void setKey(String key) {
		this.key = key;
	}

	public boolean isSendWithStartup() {
		return sendWithStartup;
	}

	public void setSendWithStartup(boolean sendWithStartup) {
		this.sendWithStartup = sendWithStartup;
	}

	public long getTargetID() {
		return targetID;
	}

	public void setTargetID(long targetID) {
		this.targetID = targetID;
	}

}
