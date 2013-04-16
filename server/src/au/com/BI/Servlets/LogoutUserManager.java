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
public class LogoutUserManager extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = -2658662832271967029L;

	/** Creates a new instance of UpdateServlet */
    public LogoutUserManager() {
    }
    
    public void doGet (HttpServletRequest req,
           HttpServletResponse resp) throws ServletException,java.io.IOException {
    	

       	req.getSession().invalidate();
        
        resp.sendRedirect("/UserManager/Users");
    }
        
    
    
}
