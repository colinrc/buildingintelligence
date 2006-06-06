/*
 * Created on 5/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.GUI;
import java.awt.AlphaComposite;
import java.awt.Color;
import java.awt.Component;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.util.Vector;

import au.com.BI.Connection.ServerHandler;
import au.com.BI.Objects.BIListener;
import au.com.BI.Util.ImageLoader;
/**
 * @author David
 *
 * 
 * 
 */
public abstract class BIButton extends Component  implements BIListener {
	/*Override Attributes*/
	protected int bgColour;
	protected int borderColour;
	protected String buttonFont;
	protected int fontColour;
	protected int fontSize;
	protected boolean disabled = false;	
	/*Inline Attributes*/
	protected int width;
	protected int height;
	protected boolean highlighted;
	protected int PNGWIDTH = 9;
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
	protected Image bufferImage;
	protected Graphics bufferGraphics;
	protected int bufferWidth;
	protected int bufferHeight;
	protected MouseAdapter mouseListener;
	/*BI Communication objects*/
	public BIButton(ImageLoader inImageLoader) {
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
		highlighted = false;
		mouseListener =new MouseAdapter() {
		public void mouseClicked(MouseEvent e) {
			doAction();
		}
		}; 
		this.addMouseListener(mouseListener);
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
	public abstract void doAction();
	public AlphaComposite makeComposite(float alpha) {
		int type = AlphaComposite.SRC_OVER;
		return (AlphaComposite.getInstance(type, alpha));
	}
	public void paint(Graphics g) {
		//    checks the buffersize with the current panelsize
		//    or initialises the image with the first paint
		resetBuffer();
		if (bufferGraphics != null) {
			//this clears the offscreen image, not the onscreen one
			Graphics2D g2d = (Graphics2D) bufferGraphics;
			g2d.setComposite(makeComposite((float) 1));
			bufferGraphics.clearRect(0, 0, bufferWidth, bufferHeight);
			//calls the paintbuffer method with 
			//the offscreen graphics as a param
			bufferGraphics.setColor(new java.awt.Color(82, 104, 141));
			bufferGraphics.fillRect(0, 0, this.getWidth(), height);			
			g2d.setComposite(makeComposite((float) 0.4));
			bufferGraphics.drawImage(baseTopLeft, 0, 0, this);
			bufferGraphics.drawImage(baseTop, PNGWIDTH, 0, width - (PNGWIDTH * 2), PNGWIDTH, this);
			bufferGraphics.drawImage(baseTopRight, width - PNGWIDTH, 0, this);
			bufferGraphics.drawImage(
				baseMiddleLeft,
				0,
				PNGWIDTH,
				PNGWIDTH,
				height - (PNGWIDTH * 2),
				this);
			bufferGraphics.drawImage(
				baseMiddle,
				PNGWIDTH,
				PNGWIDTH,
				width - (PNGWIDTH * 2),
				height - (PNGWIDTH * 2),
				this);
			bufferGraphics.drawImage(
				baseMiddleRight,
				width - PNGWIDTH,
				PNGWIDTH,
				PNGWIDTH,
				height - (PNGWIDTH * 2),
				this);
			bufferGraphics.drawImage(baseBottomLeft, 0, height - PNGWIDTH, this);
			bufferGraphics.drawImage(
				baseBottom,
				PNGWIDTH,
				height - PNGWIDTH,
				width - (PNGWIDTH * 2),
				PNGWIDTH,
				this);
			bufferGraphics.drawImage(baseBottomRight, width - PNGWIDTH, height - PNGWIDTH, this);
			g2d.setComposite(makeComposite(1));
			if (highlighted) {
				bufferGraphics.drawImage(highlightTopLeft, 0, 0, this);
				bufferGraphics.drawImage(
					highlightTop,
					PNGWIDTH,
					0,
					width - (PNGWIDTH * 2),
					PNGWIDTH,
					this);
				bufferGraphics.drawImage(highlightTopRight, width - PNGWIDTH, 0, this);
				bufferGraphics.drawImage(
					highlightMiddleLeft,
					0,
					PNGWIDTH,
					PNGWIDTH,
					height - (PNGWIDTH * 2),
					this);
				bufferGraphics.drawImage(
					highlightMiddleRight,
					width - PNGWIDTH,
					PNGWIDTH,
					PNGWIDTH,
					height - (PNGWIDTH * 2),
					this);
				bufferGraphics.drawImage(highlightBottomLeft, 0, height - PNGWIDTH, this);
				bufferGraphics.drawImage(
					highlightBottom,
					PNGWIDTH,
					height - PNGWIDTH,
					width - (PNGWIDTH * 2),
					PNGWIDTH,
					this);
				bufferGraphics.drawImage(
					highlightBottomRight,
					width - PNGWIDTH,
					height - PNGWIDTH,
					this);
			}
			if(disabled){
				g2d.setComposite(makeComposite((float) 1));
				g2d.setComposite(makeComposite((float) 0.5));
				g2d.setColor(new Color(82, 104, 141));
				g2d.fillRect(0,0,this.getWidth(),this.getHeight());
			}
			paintBuffer(bufferGraphics);
			//we finaly paint the offscreen image onto the onscreen image
			g.drawImage(bufferImage, 0, 0, this);
		}
	}
	public void setDisabled(boolean inEnabled){
		disabled = inEnabled;
		repaint();
	}
	public void paintBuffer(Graphics g) {
		//in classes extended from this one, add something to paint here!
		//always remember, g is the offscreen graphics
	}
	private void resetBuffer() {
		try {
			// always keep track of the image size
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
	public void update() {
		repaint();
	}
	public void repaint() {
		paint(this.getGraphics());
	}
	public boolean getGetHighLighted() {
		return highlighted;
	}
	public void setHighLighted(boolean inHighlighted) {
		highlighted = inHighlighted;
		repaint();
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
	public void finalize() throws Throwable {
		try {
			bufferImage = null;
			bufferGraphics = null;
		} finally {
			super.finalize();
		}
	}
	protected ServerHandler serverHandle = null;
		protected Vector keys = new Vector();
	public void setServerHandler(ServerHandler inServerHandler) {
		serverHandle = inServerHandler;
	}
	public void setKeys(Vector inVector) {
		keys = inVector;
	}
	public Vector getKeys() {
		return keys;
	}
}
