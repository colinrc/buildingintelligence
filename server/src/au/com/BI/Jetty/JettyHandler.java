package au.com.BI.Jetty;

import au.com.BI.Command.*;
import au.com.BI.Config.Security;
import au.com.BI.Util.SimplifiedModel;
import au.com.BI.Util.ClientModel;
import au.com.BI.Util.DeviceModel;
import org.mortbay.jetty.bio.SocketConnector;
import org.mortbay.jetty.servlet.ServletHolder;
import org.mortbay.jetty.Connector;
import org.mortbay.jetty.Server;
import org.mortbay.jetty.SessionManager;
import org.mortbay.jetty.handler.ContextHandler;
import org.mortbay.jetty.servlet.SessionHandler;

import org.mortbay.jetty.handler.ContextHandlerCollection;
import org.mortbay.jetty.handler.DefaultHandler;
import org.mortbay.jetty.servlet.ServletHandler;
import org.mortbay.jetty.handler.HandlerCollection;
import org.mortbay.jetty.security.Constraint;
import org.mortbay.jetty.security.ConstraintMapping;
import org.mortbay.jetty.security.HashUserRealm;
import org.mortbay.jetty.security.SecurityHandler;
import org.mortbay.jetty.security.SslSocketConnector;
import org.mortbay.jetty.security.UserRealm;
//import org.mortbay.jetty.handler.*;
import java.util.List;
import java.util.logging.*;


public class JettyHandler extends SimplifiedModel implements DeviceModel, ClientModel {
    boolean SSL = false;
    CacheBridgeFactory cacheBridgeFactory = null;
    org.mortbay.jetty.Server server = null,client_server = null;
    Logger logger;
    Security security = null;
    public static final int timeout = 30; // 1 minute timeout for a session;
    
    public JettyHandler(Security security) {
        logger = Logger.getLogger(this.getClass().getPackage().getName());
        cacheBridgeFactory = new CacheBridgeFactory();
        this.setName("JETTY");
        this.setAutoReconnect(false);
        this.security = security;
    }
    
    public boolean removeModelOnConfigReload() {
        return false;
    }
    
    public void startHTMLServer () throws Exception {
    	
    	client_server = new Server();
        
        org.mortbay.jetty.bio.SocketConnector connector = new SocketConnector();
        connector.setPort(bootstrap.getJettyPort());
        connector.setMaxIdleTime(50000);
        connector.setName("HTTP_CONNECT");
        client_server.setConnectors(new Connector[]{connector});
        
        // HTML static handler
        ContextHandler mainContextHandler = new ContextHandler ();
        mainContextHandler.setContextPath("/html");
        mainContextHandler.setResourceBase("../client/lib/html");

        ServletHandler servletHandler = new ServletHandler ();         
        ServletHolder defServlet = servletHandler.addServletWithMapping("org.mortbay.jetty.servlet.DefaultServlet","/");
        defServlet.setInitParameter("dirAllowed","false");
        mainContextHandler.setHandler(servletHandler);
        
        ContextHandlerCollection contexts = new ContextHandlerCollection();
        contexts.setHandlers(new org.mortbay.jetty.Handler[]{mainContextHandler});

        HandlerCollection handlers = new HandlerCollection();
        handlers.setHandlers(new org.mortbay.jetty.Handler[]{contexts,new DefaultHandler()});
        
        client_server.setHandler(handlers);
        client_server.setStopAtShutdown(true);
        
        // Start the http server
        client_server.start ();
    }
    
    
    public  void start()
    throws Exception {
        // Create the server
    	if (!bootstrap.isJettyActive()){
    		return;
    	}
    	
        try {
        	startHTMLServer ();

        } catch (Exception ex){
            logger.log (Level.WARNING,"Problems starting web server " + ex.getMessage());
            throw ex;
        }
        
        try {
            server = new Server();
            // jettyHandler.setSSL(bootstrap.isSSL());
            
              SslSocketConnector sslConnect = new SslSocketConnector();
            	sslConnect.setPort(bootstrap.getJettySSLPort());
            	sslConnect.setMaxIdleTime(30000);
            	sslConnect.setKeystore("datafiles/keystore");
            	sslConnect.setPassword("building12");
            	sslConnect.setKeyPassword("building12");
            	sslConnect.setName("SSL_CONNECT");
              server.setConnectors(new Connector[]{sslConnect});
 
              
            // HTML Security realm

            HashUserRealm  webPass = new HashUserRealm ();
            webPass.setName("eLife");
            webPass.setConfig("datafiles/realm.properties");
            server.addUserRealm(webPass);

            //ELifeAuthenticator eLifeAuthenticator = new ELifeAuthenticator();
            // Authenticator 
            // Call servlet directly
            ContextHandler updateContextHandler = new ContextHandler ();

            //updateContextHandler.setContextPath("/webclient");
            updateContextHandler.setContextPath("/");
                       
            updateContextHandler.setResourceBase("../www");
            updateContextHandler.setConnectorNames(new String[]{"SSL_CONNECT"});

            ServletHandler updateHandler = new ServletHandler ();   

            ServletHolder updateServlet = updateHandler.addServletWithMapping("au.com.BI.Servlets.UpdateServlet","/webclient/update");
            ServletHolder userManager = updateHandler.addServletWithMapping("au.com.BI.Servlets.UserManagerServlet","/UserManager");
            ServletHolder logoutServlet = updateHandler.addServletWithMapping("au.com.BI.Servlets.Logout","/webclient/logout");
            ServletHolder defServlet = updateHandler.addServletWithMapping("org.mortbay.jetty.servlet.DefaultServlet","/");
            
            SessionHandler sessionHandler = new SessionHandler();
            sessionHandler.setHandler(updateHandler);
           SessionManager sessionManager =  sessionHandler.getSessionManager();
           sessionManager.setMaxInactiveInterval(timeout);
           
            updateContextHandler.setHandler(sessionHandler);
            updateContextHandler.setAttribute("CacheBridgeFactory",cacheBridgeFactory);
            updateContextHandler.setAttribute("AddressBook",addressBook);
            updateContextHandler.setAttribute("CommandQueue",commandQueue);
            updateContextHandler.setAttribute("Security",security);
            updateContextHandler.setAttribute("ServerID",new Long (this.getServerID()));
            updateContextHandler.setAttribute("VersionManager",this.getVersionManager());
            updateContextHandler.setAttribute("UserManager",webPass);
            updateContextHandler.setAttribute("WebClientCount",new Integer(0));
            
            sessionManager.addEventListener(new SessionCounter());


            SecurityHandler servletSec = null;
            
            if (bootstrap.isRequestUserNames()) {
            	servletSec= addUserNameSecurity(updateContextHandler, webPass);
            	
	        }
      
            ContextHandlerCollection contexts = new ContextHandlerCollection();

            if (bootstrap.isRequestUserNames()){
            	contexts.setHandlers(new org.mortbay.jetty.Handler[]{servletSec});
            } else {
            	contexts.setHandlers(new org.mortbay.jetty.Handler[]{updateContextHandler});
            }           
    
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
    
    
    public SecurityHandler  addUserNameSecurity (ContextHandler updateContextHandler, UserRealm webPass) {
        // Servlet Security config
    	SecurityHandler servletSec = new SecurityHandler();

        
        servletSec.setServer(server);
        servletSec.setAuthMethod(Constraint.__BASIC_AUTH);
        servletSec.setUserRealm(webPass);

        ConstraintMapping servletConstraintMap = new ConstraintMapping();
        servletConstraintMap.setPathSpec("/*");
        Constraint servletConstraint = new Constraint();
        servletConstraint.setName("Servlet");
        servletConstraint.setRoles(new String[]{"user","admin","integrator"});
        servletConstraint.setAuthenticate(true);
        servletConstraintMap.setConstraint(servletConstraint);
        servletSec.setConstraintMappings(new ConstraintMapping[] {servletConstraintMap});
        servletSec.setHandler(updateContextHandler);
        
    	ELifeAuthenticator eLifeAuthenticator = new ELifeAuthenticator ();
        servletSec.setAuthenticator(eLifeAuthenticator);
        
        //servletSec.addHandler(updateContextHandler);
        return servletSec;
    }
    
    public void setCache(Cache cache){
        this.cache = cache;
        cacheBridgeFactory.setCache(cache);
    }

	/* (non-Javadoc)
	 * @see au.com.BI.Util.ClientModel#broadcastCommand(au.com.BI.Command.CommandInterface)
	 */
	public void broadcastCommand(CommandInterface command) {
		
	}
	
    public void attatchComms(List <CommandInterface> commandQueue) throws au.com.BI.Comms.
    ConnectionFail {};

}
