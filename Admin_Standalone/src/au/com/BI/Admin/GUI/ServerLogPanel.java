package au.com.BI.Admin.GUI;
/*
 * Controls.java
 * part of the eLife_Admin plugin for the jEdit text editor
 */

import au.com.BI.Admin.Home.Admin;
import au.com.BI.Admin.util.FileList;
import java.awt.*;
import java.awt.event.*;
import java.lang.reflect.InvocationTargetException;
import java.util.logging.Logger;

import javax.swing.*;



public class ServerLogPanel extends JPanel
{
	private Admin eLife;
	private JList results;
	private Logger logger;
    private DefaultListModel listModel;
    private Object[] files;
    private int numElements = 0;
    private JLabel status;
    private JCheckBox confirm;
    private String startup;
	private String logDir = "server/log";
    
	public ServerLogPanel(Admin eLife)
	{
		this.eLife = eLife;
		logger = Logger.getLogger("Log");
		this.setLayout(new BorderLayout());
			
		
		JPanel serviceButtons = new JPanel();
		serviceButtons.setLayout (new BoxLayout (serviceButtons,BoxLayout.X_AXIS));

		JButton list = new JButton("List Files");
		list.addActionListener(
			new ActionListener() {
				public void actionPerformed(ActionEvent evt) {
					ServerLogPanel.this.eLife.readFiles(logDir,"trace.log.*");
				}
			});
		serviceButtons.add (list);
		serviceButtons.add(Box.createRigidArea(new Dimension(5, 0)));

		
		JButton download = new JButton("Download File");
		download.addActionListener(
			new ActionListener() {
				public void actionPerformed(ActionEvent evt) {
					int sel = results.getSelectedIndex();
					if (sel <= numElements) {
						ServerLogPanel.this.eLife.downloadFile(logDir,(String)files[sel]);
					}
				}
			});
		serviceButtons.add (download);
		serviceButtons.add(Box.createRigidArea(new Dimension(5, 0)));
		
		JButton delete = new JButton("Delete File");
		delete.addActionListener(
				new ActionListener() {
					public void actionPerformed(ActionEvent evt) {
						int sel = results.getSelectedIndex();
						boolean confirmed = confirm.isSelected();
						if (sel <= numElements && confirmed) {
							clearConfirm();
							ServerLogPanel.this.eLife.deleteFile(logDir,(String)files[sel]);
						}
					}
				});
		serviceButtons.add (delete);

		confirm = new JCheckBox ();
		confirm.setText("Confirm");
		serviceButtons.add (confirm);
		serviceButtons.add(Box.createRigidArea(new Dimension(5, 0)));
		
		serviceButtons.add(Box.createHorizontalGlue());
		serviceButtons.setBorder(BorderFactory.createEmptyBorder(0,0,5,0));
		
		JPanel statusPanel = new JPanel();
		statusPanel.setLayout (new FlowLayout (FlowLayout.LEADING));
		status = new JLabel ();
		statusPanel.add (status);
		

		JPanel topPart = new JPanel();
		topPart.setLayout (new BoxLayout (topPart,BoxLayout.Y_AXIS));
		topPart.add (serviceButtons);
		topPart.add (statusPanel);
		
		add(topPart,BorderLayout.NORTH);

		listModel = new DefaultListModel();
		
		//Create the list and put it in a scroll pane.
        results = new JList(listModel);
		results.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
		results.setSelectedIndex(0);
		results.setVisibleRowCount(5);
        JScrollPane listScrollPane = new JScrollPane(results);
        add(listScrollPane, BorderLayout.CENTER);
	}

	private class SetResultsString implements Runnable {
		private String message;
		public SetResultsString (String message) {
			this.message = message;
		}
		
		public void run () {
			status.setText(message);
		}
	}

	public void setResults (String results) {
		SetResultsString updater = new SetResultsString  (results);
		SwingUtilities.invokeLater (updater);
	}
	
	public void setStartupFile (String startup) {
		this.startup = startup;
	}
	
	public void clearConfirm () {
		Runnable updateList = new Runnable () {
			public void run () {
				confirm.setSelected (false);
			}
		};
		SwingUtilities.invokeLater(updateList);
	}
	
	public void clearScriptList () {
		Runnable updateList = new Runnable () {
			public void run () {
				listModel = new DefaultListModel();
				results.setModel (listModel);
			}
		};
		SwingUtilities.invokeLater(updateList);
	}

	public void clear () {
		clearScriptList();
		setResults("");
	}
	
	private class UpdateListModel implements Runnable{
		private Object [] newData;
		private int selected;
		
		public UpdateListModel (Object [] newData, int selected) {
			this.newData = newData;
			this.selected = selected;
		}
		
		public void run () {
			results.setListData(newData);
			if (selected != -1) {
				results.setSelectedIndex(selected);
			}
		}
		
	}
	
	public void setFileList (FileList fileList) {
		numElements = fileList.getNumberItems();
		Object [] displayList = fileList.getJoined();
		Object [] shortList = fileList.getNames();
		int selected = -1;
		for (int i = 0; i < shortList.length; i++) {
			if (((String)shortList[i]).equals (startup)) {
				selected = i;
			}
		}
		UpdateListModel updater = new UpdateListModel (displayList,selected);
		try {
			SwingUtilities.invokeAndWait(updater);
		} catch (InterruptedException e) {
		} catch (InvocationTargetException e) {
		}
		this.files = fileList.getNames();
		
	}
	
	void propertiesChanged()
	{

	}

	public String getLogDir() {
		return logDir;
	}

	public void setLogDir(String logDir) {
		this.logDir = logDir;
	}

}

