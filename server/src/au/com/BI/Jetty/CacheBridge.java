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
import java.io.*;

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
    
    public void getCommands (PrintWriter out){
        out.println("<HTML>");
        out.println("<BODY>");
        out.println("<P>First test from get");
        synchronized (commandsToSend){
        	for (String key:commandsToSend.keySet()){
        		out.println("<P>"+key);
        	}
        	commandsToSend.clear();
        }
        out.println("</BODY>");
        out.println("</HTML>");
    }

	public long getID() {
		return ID;
	}

	public void setID(long id) {
		ID = id;
	}
    
}
