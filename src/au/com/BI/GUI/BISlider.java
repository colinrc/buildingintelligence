/*
 * Created on 26/05/2006
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
import au.com.BI.Util.ImageLoader;
/**
 * @author David
 *
 * 
 * 
 */
public class BISlider extends Component {
	private int height;
	private int width;
	private int value;
	private int bufferWidth;
	private int bufferHeight;
	private Image bufferImage;
	private Graphics bufferGraphics;
	private String FULL = "images/levels/box-full";
	private String EMPTY = "images/levels/box-empty";
	private Image full;
	private Image empty;
	private ImageLoader imageHandle;
	private BISliderButton sliderButton;
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
	protected int PNGWIDTH = 9;
	public BISlider(ImageLoader imageHandle, BISliderButton sliderButton) {
		super();
		height = 240;
		width = 38;
		this.sliderButton = sliderButton;
		value = sliderButton.getValue();
		this.imageHandle = imageHandle;
		full = imageHandle.getImage(FULL);
		empty = imageHandle.getImage(EMPTY);
		baseTopLeft = imageHandle.getImage("images/base/button-base_01");
		baseTop = imageHandle.getImage("images/base/button-base_02");
		baseTopRight = imageHandle.getImage("images/base/button-base_03");
		baseMiddleLeft = imageHandle.getImage("images/base/button-base_04");
		baseMiddle = imageHandle.getImage("images/base/button-base_05");
		baseMiddleRight = imageHandle.getImage("images/base/button-base_06");
		baseBottomLeft = imageHandle.getImage("images/base/button-base_07");
		baseBottom = imageHandle.getImage("images/base/button-base_08");
		baseBottomRight = imageHandle.getImage("images/base/button-base_09");
		// TODO Auto-generated constructor stub
	}
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
		Graphics2D g2d = (Graphics2D) g;
		g2d.setComposite(makeComposite((float) 1));
		g.setColor(new java.awt.Color(82, 104, 141));
		g.fillRect(0, 0, width, height);
		g2d.setComposite(makeComposite((float) 0.4));
		
		bufferGraphics.drawImage(baseTopRight, width - PNGWIDTH-4, 10, this);
		bufferGraphics.drawImage(
			baseMiddleLeft,
			0,
			PNGWIDTH + 10,
			PNGWIDTH,
			height - (PNGWIDTH * 2) - 22,
			this);
		bufferGraphics.drawImage(
			baseMiddle,
			PNGWIDTH,
			PNGWIDTH + 10,
			width - (PNGWIDTH * 2)-4,
			height - (PNGWIDTH * 2) - 22,
			this);
		bufferGraphics.drawImage(
			baseMiddleRight,
			width - PNGWIDTH-4,
			PNGWIDTH + 10,
			PNGWIDTH,
			height - (PNGWIDTH * 2) - 22,
			this);
		bufferGraphics.drawImage(baseBottomRight, width - PNGWIDTH-4, height - PNGWIDTH - 12, this);
		
		if(((DevicePage)this.getParent()).getButtonPosition() == 2){
			g.drawImage(baseTopLeft, 0, 10, this);
			bufferGraphics.drawImage(baseTop, PNGWIDTH, 10, width - (PNGWIDTH * 2)-4, PNGWIDTH, this);
			bufferGraphics.drawImage(
						baseBottom,
						0,
						height - PNGWIDTH - 12,
						width - PNGWIDTH-4,
						PNGWIDTH,
						this);
		} else if(((DevicePage)this.getParent()).getButtonPosition() == 0){
			bufferGraphics.drawImage(baseBottomLeft, 0, height - PNGWIDTH - 12, this);
			bufferGraphics.drawImage(baseTop, 0, 10, width - (PNGWIDTH)-4, PNGWIDTH, this);
			bufferGraphics.drawImage(
						baseBottom,
						PNGWIDTH,
						height - PNGWIDTH - 12,
						width - (PNGWIDTH * 2)-4,
						PNGWIDTH,
						this);
		} else{
			bufferGraphics.drawImage(baseBottomLeft, 0, height - PNGWIDTH - 12, this);
			g.drawImage(baseTopLeft, 0, 10, this);
			bufferGraphics.drawImage(baseTop, PNGWIDTH, 10, width - (PNGWIDTH * 2)-4, PNGWIDTH, this);
			bufferGraphics.drawImage(
						baseBottom,
						PNGWIDTH,
						height - PNGWIDTH - 12,
						width - (PNGWIDTH * 2)-4,
						PNGWIDTH,
						this);
		}
		g2d.setComposite(makeComposite((float) 1));
		if (value >= 90) {
			g.drawImage(full, 3, 17, this);
		} else {
			g.drawImage(empty, 3, 17, this);
		}
		if (value > 80) {
			g.drawImage(full, 3, 38, this);
		} else {
			g.drawImage(empty, 3, 38, this);
		}
		if (value > 70) {
			g.drawImage(full, 3, 59, this);
		} else {
			g.drawImage(empty, 3, 59, this);
		}
		if (value > 60) {
			g.drawImage(full, 3, 80, this);
		} else {
			g.drawImage(empty, 3, 80, this);
		}
		if (value > 50) {
			g.drawImage(full, 3, 101, this);
		} else {
			g.drawImage(empty, 3, 101, this);
		}
		if (value > 40) {
			g.drawImage(full, 3, 122, this);
		} else {
			g.drawImage(empty, 3, 122, this);
		}
		if (value > 30) {
			g.drawImage(full, 3, 143, this);
		} else {
			g.drawImage(empty, 3, 143, this);
		}
		if (value > 20) {
			g.drawImage(full, 3, 164, this);
		} else {
			g.drawImage(empty, 3, 164, this);
		}
		if (value > 10) {
			g.drawImage(full, 3, 185, this);
		} else {
			g.drawImage(empty, 3, 185, this);
		}
		if (value > 0) {
			g.drawImage(full, 3, 206, this);
		} else {
			g.drawImage(empty, 3, 206, this);
		}
	}
	private void resetBuffer() {
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
	}
	public void repaint() {
		paint(this.getGraphics());
	}
	public AlphaComposite makeComposite(float alpha) {
		int type = AlphaComposite.SRC_OVER;
		return (AlphaComposite.getInstance(type, alpha));
	}
	/**
	 * 
	 */
	public void changeValue(int changeValue) {
		if (changeValue > 0) {
			if (value < 100) {
				if (value + changeValue < 100) {
					value = value + changeValue;
				} else {
					value = 100;
				}
			}
		} else if (changeValue < 0) {
			if (value > 0) {
				if (value + changeValue > 0) {
					value = value + changeValue;
				} else {
					value = 0;
				}
			}
		}
		repaint();
	}
	public void setValue(int inValue) {
		value = inValue;
		repaint();
	}
	public int getValue() {
		return value;
	}
}
