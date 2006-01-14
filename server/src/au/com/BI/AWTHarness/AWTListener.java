/*
 * Created on Feb 9, 2004
 *
 */
package au.com.BI.AWTHarness;
import java.awt.*;
import java.awt.event.*;

import au.com.BI.Command.*;
import au.com.BI.GC100.*;
import java.util.List;
import au.com.BI.User.User;
import java.util.logging.*;
import java.io.File;
import javax.swing.*;
import javax.swing.event.*;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.GUIModel;

/**
 * @author Colin Canfield
 * Main GUI thread
 *
 **/
public class AWTListener extends Thread implements ActionListener,ListSelectionListener
{
	
	protected List commandQueue;
	protected User user; // fill in for the demo
	protected JTextArea messageAreaOut;
	protected JTextField irNameField;
	protected Frame frame;
	protected Logger logger;
	protected LogHandler logHandler = null;
	protected IRCodeDB iRCodeDB;
	protected String irName = "";
	protected au.com.BI.IR.Model irLearner;
	protected GUIModel aWTHarness;
	
	public AWTListener (){
		user = new User ("","");
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
	public void setMessageAreaOut (JTextArea messageAreaOut){
		this.messageAreaOut = messageAreaOut;
		
	}
	
	public void setControllerInfo (List commandQueue){
		this.commandQueue = commandQueue;
	}
	
	
	public void actionPerformed(ActionEvent e) {
		String cmd = e.getActionCommand();
		
		if (cmd.equals("Exit")) {
			logger.log (Level.FINER,"Received shutdown message");
			Command command = new Command ("SYSTEM", "ShutDown",user);
			synchronized (commandQueue){
				commandQueue.add (command);
				commandQueue.notifyAll();
			}
		}

			if (cmd.equals("Read Configuration")) {
				FileDialog fileDialog = new FileDialog (frame,"Select configuration file",FileDialog.LOAD); 
				fileDialog.setDirectory (System.getProperty("user.dir")+File.separator+"config");
				fileDialog.show();
				String fileName = fileDialog.getFile();
				if (fileName != null){
					Command command = new Command ("SYSTEM","ReadConfig",user,fileDialog.getDirectory()+fileName);
					synchronized (commandQueue){
						commandQueue.add (command);
						commandQueue.notifyAll();
					}
				}
			}
			if (cmd.equals("Pause Logging")) {
				((JButton)e.getSource()).setText("Resume Logging");
				logHandler.pauseLogging();
			}
			if (cmd.equals("Resume Logging")) {
				((JButton)e.getSource()).setText("Pause Logging");
				logHandler.resumeLogging();
			}		
			if (cmd.equals("irName")) {
				irName = ((JTextField)e.getSource()).getText();
				logger.log(Level.FINEST,"IR Command name set to : " + irName);
			}	
			if (cmd.equals("Send XML")) {				
				String XML = messageAreaOut.getText();
				logger.log(Level.FINEST,"sending "+XML);
				GUICommand command = new GUICommand ("RawXML_Send","RawXML",null,XML);
				synchronized (commandQueue){
					commandQueue.add (command);
					commandQueue.notifyAll();
				}
			}
			if (cmd.equals("Learn IR")) {		
				if (irLearner != null ) {
				    JButton button = (JButton)e.getSource();
				    synchronized (button){
				        button.setEnabled(false);
				    }
					irLearner.learnCommand (this.irNameField.getText());
				} else {
				    logger.log (Level.SEVERE,"IR Learner not configured in configuration file");
				}
			}
            if (cmd.equals("Load Scripts")) {
                Command command = new Command ("SYSTEM","LoadScripts",user);
                synchronized (commandQueue){
                        commandQueue.add (command);
                        commandQueue.notifyAll();
                }
            }

	}

	public void valueChanged(ListSelectionEvent e) {
		if (e.getValueIsAdjusting() == false) {
			JList list = (JList)e.getSource();
			
    			String packageName = list.getName();
    			int theSelection =list.getSelectedIndex(); 
	        if (theSelection == -1) {
	    			logger.log (Level.INFO,"Disabling debug for package " + packageName);
	    			Logger.getLogger(packageName).setLevel (Level.WARNING);
	        } else {
	        		Level newLevel = Level.WARNING;
	        		switch (theSelection) {
	        			case 0 : newLevel = Level.INFO; break;
	        			case 1 : newLevel = Level.FINE; break;
	        			case 2 : newLevel = Level.FINER; break;
	        			case 3 : newLevel = Level.FINEST; break;
	        		}
	    			logger.log (Level.INFO,"Setting debug " + newLevel + " for package " + packageName);
	    			Logger.getLogger(packageName).setLevel (newLevel);	        
	    		}
	    }
	}
	
	
	/**
	 * @return Returns the frame.
	 */
	public Frame getFrame() {
		return frame;
	}
	/**
	 * @param frame The frame to set.
	 */
	public void setFrame(Frame frame) {
		this.frame = frame;
	}

	/**
	 * @return Returns the logHandler.
	 */
	public LogHandler getLogHandler() {
		return logHandler;
	}
	/**
	 * @param logHandler The logHandler to set.
	 */
	public void setLogHandler(LogHandler logHandler) {
		this.logHandler = logHandler;
	}
    /**
     * @return Returns the iRCodeDB.
     */
    public IRCodeDB getIRCodeDB() {
        return iRCodeDB;
    }
    /**
     * @param codeDB The iRCodeDB to set.
     */
    public void setIRCodeDB(IRCodeDB codeDB) {
        iRCodeDB = codeDB;
    }
    /**
     * @param irLearner The irLearner to set.
     */
    public void setIrLearner(DeviceModel irLearner) {
        this.irLearner = (au.com.BI.IR.Model)irLearner;
    }
    /**
     * @return Returns the irNameField.
     */
    public JTextField getIrNameField() {
        return irNameField;
    }
    /**
     * @param irNameField The irNameField to set.
     */
    public void setIrNameField(JTextField irNameField) {
        this.irNameField = irNameField;
    }
    /**
     * @return Returns the aWTHarness.
     */
    public GUIModel getAWTHarness() {
        return aWTHarness;
    }
    /**
     * @param harness The aWTHarness to set.
     */
    public void setAWTHarness(GUIModel harness) {
        aWTHarness = harness;
    }
}
