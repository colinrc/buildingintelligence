package au.com.BI.Jetty;

import au.com.BI.Command.*;
import java.util.*;
import org.mortbay.jetty.bio.SocketConnector;
import org.mortbay.jetty.servlet.ServletHolder;
import org.mortbay.jetty.*;
import org.mortbay.jetty.servlet.*;
import org.mortbay.jetty.security.*;
import org.mortbay.jetty.handler.*;
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
            
           

            /*
            // Call Web application 
            WebAppContext updateContextHandler = new WebAppContext ();
            updateContextHandler.setContextPath("/update");
            updateContextHandler.setResourceBase(docRoot);
            updateContextHandler.setServer (server);
            updateContextHandler.setWar(docRoot+"/webapps/"+"eLife");
            */

            /*
             * Switched to web app 
             *
            // HTML Security realm
            HashUserRealm webPass = new HashUserRealm();
            webPass.setName("eLife");
            webPass.setConfig("datafiles/realm.properties");
            server.addUserRealm(webPass);


            // Call servlet directly
            ContextHandler updateContextHandler = new ContextHandler ();
            updateContextHandler.setContextPath("/update");
            updateContextHandler.setResourceBase(docRoot);
            
            
            ServletHandler updateHandler = new ServletHandler ();   
            ServletHolder updateServlet = updateHandler.addServlet("au.com.BI.Servlets.UpdateServlet","/update/*");
            ServletHolder logoutServlet = updateHandler.addServlet("au.com.BI.Servlets.Logout","/logout/*");
            updateContextHandler.setHandler(updateHandler);
            updateContextHandler.setAttribute("CacheBridgeFactory",cacheBridgeFactory);

                    
            //server.addHandler (updateContextHandler);
            
            // Servlet Security config
            SecurityHandler servletSec = new SecurityHandler();
            servletSec.setServer(server);
            servletSec.setAuthMethod(Constraint.__BASIC_AUTH);
            servletSec.setUserRealm(webPass);
            
            ConstraintMapping servletConstraintMap = new ConstraintMapping();
            servletConstraintMap.setPathSpec("/update/*");
            Constraint servletConstraint = new Constraint();
            servletConstraint.setName("Servlet");
            servletConstraint.setRoles(new String[]{"user"});
            servletConstraint.setAuthenticate(true);
            servletConstraintMap.setConstraint(servletConstraint);
            servletSec.setConstraintMappings(new ConstraintMapping[] {servletConstraintMap});
            servletSec.setHandler(updateContextHandler);
            server.addHandler(servletSec);

            
            
            
            // logout servlet
            ServletHandler logoutHandler = new ServletHandler ();   
            ServletHolder logoutServlet = logoutHandler.addServlet("au.com.BI.Servlets.Logout","/logout/*");
            updateContextHandler.setHandler(logoutHandler);
           
            // Logout Security config
            SecurityHandler logoutSec = new SecurityHandler();
            logoutSec.setServer(server);
            logoutSec.setAuthMethod(Constraint.__BASIC_AUTH);
            logoutSec.setUserRealm(webPass);
            ConstraintMapping logoutConstraintMap = new ConstraintMapping();
            logoutConstraintMap.setPathSpec("/update/*");
            Constraint logoutConstraint = new Constraint();
            logoutConstraint.setName("Servlet");
            logoutConstraint.setRoles(new String[]{"user"});
            logoutConstraint.setAuthenticate(true);
            logoutConstraintMap.setConstraint(logoutConstraint);
            logoutSec.setConstraintMappings(new ConstraintMapping[] {logoutConstraintMap});
            logoutSec.setHandler(logoutHandler);
            server.addHandler(logoutSec);

            */
            // HTML static handler
            ContextHandler mainContextHandler = new ContextHandler ();
            mainContextHandler.setContextPath("/");
            mainContextHandler.setResourceBase(docRoot);

            ServletHandler servletHandler = new ServletHandler ();

            ServletHolder defServlet = servletHandler.addServlet("org.mortbay.jetty.servlet.DefaultServlet","/*");
            mainContextHandler.setHandler(servletHandler);
            
            server.addHandler(mainContextHandler); // added to security handler if security is needed
            
            
            /*
            // HTML Security config
            SecurityHandler overallSec = new SecurityHandler();
            overallSec.setServer(server);
            overallSec.setAuthMethod(Constraint.__BASIC_AUTH);
            overallSec.setUserRealm(webPass); Temporarily switch off security for static content
            
            ConstraintMapping overallConstraintMap = new ConstraintMapping();
            overallConstraintMap.setPathSpec("/");
            Constraint overallConstraint = new Constraint();
            overallConstraint.setName("Overall");
            overallConstraint.setRoles(new String[]{"*"});
            overallConstraint.setAuthenticate(true);
            overallConstraintMap.setConstraint(overallConstraint);
            overallSec.setConstraintMappings(new ConstraintMapping[] {overallConstraintMap});
            overallSec.setHandler(mainContextHandler);
            server.addHandler(overallSec);
            */

            server.setStopAtShutdown(true);
            
            // Start the http server
            server.start ();
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
