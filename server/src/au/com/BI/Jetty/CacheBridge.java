/*
 * CacheBridge.java
 *
 * Created on March 22, 2006, 9:31 PM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package au.com.BI.Jetty;

import java.util.logging.*;
import java.util.*;
import au.com.BI.Command.*;
import org.jdom.Element;
import org.jdom.IllegalAddException;

/**
 *
 * @author colin
 */
public class CacheBridge implements CacheListener {
        Map <String,CacheWrapper>commandsToSend;
        long ID = 0;
        
    protected Logger logger = null;
    
    /** Creates a new instance of CacheBridge */
    public CacheBridge() {
        commandsToSend = new HashMap<String,CacheWrapper>();
        logger = Logger.getLogger(this.getClass().getPackage().getName());
    }
    
    public void addToCommandQueue(String key , CommandInterface command, long targetID, boolean isSet) {
    	if (targetID > 0 && targetID != this.ID){
    		return ;
    	}
    	logger.log(Level.FINEST,"Adding key from command "  + key);
    	CacheWrapper cacheWrapper ;
    	synchronized (commandsToSend){
	    	try {
		    	if (isSet){
		    		if (commandsToSend.containsKey(key)){
		    			cacheWrapper = commandsToSend.get(key);
		    		} else {
		    			cacheWrapper = new CacheWrapper();
		    			cacheWrapper.setKey(key);
		    			cacheWrapper.setSet(true);
		    	   		cacheWrapper.setTargetID(targetID);
		    	   	 }
		    		cacheWrapper.addToMap(command.getCommandCode(),command.clone());
		    		commandsToSend.put(key,cacheWrapper);   		
		    	} else {
			    	cacheWrapper = new CacheWrapper(key,command.clone());
			    	cacheWrapper.setTargetID(targetID);
			    	commandsToSend.put(key,cacheWrapper);   	
		    	}
	    	} catch (CloneNotSupportedException ex){
				logger.log(Level.WARNING,"There was an error sending the commands to the web client." + ex.getMessage());
	    	}
	    	}
    }
    
    public void addToCommandQueue(String key , CacheWrapper cacheWrapper) {
    	if (cacheWrapper.getTargetID() > 0 && cacheWrapper.getTargetID() != this.ID  ){
    		return ;
    	}
    	if (key == null){
    		logger.log (Level.SEVERE,"A command with no key was added to the startup cache");
    		return;
    	}
    	/*
    	try {
    		commandsToSend.put(key,cacheWrapper.clone());
    	} catch (IllegalAddException ex){
			logger.log(Level.WARNING,"There was an error sending the commands to the web client." + ex.getMessage());
		}*/
    	synchronized (commandsToSend){
    		commandsToSend.put(key,cacheWrapper);
    	}
    	logger.log(Level.FINEST,"Adding key "  + key);
    }
    
    public boolean getCommands (List<Element> extraElementsToInclude, Element resultsDoc){
    	boolean values = false;
    	
    	if (extraElementsToInclude != null){
	    	for (Element elm:extraElementsToInclude){
	    		try {
					elm.detach();
	    			resultsDoc.addContent(elm);
			    } catch (IllegalAddException ex){
						logger.log(Level.WARNING,"There was an error sending the commands to the web client." + ex.getMessage());
				}
	    	}
    	}
    	
    	synchronized (commandsToSend){
	        	for (CacheWrapper cacheWrapper:commandsToSend.values()) {
		        		if (cacheWrapper.isSet()) {
		        			for (CommandInterface command:cacheWrapper.getMapValues()){
		        				try {
		        					resultsDoc.addContent((Element)command.getXMLCommand());
		        					values = true;
		        				} catch (IllegalAddException ex){
		        						logger.log(Level.WARNING,"There was an error sending the commands to the web client." + ex.getMessage());
		        				} catch (NullPointerException ex){
		    						logger.log(Level.WARNING,"There was an error sending the commands to the web client." + ex.getMessage());        					
		        				}
		        			}
		        		} else {
		        			CommandInterface command = cacheWrapper.getCommand();
		        			if (command != null) {
		        				Element xMLCommand = null;
		        				try {
		        						xMLCommand = (Element)command.getXMLCommand();
		        						xMLCommand.detach();
		        						resultsDoc.addContent(xMLCommand);      
		        						values = true;
		        				} catch (IllegalAddException ex){
		        						logger.log(Level.WARNING,"There was an error sending the commands to the web client." + ex.getMessage());
		        				}
		        			}
		        		}
	        }
	        commandsToSend.clear();
    	}
        return values;
    }

	public long getID() {
		return ID;
	}

	public void setID(long id) {
		ID = id;
	}
    
}
