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
	
	public CacheWrapper () {
        logger = Logger.getLogger(this.getClass().getPackage().getName());
		isSet = false;
		Date now = new Date();
		creationTime = now.getTime();

	}
	
	public CacheWrapper (String key, CommandInterface command) {
        logger = Logger.getLogger(this.getClass().getPackage().getName());
		isSet = false;

		if (key == null){
			logger.log(Level.WARNING,"A cache wrapper has been created with a null key");
		} else {
			this.setCommand(key,command);
		}
	}
	
	
	
	public CacheWrapper (boolean isSet) {
        logger = Logger.getLogger(this.getClass().getPackage().getName());		
		this.isSet = isSet;
		Date now = new Date();
		creationTime = now.getTime();
		if (isSet) {
			this.makeNewMap();
		}

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
	
	protected void makeNewMap () {

		map = new HashMap<String, CommandInterface>();
		this.creationTime = new Date().getTime();
		this.isSet = true;
	}
	
	public Collection<CommandInterface> getMapValues() {
		return this.map.values();
	}
	
	public void addToMap (String newKey, CommandInterface newCommand){
		if (newKey == null || newCommand == null) {
			return;
		}
		if (key == null){
			this.key = newKey;
		}
		if (newCommand.getDisplayName() == null ||newCommand.getDisplayName().equals ("")) {
			logger.log(Level.WARNING,"A command was attempted to be sent to the cache with a null or empty display name. Calling method: " + 
					new Throwable().fillInStackTrace().getStackTrace()[1].getMethodName());
			newCommand.setDisplayName(newKey);
		}
		if (map == null) {
			makeNewMap();
			if (command != null) {
				map.put(newCommand.getCommandCode(),command);
			}
		}
		String newCode =newCommand.getCommandCode(); 
		map.put(newCode, newCommand);
        if (newCode.equals("on")) {
            map.remove("off");
		}
		if (newCode.equals("off")) {
            map.remove("on");
		}
		if (newCommand.getTargetDeviceModel() != this.getTargetID()) this.setTargetID(newCommand.getTargetDeviceModel());
		this.creationTime = new Date().getTime();

	}
	
	public void setCommand (String key, CommandInterface command) {
		this.creationTime = new Date().getTime();
		this.key = key;
		if (command.getDisplayName().equals ("")) command.setDisplayName(key);
		this.command = command;
	}
	
	protected void setMap (String key, Map <String,CommandInterface>map) {
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
