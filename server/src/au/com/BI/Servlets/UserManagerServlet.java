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

import java.io.*;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.http.*;

import au.com.BI.Jetty.BIHashLoginService;


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
    	BIHashLoginService userRealm = (BIHashLoginService)context.getAttribute("UserManager");
		resp.setContentType("text/html");
		
		PrintWriter out = resp.getWriter();
    	displayUsers (out,"",userRealm , req.getRemoteUser(), req.isUserInRole("admin"),req.isUserInRole("integrator"));
        
        resp.flushBuffer();
        resp.setStatus(HttpServletResponse.SC_ACCEPTED);
        return;
        
    }
    
    
    protected void doPost(HttpServletRequest req,
            HttpServletResponse resp) throws ServletException,java.io.IOException {
    	
        HttpSession session = req.getSession(false);  	
        String message = "";
        String[] userType = {""};

    	if (req.isUserInRole(null) || session == null){
       		logger.log (Level.WARNING,"A user attempted to execute the User Manager without being logged in");
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.sendRedirect("/index.html");
            return;
    	}
    	
    	ServletContext context =  session.getServletContext();
    	BIHashLoginService userRealm = (BIHashLoginService)context.getAttribute("UserManager");
    	
    	try {
        		
	        String op = req.getParameter("OP");
	        if (op != null) {
	        	if (op.equals ("Change Password")){
	        		String newPasstxt = req.getParameter ("PWD");
	        		String user = req.getParameter ("USER");
	        		 
        			userType[0] = setUserType(user,req);
        			if (!user.equals(req.getRemoteUser()) && (!req.isUserInRole("admin") && !req.isUserInRole("integrator"))) {
        				message = "Only an admin user or integrator can change the password of a user other than themself";
        			} else {
		        		userRealm.putUser (user,newPasstxt,userType);
		        		message = "Password changed for " + user;
        			}
	        	}
	        	
	        	if (op.equals ("Add User")){
	        		String newPasstxt = req.getParameter ("NEW_PWD");
	        		String user = req.getParameter ("NEW_USER");
	        		userType[0] = setUserType(req.getParameter ("newUserRole"),req);

        			
        			if ((!req.isUserInRole("integrator") && !req.isUserInRole("admin"))){
	        			message = "Only an admin or integrator can add new users";
        			}
        			else {
		        		userRealm.putUser (user,newPasstxt,userType);
		        		message = "User " + user + " added";
        			}
	        	}
	        	
	        	if (op.equals ("Delete User")){
	        		String user = req.getParameter ("USER");
	        		userType[0] = setUserType(user,req);
	        			
        			userRealm.removeUser(user);
	        		message = "User " + user + " deleted";
	        	}

	        }

			displayUsers(resp.getWriter(),message,userRealm, 
					req.getRemoteUser(), req.isUserInRole("admin"),req.isUserInRole("integrator"));
			
    	} catch (Exception ex){
    		logger.log (Level.WARNING,"An exception occured reading or writing the user password file " + ex.getMessage());
    	}
    }
    
	public String setUserType(String reqUserType,HttpServletRequest req) {
		String userType;
		userType = "user";
		
		if (reqUserType.equals ("admin")&& !req.isUserInRole("user") ){
			userType = "admin";
		} 
		if (reqUserType.equals ("integrator") && !req.isUserInRole("user")){
			userType = "integrator";
		} 
		return userType;
	}	
	
    public void displayUsers (PrintWriter resp, String message,BIHashLoginService userRealm,  String currentUser, boolean isAdmin,boolean isIntegrator) {
    		
    	    //  for (Enumeration<String> i = properties.propertyNames() ; i.hasMoreElements() ;) {
 
    	     // }
    		resp.println("<HTML>");
    		// resp.println("<link REL=STYLESHEET HREF=\"/style.css\" TEXT=\"text/css\">");
    		resp.println("<BODY>");
    		resp.println("<CENTER>");    	 
    		resp.println ("<H1>eLife User Manager </H1>");

    		if (!message.equals("")){
        		resp.println ("<P>" + message);
    		}
    		
    		resp.println ("<HR>");
    		
    		resp.println ("<FORM METHOD='POST' ACTION='/UserManager/Users' >");
    		
    		if (isAdmin || isIntegrator) {
	       		resp.println ("<TABLE BORDER='1'>");
	   	        resp.print ("<TR class=\"TableHeader\"><TH> </TH><TH>Name</TH><TH>Role</TH></TR>");
	       	    		
	       		for (String name:userRealm.getUsers().keySet()){
	    	   	        resp.print ("<TR><TD><INPUT TYPE='RADIO' CLASS='radio' NAME='USER' VALUE='" + name + "'></TD><TD>"+name+"</TD>");
	    	   	        resp.println ("</TR>");
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
	 	  		resp.print ("<P>Role: ");
	 	  		resp.print ( "User<INPUT TYPE='radio' NAME='newUserRole' VALUE='user' SELECTED> </INPUT>  ");
	 	  		resp.print ( "Admin<INPUT TYPE='radio' NAME='newUserRole' VALUE='admin'> </INPUT>  ");
	 	  		resp.println ( "Integrator<INPUT TYPE='radio' NAME='newUserRole' VALUE='integrator'> </INPUT>  ");
	 	  		resp.println ("<P><INPUT TYPE=SUBMIT NAME='OP' VALUE='Add User'>");
		  		resp.println ("<HR>");
		  	}
 	  		
   	  		resp.println ("</FORM>");
   	  		
   	  		resp.println("<A HREF='/UserManager/Logout'>Logout</A> of the User Manager.");
    		resp.println("</CENTER>");   
	  		resp.println("</BODY>");
	  		resp.println("</HTML>");
    }    
     
    public void destory() {
        super.destroy();
    }
    
}
