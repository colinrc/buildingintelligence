/*
 * Created on Dec 8 2004
 *
 */
package au.com.BI.Admin;
import java.io.*;
import java.net.*;

import java.util.logging.*;
import java.util.*;

import org.jdom.*;
import org.jdom.input.SAXBuilder;
import org.jdom.output.Format;
import org.jdom.output.XMLOutputter;
/**
 * @author Colin Canfield
 *
 **/
public class eLife_monitor
{
	
	public String IPAddress = "";
	public String devicePort = "10002";
	protected Level defaultDebugLevel = Level.INFO;
	protected boolean running = true;
	Logger logger;
	boolean gettingLines = false;
	protected String eSmart_install;
	protected Socket adminConnection;
	protected ProcessXML processXML;
	protected ConnectionManager connection;
	
	
	/**
	 * Sets up the client handling system
	 * @param numberClients An indicative number of clients, 
	 * the actual number may be larger than this
	 */
	public eLife_monitor ( ){
		
		
		logger = Logger.getLogger("eLife_monitor");
		running = true;
		int port = 10002;
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
	    		port = 10002;
	    	}
	    }
	    
	    String major_version = properties.getProperty("major_version");
	    String minor_version = properties.getProperty("minor_version");
	    eSmart_install = properties.getProperty("eSmart_install");

		System.out.println ("Launching eLife monitor task V" + major_version + "." + 
					minor_version);
		
		logger.info("Openning port " + port);

		logger.info("Listening for connection on " + port);
		connection = new ConnectionManager (port,this);
		connection.start();
	}

	public void disconnect () {
		try {
			connection.stopHeartbeat();
			running = false;
			if (adminConnection != null) {
				synchronized (adminConnection){
					processXML.setGettingLines(false);
					adminConnection.close();
				}
			}
		} catch (IOException e) {
		}
		gettingLines = false;
	}
	
	public void connect (Socket adminConnection) {

		this.adminConnection = adminConnection;
		processXML = new ProcessXML (adminConnection,eSmart_install);
		processXML.start();
	}
	
	public boolean isConnected () {
		if (processXML != null && processXML.isAlive()) 
			return true;
		else
			return false;
	}
	
	public static void main(String[] args)
	{

		eLife_monitor monitor = new eLife_monitor();

	}
}