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

// from jEdit:
import org.gjt.sp.jedit.*;
import org.gjt.sp.jedit.gui.*;
import org.gjt.sp.jedit.msg.*;
import org.gjt.sp.jedit.browser.VFSBrowser;


public class eLife_Admin extends JPanel implements EBComponent, eLife_AdminActions, DefaultFocusComponent
{
	private String serverIP = "127.0.0.1";
	private int defaultMonitorPort = 10002;
	private int defaultAdminPort = 10001;
	private int monitorPort = defaultMonitorPort;
	private int adminPort = defaultAdminPort;
	private String workingDir;

	private boolean floating;
	private JTextArea textArea;

	private eLife_AdminToolPanel toolPanel;
	private eLife_AdminTabbedPane tabPanel;
	private ConnectionManager connection;
	protected Logger logger;
	private IP ip;
	protected View view;
	protected String workDir = "";;
	private String irName;
	protected String logDir = "log";
	protected boolean shownAdminConnectError = false;
	
	//
	// Constructor
	//

	public eLife_Admin(View theView, String position)
	{		
		
		super(new BorderLayout());

		view = theView;
		this.floating  = position.equals(DockableWindowManager.FLOATING);
		EditBus.addToBus(this);
		logger = Logger.getLogger("Log");

		getParameters ();
		
	    Properties properties = new Properties();
	    try {
	    		properties.load(this.getClass().getResourceAsStream("my.properties"));
	    } catch (IOException e) {
	    }
	       
	    String major_version = properties.getProperty("major_version");
	    String minor_version = properties.getProperty("minor_version");
		
		this.tabPanel = new eLife_AdminTabbedPane(this);
		if (!workDir.equals ("")) {
			tabPanel.getControlsPanel().updateSystemStatus("eLife Admin V" + major_version + "." + minor_version + ": Work Dir : " + workDir);
		} else {
			tabPanel.getControlsPanel().updateSystemStatus("eLife Admin V" + major_version + "." + minor_version + ": Please set work directory");			
		}
		add(this.tabPanel,BorderLayout.CENTER);

		
		connection = new ConnectionManager (this);
		connection.connect(serverIP,adminPort,monitorPort);
		connection.start();
		
	}
	
	public eLife_Admin(JFrame theView, String position)
	{
		super(new BorderLayout());
		JFrame view = theView;
		
		logger = Logger.getLogger("Log");
		
		this.floating  = position.equals(DockableWindowManager.FLOATING);
		Container contentsPane  = theView.getContentPane();
		
		getParameters ();

		this.tabPanel = new eLife_AdminTabbedPane(this);
		contentsPane.add(this.tabPanel,BorderLayout.CENTER);
		view.pack();
		view.setVisible(true);

		connection = new ConnectionManager (this);
		connection.connect(serverIP,adminPort,monitorPort);
		connection.start();
	}
	
	public void createWorkingDir (String workDir,String serverIP) {
		if (workDir.equals ("")) {
			setCWD();
		}
		Calendar now = Calendar.getInstance();
		String timeStamp = now.get(Calendar.DATE) + "." + now.get (Calendar.MONTH) + "." + now.get (Calendar.YEAR);
		workingDir = workDir + "/" + serverIP;
		File newDir = new File (workingDir);
		newDir.mkdirs();
	}
	
	public void setCWD () {
		String results[] = GUIUtilities.showVFSFileDialog(view,workDir,
					VFSBrowser.CHOOSE_DIRECTORY_DIALOG,false);
		if (results.length > 0) {
			workDir = results[0];
			jEdit.setProperty(
					eLifePlugin.OPTION_PREFIX + "WorkDir",
					workDir);
			this.getControlsPanel().updateSystemStatus("Working Dir : " + workDir);
			this.createWorkingDir(workDir,serverIP);
		}
	}
	
	private class LoadBuffer implements Runnable {
		String file;
		Buffer newBuffer;
		
		public LoadBuffer  (Buffer newBuffer, String file) {
			this.file = file;
			this.newBuffer = newBuffer;
		}
		public void run() { 
			newBuffer.insert(0,file);	
		}
	}
	
	public void createFileBuffer (String theFile,String dir, String sourceName,boolean load) {
		if (theFile != null) {
			Buffer newBuffer = null;
			if (load) {
				newBuffer = jEdit.newFile(view);
				if (newBuffer == null) {
					return;
				}
				
				LoadBuffer loader = new LoadBuffer (newBuffer,theFile);
				try {
					SwingUtilities.invokeAndWait(loader);
				} catch (InterruptedException e) {
				} catch (InvocationTargetException e) {
				}
			}

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
			
			if (load) {
				newBuffer.save(view,fullPath,true);
			} else {
				try {
					File newFile = new File (fullPath);
					if (!newFile.exists () || newFile.canWrite()) {
						FileWriter outFile = new FileWriter (newFile);
						outFile.write(theFile);
						outFile.close();
					}
				} catch (IOException ex) {
					logger.log (Level.WARNING,"Could not write file " + fullPath);
				}
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
				ip.sendDebugMessage ("<IR_LEARN NAME=\"" + irName + "\" />\n");
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
	
	protected boolean getParameters () {
		String oldServerIP = this.serverIP;
		String oldWorkDir = this.workDir;
		int oldAdminPort = this.adminPort;
		int oldMonitorPort = this.monitorPort;
		
		if(jEdit.getSettingsDirectory() != null)
		{
			this.serverIP = jEdit.getProperty(
				eLifePlugin.OPTION_PREFIX + "ServerIP");
			if(this.serverIP == null || this.serverIP.length() == 0)
			{
				this.serverIP = "127.0.0.1";
				jEdit.setProperty(
					eLifePlugin.OPTION_PREFIX + "ServerIP",
					this.serverIP);
			}
			String adminPortStr = jEdit.getProperty(
					eLifePlugin.OPTION_PREFIX + "MonitorPort");
			if(adminPortStr == null || adminPortStr.length() == 0)
			{
				adminPort = defaultAdminPort;
				adminPortStr = String.valueOf(adminPort);
				jEdit.setProperty(
					eLifePlugin.OPTION_PREFIX + "MonitorPort",
					adminPortStr);
			}
			try {
				adminPort = Integer.parseInt(adminPortStr);
			} catch (NumberFormatException ex) {
				logger.log (Level.WARNING,"Could not parse monitor port property " + ex.getMessage());
				adminPort = defaultAdminPort;
			}

			
			
			String monitorPortStr = jEdit.getProperty(
					eLifePlugin.OPTION_PREFIX + "eLifePort");
			if(monitorPortStr == null || monitorPortStr.length() == 0)
			{
				monitorPort = defaultMonitorPort;
				monitorPortStr = String.valueOf(monitorPort);
				jEdit.setProperty(
					eLifePlugin.OPTION_PREFIX + "eLifePort",
					adminPortStr);
			}
			try {
				monitorPort = Integer.parseInt(monitorPortStr);
			} catch (NumberFormatException ex) {
				logger.log (Level.WARNING,"Could not parse eLife port property " + ex.getMessage());
				monitorPort = defaultMonitorPort;
			}
			this.workDir = jEdit.getProperty(
					eLifePlugin.OPTION_PREFIX + "WorkDir");
			if(this.workDir == null || this.workDir.length() == 0)
				{
					this.workDir = "";
					jEdit.setProperty(
							eLifePlugin.OPTION_PREFIX + "WorkDir",
							workDir);
				}

		}
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
				ip.sendMonitorMessage ("<ADMIN COMMAND=\"ARBITRARY\" EXTRA=\"" + command + "\" />\n");
			}
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}
		
	}

	public void getIRActions (String device) {
		try {
			if (ip != null) {
				ip.sendDebugMessage("<LIST_IR_ACTIONS DEVICE=\"" + device + "\" />\n");					
			}
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the server connection " + e.getMessage());
		}
	}
	

	public void getIRDevices () {
		try {
			if (ip != null) {
				ip.sendDebugMessage("<LIST_IR_DEVICES />\n");					
			}
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the server connection " + e.getMessage());
		}
	}
	
	public void readFiles (String dir) {
		try {
			if (ip != null) {
				if (dir.endsWith("script")) {
					ip.sendMonitorMessage ("<ADMIN COMMAND=\"LIST\" DIR=\"" + dir + "\" FILTER=\".py\" />\n");
				} else {
					ip.sendMonitorMessage ("<ADMIN COMMAND=\"LIST\" DIR=\"" + dir + "\" FILTER=\".xml\" />\n");					
				}
			}
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}
	}

	public void readFiles (String dir,String filter) {
		try {
			if (ip != null) {
				ip.sendMonitorMessage ("<ADMIN COMMAND=\"LIST\" DIR=\"" + dir + "\" FILTER=\"" + filter + "\" />\n");
			}
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}
	}

	public void downloadClientXML () {
		try {
			if (ip != null)
				ip.sendMonitorMessage ("<ADMIN COMMAND=\"DOWNLOAD\" DIR=\"client\" EXTRA=\"client.xml\" />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}		
	}
	
	public void downloadFile (String dir, String fileName) {
		try {
			if (ip != null)
				ip.sendMonitorMessage ("<ADMIN COMMAND=\"DOWNLOAD\" DIR=\"" + dir + "\" EXTRA=\"" + fileName + "\" />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}		
	}
	
	public void setStartup (String configFile) {
		try {
			if (ip != null)
				ip.sendMonitorMessage ("<ADMIN COMMAND=\"SELECT\" EXTRA=\"" + configFile + "\" />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}
	}
	
	public void deleteFile (String dir, String configFile) {
		try {
			if (ip != null)
				ip.sendMonitorMessage ("<ADMIN COMMAND=\"DELETE\" DIR=\"" + dir + "\" EXTRA=\"" + configFile + "\" />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}
	}
	
	public void uploadFile(String dir, boolean base64) {
		View currentView = jEdit.getActiveView();
		if (currentView != null) {
			Buffer currentBuffer = currentView.getBuffer();
			if (!currentBuffer.isDirty()) {
				currentBuffer.readLock();
				String fileName = currentBuffer.getName();
				String fileContents = currentBuffer.getText (0,currentBuffer.getLength());
				String newFileContents = "";
				if (base64) {
					newFileContents = Base64Coder.encode(fileContents);
				}
				currentBuffer.readUnlock();
				try {
					if (base64)
						ip.sendMonitorMessage ("<ADMIN COMMAND=\"UPLOAD\" BASE64=\"Y\" NAME=\"" + fileName + "\" DIR=\"" + dir + "\" ><![CDATA[" + newFileContents + "]]></ADMIN>\n");
					else 
						ip.sendMonitorMessage ("<ADMIN COMMAND=\"UPLOAD\" BASE64=\"N\" NAME=\"" + fileName + "\" DIR=\"" + dir + "\" ><![CDATA[" + fileContents + "]]></ADMIN>\n");
				}
				catch (IOException e) {
					logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());					
				}
			} else {
				this.getConfigsPanel().setResults ("You must save the buffer before you can upload it");
			}
		}
	}
	
	public void uploadClientXML() {
		View currentView = jEdit.getActiveView();
		if (currentView != null) {
			Buffer currentBuffer = currentView.getBuffer();
			if (!currentBuffer.isDirty()) {
				currentBuffer.readLock();
				String fileName = currentBuffer.getName();
				String fileContents = currentBuffer.getText (0,currentBuffer.getLength());
				currentBuffer.readUnlock();
				try {
					ip.sendMonitorMessage ("<ADMIN COMMAND=\"UPLOAD\" NAME=\"client.xml\" DIR=\"client\" ><![CDATA[" + fileContents + " ]]></ADMIN>\n");
				}
				catch (IOException e) {
					logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());					
				}
			} else {
				this.getConfigsPanel().setResults ("You must save the buffer before you can upload it");
			}
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
	
	public void focusOnDefaultComponent()
	{
		if (textArea != null) textArea.requestFocus();
	}

	//
	// Attribute methods
	//


	//
	// EBComponent implementation
	//

	public void handleMessage(EBMessage message)
	{
		Object sourceClassObj = message.getSource();
		if (sourceClassObj != null) {
			try {
				EditPlugin sourcePlugin = (EditPlugin)sourceClassObj;
				if (!sourcePlugin.getClassName().startsWith("eLifePlugin"))
					return;
			} catch (ClassCastException e) {
				String message2 = e.getMessage();
			}
		}

		if (message instanceof PropertiesChanged)
		{
			propertiesChanged();
		}
		if (message instanceof EditorExiting)
		{
			this.disconnect(false);
		}

		if (message instanceof PluginUpdate)
		{
			if (((PluginUpdate)message).getWhat() == PluginUpdate.DEACTIVATED) {
				this.disconnect(false);
			}
		}
		if (message instanceof PluginUpdate)
		{
			if (false && ((PluginUpdate)message).getWhat() == PluginUpdate.ACTIVATED) {
				this.disconnect(false);
				
				connection = new ConnectionManager (this);
				connection.connect(serverIP,adminPort,monitorPort);
				connection.start();
			}
		}		
		if (message instanceof PluginUpdate)
		{
			if (((PluginUpdate)message).getWhat() == PluginUpdate.UNLOADED) {
				this.disconnect(false);
			}
		}
	
		if (message instanceof DockableWindowUpdate && false)
		{
			if (((DockableWindowUpdate)message).getWhat() == DockableWindowUpdate.PROPERTIES_CHANGED) {
				this.disconnect();
			}
		}

	}

	protected void propertiesChanged() {
		boolean anyChange = this.getParameters();	
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

	// These JComponent methods provide the appropriate points
	// to subscribe and unsubscribe this object to the EditBus

	public void addNotify()
	{
		super.addNotify();
		EditBus.addToBus(this);
	}


	public void removeNotify()
	{
		super.removeNotify();
		EditBus.removeFromBus(this);
	}


	/*
	public void copyToBuffer()
	{
		jEdit.newFile(view);
		view.getEditPane().getTextArea().setText(textArea.getText());
	}
*/

	//
	// Listener objects
	//


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
			ip.sendDebugMessage("<RELOAD_SCRIPTS />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the connection to the server " + e.getMessage());
		}
	}
	
	public void reloadMacros() {
		try {
			ip.sendDebugMessage("<RELOAD_MACROS />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the connection to the server " + e.getMessage());
		}
	}

	public void reloadIRDB() {
		try {
			ip.sendDebugMessage("<RELOAD_IRDB />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the connection to the server " + e.getMessage());
		}
	}
	
	public void testIR(String repeatCount,String AVName,String irDevice,String irName) {
		try {
			ip.sendDebugMessage("<TEST_IR DEVICE=\""+irDevice+"\" ACTION=\"" + irName+"\" TARGET=\"" + AVName +"\" REPEAT=\"" +repeatCount +"\" />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the connection to the server " + e.getMessage());
		}		
	}

	public void sendIR(String messsage) {
		try {
			ip.sendDebugMessage("<IR_CONFIG EXTRA=\""+messsage+"\" />\n");
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
				ip.sendMonitorMessage ("<ADMIN COMMAND=\"START\" />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}
	}

	public void endService() {
		try {
			if (ip != null)
				ip.sendMonitorMessage ("<ADMIN COMMAND=\"STOP\" />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}	
	}
	
	public void restartService() {
		try {
			if (ip != null)
				ip.sendMonitorMessage ("<ADMIN COMMAND=\"RESTART\" />\n");
		} catch (IOException e) {
			logger.log (Level.WARNING,"Error in the admin connection " + e.getMessage());
		}	
	}
	
	
	public void restartClient() {
		try {
			if (ip != null)
				ip.sendMonitorMessage ("<ADMIN COMMAND=\"CLIENT_RESTART\" />\n");
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

