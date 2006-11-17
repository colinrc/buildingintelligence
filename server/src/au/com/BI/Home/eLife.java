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
	
	public eLife (String configName,boolean runHarness, LogHandler sh,  boolean sysOutPrint ) {

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

	    String outString = "";
	    
	    if (minor_version.equals("")){	    	
		    outString = major_version;	    	
	    } else {
	    	outString = major_version + minor_version;	    	
	    }
	    

		System.out.println ("Launching eLife V" + outString);
		logger.log (Level.INFO,"Launching eLife V" + outString);

		if (sysOutPrint){
			System.setProperty("DEBUG","true");
		}
		
		try {
		    String bootstrapFile = "datafiles" + File.separator + "bootstrap.xml"; 
		    if (sysOutPrint) System.out.println ("About to load bootstrap " + bootstrapFile);
		    bootstrap.readBootstrap(bootstrapFile);
		    if (sysOutPrint) System.out.println ("Bootstrap read OK");
		    VersionManager versionManager = new VersionManager ();
		    versionManager.setMasterVersion(outString);

		    this.defaultLogLevel = bootstrap.getDefaultDebugging();
		    
		    if (bootstrap.isFileLogging()) {
		    	if (sysOutPrint) System.out.println ("Setting up file logging");
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
				if (sysOutPrint) System.out.println ("Setting up console logging");
				try {
					ConsoleHandler consoleHandler = new ConsoleHandler();
					consoleHandler.setFormatter(new SimpleFormatter());
					consoleHandler.setLevel(defaultLogLevel);
					logger.addHandler(consoleHandler);
				} catch (SecurityException e1) {
					e1.printStackTrace();
				} 
				
		    }
			
		    if (sysOutPrint) System.out.println ("Everything set up, launching master controller");
			controller = new Controller ();
			controller.setLogHandler(sh);
			controller.setBootstrap(bootstrap);
			controller.setBindToAddress(bootstrap.getServerString());
			controller.setClientPort(bootstrap.getPort());
			controller.setVersionManager (versionManager);
			controller.setUp(); 
			if (!configName.equals ("")) {
				controller.setConfigFile (configName);
			} 
			controller.run();
		} catch (ConfigError be) {
		    logger.log (Level.SEVERE,"Error in the bootstrap file, the system cannot launch "
		            + be.getMessage());
		    if (sysOutPrint) System.out.println ("Error in the bootstrap file, the system cannot launch "
		            + be.getMessage());
			System.exit(1);
		} catch (CommsFail fail){
			
			if (logger != null) 
				logger.log(Level.SEVERE,"Could not set up controller " + fail.getMessage());
			else {
				System.out.print("Could not set up controller " + fail.getMessage());
			    if (sysOutPrint) System.out.println ("Error in the bootstrap file, the system cannot launch "
			            + fail.getMessage());
				System.exit(1);
			}

		} catch (java.lang.NullPointerException fail) {
			StackTraceElement[] errors = fail.getStackTrace();
			if (logger != null) {
				logger.log(Level.SEVERE,"Exiting: Dire problems " + fail.getMessage());
				logger.log(Level.SEVERE,"System died at : " + errors[0].toString());
			    if (sysOutPrint) {
			    	System.out.println ("Exiting: Dire problems " + fail.getMessage() 
			    			+ fail.getMessage());
			    	System.out.println ("System died at : " + errors[0].toString()
			            + fail.getMessage());
			    }
			    System.exit(1);
			}
			else {
				System.out.println ("Exiting: Dire problems " + fail.getMessage());
				fail.printStackTrace();
				System.exit(1);
			}
		}
		System.exit(0);
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
		boolean verbose = false;
		
		if (args.length > 0) {
			String verboseStr = args[0];
			if (verboseStr  != null && verboseStr.equals ("-vvv")) verbose = true;
		}			
		
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
					
		System.out.println ("Launching system");
		helloHouse = new eLife("",true,sh,verbose);
	}
}
