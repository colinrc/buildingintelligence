/*
 * Created on 30/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.GUI;

import au.com.BI.Command.Command;
import au.com.BI.Util.ImageLoader;

/**
 * @author David
 *
 * 
 * 
 */
public abstract class BIControlButton extends BIButton{
	/**
	 * @param inImageLoader
	 */
	public BIControlButton(ImageLoader inImageLoader) {
		super(inImageLoader);
		// TODO Auto-generated constructor stub
	}
	/* (non-Javadoc)
	 * @see au.com.BI.GUI.BIButton#createMessage()
	 */
	public abstract Command createMessage();
	public void doAction(){
		if(!disabled){
			((Page)getParent()).setSelected(this);
			serverHandle.sendToServer(createMessage());
			repaint();
		}
	}
}
