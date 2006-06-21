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
        Hashtable <String,CacheWrapper>commandsToSend;
        long ID = 0;
        
    protected Logger logger = null;
    
    /** Creates a new instance of CacheBridge */
    public CacheBridge() {
        commandsToSend = new Hashtable<String,CacheWrapper>();
        logger = Logger.getLogger(this.getClass().getPackage().getName());
    }
    
    public void addToCommandQueue(String key , CacheWrapper cacheWrapper) {
    	if (cacheWrapper.getTargetID() > 0 && cacheWrapper.getTargetID() != this.ID){
    		return ;
    	}
    	
        synchronized (commandsToSend){
            commandsToSend.put(key,cacheWrapper);
        }
    }
    
    public Element getCommands (List<Element> extraElementsToInclude){
    	Element resultsDoc = new Element("a");
    	
    	if (extraElementsToInclude != null){
	    	for (Element elm:extraElementsToInclude){
	    		resultsDoc.addContent(elm);
	    	}
    	}
    	
        synchronized (commandsToSend){
        	for (CacheWrapper cacheWrapper:commandsToSend.values()) {
        		if (cacheWrapper.isSet()) {
        			for (CommandInterface command:cacheWrapper.getMapValues()){
        				resultsDoc.addContent(command.getXMLCommand());
        			}
        		} else {
        			CommandInterface command = cacheWrapper.getCommand();
        			if (command != null) {
        				try {
        						resultsDoc.addContent((Element)command.getXMLCommand().clone());      
        				} catch (IllegalAddException ex){
        						logger.log(Level.WARNING,"There was an error sending the commands to the web client." + ex.getMessage());
        				}
        			}
        		}
        	}
	
        	commandsToSend.clear();
        }
        return resultsDoc;
    }

	public long getID() {
		return ID;
	}

	public void setID(long id) {
		ID = id;
	}
    
}
