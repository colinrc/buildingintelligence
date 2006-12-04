package au.com.BI.Admin.Home;
/*
 * eLife_Admin.java
 * part of the eLife_Admin plugin for the jEdit text editor
 */

// from Java:

import au.com.BI.Admin.GUI.ControlsPanel;
import au.com.BI.Admin.GUI.DebugLevelsPanel;
import au.com.BI.Admin.GUI.IRPanel;
import au.com.BI.Admin.GUI.LogPanel;
import au.com.BI.Admin.GUI.eLifeOptionPane;
import au.com.BI.Admin.GUI.eLife_AdminTabbedPane;
import au.com.BI.Admin.GUI.eLife_AdminToolPanel;
import au.com.BI.Admin.comms.ConnectionManager;
import au.com.BI.Admin.comms.IP;
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
	private boolean floating;
	private JTextArea textArea;

	private eLife_AdminToolPanel toolPanel;
	private eLife_AdminTabbedPane tabPanel;
	private ConnectionManager connection;
	protected Logger logger;
	private IP ip;
	private String irName;
	protected boolean shownAdminConnectError = false;
	protected Properties properties = null;
	protected Project project;
	//
	// Constructor
	//

	
	public Admin(JFrame theView)
	{
		super(new BorderLayout());
		JFrame view = theView;
		project = new Project();
		logger = Logger.getLogger("Log");
	    String major_version = "0";
	    String minor_version = "0";
		
		Container contentsPane  = theView.getContentPane();
		

	    properties = new Properties();
	    try {
	    		properties.load(this.getClass().getResourceAsStream("my.properties"));
	    	    major_version = properties.getProperty("major_version");
	    	    minor_version = properties.getProperty("minor_version");
	    } catch (IOException e) {
	    }

	    try {
			project.getParameters ("","proj.properties");
		} catch (IOException e) {
		}
		

		this.tabPanel = new eLife_AdminTabbedPane(this);
		contentsPane.add(this.tabPanel,BorderLayout.CENTER);
		view.pack();
		view.setVisible(true);

		if (!project.getWorkDir().equals ("")) {
			tabPanel.getControlsPanel().updateSystemStatus("eLife V" + major_version + "." + minor_version + " Work Dir : " + project.getWorkDir());
		} else {
			tabPanel.getControlsPanel().updateSystemStatus("eLife V" + major_version + "." + minor_version + " Please set work directory");			
		}
		add(this.tabPanel,BorderLayout.CENTER);
		contentsPane.add(this);

		connection = new ConnectionManager (this);
		connection.connect(project.getServerIP(),project.getMonitorPort(),project.getAdminPort());
		connection.start();
	}
	
	public void showOptions () {
		JFrame.setDefaultLookAndFeelDecorated(true);
		JFrame frame = new JFrame ("Options");
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		eLifeOptionPane optionPane = new eLifeOptionPane (project,frame);
		optionPane.pack();
		optionPane.setVisible(true);

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

	public DebugLevelsPanel getDebugLevelsPanel () {
		return this.tabPanel.getDebugLevelsPanel();
	}
	
	public ControlsPanel getControlsPanel () {
		return this.tabPanel.getControlsPanel();
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
	

	
	public void doELifeConnectionStartup () {
		this.tabPanel.getDebugLevelsPanel().sendDebugLevels();
		getIRDevices();
	}
	
	public void doAdminConnectionStartup () {
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
			connection.connect(project.getServerIP(),project.getAdminPort(),project.getMonitorPort());
			connection.start();
		}
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

}

