package au.com.BI.Jetty;

import net.sf.webdav.WebdavServlet;

import org.eclipse.jetty.servlet.DefaultServlet;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;
import org.eclipse.jetty.server.Connector;
import org.eclipse.jetty.server.Server;

import org.eclipse.jetty.server.handler.DefaultHandler;
import org.eclipse.jetty.server.handler.HandlerList;
import org.eclipse.jetty.server.ssl.SslConnector;

import org.eclipse.jetty.http.security.Constraint;
import org.eclipse.jetty.security.ConstraintMapping;
import org.eclipse.jetty.security.ConstraintSecurityHandler;
import org.eclipse.jetty.security.HashLoginService;
import org.eclipse.jetty.security.authentication.BasicAuthenticator;
import org.eclipse.jetty.server.ssl.SslSocketConnector;

//import org.eclipse.jetty.server.handler.*;
import au.com.BI.Admin.*;
import au.com.BI.Comms.HandleBonjour;

import java.util.HashSet;
import java.util.Set;
import java.util.logging.Logger;
import java.util.logging.Level; 

public class JettyHandler {
    boolean SSL = false;
    org.eclipse.jetty.server.Server server = null,client_server = null;
    Logger logger;
    public static final int timeout = 30; // 1 minute timeout for a session;
    protected String webBase = "";
    String datafiles = "";
    String installBase = "";
    HandleBonjour handleBonjour = null;
    
    public JettyHandler(Level debugLevel,String webBase,String datafiles,String installBase,HandleBonjour handleBonjour) {
        logger = Logger.getLogger(this.getClass().getPackage().getName());
        logger.setLevel( debugLevel);
        this.webBase = webBase;
        this.datafiles = datafiles;
        this.installBase = installBase;
        this.handleBonjour = handleBonjour;
    }
    
    
    public  void start(int portNumber,eLife_monitor eLife_mon)
  
    throws Exception {
        // Create the server
        
        try {
        	if (logger.getLevel().intValue() > Level.INFO.intValue()){
            	System.setProperty("DEBUG", "true");
            	System.setProperty("VERBOSE", "true");
        	}
            server = new Server(0);
            
              SslConnector sslConnect = new SslSocketConnector();
            	sslConnect.setPort(portNumber);
            	sslConnect.setKeystore(datafiles + "/keystore");
            	sslConnect.setPassword("building12");
            	sslConnect.setKeyPassword("building12");
              server.setConnectors(new Connector[]{sslConnect});
               
              HashLoginService  webPass = new HashLoginService ("eLife_Monitor",datafiles + "/realm.properties");
              webPass.setRefreshInterval(60000);
              server.addBean(webPass);

              // webdav context security handler
              ConstraintSecurityHandler webDavConstraintSecurityHandler = new ConstraintSecurityHandler();
              Constraint webdavClientConstraint = new Constraint();
              webdavClientConstraint.setAuthenticate(true);
              webdavClientConstraint.setName("eLife webdav");
              webdavClientConstraint.setRoles(new String[]{"admin","integrator"});
              
             ConstraintMapping webdavClientCM = new ConstraintMapping();
             webdavClientCM.setPathSpec("/*");
             webdavClientCM.setConstraint(webdavClientConstraint);
             
             Set<String> webdavUserRoles = new HashSet<String>();
             webdavUserRoles.add("admin");
             webdavUserRoles.add("integrator");
             webDavConstraintSecurityHandler.setConstraintMappings(new ConstraintMapping[]{webdavClientCM},webdavUserRoles);
             webDavConstraintSecurityHandler.setAuthenticator(new BasicAuthenticator());
             webDavConstraintSecurityHandler.setLoginService(webPass);
             webDavConstraintSecurityHandler.setStrict(true);             
              
              // Normal webclient  context security handler
             ConstraintSecurityHandler constraintSecurityHandler = new ConstraintSecurityHandler();
             
             Constraint webClientConstraint = new Constraint();
             webClientConstraint.setAuthenticate(true);
             webClientConstraint.setName("eLife Monitor");
             webClientConstraint.setRoles(new String[]{"admin","integrator"});
             
            ConstraintMapping webClientCM = new ConstraintMapping();
            webClientCM.setPathSpec("/*");
            webClientCM.setConstraint(webClientConstraint);
            
            Set<String> userRoles = new HashSet<String>();
            userRoles.add("admin");
            userRoles.add("integrator");
            constraintSecurityHandler.setConstraintMappings(new ConstraintMapping[]{webClientCM},userRoles);
            constraintSecurityHandler.setAuthenticator(new BasicAuthenticator());
            constraintSecurityHandler.setLoginService(webPass);
            constraintSecurityHandler.setStrict(true);
           
            // Handlers
           	HandlerList handlers = new HandlerList();    

            ServletContextHandler webDavContext= 
            	new ServletContextHandler (handlers, "/webdav",true,true);  
            webDavContext.setAllowNullPathInfo(true);
            ServletHolder davServletHolder = new ServletHolder (new WebdavServlet());   
            davServletHolder.setInitParameter("rootpath", installBase);
            davServletHolder.setInitParameter("ResourceHandlerImplementation","net.sf.webdav.LocalFileSystemStore");
            davServletHolder.setInitParameter("maxUploadSize","2000000"); // 2mb
            davServletHolder.setInitParameter("no-content-length-headers","0");            
            davServletHolder.setInitParameter("lazyFolderCreationOnPut","0");  
            webDavContext.setSecurityHandler(webDavConstraintSecurityHandler);
            webDavContext.addServlet(davServletHolder, "/*");

           	ServletContextHandler updateContext= 
            	new ServletContextHandler (handlers, "/",true,true);         
            updateContext.setAttribute("WebDavContext", webDavContext);
            
            handlers.addHandler(new DefaultHandler());

         
            updateContext.setAttribute("eSmart_Install", installBase);
            updateContext.setAttribute("handleBonjour", handleBonjour);
            updateContext.setAttribute("datafiles", datafiles);
            updateContext.setWelcomeFiles(new String[]{"index.html"});       
            updateContext.addServlet("au.com.BI.Servlets.Control","/control");
            
            
            ServletHolder defServletHold= new ServletHolder(new DefaultServlet());
            updateContext.addServlet(defServletHold,"/");  
            defServletHold.setInitParameter("dirAllowed","false");
            defServletHold.setInitParameter("aliases", "true");
            defServletHold.setInitParameter("serveIcon", "false");
            defServletHold.setInitParameter("resourceBase",webBase);   
            
            updateContext.setSecurityHandler(constraintSecurityHandler);
          
            server.setStopAtShutdown(true);
            constraintSecurityHandler.setHandler(handlers);
            server.setHandler(handlers);
            
            // Start the http server
            server.start ();
            webDavContext.stop(); // stop webdav until it is explicitly started by the integrator
            if (logger.getLevel().intValue() > Level.INFO.intValue()) {
            	System.err.println(server.dump());
            }
            server.join();
        } catch (Exception ex){
            logger.log (Level.WARNING,"Problems starting web server " + ex.getCause());
            throw ex;
        }
    }

}
