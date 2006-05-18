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
        
    protected Logger logger = null;
    
    /** Creates a new instance of CacheBridge */
    public CacheBridge() {
        commandsToSend = new Hashtable<String,CacheWrapper>();
        logger = Logger.getLogger(this.getClass().getPackage().getName());
    }
    
    public void cacheUpdated(String key, CacheWrapper cacheWrapper) {
        synchronized (commandsToSend){
            commandsToSend.put(key,cacheWrapper);
        }
    }
    
    public void getCommands (PrintWriter out,long sinceTime){
        out.println("<P>reading commands");
    }
    
}
