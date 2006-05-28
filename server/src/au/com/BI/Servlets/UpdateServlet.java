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
import javax.servlet.http.*;

import au.com.BI.Jetty.*;
/**
 *
 * @author colinc
 */
public class UpdateServlet extends HttpServlet {
    CacheBridgeFactory cacheBridgeFactory = null;
    
    /** Creates a new instance of UpdateServlet */
    public UpdateServlet() {
    }
    
    public void doGet (HttpServletRequest req,
           HttpServletResponse resp) throws ServletException,java.io.IOException {
    	CacheBridge cacheBridge = null;
    	
        HttpSession session = req.getSession(false);
        if (session == null) {
            session = req.getSession(true);
            cacheBridge = cacheBridgeFactory.createCacheBridge(session.getCreationTime());
            session.setAttribute("cacheBridge", cacheBridge);
        } else {
        	cacheBridge = (CacheBridge)session.getAttribute("cacheBridge");
        }
        
        
        resp.setContentType("text/html");

        java.io.PrintWriter out = resp.getWriter();
        cacheBridge.getCommands(out);

        resp.flushBuffer();
        resp.setStatus(HttpServletResponse.SC_OK);
        
        long lastUpdate = session.getLastAccessedTime();
        
 
    }
        
    public void doPost (HttpServletRequest req,
           HttpServletResponse resp) throws ServletException,java.io.IOException {
        resp.setContentType("text/html");
        
        java.io.PrintWriter out = resp.getWriter();
                
        out.println("<HTML>");
        out.println("<BODY>");
        out.println("<P>Test from post");
        out.println("</BODY>");
        out.println("</HTML>");
        resp.flushBuffer();
        resp.setStatus(resp.SC_OK);
    }
    
    public void init (ServletConfig cfg) throws ServletException {
        ServletContext context = cfg.getServletContext();
        cacheBridgeFactory = (CacheBridgeFactory)context.getAttribute("CacheBridgeFactory");
        super.init();
    }
    
    public void destory() {
        super.destroy();
    }
    
}
