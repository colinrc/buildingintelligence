package au.com.BI.Jetty;

import org.mortbay.jetty.servlet.Context;
import org.mortbay.jetty.servlet.ServletHolder;
import org.mortbay.jetty.Connector;
import org.mortbay.jetty.Server;
import org.mortbay.jetty.SessionManager;

import org.mortbay.jetty.handler.ContextHandlerCollection;
import org.mortbay.jetty.handler.DefaultHandler;
import org.mortbay.jetty.handler.HandlerCollection;

import org.mortbay.jetty.security.Constraint;
import org.mortbay.jetty.security.ConstraintMapping;
import org.mortbay.jetty.security.FormAuthenticator;
import org.mortbay.jetty.security.HashUserRealm;
import org.mortbay.jetty.security.SecurityHandler;
import org.mortbay.jetty.security.SslSocketConnector;

//import org.mortbay.jetty.handler.*;
import au.com.BI.Admin.*;
import java.util.logging.*;
 

public class JettyHandler {
    boolean SSL = false;
    org.mortbay.jetty.Server server = null,client_server = null;
    Logger logger;
    public static final int timeout = 30; // 1 minute timeout for a session;
    
    public JettyHandler() {
        logger = Logger.getLogger(this.getClass().getPackage().getName());
    }
    
    
    public  void start(int portNumber,String installBase,eLife_monitor eLife_mon)
  
    throws Exception {
        // Create the server

    	
        
        // HTML Security realm

        HashUserRealm  webPass = new HashUserRealm ();
        webPass.setName("eLife_Monitor");
        webPass.setConfig(installBase + "/datafiles/realm.properties");
        
        try {
            server = new Server();
            
              SslSocketConnector sslConnect = new SslSocketConnector();
            	sslConnect.setPort(portNumber);
            	sslConnect.setKeystore(installBase + "/datafiles/keystore");
            	sslConnect.setPassword("building12");
            	sslConnect.setKeyPassword("building12");
            	sslConnect.setName("SSL_CONNECT");
              server.setConnectors(new Connector[]{sslConnect});
 
              ContextHandlerCollection contexts = new ContextHandlerCollection();
              

            // Normal webclient  context
             Constraint webClientConstraint = new Constraint();
             webClientConstraint.setName(Constraint.__FORM_AUTH);
             
             webClientConstraint.setRoles(new String[]{"admin"});
             webClientConstraint.setAuthenticate(true);

            ConstraintMapping webClientCM = new ConstraintMapping();
            webClientCM.setConstraint(webClientConstraint);
            webClientCM.setPathSpec("/*");
            
            
            Context updateContext= new Context (contexts, "/",Context.SECURITY|Context.SESSIONS);
                         
            updateContext.setResourceBase("monitor_web");
            updateContext.setAttribute("eSmart_Install", installBase);
            updateContext.setConnectorNames(new String[]{"SSL_CONNECT"});

            updateContext.addServlet("au.com.BI.Servlets.Control","/control");
            ServletHolder davServlet = updateContext.addServlet("net.sf.webdav.WebdavServlet","/dav");
            ServletHolder  defServlet = updateContext.addServlet("org.mortbay.jetty.servlet.DefaultServlet","/");
            
            davServlet.setInitParameter("rootpath", installBase);
            davServlet.setInitParameter("ResourceHandlerImplementation","net.sf.webdav.LocalFileSystemStore");
            davServlet.setInitParameter("maxUploadSize","2000000"); // 2mb
            
            updateContext.setWelcomeFiles(new String[]{"index.html"});
            
            defServlet.setInitParameter("dirAllowed","false");
            defServlet.setInitParameter("aliases", "true");
            defServlet.setInitParameter("serveIcon", "false");
                 
           SessionManager updateContextSessionMgr =  updateContext.getSessionHandler().getSessionManager();
           updateContextSessionMgr.setMaxInactiveInterval(timeout);


            
            SecurityHandler updateMgrSec = updateContext.getSecurityHandler();
            updateMgrSec.setUserRealm(webPass);
            
            FormAuthenticator updateAuthenticator = new FormAuthenticator ();
            updateAuthenticator.setLoginPage("/login.html");
            updateAuthenticator.setErrorPage("/login_fail.html");
            updateMgrSec.setAuthenticator(updateAuthenticator);        
            
            updateMgrSec.setConstraintMappings(new ConstraintMapping[]{webClientCM});
                             
           	HandlerCollection handlers = new HandlerCollection();
            handlers.setHandlers(new org.mortbay.jetty.Handler[]{contexts,new DefaultHandler()});
            
            server.setHandler(handlers);
            server.setStopAtShutdown(true);

            // Start the http server
            server.start ();
        } catch (Exception ex){
            logger.log (Level.WARNING,"Problems starting web server " + ex.getMessage());
            throw ex;
        }
    }




}
