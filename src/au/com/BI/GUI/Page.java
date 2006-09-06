/*
 * Created on 26/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.GUI;
import java.awt.AlphaComposite;
import java.awt.Component;
import java.awt.Container;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.util.HashMap;
import java.util.Vector;

import au.com.BI.Connection.ServerHandler;
import au.com.BI.DataModel.BIObject;
import au.com.BI.Objects.BIListener;
import au.com.BI.Serial.SerialHandler;
import au.com.BI.Util.ImageHandler;
/**
 * @author David
 *
 * 
 * 
 */
public abstract class Page extends Container {
	protected ImageHandler imageLoader;
	protected int bufferWidth;
	protected int bufferHeight;
	protected Image bufferImage;
	protected Graphics bufferGraphics;
	protected Vector PageInfo;
	protected HashMap buttons;
	protected int pagePositions;
	protected int currentPosition;
	protected int encoderPosition;
	protected int selected = 0;
	protected int highlightedButton = 0;
	protected SerialHandler serialHandle;
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
		// TODO Auto-generated constructor stub
	}
	public void setButtonsOn(){
		serialHandle.sendSerialMessage("B2Off");
		serialHandle.sendSerialMessage("B2Blue");
		serialHandle.sendSerialMessage("B3Blue");
		serialHandle.sendSerialMessage("B4Blue");
		serialHandle.sendSerialMessage("wheelOn");
		serialHandle.sendSerialMessage("wheelButtonOff");
	}
	public void paintBuffer(Graphics g) {
		//in classes extended from this one, add something to paint here!
		//always remember, g is the offscreen graphics
		g.setColor(new java.awt.Color(82, 104, 141));
		g.fillRect(0, 0, 240, 320);
		Graphics2D g2d = (Graphics2D)g;
		g2d.setComposite(makeComposite((float) 1));
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
			//System.gc();
			//    create the new image with the size of the panel
			bufferImage = createImage(bufferWidth, bufferHeight);
			bufferGraphics = bufferImage.getGraphics();
		} catch (Exception e) {
		}
	}
	public void repaint() {
		paint(this.getGraphics());
	}
	/**
	 * 
	 */
	public Page(ImageHandler inImageLoader, SerialHandler serialHandle, Vector PageInfo) {
		imageLoader = inImageLoader;
		this.serialHandle =serialHandle;
		this.PageInfo = PageInfo;
		int rows = PageInfo.size() / 3;
		if ((PageInfo.size() % 3) != 0) {
			rows = rows + 1;
		}
		pagePositions = Math.max(rows - 3, 0);
		currentPosition = 0;
		buttons = new HashMap();
		setButtonsOn();
	}
	public AlphaComposite makeComposite(float alpha) {
		int type = AlphaComposite.SRC_OVER;
		return (AlphaComposite.getInstance(type, alpha));
	}
	public abstract void initComponents();
	public abstract BIButton createBIButton(BIObject inObject);
	public void setButtonPosition(Component inComponent, int positionNo) {
		switch (positionNo) {
			case 1 :
				inComponent.setLocation(10, 10);
				break;
			case 2 :
				inComponent.setLocation(86, 10);
				break;
			case 3 :
				inComponent.setLocation(162, 10);
				break;
			case 4 :
				inComponent.setLocation(10, 86);
				break;
			case 5 :
				inComponent.setLocation(86, 86);
				break;
			case 6 :
				inComponent.setLocation(162, 86);
				break;
			case 7 :
				inComponent.setLocation(10, 162);
				break;
			case 8 :
				inComponent.setLocation(86, 162);
				break;
			case 9 :
				inComponent.setLocation(162, 162);
				break;
		}
	}
	public void navUp() {
		if (pagePositions > 0) {
			if (currentPosition != 0) {
				this.removeAll();
				currentPosition = currentPosition - 1;
				int vectorPosition = currentPosition * 3;
				int buttonCount = Math.min(PageInfo.size() - vectorPosition, 9);
				for (int Index = 0; Index < buttonCount; Index++) {
					setButtonPosition(
						((BIButton) buttons.get((Index + vectorPosition) + "")),
						(Index + vectorPosition + 1));
					add(((BIButton) buttons.get("" + (Index + vectorPosition))));
				}
				repaint();
			}
		}
	}
	public void navDown() {
		if (pagePositions > 0) {
			if (currentPosition != pagePositions) {
				this.removeAll();
				currentPosition = currentPosition + 1;
				int vectorPosition = currentPosition * 3;
				int buttonCount = Math.min(PageInfo.size() - vectorPosition, 9);
				for (int Index = 0; Index < buttonCount; Index++) {
					setButtonPosition(
						((BIButton) buttons.get((Index + vectorPosition) + "")),
						(Index + 1));
					add(((BIButton) buttons.get("" + (Index + vectorPosition))));
				}
				repaint();
			}
		}
	}
	public void encChange(int value) {
		selected = selected + value;
		if (selected > 15) {
			if (highlightedButton + 1 < PageInfo.size()) {
				if (highlightedButton + 1 >= (currentPosition * 3) + 9) {
					navDown();
					((BIButton) buttons.get(highlightedButton + "")).setHighLighted(false);
					highlightedButton++;
					((BIButton) buttons.get(highlightedButton + "")).setHighLighted(true);
				} else {
					((BIButton) buttons.get(highlightedButton + "")).setHighLighted(false);
					highlightedButton++;
					((BIButton) buttons.get(highlightedButton + "")).setHighLighted(true);
				}
			}
			selected = 0;
		} else if (selected < -15) {
			if (highlightedButton > 0) {
				if (highlightedButton - 1 < (currentPosition * 3)) {
					navUp();
					((BIButton) buttons.get(highlightedButton + "")).setHighLighted(false);
					highlightedButton--;
					((BIButton) buttons.get(highlightedButton + "")).setHighLighted(true);
				} else {
					((BIButton) buttons.get(highlightedButton + "")).setHighLighted(false);
					highlightedButton--;
					((BIButton) buttons.get(highlightedButton + "")).setHighLighted(true);
				}
			}
			selected = 0;
		}
	}
	public void setSelected(BIButton inButton) {
		for (int index = 0; index < PageInfo.size(); index++) {
			if (((BIButton) buttons.get(index + "")).equals(inButton)) {
				if (highlightedButton != index) {
					((BIButton) buttons.get(highlightedButton + "")).setHighLighted(false);
					highlightedButton = index;
					((BIButton) buttons.get(highlightedButton + "")).setHighLighted(true);
				}
			}
		}
	}
	public void select() {
		((BIButton) buttons.get(highlightedButton + "")).doAction();
	}
	public void cancel() {
		((MainWindowBG)this.getParent()).goHome();
	}
	public void upButton(){
		((MainWindowBG)this.getParent()).upPage();
	}
	public void downButton(){
		((MainWindowBG)this.getParent()).downPage();
	}
	public void click(){
	}
	public void finalize() throws Throwable {
		try {
			bufferImage = null;
			bufferGraphics = null;
			for (int index = 0; index < PageInfo.size(); index++) {
				BIButton tempButton = ((BIButton) buttons.remove(index + ""));
				if (tempButton instanceof BIListener) {
					ServerHandler.getInstance().unRegisterComponent(((BIListener) tempButton));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			super.finalize();
		}
	}
}
