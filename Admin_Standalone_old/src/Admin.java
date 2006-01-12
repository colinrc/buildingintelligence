/*
 * eLife_Admin.java
 * part of the eLife_Admin plugin for the jEdit text editor
 */

// from Java:
import java.awt.*;
import java.io.*;
import java.lang.reflect.InvocationTargetException;
import java.util.logging.*;
import java.util.Calendar;
import java.util.Properties;

// from Swing:
import javax.swing.*;




public class Admin extends JPanel 
{
	private String serverIP = "127.0.0.1";
	private int defaultMonitorPort = 10001;
	private int defaultAdminPort = 10002;
	private int monitorPort = defaultMonitorPort;
	private int adminPort = defaultAdminPort;
	private String workingDir = "";
	private String editCMD = "";

	private boolean floating;
	private JTextArea textArea;

	private eLife_AdminToolPanel toolPanel;
	private eLife_AdminTabbedPane tabPanel;
	private ConnectionManager connection;
	protected Logger logger;
	private IP ip;
	protected String workDir = "";;
	private String irName;
	protected String logDir = "log";
	protected boolean shownAdminConnectError = false;
	protected Properties properties = null;
	
	//
	// Constructor
	//

	
	public Admin(JFrame theView)
	{
		super(new BorderLayout());
		JFrame view = theView;
		
		logger = Logger.getLogger("Log");
		
		Container contentsPane  = theView.getContentPane();
		

	    properties = new Properties();
	    try {
	    		properties.load(this.getClass().getResourceAsStream("my.properties"));
	    } catch (IOException e) {
	    }
		getParameters (properties);
		
	    String major_version = properties.getProperty("major_version");
	    String minor_version = properties.getProperty("minor_version");

		this.tabPanel = new eLife_AdminTabbedPane(this);
		contentsPane.add(this.tabPanel,BorderLayout.CENTER);
		view.pack();
		view.setVisible(true);

		if (!workDir.equals ("")) {
			tabPanel.getControlsPanel().updateSystemStatus("eLife V" + major_version + "." + minor_version + " Work Dir : " + workDir);
		} else {
			tabPanel.getControlsPanel().updateSystemStatus("eLife V" + major_version + "." + minor_version + " Please set work directory");			
		}
		add(this.tabPanel,BorderLayout.CENTER);
		contentsPane.add(this);

		connection = new ConnectionManager (this);
		connection.connect(serverIP,monitorPort,adminPort);
		connection.start();
	}
	
	public void createWorkingDir (String workDir,String serverIP) {
		if (workDir.equals ("")) {
			// setCWD();
			// @TODO make option window popup instead
		}
		Calendar now = Calendar.getInstance();
		String timeStamp = now.get(Calendar.DATE) + "." + now.get (Calendar.MONTH) + "." + now.get (Calendar.YEAR);
		workingDir = workDir + "/" + serverIP;
		File newDir = new File (workingDir);
		newDir.mkdirs();
	}
	
	
	
	public void createFileBuffer (String theFile,String dir, String sourceName,boolean load) {
		if (theFile != null) {

			/*
			newBuffer.writeLock();
			if (dir.endsWith("script")) {
				newBuffer.setMode ("py");
			} else {
				newBuffer.setMode ("xml");
			}
			newBuffer.writeUnlock();
			*/
			
			String dirParts[] = dir.split("[/\\\\]");
			int numberParts = dirParts.length;
			String dirToWrite = "";
			if (numberParts > 0) {
				dirToWrite = dirParts[numberParts - 1];
				if (numberParts > 1) {
					dirToWrite = dirParts[numberParts - 2] + "/" + dirToWrite;
				}
			}
			
			String newDirStr = workingDir+"/" + dirToWrite;
			File newDir = new File (newDirStr);
			newDir.mkdirs();

			String nameParts[] = sourceName.split("[/\\\\]");
			String nameOnly = nameParts[nameParts.length-1];
			
			String fullPath = newDir + File.separator + nameOnly;
			
			try {
				File newFile = new File (fullPath);
				if (!newFile.exists () || newFile.canWrite()) {
					FileWriter outFile = new FileWriter (newFile);
					outFile.write(theFile);
					outFile.close();
				}
				if (!editCMD.equals("")) {
					String toRun [] = new String[2];
					toRun [0] = editCMD;
					toRun [1]  = fullPath;
					Process p = Runtime.getRuntime().exec (toRun);		
				}
			} catch (IOException ex) {
				logger.log (Level.WARNING,"Could not write file " + fullPath);
			}
		}
	}
	
	public void 	setStartupFile(String startupFile) {
		this.getConfigsPanel().setStartupFile(startupFile);
	}

	public void 	setLogDir(String logDir) {
		this.getServerLogPanel().setLogDir(logDir);
		this.ip.setLogDir(logDir);
	}
	
	public void learnIR(String irName){
		this.setIrNameField(irName);
		learnIR();
	}
	
	public void learnIR () {
		if (ip != null && irName != null && !irName.equals("")) {
			try {
				ip.sendMonitorMessage ("<IR_LEARN NAME=\"" + irName + "\" />\n");
			} catch (IOException e) {
			}
		}
	}
	
	public void IRCompleted (String message) {
		this.getIRPanel().setLearntMessage(message);
		this.getIRPanel().clearIRLearn();
		this.getIRPanel().nextInstruction();
	}
	
	public void setExecResult (String execString) {
		this.tabPanel.getControlsPanel().setExecResult (execString);
	}

	public void setDataFilesResult (String resultsString) {
		this.tabPanel.getDataFilesPanel().setResults (resultsString);
	}
	
	public void setConfigResult (String resultsString) {
		this.tabPanel.getConfigsPanel().setResults (resultsString);
	}

	public void setJRobinRRDResult (String resultsString) {
		this.tabPanel.getJRobinRRDPanel().setResults (resultsString);
	}

	public void setJRobinGraphResult (String resultsString) {
		this.tabPanel.getJRobinGraphPanel().setResults (resultsString);
	}


	public void setClientResult (String resultsString) {
		this.tabPanel.getClientPanel().setResults (resultsString);
	}

	public void setServerLogResult (String resultsString) {
		this.tabPanel.getServerLogPanel().setResults (resultsString);		
	}

	public void setClientCoreResult (String resultsString) {
		this.tabPanel.getClientCorePanel().setResults (resultsString);
	}
	
	public void setScriptsResult (String resultsString) {
		this.tabPanel.getScriptsPanel().setResults (resultsString);
	}

	public DebugLevelsPanel getDebugLevelsPanel () {
		return this.tabPanel.getDebugLevelsPanel();
	}
	
	public ControlsPanel getControlsPanel () {
		return this.tabPanel.getControlsPanel();
	}

	public ServerLogPanel getServerLogPanel () {
		return this.tabPanel.getServerLogPanel();
	}
	
	public ClientCorePanel getClientCorePanel () {
		return this.tabPanel.getClientCorePanel();
	}
	
	public JRobinRRDPanel getJRobinRRDPanel () {
		return this.tabPanel.getJRobinRRDPanel();
	}

	public JRobinGraphPanel getJRobinGraphPanel () {
		return this.tabPanel.getJRobinGraphPanel();
	}
	
	public ConfigsPanel getConfigsPanel () {
		return this.tabPanel.getConfigsPanel();
	}

	public ScriptsPanel getScriptsPanel () {
		return this.tabPanel.getScriptsPanel();
	}

	public DataFilesPanel getDataFilesPanel () {
		return this.tabPanel.getDataFilesPanel();
	}

	public ClientPanel getClientPanel () {
		return this.tabPanel.getClientPanel();
	}


	public IRPanel getIRPanel () {
		return this.tabPanel.getIRPanel();
	}
	
	public LogPanel getLogViewer () {
		return tabPanel.getLogPanel();
	}

	public void sendELifeMessage (String message) throws IOException {
		connection.sendMonitorMessage(message);
	}
	
	public void setELifeConnectionStatus (boolean connected) {

		tabPanel.getControlsPanel().setMonitorConnectionStatus (connected);

	}

	public void setAdminConnectionStatus (boolean connected) {

		tabPanel.getControlsPanel().setAdminConnectionStatus (connected);
		if (connected == false) {
			tabPanel.getConfigsPanel().clear();
			tabPanel.getScriptsPanel().clear();
			tabPanel.getDataFilesPanel().clear();
			tabPanel.getJRobinGraphPanel().clear();
			tabPanel.getJRobinRRDPanel().clear();
			tabPanel.getClientPanel().clear();
			tabPanel.getClientCorePanel().clear();
		}
	}

	public void setIP (IP ip) {
		this.ip = ip;
	}
	
	public void alreadyInUse(String errorString,int option) {
		if (!shownAdminConnectError) {
			shownAdminConnectError = true;
			showMessage (errorString,option);
		}
	}
	
	private class MessageDisplay implements Runnable  {
		private String errorString;
		private int option;
		
		public MessageDisplay(String errorString, int option) {
			this.errorString = errorString;
			this.option = option;
		}
		
		public void run () {
			JOptionPane.showMessageDialog(null,errorString, "eLife", option);
		}
		
	}
	
	public void showMessage (String errorString,int option) {
		MessageDisplay message = new MessageDisplay (errorString,option);
		SwingUtilities.invokeLater (message);
	}
	
	protected boolean getParameters (Properties properties) {
		String oldServerIP = this.serverIP;
		String oldWorkDir = this.workDir;
		int oldAdminPort = this.adminPort;
		int oldMonitorPort = this.monitorPort;

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
		this.workDir = properties.getProperty(
				"WorkDir");
		if(this.workDir == null || this.workDir.length() == 0)
			{
				this.workDir = "";
				properties.setProperty(
						"WorkDir",
						workDir);
			}

		this.editCMD = properties.getProperty(	"EditCMD","");
		
		if (oldAdminPort == this.adminPort && oldMonitorPort == this.monitorPort && oldServerIP.equals(this.serverIP) && oldWorkDir.equals(this.workDir))
			return false;
		else 
			return true;
	}

	
	public void doELifeConnectionStartup () {
		this.tabPanel.getDebugLevelsPanel().sendDebugLevels();
		getIRDevices();
	}
	
	public void doAdminConnectionStartup () {
		this.createWorkingDir(this.workDir,this.serverIP);
	}
	
	public void sendArbitraryCommand (String command ) {
		try {
			if (ip != null) {
				ip.sendAdminMessage ("<ADMIN COMMAND=\"ARBITRARY\" EXTRA=\"" + command + "\" />\n");
			}
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}
		
	}

	public void getIRActions (String device) {
		try {
			if (ip != null) {
				ip.sendMonitorMessage("<LIST_IR_ACTIONS DEVICE=\"" + device + "\" />\n");					
			}
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the server connection " + e.getMessage());
		}
	}
	

	public void getIRDevices () {
		try {
			if (ip != null) {
				ip.sendMonitorMessage("<LIST_IR_DEVICES />\n");					
			}
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the server connection " + e.getMessage());
		}
	}
	
	public void readFiles (String dir) {
		try {
			if (ip != null) {
				if (dir.endsWith("script")) {
					ip.sendAdminMessage ("<ADMIN COMMAND=\"LIST\" DIR=\"" + dir + "\" FILTER=\".py\" />\n");
				} else {
					ip.sendAdminMessage ("<ADMIN COMMAND=\"LIST\" DIR=\"" + dir + "\" FILTER=\".xml\" />\n");					
				}
			}
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}
	}

	public void readFiles (String dir,String filter) {
		try {
			if (ip != null) {
				ip.sendAdminMessage ("<ADMIN COMMAND=\"LIST\" DIR=\"" + dir + "\" FILTER=\"" + filter + "\" />\n");
			}
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}
	}

	public void downloadClientXML () {
		try {
			if (ip != null)
				ip.sendAdminMessage ("<ADMIN COMMAND=\"DOWNLOAD\" DIR=\"client\" EXTRA=\"client.xml\" />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}		
	}
	
	public void downloadFile (String dir, String fileName) {
		try {
			if (ip != null)
				ip.sendAdminMessage ("<ADMIN COMMAND=\"DOWNLOAD\" DIR=\"" + dir + "\" EXTRA=\"" + fileName + "\" />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}		
	}
	
	public void setStartup (String configFile) {
		try {
			if (ip != null)
				ip.sendAdminMessage ("<ADMIN COMMAND=\"SELECT\" EXTRA=\"" + configFile + "\" />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}
	}
	
	public void deleteFile (String dir, String configFile) {
		try {
			if (ip != null)
				ip.sendAdminMessage ("<ADMIN COMMAND=\"DELETE\" DIR=\"" + dir + "\" EXTRA=\"" + configFile + "\" />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}
	}
	
	public void uploadFile(String dir, String fileName) {

		if (fileName.equals("")) {
			JFileChooser newChooser = new JFileChooser (dir);			
			int returnVal = newChooser.showOpenDialog(this);
			if (returnVal != JFileChooser.APPROVE_OPTION)
				return;
			fileName = newChooser.getName();
		}
		File fileToSend = new File(fileName);		
		FileReader reader = null;
		try {
			reader = new FileReader (fileToSend);
		} catch (FileNotFoundException ex){
			logger.log (Level.WARNING,"File not found in uploading the file " + fileName);								
		}
		int fileLength = (int)fileToSend.length();
		char fileContents[] = new char [fileLength];

		try {
			reader.read(fileContents,0,fileLength);
			ip.sendAdminMessage ("<ADMIN COMMAND=\"UPLOAD\" NAME=\"" + fileName + "\" DIR=\"" + dir + "\" ><![CDATA[" + fileContents + " ]]></ADMIN>\n");
		}
		catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());					
		}
	}
	
	public void uploadClientXML(String dir, String fileName) {

		if (fileName.equals("")) {
			JFileChooser newChooser = new JFileChooser (dir);			
			int returnVal = newChooser.showOpenDialog(this);
			if (returnVal != JFileChooser.APPROVE_OPTION)
				return;
			fileName = newChooser.getName();
		}
		File fileToSend = new File(fileName);		
		FileReader reader = null;
		try {
			reader = new FileReader (fileToSend);
		} catch (FileNotFoundException ex){
			logger.log (Level.WARNING,"File not found in uploading the file " + fileName);								
		}
		int fileLength = (int)fileToSend.length();
		char fileContents[] = new char [fileLength];

		try {
			reader.read(fileContents,0,fileLength);
			ip.sendAdminMessage ("<ADMIN COMMAND=\"UPLOAD\" NAME=\"client.xml\" DIR=\"client\" ><![CDATA[" + String.copyValueOf(fileContents) + " ]]></ADMIN>\n");
		}
		catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());					
		}
	}
	
	public void disconnectAdmin () {
		disconnectAdmin (true); // default behaviour is to show the in use message again on next failure
	}
	public void disconnectAdmin(boolean updateShownMessage) {
		if (connection != null) {
			connection.disconnectAdmin();
			if (updateShownMessage) {
				shownAdminConnectError = false;
			}
		}
		this.setAdminConnectionStatus(false);
	}
	
	public void disconnect_eLife () {
		if (connection != null) {
			connection.disconnectMonitor();
		}
		this.setELifeConnectionStatus(false);		
	}
	
	public void disconnect () {
		disconnect (true);
	}
	
	public void disconnect(boolean tryToReconnect) {
		connection.setTryToConnect(false);
		disconnectAdmin();
		disconnect_eLife();
	}
	




	protected void propertiesChanged() {
		boolean anyChange = true;
		// @TODO , make this actually a properties change listener
		if (anyChange) {
			if (connection != null) {
				connection.setTryToConnect(false);
			}
			this.disconnect();
			shownAdminConnectError = false;
				
			connection = new ConnectionManager (this);
			connection.connect(serverIP,adminPort,monitorPort);
			connection.start();
		}
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
	 * @return Returns the monitorPort.
	 */
	public int getMonitorPort() {
		return monitorPort;
	}
	/**
	 * @param monitorPort The monitorPort to set.
	 */
	public void setMonitorPort(int monitorPort) {
		this.monitorPort = monitorPort;
	}
	/**
	 * @return Returns the serverIP.
	 */
	public String getServerIP() {
		return serverIP;
	}
	/**
	 * @param serverIP The serverIP to set.
	 */
	public void setServerIP(String serverIP) {
		this.serverIP = serverIP;
	}
	
	public void reloadScripts() {
		try {
			ip.sendMonitorMessage("<RELOAD_SCRIPTS />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the connection to the server " + e.getMessage());
		}
	}
	
	public void reloadMacros() {
		try {
			ip.sendMonitorMessage("<RELOAD_MACROS />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the connection to the server " + e.getMessage());
		}
	}

	public void reloadIRDB() {
		try {
			ip.sendMonitorMessage("<RELOAD_IRDB />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the connection to the server " + e.getMessage());
		}
	}
	
	public void testIR(String repeatCount,String AVName,String irDevice,String irName) {
		try {
			ip.sendMonitorMessage("<TEST_IR DEVICE=\""+irDevice+"\" ACTION=\"" + irName+"\" TARGET=\"" + AVName +"\" REPEAT=\"" +repeatCount +"\" />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the connection to the server " + e.getMessage());
		}		
	}

	public void sendIR(String messsage) {
		try {
			ip.sendMonitorMessage("<IR_CONFIG EXTRA=\""+messsage+"\" />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the connection to the server " + e.getMessage());
		}		
	}
	
	public void setIrNameField (String irName) {
		this.irName = irName;
	}
	
	public void startService() {
		try {
			if (ip != null)
				ip.sendAdminMessage ("<ADMIN COMMAND=\"START\" />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}
	}

	public void endService() {
		try {
			if (ip != null)
				ip.sendAdminMessage ("<ADMIN COMMAND=\"STOP\" />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}	
	}
	
	public void restartService() {
		try {
			if (ip != null)
				ip.sendAdminMessage ("<ADMIN COMMAND=\"RESTART\" />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}	
	}
	
	
	public void restartClient() {
		try {
			if (ip != null)
				ip.sendAdminMessage ("<ADMIN COMMAND=\"CLIENT_RESTART\" />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}	
	}
		
	/**
	 * @return Returns the connection.
	 */
	public ConnectionManager getConnection() {
		return connection;
	}

	public String getLogDir() {
		return logDir;
	}

}

