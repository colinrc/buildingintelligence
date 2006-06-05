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
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.http.*;

import au.com.BI.Command.ClientCommandFactory;
import au.com.BI.Config.Security;
import au.com.BI.Config.TooManyClientsException;
import au.com.BI.Flash.ClientCommand;
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
	SAXBuilder saxb;
	AddressBook addressBook = null;

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
    	
        HttpSession session = req.getSession(false);
        try {
	        if (session == null) {
	            session = req.getSession(true);
	            setupSession(session);
	        }
	       	cacheBridge = (CacheBridge)session.getAttribute("CacheBridge");
	    	Long ID = (Long)session.getAttribute("ID");
	        long lastUpdate = session.getLastAccessedTime();  
	        
	        resp.setContentType("text/xml");
	
	        java.io.PrintWriter out = resp.getWriter();
	        Element respElement = cacheBridge.getCommands();
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
    	try {

	        if (session == null) {
	            session = req.getSession(true);
	            setupSession(session);
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
		
    
    
    public boolean setupSession (HttpSession session) throws TooManyClientsException {
    	Long ID = (Long)session.getCreationTime();
    	session.setAttribute("ID",ID);
    	ServletContext context =  session.getServletContext();
 
    	Security security = (Security)context.getAttribute("Security");
    
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
        return true;
    }
    
    
    public void init (ServletConfig cfg) throws ServletException {
        ServletContext context = cfg.getServletContext();
        cacheBridgeFactory = (CacheBridgeFactory)context.getAttribute("CacheBridgeFactory");
        commandQueue = (List)context.getAttribute("CommandQueue");
        super.init();
    }
    
    public void destory() {
        super.destroy();
    }
    
}
