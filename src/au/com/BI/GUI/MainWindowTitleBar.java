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

import au.com.BI.Util.ImageHandler;
/**
 * @author David
 *
 * 
 * 
 */
public class MainWindowTitleBar extends Component implements Runnable {
	private ImageHandler imageLoader;
	protected Image offScreenImage;
	private Calendar cal;
	private String name;
	private boolean showDay;
	private int count;
	/**
	 * 
	 */
	/*Concurrent Components*/
	protected Thread updateThread = null;
	protected int bufferWidth;
	protected int bufferHeight;
	protected Image bufferImage;
	protected Graphics bufferGraphics;
	public void paint(Graphics g) {
		resetBuffer();
		if (bufferGraphics != null) {
			//this clears the offscreen image, not the onscreen one
			bufferGraphics.clearRect(0, 0, bufferWidth, bufferHeight);
			//calls the paintbuffer method with 
			//the offscreen graphics as a param
			paintBuffer(bufferGraphics);
			//we finaly paint the offscreen image onto the onscreen image
			g.drawImage(bufferImage, 0, 0, this);
		}
	}
	public void paintBuffer(Graphics g) {
		//in classes extended from this one, add something to paint here!
		//always remember, g is the offscreen graphics
		SimpleDateFormat df;
		SimpleDateFormat df2;
		cal = Calendar.getInstance();
		//if (showDay) {
			df = new SimpleDateFormat("dd MMMMMMMM yyyy");
	/*	} else {
			df = new SimpleDateFormat("EEEEEEEE");
		}*/
		df2 = new SimpleDateFormat("kk:mm");
		g.setColor(new java.awt.Color(0, 0, 0));
		g.fillRect(0, 0, 240, 80);
		g.setColor(new java.awt.Color(255, 255, 255));
		g.setFont(new java.awt.Font("Arial", java.awt.Font.BOLD, 16));
		g.drawString(df.format(cal.getTime()), 10, 25);
		g.drawString(df2.format(cal.getTime()), 190, 25);
		g.drawString(name, 10, 60);
		if (!updateThread.isAlive()) {
			updateThread.start();
		}
	}
	private void resetBuffer() {
		// always keep track of the image size
		try {
			bufferWidth = getSize().width;
			bufferHeight = getSize().height;
			//    clean up the previous image
			if (bufferGraphics != null) {
				bufferGraphics.dispose();
				bufferGraphics = null;
			}
			if (bufferImage != null) {
				bufferImage.flush();
				bufferImage = null;
			}
			System.gc();
			//    create the new image with the size of the panel
			bufferImage = createImage(bufferWidth, bufferHeight);
			bufferGraphics = bufferImage.getGraphics();
		} catch (Exception e) {
		}
	}
	public void repaint() {
		paint(this.getGraphics());
	}
	public MainWindowTitleBar(
	ImageHandler inImageLoader,
		String current) {
		imageLoader = inImageLoader;
		name = current;
		// TODO Auto-generated constructor stub
		showDay = false;
		count = 0;
		if (updateThread == null) {
			updateThread = new Thread(this, "timer");
		}
	}
	public void run() {
		while (updateThread == Thread.currentThread()) {
			try {
				repaint();
				count++;
				if (count == 10) {
					count = 0;
					showDay = !showDay;
				}
				Thread.sleep(500);
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
	public void setTitle(String inTitle) {
		name = inTitle;
		repaint();
	}
}
