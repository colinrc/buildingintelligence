/*
 * Created on 25/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.simulator;
import java.awt.Component;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.event.MouseMotionListener;
import au.com.BI.Util.ImageLoader;
/**
 * @author David
 *
 * 
 * 
 */
public class SimulatorEncoder extends Component {
	private Image offScreenImage;
	private ImageLoader imageLoader;
	private int width;
	private int height;
	private int x;
	private int y;
	private int lastValue;
	private String buttonStatus = "off";
	private String wheelStatus = "off";
	private SimulatorControls controls;
	private String innerGlow = "images/elife_active/wheel-inner-glow";
	private String outerGlow = "images/elife_active/wheel-outer-glow";
	/**
	 * 
	 */
	public SimulatorEncoder(ImageLoader inImageLoader, SimulatorControls controls) {
		super();
		this.controls = controls;
		this.imageLoader = inImageLoader;
		this.addMouseListener(new MouseAdapter() {
			public void mouseClicked(MouseEvent e) {
				sendMessage("Click");
			}
		});
		this.addMouseMotionListener(new MouseMotionListener() {
			public void mouseDragged(MouseEvent e) {
				rotoryChange(e);
			}
			public void mouseMoved(MouseEvent e) {
			}
		});
	}
	public void rotoryChange(MouseEvent e) {
		int radius = getSize().width / 2;
		int maxValue = 100;
		int minValue = 0;
		int y = e.getY();
		int x = e.getX();
		double th = Math.atan((1.0 * y - radius) / (x - radius));
		int value = ((int) (th / (2 * Math.PI) * (maxValue - minValue)));
		int newValue;
		if (x < radius){
			newValue = value + maxValue / 2;
		}
		else if (y < radius){
			newValue = value + maxValue;
		}
		else{
			newValue = value;
		}
		int sendValue = newValue - lastValue;
		lastValue = newValue;
		if((sendValue >0)&&(sendValue <5)){
			sendMessage("Moved: +" + sendValue);
		} else if((sendValue >-5)&&(sendValue <0)){
			sendMessage("Moved: " + sendValue);
		}
		 
	}
	public void sendMessage(String suffix) {
		controls.outgoingSerial("RotEnc" + suffix);
	}
	public void setStatus(String inStatus) {
		if (inStatus.equals("wheelOn")) {
			wheelStatus = "on";
		} else if (inStatus.equals("wheelOff")) {
			wheelStatus = "off";
		} else if (inStatus.equals("wheelButtonOn")) {
			buttonStatus = "on";
		} else if (inStatus.equals("wheelButtonOff")) {
			buttonStatus = "off";
		}
	}
	public void paint(Graphics g) {
		super.paint(g);
		if (buttonStatus.equals("on")) {
			g.drawImage(imageLoader.getImage(innerGlow), (226 - 98) / 2, (226 - 92) / 2, this);
		}
		if (wheelStatus.equals("on")) {
			g.drawImage(imageLoader.getImage(outerGlow), 0, 0, this);
		}
	}
}