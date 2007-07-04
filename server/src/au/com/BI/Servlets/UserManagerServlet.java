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

import au.com.BI.Config.Security;
import au.com.BI.Jetty.*;

import org.jdom.Document;
import org.jdom.Element;
import org.mortbay.jetty.security.UnixCrypt;
import org.mortbay.jetty.security.HashUserRealm;

/**
 *
 * @author colin
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
        boolean emptyResponse = true;
        HttpSession session = req.getSession(true);  
    	ServletContext context =  session.getServletContext();
		HashUserRealm userRealm = (HashUserRealm)context.getAttribute("UserManager");
		resp.setContentType("text/html");
		
		PrintWriter out = resp.getWriter();
    	Properties properties = new Properties();
    	try {
    		properties.load(new FileInputStream("datafiles/realm.properties"));

    		displayUsers (out,"",properties , req.getRemoteUser(), userRealm.isUserInRole(userRealm.getPrincipal(req.getRemoteUser()),"admin"));
    	} catch (IOException ex){
    		logger.log (Level.WARNING,"An exception occured reading the user password file");
    	}
        
        resp.flushBuffer();
        resp.setStatus(HttpServletResponse.SC_ACCEPTED);
        return;
        
    }
    
    
    public void doPost(HttpServletRequest req,
            HttpServletResponse resp) throws ServletException,java.io.IOException {
        HttpSession session = req.getSession(true);  	
        String message = "";
        String userType = "";
        
    	ServletContext context =  session.getServletContext();
		HashUserRealm userRealm = (HashUserRealm)context.getAttribute("UserManager");

		Properties properties = new Properties();
    	try {
    		InputStream inStream = new FileInputStream("datafiles/realm.properties");
    		properties.load(inStream);
    		inStream.close();
    		
	        String op = req.getParameter("OP");
	        if (op != null) {
	        	if (op.equals ("Change Password")){
	        		String newPasstxt = req.getParameter ("PWD");
	        		String user = req.getParameter ("USER");
	        		if (newPasstxt == null || newPasstxt.equals ("") || user == null || user.equals("")){
	        			message = "New password cannot be empty";
	        		} else {
	        			if (user.equals ("admin")){
	        				userType = ",admin";
	        			} else {
	        				userType = ",user";
	        			}
	        				
	        			String rawPwd = "CRYPT:" + UnixCrypt.crypt (newPasstxt, new Date().toString());
		        		String newPwd = rawPwd +userType;
		        		properties.put (user,newPwd);
		        		userRealm.put (user,rawPwd);
		        		userRealm.logout(userRealm.getPrincipal( user));

		        		message = "Password changed for " + user;
	        		}
	        	}
	        	
	        	if (op.equals ("Add User")){
	        		String newPasstxt = req.getParameter ("NEW_PWD");
	        		String user = req.getParameter ("NEW_USER");
        			if (user.equals ("admin")){
        				userType = "admin";
        			} else {
        				userType = "user";
        			}

        			if (newPasstxt == null || newPasstxt.equals ("") || user == null || user.equals("")){
	        			message = "New password and / or user cannot be empty";
	        		} else {
	        			String rawPwd = "CRYPT:" + UnixCrypt.crypt (newPasstxt, new Date().toString());
		        		String newPwd = rawPwd +"," + userType;
		        		
		        		properties.put (user,newPwd);
		        		userRealm.put (user,rawPwd);
		        		userRealm.addUserToRole (user,userType);
		        		userRealm.logout(userRealm.getPrincipal( user));
		        		message = "User " + user + " added";
	        		}
	        	}
	        	
	        	if (op.equals ("Delete User")){
	        		String user = req.getParameter ("USER");
	        		if (user == null || user.equals("")){
	        			message = "User cannot be empty";
	        		} else {
		        		properties.remove (user);
		        		userRealm.disassociate(userRealm.getPrincipal( user));
		        		message = "User " + user + " deleted";
	        		}
	        	}

	        }
	        FileOutputStream outStream = new FileOutputStream("datafiles/realm.properties");
	        properties.store (outStream,null);
    		outStream.close();

			displayUsers(resp.getWriter(),message,properties, 
					req.getRemoteUser(), userRealm.isUserInRole(userRealm.getPrincipal(req.getRemoteUser()),"admin"));
			
    	} catch (IOException ex){
    		logger.log (Level.WARNING,"An exception occured reading or writing the user password file " + ex.getMessage());
    	}
    }
    
    public void displayUsers (PrintWriter resp, String message,Properties properties, String currentUser, boolean isAdmin) {
    		
    	    //  for (Enumeration<String> i = properties.propertyNames() ; i.hasMoreElements() ;) {
 
    	     // }
    		resp.println("<HTML>");
    		resp.println("<BODY>");
    	 
    		resp.println ("<H1>eLife User Manager </H1>");

    		if (!message.equals("")){
        		resp.println ("<P>" + message);
    		}
    		
    		resp.println ("<HR>");
    		
    		resp.println ("<FORM METHOD=\"POST\" ACTION=\"/UserManager\"");
    		
    		if (isAdmin) {
	       		resp.println ("<TABLE>");
	       	    		
	    	     for (Object i: properties.keySet()){
	    	   	        resp.println ("<TR><TD><INPUT TYPE='RADIO' NAME='USER' VALUE='" + i + "'><TD>"+(String)i+"</TD></TR>");
	   	    	 
	    	     }
	 
	       		resp.println ("</TABLE>");
	       		resp.println ("<HR>");
		  		resp.println ("<P>To <BOLD>change password</BOLD> select a user from the list above the enter a new password");	  		
    		} else {
		  		resp.println ("<P>To <BOLD>change password</BOLD> for " + currentUser + " enter a new password");	  		
		  		resp.println ("<INPUT TYPE=HIDDEN NAME='USER' VALUE='" + currentUser + "'>");
    			
    		}
 	  		
 	  		resp.println ("<P>Password: <INPUT NAME='PWD' VALUE=''>");
	  		resp.println ("<INPUT TYPE=SUBMIT NAME='OP' VALUE='Change Password'>");

 	  		resp.println ("<HR>");

 	  		if (isAdmin){
		  		resp.println ("<P>To <BOLD>delete a user<BOLD>, select the user from the list above then  press ");	  		
		  		resp.println ("<INPUT TYPE=SUBMIT NAME='OP' VALUE='Delete User'>");
	
	      	     resp.println ("<HR>");
	  	  		
	 	  		resp.println ("<P>To <BOLD>add a user</BOLD> enter the details below");	  		
	 	  		resp.println ("<P>User: <INPUT NAME='NEW_USER' VALUE=''>");
	 	  		resp.println ("<P>Password: <INPUT NAME='NEW_PWD' VALUE=''>");
	 	  		resp.println ("<INPUT TYPE=SUBMIT NAME='OP' VALUE='Add User'>");
		  		resp.println ("<HR>");
		  	}
 	  		
   	  		resp.println ("</FORM>");

	  		resp.println("</BODY>");
	  		resp.println("</HTML>");
    }    
     
    public void destory() {
        super.destroy();
    }
    
}
