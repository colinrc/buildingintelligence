/*
 * Created on 23/05/2006
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

import au.com.BI.Util.ImageLoader;
/**
 * @author David
 *
 * 
 * 
 */
public class SimulatorButton extends Component {
	/**
	 * 
	 */
	private Image offScreenImage;
	private String command;
	private String buttonHalo1 = "images/elife_active/button-halo-green";
	private String buttonHalo2 = "images/elife_active/button-halo-yellow";
	private ImageLoader imageLoader;
	private int width;
	private int height;
	private int x;
	private int y;
	private String status = "off";
	private SimulatorControls controls;
	public SimulatorButton(ImageLoader inImageLoader, String command, SimulatorControls controls) {
		super();
		this.controls = controls;
		this.command = command;
		this.imageLoader = inImageLoader;
		width = 39;
		height = 83;
		x = 50;
		y = 3;
		this.addMouseListener(new MouseAdapter() {
			public void mousePressed(MouseEvent e){
				sendMessage("Down");
			}
			public void mouseReleased(MouseEvent e){
				sendMessage("Up");
			}
		});
	}
	public void sendMessage(String suffix){
		controls.outgoingSerial(command+suffix);
	}
	public void setStatus(String inStatus){
		status = inStatus;
	}
	public void paint(Graphics g){
				super.paint(g);
		if (status.equals("on")) {
			g.drawImage(imageLoader.getImage(buttonHalo1), x, y, width, height, this);
		} else if(status.equals("yellow")){
			g.drawImage(imageLoader.getImage(buttonHalo2), x, y, width, height, this);
		}
	}
}
