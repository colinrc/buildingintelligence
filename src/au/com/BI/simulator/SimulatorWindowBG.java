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
	/**
	 * 
	 */
	public SimulatorWindowBG(ServerHandler inServerHandler, ImageLoader imageLoader) {
		this.imageLoader = imageLoader;
		serverHandle = inServerHandler;
		bg = new MainWindowBG(imageLoader, serverHandle);
		bg.setBounds(180,59,240,320);
		this.add(bg);
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
		//graphics.setColor( new java.awt.Color(82, 104, 141));
		//graphics.fillRect(0,0,graphics.getClipBounds().width,graphics.getClipBounds().height);
		//graphics.setColor( new java.awt.Color(0, 0, 0));
		//graphics.fillRect(0,0,graphics.getClipBounds().width,50);
		//graphics.setColor( new java.awt.Color(255, 255, 255));
		//graphics.setFont(new java.awt.Font("helvetica",java.awt.Font.PLAIN,16));
		//graphics.drawString("Monday, 22 August 2006",0,25);
		//graphics.setFont(new java.awt.Font("helvetica",java.awt.Font.BOLD,12));
		//graphics.drawString("Macros",3,45);
		super.paint(graphics);		
		graphics.drawImage(imageLoader.getImage("images/elife_active/elife-base"),0,-20,this);
		
		
	}
	public void repaint(){
		update(this.getGraphics());
	}
}
