/*
 * Created on 22/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.simulator;
import java.awt.Container;
import java.awt.Graphics;
import java.awt.Image;
import au.com.BI.Connection.ServerHandler;
import au.com.BI.GUI.MainWindowBG;
import au.com.BI.Serial.SerialHandler;
import au.com.BI.Util.ImageLoader;
import au.com.BI.DataModel.eLifeActiveLoader;
/**
 * @author David
 *
 * 
 * 
 */
public class SimulatorWindowBG extends Container {
	private MainWindowBG bg;
	private ServerHandler serverHandle;
	private ImageLoader imageLoader;
	private Image offScreenImage;
	private SimulatorButton b1;
	private SimulatorButton b2;
	private SimulatorButton b3;
	private SimulatorButton b4;
	private SimulatorEncoder rotoryEncoder;
	private SimulatorEMan eMan;
	private SimulatorControls controls;
	private eLifeActiveLoader client;
	private SerialHandler serialHandle;
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
		g.drawImage(imageLoader.getImage("images/elife_active/elife-base"), 0, -20, this);
		super.paint(g);
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
			//    create the new image with the size of the panel
			bufferImage = createImage(bufferWidth, bufferHeight);
			bufferGraphics = bufferImage.getGraphics();
		} catch (Exception e) {
		}
	}
	public void repaint() {
		paint(this.getGraphics());
	}
	/**eLifeActiveLoader
	 * 
	 */
	public SimulatorWindowBG(
		ServerHandler inServerHandler,
		ImageLoader imageLoader,
		SimulatorControls controls,
		eLifeActiveLoader client,
		SerialHandler serialHandle) {
		this.imageLoader = imageLoader;
		this.controls = controls;
		serverHandle = inServerHandler;
		this.client = client;
		this.serialHandle = serialHandle;
		b1 = new SimulatorButton(imageLoader, "b1", controls);
		b1.setBounds(56, 52, 80, 75);
		this.add(b1);
		b2 = new SimulatorButton(imageLoader, "b2", controls);
		b2.setBounds(56, 133, 80, 75);
		this.add(b2);
		b3 = new SimulatorButton(imageLoader, "b3", controls);
		b3.setBounds(56, 217, 80, 75);
		this.add(b3);
		b4 = new SimulatorButton(imageLoader, "b4", controls);
		b4.setBounds(56, 298, 80, 75);
		this.add(b4);
		eMan = new SimulatorEMan(imageLoader, controls);
		eMan.setBounds(515, 85, 63, 64);
		this.add(eMan);
		rotoryEncoder = new SimulatorEncoder(imageLoader, controls);
		rotoryEncoder.setBounds(433, 145, 226, 266);
		this.add(rotoryEncoder);
	}
	public void init() {
		bg = new MainWindowBG(imageLoader, serverHandle, client, serialHandle);
		bg.setBounds(180, 59, 240, 320);
		this.add(bg);
	}
	public SerialHandler getSerialHandler() {
		return bg.getSerialHandle();
	}
	public void receiveMessage(String inMessage) {
		//bg.receiveMessage(inMessage);
		//System.out.println(inMessage);
		if (inMessage.equals("B1Off")) {
			b1.setStatus("off");
			b1.repaint();
		} else if (inMessage.equals("B1Blue")) {
			b1.setStatus("on");
			b1.repaint();
		} else if (inMessage.equals("B1Yellow")) {
			b1.setStatus("yellow");
			b1.repaint();
		} else if (inMessage.equals("B2Off")) {
			b2.setStatus("off");
			b2.repaint();
		} else if (inMessage.equals("B2Blue")) {
			b2.setStatus("on");
			b2.repaint();
		} else if (inMessage.equals("B2Yellow")) {
			b2.setStatus("yellow");
			b2.repaint();
		} else if (inMessage.equals("B3Off")) {
			b3.setStatus("off");
			b3.repaint();
		} else if (inMessage.equals("B3Blue")) {
			b3.setStatus("on");
			b3.repaint();
		} else if (inMessage.equals("B3Yellow")) {
			b3.setStatus("yellow");
			b3.repaint();
		} else if (inMessage.equals("B4Off")) {
			b4.setStatus("off");
			b4.repaint();
		} else if (inMessage.equals("B4Blue")) {
			b4.setStatus("on");
			b4.repaint();
		} else if (inMessage.equals("B4Yellow")) {
			b4.setStatus("yellow");
			b4.repaint();
		} else if (inMessage.equals("eManOn")) {
			eMan.setStatus("on");
			eMan.repaint();
		} else if (inMessage.equals("eManOff")) {
			eMan.setStatus("off");
			eMan.repaint();
		} else if (inMessage.equals("wheelOn")) {
			rotoryEncoder.setStatus(inMessage);
			rotoryEncoder.repaint();
		} else if (inMessage.equals("wheelOff")) {
			rotoryEncoder.setStatus(inMessage);
			rotoryEncoder.repaint();
		} else if (inMessage.equals("wheelButtonOn")) {
			rotoryEncoder.setStatus(inMessage);
			rotoryEncoder.repaint();
		} else if (inMessage.equals("wheelButtonOff")) {
			rotoryEncoder.setStatus(inMessage);
			rotoryEncoder.repaint();
		} else if (inMessage.equals("BacklightOn")) {
		} else if (inMessage.equals("BacklightOff")) {
		} else if (inMessage.equals("getTemp")) {
		} else if (inMessage.equals("getLight")) {
		}
		//repaint();	
	}
}
