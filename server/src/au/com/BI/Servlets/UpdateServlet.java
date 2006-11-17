/*
 * UpdateServlet.java
 *
 * Created on March 21, 2006, 11:02 PM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package au.com.BI.Servlets;
import javax.servlet.*;

import java.io.PrintWriter;
import java.io.StringReader;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.http.*;

import au.com.BI.Command.ClientCommandFactory;
import au.com.BI.Command.Command;
import au.com.BI.Command.CommandQueue;
import au.com.BI.Command.UnknownCommandException;
import au.com.BI.Config.Security;
import au.com.BI.Config.TooManyClientsException;
import au.com.BI.Flash.ClientCommand;
import au.com.BI.Home.VersionManager;
import au.com.BI.Jetty.*;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;
import org.jdom.output.XMLOutputter;
import au.com.BI.Messaging.AddressBook;
import au.com.BI.Messaging.AddressBook.Locations;
/**
 *
 * @author colinc
 */
public class UpdateServlet extends HttpServlet {
    CacheBridgeFactory cacheBridgeFactory = null;
    protected XMLOutputter xmlOut = null;
    protected Logger logger;

	AddressBook addressBook = null;
	VersionManager versionManager = null;
	CommandQueue commandQueue = null;
	
    /** Creates a new instance of UpdateServlet */
    public UpdateServlet() {
        logger = Logger.getLogger(this.getClass().getPackage().getName());
    	xmlOut = new XMLOutputter();

    }
    
    public  void doGet (HttpServletRequest req,
           HttpServletResponse resp) throws ServletException,java.io.IOException {
    	CacheBridge cacheBridge = null;
    	List<Element> extraStuffForStartup = null;
    	Long ID = null;
    	Long serverID = null;
    	ConcurrentHashMap<Long,LocalSession> localSessions = null;
        HttpSession session = req.getSession(false);
        Map  params = req.getParameterMap();
        boolean emptyResponse = true;
        LocalSession localSession = null;
        
        if (session == null){
        	localSessions = new ConcurrentHashMap<Long,LocalSession>();
            session = req.getSession(true);
            session.setAttribute("LocalSessions", localSessions);
        } else {
        	localSessions = (ConcurrentHashMap<Long,LocalSession>)session.getAttribute("LocalSessions");
        }
        
    	if (params == null){
		        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
		        logger.log (Level.WARNING,"HTTP request contains no parameters ");
		        return;
    	}
        try {
	        if (params != null && params.containsKey("INIT")) {
	            ID = System.currentTimeMillis();
	        	localSession = new LocalSession();
	            setupSession(localSession,ID,session);
	            localSessions.put(ID,localSession);
	            extraStuffForStartup = newClient (ID,localSession.getServerID(),versionManager);
	            emptyResponse = false;
	        } else {
	        	try {
		        	Long  localSessionID = Long.parseLong((String)params.get("SESSION_ID"));
		        	if (localSessionID == null ){
				        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
				        logger.log (Level.WARNING,"Session parameter was not passed to the server");
				        return;
		        	}
		        	
		        	localSession = localSessions.get(localSessionID);
		        	if (localSession == null ){
				        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
				        logger.log (Level.WARNING,"Server get was called before INIT=Y was called");
				        return;
				        // get was called before INIT was called.
		        	}
		        	serverID = localSession.getServerID();
	
			        if (localSession.isHandlingSession()){
						resp.setContentType("text/xml");
				        
				        PrintWriter out = resp.getWriter();
				                
				        Element wrapper = new Element ("a");
				        xmlOut.output(wrapper, out);
				        resp.flushBuffer();
				        resp.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
				        return;
			        }
	        	} catch (NumberFormatException ex) {
			        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			        return;
	        	} catch (NullPointerException ex) {
			        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			        return;
	        	}
		        //setHandlingSession(session,true);
	        }

	       	cacheBridge = localSession.getCacheBridge();
	        
	        resp.setContentType("text/xml");
	
	        java.io.PrintWriter out = resp.getWriter();
	        
	    	Element resultsDoc = new Element("a");
	        if ( cacheBridge.getCommands(extraStuffForStartup,resultsDoc)) {
	        	emptyResponse = false;
	        }
	        xmlOut.output(resultsDoc, out);
	        resp.flushBuffer();
	        if (!emptyResponse){

		        resp.setStatus(HttpServletResponse.SC_OK);
	        } else {
		        resp.setStatus(HttpServletResponse.SC_NO_CONTENT);	        	
	        }
	        localSession.setHandlingSession(false);
        } catch (TooManyClientsException ex){
        	Date currentTime = new Date();
        	

			logger.log(Level.WARNING, "Too many clients error " + ex.getMessage());
			resp.setContentType("text/xml");
	        
	        PrintWriter out = resp.getWriter();
	                
	        Element wrapper = new Element ("a");
	    	Element conElement = new Element("MESSAGE");
	    	conElement.setAttribute("TITLE", "Security");
	    	conElement.setAttribute("ICON", "warning");
	    	conElement.setAttribute("AUTOCLOSE", "45");
	    	conElement.setAttribute("HIDECLOSE", "TRUE");
	    	conElement.setAttribute("TARGET", AddressBook.ALL);
	    	
	    	conElement.setAttribute("CONTENT", ex.getMessage());
	    	wrapper.addContent(conElement);
	        xmlOut.output(wrapper, out);
	    	
	        resp.flushBuffer();
	        resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
    		session.invalidate();
        }
        
    }
    

    public void doPost(HttpServletRequest req,
            HttpServletResponse resp) throws ServletException,java.io.IOException {
        HttpSession session = req.getSession(false);  	

    	ConcurrentHashMap<Long,LocalSession> localSessions = null;
        Map  params = req.getParameterMap();
        boolean emptyResponse = true;
        LocalSession localSession = null;
        
        
    	SAXBuilder saxb = null;
    	saxb = new SAXBuilder(false); // get a SAXBuilder
    	
        if (session == null  ) {
			logger.log(Level.WARNING, "You must GET the current server status before posting new messages");
			resp.setContentType("text/html");
	        
	        java.io.PrintWriter out = resp.getWriter();
	                
	        out.println("<HTML>");
	        out.println("<BODY>");
	        out.println("<P>You must GET the current server status before posting new messages");
	        out.println("</BODY>");
	        out.println("</HTML>");
	        resp.flushBuffer();
	        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
	        return;
        }
        

        Long  localSessionID = null;
        try {
            String jSession = (String)req.getParameter("SESSION_ID");
    		 localSessionID = Long.parseLong(jSession);
    		 localSessions = (ConcurrentHashMap<Long,LocalSession>)session.getAttribute("LocalSessions");
        } catch (NumberFormatException ex){
	        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
	        logger.log (Level.WARNING,"Session parameter was not passed to the server");
	        return;        	
        }catch (NullPointerException  ex){
	        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
	        logger.log (Level.WARNING,"Session parameter was not passed to the server");
	        return;        	
        }
        
        if (localSessionID == null ){
	        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
	        logger.log (Level.WARNING,"Session parameter was not passed to the server");
	        return;
    	}
 
    	localSession = localSessions.get(localSessionID);
    	if (localSession == null ){
	        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
	        logger.log (Level.WARNING,"Server post was called before INIT=Y was called");
	        return;
    	}

    	ClientCommandFactory clientCommandFactory = localSession.getClientCommandFactory();
        String message = req.getParameter("MESSAGE");

        if (message == null) return;

        Document xmlDoc; // xml document object to work with

		if (logger.isLoggable(Level.FINEST)){
			logger.log(Level.FINEST, "Received string " + message + " from client, processing");
		}


		try {
			xmlDoc = saxb.build(new StringReader(message));

			Element rootElement = xmlDoc.getRootElement();
			ClientCommand  command = null;
			if (rootElement != null){
				 command = clientCommandFactory.processXML(rootElement);
			}
	    	if (command != null){
		    	if (localSessionID == null  ){
		    		logger.log(Level.WARNING,"ID was null");
		    		return;
		    	}else {
					command.setOriginatingID(localSessionID);	    		
		    	}
				commandQueue.add(command);

	    	}
			
			resp.setContentType("text/html");
	        java.io.PrintWriter out = resp.getWriter();
	        out.println("<HTML>");
	        out.println("<BODY>");
	        out.println("<P>Post successful");
	        out.println("</BODY>");
	        out.println("</HTML>");
	        resp.flushBuffer();
	        resp.setStatus(HttpServletResponse.SC_OK);
		 
		} catch (JDOMException ex) {
			logger.log(Level.WARNING, "XML ERROR " + ex.getMessage());
			resp.setContentType("text/html");
	        
	        java.io.PrintWriter out = resp.getWriter();
	                
	        out.println("<HTML>");
	        out.println("<BODY>");
	        out.println("XML Error " + ex.getMessage());
	        out.println("</BODY>");
	        out.println("</HTML>");
	        resp.flushBuffer();
	        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
		} 
		catch (UnknownCommandException ex) {
			logger.log(Level.WARNING, "XML ERROR " + ex.getMessage());
			resp.setContentType("text/html");
	        
	        java.io.PrintWriter out = resp.getWriter();
	                
	        out.println("<HTML>");
	        out.println("<BODY>");
	        out.println("Unkown Command Error " + ex.getMessage());
	        out.println("</BODY>");
	        out.println("</HTML>");
	        resp.flushBuffer();
	        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
		} catch (IllegalStateException ex) {
			logger.log(Level.WARNING, "XML ERROR " + ex.getMessage());
			resp.setContentType("text/html");
	        
	        java.io.PrintWriter out = resp.getWriter();
	                
	        out.println("<HTML>");
	        out.println("<BODY>");
	        out.println("<P>XML Error " + ex.getMessage());
	        out.println("</BODY>");
	        out.println("</HTML>");
	        resp.flushBuffer();
	        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
		}  
    }
		
    
    
    public void setupSession (LocalSession localSession, Long ID, HttpSession session) throws TooManyClientsException {
    	localSession.setHandlingSession(true);
    	localSession.setID(ID);

    	ServletContext context =  session.getServletContext();
 
    	Security security = (Security)context.getAttribute("Security");
    	Long serverID = (Long)context.getAttribute("ServerID");
    	localSession.setServerID(serverID);
    	
		SessionCounter sessionCounter = (SessionCounter)context.getAttribute("sessionCounter");
    	int numberClients = sessionCounter.getCurrentSessionCount();
    	if (!security.allowWebClient(numberClients)){
    		throw new TooManyClientsException ("You have requested more clients than you have licenses for, please contact your integrator");
    	}
        AddressBook addressBook = (AddressBook)context.getAttribute("AddressBook");
        
    	ClientCommandFactory clientCommandFactory =  ClientCommandFactory.getInstance();
    	clientCommandFactory.setID(ID);
    	clientCommandFactory.setOriginating_location(Locations.HTTP);
    	clientCommandFactory.setAddressBook(addressBook);
    	CacheBridge cacheBridge = cacheBridgeFactory.createCacheBridge(ID);
        localSession.setCacheBridge(cacheBridge);
        localSession.setClientCommandFactory(clientCommandFactory);
        VersionManager versionManager = (VersionManager)context.getAttribute("VersionManager");

    }
   
    protected List<Element> newClient(Long sessionID,Long serverID,VersionManager versionManager) {
    	// tell the user that they're connected
    	
    	List<Element> returnList = new LinkedList<Element>();
    	
    	String masterVersion = versionManager.getMasterVersion();
    	Element conElement = new Element("connected");
    	
       	conElement.setAttribute("session", sessionID.toString());
        conElement.setAttribute("version", masterVersion);
    	returnList.add(conElement);
    	
    	
    	Command initConnection = new Command();
    	initConnection.setKey("SYSTEM");
    	initConnection.setCommand("ClientAttach");
    	initConnection.setExtraInfo(sessionID.toString());
    	initConnection.setExtra2Info(serverID.toString());
    	commandQueue.add(initConnection);
    	
    	return returnList;
    }
    
    public void init (ServletConfig cfg) throws ServletException {
        ServletContext context = cfg.getServletContext();
        cacheBridgeFactory = (CacheBridgeFactory)context.getAttribute("CacheBridgeFactory");
        commandQueue = (CommandQueue)context.getAttribute("CommandQueue");
        versionManager = (VersionManager)context.getAttribute("VersionManager");
        
        super.init();
    }
    
    public void destory() {
        super.destroy();
    }
    
}
