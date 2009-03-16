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

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;
import org.jdom.output.Format;
import org.jdom.output.XMLOutputter;

import au.com.BI.Jetty.*;


/**
 *
 * @author colin
 */
public class Control extends HttpServlet {
    protected Logger logger;

	
    /** Creates a new instance of ControlServlet */
    public Control() {
        logger = Logger.getLogger(this.getClass().getPackage().getName());

    }
  
    protected  void doGet (HttpServletRequest req,
           HttpServletResponse resp) throws ServletException,java.io.IOException {
		Process p = null;
		boolean abort = false;
		boolean commandFound = false;
		int responseCode = HttpServletResponse.SC_OK;
		
    	HttpSession session = req.getSession(true);  

        ServletContext context =  session.getServletContext();
        String commandName = req.getParameter("OP");
		resp.setContentType("text/html");
		PrintWriter output = resp.getWriter();
		output.println("<HTML>");		
		output.println("<BODY>");
	  	
        if (commandName == null){
        	output.println("<P>Please pass correct operation as OP");
	   	  		
		    responseCode = HttpServletResponse.SC_BAD_REQUEST;
        	
        } else {
			if (commandName.equals ("START")) {
				logger.log (Level.INFO,"Starting eLife service");
				output.println("<P>Starting eLife service");
				p = Runtime.getRuntime().exec ("net start eLife");
				displayProcessResults (p,output);
				commandFound = true;
			}
	
			if (commandName.equals ("STOP")) {
				logger.log (Level.INFO,"Stopping eLife service");
				output.println("<P>Stopping eLife service");
				p = Runtime.getRuntime().exec ("net stop eLife");			
				displayProcessResults (p,output);
				commandFound = true;
			}
	
			if (commandName.equals ("EXIT")) {
				logger.log (Level.INFO,"Stopping monitor service");
				output.println("<P>Stopping monitor service");
				abort = true;
				commandFound = true;
			}
			
			if (commandName.equals ("RESTART")) {
				logger.log (Level.INFO,"Restarting eLife service");
				output.println("<P>Restarting eLife service");
				p = Runtime.getRuntime().exec ("net stop eLife");
				displayProcessResults (p,output);
				p = Runtime.getRuntime().exec ("net start eLife");
				displayProcessResults (p,output);
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
				output.println("<P>Restarting eLife client");
				p = Runtime.getRuntime().exec ("taskkill /F /IM elife.exe");			
				displayProcessResults (p,output);
				commandFound = true;
			}
			if (commandName.equals ("SELECT")) {
			    if (!extra.equals ("") ) {
			        logger.log (Level.FINER,"Setting XML configuration file for startup " + extra);
					commandFound = true;
			        if (!setBootstrapFile (this.eSmart_install,extra,output)) {
				        String returnString = "<SELECT>Startup file changed : " + extra + "</SELECT>\n";
						synchronized (output){ 
							output.write (returnString.getBytes());
						}
			        }
				} else {
			        logger.log (Level.WARNING,"Select XML configuration file requested, but no filename was specified in the FILE parameter");
				}
			}
	 
        }
        
	    
	  	output.println("<P>Operation complete");
	  		
    	output.println("<P><A HREF='/index.html'>Return to main page</A>");
    	
    	output.println("</BODY>");
    	output.println("</HTML>");
	    resp.flushBuffer();
	    resp.setStatus(responseCode);
	    
    }    
     
	public String getStartupFile (String eSmart_install, OutputStream output) {
    	boolean errorCode = false;

    	String startupFile = null;
	try {
		String fileName = eSmart_install + "/server/datafiles/bootstrap.xml";
		File theFile = new File (fileName);
		
		SAXBuilder saxb = new SAXBuilder(false); 
		Document bootstrap = saxb.build (theFile);
		
		Element topBoot = bootstrap.getRootElement();
		Element bootup = topBoot.getChild("CONFIG_FILE");
		
		startupFile = bootup.getAttributeValue("NAME");
		
			
	} catch (IOException e) {
		sendError ("IO Error writing the file " + e.getMessage(),output);

	} catch (JDOMException e1) {
		sendError ("XML parse error on the bootstrap file " + e1.getMessage(),output);
	}


	  public boolean setBootstrapFile (String eSmart_install, String extra,OutputStream output) {
	    	boolean errorCode = false;
		try {
			String fileName = eSmart_install + "/server/datafiles/bootstrap.xml";
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
					sendError ("Could not delete old file "+oldFile.getName(),output);

					errorCode = true;
				    logger.log (Level.SEVERE, "Could not delete old file "+oldFile.getName());
			    }
				if (!oldFile.renameTo (newName)) { 
					sendError ("Could not rename new file "+fileToUpload.getName()+" to " + oldFile.getName(),output);
				    logger.log (Level.SEVERE, "Could not rename old file "+oldFile.getName()+" to " + newName.getName());
					errorCode = true;
				}
			}

			if (!fileToUpload.renameTo(oldFile)) {
				sendError ("Could not rename new file "+fileToUpload.getName()+" to " + oldFile.getName(),output);
			    logger.log (Level.SEVERE, "Could not rename new file "+fileToUpload.getName()+" to " + oldFile.getName());
				errorCode = true;
			}
				    
			File finalName = new File (fileName+".old");
		    if (finalName.exists() && !finalName.delete()) {
				sendError ("Could not delete old file "+finalName.getName(),output);

			    logger.log (Level.SEVERE, "Could not delete old file "+finalName.getName());
				errorCode = true;
		    }
			synchronized (output){
				output.write((byte)0);
				output.flush();
			}

				
		} catch (IOException e) {
			sendError ("IO Error writing the file " + e.getMessage(),output);
			errorCode = true;
		} catch (JDOMException e1) {
			sendError ("XML parse error on the bootstrap file " + e1.getMessage(),output);
			errorCode = true;

		}

	return startupFile;
    }
	
		public void displayProcessResults (Process p, PrintWriter output) {
			if (p != null ) {
				String s= "";
				BufferedReader stdInput = new BufferedReader (new InputStreamReader (p.getInputStream()));
				BufferedReader stdError = new BufferedReader (new InputStreamReader (p.getErrorStream()));
				try {
					output.println( "<RAW>");
					while ((s = stdInput.readLine()) != null) {
						output.println(  s);
					}
					output.println( "</RAW>");
				} catch (IOException e) {

				}
			}
		}
		
	  public boolean setBootstrapFile (String eSmart_install, String extra,OutputStream output) {
	    	boolean errorCode = false;
		try {
			String fileName = eSmart_install + "/server/datafiles/bootstrap.xml";
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
					sendError ("Could not delete old file "+oldFile.getName(),output);

					errorCode = true;
				    logger.log (Level.SEVERE, "Could not delete old file "+oldFile.getName());
			    }
				if (!oldFile.renameTo (newName)) { 
					sendError ("Could not rename new file "+fileToUpload.getName()+" to " + oldFile.getName(),output);
				    logger.log (Level.SEVERE, "Could not rename old file "+oldFile.getName()+" to " + newName.getName());
					errorCode = true;
				}
			}

			if (!fileToUpload.renameTo(oldFile)) {
				sendError ("Could not rename new file "+fileToUpload.getName()+" to " + oldFile.getName(),output);
			    logger.log (Level.SEVERE, "Could not rename new file "+fileToUpload.getName()+" to " + oldFile.getName());
				errorCode = true;
			}
				    
			File finalName = new File (fileName+".old");
		    if (finalName.exists() && !finalName.delete()) {
				sendError ("Could not delete old file "+finalName.getName(),output);

			    logger.log (Level.SEVERE, "Could not delete old file "+finalName.getName());
				errorCode = true;
		    }
			synchronized (output){
				output.write((byte)0);
				output.flush();
			}

				
		} catch (IOException e) {
			sendError ("IO Error writing the file " + e.getMessage(),output);
			errorCode = true;
		} catch (JDOMException e1) {
			sendError ("XML parse error on the bootstrap file " + e1.getMessage(),output);
			errorCode = true;

		}

    public void destory() {
        super.destroy();
    }
    
}
