package au.com.BI.Jetty;

import au.com.BI.Command.*;
import au.com.BI.Config.Security;
import au.com.BI.Util.SimplifiedModel;
import au.com.BI.Util.ClientModel;
import au.com.BI.Util.DeviceModel;
import org.eclipse.jetty.server.bio.SocketConnector;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;
import org.eclipse.jetty.server.Connector;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.SessionManager;

import org.eclipse.jetty.server.handler.ContextHandlerCollection;
import org.eclipse.jetty.server.handler.DefaultHandler;
import org.eclipse.jetty.server.handler.HandlerCollection;

import org.eclipse.jetty.http.security.Constraint;
import org.eclipse.jetty.security.ConstraintMapping;
import org.eclipse.jetty.security.HashLoginService;
import org.eclipse.jetty.security.LoginService;
import org.eclipse.jetty.security.authentication.FormAuthenticator;
import org.eclipse.jetty.server.session.SessionHandler;
import org.eclipse.jetty.server.ssl.SslSocketConnector;


import au.com.BI.Config.Security.IPType;
//import org.eclipse.jetty.server.handler.*;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.*;

public class JettyHandler extends SimplifiedModel implements DeviceModel, ClientModel {
    boolean SSL = false;
    CacheBridgeFactory cacheBridgeFactory = null;
    org.eclipse.jetty.server.Server server = null,client_server = null;
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
        if (logger.isLoggable(Level.INFO)){
        	System.setProperty("org.eclipse.jetty.util.log.DEBUG", "true");
        }
    }
    
    public boolean removeModelOnConfigReload() {
        return false;
    }
    
    public void startHTTPServer (HashLoginService webPass) throws Exception {
    	client_server = new Server(0);
    	
    	client_server.addBean(webPass);
    	
        
        org.eclipse.jetty.server.bio.SocketConnector connector = new SocketConnector();
        connector.setPort(bootstrap.getJettyPort());
        connector.setName("HTTP_CONNECT");
        client_server.setConnectors(new Connector[]{connector}); 
        
        ContextHandlerCollection contexts = new ContextHandlerCollection();
        
        // HTML static handler
        ServletContextHandler mainContext= new ServletContextHandler (contexts, "/html"); 
        mainContext.setResourceBase("../client/lib/html");

        ServletHolder defServlet = mainContext.addServlet("org.eclipse.jetty.servlet.DefaultServlet","/");
        defServlet.setInitParameter("dirAllowed","false");
        defServlet.setInitParameter("aliases", "true");
        defServlet.setInitParameter("serveIcon", "false");
           
        contexts.addHandler(new DefaultHandler());
        
        client_server.setHandler(contexts);
        client_server.setStopAtShutdown(true);
        
        // Start the http server
        client_server.start ();
    }
    

    

    public void startClientProtocolServer (LoginService webPass) throws Exception {
        server = new Server(0);
        
        server.addBean(webPass);
        
        SslSocketConnector sslConnect = new SslSocketConnector();
        sslConnect.setPort(bootstrap.getJettySSLPort());
        sslConnect.setKeystore("datafiles/keystore");
        sslConnect.setPassword("building12");
        sslConnect.setKeyPassword("building12");
        sslConnect.setName("SSL_CONNECT");
        server.setConnectors(new Connector[]{sslConnect});

        ContextHandlerCollection contexts = new ContextHandlerCollection();
        addPostOnlyContext(contexts);  
        addNormalWebClientContext (contexts);
        addUserManagerContext (contexts,webPass);
        
        contexts.addHandler(new DefaultHandler());
        
        //server.setHandler(handlers);
        server.setHandler(contexts);
        server.setStopAtShutdown(true);

        // Start the client communication server
        server.start ();
   	
    }
    
    protected void addPostOnlyContext (ContextHandlerCollection contexts){
   
        Constraint postClientConstraint = new Constraint();
        postClientConstraint.setName(Constraint.__FORM_AUTH);
        postClientConstraint.setRoles(new String[]{"user","admin","integrator"});
        postClientConstraint.setAuthenticate(true);
        
        /** Post only content */            
        IPInRangeHandler iPInRangeHandler = new IPInRangeHandler();
        iPInRangeHandler.setIpType(IPType.PostOnly);
        iPInRangeHandler.setSecurity(security);
        ServletContextHandler postContext = new ServletContextHandler (contexts,"/post", true,false);
        postContext.setSecurityHandler(iPInRangeHandler);
        postContext.setAttribute("Cache",cache);
        postContext.setAttribute("ServerID",new Long (this.getServerID()));
        postContext.setAttribute("CommandQueue",commandQueue);
        postContext.setAttribute("Security",security);       
        postContext.setAttribute("IPType",IPType.PostOnly);    
        postContext.addServlet("au.com.BI.Servlets.PostUpdateServlet","/update");

        ConstraintMapping postClientCM = new ConstraintMapping();
        postClientCM.setConstraint(postClientConstraint);
        postClientCM.setPathSpec("/*");
        
        iPInRangeHandler.setConstraintMappings(new ConstraintMapping[] {postClientCM});
    }
    
    protected void addNormalWebClientContext(ContextHandlerCollection contexts) {
        // Normal webclient  context
        Constraint webClientConstraint = new Constraint();
        webClientConstraint.setName(Constraint.__FORM_AUTH);
        webClientConstraint.setRoles(new String[]{"user","admin","integrator"});
        webClientConstraint.setAuthenticate(true);

       ConstraintMapping webClientCM = new ConstraintMapping();
       webClientCM.setConstraint(webClientConstraint);
       webClientCM.setPathSpec("/*");
       
       IPInRangeHandler fullFunctionSecHandler = new IPInRangeHandler();
       fullFunctionSecHandler.setSecurity(security);
       fullFunctionSecHandler.setIpType(IPType.FullFunction);
       fullFunctionSecHandler.setAuthenticator(new FormAuthenticator ("/login.html","/login_fail.html",false));
       fullFunctionSecHandler.setConstraintMappings(new ConstraintMapping[] {webClientCM});
       
       
       ServletContextHandler updateContext= new ServletContextHandler (contexts, "/",true,true);
       updateContext.setSecurityHandler(fullFunctionSecHandler);
       SessionHandler sessionHandler = updateContext.getSessionHandler();
       updateContext.setResourceBase("../www");
       updateContext.setConnectorNames(new String[]{"SSL_CONNECT"});

       updateContext.addServlet("au.com.BI.Servlets.UpdateServlet","/webclient/update");
       updateContext.addServlet("au.com.BI.Servlets.Logout","/webclient/logout");
       
       // forwards handler
       //Context forwardContext = new Context (contexts,"/forwards",Context.SECURITY|Context.SESSIONS);
       updateContext.setAttribute("forwards", forwards);
       ServletHolder forwardServlet = updateContext.addServlet ("au.com.BI.Servlets.RequestForward","/forward/*");
       forwardServlet.setInitParameter ("maxThreads","5");
       forwardServlet.setInitParameter ("maxConnections","5");
       ServletHolder  defServlet = updateContext.addServlet("org.eclipse.jetty.servlet.DefaultServlet","/");
       
       updateContext.setWelcomeFiles(new String[]{"index.html"});
       
       defServlet.setInitParameter("dirAllowed","false");
       defServlet.setInitParameter("aliases", "true");
       defServlet.setInitParameter("serveIcon", "false");
            
      SessionManager updateContextSessionMgr =  sessionHandler.getSessionManager();
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
	}

    protected void addUserManagerContext (HandlerCollection contexts, LoginService webPass) {
        // User manager context 
        
        Constraint constraint = new Constraint();
        constraint.setName(Constraint.__FORM_AUTH);;
        constraint.setRoles(new String[]{"user","admin","integrator"});
        constraint.setAuthenticate(true);


        ConstraintMapping cm = new ConstraintMapping();
        cm.setConstraint(constraint);
        cm.setPathSpec("/Users/*");
        
        IPInRangeHandler usrSecHandler = new IPInRangeHandler();
        usrSecHandler.setIpType(IPType.PWDOnly);
        usrSecHandler.setAuthenticator(new FormAuthenticator ("/login.html","/login_fail.html",false));
        usrSecHandler.setSecurity(security);

        usrSecHandler.setConstraintMappings(new ConstraintMapping[]{cm});
        
        ServletContextHandler userMgrContext = new ServletContextHandler (contexts, "/UserManager",true,true);
        userMgrContext.setSecurityHandler(usrSecHandler);
        userMgrContext.setResourceBase("../www/UserManager");
        userMgrContext.setAttribute("UserManager",webPass);
        userMgrContext.setAttribute("AddressBook",addressBook);
        userMgrContext.setConnectorNames(new String[]{"SSL_CONNECT"});

        ServletHolder useMgrDef = userMgrContext.addServlet("org.eclipse.jetty.servlet.DefaultServlet","/*");
        userMgrContext.addServlet("au.com.BI.Servlets.UserManagerServlet", "/Users");
        userMgrContext.addServlet("au.com.BI.Servlets.LogoutUserManager", "/Logout");
 
        useMgrDef.setInitParameter("welcome","/Users");
        useMgrDef.setInitParameter("aliases", "true");
        useMgrDef.setInitParameter("serveIcon", "false");
        useMgrDef.setInitParameter("redirectWelcome", "false");
        userMgrContext.setSecurityHandler(usrSecHandler);
    
        userMgrContext.setWelcomeFiles(new String[]{"Users","index.html"});
    }
    
    
    public  void start()
    throws Exception {
        // Create the server
    	if (!bootstrap.isJettyActive()){
    		return;
    	}
    	
        
        // HTML Security realm
        HashLoginService  webPass = new BIHashLoginService ("eLife","datafiles/realm.properties");
        webPass.setRefreshInterval(60000);
        try {
        	startHTTPServer (webPass);

        } catch (Exception ex){
            logger.log (Level.WARNING,"Problems starting web server " + ex.getMessage());
            throw ex;
        }

        
        try {
        	startClientProtocolServer (webPass);
        	
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
		forwards.put("/forward/" + src,dest);		
	}

	/**
	 * 
	 */
	public void clearForwards() {
		forwards.clear();
		
	};

}
