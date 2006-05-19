/*
 * Created on 10/05/2006
 *
 * 
 * Copywrite Building Intelligence 2006
 */
package au.com.BI.GUI;

import java.awt.Graphics;
import java.awt.Image;

import au.com.BI.Command.Command;
import au.com.BI.DataModel.Key;
import au.com.BI.Util.ImageLoader;

/**
 * @author David
 *
 * 
 * Copyright Building Intelligence 2006
 */
public class BIToggleButton extends BIButton {
	private String command = "";
	private String extra = "";
	private String extra2 = "";
	private String icon1;
	private String icon2;
	private Image iconImg1;
	private Image iconImg2;
	/**
	 * @param inButtonLoader
	 */
	public BIToggleButton(ImageLoader inImageLoader) {
		super(inImageLoader);
		// TODO Auto-generated constructor stub
		String path;
	}
	public void run() {
		while (updateThread == Thread.currentThread()) {
			if (highlighted > 0) {
				repaint(highlighted);
				try {
					updateThread.sleep(100);
				} catch (InterruptedException e) {
					System.err.println(e.getMessage());
					e.printStackTrace();
				}
				highlighted = highlighted-20;
			} else {
				repaint(highlighted);
				stop();
			}
		}
	}
	public void paint(Graphics graphics){
		super.paint(graphics);
		if(((Key)keys.get(0)).getState().getCommand().equals(extra2)){
			graphics.drawImage(iconImg2, 9, 9, this);
		} else{
			graphics.drawImage(iconImg1, 9, 9, this);
		}
	}
	public Command createMessage() {
		Command newCommand = new Command();
		newCommand.key = ((Key)keys.get(0)).getKey();
		if(((Key)keys.get(0)).getState().getCommand().equals(extra2)){
			newCommand.setCommand(extra);
			((Key)keys.get(0)).getState().setCommand(extra);
			newCommand.setExtraInfo("0");
		} else{
			newCommand.setCommand(extra2);
			((Key)keys.get(0)).getState().setCommand(extra2);
			newCommand.setExtraInfo("100");
		}
		
		return newCommand;
	}
			
	public void setCommand(String inString) {
		command = inString;
	}
	public void setIcons(String inString){
		icon1 = inString.substring(0,inString.indexOf(","));
		icon2 = inString.substring(inString.indexOf(",")+1);
		iconImg1 = imageLoader.getImage(icon1).getScaledInstance(34,34,Image.SCALE_SMOOTH);
		iconImg2 = imageLoader.getImage(icon2).getScaledInstance(34,34,Image.SCALE_SMOOTH);
	}
	public void setExtras(String inString){
		extra = inString.substring(0,inString.indexOf(","));
		extra2 = inString.substring(inString.indexOf(",")+1);
	}
}
