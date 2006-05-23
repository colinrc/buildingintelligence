/*
 * Created on 8/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.GUI;
import java.awt.Image;

import au.com.BI.Connection.ServerHandler;
import au.com.BI.Util.ImageLoader;
/**
 *
 * @author David
 */
public class MainWindowBG extends java.awt.Container {
	private MainWindowPage currentPage;
	private MainWindowTitleBar titleBar;
	private ImageLoader imageLoader;
	private ServerHandler serverHandle;
	protected Image offScreenImage;
	/** Creates a new instance of MainWindowBG */
	public MainWindowBG(ImageLoader inImageLoader, ServerHandler inServerHandler) {
		imageLoader = inImageLoader;
		serverHandle = inServerHandler;
		titleBar = new MainWindowTitleBar(inImageLoader, inServerHandler);
		titleBar.setBounds(0,0,240,80);
		currentPage = new MainWindowPage(inImageLoader, inServerHandler);
		currentPage.setBounds(0, 80, 240, 240);
		add(titleBar);
		add(currentPage);
	}
}
