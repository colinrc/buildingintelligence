/*
 * eLife_AdminOptionPane.java
 */

import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.*;

import java.text.NumberFormat;

import org.gjt.sp.jedit.GUIUtilities;
import org.gjt.sp.jedit.jEdit;
import org.gjt.sp.jedit.AbstractOptionPane;
import org.gjt.sp.jedit.browser.VFSBrowser;
import org.gjt.sp.jedit.gui.FontSelector;
import java.util.logging.*;


public class eLifeOptionPane extends AbstractOptionPane
{
	private JTextField serverIPField;
	private JTextField workDirField;
	private JFormattedTextField monitorPortField;
	private JFormattedTextField eLifePortField;
	private FontSelector font;
	private NumberFormat portFormat;
	private Logger logger;
	private JPanel workDirPanel;

	public eLifeOptionPane()
	{
		super(eLifePlugin.NAME);
		logger = Logger.getLogger("Log");
		portFormat = NumberFormat.getIntegerInstance();
	}

	public void _init()
	{
		JPanel ipBox = new JPanel();
		JLabel ipLabel = new JLabel ("eLife Server IP");
		ipBox.add (ipLabel);
		serverIPField = new JTextField(jEdit.getProperty(
				eLifePlugin.OPTION_PREFIX + "ServerIP"));
		serverIPField.setColumns(15);
		ipBox.add (serverIPField);
		addComponent (ipBox);
		
		JPanel monitorBox = new JPanel();
		JLabel monitorLabel = new JLabel ("eLife Monitor Port");
		monitorBox.add (monitorLabel);
		monitorPortField = new JFormattedTextField(portFormat);
		monitorPortField.setColumns(8);

		try {
			monitorPortField.setValue(Integer.decode(jEdit.getProperty(
				eLifePlugin.OPTION_PREFIX + "MonitorPort")));
		} catch (NullPointerException ex) {
			monitorPortField.setValue(new Integer(10002));
		} catch (NumberFormatException ex) {
			monitorPortField.setValue(new Integer(10002));
		} catch (IllegalArgumentException ex) {
			logger.log (Level.WARNING,"Could not set monitor port option " + ex.getMessage());
		}
		monitorBox.add (monitorPortField);
		addComponent (monitorBox);
		
		JPanel eLifeBox = new JPanel();
		JLabel eLifeLabel = new JLabel ("eLife Port");
		eLifeBox.add (eLifeLabel);
		
		eLifePortField = new JFormattedTextField(portFormat);
		eLifePortField.setColumns(8);
		try {
			eLifePortField.setValue(Integer.decode(jEdit.getProperty(
				eLifePlugin.OPTION_PREFIX + "eLifePort")));
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
		addComponent (eLifeBox);
		
		
		workDirPanel = new JPanel();
		JLabel workLabel = new JLabel ("eLife Working Directory");
		workDirPanel.add (workLabel);
		String currentWorkDir = jEdit.getProperty(
				eLifePlugin.OPTION_PREFIX + "WorkDir");
		if (currentWorkDir == null) currentWorkDir = "";
		workDirField = new JTextField(currentWorkDir);
		workDirField.setColumns(10);
		workDirField.setEditable(false);
		
		workDirPanel.add (workDirField);
		
		JButton setCWD = new JButton("Set");
		setCWD.addActionListener(
			new ActionListener() {
				public void actionPerformed(ActionEvent evt) {
					setCWD(workDirField.getText());
				}
			});
		workDirPanel.add (setCWD);
		workDirPanel.add(Box.createRigidArea(new Dimension(10, 0)));
		
		addComponent (workDirPanel);
	}

	public void setCWD (String workDir) {
		String results[] = GUIUtilities.showVFSFileDialog(null,workDir,
					VFSBrowser.CHOOSE_DIRECTORY_DIALOG,false);
		if (results.length > 0) {
			String workDirSel = results[0];
			jEdit.setProperty(
					eLifePlugin.OPTION_PREFIX + "WorkDir",
					workDirSel);
			UpdateWorkDirMessage updater = new UpdateWorkDirMessage (workDirSel);
			SwingUtilities.invokeLater(updater);
			
		}
	}
	
	
	private class UpdateWorkDirMessage implements Runnable {
		String message;
		public UpdateWorkDirMessage  (String message) {
			this.message = message;
		}
		    public void run() { 
		    	workDirField.setText(message);
		    	workDirPanel.invalidate();
		    }
	}
	
	public void _save()
	{
		jEdit.setProperty(
				eLifePlugin.OPTION_PREFIX + "ServerIP",serverIPField.getText());
		
		jEdit.setProperty(
				eLifePlugin.OPTION_PREFIX + "WorkDir",workDirField.getText());

		int monitorValue = ((Number)monitorPortField.getValue()).intValue();
		int eLifeValue = ((Number)eLifePortField.getValue()).intValue();
		jEdit.setProperty(
				eLifePlugin.OPTION_PREFIX + "MonitorPort",Integer.toString(monitorValue));

		jEdit.setProperty(
				eLifePlugin.OPTION_PREFIX + "eLifePort",Integer.toString(eLifeValue));


	}
	// end AbstractOptionPane implementation


}

