/*
 * Created on Nov 21, 2004
 *
 */
package au.com.BI.Config;
import java.util.*;
import java.io.*;


import org.jdom.*;
import org.jdom.input.*;
import java.util.logging.*;

/**
 * @author Colin Canfield
 *
 */

public class Bootstrap {
    Logger logger;
    protected String serverString;
    protected String adminString;
    protected String adminIP;
    protected String configFile;
    protected String configEntry;
    protected int adminPort;
    protected int port;
    protected Level defaultDebugging = Level.INFO;
    protected boolean fileLogging = false;
    protected String logDir = "";
    protected boolean consoleLogging = false;
    protected String rrdGraphDir;
    protected String RRDBDIRECTORY = "." + File.separator + "JRobin" + File.separator;
    protected String RRDXMLDIRECTORY = "." + File.separator + "JRobin" + File.separator+"RRDDefinition" + File.separator;
    protected Date startTime = null;
    protected int jettyPort = 80;
    protected int jettySSLPort = 443;
    private boolean jettyActive = false;
    protected boolean requestUserNames = true;
    protected String  maintenanceTime = "";
    protected boolean integratorMode = false;
    
    public Bootstrap() {
        logger = Logger.getLogger(this.getClass().getPackage().getName());
    }
    
    public void readBootstrap(String fileName)
    throws ConfigError {
        // Create an instance of the tester and test
        try {
            SAXBuilder builder = null;
            
            builder = new SAXBuilder();
            Document doc = builder.build(fileName);
            Element theConfig = doc.getRootElement();
            
            List graphInfo = theConfig.getChildren("RRDGRAPH");
            Iterator graphList = graphInfo.iterator();
            if (graphList.hasNext()) {
                Element dirElement = (Element) graphList.next();
                rrdGraphDir = dirElement.getAttributeValue("DIR");
            } else {
                rrdGraphDir = "." + File.separator + "JRobin" + File.separator + "Graph";
            }
            
            List rrdDirEntries = theConfig.getChildren("RRDBDIRECTORY");
            Iterator rrdDirEntriesIter = rrdDirEntries.iterator();
            if (rrdDirEntriesIter.hasNext()) {
                Element dirElement = (Element) rrdDirEntriesIter.next();
                RRDBDIRECTORY = dirElement.getAttributeValue("DIR");
            } else {
                RRDBDIRECTORY = "." + File.separator + "JRobin" + File.separator + "RRDBDIRECTORY" + File.separator;
            }
            
            List rrdXmlDirEntries = theConfig.getChildren("RRDXMLDIRECTORY");
            Iterator rrdXmlDirEntriesIter = rrdXmlDirEntries.iterator();
            if (rrdXmlDirEntriesIter.hasNext()) {
                Element dirElement = (Element) rrdXmlDirEntriesIter.next();
                RRDXMLDIRECTORY = dirElement.getAttributeValue("DIR");
            } else {
                RRDXMLDIRECTORY = "." + File.separator + "JRobin" + File.separator + "RRDXMLDIRECTORY"+ File.separator;
            }
    
            Element maintenanceElm = theConfig.getChild("MAINTENANCE");
            if (maintenanceElm != null) {
            	this.setMaintenanceTime(maintenanceElm.getAttributeValue("TIME")) ;
            }
            
            Element serverConfigs = theConfig.getChild("SERVER");
            if (serverConfigs == null)
                throw new ConfigError("SERVER tag not found in bootstrap file");
            
            serverString = serverConfigs.getAttributeValue("IP");
            if (serverString == null) serverString = "";
            String portString = serverConfigs.getAttributeValue("PORT");
            
            if (portString != null && !portString.equals("")) {
                try {
                    this.port = Integer.parseInt(portString);
                } catch (NumberFormatException ne) {
                    port = 10000;
                }
                
            } else {
                port = 10000;
            }
            
            
            Element serverConfigFile = theConfig.getChild("CONFIG_FILE");
            this.configEntry = serverConfigFile.getAttributeValue("NAME");
            configFile = configEntry;
            
            this.startTime = new Date();
            
            Element adminSpec = theConfig.getChild("ADMIN");
            String adminPortString = "10001";
            if (adminSpec != null) {
                adminString = adminSpec.getAttributeValue("IP");
                if (adminString == null) adminString = "";
                adminPortString = adminSpec.getAttributeValue("PORT");
            }
            
            if (adminString.equals("")) adminString = "127.0.0.1"; // Bind to all ports;
            if (adminPortString != null && !adminPortString.equals("")) {
                try {
                    adminPort = Integer.parseInt(adminPortString);
                } catch (NumberFormatException ne) {
                    adminPort = 10001;
                }
                
            } else {
                adminPort = 10001;
            }
            
            Element integratorModeElm = theConfig.getChild("INTEGRATOR_MODE");
            if (integratorModeElm != null) {
                String valueStr = integratorModeElm.getAttributeValue("ACTIVE");

                if (valueStr != null && valueStr.equals("Y")) {
                	this.setIntegratorMode( true);
                	logger.log(Level.INFO,"Integrator mode activated");
                }
                else {
                	this.setIntegratorMode(false);
                }
            }
            
            Element debugConfig = theConfig.getChild("DEBUG");
            if (debugConfig != null) {
                String levelStr = debugConfig.getAttributeValue("LEVEL");
                String debugYN = debugConfig.getAttributeValue("FILE");
                logDir = debugConfig.getAttributeValue("LOGDIR");
                if (logDir == null) logDir = "";
                if (debugYN != null && debugYN.equals("Y")) this.fileLogging = true;
                String consoleYN = debugConfig.getAttributeValue("CONSOLE");
                if (consoleYN != null && consoleYN.equals("Y")) this.consoleLogging = true;
                
                if (levelStr != null) {
                    try {
                        this.defaultDebugging = Level.parse(levelStr);
                    } catch (IllegalArgumentException ex) {
                        this.defaultDebugging = Level.INFO;
                    }
                }
            }
            
            Element jettyConfig = theConfig.getChild("JETTY");
            if (jettyConfig != null) {

                String jettyActiveStr = jettyConfig.getAttributeValue("ACTIVE");
                if (jettyActiveStr != null && jettyActiveStr.equals ("Y")){
                	setJettyActive(true);
                }
                String requestUserNames = jettyConfig.getAttributeValue("USER_NAMES");
                if (requestUserNames != null && requestUserNames.equals ("N")){
                	setRequestUserNames (false);
                }

                String jettyPortStr = jettyConfig.getAttributeValue("PORT");
                if (jettyPortStr != null) {
                    try {
                        jettyPort = Integer.parseInt(jettyPortStr);
                    } catch (NumberFormatException ex){
                        throw new ConfigError("Jetty port is not a number, please correct PORT entry in the JETTY element.");
                    }
                }
                String jettySSLPortStr = jettyConfig.getAttributeValue("SSL_PORT");
                if (jettySSLPortStr != null) {
                    try {
                        jettySSLPort = Integer.parseInt(jettySSLPortStr);
                    } catch (NumberFormatException ex){
                        throw new ConfigError("Jetty SSL port is not a number, please correct PORT entry in the JETTY element.");
                    }
                }
                
            } else {
                logger.log(Level.WARNING,"Please add a configuration entry for JETTY to the bootstrap.xml file");
            }
            
            
        } catch (JDOMException e) {
            throw new ConfigError(e);
        } catch (IOException e) {
            throw new ConfigError(e);
        } catch (NullPointerException e) {
            throw new ConfigError("Attribute not set properly in bootstrap file");
        }
        
    }
    /**
     * @return Returns the portString.
     */
    public int getPort() {
        return port;
    }
    /**
     * @param portString The portString to set.
     */
    public void setPortString(int port) {
        this.port = port;
    }
    /**
     * @return Returns the serverString.
     */
    public String getServerString() {
        return serverString;
    }
    /**
     * @param serverString The serverString to set.
     */
    public void setServerString(String serverString) {
        this.serverString = serverString;
    }
    /**
     * @return Returns the configFile.
     */
    public String getConfigFile() {
        return configFile;
    }
    
    /**
     * @return Returns the adminIP.
     */
    public String getAdminIP() {
        return adminIP;
    }
    /**
     * @param adminIP The adminIP to set.
     */
    public void setAdminIP(String adminIP) {
        this.adminIP = adminIP;
    }
    /**
     * @return Returns the adminPort.
     */
    public int getAdminPort() {
        return adminPort;
    }
    /**
     * @param adminPort The adminPort to set.
     */
    public void setAdminPort(int adminPort) {
        this.adminPort = adminPort;
    }
    
    /**
     * @return Returns the defaultDebugging.
     */
    public Level getDefaultDebugging() {
        return defaultDebugging;
    }
    /**
     * @param defaultDebugging The defaultDebugging to set.
     */
    public void setDefaultDebugging(Level defaultDebugging) {
        this.defaultDebugging = defaultDebugging;
    }
    /**
     * @return Returns the fileLogging.
     */
    public boolean isFileLogging() {
        return fileLogging;
    }
    /**
     * @param fileLogging The fileLogging to set.
     */
    public void setFileLogging(boolean fileLogging) {
        this.fileLogging = fileLogging;
    }
    
    public String getRrdGraphDir() {
        return this.rrdGraphDir;
    }
    /**
     * @return Returns the configEntry.
     */
    public String getConfigEntry() {
        return configEntry;
    }
    /**
     * @return Returns the startTime.
     */
    public Date getStartTime() {
        return startTime;
    }
    /**
     * @return Returns the rRDBDIRECTORY.
     */
    public String getRRDBDIRECTORY() {
        return RRDBDIRECTORY;
    }
    /**
     * @return Returns the rRDXMLDIRECTORY.
     */
    public String getRRDXMLDIRECTORY() {
        return RRDXMLDIRECTORY;
    }
    /**
     * @return Returns the consoleLogging.
     */
    public boolean isConsoleLogging() {
        return consoleLogging;
    }
    /**
     * @param consoleLogging The consoleLogging to set.
     */
    public void setConsoleLogging(boolean consoleLogging) {
        this.consoleLogging = consoleLogging;
    }
    
    public String getLogDir() {
        return logDir;
    }
    
    public void setLogDir(String logDir) {
        this.logDir = logDir;
    }
    
    public int getJettyPort() {
        return jettyPort;
    }

    public boolean isJettyActive() {
        return jettyActive;
    }

    public void setJettyActive(boolean jettyActive) {
        this.jettyActive = jettyActive;
    }

	public boolean isRequestUserNames() {
		return requestUserNames;
	}

	public void setRequestUserNames(boolean requestUserNames) {
		this.requestUserNames = requestUserNames;
	}

	public int getJettySSLPort() {
		return jettySSLPort;
	}

	public void setJettySSLPort(int sslPort) {
		this.jettySSLPort = sslPort;
	}

	public String getMaintenanceTime() {
		return maintenanceTime;
	}

	public void setMaintenanceTime(String maintenanceTime) {
		this.maintenanceTime = maintenanceTime;
	}

	public boolean isIntegratorMode() {
		return integratorMode;
	}

	public void setIntegratorMode(boolean integratorMode) {
		this.integratorMode = integratorMode;
	}
    
    
}
