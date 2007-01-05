package au.com.BI.Admin.GUI;
/*
 * eLife_AdminOptionPane.java
 */

import au.com.BI.Admin.Home.Admin;
import au.com.BI.Admin.Home.Project;
import au.com.BI.Admin.comms.ConnectionManager;

import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.Component;

import javax.swing.*;

import java.text.NumberFormat;
import java.util.logging.*;
import java.util.Properties;
import java.io.File;

public class eLifeOptionPane extends JDialog
{
	protected JTextField serverIPField;
	protected JFormattedTextField monitorPortField;
	protected JFormattedTextField eLifePortField;
	protected NumberFormat portFormat;
	protected Logger logger;
	protected JPanel workDirPanel;
	protected Project properties;
	protected boolean updated = false;
	protected JFrame jFrame;
	protected Admin admin  = null;

	public eLifeOptionPane(Project properties,JFrame frame, Admin admin)
	{
		super (frame,"Options",true);
		this.admin = admin;
		super.getContentPane().setLayout(new BoxLayout (super.getContentPane(),BoxLayout.Y_AXIS));
		logger = Logger.getLogger("Log");
		portFormat = NumberFormat.getNumberInstance();
		portFormat.setGroupingUsed(false);
		this.properties = properties;
		this.jFrame = frame;

		JPanel ipBox = new JPanel();
		JLabel ipLabel = new JLabel ("eLife Server IP");
		ipBox.add (ipLabel);
		String serverIP = properties.getServerIP();
		serverIPField = new JTextField(serverIP);
		serverIPField.setColumns(15);
		ipBox.add (serverIPField);
		ipBox.setAlignmentX(Component.LEFT_ALIGNMENT);
		this.getContentPane().add (ipBox);
		
		JPanel monitorBox = new JPanel();
		JLabel monitorLabel = new JLabel ("eLife Monitor Port");
		monitorBox.add (monitorLabel);
		monitorPortField = new JFormattedTextField(portFormat);
		monitorPortField.setColumns(8);

		try {
			monitorPortField.setText(Integer.toString(properties.getMonitorPort()));
		} catch (NullPointerException ex) {
			monitorPortField. setValue(10002);
		} catch (NumberFormatException ex) {
			monitorPortField.setValue(10002);
		} catch (IllegalArgumentException ex) {
			logger.log (Level.WARNING,"Could not set monitor port option " + ex.getMessage());
		}
		monitorBox.add (monitorPortField);
		monitorBox.setAlignmentX(Component.LEFT_ALIGNMENT);
		this.getContentPane().add (monitorBox);
		
		JPanel eLifeBox = new JPanel();
		JLabel eLifeLabel = new JLabel ("eLife Port");
		eLifeBox.add (eLifeLabel);
		
		eLifePortField = new JFormattedTextField(portFormat);
		eLifePortField.setColumns(8);
		try {
			eLifePortField.setText(Integer.toString(properties.getAdminPort()));
		} catch (NullPointerException ex) {
			logger.log (Level.WARNING,"eLife port property is incorrect " + ex.getMessage());
			eLifePortField.setValue(new Integer(10001));
		} catch (NumberFormatException ex) {
			logger.log (Level.WARNING,"eLife port property is incorrect " + ex.getMessage());
			eLifePortField.setValue(new Integer(10001));
		} catch (IllegalArgumentException ex) {
			logger.log (Level.WARNING,"Could not set eLife port option " + ex.getMessage());
		}
		eLifeBox.add (eLifePortField);
		eLifeBox.setAlignmentX(Component.LEFT_ALIGNMENT);
		this.getContentPane().add (eLifeBox);
		
		
		JPanel confirmBox = new JPanel();
		JButton confirmButton = new JButton("Apply");
		confirmButton.addActionListener(
				new ActionListener() {
					public void actionPerformed(ActionEvent evt) {
						applyChanges();
					}
				});
		confirmBox.add (confirmButton);
		
		JButton cancelButton = new JButton("Cancel");
		cancelButton.addActionListener(
				new ActionListener() {
					public void actionPerformed(ActionEvent evt) {
						cancelChanges();
					}
				});
		confirmBox.add (cancelButton);
		confirmBox.setAlignmentX(Component.LEFT_ALIGNMENT);
		this.getContentPane().add (confirmBox);
	}

	public void applyChanges () {
		this._save();
		this.setVisible(false);		
		admin.propertiesChanged();
	}
	
	public void cancelChanges () {
		this.setVisible(false);
		admin.connection.setUpdatingParams(false);
	}
	

	
	
	
	public void _save()
	{
		properties.setServerIP(serverIPField.getText());

		int monitorValue = (Integer.parseInt(monitorPortField.getText()));
		properties.setMonitorPort(monitorValue);
		int eLifeValue = (Integer.parseInt(eLifePortField.getText()));
		properties.setAdminPort(eLifeValue);
		updated = true;


	}
	// end AbstractOptionPane implementation

	public boolean isUpdated() {
		return updated;
	}

	public void setUpdated(boolean updated) {
		this.updated = updated;
	}


}

