/*
 * Created on 10/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
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
 * 
 */
public class BISimpleButton extends BIButton {
	private String command = "";
	private String extra = "";
	private String extra2 = "";
	private String extra3 = "";
	private String extra4 = "";
	private String extra5 = "";
	private Image iconImg;
	/**
	 * @param inButtonLoader
	 */
	public BISimpleButton(ImageLoader inImageLoader) {
		super(inImageLoader);
		command = "";
		// TODO Auto-generated constructor stub
	}
	public void run() {
		while (updateThread == Thread.currentThread()) {
			if (highlighted > 0) {
				repaint(highlighted);
				try {
					updateThread.sleep(50);
				} catch (InterruptedException e) {
					System.err.println(e.getMessage());
					e.printStackTrace();
				}
				highlighted = highlighted - 20;
			} else {
				repaint(highlighted);
				stop();
			}
		}
	}
	public Command createMessage() {
		Command newCommand = new Command();
		newCommand.key = ((Key)keys.get(0)).getKey();
		newCommand.setCommand(command); 
		newCommand.setExtraInfo(extra);
		newCommand.setExtra2Info(extra2);
		newCommand.setExtra3Info(extra3);
		newCommand.setExtra4Info(extra4);
		newCommand.setExtra5Info(extra5);
		return newCommand;
	}
	public void paint(Graphics graphics){
		super.paint(graphics);
		graphics.drawImage(iconImg, 9, 9, this);
	}
	public void setIcon(String inString){
		iconImg = imageLoader.getImage(inString).getScaledInstance(width-18,width-18,Image.SCALE_SMOOTH);
	}
	public void setCommand(String inString) {
		command = inString;
	}
	public void setExtra(String inString){
		extra = inString;
	}
	public void setExtra2(String inString){
		extra2 = inString;
	}
	public void setExtra3(String inString){
		extra3 = inString;
	}
	public void setExtra4(String inString){
		extra4 = inString;
	}
	public void setExtra5(String inString){
		extra5 = inString;
	}
}
