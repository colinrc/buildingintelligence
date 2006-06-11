package au.com.BI.Jetty;

import au.com.BI.Command.*;
import au.com.BI.Config.Security;
import au.com.BI.Util.BaseModel;
import au.com.BI.Util.ClientModel;
import au.com.BI.Util.DeviceModel;
import org.mortbay.jetty.bio.SocketConnector;
import org.mortbay.jetty.servlet.ServletHolder;
import org.mortbay.jetty.Connector;
import org.mortbay.jetty.Server;
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
//import org.mortbay.jetty.handler.*;
import java.util.List;
import java.util.logging.*;
import org.mortbay.jetty.security.SslSocketConnector;


public class JettyHandler extends BaseModel implements DeviceModel, ClientModel {
    boolean SSL = false;
    CacheBridgeFactory cacheBridgeFactory = null;
    org.mortbay.jetty.Server server = null;
    Logger logger;
    Security security = null;
    
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
    
    public  void start()
    throws Exception {
        // Create the server
    	if (!bootstrap.isJettyActive()){
    		return;
    	}
    	
        try {
            server = new Server();
            // jettyHandler.setSSL(bootstrap.isSSL());
            
            org.mortbay.jetty.bio.SocketConnector connector = new SocketConnector();
            connector.setPort(bootstrap.getJettyPort());
            connector.setMaxIdleTime(50000);

            if (bootstrap.isSSL()){
                SslSocketConnector sslConnect = new SslSocketConnector();
            	sslConnect.setPort(bootstrap.getJettySSLPort());
            	sslConnect.setMaxIdleTime(30000);
            	sslConnect.setKeystore("datafiles/keystore");
            	sslConnect.setPassword("building12");
            	sslConnect.setKeyPassword("building12");
                server.setConnectors(new Connector[]{connector,sslConnect});
            } else {
                server.setConnectors(new Connector[]{connector});           	
            }
            
            

           

            // HTML Security realm

            HashUserRealm webPass = new HashUserRealm();
            webPass.setName("eLife");
            webPass.setConfig("datafiles/realm.properties");
            server.addUserRealm(webPass);

            // Call servlet directly
            ContextHandler updateContextHandler = new ContextHandler ();

            updateContextHandler.setContextPath("/webclient");
            updateContextHandler.setResourceBase("www");

            ServletHandler updateHandler = new ServletHandler ();   
            
            ServletHolder updateServlet = updateHandler.addServletWithMapping("au.com.BI.Servlets.UpdateServlet","/update");
            ServletHolder logoutServlet = updateHandler.addServletWithMapping("au.com.BI.Servlets.Logout","/logout");
            
            SessionHandler sessionHandler = new SessionHandler();
            sessionHandler.setHandler(updateHandler);
            
            updateContextHandler.setHandler(sessionHandler);
            updateContextHandler.setAttribute("CacheBridgeFactory",cacheBridgeFactory);
            updateContextHandler.setAttribute("AddressBook",addressBook);
            updateContextHandler.setAttribute("CommandQueue",commandQueue);
            updateContextHandler.setAttribute("Security",security);
            updateContextHandler.setAttribute("ServerID",new Long (this.getServerID()));
            updateContextHandler.setAttribute("VersionManager",this.getVersionManager());
 
            SecurityHandler servletSec = null;
            
            if (bootstrap.isRequestUserNames()) {
            // Servlet Security config
	            servletSec = new SecurityHandler();
	            servletSec.setServer(server);
	            servletSec.setAuthMethod(Constraint.__BASIC_AUTH);
	            servletSec.setUserRealm(webPass);
	            ConstraintMapping servletConstraintMap = new ConstraintMapping();
	            servletConstraintMap.setPathSpec("/webclient/*");
	            Constraint servletConstraint = new Constraint();
	            servletConstraint.setName("Servlet");
	            servletConstraint.setRoles(new String[]{"user"});
	            servletConstraint.setAuthenticate(true);
	            servletConstraintMap.setConstraint(servletConstraint);
	            servletSec.setConstraintMappings(new ConstraintMapping[] {servletConstraintMap});
	            servletSec.setHandler(updateContextHandler);
	        }
            
            // HTML static handler
            ContextHandler mainContextHandler = new ContextHandler ();
            mainContextHandler.setContextPath("/");
            mainContextHandler.setResourceBase("www");

            ServletHandler servletHandler = new ServletHandler ();         
            ServletHolder defServlet = servletHandler.addServletWithMapping("org.mortbay.jetty.servlet.DefaultServlet","/");
            defServlet.setInitParameter("dirAllowed","false");
            
            mainContextHandler.setHandler(servletHandler);
            
            
            ContextHandlerCollection contexts = new ContextHandlerCollection();
            if (bootstrap.isRequestUserNames()){
            	contexts.setHandlers(new org.mortbay.jetty.Handler[]{servletSec,mainContextHandler});
            } else {
            	contexts.setHandlers(new org.mortbay.jetty.Handler[]{updateContextHandler,mainContextHandler});
            }
    
            HandlerCollection handlers = new HandlerCollection();
            handlers.setHandlers(new org.mortbay.jetty.Handler[]{contexts,new DefaultHandler()});
            
            server.setHandler(handlers);
            server.setStopAtShutdown(true);
            
            // Start the http server
            server.start ();
            //server.join();
        } catch (Exception ex){
            logger.log (Level.WARNING,"Problems starting web server");
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
		// TODO Auto-generated method stub
		
	}
	
    public void attatchComms(List commandQueue) throws au.com.BI.Comms.
    ConnectionFail {};

}
