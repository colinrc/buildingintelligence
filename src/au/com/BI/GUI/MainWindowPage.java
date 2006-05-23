/*
 * Created on 22/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.GUI;
import java.awt.Container;
import java.awt.Graphics;
import java.awt.Image;
import java.util.Vector;

import au.com.BI.Connection.ServerHandler;
import au.com.BI.Util.ImageLoader;
/**
 * @author David
 *
 * 
 * 
 */
public class MainWindowPage extends Container {
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
	/**
	 * 
	 */
	public MainWindowPage(ImageLoader inImageLoader, ServerHandler inServerHandler) {
		// TODO Auto-generated constructor stub
		imageLoader = inImageLoader;
		serverHandle = inServerHandler;
		initComponents();
	}
	public void initComponents() {
		testButton1 = new BIToggleButton(imageLoader);
		testButton1.setBounds(10, 10, 66, 66);
		Vector newVector = new Vector();
		newVector.add("LIGHT1");
		testButton1.setCommand("state");
		testButton1.setExtras("off,on");
		testButton1.setIcons("lib/icons/light-bulb-off,lib/icons/light-bulb");
		serverHandle.RegisterComponent(testButton1, newVector);
		this.add(testButton1);
		testButton2 = new BISimpleButton(imageLoader);
		testButton2.setBounds(10, 86, 66, 66);
		newVector = new Vector();
		newVector.add("LIGHT2");
		testButton2.setCommand("on");
		testButton2.setExtra("100");
		testButton2.setIcon("lib/icons/light-bulb");
		serverHandle.RegisterComponent(testButton2, newVector);
		this.add(testButton2);
		testButton3 = new BISimpleButton(imageLoader);
		testButton3.setBounds(10, 162, 66, 66);
		testButton3.setCommand("on");
		testButton3.setExtra("100");
		testButton3.setIcon("lib/icons/light-bulb");
		serverHandle.RegisterComponent(testButton3, newVector);
		this.add(testButton3);
		testButton4 = new BISimpleButton(imageLoader);
		testButton4.setBounds(86, 10, 66, 66);
		testButton4.setCommand("on");
		testButton4.setExtra("100");
		testButton4.setIcon("lib/icons/light-bulb");
		serverHandle.RegisterComponent(testButton4, newVector);
		this.add(testButton4);
		testButton5 = new BISimpleButton(imageLoader);
		testButton5.setBounds(86, 86, 66, 66);
		testButton5.setCommand("on");
		testButton5.setExtra("100");
		testButton5.setIcon("lib/icons/light-bulb");
		serverHandle.RegisterComponent(testButton5, newVector);
		this.add(testButton5);
		testButton6 = new BISimpleButton(imageLoader);
		testButton6.setBounds(86, 162, 66, 66);
		testButton6.setCommand("on");
		testButton6.setExtra("100");
		testButton6.setIcon("lib/icons/light-bulb");
		serverHandle.RegisterComponent(testButton6, newVector);
		this.add(testButton6);
		testButton7 = new BISimpleButton(imageLoader);
		testButton7.setBounds(162, 10, 66, 66);
		testButton7.setCommand("on");
		testButton7.setExtra("100");
		testButton7.setIcon("lib/icons/light-bulb");
		serverHandle.RegisterComponent(testButton7, newVector);
		this.add(testButton7);
		testButton8 = new BISimpleButton(imageLoader);
		testButton8.setBounds(162, 86, 66, 66);
		testButton8.setCommand("on");
		testButton8.setExtra("100");
		testButton8.setIcon("lib/icons/light-bulb");
		serverHandle.RegisterComponent(testButton8, newVector);
		this.add(testButton8);
		testButton9 = new BISimpleButton(imageLoader);
		testButton9.setBounds(162, 162, 66, 66);
		testButton9.setCommand("on");
		testButton9.setExtra("100");
		testButton9.setIcon("lib/icons/light-bulb");
		serverHandle.RegisterComponent(testButton9, newVector);
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
		super.paint(graphics);
	}
	public void repaint(){
		update(this.getGraphics());
	}
}
