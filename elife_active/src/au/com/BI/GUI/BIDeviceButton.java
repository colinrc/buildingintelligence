/*
 * Created on 30/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.GUI;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.MediaTracker;
import java.util.Vector;

import au.com.BI.Connection.ServerHandler;
import au.com.BI.DataModel.ActiveControl;
import au.com.BI.DataModel.ActiveGroup;
import au.com.BI.Objects.BIListener;
import au.com.BI.Util.ImageHandler;
/**
 * @author David
 *
 * 
 * 
 */
public class BIDeviceButton extends BIButton implements BIListener{
	private ActiveGroup group;
	private String icon1;
	private String icon2;
	private Image iconImg1;
	private Image iconImg2;
	/**
	 * 
	 */
	public BIDeviceButton(ImageHandler inImageLoader, ActiveGroup inGroup) {
		super(inImageLoader);
		group = inGroup;
		Vector newVector = new Vector();
		for(int index = 0;index<group.getControls().size();index++){
			newVector.add(((ActiveControl)group.getControls().get(index)).getKey());
		}
		ServerHandler.getInstance().registerComponent(this,newVector);
	}
	public void paintBuffer(Graphics graphics) {
		boolean active = false;
		for(int index = 0;index<group.getControls().size();index++){
			if(!(ServerHandler.getInstance().getState(((ActiveControl)group.getControls().get(index)).getKey()).getCommand().equals(""))&&!(ServerHandler.getInstance().getState(((ActiveControl)group.getControls().get(index)).getKey()).getCommand().equals(((ActiveControl)group.getControls().get(index)).getExtras().substring(0,((ActiveControl)group.getControls().get(index)).getExtras().lastIndexOf(","))))){
				active = true;
				break;
			}
		}
		if (active) {
			graphics.drawImage(iconImg2, 9, 9, this);
		} else {
			graphics.drawImage(iconImg1, 9, 9, this);
		}
	}
	public void doAction() {
		 ((MainWindowBG)((RoomPage) this.getParent()).getParent()).buildDevicePage(group);
	}
	public void setIcons(String inString) {
		icon1 = "lib/icons/"+inString.substring(0, inString.indexOf(","));
		icon2 = "lib/icons/"+inString.substring(inString.indexOf(",") + 1);
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
	public void finalize() throws Throwable {
			try {
				bufferImage = null;
				iconImg1 = null;
				iconImg2 = null;
				bufferGraphics = null;
			} finally {
				super.finalize();
			}
		}
}
