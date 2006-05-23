package au.com.BI.simulator;
import java.awt.Dimension;
import java.awt.Frame;
import java.util.Vector;

import au.com.BI.Connection.ServerHandler;
import au.com.BI.Util.ImageLoader;
/*
 * Created on 22/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
/**
 * @author David
 *
 * 
 * 
 */
public class SimulatorWindow extends Frame {
	private SimulatorWindowBG bg;
	private ImageLoader imageLoader;
	private ServerHandler serverHandle;
	/**
	 * 
	 */
	public SimulatorWindow(ServerHandler inServerHandler, Vector inImages) {
		serverHandle = inServerHandler;
		imageLoader = new ImageLoader(this);
		imageLoader.loadImages(inImages);
		bg = new SimulatorWindowBG(inServerHandler, imageLoader);
		initComponents();
	}
	private void initComponents() {
		Dimension screenSize = java.awt.Toolkit.getDefaultToolkit().getScreenSize();
		this.setBounds((screenSize.width - 685)/ 2, (screenSize.height - 467) / 2, 685, 467);
		this.setTitle("Elife Active Simulator");
		this.setResizable(false);
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
