/*
 * Created on 8/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.GUI;

import java.awt.Graphics;
import java.awt.Image;
import java.util.Vector;

import au.com.BI.Connection.ServerHandler;
import au.com.BI.Util.ImageLoader;

/**
 *
 * @author David
 */
public class MainWindowBG extends java.awt.Container/*Canvas*/ {
	private Image image = null;
	private BIToggleButton testButton1;
	private BISimpleButton testButton2;
	private BISimpleButton testButton3;
	private BISimpleButton testButton4;
	private BISimpleButton testButton5;
	private BISimpleButton testButton6;
	private BISimpleButton testButton7;
	private BISimpleButton testButton8;
	private BISimpleButton testButton9;
	private ImageLoader imageLoader;
	private ServerHandler serverHandle;
	protected Image offScreenImage;
	/** Creates a new instance of MainWindowBG */
	public MainWindowBG(ImageLoader inImageLoader, ServerHandler inServerHandler) {
		imageLoader=inImageLoader;
		serverHandle = inServerHandler;
		initComponents();
	}
	public void initComponents(){
		testButton1 = new BIToggleButton(imageLoader);
		testButton1.setBounds(8,58,52,52);
		Vector newVector = new Vector();
		newVector.add("LIGHT1");
		testButton1.setCommand("state");
		testButton1.setExtras("off,on");
		testButton1.setIcons( "lib/icons/light-bulb-off,lib/icons/light-bulb");
		serverHandle.RegisterComponent(testButton1,newVector);
		this.add(testButton1);
		testButton2 = new BISimpleButton(imageLoader);
		testButton2.setBounds(8,118,52,52);
		this.add(testButton2);
		testButton3 = new BISimpleButton(imageLoader);
		testButton3.setBounds(8,178,52,52);
		this.add(testButton3);
		testButton4 = new BISimpleButton(imageLoader);
		testButton4.setBounds(68,58,52,52);
		this.add(testButton4);
		testButton5 = new BISimpleButton(imageLoader);
		testButton5.setBounds(68,118,52,52);
		this.add(testButton5);
		testButton6 = new BISimpleButton(imageLoader);
		testButton6.setBounds(68,178,52,52);
		this.add(testButton6);
		testButton7 = new BISimpleButton(imageLoader);
		testButton7.setBounds(128,58,52,52);
		this.add(testButton7);
		testButton8 = new BISimpleButton(imageLoader);
		testButton8.setBounds(128,118,52,52);
		this.add(testButton8);
		testButton9 = new BISimpleButton(imageLoader);
		testButton9.setBounds(128,178,52,52);
		this.add(testButton9);
	}
	public void update(Graphics graphics) {
		// Create an offscreen image and then get its
		// graphics context for the drawing.
		 if ( offScreenImage == null )
		   offScreenImage =
			 createImage( getSize().width,
						  getSize().height );

		 Graphics gOffScreenImage= offScreenImage.getGraphics();

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
		 paint( gOffScreenImage );

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
		graphics.setColor( new java.awt.Color(82, 104, 141));
		graphics.fillRect(0,0,graphics.getClipBounds().width,graphics.getClipBounds().height);
		graphics.setColor( new java.awt.Color(0, 0, 0));
		graphics.fillRect(0,0,graphics.getClipBounds().width,50);
		graphics.setColor( new java.awt.Color(255, 255, 255));
		graphics.setFont(new java.awt.Font("helvetica",java.awt.Font.PLAIN,16));
		graphics.drawString("Monday, 22 August 2006",0,25);
		graphics.setFont(new java.awt.Font("helvetica",java.awt.Font.BOLD,12));
		graphics.drawString("Macros",3,45);
		super.paint(graphics);		
	}
	public void repaint(){
		update(this.getGraphics());
	}
}
