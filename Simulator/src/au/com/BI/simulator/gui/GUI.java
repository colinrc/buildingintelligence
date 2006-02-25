package au.com.BI.simulator.gui;




import java.awt.*;
import java.awt.event.*;
import java.util.*;
import javax.swing.*;

import au.com.BI.simulator.sims.*;
import au.com.BI.simulator.util.Utility;
import au.com.BI.simulator.conf.*;


public class GUI extends JPanel {
	   /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	// Various GUI components and info
	   public JFrame mainFrame = null;
	   public JTextArea chatText = null;
	   public JTextField chatLine = null;
	   public JPanel statusBar = null;
	   public JLabel statusField = null;
	   public JTextField statusColor = null;
	   public JButton clearButton = null;
	   private Helper helper = null;
	   public Simulator simulator;
	   
	   // Connection atate info
	   public static String hostIP = "localhost";
	   public int connectionStatus = Helper.BEGIN_CONNECT;
	   
	   public String statusString = "";
	   
	   protected Icon iconOn;
	   protected Icon iconOff;
	   protected JPanel buttonBar;
	   protected Config config;

	   public static StringBuffer toAppend = new StringBuffer("");
	   /////////////////////////////////////////////////////////////////

	   public  GUI (Helper helper,Simulator simulator) {
			  this.helper = helper;
			  this.simulator = simulator;
			  this.config = helper.getConfig();
		      JPanel pane = null;
		      ActionAdapter buttonListener = null;
		      
		      java.net.URL imageOnURL = Simulator.class.getResource("images/lightOn.png");
		      java.net.URL imageOffURL = Simulator.class.getResource("images/lightOff.png");
		      if (imageOnURL != null)
		    	  	iconOn = new ImageIcon(imageOnURL);
		      if (imageOffURL != null)
		    	  	iconOff = new ImageIcon(imageOffURL);
		      ActionAdapter clearButtonListener = null;
				statusString = Helper.statusMessages[connectionStatus];
				
		      // Create an options pane
			  this.setLayout (new GridLayout(5, 1));
			  
			   // Set up controls for the simulator
			   buttonBar = new JPanel (new FlowLayout());
		   		buttonBar.setAlignmentY(JPanel.TOP_ALIGNMENT);
		      // Clear button
		      clearButtonListener = new ActionAdapter() {
		            public void actionPerformed(ActionEvent e) {
		                chatText.setText("");
		            }
		         };
		      clearButton = new JButton ("Clear");
		      clearButton.addActionListener(clearButtonListener);
		      pane = new JPanel(new FlowLayout(FlowLayout.RIGHT));
		      pane.add(clearButton);
		      this.add(pane);
		      		
			   // Other controls
		      // Set up the status bar
		      statusField = new JLabel();
		      statusField.setText(Helper.statusMessages[Helper.DISCONNECTED]);
		      statusColor = new JTextField(1);
		      statusColor.setBackground(Color.red);
		      statusColor.setEditable(true);
		      statusBar = new JPanel(new BorderLayout());
		      statusBar.add(statusColor, BorderLayout.WEST);
		      statusBar.add(statusField, BorderLayout.CENTER);


		      // Set up the chat pane
		      JPanel chatPane = new JPanel(new BorderLayout());
		      chatText = new JTextArea(10, 20);
		      chatText.setLineWrap(true);
		      chatText.setEditable(false);
		      chatText.setForeground(Color.blue);
		      JScrollPane chatTextPane = new JScrollPane(chatText,
		         JScrollPane.VERTICAL_SCROLLBAR_ALWAYS,
		         JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
		      chatLine = new JTextField();
		      chatLine.setEnabled(false);
		      chatLine.addActionListener(new SimulatorAdapter(simulator) {});
		      chatPane.add(chatLine, BorderLayout.SOUTH);
		      chatPane.add(chatTextPane, BorderLayout.CENTER);
		      chatPane.setPreferredSize(new Dimension(200, 200));

		      // Set up the main pane
		      JPanel mainPane = new JPanel(new BorderLayout());
			  mainPane.add(buttonBar,BorderLayout.PAGE_START);
		      mainPane.add(statusBar, BorderLayout.SOUTH);
		      mainPane.add(this, BorderLayout.WEST);
		      mainPane.add(chatPane, BorderLayout.CENTER);

		      // Set up the main frame
		      mainFrame = new JFrame("eLife House Simulator");
		      mainFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		      mainFrame.setContentPane(mainPane);
		      mainFrame.setSize(mainFrame.getPreferredSize());
		      mainFrame.setLocation(200, 200);
		      mainFrame.pack();
		      mainFrame.setVisible(true);
	   }

	   public void redraw () {
		   mainFrame.pack();
		      //mainFrame.repaint();
		   mainFrame.setVisible(true);
		   mainFrame.repaint();
	   }
	   
	   public void addGUIPanel (GUIPanel gUIPanel) {
	   		JPanel eachBox = gUIPanel.drawPanel(iconOn,iconOff, helper,this,simulator);
		   buttonBar.add(eachBox);
	   }
	   
	   private class SimulatorAdapter extends ActionAdapter {
		   Simulator simulator;
		   public SimulatorAdapter (Simulator simulator) {
			   super();
			   this.simulator = simulator;
		   }
		   
           public void actionPerformed(ActionEvent e) {
               String s = chatLine.getText();
               if (!s.equals("")) {
            	   	String ps = Utility.parseString(s);
                  appendToChatBox("OUT",ps,"\n");
                  chatLine.selectAll();

                  // Send the string
                  simulator.sendString(ps+"\n");
               }
            }
	   }
	   
	   public void setLight (boolean state, GUIPanel gUIPanel) {
		   if (gUIPanel == null) {
			   return;
		   }
		 if (state) {
			 gUIPanel.getLight().setIcon(iconOn);
		 } else {
			 gUIPanel.getLight().setIcon(iconOff);			 
		 }
	   }
	   
	   public void setAllStatus (boolean connectState, boolean disconnectState, boolean ipState,
			   boolean chatState, Color statusColorState) {
	         chatLine.setEnabled(chatState);
	         statusColor.setBackground(statusColorState);
			 if (chatState) this.chatLine.grabFocus();
	   }
	   
	   private class Updater implements Runnable  {
		   private String statusString;
		   
		   public Updater ( String statusString) {
			   this.statusString = statusString;
		   }
		   
		   public void run() {
			   // CC do something with it
			     statusField.setText(statusString);
		   }
	   }
	   /////////////////////////////////////////////////////////////////
	   // The thread-safe way to change the GUI components while
	   // changing state
	   public void changeStatusTS(int newConnectStatus, boolean noError) {
	      // Change state if valid state
	      if (newConnectStatus != Helper.NULL) {
	         connectionStatus = newConnectStatus;
	      }

	      // If there is no error, display the appropriate status message
	      if (noError) {
	         statusString = Helper.statusMessages[connectionStatus];
	      }
	      // Otherwise, display error message
	      else {
	         statusString = Helper.statusMessages[Helper.NULL];
	      }

	      // Call the run() routine (Runnable interface) on the
	      // error-handling and GUI-update thread
		  Updater updater = new Updater (statusString);
	      SwingUtilities.invokeLater(updater);
	   }

	   /////////////////////////////////////////////////////////////////
	   // The non-thread-safe way to change the GUI components while
	   // changing state
	   public void changeStatusNTS(int newConnectStatus, boolean noError) {
	      // Change state if valid state
	      if (newConnectStatus != Helper.NULL) {
	         connectionStatus = newConnectStatus;
	      }

	      // If there is no error, display the appropriate status message
	      if (noError) {
	         statusString = Helper.statusMessages[connectionStatus];
	      }
	      // Otherwise, display error message
	      else {
	         statusString = Helper.statusMessages[Helper.NULL];
	      }
		  simulator.setConnectionStatus (connectionStatus);
		  Updater updater = new Updater (statusString);
	      SwingUtilities.invokeLater(updater);
	   }

		public void setChatLine(String chatLine){
			this.chatLine.setText(chatLine); 
		}
		
		public void setStatus (String statusString) {
			  Updater updater = new Updater (statusString);
		      SwingUtilities.invokeLater(updater);
		}

	   private class UpdateChat implements Runnable  {
		   private String s;
		   
		   public UpdateChat (String s) {
			   this.s = s;
		   }
		   
		   public void run() {
		      synchronized (toAppend) {
			         toAppend.append(s);
				      chatText.append(toAppend.toString());
				      toAppend.setLength(0);
				      chatText.setCaretPosition(chatText.getDocument().getLength());

				      mainFrame.repaint();
			      }
		   }
	   }
		   
	   /////////////////////////////////////////////////////////////////

	   // Thread-safe way to append to the chat box
	   public  void appendToChatBox(String prefix,String s,String suffix) {
		   String toWrite = "";
		   for (int i = 0; i < s.length(); i ++ ){
			   int eachOne = s.charAt(i);
			   if (config.isHexOnly()|| ((eachOne < 32 || eachOne > 126 ) && eachOne != 10 && eachOne != 13 ) ){
				   String hexVers = Integer.toHexString(eachOne);
				   if (hexVers.length() == 1) hexVers = "0" + hexVers;
				   toWrite += "#" + hexVers;
			   } else {
				   toWrite += (char)eachOne;
			   }
		   }
		   UpdateChat update = new UpdateChat (prefix+"."+toWrite+suffix);
		   SwingUtilities.invokeLater(update);
	   }

	   private class UpdateIcon implements Runnable  {
		   private GUIPanel control;
		   private boolean flag;
		   
		   public UpdateIcon (GUIPanel control,boolean flag) {
			   this.control = control;
			   this.flag = flag;
		   }
		   
		   public void run() {
			   setLight (flag,control);
		      mainFrame.repaint();
		   }
	   }
		   
	   /////////////////////////////////////////////////////////////////

	   // Thread-safe way to append to the chat box
	   public  void changeIcon(GUIPanel control, boolean flag) {
		   UpdateIcon update = new UpdateIcon (control,flag);
		   SwingUtilities.invokeLater(update);
	   }
	   
	   public void setLevel (GUIPanel control,int level) {
		   if (control == null) {
			   return;
		   }
		   if (control.isHasSlider()){
			   control.getSlider().setValue(level);
		   }
	   }

	   private class UpdateLevel implements Runnable  {
		   private GUIPanel control;
		   private int level;
		   
		   public UpdateLevel (GUIPanel control,int level) {
			   this.control = control;
			   this.level = level;
		   }
		   
		   public void run() {
			   control.setUpdatingSlider(true);
			   setLevel (control,level);
		      mainFrame.repaint();
			   control.setUpdatingSlider(false);
		   }
	   }
		   
	   /////////////////////////////////////////////////////////////////

	   // Thread-safe way to append to the chat box
	   public  void changeLevel(GUIPanel control, int level) {
		   UpdateLevel update = new UpdateLevel (control,level);
		   SwingUtilities.invokeLater(update);
	   }

}
