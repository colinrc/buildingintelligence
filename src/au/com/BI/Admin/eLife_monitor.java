/*
 * Created on Mar 18 2009
 *
 */
package au.com.BI.Admin;
import java.io.*;


import java.util.logging.*;
import java.util.*;

import com.apple.dnssd.DNSSDException;

import au.com.BI.Comms.HandleBonjour;
import au.com.BI.Jetty.*;
import au.com.BI.Servlets.CommandFail;

/**
 * @author Colin Canfield
 *
 **/
public class eLife_monitor
{
	
	public String IPAddress = "";
	public int port = 8082;
	protected Level defaultDebugLevel = Level.INFO;
	protected boolean running = true;
	Logger logger;
	boolean gettingLines = false;
	protected String eSmart_Install;
	protected String webRoot;
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
	    String read_eSmart_Install = properties.getProperty("eSmart_install");
	    String webBase = properties.getProperty("web_base");
	    String datafiles = properties.getProperty("datafiles");
	    	    
	    eSmart_Install = System.getProperty("eSmart_install",read_eSmart_Install);
	    String monitor_web = System.getProperty("monitor_web",webBase);
	    String datafilesLoc = System.getProperty("datafiles",datafiles);

		System.out.println ("Launching eLife monitor task V" + major_version + "." + 
					minor_version);

		BootstrapHandler bootstrapHandler = new BootstrapHandler();
		HandleBonjour handleBonjour = new HandleBonjour(Level.INFO,port);
		
		String serverName = "Unknown";
		try {
			serverName = bootstrapHandler.getBootstrapParameter(datafiles,"SERVER_NAME");
			
		} catch  (CommandFail ex){
			logger.log(Level.FINEST,"Could not read initial server name");
		} 

		try {
			handleBonjour.startBonjour("Monitor Service : " + serverName);
		} catch (DNSSDException ex){
			logger.log(Level.WARNING,"Could not start Bonjour service");
		}

		
		logger.info("Listening for connections on " + port);
		connection = new JettyHandler (this.defaultDebugLevel,monitor_web,datafilesLoc,eSmart_Install,handleBonjour);
		try {
			connection.start(port,this);	
		} catch (Exception e){
			logger.log(Level.SEVERE,"Could not start monitor web server "+ e.getCause());
		}
		handleBonjour.stopBonjour();
	}
	

	
	public static void main(String[] args)
	{
		new eLife_monitor();

	}
}