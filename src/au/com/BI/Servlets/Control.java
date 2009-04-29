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

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;
import org.jdom.output.Format;
import org.jdom.output.XMLOutputter;



/**
 *
 * @author colin
 */
public class Control extends HttpServlet {
    protected Logger logger;
    protected String eSmart_Install = "";
    protected boolean xmlMode = false;
    protected PrintWriter output = null;
	
    /** Creates a new instance of ControlServlet */
    public Control() {
        logger = Logger.getLogger(this.getClass().getPackage().getName());
        

    }
    
    public void init (ServletConfig cfg) throws ServletException {
        ServletContext context = cfg.getServletContext();
        eSmart_Install = (String)context.getAttribute("eSmart_Install");
        
        super.init();
    }
  
    protected  void doGet (HttpServletRequest req,
           HttpServletResponse resp) throws ServletException,java.io.IOException {
		Process p = null;
		boolean commandFound = false;
		int responseCode = HttpServletResponse.SC_OK;
		
        String commandName = req.getParameter("op");
        String respType = req.getParameter("resp");
        if (resp != null && !resp.equals("html")){xmlMode = true;};
		resp.setContentType("text/html");
		output = resp.getWriter();
		if (xmlMode)
		{
			output.println("<HTML>");		
			output.println("<BODY>");
		} else {
			output.println("<RESP>");		
		}
	  	
        if (commandName == null){
        	sendError("Please pass correct operation as op (START|STOP|EXIT|RESTART|CLIENT_RESTART|SELECT");	   	  		
		    responseCode = HttpServletResponse.SC_BAD_REQUEST;
        	
        } else {
			if (commandName.equals ("START")) {
				logger.log (Level.INFO,"Starting eLife service");
				sendMessage("Starting eLife service");
				p = Runtime.getRuntime().exec ("net start eLife");
				displayProcessResults (p);
				commandFound = true;
			}
	
			if (commandName.equals ("STOP")) {
				logger.log (Level.INFO,"Stopping eLife service");
				sendMessage("Stopping eLife service");
				p = Runtime.getRuntime().exec ("net stop eLife");			
				displayProcessResults (p);
				commandFound = true;
			}
	
			if (commandName.equals ("EXIT")) {
				logger.log (Level.INFO,"Stopping monitor service");
				sendMessage("Stopping monitor service");
				commandFound = true;
			}
			
			if (commandName.equals ("RESTART")) {
				logger.log (Level.INFO,"Restarting eLife service");
				sendMessage("Restarting eLife service");
				p = Runtime.getRuntime().exec ("net stop eLife");
				displayProcessResults (p);
				p = Runtime.getRuntime().exec ("net start eLife");
				displayProcessResults (p);
				commandFound = true;
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
				sendMessage("Restarting eLife client");
				p = Runtime.getRuntime().exec ("taskkill /F /IM elife.exe");			
				displayProcessResults (p);
				commandFound = true;
			}
			if (commandName.equals ("GET_STARTUP")) {
				logger.log (Level.INFO,"Fetching current configuration file");
				String startupFile = this.getStartupFile();
				if (xmlMode){
					this.sendMessage(startupFile);
				}else {
					this.sendMessage("Current configuration file is " + startupFile);
				}
				commandFound = true;
			}
			if (commandName.equals ("SELECT")) {
		        String extra = req.getParameter("par")+".xml";
			    if (extra != null && !extra.equals ("") ) {
			        logger.log (Level.FINER,"Setting XML configuration file for startup " + extra);
					commandFound = true;
			        if (!setBootstrapFile (this.eSmart_Install,extra,output)) {
				        String returnString = "Startup file changed : " + extra + "\n";
						logger.log (Level.INFO,returnString);
						sendMessage(returnString);
			        }
				} else {
			        logger.log (Level.WARNING,"Select XML configuration file requested, but no filename was specified in the FILE parameter");
				}
			}
			

	 
        }
        
		if (commandFound == false){
	        logger.log (Level.SEVERE,"No commands were passed to the servlet for execution");
	        sendError("No commands were sent to the servlet for execution");	        
		} else {	
		  	sendMessage("Operation complete");			
		}
	  		
		if (xmlMode)
		{
			output.println("</RESP>");
			
		}else {
			output.println("<P><A HREF='/index.html'>Return to main page</A>");
    	
			output.println("</BODY>");
			output.println("</HTML>");
		}
	    resp.flushBuffer();
	    resp.setStatus(responseCode);
	    
    }    
     
    public void sendError (String message){
		if (xmlMode){
			output.println ("<ERROR>" + message + "<ERROR />" );
		} else {
			output.println ("<P>" + message);			
		}
    	logger.log(Level.SEVERE,message);
    }
    
    public void sendMessage (String message){
		if (xmlMode){
			output.println ("<RESP_LINE>" + message + "<RESP_LINE />" );
		} else {
			output.println ("<P class=\"normal\">" + message);			
		}
    	logger.log(Level.SEVERE,message);
    }
    
	public String getStartupFile () {

    	String startupFile = null;
	try {
		String fileName = eSmart_Install + "/server/datafiles/bootstrap.xml";
		File theFile = new File (fileName);
		
		SAXBuilder saxb = new SAXBuilder(false); 
		Document bootstrap = saxb.build (theFile);
		
		Element topBoot = bootstrap.getRootElement();
		Element bootup = topBoot.getChild("CONFIG_FILE");
		
		startupFile = bootup.getAttributeValue("NAME");
		return startupFile;

			
	} catch (IOException e) {
		sendError ("IO Error writing the file " + e.getMessage());

	} catch (JDOMException e1) {
		sendError ("XML parse error on the bootstrap file " + e1.getMessage());
	}
	return startupFile;
	}


	  public boolean setBootstrapFile (String eSmart_install, String extra,PrintWriter output) {
	    	boolean errorCode = false;
		try {
			String fileName = eSmart_install + "/datafiles/bootstrap.xml";
			File theFile = new File (fileName);
			
			SAXBuilder saxb = new SAXBuilder(false); 
			Document bootstrap = saxb.build (theFile);
			
			Element topBoot = bootstrap.getRootElement();
			Element bootup = topBoot.getChild("CONFIG_FILE");
			bootup.setAttribute("NAME",extra);
			
			File fileToUpload = new File (fileName+".new");
			Document doc = new Document ();
			topBoot.detach();
			doc.setRootElement(topBoot);

			XMLOutputter xmlOut = new XMLOutputter (Format.getPrettyFormat());
			FileWriter out = new FileWriter(fileToUpload);
			xmlOut.output(doc, out) ;
			out.flush();
			out.close();
			logger.log (Level.FINE,"File write succeeded.");
			
			File oldFile = new File (fileName);
			File newName = new File (fileName+".old");
			
			if (oldFile.exists()) {
			    if (newName.exists() && !newName.delete()) {
					sendError ("Could not delete old file "+oldFile.getName());

					errorCode = true;
				    logger.log (Level.SEVERE, "Could not delete old file "+oldFile.getName());
			    }
				if (!oldFile.renameTo (newName)) { 
					sendError ("Could not rename new file "+fileToUpload.getName()+" to " + oldFile.getName());
				    logger.log (Level.SEVERE, "Could not rename old file "+oldFile.getName()+" to " + newName.getName());
					errorCode = true;
				}
			}

			if (!fileToUpload.renameTo(oldFile)) {
				sendError ("Could not rename new file "+fileToUpload.getName()+" to " + oldFile.getName());
			    logger.log (Level.SEVERE, "Could not rename new file "+fileToUpload.getName()+" to " + oldFile.getName());
				errorCode = true;
			}
				    
			File finalName = new File (fileName+".old");
		    if (finalName.exists() && !finalName.delete()) {
				sendError ("Could not delete old file "+finalName.getName());

			    logger.log (Level.SEVERE, "Could not delete old file "+finalName.getName());
				errorCode = true;
		    }
			synchronized (output){
				output.write((byte)0);
				output.flush();
			}

				
		} catch (IOException e) {
			sendError ("IO Error writing the file " + e.getMessage());
			errorCode = true;
		} catch (JDOMException e1) {
			sendError ("XML parse error on the bootstrap file " + e1.getMessage());
			errorCode = true;

		}

	return errorCode;
    }
	
		public void displayProcessResults (Process p) {
			if (p != null ) {
				String s= "";
				BufferedReader stdInput = new BufferedReader (new InputStreamReader (p.getInputStream()));
				//BufferedReader stdError = new BufferedReader (new InputStreamReader (p.getErrorStream()));
				try {
					if (!xmlMode){
						output.println( "<RAW>");
					}
					while ((s = stdInput.readLine()) != null) {
						if (xmlMode){
							output.println("<RESULT>" + s + "<RESULT />");
						} else {
							output.println("<P>" + s);							
						}
					}
					if (!xmlMode){
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
