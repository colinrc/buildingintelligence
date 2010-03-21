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
import org.eclipse.jetty.servlet.ServletContextHandler;
import au.com.BI.Admin.BootstrapHandler;


/**
 *
 * @author colin
 */
@SuppressWarnings("serial")
public class Control extends HttpServlet {
    protected Logger logger;
    protected String datafiles = "";
    protected boolean xmlMode = false;
    protected PrintWriter output = null;
    ServletContextHandler webDavContextHandler = null;
	
    protected BootstrapHandler bootstrapHandler;
    
    /** Creates a new instance of ControlServlet */
    public Control() {
        logger = Logger.getLogger(this.getClass().getPackage().getName());
        bootstrapHandler = new BootstrapHandler();

    }
    
    public void init (ServletConfig cfg) throws ServletException {
        ServletContext context = cfg.getServletContext();
        datafiles = (String)context.getAttribute("datafiles");
        webDavContextHandler = (ServletContextHandler)context.getAttribute("WebDavContext");
        super.init();
    }
  
    protected  void doGet (HttpServletRequest req,
           HttpServletResponse resp) throws ServletException,java.io.IOException {
		Process p = null;
		boolean commandFound = false;
		int responseCode = HttpServletResponse.SC_OK;
		
        String commandName = req.getParameter("op");
        String respType = req.getParameter("resp");
        if (respType != null && !respType.equals("html")){xmlMode = true;};
		resp.setContentType("text/html");
		output = resp.getWriter();
		if (xmlMode)
		{
			output.println("<resp>");	
		} else {
			output.println("<HTML>");
			output.println("<link REL=STYLESHEET HREF=\"style.css\" TEXT=\"text/css\">");
			output.println("<BODY>");	
		}
	  	
        if (commandName == null){
        	sendStatus("UNKNOWN_OP","","Please pass correct operation as op (START|STOP|EXIT|RESTART|CLIENT_RESTART|GET_CONFIG|SET_CONFIG|SHARE|SHARE_STOP");	   	  		
		    responseCode = HttpServletResponse.SC_BAD_REQUEST;
        	
        } else {
			if (commandName.equals ("START")) {
				logger.log (Level.INFO,"Starting eLife service");
				commandFound = true;
				sendMessage("Starting eLife service");
				p = Runtime.getRuntime().exec ("net start eLife");
				displayProcessResults (p);
				sendStatus("OK","Starting eLife service","");	
			}
	
			if (commandName.equals ("STOP")) {
				logger.log (Level.INFO,"Stopping eLife service");
				commandFound = true;
				sendMessage("Stopping eLife service");
				p = Runtime.getRuntime().exec ("net stop eLife");			
				displayProcessResults (p);
				sendStatus("OK","Stopping eLife server","");	
			}
	
			if (commandName.equals ("EXIT")) {
				try {
					logger.log (Level.INFO,"Stopping monitor service");
					this.disableWebdav(req);
				} catch  (CommandFail ex){
					sendStatus(ex.getErrorCode(),"",ex.getMessage());						
				}
				if (xmlMode){
					sendStatus("OK","Stopping monitor service","");					
				}else {
					sendMessage("Stopping monitor service");
				}
				System.exit(0);
				commandFound = true;

			}
			
			if (commandName.equals ("RESTART")) {
				logger.log (Level.INFO,"Restarting eLife service");
				commandFound = true;
				sendMessage("Restarting eLife service");
				p = Runtime.getRuntime().exec ("net stop eLife");
				displayProcessResults (p);
				p = Runtime.getRuntime().exec ("net start eLife");
				displayProcessResults (p);
				sendStatus("OK","eLife server restarted","");			
			}
			/*
			if (commandName.equals ("ARBITRARY")) {
			    if (!extra.equals("")){
			        logger.log (Level.FINER,"Running command " + extra);
					output.println("<P>Running command " + extra);
					p = Runtime.getRuntime().exec (extra);
					displayProcessResults (p,output);
					commandFound = true;
			    } else {
					sendError ("Run command requested but no command was specified in the EXTRA field",output);	
				}
			}
			*/
			if (commandName.equals ("CLIENT_RESTART")) {
				logger.log (Level.INFO,"Restarting client service");
				commandFound = true;
				sendMessage("Restarting eLife client");
				p = Runtime.getRuntime().exec ("taskkill /F /IM elife.exe");			
				displayProcessResults (p);
				sendStatus("OK","Client restarted","");	
			}
			if (commandName.equals ("GET_CONFIG")) {
				logger.log (Level.INFO,"Fetching current configuration file");
				commandFound = true;
				try {
					String startupFile = bootstrapHandler.getBootstrapParameter(datafiles,"CONFIG_FILE");
					if (xmlMode){
						this.sendMessage(startupFile);
						sendStatus("OK","Configuration file retrieved","");			
					}else {
						this.sendMessage("Current configuration file is " + startupFile);
					}
				} catch  (CommandFail ex){
					sendStatus(ex.getErrorCode(),"",ex.getMessage());						
				}
			}
			if (commandName.equals ("SET_CONFIG")) {
				commandFound = true;
		        String extra = req.getParameter("filename");
			    if (extra != null && !extra.trim().equals ("") ) {
			    	extra += ".xml";
			        logger.log (Level.FINER,"Setting XML configuration file for startup " + extra);
			    	try {
			    		bootstrapHandler.setBootstrapParameter (datafiles,"CONFIG_FILE",extra);
				        String returnString = "Configuration file changed : " + extra + "\n";
						logger.log (Level.INFO,returnString);
						sendStatus("OK",returnString,"");			
			    	} catch (CommandFail ex) {
						sendStatus(ex.getErrorCode(),"",ex.getMessage());	
			    	}
				} else {
			        logger.log (Level.WARNING,"Set configuration file requested, but no filename was specified in the par parameter");
					sendStatus("MISSING_PARAMTER","","No file pattern was specifed to change the configuration entry to");	
				}
			}
			if (commandName.equals ("GET_NAME")) {
				logger.log (Level.INFO,"Fetching current server name");
				commandFound = true;
				try {
					String serverName = bootstrapHandler.getBootstrapParameter(datafiles,"SERVER_NAME");
					if (serverName == null) serverName = "Uknown";
					if (xmlMode){
						this.sendMessage(serverName);
						sendStatus("OK","Server name retrieved","");			
					}else {
						this.sendMessage("Current sever name file is " + serverName);
					}
				} catch  (CommandFail ex){
					sendStatus(ex.getErrorCode(),"",ex.getMessage());						
				}
			}
			if (commandName.equals ("SET_NAME")) {
				commandFound = true;
		        String extra = req.getParameter("serverName");
			    if (extra != null && !extra.trim().equals ("") ) {
			    	extra += ".xml";
			        logger.log (Level.FINER,"Setting server name " + extra);
			    	try {
			    		bootstrapHandler.setBootstrapParameter (datafiles,"SERVER_NAME",extra);
				        String returnString = "Server name : " + extra + "\n";
						logger.log (Level.INFO,returnString);
						sendStatus("OK",returnString,"");			
			    	} catch (CommandFail ex) {
						sendStatus(ex.getErrorCode(),"",ex.getMessage());	
			    	}
				} else {
			        logger.log (Level.WARNING,"Set server name requested, but no name was specified in the par parameter");
					sendStatus("MISSING_PARAMTER","","No server name was specifed to change the name to");	
				}
			}
			if (commandName.equals ("SHARE")) {
				logger.log (Level.INFO,"Sharing eLife file system");
				commandFound = true;
				try {
					this.enableWebdav(req);
					if (xmlMode){
						sendStatus("OK","File system available through webdav at /dav","");			
					}else {
						this.sendMessage("File system available through webdav at /dav");
					}
				} catch  (CommandFail ex){
					sendStatus(ex.getErrorCode(),"",ex.getMessage());						
				}
			}
			if (commandName.equals ("STOP_SHARE")) {
				logger.log (Level.INFO,"Disabling sharing eLife file system");
				commandFound = true;
				try {
					this.disableWebdav(req);
					if (xmlMode){
						sendStatus("OK","File system disabled from /dav","");			
					}else {
						this.sendMessage("File system disabled at /dav");
					}
				} catch  (CommandFail ex){
					sendStatus(ex.getErrorCode(),"",ex.getMessage());						
				}
			}
			if (commandName.equals ("LOGOUT")) {
				logger.log (Level.INFO,"Logging out of monitor service");
				commandFound = true;
				sendMessage("Logging out of monitor service");
		        HttpSession session = req.getSession(false);  	
		        
		        if (session != null){
		        	session.invalidate();
		        }

				sendStatus("OK","Logged out of monitor","");	
		        resp.sendRedirect("/");

			}
	 
        }
        
		if (commandFound == false){
	        logger.log (Level.SEVERE,"No commands were passed to the servlet for execution");
	        sendStatus("COMMAND_NOT_FOUND","","No commands were sent to the servlet for execution");	        
		}
	  		
		if (xmlMode)
		{
			output.println("</resp>");
			
		}else {
			output.println("<P><A HREF='/index.html'>Return to main page</A>");
    	
			output.println("</BODY>");
			output.println("</HTML>");
		}
	    resp.flushBuffer();
	    resp.setStatus(responseCode);
	    
    }    


	private void enableWebdav(HttpServletRequest req) throws CommandFail{
    	
    	if (webDavContextHandler == null){
    		throw new CommandFail ("WebDav Context was not created");
    	}
    	try {    	
    		webDavContextHandler.start();
    	} catch (Exception ex){
    		throw new CommandFail ("Could not start WebDav context " + ex.getMessage());
    	}
		
	}

    private void disableWebdav(HttpServletRequest req) throws CommandFail{

        if (webDavContextHandler == null){
    		throw new CommandFail ("WebDav Context was not created");
    	}
    	try {    	
    		webDavContextHandler.stop();
    	} catch (Exception ex){
    		throw new CommandFail ("Could not stop WebDav context " + ex.getMessage());
    	}
		
	}


	public void sendMessage (String message){
		if (xmlMode){
			output.println ("  <resp_line>" + message + "<resp_line />" );
		} else {
			output.println ("<P class=\"normal\">" + message);			
		}
    	logger.log(Level.INFO,message);
    }
    
    public void sendStatus (String status,String message,String errorMessage){
		if (xmlMode){
			output.println ("  <status code=\"" + status + "\" msg=\"" + message + "\" error=\"" + errorMessage + "\"/>" );
		} else {
			if (errorMessage.equals("")){
				output.println ("<P class=\"normal\">Status:" + status + " " + message);			
			} else {
				output.println ("<P class=\"normal\">Status:" + status + " " + errorMessage);							
			}
		}
		if (status.equals("OK")){
			logger.log(Level.INFO,message);
		} else {
			logger.log(Level.SEVERE,message);
		}
    }
    
		public void displayProcessResults (Process p) {
			if (p != null ) {
				String s= "";
				BufferedReader stdInput = new BufferedReader (new InputStreamReader (p.getInputStream()));
				//BufferedReader stdError = new BufferedReader (new InputStreamReader (p.getErrorStream()));
				try {
					if (!xmlMode){
						output.println( "<RAW>");
					} else {
						output.println( "  <exec_results>");						
					}
					while ((s = stdInput.readLine()) != null) {
						if (xmlMode){
							output.println("    <result_line>" + s + "<result_line />");
						} else {
							output.println("<P>" + s);							
						}
					}
					if (xmlMode){
						output.println( "  </exec_results>");						
					}else {
						output.println( "</RAW>");
					}
				} catch (IOException e) {

				}
			}
		}
		


    public void destory() {
        super.destroy();
    }
    
}
