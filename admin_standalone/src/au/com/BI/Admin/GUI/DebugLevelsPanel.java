package au.com.BI.Admin.GUI;
/*
 * Controls.java
 * part of the eLife_Admin plugin for the jEdit text editor
 */

import au.com.BI.Admin.Home.Admin;
import java.awt.*;
import java.awt.event.*;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.HashMap;
import javax.swing.*;



public class DebugLevelsPanel extends JPanel implements ActionListener
{
	private Admin eLife;
	private JPanel debugMenus;
	private Logger logger;
	private HashMap <String,Integer>debugMenuHash;


	public DebugLevelsPanel(Admin eLife)
	{

		this.eLife = eLife;
		logger = Logger.getLogger("Log");
		this.setLayout(new FlowLayout());
		this.setAlignmentX(LEFT_ALIGNMENT);
		debugMenuHash = new HashMap <String,Integer>(100);
		renderPanels();
	}
	
	public void renderPanels() {
		addDebugMenu ("BI", "au.com.BI","FINER");
		addDebugMenu ("Config", "au.com.BI.Config","FINER");
		addDebugMenu ("Comms", "au.com.BI.Comms");
		addDebugMenu ("Script", "au.com.BI.Script");
		addDebugMenu("Jetty", "au.com.BI.Jetty");
		addDebugMenu("Groovy", "au.com.BI.GroovyModels");
		addDebugMenu("IR Learner", "au.com.BI.IR");
		addDebugMenu("Macro", "au.com.BI.Macro");
		
		addDebugMenu("Comfort", "au.com.BI.Comfort");
		addDebugMenu("Raw", "au.com.BI.Raw");
		addDebugMenu("Client", "au.com.BI.Flash");
		addDebugMenu("Admin", "au.com.BI.Admin");
		addDebugMenu("HAL", "au.com.BI.HAL");
		addDebugMenu("Tutondo", "au.com.BI.Tutondo");
		addDebugMenu("CBUS", "au.com.BI.CBUS");
		addDebugMenu("Kramer", "au.com.BI.Kramer");
		addDebugMenu("Nuvo", "au.com.BI.Nuvo");
		addDebugMenu("GC100", "au.com.BI.GC100");
		addDebugMenu("Oregon", "au.com.BI.OregonScientific");
		addDebugMenu("Slim Server", "au.com.BI.MultiMedia.SlimServer");
		addDebugMenu("Autonomic", "au.com.BI.MultiMedia.AutonomicHome");		
		addDebugMenu("JRobin", "au.com.BI.JRobin");
		addDebugMenu("Pelco", "au.com.BI.Pelco");
		addDebugMenu("DynaLite", "au.com.BI.Dynalite");
		addDebugMenu("M1", "au.com.BI.M1");

	}

	public void sendDebugLevels () {
		for (String nextPackage:debugMenuHash.keySet()){
			Integer theLevel = (Integer)debugMenuHash.get (nextPackage);
			sendTheLevel (theLevel.intValue(),nextPackage);
		}
	}
		
	private class ClearMenus implements Runnable {
		private JPanel jPanel;

		public ClearMenus(JPanel jPanel) {
			this.jPanel = jPanel;
		}
		public void run() { jPanel.removeAll (); jPanel.validate(); }
	}
	
	public void clearDebugMenus() {
		ClearMenus clear = new ClearMenus (this);
		debugMenuHash.clear();
		SwingUtilities.invokeLater(clear);
	}

	
	private class ValidateMenu implements Runnable {
		private JPanel jPanel;

		public ValidateMenu(JPanel jPanel) {
			this.jPanel = jPanel;
		}
		public void run() { jPanel.revalidate(); }
	}
		
	
	public void validateMenus() {
		ValidateMenu validate = new ValidateMenu (this);
		SwingUtilities.invokeLater(validate);
	}

	
	private class AddMenu implements Runnable {
		private JPanel jPanel;
		private JPanel overallPanel;

		public AddMenu(JPanel jPanel, JPanel overallPanel) {
			this.jPanel = jPanel;
			this.overallPanel = overallPanel;
		}
		public void run() { overallPanel.add (jPanel); }
	}
	
	public void addDebugMenu(String shortName,String packageName) {
		addDebugMenu (shortName,packageName,"INFO");
	}

	public void addDebugMenu(String shortName,String packageName,String level) {
		String[] debugLevels = { "Warning" , "Info", "Fine", "Finer", "Finest" };
		
		JPanel eachBox = new JPanel();
		eachBox.setLayout (new BoxLayout (eachBox, BoxLayout.Y_AXIS));
		
		JComboBox debugLevelList = new JComboBox(debugLevels);
		debugLevelList.setName(packageName);
		
		int theSelection = -1;
		if (level.equals ("WARNING")) theSelection = 0;
		if (level.equals ("INFO")) theSelection = 1;
		if (level.equals ("FINE")) theSelection = 2;
		if (level.equals ("FINER")) theSelection = 3;
		if (level.equals ("FINEST")) theSelection = 4;
		debugLevelList.setSelectedIndex(theSelection);
		debugMenuHash.put(packageName,new Integer(theSelection));
		debugLevelList.setBorder(BorderFactory.createEtchedBorder() );
		JLabel title = new JLabel ();
		title.setText(shortName);
		eachBox.add(title);

		debugLevelList.addActionListener(this);
		eachBox.add (debugLevelList);
		AddMenu addMenu = new AddMenu (eachBox, this);

		SwingUtilities.invokeLater(addMenu);
	}
	
	
	public void actionPerformed(ActionEvent e) {
	    	JComboBox list = (JComboBox)e.getSource();
		list.setActionCommand("DEBUG");
		
		String packageName = list.getName();
		int theSelection =list.getSelectedIndex(); 
		debugMenuHash.put(packageName,new Integer(theSelection));

		sendTheLevel (theSelection,packageName);
		
	}
	
	public void sendTheLevel (int theSelection, String packageName) {
		if (theSelection == -1) {
			logger.log (Level.INFO,"Disabling debug for package " + packageName);
			Logger.getLogger(packageName).setLevel (Level.WARNING);
		} else {
    		Level newLevel = Level.WARNING;
    		switch (theSelection) {
			case 0 : newLevel = Level.WARNING; break;
			case 1 : newLevel = Level.INFO; break;
    			case 2 : newLevel = Level.FINE; break;
    			case 3 : newLevel = Level.FINER; break;
    			case 4 : newLevel = Level.FINEST; break;
    		}
		logger.log (Level.INFO,"Setting debug " + newLevel + " for package " + packageName);
		try {
			synchronized (eLife) {
				eLife.sendELifeMessage ("<DEBUG PACKAGE=\"" + packageName + "\" LEVEL=\"" + newLevel.getName() +"\" />\n");
			}
		} catch (IOException ex) {
			logger.log (Level.WARNING,"Error in the monitor connection " + ex.getMessage());
			synchronized (eLife) {
				eLife.disconnect_eLife();

			}				
		}
	}

	}
}

