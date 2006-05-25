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

import au.com.BI.Util.ImageLoader;


/**
 * @author David
 *
 * 
 * 
 */
public class SimulatorEMan extends Component {
	private Image offScreenImage;
	private ImageLoader imageLoader;
	private int width;
	private int height;
	private int x;
	private int y;
	private String status = "off";
	private SimulatorControls controls;
	/**
	 * 
	 */
	public SimulatorEMan(ImageLoader inImageLoader, SimulatorControls controls) {
		super();
		this.controls = controls;
		this.imageLoader = inImageLoader;
	}
	public void setStatus(String inStatus){
		status = inStatus;
	}
	public void paint(Graphics g){
				super.paint(g);
		if (status.equals("on")) {
			g.drawImage(imageLoader.getImage("images/elife_active/elife-man-white"), 0, 0, this);
		}
	}
}

