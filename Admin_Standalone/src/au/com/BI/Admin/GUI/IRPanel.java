package au.com.BI.Admin.GUI;
/*
 * Controls.java
 * part of the eLife_Admin plugin for the jEdit text editor
 */

import au.com.BI.Admin.Home.Admin;
import java.awt.*;
import java.util.*;
import java.awt.event.*;
import java.util.logging.Logger;

import javax.swing.*;

public class IRPanel extends JPanel
{
	private Admin eLife;
	private JButton learnIR;
	private JButton cancelIR;
	//private JTextField irDevice;
	private JComboBox irDevice;
	//private JTextField irName;
	private JComboBox irName;
	private Logger logger;
	private boolean connected = false;
	private JLabel systemStatusLabel;
	protected JTextField repeatCount = null;
	private boolean nameSet = false;
	protected JTextField AVName = null;

	private Vector<String> learntActions;
	private Vector<String> learntDevices;

	public IRPanel(Admin eLife)
	{

		this.eLife = eLife;
		logger = Logger.getLogger("Log");
		this.setLayout(new BorderLayout());
		learntActions = new Vector<String>();
		learntDevices = new Vector<String>();
		
		JPanel deviceSelect = new JPanel();
		deviceSelect.setLayout (new FlowLayout (FlowLayout.LEADING));
		
		JPanel devicePanel = new JPanel ();
		devicePanel.setLayout (new BoxLayout (devicePanel, BoxLayout.Y_AXIS));
		JLabel deviceLabel = new JLabel ("Device");
		deviceLabel.setHorizontalAlignment(SwingConstants.LEFT);
		devicePanel.add (deviceLabel);

		irDevice = new JComboBox();
		irDevice.setEditable(true);
		irDevice.setMaximumRowCount(10);
		//irDevice.setPopupVisible(true);
		irDevice.setToolTipText("Type device name and press Enter");
		irDevice.addActionListener(
				new ActionListener () {
					public void actionPerformed(ActionEvent evt) {
						//if (evt.getActionCommand().equals ("comboBoxEdited")){
							//irName.setText("");
							irName.setSelectedIndex(-1);
							irName.removeAllItems();
							synchronized (learntActions){
								learntActions.clear();
							}
							irName.requestFocus();
							systemStatusLabel.setText("Retrieving known actions for " + (String)irDevice.getSelectedItem());
							IRPanel.this.eLife.getIRActions((String)irDevice.getSelectedItem());
						//}
					}					
				});
		devicePanel.add(irDevice);
		deviceSelect.add(devicePanel);

		deviceSelect.add (Box.createHorizontalStrut(5));


		JPanel actionPanel = new JPanel ();
		actionPanel.setLayout (new BoxLayout (actionPanel, BoxLayout.Y_AXIS));
		JLabel actionLabel = new JLabel ("Action");
		actionLabel.setHorizontalAlignment(SwingConstants.LEFT);
		actionPanel.add (actionLabel);
		
		irName = new JComboBox();
		irName.setToolTipText("Type action name and press Enter");
		irName.setEditable(true);
		irName.setMaximumRowCount(10);
		//irName.setPopupVisible(true);
		irName.addActionListener(
				new ActionListener () {
					public void actionPerformed(ActionEvent evt) {
						if (evt.getActionCommand().equals ("comboBoxEdited")){
							doIRLearn();
						}
						if (evt.getActionCommand().equals ("comboBoxChanged")){
						}

					}					
				});
		actionPanel.add(irName);
		deviceSelect.add(actionPanel);
		deviceSelect.add (Box.createHorizontalStrut(5));

		JPanel extraControls = new JPanel();
		extraControls.setLayout (new FlowLayout (FlowLayout.LEADING));
		
		JPanel buttons1 = new JPanel();
		buttons1.setLayout (new BoxLayout (buttons1, BoxLayout.Y_AXIS));
		
		JButton learnIR = new JButton("Learn IR");
		learnIR.addActionListener(
				new ActionListener () {
					public void actionPerformed(ActionEvent evt) {
						doIRLearn();
					}					
				});
		buttons1.add(learnIR);	
		
		cancelIR = new JButton("Cancel IR Learn");
		cancelIR.addActionListener(
				new ActionListener () {
					public void actionPerformed(ActionEvent evt) {
						IRPanel.this.setIRLearn(true);
						IRPanel.this.updateSystemStatus("");
					}					
				});
		buttons1.add(cancelIR);	
		

		extraControls.add(buttons1);

		JPanel testGroup = new JPanel();
		testGroup.setLayout (new BoxLayout (testGroup, BoxLayout.Y_AXIS));
		
		JPanel test = new JPanel();
		JButton testButton = new JButton("Test");
		testButton.addActionListener(
			new ActionListener() {
				public void actionPerformed(ActionEvent evt) {
					IRPanel.this.eLife.testIR(repeatCount.getText(),AVName.getText(),(String)irDevice.getSelectedItem(),(String)irName.getSelectedItem());
				}
			});
		repeatCount = new JTextField();
		repeatCount.setColumns(1);
		repeatCount.setText("1");
		repeatCount.setToolTipText("Enter the number of times to repeat the IR string");
		test.add(testButton);
		JLabel repLabel = new JLabel ("Repeat");
		test.add(repLabel);
		test.add(repeatCount);
		testGroup.add(test);
		
		
		AVName = new JTextField();
		AVName.setText ("AV.STUDY_IR");
		AVName.setToolTipText("Enter the name of a the IR device you have configured.");
		testGroup.add(AVName);

		JPanel timeoutPanel = new JPanel();
		timeoutPanel.setLayout(new FlowLayout());
		JLabel endLabel = new JLabel("End value");
		endLabel.setToolTipText("Enter the end value for the IR learner.");
        JRadioButton a = new JRadioButton("20");
        JRadioButton b = new JRadioButton("35");
        JRadioButton c = new JRadioButton("50");
        JRadioButton d = new JRadioButton("100");
        
        ButtonGroup group = new ButtonGroup();
        group.add(a);
        group.add(b);
        group.add(c);
        group.add(d);

		a.addActionListener(			
			new ActionListener() {
			public void actionPerformed(ActionEvent evt) {
				IRPanel.this.eLife.sendIR("20");
			}
		});
		b.addActionListener(			
				new ActionListener() {
				public void actionPerformed(ActionEvent evt) {
					IRPanel.this.eLife.sendIR("35");
				}
			});
		c.addActionListener(			
				new ActionListener() {
				public void actionPerformed(ActionEvent evt) {
					IRPanel.this.eLife.sendIR("50");
				}
			});
		d.addActionListener(			
				new ActionListener() {
				public void actionPerformed(ActionEvent evt) {
					IRPanel.this.eLife.sendIR("100");
				}
			});
		timeoutPanel.add(endLabel);
		timeoutPanel.add(a);
		timeoutPanel.add(b);
		timeoutPanel.add(c);
		timeoutPanel.add(d);
		
		testGroup.add(timeoutPanel);
		
		extraControls.add(testGroup);

		extraControls.add (Box.createHorizontalStrut(5));

		JPanel systemStatus = new JPanel ();
		
		systemStatus.setLayout (new FlowLayout (FlowLayout.LEADING));
		systemStatusLabel = new JLabel();
		systemStatus.add (systemStatusLabel);		
			
		JPanel allButtons = new JPanel();
		allButtons.setLayout (new BoxLayout (allButtons, BoxLayout.Y_AXIS));
		allButtons.add(deviceSelect);		
		allButtons.add(extraControls);		
		allButtons.add(systemStatus);		
		add(allButtons,BorderLayout.NORTH);
	}

	public void doIRLearn() {
		IRPanel.this.setIRLearn(false);
		String actionName = (String)irName.getSelectedItem();
		if (actionName.equals ("")){
			return;
		}
		String name = (String)irDevice.getSelectedItem() + "." + actionName;
		IRPanel.this.updateSystemStatus("Learning " + name);
		IRPanel.this.eLife.learnIR(name);
		synchronized (learntActions){
			if (!learntActions.contains(actionName)){
				learntActions.add(actionName);
				irName.addItem(actionName);
			}
		}
	}
	
	public void setIRLearn (boolean state) {
		if (nameSet)
			learnIR.setEnabled (state);
	}
	
	public void clearIRLearn () {
		learnIR.setEnabled (true);
	}
	
	public void nextInstruction() {
		SwingUtilities.invokeLater(
				new Runnable () {
						public void run() {
							irName.requestFocus(); 
							//irName.selectAll();
							//irName.setSelectedIndex(-1);
						} 
				});
	}
	
	public void setLearntMessage(String message) {
		updateSystemStatus (message);
	}
	
	public void clear (){
	}
	
	
	private class UpdateSystemStatusMessage implements Runnable {
		String message;
		public UpdateSystemStatusMessage (String message) {
			this.message = message;
		}
		    public void run() { systemStatusLabel.setText(message); }
	}
		
	public void updateSystemStatus (String message) {
		UpdateSystemStatusMessage update = new UpdateSystemStatusMessage (message);
			SwingUtilities.invokeLater(update);
	}
	
	private class UpdateActionList implements Runnable {
		Vector <String>actions;
		public UpdateActionList (Vector <String>actions) {
			this.actions = actions;
		}
		
		public void run() { 
		    	systemStatusLabel.setText("Received action list for " + irDevice.getSelectedItem());
			irName.removeAllItems();
		    	synchronized (learntActions){
		    		learntActions = actions;
		    		for (String nextAction:actions){
			    		irName.addItem(nextAction);
			    	}
		    		
		    	}
		   irName.repaint();
	   }
	}
		
	public void updateActionList (Vector <String>actions) {
		UpdateActionList update = new UpdateActionList (actions);
			SwingUtilities.invokeLater(update);
	}
	
	private class UpdateDeviceList implements Runnable {
		Vector <String>devices;
		public UpdateDeviceList (Vector <String>devices) {
			this.devices = devices;
		}
		
		public void run() { 
		    	systemStatusLabel.setText("Received device list");
		    irName.removeAllItems();
		    	irDevice.removeAllItems();
		    	synchronized (learntDevices){
		    		learntDevices = devices;
		    		for (String nextDevice: learntDevices){
			    		irDevice.addItem(nextDevice);
			    	}
		    		
		    	}
		    	irDevice.repaint();
	   }
	}
		
	public void updateDeviceList (Vector <String>devices) {
		UpdateDeviceList update = new UpdateDeviceList (devices);
			SwingUtilities.invokeLater(update);
	}
	
	void propertiesChanged()
	{

	}

}

