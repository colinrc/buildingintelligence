/*
 * Created on 5/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.GUI;
import java.awt.AlphaComposite;
import java.awt.Component;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.util.Vector;

import au.com.BI.Command.Command;
import au.com.BI.Connection.ServerHandler;
import au.com.BI.Objects.BIListener;
import au.com.BI.Objects.BIState;
import au.com.BI.Util.ImageLoader;
/**
 * @author David
 *
 * 
 * 
 */
public abstract class BIButton extends Component implements Runnable, BIListener {
	/*Override Attributes*/
	protected int bgColour;
	protected int borderColour;
	protected String buttonFont;
	protected int fontColour;
	protected int fontSize;
	/*Inline Attributes*/
	protected Vector keys = new Vector();
	protected int width;
	protected int height;
	protected int PNGWIDTH = 9;
	protected int highlighted;
	/*Button Components*/
	protected ImageLoader imageLoader;
	protected Image baseTopLeft;
	protected Image baseTop;
	protected Image baseTopRight;
	protected Image baseMiddleLeft;
	protected Image baseMiddle;
	protected Image baseMiddleRight;
	protected Image baseBottomLeft;
	protected Image baseBottom;
	protected Image baseBottomRight;
	protected Image highlightTopLeft;
	protected Image highlightTop;
	protected Image highlightTopRight;
	protected Image highlightMiddleLeft;
	protected Image highlightMiddleRight;
	protected Image highlightBottomLeft;
	protected Image highlightBottom;
	protected Image highlightBottomRight;
	protected Image offScreenImage;
	/*Concurrent Components*/
	protected Thread updateThread = null;
	/*BI Communication objects*/
	protected BIState state = null;
	protected ServerHandler serverHandle = null;
	public BIButton(ImageLoader inImageLoader) {
		//this.setCursor();
		imageLoader = inImageLoader;
		/*Override Attributes*/
		bgColour = Integer.parseInt("0x7C90B0".substring(2), 16);
		borderColour = Integer.parseInt("0x95A7C4".substring(2), 16);
		buttonFont = "helvetica";
		fontColour = Integer.parseInt("0xFFFFFF".substring(2), 16);
		fontSize = 16;
		/*Inline Attributes*/
		width = 66;
		height = 66;
		highlighted = 0;
		if (updateThread == null) {
			updateThread = new Thread(this, "highlighter");
		}
		this.addMouseListener(new MouseAdapter() {
			public void mouseClicked(MouseEvent e) {
				if (updateThread.isAlive()) {
					stop();
					updateThread.start();
					highlighted = 100;
				} else {
					updateThread.start();
					highlighted = 100;
				}
				serverHandle.sendToServer(createMessage());
				repaint(highlighted);
			}
		});
		baseTopLeft = imageLoader.getImage("images/base/button-base_01");
		baseTop = imageLoader.getImage("images/base/button-base_02");
		baseTopRight = imageLoader.getImage("images/base/button-base_03");
		baseMiddleLeft = imageLoader.getImage("images/base/button-base_04");
		baseMiddle = imageLoader.getImage("images/base/button-base_05");
		baseMiddleRight = imageLoader.getImage("images/base/button-base_06");
		baseBottomLeft = imageLoader.getImage("images/base/button-base_07");
		baseBottom = imageLoader.getImage("images/base/button-base_08");
		baseBottomRight = imageLoader.getImage("images/base/button-base_09");
		highlightTopLeft = imageLoader.getImage("images/highlight/button-highlight_01");
		highlightTop = imageLoader.getImage("images/highlight/button-highlight_02");
		highlightTopRight = imageLoader.getImage("images/highlight/button-highlight_03");
		highlightMiddleLeft = imageLoader.getImage("images/highlight/button-highlight_04");
		highlightMiddleRight = imageLoader.getImage("images/highlight/button-highlight_06");
		highlightBottomLeft = imageLoader.getImage("images/highlight/button-highlight_07");
		highlightBottom = imageLoader.getImage("images/highlight/button-highlight_08");
		highlightBottomRight = imageLoader.getImage("images/highlight/button-highlight_09");
	}
	public abstract Command createMessage();
	public void paint(Graphics graphics) {
		Graphics g2 = offScreenImage == null ? graphics : offScreenImage.getGraphics();
		graphics.setColor(new java.awt.Color(82, 104, 141));
		graphics.fillRect(0, 0, width, height);
		Graphics2D g2d = (Graphics2D)graphics;
		g2d.setComposite(makeComposite((float)0.4));
		//}
		// Create an offscreen image and then get its
		// graphics context for the drawing.
		// Don't bother to call paint,
		// just draw the offscreen image
		// to the screen.
		graphics.drawImage(baseTopLeft, 0, 0, this);
		graphics.drawImage(baseTop, PNGWIDTH, 0, width - (PNGWIDTH * 2), PNGWIDTH, this);
		graphics.drawImage(baseTopRight, width - PNGWIDTH, 0, this);
		graphics.drawImage(baseMiddleLeft, 0, PNGWIDTH, PNGWIDTH, height - (PNGWIDTH * 2), this);
		graphics.drawImage(
			baseMiddle,
			PNGWIDTH,
			PNGWIDTH,
			width - (PNGWIDTH * 2),
			height - (PNGWIDTH * 2),
			this);
		graphics.drawImage(
			baseMiddleRight,
			width - PNGWIDTH,
			PNGWIDTH,
			PNGWIDTH,
			height - (PNGWIDTH * 2),
			this);
		graphics.drawImage(baseBottomLeft, 0, height - PNGWIDTH, this);
		graphics.drawImage(
			baseBottom,
			PNGWIDTH,
			height - PNGWIDTH,
			width - (PNGWIDTH * 2),
			PNGWIDTH,
			this);
		graphics.drawImage(baseBottomRight, width - PNGWIDTH, height - PNGWIDTH, this);
		if (offScreenImage != null)
			graphics.drawImage(offScreenImage, 0, 0, this);
		g2d.setComposite(makeComposite(1));
		super.paint(graphics);
	}
	public void setServerHandler(ServerHandler inServerHandler) {
		serverHandle = inServerHandler;
	}
	public void setKeys(Vector inVector) {
		keys = inVector;
	}
	public Vector getKeys() {
		return keys;
	}
	public void setState(BIState inState) {
		state = inState;
	}
	public void update() {
		repaint(highlighted);
	}
	public void repaint() {
		update(this.getGraphics());
	}
	private AlphaComposite makeComposite(float alpha) {
		int type = AlphaComposite.SRC_OVER;
		return (AlphaComposite.getInstance(type, alpha));
	}
	public void repaint(int highlighted) {
		Graphics graphics = this.getGraphics();
		update(graphics);
		Graphics2D g2d = (Graphics2D)graphics;
		g2d.setComposite(makeComposite((float)0.01*highlighted));
		if (highlighted > 0) {			
			graphics.drawImage(highlightTopLeft, 0, 0, this);
			graphics.drawImage(highlightTop, PNGWIDTH, 0, width - (PNGWIDTH * 2), PNGWIDTH, this);
			graphics.drawImage(highlightTopRight, width - PNGWIDTH, 0, this);
			graphics.drawImage(
				highlightMiddleLeft,
				0,
				PNGWIDTH,
				PNGWIDTH,
				height - (PNGWIDTH * 2),
				this);
			graphics.drawImage(
				highlightMiddleRight,
				width - PNGWIDTH,
				PNGWIDTH,
				PNGWIDTH,
				height - (PNGWIDTH * 2),
				this);
			graphics.drawImage(highlightBottomLeft, 0, height - PNGWIDTH, this);
			graphics.drawImage(
				highlightBottom,
				PNGWIDTH,
				height - PNGWIDTH,
				width - (PNGWIDTH * 2),
				PNGWIDTH,
				this);
			graphics.drawImage(highlightBottomRight, width - PNGWIDTH, height - PNGWIDTH, this);
		}
		
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
	public int getGetHighLighted() {
		return highlighted;
	}
	public void setHighLighted(int inHighlighted) {
		highlighted = inHighlighted;
	}
	public void setBGColour(String inString) {
		bgColour = Integer.parseInt(inString.substring(2), 16);
	}
	public void setBorderColour(String inString) {
		borderColour = Integer.parseInt(inString.substring(2), 16);
	}
	public void setButtonFont(String inString) {
		buttonFont = inString;
	}
	public void setFontColour(String inString) {
		fontColour = Integer.parseInt(inString.substring(2), 16);
	}
	public void setFontSize(String inString) {
		fontSize = Integer.parseInt(inString);
	}
	public void setWidth(String inString) {
		width = Integer.parseInt(inString);
	}
	public void setHeight(String inString) {
		height = Integer.parseInt(inString);
	}
	abstract public void run();
	public void stop() {
		if (updateThread.isAlive()) {
			updateThread = null;
			updateThread = new Thread(this, "highlighter");
		}
	}
}
