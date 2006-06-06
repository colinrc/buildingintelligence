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
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.event.MouseMotionListener;
import au.com.BI.Util.ImageLoader;
/**
 * @author David
 *
 * 
 * 
 */
public class SimulatorEncoder extends Component {
	private Image offScreenImage;
	private ImageLoader imageLoader;
	private int width;
	private int height;
	private int x;
	private int y;
	private int lastValue;
	private String buttonStatus = "off";
	private String wheelStatus = "off";
	private SimulatorControls controls;
	private String innerBlue = "images/elife_active/wheel-clicker-on";
	private String innerYellow = "images/elife_active/wheel-clicker-on-yellow";
	private String outerOn = "images/elife_active/wheel-on";
	private String outerOff = "images/elife_active/wheel-off";
	protected int bufferWidth;
	protected int bufferHeight;
	protected Image bufferImage;
	protected Graphics bufferGraphics;
	public void paint(Graphics g) {
		resetBuffer();
		if (bufferGraphics != null) {
			//this clears the offscreen image, not the onscreen one
			bufferGraphics.clearRect(0, 0, 226, 226);
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
			bufferWidth = 226;
			bufferHeight = 226;
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
	public SimulatorEncoder(ImageLoader inImageLoader, SimulatorControls controls) {
		super();
		this.controls = controls;
		this.imageLoader = inImageLoader;
		this.addMouseListener(new MouseAdapter() {
			public void mouseClicked(MouseEvent e) {
				sendMessage("Click");
			}
		});
		this.addMouseMotionListener(new MouseMotionListener() {
			public void mouseDragged(MouseEvent e) {
				rotoryChange(e);
			}
			public void mouseMoved(MouseEvent e) {
			}
		});
	}
	public void rotoryChange(MouseEvent e) {
		int radius = getSize().width / 2;
		int maxValue = 100;
		int minValue = 0;
		int y = e.getY();
		int x = e.getX();
		double th = Math.atan((1.0 * y - radius) / (x - radius));
		int value = ((int) (th / (2 * Math.PI) * (maxValue - minValue)));
		int newValue;
		if (x < radius) {
			newValue = value + maxValue / 2;
		} else if (y < radius) {
			newValue = value + maxValue;
		} else {
			newValue = value;
		}
		int sendValue = newValue - lastValue;
		lastValue = newValue;
		if ((sendValue > 0) && (sendValue < 5)) {
			sendMessage("Moved:" + sendValue);
		} else if ((sendValue > -5) && (sendValue < 0)) {
			sendMessage("Moved:" + sendValue);
		}
	}
	public void sendMessage(String suffix) {
		controls.outgoingSerial("RotEnc" + suffix);
	}
	public void setStatus(String inStatus) {
		if (inStatus.equals("wheelOn")) {
			wheelStatus = "on";
		} else if (inStatus.equals("wheelOff")) {
			wheelStatus = "off";
		} else if (inStatus.equals("wheelButtonBlue")) {
			buttonStatus = "blue";
		} else if (inStatus.equals("wheelButtonYellow")) {
			buttonStatus = "yellow";
		} else if (inStatus.equals("wheelButtonOff")) {
			buttonStatus = "off";
		}
	}
	public void paintBuffer(Graphics g) {
		if (wheelStatus.equals("on")) {
			g.drawImage(imageLoader.getImage(outerOn), 0, 0, this);
		} else {
			g.drawImage(imageLoader.getImage(outerOff), 0, 0, this);
		}
		if (buttonStatus.equals("blue")) {
			g.drawImage(imageLoader.getImage(innerBlue), ((226 - 80) / 2)-4, (226 - 80) / 2, this);
		}else if (buttonStatus.equals("yellow")) {
			g.drawImage(imageLoader.getImage(innerYellow), ((226 - 80) / 2)-4, (226 - 80) / 2, this);
		}
	}
	public void repaint() {
		paint(this.getGraphics());
	}
}