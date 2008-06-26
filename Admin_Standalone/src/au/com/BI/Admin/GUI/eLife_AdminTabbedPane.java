package au.com.BI.Admin.GUI;
/*
 * eLife_AdminToolPanel.java
 * part of the eLife_Admin plugin for the jEdit text editor
 */

import au.com.BI.Admin.Home.Admin;

import javax.swing.*;

public class eLife_AdminTabbedPane extends JTabbedPane
{
	private Admin eLife;
	private JLabel label;
	private LogPanel logPanel;
	private ControlsPanel controls;
	private IRPanel irPanel;
	private DebugLevelsPanel debugLevels;
	
	public eLife_AdminTabbedPane(Admin eLife)
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

	
	void propertiesChanged()
	{
		// ip.connect (); FILL THIS IN
	}

	/**
	 * @return Returns the debugLevels.
	 */
	public DebugLevelsPanel getDebugLevelsPanel() {
		return debugLevels;
	}

}

