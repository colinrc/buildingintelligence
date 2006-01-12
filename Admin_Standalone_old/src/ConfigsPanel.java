/*
 * Controls.java
 * part of the eLife_Admin plugin for the jEdit text editor
 */

import java.awt.*;
import java.awt.event.*;
import java.lang.reflect.InvocationTargetException;
import java.util.logging.Logger;
import javax.swing.*;


public class ConfigsPanel extends JPanel
{
	private Admin eLife;
	private JList results;
	private Logger logger;
    private DefaultListModel listModel;
    private Object[] configs;
    private int numElements = 0;
    private JLabel status;
    private JCheckBox confirm;
    private String startup;
    private int startupIndex = -1;
    
	public ConfigsPanel(Admin eLife)
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
					ConfigsPanel.this.eLife.readFiles("server/config");
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
						ConfigsPanel.this.eLife.downloadFile("server/config",(String)configs[sel]);
					}
				}
			});
		serviceButtons.add (download);
		serviceButtons.add(Box.createRigidArea(new Dimension(5, 0)));

		JButton startupButton = new JButton("Set as Startup");
		startupButton.addActionListener(
				new ActionListener() {
					public void actionPerformed(ActionEvent evt) {
						int sel = results.getSelectedIndex();
						setStartupFile ((String)configs[sel]);
						if (sel <= numElements) {
							ConfigsPanel.this.eLife.setStartup((String)configs[sel]);
						}
						results.repaint();

					}
				});
		serviceButtons.add (startupButton);
		serviceButtons.add(Box.createRigidArea(new Dimension(5, 0)));


		JButton upload = new JButton("Upload File");
		upload.addActionListener(
				new ActionListener() {
					public void actionPerformed(ActionEvent evt) {
						ConfigsPanel.this.eLife.uploadFile("server/config","");
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
							ConfigsPanel.this.eLife.deleteFile("server/config",(String)configs[sel]);
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
        results.setCellRenderer(new ConfigsCellRenderer());
		results.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
		results.setSelectedIndex(0);
		results.setVisibleRowCount(5);
        JScrollPane listScrollPane = new JScrollPane(results);
        add(listScrollPane, BorderLayout.CENTER);
	}

	 class ConfigsCellRenderer extends JLabel implements ListCellRenderer {
	     public ConfigsCellRenderer() {
	         setOpaque(true);
	     }
	     public Component getListCellRendererComponent(
	         JList list,
	         Object value,
	         int index,
	         boolean isSelected,
	         boolean cellHasFocus)
	     {
	     	 String beingDrawn = value.toString(); 
	         setText(beingDrawn);
	         setBackground(isSelected ? Color.blue : Color.white);
	         setForeground(isSelected ? Color.white : Color.black);
	         if (index == startupIndex ) {
	         	setFont (this.getFont().deriveFont(Font.BOLD));
	         }else {
	         	setFont (this.getFont().deriveFont(Font.PLAIN));	         	
	         }
	         return this;
	     }
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
		if (startup == null) {
			this.startup = "";
			this.startupIndex = -1;
		}
		else {
			this.startup = startup;
			if (configs != null) {
				matchStartup (startup);
	
			}
		}
	}

	public void matchStartup (String startup) {
		for (int i = 0; i < configs.length; i++) {
			if (((String)configs[i]).equals (startup)) {
				this.startupIndex = i;
			}
		}
	}
	
	public void clearConfirm () {
		Runnable updateList = new Runnable () {
			public void run () {
				confirm.setSelected (false);
			}
		};
		SwingUtilities.invokeLater(updateList);
	}
	
	public void clearConfigList () {
		Runnable updateList = new Runnable () {
			public void run () {
				listModel = new DefaultListModel();
				results.setModel(listModel);
			}
		};
		SwingUtilities.invokeLater(updateList);
	}

	public void clear (){
		clearConfigList();
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
			matchStartup (startup);
			results.invalidate();
		}
		
	}
	
	public void setFileList (FileList fileList) {
		numElements = fileList.getNumberItems();
		Object [] displayList = fileList.getJoined();

		this.configs = fileList.getNames();
	UpdateListModel updater = new UpdateListModel (displayList,-1);
		try {
			SwingUtilities.invokeAndWait(updater);
		} catch (InterruptedException e) {
		} catch (InvocationTargetException e) {
		}
	}
	
	void propertiesChanged()
	{

	}

}

