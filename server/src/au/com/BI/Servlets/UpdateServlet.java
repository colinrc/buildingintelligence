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
    	
        HttpSession session = req.getSession(false);
        Map  params = req.getParameterMap();
        boolean emptyResponse = true;
        
        try {
	        if (params != null && (session == null || params.containsKey("INIT"))) {
	            session = req.getSession(true);
	            setHandlingSession(session,true);
	            setupSession(session);
	            ID = (Long)session.getAttribute("ID");
	            serverID = (Long)session.getAttribute("ServerID");
	            extraStuffForStartup = newClient (ID,serverID,versionManager);
	            emptyResponse = false;
	        } else {
	        	ID = (Long)session.getAttribute("ID");
	        	serverID = (Long)session.getAttribute("ServerID");

		        if (isHandlingSession(session)){
					resp.setContentType("text/xml");
			        
			        PrintWriter out = resp.getWriter();
			                
			        Element wrapper = new Element ("a");
	
			        xmlOut.output(wrapper, out);
			    	
			        resp.flushBuffer();
			        resp.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
			        return;
		        }
		        setHandlingSession(session,true);
	        }

	       	cacheBridge = (CacheBridge)session.getAttribute("CacheBridge");
	        long lastUpdate = session.getLastAccessedTime();  
	        
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
	        setHandlingSession(session,false);
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
    
    public void setHandlingSession(HttpSession session , boolean handling) {
    	Boolean handlingVal = new Boolean (handling);
    	session.setAttribute("Lock", handlingVal);
    }
    
    public boolean isHandlingSession(HttpSession session ) {
    	Boolean handlingVal = (Boolean)session.getAttribute("Lock");
    	return handlingVal.booleanValue();
    }

    public void doPost(HttpServletRequest req,
            HttpServletResponse resp) throws ServletException,java.io.IOException {
        HttpSession session = req.getSession(false);  	

    	SAXBuilder saxb = null;
    	saxb = new SAXBuilder(false); // get a SAXBuilder
    	
        if (session == null) {
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

    	Long ID = (Long)session.getAttribute("ID");

    	ClientCommandFactory clientCommandFactory = (ClientCommandFactory)session.getAttribute("ClientCommandFactory");
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
		    	if (ID == null  ){
		    		logger.log(Level.WARNING,"ID was null");
		    		return;
		    	}else {
					command.setOriginatingID(ID);	    		
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
	        out.println("XML Error " + ex.getMessage());
	        out.println("</BODY>");
	        out.println("</HTML>");
	        resp.flushBuffer();
	        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
		}  
    }
		
    
    
    public void setupSession (HttpSession session) throws TooManyClientsException {
    	Long ID = (Long)session.getCreationTime();
    	session.setAttribute("ID",ID);
    	ServletContext context =  session.getServletContext();
 
    	Security security = (Security)context.getAttribute("Security");
    	Long serverID = (Long)context.getAttribute("ServerID");
    	session.setAttribute("ServerID",serverID);
    	
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
        session.setAttribute("CacheBridge", cacheBridge);
        session.setAttribute("ClientCommandFactory", clientCommandFactory);
        VersionManager versionManager = (VersionManager)context.getAttribute("VersionManager");

    }
   
    protected List<Element> newClient(Long sessionID,Long serverID,VersionManager versionManager) {
    	// tell the user that they're connected
    	
    	List<Element> returnList = new LinkedList<Element>();
    	
    	String masterVersion = versionManager.getMasterVersion();
    	Element conElement = new Element("connected");
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
