/*
 * CacheBridgeFactory.java
 *
 * Created on March 22, 2006, 9:36 PM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package au.com.BI.Jetty;
import au.com.BI.Command.Cache;
import au.com.BI.Command.CacheWrapper;
import java.util.logging.*;
/**
 *
 * @author colin
 */
public class CacheBridgeFactory {
    private Cache cache = null;
    private Logger logger;
    
    /** Creates a new instance of CacheBridgeFactory */
    public CacheBridgeFactory() {
         logger = Logger.getLogger(this.getClass().getPackage().getName());
    }

    public Cache getCache() {
        return cache;
    }

    public void setCache(Cache cache) {
        this.cache = cache;
    }
    
    public CacheBridge createCacheBridge(long ID) {
        if (cache != null){
            CacheBridge theBridge = new CacheBridge();
            theBridge.setID(ID);
            cache.registerCacheListener(theBridge);
            synchronized (cache){
	            for (CacheWrapper item: cache.getAllCommands()) {
	            	theBridge.addToCommandQueue(item.getKey(),item);
	            }
            }
            return theBridge;
        } else{
            logger.log (Level.SEVERE,"An attempt was made to create a web cache bridge but the Cache has not yet been initialised.");
            return null;
        }
    }
    
}
