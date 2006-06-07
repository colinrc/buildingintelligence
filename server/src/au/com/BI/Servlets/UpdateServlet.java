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

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.http.*;

import au.com.BI.Command.ClientCommandFactory;
import au.com.BI.Command.Command;
import au.com.BI.Config.Security;
import au.com.BI.Config.TooManyClientsException;
import au.com.BI.Flash.ClientCommand;
import au.com.BI.Flash.FlashClientHandler;
import au.com.BI.Home.VersionManager;
import au.com.BI.Jetty.*;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;
import org.jdom.output.XMLOutputter;
import au.com.BI.Messaging.AddressBook;
/**
 *
 * @author colinc
 */
public class UpdateServlet extends HttpServlet {
    CacheBridgeFactory cacheBridgeFactory = null;
    protected XMLOutputter xmlOut = null;
    protected Logger logger;
	SAXBuilder saxb = null;
	AddressBook addressBook = null;
	VersionManager versionManager = null;
	List commandQueue = null;
	
    /** Creates a new instance of UpdateServlet */
    public UpdateServlet() {
        logger = Logger.getLogger(this.getClass().getPackage().getName());
    	xmlOut = new XMLOutputter();
    	saxb = new SAXBuilder(false); // get a SAXBuilder
    }
    
    public void doGet (HttpServletRequest req,
           HttpServletResponse resp) throws ServletException,java.io.IOException {
    	CacheBridge cacheBridge = null;
    	List<Element> extraStuffForStartup = null;
    	
        HttpSession session = req.getSession(false);
        try {
	        if (session == null) {
	            session = req.getSession(true);
	            extraStuffForStartup = setupSession(session);
	        }
	       	cacheBridge = (CacheBridge)session.getAttribute("CacheBridge");
	    	Long ID = (Long)session.getAttribute("ID");
	        long lastUpdate = session.getLastAccessedTime();  
	        
	        resp.setContentType("text/xml");
	
	        java.io.PrintWriter out = resp.getWriter();
	        Element respElement = cacheBridge.getCommands(extraStuffForStartup);
	        xmlOut.output(respElement, out);
	        resp.flushBuffer();
	        resp.setStatus(HttpServletResponse.SC_OK);
        } catch (TooManyClientsException ex){
    		session.invalidate();
			logger.log(Level.WARNING, "Too many clients error " + ex.getMessage());
			resp.setContentType("text/html");
	        
	        java.io.PrintWriter out = resp.getWriter();
	                
	        out.println("<HTML>");
	        out.println("<BODY>");
	        out.println(ex.getMessage());
	        out.println("</BODY>");
	        out.println("</HTML>");
	        resp.flushBuffer();
	        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
        
    }

    
    public void doPost(HttpServletRequest req,
            HttpServletResponse resp) throws ServletException,java.io.IOException {
        HttpSession session = req.getSession(false);  	


        if (session == null) {
    		session.invalidate();
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
			
			ClientCommand  command = clientCommandFactory.processXML(rootElement);
			command.setOriginatingID((Long)session.getAttribute("ID"));

			synchronized (commandQueue){
				commandQueue.add(command);
				commandQueue.notifyAll();
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
    }
		
    
    
    public List<Element> setupSession (HttpSession session) throws TooManyClientsException {
    	Long ID = (Long)session.getCreationTime();
    	session.setAttribute("ID",ID);
    	ServletContext context =  session.getServletContext();
 
    	Security security = (Security)context.getAttribute("Security");
    	Long serverID = (Long)context.getAttribute("ServerID");
    
    	Integer number = (Integer)context.getAttribute("NUMBER_WEB_CLIENTS");
    	if (number == null) number = new Integer(0);
    	synchronized (number){
	    	security.allowWebClient(number);
	    	number++;
	    	context.setAttribute("NUMBER_WEB_CLIENTS",number);
    	}
    	
        AddressBook addressBook = (AddressBook)context.getAttribute("AddressBook");
        
    	ClientCommandFactory clientCommandFactory = new ClientCommandFactory();
    	clientCommandFactory.setAddressBook(addressBook);
    	CacheBridge cacheBridge = cacheBridgeFactory.createCacheBridge(ID);
        session.setAttribute("CacheBridge", cacheBridge);
        session.setAttribute("ClientCommandFactory", clientCommandFactory);
        VersionManager versionManager = (VersionManager)context.getAttribute("VersionManager");
        List<Element> extraStartupElements = newClient (ID,serverID,versionManager);
        return extraStartupElements;
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
    	synchronized (commandQueue){
    		commandQueue.add(initConnection);
    		commandQueue.notifyAll();
    	}
    	
    	return returnList;
    }
    
    public void init (ServletConfig cfg) throws ServletException {
        ServletContext context = cfg.getServletContext();
        cacheBridgeFactory = (CacheBridgeFactory)context.getAttribute("CacheBridgeFactory");
        commandQueue = (List)context.getAttribute("CommandQueue");
        versionManager = (VersionManager)context.getAttribute("VersionManager");
        
        super.init();
    }
    
    public void destory() {
        super.destroy();
    }
    
}
