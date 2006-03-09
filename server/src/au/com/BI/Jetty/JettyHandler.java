package au.com.BI.Jetty;

import au.com.BI.Command.*;
import java.util.*;

public class JettyHandler implements CacheListener{
	int port = 80;
	String docRoot;
	boolean SSL = false;
	Cache cache = null;
	LinkedList commandsToSend;
	
	public JettyHandler() {
		commandsToSend = new LinkedList ();
	}

	public void start() throws JettyException {
		
	}
	
	public void setCache (Cache cache){
		this.cache = cache;
		cache.registerCacheListener(this);
		// This will need to move to the new client connection area, in order to have one
		// listener per web client
	}
	
	public void cacheUpdated (String key, CacheWrapper cacheWrapper) {
		synchronized (commandsToSend){
			commandsToSend.add(cacheWrapper);
		}
	}
	
	public String getDocRoot() {
		return docRoot;
	}
	public void setDocRoot(String docRoot) {
		this.docRoot = docRoot;
	}
	public int getPort() {
		return port;
	}
	public void setPort(int port) {
		this.port = port;
	}
	public boolean isSSL() {
		return SSL;
	}
	public void setSSL(boolean ssl) {
		SSL = ssl;
	}
}
