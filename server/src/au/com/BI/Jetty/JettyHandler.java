package au.com.BI.Jetty;

import au.com.BI.Command.*;
import java.util.*;
import java.io.*;
import java.net.*;
import org.mortbay.jetty.bio.SocketConnector;
import org.mortbay.util.*;
import org.mortbay.jetty.*;
import org.mortbay.jetty.servlet.*;
import org.mortbay.servlet.*;
import org.mortbay.jetty.security.*;

public class JettyHandler implements CacheListener{
    int port = 80;
    String docRoot;
    boolean SSL = false;
    Cache cache = null;
    LinkedHashMap commandsToSend;
    
    public JettyHandler() {
        commandsToSend = new LinkedHashMap();
    }
    
    public  void start()
    throws Exception {
        // Create the server
        org.mortbay.jetty.Server server = new Server();
        org.mortbay.jetty.bio.SocketConnector connector = new SocketConnector();
        connector.setPort(port);
        connector.setMaxIdleTime(50000);
        server.setConnectors(new Connector[]{connector});
        
        // Create a context
        //HttpContext context = new HttpContext();
        //context.setContextPath("/mystuff/*");
        //server.addContext(context);
        
        // Create a servlet container
        //ServletHandler servlets = new ServletHandler();
        //context.addHandler(servlets);
        
        // Map a servlet onto the container
        //servlets.addServlet("Dump","/Dump/*","org.mortbay.servlet.Dump");
        
        // Serve static content from the context
        //String home = System.getProperty("jetty.home",".");
        //context.setResourceBase(home+"/demo/webapps/jetty/tut/");
        //context.addHandler(new ResourceHandler());
        /*
              <Array type="org.mortbay.jetty.security.UserRealm">
        <Item>
          <New class="org.mortbay.jetty.security.HashUserRealm">
            <Set name="name">Test Realm</Set>
            <Set name="config">etc/realm.properties</Set>
          </New>
        </Item>
      </Array>
          */            
        HashUserRealm webPass = new HashUserRealm();
        webPass.setName("eLife");
        webPass.setConfig("datafiles/realm.properties");
        server.addUserRealm(webPass);
        server.setStopAtShutdown(true);
        // Start the http server
        server.start ();
    }
    
    
    public void setCache(Cache cache){
        this.cache = cache;
        cache.registerCacheListener(this);
        // This will need to move to the new client connection area, in order to have one
        // listener per web client
    }
    
    public void cacheUpdated(String key, CacheWrapper cacheWrapper) {
        synchronized (commandsToSend){
            commandsToSend.put(key,cacheWrapper);
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
