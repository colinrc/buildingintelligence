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
	/**
	 * 
	 */
	public SimulatorWindowBG(ServerHandler inServerHandler, ImageLoader imageLoader, SimulatorControls controls) {
		this.imageLoader = imageLoader;
		this.controls = controls;
		serverHandle = inServerHandler;
		bg = new MainWindowBG(imageLoader, serverHandle);
		bg.setBounds(180, 59, 240, 320);
		this.add(bg);
		b1 = new SimulatorButton(imageLoader, "b1",controls);
		b1.setBounds(50, 47, 83, 83);
		this.add(b1);
		b2 = new SimulatorButton(imageLoader, "b2",controls);
		b2.setBounds(50, 129, 83, 83);
		this.add(b2);
		b3 = new SimulatorButton(imageLoader, "b3",controls);
		b3.setBounds(50, 212, 83, 83);
		this.add(b3);
		b4 = new SimulatorButton(imageLoader, "b4",controls);
		b4.setBounds(50, 296, 83, 83);
		this.add(b4);
		eMan = new SimulatorEMan(imageLoader, controls);
		eMan.setBounds(520,85,50,49);
		this.add(eMan);
		rotoryEncoder = new SimulatorEncoder(imageLoader, controls);
		rotoryEncoder.setBounds(433,145,226,266);
		this.add(rotoryEncoder);
	}
	public SerialHandler getSerialHandler(){
		return bg.getSerialHandle();
	}
	public void update(Graphics graphics) {
		// Create an offscreen image and then get its
		// graphics context for the drawing.
		if (offScreenImage == null)
			offScreenImage = createImage(getSize().width, getSize().height);
		Graphics gOffScreenImage = offScreenImage.getGraphics();
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
	public void paint(Graphics graphics) {
		//graphics.setColor( new java.awt.Color(82, 104, 141));
		//graphics.fillRect(0,0,graphics.getClipBounds().width,graphics.getClipBounds().height);
		//graphics.setColor( new java.awt.Color(0, 0, 0));
		//graphics.fillRect(0,0,graphics.getClipBounds().width,50);
		//graphics.setColor( new java.awt.Color(255, 255, 255));
		//graphics.setFont(new java.awt.Font("helvetica",java.awt.Font.PLAIN,16));
		//graphics.drawString("Monday, 22 August 2006",0,25);
		//graphics.setFont(new java.awt.Font("helvetica",java.awt.Font.BOLD,12));
		//graphics.drawString("Macros",3,45);
		
		//graphics.drawImage(bg.createImage(240,320),0,0,this);		
		graphics.drawImage(imageLoader.getImage("images/elife_active/elife-base"), 0, -20, this);
		super.paint(graphics);
		//graphics.drawImage(homeButton.createImage(83,83),50,50,this);
		//graphics.drawImage(imageLoader.getImage("images/elife_active/button-halo-green"),100, 50, 39,83, this);
		//graphics.drawImage(imageLoader.getImage("images/elife_active/button-halo-green"),100, 130, 39,83, this);
		//graphics.drawImage(imageLoader.getImage("images/elife_active/button-halo-green"),100, 215, 39,83, this);
		//graphics.drawImage(imageLoader.getImage("images/elife_active/button-halo-green"),100, 296, 39,83, this);
	}
	public void repaint() {
		update(this.getGraphics());
	}
	public void receiveMessage(String inMessage){
		//bg.receiveMessage(inMessage);
		//System.out.println(inMessage);
		if(inMessage.equals("B1Off")){
			b1.setStatus("off");
			b1.repaint();
		} else if(inMessage.equals("B1Green")){
			b1.setStatus("on");
			b1.repaint();			
		} else if(inMessage.equals("B1Yellow")){
			b1.setStatus("yellow");
			b1.repaint();
		} else if(inMessage.equals("B2Off")){
			b2.setStatus("off");
			b2.repaint();
		} else if(inMessage.equals("B2Green")){
			b2.setStatus("on");
			b2.repaint();
		} else if(inMessage.equals("B2Yellow")){
			b2.setStatus("yellow");
			b2.repaint();
		} else if(inMessage.equals("B3Off")){
			b3.setStatus("off");
			b3.repaint();
		} else if(inMessage.equals("B3Green")){
			b3.setStatus("on");
			b3.repaint();
		} else if(inMessage.equals("B3Yellow")){
			b3.setStatus("yellow");
			b3.repaint();
		} else if(inMessage.equals("B4Off")){
			b4.setStatus("off");
			b4.repaint();
		} else if(inMessage.equals("B4Green")){
			b4.setStatus("on");
			b4.repaint();
		} else if(inMessage.equals("B4Yellow")){
			b4.setStatus("yellow");
			b4.repaint();
		} else if(inMessage.equals("eManOn")){
			eMan.setStatus("on");
			eMan.repaint();
		} else if(inMessage.equals("eManOff")){
			eMan.setStatus("off");
			eMan.repaint();
		} else if(inMessage.equals("wheelOn")){
			rotoryEncoder.setStatus(inMessage);
			rotoryEncoder.repaint();
		} else if(inMessage.equals("wheelOff")){
			rotoryEncoder.setStatus(inMessage);
			rotoryEncoder.repaint();
		} else if(inMessage.equals("wheelButtonOn")){
			rotoryEncoder.setStatus(inMessage);
			rotoryEncoder.repaint();
		} else if(inMessage.equals("wheelButtonOff")){
			rotoryEncoder.setStatus(inMessage);
			rotoryEncoder.repaint();
		} else if(inMessage.equals("BacklightOn")){
			
		} else if(inMessage.equals("BacklightOff")){
			
		} else if(inMessage.equals("getTemp")){
			
		} else if(inMessage.equals("getLight")){
		}	
	}
}
