/*
 * Created on 25/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.simulator;
import java.awt.Component;
import java.awt.Graphics;
import java.awt.Image;

import au.com.BI.Util.ImageLoader;
/**
 * @author David
 *
 * 
 * 
 */
public class SimulatorEMan extends Component {
	private Image offScreenImage;
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
	/**
	 * 
	 */
	public SimulatorEMan(ImageLoader inImageLoader, SimulatorControls controls) {
		super();
		this.controls = controls;
		this.imageLoader = inImageLoader;
	}
	public void setStatus(String inStatus) {
		status = inStatus;
	}
	public void paintBuffer(Graphics g) {
		super.paint(g);
		if (status.equals("on")) {
			g.drawImage(imageLoader.getImage("images/elife_active/eman-on"), 0, 0, this);
		} else {
			g.drawImage(imageLoader.getImage("images/elife_active/eman-off"), 0, 0, this);
		}
	}
	public void repaint() {
		paint(this.getGraphics());
	}
}
