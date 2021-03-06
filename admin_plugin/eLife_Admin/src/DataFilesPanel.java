/*
 * Controls.java
 * part of the eLife_Admin plugin for the jEdit text editor
 */

import java.awt.*;
import java.awt.event.*;
import java.lang.reflect.InvocationTargetException;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.swing.*;
import javax.swing.event.*;
import java.util.ArrayList;

import org.gjt.sp.jedit.*;
import org.gjt.sp.jedit.gui.*;


public class DataFilesPanel extends JPanel
{
	private eLife_Admin eLife;
	private JList results;
	private Logger logger;
    private DefaultListModel listModel;
    private Object[] datas;
    private int numElements = 0;
    private JLabel status;
    private JCheckBox confirm;
    private String startup;
    
	public DataFilesPanel(eLife_Admin eLife)
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
					DataFilesPanel.this.eLife.readFiles("server/datafiles");
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
						DataFilesPanel.this.eLife.downloadFile("server/datafiles",(String)datas[sel]);
					}
				}
			});
		serviceButtons.add (download);
		serviceButtons.add(Box.createRigidArea(new Dimension(5, 0)));


		JButton upload = new JButton("Upload Buffer");
		upload.addActionListener(
				new ActionListener() {
					public void actionPerformed(ActionEvent evt) {
						DataFilesPanel.this.eLife.uploadFile("server/datafiles",false);
					}
				});
		serviceButtons.add (upload);
		serviceButtons.add(Box.createRigidArea(new Dimension(5, 0)));
		
		JButton delete = new JButton("Delete File");
		delete.addActionListener(
				new ActionListener() {
					public void actionPerformed(ActionEvent evt) {
						int sel = results.getSelectedIndex();
						boolean confirmed = confirm.isSelected();
						if (sel <= numElements && confirmed) {
							clearConfirm();
							DataFilesPanel.this.eLife.deleteFile("server/datafiles",(String)datas[sel]);
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
		
		JPanel extraControls = new JPanel();
		extraControls.setLayout (new FlowLayout (FlowLayout.LEADING));

		JButton loadMacros = new JButton("Reload Macros");
		loadMacros.addActionListener(
			new ActionListener() {
				public void actionPerformed(ActionEvent evt) {
					status.setText ("Reloading macro database");
					DataFilesPanel.this.eLife.reloadMacros();
				}
			});
		extraControls.add (loadMacros);
		
		JButton reloadIR = new JButton("Reload IR database");
		reloadIR.addActionListener(
				new ActionListener() {
					public void actionPerformed(ActionEvent evt) {
						status.setText ("Reloading IR database");
						DataFilesPanel.this.eLife.reloadIRDB();
					}
				});
		extraControls.add(reloadIR);	
		
		JPanel statusPanel = new JPanel();
		statusPanel.setLayout (new FlowLayout (FlowLayout.LEADING));
		status = new JLabel ();
		statusPanel.add (status);
		
		JPanel topPart = new JPanel();
		topPart.setLayout (new BoxLayout (topPart,BoxLayout.Y_AXIS));
		topPart.add (serviceButtons);
		topPart.add(extraControls);
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
	
	public void clearDataFileList () {
		Runnable updateList = new Runnable () {
			public void run () {
				listModel = new DefaultListModel();
				results.setModel(listModel);
			}
		};
		SwingUtilities.invokeLater(updateList);
	}

	
	public void clear (){
		this.clearDataFileList();
		this.setResults("");
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
		this.datas = fileList.getNames();
		
	}
	
	void propertiesChanged()
	{

	}

}

