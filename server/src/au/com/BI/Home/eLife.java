package au.com.BI.Home;
import java.io.File;
import au.com.BI.Admin.LogHandler;
import au.com.BI.Admin.BIFormatter;
import java.io.IOException;
import java.util.Properties;
import java.util.logging.*;
import au.com.BI.Config.*;

import au.com.BI.Comms.*;
/*
 * Created on Dec 28, 2003
 *
*/

/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 */


public class eLife {
	Controller controller;
	protected static eLife helloHouse;
	Logger logger;
	Level defaultLogLevel = Level.INFO;
	LogHandler sh;
	Logger globalLogger;
	
	public eLife (String configName,boolean runHarness, LogHandler sh) {
		this.sh = sh;
		logger = Logger.getLogger("au.com.BI");
		//this.logger = globalLogger;
		
		Bootstrap bootstrap = new Bootstrap();
	    Properties properties = new Properties();
	    try {
	    		properties.load(this.getClass().getResourceAsStream("my.properties"));
	    } catch (IOException e) {
	    }

	    String major_version = properties.getProperty("major_version");
	    String minor_version = properties.getProperty("minor_version");
	    String eSmart_install = properties.getProperty("eSmart_install");


		System.out.println ("Launching eLife V" + major_version + "." + 
				minor_version);
		logger.log (Level.INFO,"Launching eLife V" + major_version + "." + 
				minor_version);

		try {
		    String bootstrapFile = "datafiles" + File.separator + "bootstrap.xml"; 
		    bootstrap.readBootstrap(bootstrapFile);
			bootstrap.setVersion (major_version + "." + minor_version);

		    this.defaultLogLevel = bootstrap.getDefaultDebugging();
		    
		    if (bootstrap.isFileLogging()) {
				try {
					FileHandler fileHandler = new FileHandler ("log/trace.log",10000000,10,false);
					fileHandler.setFormatter(new SimpleFormatter());
					fileHandler.setLevel(defaultLogLevel);
					logger.addHandler(fileHandler);
				} catch (SecurityException e1) {
					e1.printStackTrace();
				} catch (IOException e1) {
					logger.log(Level.SEVERE,"Could not open log file " + e1.getMessage());
				}
				
		    }
		    
		    if (bootstrap.isConsoleLogging()) {
				try {
					ConsoleHandler consoleHandler = new ConsoleHandler();
					consoleHandler.setFormatter(new SimpleFormatter());
					consoleHandler.setLevel(defaultLogLevel);
					logger.addHandler(consoleHandler);
				} catch (SecurityException e1) {
					e1.printStackTrace();
				} 
				
		    }
			
			controller = new Controller ();
			controller.setLogHandler(sh);
			controller.setBootstrap(bootstrap);
			controller.setBindToAddress(bootstrap.getServerString());
			controller.setClientPort(bootstrap.getMasterPort());
			if (bootstrap.getGUI().equals ("Y"))
				runHarness = true;
			else
				runHarness = false;
			if (runHarness) controller.setUpGUIHarness(defaultLogLevel,globalLogger);
			controller.setUp(); 
			if (!configName.equals ("")) {
				controller.setConfigFile (configName);
			} else {
			    controller.setConfigFile (bootstrap.getConfigFile());
			}
			controller.run();
		} catch (ConfigError be) {
		    logger.log (Level.SEVERE,"Error in the bootstrap file, the system cannot launch "
		            + be.getMessage());
		} catch (CommsFail fail){
			
			if (logger != null) 
				logger.log(Level.SEVERE,"Could not set up controller " + fail.getMessage());
			else
				System.out.print("Could not set up controller " + fail.getMessage());
		} catch (java.lang.NullPointerException fail) {
			StackTraceElement[] errors = fail.getStackTrace();
			if (logger != null) {
				logger.log(Level.SEVERE,"Exiting: Dire problems " + fail.getMessage());
				logger.log(Level.SEVERE,"System died at : " + errors[0].toString());
			}
			else {
				System.err.println ("Exiting: Dire problems " + fail.getMessage());
				fail.printStackTrace();
				System.exit(1);
			}
		}
	}
	
	/**
	 Responds to the menu items and buttons.
	 */
	
	/**
	 Cleanly shuts down the applicaion. first closes any open ports and
	 cleans up, then exits.
	 */
	private void shutdown() {
		if (controller != null)	controller.doShutdown();
		System.exit(1);
	} 
	
	
	public static void main(String[] args)
	{
		boolean runHarness = true;
		
		Runtime.getRuntime().addShutdownHook(new Thread() {
	        public void run() {
	            if (helloHouse != null)
	                helloHouse.shutdown();
	        }
	    });;
	    
		LogManager manager = LogManager.getLogManager();
		manager.reset();
		LogHandler sh = new LogHandler (new BIFormatter());
		sh.setLevel(Level.ALL);
		Logger logger = Logger.getLogger("au.com.BI");
		logger.setLevel (Level.FINEST);
		logger.addHandler(sh);
		
		if (args.length > 1) {
			if (args.length != 2) {
				System.out.println ("Usage:  ConfigFile GUI[Y-N]");
				System.exit(0);
			}
			String configName = args[0];
			if (args[1].equals("N")) {
				runHarness = false;
			}
					
			System.out.println ("Launching system with config " + args[0]);
			helloHouse = new eLife(args[0],runHarness,sh);
		} else {
			System.out.println ("Launching system");
			helloHouse = new eLife("",true,sh);
		}
	}
}
