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


import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.http.*;

import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandQueue;
import au.com.BI.Flash.ClientCommand;
import au.com.BI.Home.VersionManager;
import au.com.BI.Jetty.*;

/**
 *
 * @author colinc
 */
public class PostUpdateServlet extends HttpServlet {
    CacheBridgeFactory cacheBridgeFactory = null;
    protected Logger logger;
    int MaxTimeOut= 30; // 360 seconds of inactivity before sessions are invalidated.

	VersionManager versionManager = null;
	CommandQueue commandQueue = null;
	Cache cache = null;
	Long serverID = null;
	
    /** Creates a new instance of UpdateServlet */
    public PostUpdateServlet() {
        logger = Logger.getLogger(this.getClass().getPackage().getName());

    }
    
    public  void doGet (HttpServletRequest req,
           HttpServletResponse resp) throws ServletException,java.io.IOException {

    	Long ID = null;

        String command = req.getParameter("co");
        String displayName = req.getParameter("ds");
        String extra = req.getParameter("ex");
        String extra2 = req.getParameter("ex2");
        String extra3 = req.getParameter("ex3");
        String extra4 = req.getParameter("ex4");
        String extra5 = req.getParameter("ex5");
                                           
        if (extra5 == null) extra5 = "";
        if (extra4 == null) extra4 = "";
        if (extra3 == null) extra3 = "";
        if (extra2 == null) extra2 = "";
        if (extra == null) extra = "";
	        
        resp.setContentType("text/xml");
	
        java.io.PrintWriter out = resp.getWriter();

        String message = req.getParameter("MESSAGE");

        if (command == null || command.equals("")){
	        out.println("<HTML><BODY>");
	        out.println("No Command field present ");
	        out.println("</BODY></HTML>");
	        resp.flushBuffer();
	        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);

        	return;
        }
        
        if (displayName == null || displayName.equals("")){
	        out.println("<HTML><BODY>");
	        out.println("No display name present ");
	        out.println("</BODY></HTML>");
	        resp.flushBuffer();
	        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);

        	return;
        }
        
		if (logger.isLoggable(Level.FINEST)){
			logger.log(Level.FINEST, "Received string " + message + " from client, processing");
		}
		ClientCommand receivedCommand = new ClientCommand();
		receivedCommand.setDisplayName(displayName);
		receivedCommand.setKey(displayName);
		receivedCommand.setCommand(command);
		receivedCommand.setExtraInfo(extra);
		receivedCommand.setExtra2Info(extra2);
		receivedCommand.setExtra3Info(extra3);
		receivedCommand.setExtra4Info(extra4);
		receivedCommand.setExtra5Info(extra5);
		receivedCommand.setTargetDeviceID(0);
		
        cache.setCachedCommand(receivedCommand.getDisplayName(), receivedCommand);
        commandQueue.add(receivedCommand);
        
        out.println("<HTML><BODY>");
        out.println("Post successful");
        out.println("</BODY></HTML>");
        resp.flushBuffer();
        resp.setStatus(HttpServletResponse.SC_OK);

        
        return;
    }
		
    public void init (ServletConfig cfg) throws ServletException {
        ServletContext context = cfg.getServletContext();
        cacheBridgeFactory = (CacheBridgeFactory)context.getAttribute("CacheBridgeFactory");
        cache = (Cache)context.getAttribute("Cache");
        commandQueue = (CommandQueue)context.getAttribute("CommandQueue");
        versionManager = (VersionManager)context.getAttribute("VersionManager");
        serverID = (Long)context.getAttribute("ServerID");
        
        super.init();
    }
    
    public void destory() {
        super.destroy();
    }
    
}
