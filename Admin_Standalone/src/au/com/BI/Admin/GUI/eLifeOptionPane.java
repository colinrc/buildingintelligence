package au.com.BI.Admin.GUI;
/*
 * eLife_AdminOptionPane.java
 */

import au.com.BI.Admin.Home.Project;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.Component;

import javax.swing.*;
import javax.swing.JDialog;

import java.text.NumberFormat;
import java.util.logging.*;
import java.util.Properties;
import java.io.File;

public class eLifeOptionPane extends JDialog
{
	protected JTextField serverIPField;
	protected JTextField editCMDField;
	protected JFormattedTextField monitorPortField;
	protected JFormattedTextField eLifePortField;
	protected NumberFormat portFormat;
	protected Logger logger;
	protected JPanel workDirPanel;
	protected Project properties;
	protected boolean updated = false;
	protected JFrame jFrame;

	public eLifeOptionPane(Project properties,JFrame frame)
	{
		super (frame,"Options",true);
		super.getContentPane().setLayout(new BoxLayout (super.getContentPane(),BoxLayout.Y_AXIS));
		logger = Logger.getLogger("Log");
		portFormat = NumberFormat.getIntegerInstance();
		this.properties = properties;
		this.jFrame = frame;

		JPanel ipBox = new JPanel();
		JLabel ipLabel = new JLabel ("eLife Server IP");
		ipBox.add (ipLabel);
		serverIPField = new JTextField(properties.getProperty(
				"ServerIP"));
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
			monitorPortField.setValue(Integer.decode(properties.getProperty(
				"MonitorPort")));
		} catch (NullPointerException ex) {
			monitorPortField.setValue(new Integer(10002));
		} catch (NumberFormatException ex) {
			monitorPortField.setValue(new Integer(10002));
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
			eLifePortField.setValue(Integer.decode(properties.getProperty(
				"eLifePort")));
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
		
		
		JPanel editCMDBox = new JPanel();
		JLabel ediCMDLabel = new JLabel ("Edit Command");
		editCMDBox.add (ediCMDLabel);
		String editCmd = properties.getProperty("EditCMD");
		if (editCmd == null) editCmd = "";
		editCMDField = new JTextField();
		editCMDBox.add (editCMDField);
		editCMDBox.setAlignmentX(Component.LEFT_ALIGNMENT);
		this.getContentPane().add (editCMDBox);
		
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
	}
	
	public void cancelChanges () {
		this.setVisible(false);
	}
	

	
	
	
	public void _save()
	{
		properties.setProperty(
				"ServerIP",serverIPField.getText());

		properties.setProperty(
				"EditCmd",editCMDField.getText());

		int monitorValue = ((Number)monitorPortField.getValue()).intValue();
		int eLifeValue = ((Number)eLifePortField.getValue()).intValue();
		properties.setProperty(
				"MonitorPort",Integer.toString(monitorValue));

		properties.setProperty(
				"eLifePort",Integer.toString(eLifeValue));


	}
	// end AbstractOptionPane implementation

	public boolean isUpdated() {
		return updated;
	}

	public void setUpdated(boolean updated) {
		this.updated = updated;
	}


}

