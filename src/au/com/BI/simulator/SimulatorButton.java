/*
 * Created on 23/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.simulator;
import java.awt.AlphaComposite;
import java.awt.Color;
import java.awt.Component;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

import au.com.BI.Util.ImageLoader;
/**
 * @author David
 *
 * 
 * 
 */
public class SimulatorButton extends Component /*implements Runnable */{
	/**
	 * 
	 */
	private Image offScreenImage;
	//private Thread updateThread;
	private String command;
	private String buttonHalo1 = "images/elife_active/button-halo-green";
	private String buttonHalo2 = "images/elife_active/button-halo-yellow";
	private ImageLoader imageLoader;
	private int width;
	private int height;
	private int x;
	private int y;
	private boolean on = false;
	public SimulatorButton(ImageLoader inImageLoader, String command) {
		super();
		this.command = command;
		this.imageLoader = inImageLoader;
		width = 39;
		height = 83;
		x = 50;
		y = 3;
	/*	if (updateThread == null) {
			updateThread = new Thread(this, "highlighter");
		}*/
		this.addMouseListener(new MouseAdapter() {
			public void mouseClicked(MouseEvent e) {
				if (on) {
					//stop();
					//updateThread.start();
					//highlighted = 100;
					on = false;
					repaint();
				} else {
					//updateThread.start();
					//highlighted = 100;
					on = true;
					repaint();
				}
				//repaint(highlighted);
			}
		});
		// TODO Auto-generated constructor stub
	}
	public void paint(Graphics g){
		/*Graphics2D g2d = (Graphics2D) g;
		//g2d.setComposite(makeComposite((float) 0.00f));
		g2d.fillRect(x,y,width,height);*/
		super.paint(g);
		if (on) {
			g.drawImage(imageLoader.getImage(buttonHalo1), x, y, width, height, this);
		}
	}
	//public void update() {
		//repaint(highlighted);
	//}
	/*public void repaint() {
		//update(this.getGraphics());
		repaint(highlighted);
	}*/
	/*private AlphaComposite makeComposite(float alpha) {
		int type = AlphaComposite.SRC_OVER;
		return (AlphaComposite.getInstance(type, alpha));
	}*/
//	public void repaint() {
	//	Graphics graphics = this.getGraphics();
	//	update(graphics);
	//	Graphics2D g2d = (Graphics2D) graphics;
		//g2d.setComposite(makeComposite((float) 0.01 * highlighted));
		//paint(g2d);
		//g2d.fillRect(x,y,width,height);
		//g2d.clearRect(x,y,width,height);
//	}
	//public void update(Graphics graphics) {
		// Create an offscreen image and then get its
		// graphics context for the drawing.
	//	if (offScreenImage == null)
	//		offScreenImage = createImage(90,90);
	//	Graphics gOffScreenImage = offScreenImage.getGraphics();
		// Do the clipping on both the off
		// and on screen graphics contexts.
		/*		 int lastX = currentX, lastY = currentY;
				 currentX = newX; currentY = newY;
				 clipToAffectedArea( og, lastX, lastY,
					 currentX, currentY, iamgeWd, imageHt );
				 clipToAffectedArea( g, lastX, lastY,
					 currentX, currentY, imageWd, imageHt );
		*/
		// Now draw on the offscreen image.
		//paint(gOffScreenImage);
		// Don't bother to call paint,
		// just draw the offscreen image
		// to the screen.
		//graphics.drawImage(offScreenImage, 0, 0, this);
		// Get rid of the offscreen graphics context.
		// Can't unclip a graphics context so have
		// to get a new one next time around.
		//gOffScreenImage.dispose();
	//}
	/*public void run() {
		while (updateThread == Thread.currentThread()) {
			/*if (highlighted > 0) {
				repaint(highlighted);
				try {
					updateThread.sleep(500);
				} catch (InterruptedException e) {
					System.err.println(e.getMessage());
					e.printStackTrace();
				}
				highlighted = highlighted - 20;
			} else {
				//repaint(highlighted);
				this.getParent().repaint();
				stop();
			}*/
	/*	}
	}
	public void stop() {
		if (updateThread.isAlive()) {
			updateThread = null;
			updateThread = new Thread(this, "highlighter");
		}
	}*/
}
