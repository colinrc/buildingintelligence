/*
 * Created on 1/06/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.GUI;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.MediaTracker;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import au.com.BI.Command.Command;
import au.com.BI.DataModel.Key;
import au.com.BI.Objects.BIListener;
import au.com.BI.Util.ImageLoader;
/**
 * @author David
 *
 * 
 * 
 */
public class BISliderButton extends BIButton implements BIListener {
	private String command = "";
	private int value = 0;
	private String extra = "";
	private String extra2 = "";
	private String interactive = "";
	private String icon1;
	private String icon2;
	private Image iconImg1;
	private Image iconImg2;
	private String FULL = "images/levels/ramp-full";
	private String EIGTHY = "images/levels/ramp-80";
	private String SIXTY = "images/levels/ramp-60";
	private String FORTY = "images/levels/ramp-40";
	private String TWENTY = "images/levels/ramp-20";
	private String EMPTY = "images/levels/ramp-0";
	private Image rampFull;
	private Image ramp80;
	private Image ramp60;
	private Image ramp40;
	private Image ramp20;
	private Image rampEmpty;
	private boolean active = false;
	/**
	 * @param inImageLoader
	 */
	public BISliderButton(ImageLoader inImageLoader) {
		super(inImageLoader);
		// TODO Auto-generated constructor stub
		rampFull = inImageLoader.getImage(FULL);
		ramp80 = inImageLoader.getImage(EIGTHY);
		ramp60 = inImageLoader.getImage(SIXTY);
		ramp40 = inImageLoader.getImage(FORTY);
		ramp20 = inImageLoader.getImage(TWENTY);
		rampEmpty = inImageLoader.getImage(EMPTY);
		this.removeMouseListener(mouseListener);
		this.addMouseListener(new MouseAdapter() {
			public void mouseClicked(MouseEvent e) {
				//	doAction();
				if (e.getX() > 70) {
					rampClicked();
				} else {
					buttonClicked();
				}
			}
		});
	}
	/* (non-Javadoc)
	 * @see au.com.BI.GUI.BIButton#doAction()
	 */
	public void paintBuffer(Graphics graphics) {
		int tempInt;
		try {
			tempInt = Integer.parseInt(((Key) keys.get(0)).getState().getExtra());
		} catch (NumberFormatException e) {
			tempInt = 0;
		}
		if ((value > 0) || ((!active) && (tempInt > 0))) {
			graphics.drawImage(iconImg2, 9, 9, this);
		} else {
			graphics.drawImage(iconImg1, 9, 9, this);
		}
		/**/
		Graphics2D g2d = (Graphics2D) graphics;
		g2d.setComposite(makeComposite((float) 0.4));
		bufferGraphics.drawImage(baseTopLeft, 70, 0, this);
		bufferGraphics.drawImage(
			baseMiddleLeft,
			70,
			PNGWIDTH,
			PNGWIDTH,
			height - (PNGWIDTH * 2),
			this);
		bufferGraphics.drawImage(baseBottomLeft, 70, height - PNGWIDTH, this);
		if ((!disabled) && (!((DevicePage) this.getParent()).sliderActive())) {
			bufferGraphics.drawImage(
				baseTop,
				PNGWIDTH + 70,
				0,
				width + 82 - (PNGWIDTH * 2),
				PNGWIDTH,
				this);
			bufferGraphics.drawImage(baseTopRight, width - PNGWIDTH + 70 + 82, 0, this);
			bufferGraphics.drawImage(
				baseMiddle,
				PNGWIDTH + 70,
				PNGWIDTH,
				width - (PNGWIDTH * 2) + 82,
				height - (PNGWIDTH * 2),
				this);
			bufferGraphics.drawImage(
				baseMiddleRight,
				width - PNGWIDTH + 70 + 82,
				PNGWIDTH,
				PNGWIDTH,
				height - (PNGWIDTH * 2),
				this);
			bufferGraphics.drawImage(
				baseBottom,
				PNGWIDTH + 70,
				height - PNGWIDTH,
				width - (PNGWIDTH * 2) + 82,
				PNGWIDTH,
				this);
			bufferGraphics.drawImage(
				baseBottomRight,
				width - PNGWIDTH + 70 + 82,
				height - PNGWIDTH,
				this);
		} else if ((!disabled) && (((DevicePage) this.getParent()).sliderActive())) {
			bufferGraphics.drawImage(
				baseTop,
				PNGWIDTH + 70,
				0,
				width + 100 - (PNGWIDTH * 2),
				PNGWIDTH,
				this);
			bufferGraphics.drawImage(
				baseMiddle,
				PNGWIDTH + 70,
				PNGWIDTH,
				width - (PNGWIDTH * 2) + 100,
				height - (PNGWIDTH * 2),
				this);
			bufferGraphics.drawImage(
				baseBottom,
				PNGWIDTH + 70,
				height - PNGWIDTH,
				width - (PNGWIDTH * 2) + 100,
				PNGWIDTH,
				this);
		} else {
			bufferGraphics.drawImage(
				baseTop,
				PNGWIDTH + 70,
				0,
				width + 44 - (PNGWIDTH * 2),
				PNGWIDTH,
				this);
			bufferGraphics.drawImage(baseTopRight, width - PNGWIDTH + 70 + 44, 0, this);
			bufferGraphics.drawImage(
				baseMiddle,
				PNGWIDTH + 70,
				PNGWIDTH,
				width - (PNGWIDTH * 2) + 44,
				height - (PNGWIDTH * 2),
				this);
			bufferGraphics.drawImage(
				baseMiddleRight,
				width - PNGWIDTH + 70 + 44,
				PNGWIDTH,
				PNGWIDTH,
				height - (PNGWIDTH * 2),
				this);
			bufferGraphics.drawImage(
				baseBottom,
				PNGWIDTH + 70,
				height - PNGWIDTH,
				width - (PNGWIDTH * 2) + 44,
				PNGWIDTH,
				this);
			bufferGraphics.drawImage(
				baseBottomRight,
				width - PNGWIDTH + 70 + 44,
				height - PNGWIDTH,
				this);
		}
		g2d.setComposite(makeComposite((float) 1));
		/**/
		graphics.setFont(new java.awt.Font("helvetica", java.awt.Font.BOLD, 14));
		graphics.setColor(new Color(255, 255, 255));
		graphics.drawString(this.getName(), 75, 26);
		if ((((Key) keys.get(0)).getState().getExtra().equals(""))
			|| (((Key) keys.get(0)).getState().getExtra().equals("0"))
			|| ((value == 0) && (active))) {
			graphics.drawString("(" + extra + ")", 75, 46);
		} else {
			if (active) {
				graphics.drawString("(" + value + "%)", 75, 46);
			} else {
				graphics.drawString("(" + ((Key) keys.get(0)).getState().getExtra() + "%)", 75, 46);
			}
		}
		if (!((DevicePage) this.getParent()).sliderActive()) {
			if (tempInt > 80) {
				graphics.drawImage(rampFull, 160, 20, this);
			} else if (tempInt > 60) {
				graphics.drawImage(ramp80, 160, 20, this);
			} else if (tempInt > 40) {
				graphics.drawImage(ramp60, 160, 20, this);
			} else if (tempInt > 20) {
				graphics.drawImage(ramp40, 160, 20, this);
			} else if (tempInt > 0) {
				graphics.drawImage(ramp20, 160, 20, this);
			} else {
				graphics.drawImage(rampEmpty, 160, 20, this);
			}
		}
		if (disabled) {
			g2d.setComposite(makeComposite((float) 1));
			g2d.setComposite(makeComposite((float) 0.5));
			g2d.setColor(new Color(82, 104, 141));
			g2d.fillRect(70, 0, this.getWidth() - 70, this.getHeight());
		}
		/*
		
		graphics.setFont(new java.awt.Font("helvetica", java.awt.Font.BOLD, 14));
		graphics.setColor(new Color(255, 255, 255));
		graphics.drawString(this.getName(), 75, 26);
		if (((Key) keys.get(0)).getState().getCommand().equals("")) {
		graphics.drawString("(" + extra + ")", 75, 46);
		} else {
		graphics.drawString("(" + ((Key) keys.get(0)).getState().getCommand() + ")", 75, 46);
		}*/
	}
	public void paint(Graphics g) {
		//    checks the buffersize with the current panelsize
		//    or initialises the image with the first paint
		resetBuffer();
		if (bufferGraphics != null) {
			if (this.getParent() != null) {
				//this clears the offscreen image, not the onscreen one
				Graphics2D g2d = (Graphics2D) bufferGraphics;
				g2d.setComposite(makeComposite((float) 1));
				if ((!disabled) && (!((DevicePage) this.getParent()).sliderActive())) {
					bufferGraphics.clearRect(0, 0, bufferWidth, bufferHeight);
				} else if ((!disabled) && (((DevicePage) this.getParent()).sliderActive())) {
					bufferGraphics.clearRect(0, 0, bufferWidth - 54, bufferHeight);
				} else {
					bufferGraphics.clearRect(0, 0, bufferWidth - 56, bufferHeight);
				}
				//calls the paintbuffer method with 
				//the offscreen graphics as a param
				bufferGraphics.setColor(new java.awt.Color(82, 104, 141));
				bufferGraphics.fillRect(0, 0, this.getWidth(), height);
				g2d.setComposite(makeComposite((float) 0.4));
				bufferGraphics.drawImage(baseTopLeft, 0, 0, this);
				bufferGraphics.drawImage(
					baseTop,
					PNGWIDTH,
					0,
					width - (PNGWIDTH * 2),
					PNGWIDTH,
					this);
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
				bufferGraphics.drawImage(
					baseBottomRight,
					width - PNGWIDTH,
					height - PNGWIDTH,
					this);
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
				if (disabled) {
					g2d.setComposite(makeComposite((float) 1));
					g2d.setComposite(makeComposite((float) 0.5));
					g2d.setColor(new Color(82, 104, 141));
					g2d.fillRect(0, 0, this.getWidth(), this.getHeight());
				}
				paintBuffer(bufferGraphics);
				//we finaly paint the offscreen image onto the onscreen image
				g.drawImage(bufferImage, 0, 0, this);
			}
		}
	}
	private void resetBuffer() {
		try {
			// always keep track of the image size
			if ((!disabled) && (!((DevicePage) this.getParent()).sliderActive())) {
				bufferWidth = getSize().width;
			} else if ((!disabled) && (((DevicePage) this.getParent()).sliderActive())) {
				bufferWidth = getSize().width - 54;
			} else {
				bufferWidth = getSize().width - 56;
			}
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
	public void setActive(boolean inActive) {
		active = inActive;
		try {
			value = Integer.parseInt(((Key) keys.get(0)).getState().getExtra());
		} catch (NumberFormatException e) {
			value = 0;
		}
	}
	public void doAction() {
		if (!disabled) {
			buttonClicked();
		}
	}
	public void buttonClicked() {
		if (!disabled) {
			((Page) getParent()).setSelected(this);
			if (value < 100) {
				value = 100;
			} else {
				value = 0;
			}
			if (((DevicePage) this.getParent()).sliderActive()) {
				((DevicePage) this.getParent()).setSliderLevel(value);
			}
			serverHandle.sendToServer(createMessage());
			repaint();
		}
	}
	public void rampClicked() {
		if (!disabled) {
			if (!((DevicePage) this.getParent()).sliderActive()) {
				((Page) getParent()).setSelected(this);
				((DevicePage) this.getParent()).addSlider();
			}
		}
	}
	public Command createMessage() {
		Command newCommand = new Command();
		newCommand.key = ((Key) keys.get(0)).getKey();
		if (value > 0) {
			newCommand.setCommand(extra2);
			((Key) keys.get(0)).getState().setCommand(extra2);
			newCommand.setExtraInfo("" + value);
			((Key) keys.get(0)).getState().setExtra("" + value);
		} else {
			newCommand.setCommand(extra);
			((Key) keys.get(0)).getState().setCommand(extra);
			newCommand.setExtraInfo("" + value);
			((Key) keys.get(0)).getState().setExtra("" + value);
		}
		return newCommand;
	}
	public void setIcons(String inString) {
		icon1 = "lib/icons/" + inString.substring(0, inString.indexOf(","));
		icon2 = "lib/icons/" + inString.substring(inString.indexOf(",") + 1);
		iconImg1 =
			imageLoader.getImage(icon1).getScaledInstance(
				width - 18,
				height - 18,
				Image.SCALE_FAST);
		iconImg2 =
			imageLoader.getImage(icon2).getScaledInstance(
				width - 18,
				height - 18,
				Image.SCALE_FAST);
		MediaTracker media = new MediaTracker(this);
		media.addImage(iconImg1, 0);
		media.addImage(iconImg2, 1);
		try {
			media.waitForID(0);
			media.waitForID(1);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	public int getValue() {
		try {
			int tempValue = Integer.parseInt(((Key) keys.get(0)).getState().getExtra());
			return tempValue;
		} catch (NumberFormatException e) {
			return 0;
		}
	}
	public void setValue(int inValue) {
		value = inValue;
		repaint();
	}
	public void setExtras(String inString) {
		extra = inString.substring(0, inString.indexOf(","));
		extra2 = inString.substring(inString.indexOf(",") + 1);
	}
	public void setInteractive(String inString) {
		interactive = inString;
	}
	public boolean getInteractive() {
		return interactive.equals("true");
	}
	public void update() {
		if (active) {
			try {
				value = Integer.parseInt(((Key) keys.get(0)).getState().getExtra());
			} catch (NumberFormatException e) {
				value = 0;
			}
			((DevicePage) this.getParent()).setSliderLevel(value);
		}
		super.update();
	}
}
