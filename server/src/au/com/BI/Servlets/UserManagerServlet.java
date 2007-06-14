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

import java.util.*;
import java.io.*;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.http.*;

import au.com.BI.Jetty.*;

import org.jdom.Document;
import org.jdom.Element;

/**
 *
 * @author colinc
 */
public class UserManagerServlet extends HttpServlet {
    protected Logger logger;

	
    /** Creates a new instance of UpdateServlet */
    public UserManagerServlet() {
        logger = Logger.getLogger(this.getClass().getPackage().getName());

    }
    
    public  void doGet (HttpServletRequest req,
           HttpServletResponse resp) throws ServletException,java.io.IOException {
    	Long serverID = null;
        Map  params = req.getParameterMap();
        boolean emptyResponse = true;
        
		resp.setContentType("text/html");
 
		PrintWriter out = resp.getWriter();
		
	    out.println("<HTML>");
	    out.println("<BODY>");
	 
		out.println ("<H1>eLife User Manager </H1>");
		        
        
        displayUsers (out);
        out.println("</BODY>");
       out.println("</HTML>");
        
        resp.flushBuffer();
        resp.setStatus(HttpServletResponse.SC_ACCEPTED);
        return;
        
    }
    
    public void displayUsers (PrintWriter resp) {
    	Properties properties = new Properties();
    	try {
    		properties.load(new FileInputStream("datafiles/realm.properties"));
    		
    	    //  for (Enumeration<String> i = properties.propertyNames() ; i.hasMoreElements() ;) {
 
    	     // }
    		resp.println ("<FORM METHOD=\"POST\" ACTION=\"/UserManager\"");
       		resp.println ("<TABLE>");
       	    		
    	     for (Object i: properties.keySet()){
    	   	        resp.println ("<TR><TD><INPUT TYPE='RADIO' NAME='user' VALUE='" + i + "'><TD>"+(String)i+"</TD></TR>");
   	    	 
    	     }
    	  		resp.println ("</FORM");
    	  	  
    	} catch (IOException ex){
    		logger.log (Level.WARNING,"An exception occured reading the user password file");
    	}
    }

    
    public void doPost(HttpServletRequest req,
            HttpServletResponse resp) throws ServletException,java.io.IOException {
        HttpSession session = req.getSession(false);  	
    }
		   
    
     
    public void destory() {
        super.destroy();
    }
    
}
