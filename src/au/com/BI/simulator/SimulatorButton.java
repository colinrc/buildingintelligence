/*
 * Created on 23/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.simulator;
import java.awt.Component;
import java.awt.Graphics;
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
public class SimulatorButton extends Component {
	/**
	 * 
	 */
	private Image offScreenImage;
	private String command;
	private String button1Halo1 = "images/elife_active/home-on";
	private String button1Halo2 = "images/elife_active/home-on-yellow";
	private String button1HaloOff = "images/elife_active/home-off";
	private String button2Halo1 = "images/elife_active/up-on";
	private String button2Halo2 = "images/elife_active/up-on-yellow";
	private String button2HaloOff = "images/elife_active/up-off";
	private String button3Halo1 = "images/elife_active/down-on";
	private String button3Halo2 = "images/elife_active/down-on-yellow";
	private String button3HaloOff = "images/elife_active/down-off";
	private String button4Halo1 = "images/elife_active/ok-on";
	private String button4Halo2 = "images/elife_active/ok-on-yellow";
	private String button4HaloOff = "images/elife_active/ok-off";
	private ImageLoader imageLoader;
	private int width;
	private int height;
	private int x;
	private int y;
	private String status = "off";
	private SimulatorControls controls;
	protected int bufferWidth;
	protected int bufferHeight;
	protected Image bufferImage;
	protected Graphics bufferGraphics;
	public void paint(Graphics g) {
		resetBuffer();
		if (bufferGraphics != null) {
			//this clears the offscreen image, not the onscreen one
			bufferGraphics.clearRect(0, 0, bufferWidth, bufferHeight);
			//super.paint(bufferGraphics);
			//calls the paintbuffer method with 
			//the offscreen graphics as a param
			paintBuffer(bufferGraphics);
			//we finaly paint the offscreen image onto the onscreen image
			g.drawImage(bufferImage, 0, 0, this);
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
				//System.gc();
				//    create the new image with the size of the panel
				bufferImage = createImage(bufferWidth, bufferHeight);
				bufferGraphics = bufferImage.getGraphics();
			} catch (Exception e) {
			}
		}
	public void paintBuffer(Graphics g) {
		//in classes extended from this one, add something to paint here!
		//always remember, g is the offscreen graphics
		if (command.equals("b1")) {
			if (status.equals("on")) {
				g.drawImage(imageLoader.getImage(button1Halo1), 0, 0,this);
			} else if (status.equals("yellow")) {
				g.drawImage(imageLoader.getImage(button1Halo2), 0, 0,this);
			} else {
				g.drawImage(imageLoader.getImage(button1HaloOff), 0, 0, this);
			}
		} else if (command.equals("b2")) {
			if (status.equals("on")) {
				g.drawImage(imageLoader.getImage(button2Halo1), 0, 0, this);
			} else if (status.equals("yellow")) {
				g.drawImage(imageLoader.getImage(button2Halo2), 0, 0, this);
			} else {
				g.drawImage(imageLoader.getImage(button2HaloOff), 0, 0,this);
			}
		} else if (command.equals("b3")) {
			if (status.equals("on")) {
				g.drawImage(imageLoader.getImage(button3Halo1), 0, 0, this);
			} else if (status.equals("yellow")) {
				g.drawImage(imageLoader.getImage(button3Halo2), 0, 0, this);
			} else {
				g.drawImage(imageLoader.getImage(button3HaloOff), 0, 0,this);
			}
		} else if (command.equals("b4")) {
			if (status.equals("on")) {
				g.drawImage(imageLoader.getImage(button4Halo1), 0, 0, this);
			} else if (status.equals("yellow")) {
				g.drawImage(imageLoader.getImage(button4Halo2), 0, 0, this);
			} else {
				g.drawImage(imageLoader.getImage(button4HaloOff), 0, 0,this);
			}
		}
	}
	public void repaint() {
		paint(this.getGraphics());
	}
	public SimulatorButton(ImageLoader inImageLoader, String command, SimulatorControls controls) {
		super();
		this.controls = controls;
		this.command = command;
		this.imageLoader = inImageLoader;
		width = 39;
		height = 83;
		x = 50;
		y = 3;
		this.addMouseListener(new MouseAdapter() {
			public void mousePressed(MouseEvent e) {
				sendMessage("Down");
			}
			public void mouseReleased(MouseEvent e) {
				sendMessage("Up");
			}
		});
	}
	public void sendMessage(String suffix) {
		controls.outgoingSerial(command + suffix);
	}
	public void setStatus(String inStatus) {
		status = inStatus;
	}
}
