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


/**
 *
 * @author colinc
 */
public class Logout extends HttpServlet {
    
    /** Creates a new instance of UpdateServlet */
    public Logout() {
    }
    
    public void doGet (HttpServletRequest req,
           HttpServletResponse resp) throws ServletException,java.io.IOException {
    	
        HttpSession session = req.getSession(false);  	
        
        if (session != null){
        	session.invalidate();
        }
        
        resp.setContentType("text/html");
        
        java.io.PrintWriter out = resp.getWriter();
                
        out.println("<HTML>");
        out.println("<BODY>");
        out.println("<P>You have logged out");
        out.println("</BODY>");
        out.println("</HTML>");
        resp.flushBuffer();
        resp.setStatus(HttpServletResponse.SC_OK);
    }
        
    
    public void init (ServletConfig cfg) throws ServletException {
        super.init();
    }
    
    public void destory() {
        super.destroy();
    }
    
}
