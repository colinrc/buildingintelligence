package au.com.BI.Jetty;

import au.com.BI.Command.*;
import au.com.BI.Config.Security;
import au.com.BI.Util.SimplifiedModel;
import au.com.BI.Util.ClientModel;
import au.com.BI.Util.DeviceModel;
import org.mortbay.jetty.bio.SocketConnector;
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
import org.mortbay.jetty.security.HashUserRealm;
import org.mortbay.jetty.security.SecurityHandler;
import org.mortbay.jetty.security.SslSocketConnector;
import org.mortbay.jetty.security.UserRealm;

import au.com.BI.Config.Security.IPType;
//import org.mortbay.jetty.handler.*;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.*;
import au.com.BI.Servlets.*;

public class JettyHandler extends SimplifiedModel implements DeviceModel, ClientModel {
    boolean SSL = false;
    CacheBridgeFactory cacheBridgeFactory = null;
    org.mortbay.jetty.Server server = null,client_server = null;
    Logger logger;
    Security security = null;
    public static final int timeout = 30; // 1 minute timeout for a session;
    protected ConcurrentHashMap <String,String>forwards;
    
    public JettyHandler(Security security) {
        logger = Logger.getLogger(this.getClass().getPackage().getName());
        cacheBridgeFactory = new CacheBridgeFactory();
        this.setName("JETTY");
        this.setAutoReconnect(false);
        this.security = security;
        forwards= new ConcurrentHashMap<String,String>();
    }
    
    public boolean removeModelOnConfigReload() {
        return false;
    }
    
    public void startHTTPServer (UserRealm webPass) throws Exception {
    	client_server = new Server();
        
        org.mortbay.jetty.bio.SocketConnector connector = new SocketConnector();
        connector.setPort(bootstrap.getJettyPort());
        connector.setName("HTTP_CONNECT");
        client_server.setConnectors(new Connector[]{connector}); 
        
        ContextHandlerCollection contexts = new ContextHandlerCollection();
 
        // forwards handler
        Context forwardContext = new Context (contexts,"/forwards");
        forwardContext.addServlet ("au.com.BI.Servlets.RequestForward","/");
        forwardContext.setAttribute("forwards", forwards);
        
        // HTML static handler
        Context mainContext= new Context (contexts, "/html"); 
        mainContext.setResourceBase("../client/lib/html");

        ServletHolder defServlet = mainContext.addServlet("org.mortbay.jetty.servlet.DefaultServlet","/");
        defServlet.setInitParameter("dirAllowed","false");
        defServlet.setInitParameter("aliases", "true");
        defServlet.setInitParameter("serveIcon", "false");
        
        
         
        /** Post only content */ 
        
        Context postContext = new Context (contexts,"/post", Context.SECURITY | Context.NO_SESSIONS);
                   
        postContext.setAttribute("Cache",cache);
        postContext.setAttribute("ServerID",new Long (this.getServerID()));
        postContext.setAttribute("CommandQueue",commandQueue);
        postContext.setAttribute("Security",security);       
        postContext.addServlet("au.com.BI.Servlets.PostUpdateServlet","/update");
 
          
        SecurityHandler postContextMgrSrc = postContext.getSecurityHandler();
        postContextMgrSrc.setUserRealm(webPass);
        
        ELifeAuthenticator updateAuthenticator = new ELifeAuthenticator ();
        updateAuthenticator.setSecurity(security);
        updateAuthenticator.setIpType(IPType.PostOnly);
        postContextMgrSrc.setAuthenticator(updateAuthenticator);
        updateAuthenticator.setLoginPage("/login.html");
        updateAuthenticator.setErrorPage("/login_fail.html");
        Constraint postClientConstraint = new Constraint();
        postClientConstraint.setName(Constraint.__FORM_AUTH);
        postClientConstraint.setRoles(new String[]{"user","admin","moderator"});
        postClientConstraint.setAuthenticate(true);

       ConstraintMapping postClientCM = new ConstraintMapping();
       postClientCM.setConstraint(postClientConstraint);
       postClientCM.setPathSpec("/*");
       
        postContextMgrSrc.setConstraintMappings(new ConstraintMapping[]{postClientCM});
        
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
    	
        
        // HTML Security realm

        HashUserRealm  webPass = new HashUserRealm ();
        webPass.setName("eLife");
        webPass.setConfig("datafiles/realm.properties");
       
        try {
        	startHTTPServer (webPass);

        } catch (Exception ex){
            logger.log (Level.WARNING,"Problems starting web server " + ex.getMessage());
            throw ex;
        }

        
        try {
            server = new Server();
            
              SslSocketConnector sslConnect = new SslSocketConnector();
            	sslConnect.setPort(bootstrap.getJettySSLPort());
            	sslConnect.setKeystore("datafiles/keystore");
            	sslConnect.setPassword("building12");
            	sslConnect.setKeyPassword("building12");
            	sslConnect.setName("SSL_CONNECT");
              server.setConnectors(new Connector[]{sslConnect});
 
              ContextHandlerCollection contexts = new ContextHandlerCollection();
              

            // Normal webclient  context
             Constraint webClientConstraint = new Constraint();
             webClientConstraint.setName(Constraint.__FORM_AUTH);
             
             webClientConstraint.setRoles(new String[]{"user","admin","moderator"});
             webClientConstraint.setAuthenticate(true);

            ConstraintMapping webClientCM = new ConstraintMapping();
            webClientCM.setConstraint(webClientConstraint);
            webClientCM.setPathSpec("/*");
            
            
            Context updateContext= new Context (contexts, "/",Context.SECURITY|Context.SESSIONS);
                         
            updateContext.setResourceBase("../www");
            updateContext.setConnectorNames(new String[]{"SSL_CONNECT"});

            updateContext.addServlet("au.com.BI.Servlets.UpdateServlet","/webclient/update");
            updateContext.addServlet("au.com.BI.Servlets.Logout","/webclient/logout");
            ServletHolder  defServlet = updateContext.addServlet("org.mortbay.jetty.servlet.DefaultServlet","/");
            
            updateContext.setWelcomeFiles(new String[]{"index.html"});
            
            defServlet.setInitParameter("dirAllowed","false");
            defServlet.setInitParameter("aliases", "true");
            defServlet.setInitParameter("serveIcon", "false");
                 
           SessionManager updateContextSessionMgr =  updateContext.getSessionHandler().getSessionManager();
           updateContextSessionMgr.setMaxInactiveInterval(timeout);

           updateContext.setAttribute("CacheBridgeFactory",cacheBridgeFactory);
           updateContext.setAttribute("AddressBook",addressBook);
           updateContext.setAttribute("CommandQueue",commandQueue);
           updateContext.setAttribute("Security",security);
           updateContext.setAttribute("ServerID",new Long (this.getServerID()));
           updateContext.setAttribute("VersionManager",this.getVersionManager());
           updateContext.setAttribute("WebClientCount",new Integer(0));

           SessionCounter sessionCounter = new SessionCounter ();
           sessionCounter.setAddressBook(addressBook);
           
           updateContext.setAttribute("SessionCounter", sessionCounter);
  
            updateContextSessionMgr.addEventListener(sessionCounter);
            security.setSessionCounter (sessionCounter);
            
            SecurityHandler updateMgrSec = updateContext.getSecurityHandler();
            updateMgrSec.setUserRealm(webPass);
            
            ELifeAuthenticator updateAuthenticator = new ELifeAuthenticator ();
            updateAuthenticator.setSecurity(security);
            updateAuthenticator.setIpType(IPType.FullFunction);
            updateAuthenticator.setLoginPage("/login.html");
            updateAuthenticator.setErrorPage("/login_fail.html");
            updateMgrSec.setAuthenticator(updateAuthenticator);
            
            
            updateMgrSec.setConstraintMappings(new ConstraintMapping[]{webClientCM});
                 
            
            /** User manager context */
            
            Constraint constraint = new Constraint();
            constraint.setName(Constraint.__FORM_AUTH);;
            constraint.setRoles(new String[]{"user","admin","moderator"});
            constraint.setAuthenticate(true);

            ConstraintMapping cm = new ConstraintMapping();
            cm.setConstraint(constraint);
            cm.setPathSpec("/*");
            
  
            Context userMgrContext = new Context (contexts, "/UserManager",Context.SECURITY|Context.SESSIONS);
            userMgrContext.setResourceBase("../www/UserManager");
            userMgrContext.setAttribute("UserManager",webPass);
            userMgrContext.setAttribute("AddressBook",addressBook);
            userMgrContext.setConnectorNames(new String[]{"SSL_CONNECT"});
//            WelcomeFilter userWelcome  = userMgrContext.addFilter(new WelcomeFilter(), "/", "/Users");

            ServletHolder  useMgrDef  =userMgrContext.addServlet("org.mortbay.jetty.servlet.DefaultServlet","/*");

            userMgrContext.addServlet("au.com.BI.Servlets.UserManagerServlet", "/Users");
            userMgrContext.addServlet("au.com.BI.Servlets.LogoutUserManager", "/Logout");
     
            useMgrDef.setInitParameter("welcome","/Users");
            useMgrDef.setInitParameter("aliases", "true");
            useMgrDef.setInitParameter("serveIcon", "false");
            useMgrDef.setInitParameter("redirectWelcome", "false");
        
           userMgrContext.setWelcomeFiles(new String[]{"Users","index.html"});
            
            SecurityHandler userMgrSec = userMgrContext.getSecurityHandler();
            userMgrSec.setUserRealm(webPass);
        	
            ELifeAuthenticator usrAuthenticator = new ELifeAuthenticator ();
            usrAuthenticator.setSecurity(security);
            usrAuthenticator.setLoginPage("/login.html");
            usrAuthenticator.setErrorPage("/login_fail.html");
            usrAuthenticator.setIpType(IPType.PWDOnly);
        	
            userMgrSec.setAuthenticator(usrAuthenticator);
            userMgrSec.setConstraintMappings(new ConstraintMapping[]{cm});
                       
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
    ConnectionFail {}

	/**
	 * @param src
	 * @param dest
	 */
	public void addForward(String src, String dest) {
		forwards.put(src,dest);		
	}

	/**
	 * 
	 */
	public void clearForwards() {
		forwards.clear();
		
	};

}
