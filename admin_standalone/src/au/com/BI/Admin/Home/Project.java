package au.com.BI.Admin.Home;
import java.io.IOException;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class Project {
	
	private String serverIP = "127.0.0.1";
	private int defaultMonitorPort = 10002;
	private int defaultAdminPort = 10001;
	private int monitorPort = defaultMonitorPort;
	private int adminPort = defaultAdminPort;
	protected Logger logger;
	protected String fileName = "";
	protected Properties properties;
	
	public Project () {
		super();
		logger = Logger.getLogger("Log");
		properties = new Properties();
	}
	
	public int getAdminPort() {
		return adminPort;
	}
	public void setAdminPort(int adminPort) {
		this.adminPort = adminPort;
	}

	public int getMonitorPort() {
		return monitorPort;
	}
	public void setMonitorPort(int monitorPort) {
		this.monitorPort = monitorPort;
	}
	public String getServerIP() {
		return serverIP;
	}
	public void setServerIP(String serverIP) {
		this.serverIP = serverIP;
	}
	
	protected boolean getParameters (String projectName, String fileName) throws IOException {
		String oldServerIP = this.serverIP;
		int oldAdminPort = this.adminPort;
		int oldMonitorPort = this.monitorPort;

		this.fileName = fileName;
		
		try {
			properties.load(this.getClass().getResourceAsStream(fileName));
	
			this.serverIP = properties.getProperty(
				"ServerIP");
			if(this.serverIP == null || this.serverIP.length() == 0)
			{
				this.serverIP = "127.0.0.1";
				properties.setProperty(
					"ServerIP",
					this.serverIP);
			}
			String adminPortStr = properties.getProperty(
					"eLifePort");
			if(adminPortStr == null || adminPortStr.length() == 0)
			{
				adminPort = defaultAdminPort;
				adminPortStr = String.valueOf(adminPort);
				properties.setProperty(
					"eLifePort",
					adminPortStr);
			}
			try {
				adminPort = Integer.parseInt(adminPortStr);
			} catch (NumberFormatException ex) {
				logger.log (Level.WARNING,"Could not parse monitor port property " + ex.getMessage());
				adminPort = defaultAdminPort;
			}
	
			
			
			String monitorPortStr = properties.getProperty(
					"MonitorPort");
			if(monitorPortStr == null || monitorPortStr.length() == 0)
			{
				monitorPort = defaultMonitorPort;
				monitorPortStr = String.valueOf(monitorPort);
				properties.setProperty(
					"MonitorPort",
					monitorPortStr);
			}
			try {
				monitorPort = Integer.parseInt(monitorPortStr);
			} catch (NumberFormatException ex) {
				logger.log (Level.WARNING,"Could not parse eLife port property " + ex.getMessage());
				monitorPort = defaultMonitorPort;
			}

		} catch (NullPointerException ex){}
		
		if (oldAdminPort == this.adminPort && oldMonitorPort == this.monitorPort && oldServerIP.equals(this.serverIP) )
			return false;
		else 
			return true;
	}
}
