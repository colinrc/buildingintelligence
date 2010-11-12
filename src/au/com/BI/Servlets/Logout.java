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

import au.com.BI.Command.ClientCommandFactory;
import au.com.BI.Command.CommandQueue;
import au.com.BI.Flash.ClientCommand;
import au.com.BI.Jetty.CacheBridgeFactory;
import au.com.BI.Messaging.AddressBook;


/**
 *
 * @author colinc
 */
@SuppressWarnings("serial")
public class Logout extends HttpServlet {
    CacheBridgeFactory cacheBridgeFactory = null;
    AddressBook  addressBook = null;

	CommandQueue commandQueue = null;
	
    /** Creates a new instance of UpdateServlet */
    public Logout() {
    }
    
    public void doGet (HttpServletRequest req,
           HttpServletResponse resp) throws ServletException,java.io.IOException {
    	
        HttpSession session = req.getSession(false);  	
        
        if (session != null){
        	
        	Long ID = (Long)session.getAttribute("ID");
        	ClientCommandFactory clientCommandFactory = (ClientCommandFactory)session.getAttribute("ClientCommandFactory");

        	session.invalidate();
        	if (clientCommandFactory != null && ID != null && commandQueue  != null && addressBook != null){
            	clientCommandFactory.setID(ID);
			    	addressBook.removeByID(ID);
					ClientCommand clientCommand = clientCommandFactory.buildListNamesCommand();
					if (clientCommand != null) {
						commandQueue.add(clientCommand);
					}			    	
        	}
        }
        
        resp.sendRedirect("/UserManager");

    }
        
    
    public void init (ServletConfig cfg) throws ServletException {
        ServletContext context = cfg.getServletContext();
        cacheBridgeFactory = (CacheBridgeFactory)context.getAttribute("CacheBridgeFactory");
        commandQueue = (CommandQueue)context.getAttribute("CommandQueue");
         addressBook = (AddressBook)context.getAttribute("AddressBook");
        super.init();
    }
    
    public void destory() {
        super.destroy();
    }
    
}
