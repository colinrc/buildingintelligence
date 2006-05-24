/*
 * Created on 22/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.GUI;

import java.awt.Component;
import java.awt.Graphics;
import java.awt.Image;
import java.text.SimpleDateFormat;
import java.util.Calendar;

import au.com.BI.Connection.ServerHandler;
import au.com.BI.Util.ImageLoader;

/**
 * @author David
 *
 * 
 * 
 */
public class MainWindowTitleBar extends Component implements Runnable{
	private ImageLoader imageLoader;
	private ServerHandler serverHandle;
	protected Image offScreenImage;
	private Calendar cal;
	/**
	 * 
	 */
	/*Concurrent Components*/
	protected Thread updateThread = null;
	public MainWindowTitleBar(ImageLoader inImageLoader, ServerHandler inServerHandler) {
		imageLoader = inImageLoader;
		serverHandle = inServerHandler;
		// TODO Auto-generated constructor stub
		if (updateThread == null) {
					updateThread = new Thread(this, "timer");
		}
	}
	public void update(Graphics graphics) {
		try{
		
			// Create an offscreen image and then get its
			// graphics context for the drawing.
			if (offScreenImage == null){
				offScreenImage = createImage(240, 80);
			}
			Graphics gOffScreenImage = offScreenImage.getGraphics();
			// Do the clipping on both the off
			// and on screen graphics contexts.
			// Now draw on the offscreen image.
			paint(gOffScreenImage);
			// Don't bother to call paint,
			// just draw the offscreen image
			// to the screen.
			graphics.drawImage(offScreenImage, 0, 0, this);
			// Get rid of the offscreen graphics context.
			// Can't unclip a graphics context so have
			// to get a new one next time around.
			gOffScreenImage.dispose();
		}
		catch(Exception e){
			
		}
		}
		public void paint(Graphics graphics) {
			super.paint(graphics);
			SimpleDateFormat df;
			SimpleDateFormat df2;
			cal = Calendar.getInstance();
			df = new SimpleDateFormat("EEEEEEEE, dd MMMMMMMM yyyy");
			df2 = new SimpleDateFormat("kk:mm");
			graphics.setColor(new java.awt.Color(0, 0, 0));
			graphics.fillRect(0, 0, 240, 80);
			graphics.setColor(new java.awt.Color(255, 255, 255));
			graphics.setFont(new java.awt.Font("helvetica", java.awt.Font.PLAIN, 18));
			graphics.drawString(df.format(cal.getTime()), 10, 25);
			graphics.drawString(df2.format(cal.getTime()), 10, 50);
			//graphics.setFont(new java.awt.Font("helvetica", java.awt.Font.BOLD, 12));
			//graphics.drawString("Macros", 3, 45);
			if(!updateThread.isAlive()){
				updateThread.start();
			}
			
		}
		public void repaint() {
			update(this.getGraphics());
		}
		public void run() {
			while (updateThread == Thread.currentThread()) {
				try {
					repaint();
					updateThread.sleep(500);			
				} catch (Exception e) {
					e.printStackTrace();
					System.exit(1);
				}
			}
		}
		public void stop() {
			if (updateThread.isAlive()) {
				updateThread = null;
				updateThread = new Thread(this, "highlighter");
			}
		}
}
