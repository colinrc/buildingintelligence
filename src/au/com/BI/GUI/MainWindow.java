/*
 * Created on 8/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.GUI;
import java.awt.Image;
import java.awt.LayoutManager;
import java.util.Vector;

import au.com.BI.Connection.ServerHandler;
import au.com.BI.Util.ImageLoader;

/**
 *
 * @author  David
 */
public class MainWindow extends java.awt.Frame {
	private Image image;
	private MainWindowBG bg;
	private ImageLoader imageLoader;
	private LayoutManager layout;
	private ServerHandler serverHandle;
	/** Creates new form MainWindow */
	public MainWindow(ServerHandler inServerHandler, Vector inImages) {
		serverHandle = inServerHandler;
		imageLoader = new ImageLoader(this);
		imageLoader.loadImages(inImages);
		initComponents();
	}

	private void initComponents() {
		//myButtonLoader = new ButtonLoader(this);
		//Dimension screenSize = java.awt.Toolkit.getDefaultToolkit().getScreenSize();
		this.setBounds(500,500,240,320);
		this.setTitle("Elife Test");
		//tLayout(null);
		bg = new MainWindowBG(imageLoader, serverHandle);
		bg.setBounds(0,0,240,320);
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
