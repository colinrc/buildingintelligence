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

import org.eclipse.jetty.security.HashLoginService;
import org.eclipse.jetty.http.security.Credential;
import org.eclipse.jetty.http.security.UnixCrypt;


/**
 *
 * @author colin
 */
@SuppressWarnings("serial")
public class UserManagerServlet extends HttpServlet {
    protected Logger logger;

	
    /** Creates a new instance of UpdateServlet */
    public UserManagerServlet() {
        logger = Logger.getLogger(this.getClass().getPackage().getName());

    }
  
    protected  void doGet (HttpServletRequest req,
           HttpServletResponse resp) throws ServletException,java.io.IOException {

        HttpSession session = req.getSession(true);  
    	if (req.isUserInRole(null) || session == null){
       		logger.log (Level.WARNING,"A user attempted to execute the User Manager without being logged in");
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.sendRedirect("/index.html");
            return;
    	}
    	
    	ServletContext context =  session.getServletContext();
    	HashLoginService userRealm = (HashLoginService)context.getAttribute("UserManager");
		resp.setContentType("text/html");
		
		PrintWriter out = resp.getWriter();
    	Properties properties = new Properties();

    	try {
    		properties.load(new FileInputStream("datafiles/realm.properties"));

    		displayUsers (out,"",userRealm , req.getRemoteUser(), req.isUserInRole("admin"),req.isUserInRole("integrator"));
    	} catch (IOException ex){
    		logger.log (Level.WARNING,"An exception occured reading the user password file");
    	}
        
        resp.flushBuffer();
        resp.setStatus(HttpServletResponse.SC_ACCEPTED);
        return;
        
    }
    
    
    protected void doPost(HttpServletRequest req,
            HttpServletResponse resp) throws ServletException,java.io.IOException {
    	
        HttpSession session = req.getSession(false);  	
        String message = "";
        String[] userType = {""};
        
    	ServletContext context =  session.getServletContext();
    	HashLoginService userRealm = (HashLoginService)context.getAttribute("UserManager");

    	if (req.isUserInRole(null) || session == null){
       		logger.log (Level.WARNING,"A user attempted to execute the User Manager without being logged in");
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.sendRedirect("/index.html");
            return;
    	}
    	
    	try {
        	Properties properties = new Properties();
       		properties.load(new FileInputStream("datafiles/realm.properties"));
        		
	        String op = req.getParameter("OP");
	        if (op != null) {
	        	if (op.equals ("Change Password")){
	        		String newPasstxt = req.getParameter ("PWD");
	        		String user = req.getParameter ("USER");
	        		
        			userType[0] = setUserType(user,req);
        			if (userType[0].equals ("admin") && (!req.isUserInRole("admin") && !req.isUserInRole("integrator"))) {
        				message = "Only an admin user or integrator can change the password of this user";
        			}
        			if (userType[0].equals ("integrator") && !req.isUserInRole("integrator")) {
        				message = "Only an integrator can change the password of an integrator";
        			}	
        			if (!message.equals("")){
		        		if (newPasstxt == null || newPasstxt.equals ("") || user == null || user.equals("")){
		        			message = "New password cannot be empty";
		        		} else {
		        				
		        			String rawPwd = "CRYPT:" + UnixCrypt.crypt (newPasstxt, new Date().toString());
			        		String newPwd = rawPwd +userType;
			        		properties.put (user,newPwd);
			        		userRealm.putUser (user,Credential.getCredential(rawPwd),userType);
	
			        		message = "Password changed for " + user;
		        		}
        			}
	        	}
	        	
	        	if (op.equals ("Add User")){
	        		String newPasstxt = req.getParameter ("NEW_PWD");
	        		String user = req.getParameter ("NEW_USER");
        			userType[0] = setUserType(user,req);
        			
        			if ((!req.isUserInRole("integrator") && !req.isUserInRole("admin"))){
	        			message = "Only an integrator or admin user can add new users";
        			}
        			else {
	
	        			if ( newPasstxt == null || newPasstxt.equals ("") || user == null || user.equals("")){
		        			message = "New password and / or user cannot be empty";
		        		} else {
		        			String rawPwd = "CRYPT:" + UnixCrypt.crypt (newPasstxt, new Date().toString());
			        		String newPwd = rawPwd +"," + userType;
			        		
			        		properties.put (user,newPwd);
			        		userRealm.putUser (user,Credential.getCredential(rawPwd),userType);
			        		//userRealm.addUserToRole (user,userType);
			        		message = "User " + user + " added";
		        		}
        			}
	        	}
	        	
	        	if (op.equals ("Delete User")){
	        		String user = req.getParameter ("USER");
	        		userType[0] = setUserType(user,req);
	        			
	        		if (user == null || user.equals("")){
	        			message = "User cannot be empty";
	        		} else {
		        		properties.remove (user);
		        		//userRealm.disassociate(userRealm.getPrincipal( user));
	        			userRealm.removeUser(user);
		        		message = "User " + user + " deleted";
	        		}
	        	}

	        }
	        //FileOutputStream outStream = new FileOutputStream("datafiles/realm.properties");
	        //properties.store (outStream,null);
    		//outStream.close();

			displayUsers(resp.getWriter(),message,userRealm, 
					req.getRemoteUser(), req.isUserInRole("admin"),req.isUserInRole("integrator"));
			
    	} catch (IOException ex){
    		logger.log (Level.WARNING,"An exception occured reading or writing the user password file " + ex.getMessage());
    	}
    }
    
	public String setUserType(String reqUserType,HttpServletRequest req) {
		String userType;
		userType = "user";
		
		if (reqUserType.equals ("admin")&& (req.isUserInRole("integrator") || req.isUserInRole("admin"))){
			userType = "admin";
		} 
		if (reqUserType.equals ("integrator") && req.isUserInRole("integrator")){
			userType = "integrator";
		} 
		return userType;
	}	
	
    public void displayUsers (PrintWriter resp, String message,HashLoginService userRealm,  String currentUser, boolean isAdmin,boolean isIntegrator) {
    		
    	    //  for (Enumeration<String> i = properties.propertyNames() ; i.hasMoreElements() ;) {
 
    	     // }
    		resp.println("<HTML>");
    		resp.println("<link REL=STYLESHEET HREF=\"/style.css\" TEXT=\"text/css\">");
    		resp.println("<BODY>");
    	 
    		resp.println ("<H1>eLife User Manager </H1>");

    		if (!message.equals("")){
        		resp.println ("<P>" + message);
    		}
    		
    		resp.println ("<HR>");
    		
    		resp.println ("<FORM METHOD='POST' ACTION='/UserManager/Users' >");
    		
    		if (isAdmin || isIntegrator) {
	       		resp.println ("<TABLE>");
	       	    		
	       		for (String name:userRealm.getUsers().keySet()){
	    	   	        resp.println ("<TR><TD><INPUT TYPE='RADIO' NAME='USER' VALUE='" + name + "'><TD>"+name+"</TD></TR>");
	   	    	 
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

 	  		if (isAdmin || isIntegrator){
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
   	  		
   	  		resp.println("<A HREF='/UserManager/Logout'>Logout</A> of the User Manager.");

	  		resp.println("</BODY>");
	  		resp.println("</HTML>");
    }    
     
    public void destory() {
        super.destroy();
    }
    
}
