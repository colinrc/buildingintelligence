/*
 * Created on Mar 18 2009
 *
 */
package au.com.BI.Admin;
import java.io.*;


import java.util.logging.*;
import java.util.*;
import au.com.BI.Jetty.*;

/**
 * @author Colin Canfield
 *
 **/
public class eLife_monitor
{
	
	public String IPAddress = "";
	public int port = 8082;
	protected Level defaultDebugLevel = Level.ALL;
	protected boolean running = true;
	Logger logger;
	boolean gettingLines = false;
	protected String eSmart_Install;
	protected JettyHandler connection;
	
	
	/**
	 * Sets up the client handling system
	 * @param numberClients An indicative number of clients, 
	 * the actual number may be larger than this
	 */
	public eLife_monitor ( ){
		
		
		logger = Logger.getLogger("eLife_monitor");
		running = true;

		logger.setLevel(defaultDebugLevel);
	    // Read properties file.
	    Properties properties = new Properties();
	    try {
	    		properties.load(this.getClass().getResourceAsStream("my.properties"));
	    } catch (IOException e) {
	    }
	    
	    String portStr = properties.getProperty("port");
	    if (portStr != null) {
	    	try {
	    		port = Integer.parseInt(portStr);
	    	} catch (NumberFormatException ex) {
	    		port = 8082;
	    	}
	    }
	    
	    String major_version = properties.getProperty("major_version");
	    String minor_version = properties.getProperty("minor_version");
	    eSmart_Install = properties.getProperty("eSmart_install");

		System.out.println ("Launching eLife monitor task V" + major_version + "." + 
					minor_version);

		logger.info("Listening for connections on " + port);
		connection = new JettyHandler (this.defaultDebugLevel);
		try {
			connection.start(port,eSmart_Install,this);	
		} catch (Exception e){
			logger.log(Level.SEVERE,"Could not start monitor web server "+ e.getMessage());
		}
	}
	

	
	public static void main(String[] args)
	{
		new eLife_monitor();

	}
}