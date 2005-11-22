/*
 * Controls.java
 * part of the eLife_Admin plugin for the jEdit text editor
 */

import java.awt.*;
import java.awt.event.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.swing.*;
import javax.swing.event.*;

import org.gjt.sp.jedit.*;
import org.gjt.sp.jedit.gui.*;


public class ControlsPanel extends JPanel
{
	private eLife_Admin eLife;
	private JLabel monitorLabel;
	private JLabel adminLabel;
	private JTextArea results;
	private Logger logger;
    private SimpleDateFormat mDateFormatter;
	private boolean connected = false;
	protected JLabel systemStatusLabel;
	private JTextField arbitrary;

	private final String adminConnecting = "Monitor: Connecting";
	private final String adminConnected = "Monitor: Connected";
	private final String monitorConnecting = "eLife: Connecting";
	private final String monitorConnected = "eLife: Connected";
	private final String getStatus = "Waiting for server";


	public ControlsPanel(eLife_Admin eLife)
	{

		this.eLife = eLife;
		logger = Logger.getLogger("Log");
         mDateFormatter = new SimpleDateFormat("dd/MM/yyyy H:mm:ss");
		this.setLayout(new BorderLayout());

		JPanel serviceButtons = new JPanel();
		serviceButtons.setLayout (new BorderLayout());
		
		JPanel serviceButtonsGroup = new JPanel();
		serviceButtonsGroup.setLayout (new FlowLayout (FlowLayout.LEADING));
		//serviceButtons.setLayout (new BoxLayout (serviceButtons,BoxLayout.X_AXIS));
		
		JButton start = new JButton("Start");
		start.addActionListener(
			new ActionListener() {
				public void actionPerformed(ActionEvent evt) {
					ControlsPanel.this.results.setText("");
					ControlsPanel.this.eLife.startService();
				}
			});
		serviceButtonsGroup.add (start);
		//serviceButtonsGroup.add(Box.createRigidArea(new Dimension(5, 0)));

		JButton end = new JButton("Stop");
		end.addActionListener(
				new ActionListener() {
					public void actionPerformed(ActionEvent evt) {
						ControlsPanel.this.results.setText("");
						ControlsPanel.this.eLife.endService();
					}
				});
		serviceButtonsGroup.add (end);
		//serviceButtonsGroup.add(Box.createRigidArea(new Dimension(5, 0)));

		JButton restart = new JButton("Restart");
		restart.addActionListener(
				new ActionListener() {
					public void actionPerformed(ActionEvent evt) {
						ControlsPanel.this.results.setText("");
						ControlsPanel.this.eLife.restartService();
					}
				});
		serviceButtonsGroup.add (restart);
		serviceButtonsGroup.add(Box.createRigidArea(new Dimension(5, 0)));
		
		JButton restartEnd = new JButton("Client Restart");
		restartEnd.addActionListener(
				new ActionListener() {
					public void actionPerformed(ActionEvent evt) {
						ControlsPanel.this.results.setText("");
						ControlsPanel.this.eLife.restartClient();
					}
				});
		serviceButtonsGroup.add (restartEnd);

		JButton disconnect = new JButton("Reconnect");
		disconnect.addActionListener(
			new ActionListener() {
				public void actionPerformed(ActionEvent evt) {
					ControlsPanel.this.eLife.disconnect();
				}
			});
		serviceButtonsGroup.add (disconnect);
		serviceButtonsGroup.add(Box.createRigidArea(new Dimension(5, 0)));

		/*
		arbitrary = new JTextField();
		arbitrary.setText("Arbitrary Command");
		arbitrary.addActionListener(
			new ActionListener() {
				public void actionPerformed(ActionEvent evt) {
					ControlsPanel.this.eLife.sendArbitraryCommand (arbitrary.getText().trim());
				}	
			});
			*/
		
		serviceButtons.add (serviceButtonsGroup,BorderLayout.WEST);
		//serviceButtons.add (arbitrary,BorderLayout.CENTER);

		
		JPanel systemStatus = new JPanel ();
		
		systemStatus.setLayout (new FlowLayout (FlowLayout.LEADING));
		systemStatusLabel = new JLabel();
		systemStatus.add (systemStatusLabel);		
			
		JPanel allButtons = new JPanel();
		allButtons.setLayout (new BoxLayout (allButtons, BoxLayout.Y_AXIS));
		allButtons.add(serviceButtons);		
		allButtons.add(systemStatus);		
		add(allButtons,BorderLayout.NORTH);
		
		results = new JTextArea(5,60);
		results.setEditable(false);
		results.setBorder(BorderFactory.createTitledBorder("Results"));

		JPanel log = new JPanel ();

		JScrollPane pane = new JScrollPane(results);
		add(pane,BorderLayout.CENTER);

		JPanel status = new JPanel ();
		status.setLayout (new BorderLayout ());

		monitorLabel = new JLabel();
		monitorLabel.setText(monitorConnecting);
		status.add (monitorLabel,BorderLayout.WEST);

		adminLabel = new JLabel();
		adminLabel.setText(adminConnecting);
		status.add (adminLabel,BorderLayout.EAST);
		
		add (status,BorderLayout.SOUTH);
	}

	public void setStatus (String message) {
		
	}
	
	public void clear (){
		this.setExecResult("");
	}
	
	public void setAdminConnectionStatus (boolean connected) {
		if (connected) {
			Runnable updateAComponent = new Runnable() {
			    public void run() { adminLabel.setText(adminConnected); }
			};
			SwingUtilities.invokeLater(updateAComponent);
		} else {
			Runnable updateAComponent = new Runnable() {
			    public void run() { adminLabel.setText(adminConnecting); }
			};
			SwingUtilities.invokeLater(updateAComponent);			
		}
	}

	private class UpdateExecResult implements Runnable {
		String message;
		public UpdateExecResult  (String message) {
			this.message = message;
		}
		public void run() { 
		    	results.setText(message); 
		}
	}
	
	public void setExecResult (String execString) {
		UpdateExecResult update = new UpdateExecResult (execString);
		SwingUtilities.invokeLater(update);
	}
	
	private class UpdateMonitorMessage implements Runnable {
		String message;
		public UpdateMonitorMessage  (String message) {
			this.message = message;
		}
		    public void run() { monitorLabel.setText(message); }
	}
	
	public void setMonitorConnectionStatus (boolean connected) {
		this.connected = connected;
		if (connected) {
			UpdateMonitorMessage update = new UpdateMonitorMessage (monitorConnected);
			SwingUtilities.invokeLater(update);
		} else {
			UpdateMonitorMessage update = new UpdateMonitorMessage (monitorConnecting);
			SwingUtilities.invokeLater(update);
		
		}
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
	

	public void setConnectionMessage(String configFile, Date launchTime) {
		if (connected) {
			UpdateMonitorMessage update = new UpdateMonitorMessage (monitorConnected + " Config : " + configFile + " Startup : " + mDateFormatter.format(launchTime));
			SwingUtilities.invokeLater(update);
		}
	}
	
	void propertiesChanged()
	{

	}

}

