package au.com.BI.Jetty;

import au.com.BI.Command.*;
import java.util.*;
import org.mortbay.jetty.bio.SocketConnector;
import org.mortbay.jetty.servlet.ServletHolder;
import org.mortbay.jetty.Connector;
import org.mortbay.jetty.Server;
import org.mortbay.jetty.handler.ContextHandler;
import org.mortbay.jetty.handler.ContextHandlerCollection;
import org.mortbay.jetty.handler.DefaultHandler;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.mortbay.jetty.servlet.ServletHandler;
import org.mortbay.jetty.handler.HandlerCollection;
import org.mortbay.jetty.security.HashUserRealm;
//import org.mortbay.jetty.handler.*;
import java.util.logging.*;



public class JettyHandler {
    int port = 8080;
    String docRoot;
    boolean SSL = false;
    Cache cache = null;
    CacheBridgeFactory cacheBridgeFactory = null;
    org.mortbay.jetty.Server server = null;
    Logger logger;
    
    public JettyHandler() {
        logger = Logger.getLogger(this.getClass().getPackage().getName());
        cacheBridgeFactory = new CacheBridgeFactory();
    }
    
    public  void start()
    throws Exception {
        // Create the server
        try {
            server = new Server();
            org.mortbay.jetty.bio.SocketConnector connector = new SocketConnector();
            connector.setPort(port);
            connector.setMaxIdleTime(50000);
            server.setConnectors(new Connector[]{connector});
           

            // HTML Security realm

            HashUserRealm webPass = new HashUserRealm();
            webPass.setName("eLife");
            webPass.setConfig("datafiles/realm.properties");
            server.addUserRealm(webPass);

            // Call servlet directly
            ContextHandler updateContextHandler = new ContextHandler ();
            updateContextHandler.setContextPath("/webclient");
            updateContextHandler.setResourceBase(docRoot);
           

            ServletHandler updateHandler = new ServletHandler ();   
            
            ServletHolder updateServlet = updateHandler.addServletWithMapping("au.com.BI.Servlets.UpdateServlet","/get");
            ServletHolder logoutServlet = updateHandler.addServletWithMapping("au.com.BI.Servlets.Logout","/logout");
            
            updateContextHandler.setHandler(updateHandler);
            updateContextHandler.setAttribute("CacheBridgeFactory",cacheBridgeFactory);

            /*
            // Servlet Security config
            SecurityHandler servletSec = new SecurityHandler();
            servletSec.setServer(server);
            servletSec.setAuthMethod(Constraint.__BASIC_AUTH);
            servletSec.setUserRealm(webPass);
            ConstraintMapping servletConstraintMap = new ConstraintMapping();
            servletConstraintMap.setPathSpec("/*");
            Constraint servletConstraint = new Constraint();
            servletConstraint.setName("Servlet");
            servletConstraint.setRoles(new String[]{"user"});
            servletConstraint.setAuthenticate(true);
            servletConstraintMap.setConstraint(servletConstraint);
            servletSec.setConstraintMappings(new ConstraintMapping[] {servletConstraintMap});
            servletSec.setHandler(updateContextHandler);
            */
            
            // HTML static handler
            ContextHandler mainContextHandler = new ContextHandler ();
            mainContextHandler.setContextPath("/");
            mainContextHandler.setResourceBase(docRoot);

            ServletHandler servletHandler = new ServletHandler ();         
            ServletHolder defServlet = servletHandler.addServletWithMapping("org.mortbay.jetty.servlet.DefaultServlet","/");
            defServlet.setInitParameter("dirAllowed","false");
            
            mainContextHandler.setHandler(servletHandler);
            
            
            ContextHandlerCollection contexts = new ContextHandlerCollection();
            contexts.setHandlers(new org.mortbay.jetty.Handler[]{updateContextHandler,mainContextHandler});
    
            HandlerCollection handlers = new HandlerCollection();
            handlers.setHandlers(new org.mortbay.jetty.Handler[]{contexts,new DefaultHandler()});
            
            server.setHandler(handlers);
            server.setStopAtShutdown(true);
            
            // Start the http server
            server.start ();
            server.join();
        } catch (Exception ex){
            logger.log (Level.WARNING,"Problems starting web server");
            throw ex;
        }
    }
    
    
    public void setCache(Cache cache){
        this.cache = cache;
        cacheBridgeFactory.setCache(cache);
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
