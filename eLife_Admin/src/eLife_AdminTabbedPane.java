/*
 * eLife_AdminToolPanel.java
 * part of the eLife_Admin plugin for the jEdit text editor
 */

import java.awt.event.*;

import javax.swing.*;

import org.gjt.sp.jedit.*;
import org.gjt.sp.jedit.gui.*;


public class eLife_AdminTabbedPane extends JTabbedPane
{
	private eLife_Admin eLife;
	private JLabel label;
	private LogPanel logPanel;
	private ControlsPanel controls;
	private IRPanel irPanel;
	private ConfigsPanel configs;
	private ScriptsPanel scripts;
	private ClientPanel client;
	private ServerLogPanel serverLogs;
	private ClientCorePanel clientCore;
	private DataFilesPanel dataFiles;
	private DebugLevelsPanel debugLevels;
	private JRobinRRDPanel jRobinRRDs;
	private JRobinGraphPanel jRobinGraph;
	
	public eLife_AdminTabbedPane(eLife_Admin eLife)
	{

		this.eLife = eLife;
		controls = new ControlsPanel (eLife);
		controls.setBorder(BorderFactory.createEmptyBorder(12,12,11,11));
		this.add("Controls",controls);

		logPanel = new LogPanel(eLife);
		this.add ("Log",logPanel);

		debugLevels = new DebugLevelsPanel (eLife);
		debugLevels.setBorder(BorderFactory.createEmptyBorder(12,12,11,11));
		this.add("Levels",debugLevels);

		irPanel = new IRPanel (eLife);
		irPanel.setBorder(BorderFactory.createEmptyBorder(12,12,11,11));
		this.add("IR",irPanel);
		
		configs = new ConfigsPanel (eLife);
		configs.setBorder(BorderFactory.createEmptyBorder(12,12,11,11));
		this.add("Configs",configs);

		scripts = new ScriptsPanel (eLife);
		scripts.setBorder(BorderFactory.createEmptyBorder(12,12,11,11));
		this.add("Scripts",scripts);

		dataFiles = new DataFilesPanel (eLife);
		dataFiles.setBorder(BorderFactory.createEmptyBorder(12,12,11,11));
		this.add("Data Files",dataFiles);

		client = new ClientPanel (eLife);
		client.setBorder(BorderFactory.createEmptyBorder(12,12,11,11));
		this.add("Client",client);

		clientCore = new ClientCorePanel (eLife);
		clientCore.setBorder(BorderFactory.createEmptyBorder(12,12,11,11));
		this.add("Client-Core",clientCore);

		jRobinRRDs = new JRobinRRDPanel (eLife);
		jRobinRRDs.setBorder(BorderFactory.createEmptyBorder(12,12,11,11));
		this.add("JRobin RRD",jRobinRRDs);

		jRobinGraph = new JRobinGraphPanel (eLife);
		jRobinGraph.setBorder(BorderFactory.createEmptyBorder(12,12,11,11));
		this.add("JRobin Graph",jRobinGraph);
		
		serverLogs = new ServerLogPanel (eLife);
		serverLogs.setBorder(BorderFactory.createEmptyBorder(12,12,11,11));
		this.add("Server Logs",serverLogs);
	}

	public LogPanel getLogPanel() {
		return logPanel;
	}

	public ControlsPanel getControlsPanel() {
		return controls;
	}

	public IRPanel getIRPanel() {
		return irPanel;
	}

	public ConfigsPanel getConfigsPanel () {
		return configs;
	}

	public DataFilesPanel getDataFilesPanel () {
		return dataFiles;
	}
	
	public ScriptsPanel getScriptsPanel () {
		return scripts;
	}

	public JRobinRRDPanel getJRobinRRDPanel () {
		return jRobinRRDs;
	}

	public JRobinGraphPanel getJRobinGraphPanel () {
		return jRobinGraph;
	}
	
	public ClientPanel getClientPanel () {
		return client;
	}
	
	public ClientCorePanel getClientCorePanel () {
		return clientCore;
	}
	
	void propertiesChanged()
	{
		// ip.connect (); FILL THIS IN
	}

	private AbstractButton makeCustomButton(String name, ActionListener listener)
	{
		String toolTip = jEdit.getProperty(name.concat(".label"));
		AbstractButton b = new RolloverButton(GUIUtilities.loadIcon(
			jEdit.getProperty(name + ".icon")));
		if(listener != null)
		{
			b.addActionListener(listener);
			b.setEnabled(true);
		}
		else
		{
			b.setEnabled(false);
		}
		b.setToolTipText(toolTip);
		return b;
	}


	/**
	 * @return Returns the debugLevels.
	 */
	public DebugLevelsPanel getDebugLevelsPanel() {
		return debugLevels;
	}

	public ServerLogPanel getServerLogPanel() {
		return serverLogs;
	}

	public void setServerLogPanel(ServerLogPanel serverLogs) {
		this.serverLogs = serverLogs;
	}
}

