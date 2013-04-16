/*
 * Created on 8/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.GUI;
import java.util.Vector;

import au.com.BI.Connection.ServerHandler;
import au.com.BI.DataModel.ElifeActiveClientModel;
import au.com.BI.Serial.SerialHandler;
import au.com.BI.Util.ImageHandler;
/**
 *
 * @author  David
 */
public class MainWindow extends java.awt.Frame {
	private MainWindowBG bg;
	private ImageHandler imageLoader;
	private ElifeActiveClientModel client;
	/** Creates new form MainWindow */
	public MainWindow(Vector inImages) {
		imageLoader = new ImageHandler(this);
		this.client = ElifeActiveClientModel.getInstance();
		inImages.addAll(client.getIcons());
		imageLoader.loadImages(inImages);
		bg = new MainWindowBG(imageLoader, client, new SerialHandler(ServerHandler.getInstance()));
		initComponents();
	}
	private void initComponents() {
		this.setBounds(500, 500, 240, 320);
		this.setTitle("Elife Test");
		bg.setBounds(0, 0, 240, 320);
		this.add(bg);
		addWindowListener(new java.awt.event.WindowAdapter() {
			public void windowClosed(java.awt.event.WindowEvent evt) {
				formWindowClosed(evt);
			}
			public void windowClosing(java.awt.event.WindowEvent evt) {
				exitForm(evt);
			}
		});
	}
	private void formWindowClosed(java.awt.event.WindowEvent evt) {
		System.exit(0);
	}
	/** Exit the Application */
	private void exitForm(java.awt.event.WindowEvent evt) {
		this.dispose();
	}
}
