/*
 * Created on 22/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.GUI;
import java.util.Vector;

import au.com.BI.DataModel.ActiveGroup;
import au.com.BI.DataModel.BIObject;
import au.com.BI.Serial.SerialHandler;
import au.com.BI.Util.ImageHandler;
/**
 * @author David
 *
 * 
 * 
 */
public class RoomPage extends Page {
	/**
	 * 
	 */
	public RoomPage(
		ImageHandler inImageLoader,
		SerialHandler serialHandle,
		Vector PageInfo) {
		super(inImageLoader, serialHandle, PageInfo);
		initComponents();
	}
	public void initComponents() {
		int buttonCount = PageInfo.size();
		for (int index = 0; index < PageInfo.size(); index++) {
			buttons.put(index + "", createBIButton(((ActiveGroup) PageInfo.get(index))));
		}
		int min = Math.min(PageInfo.size(), 9);
		for (int Index = 0; Index < min; Index++) {
			((BIButton) buttons.get(Index + "")).setSize(66, 66);
			setButtonPosition(((BIButton) buttons.get(Index + "")), Index + 1);
			add(((BIButton) buttons.get(Index + "")));
		}
		if (((BIButton) buttons.get(0 + "")) != null) {
			((BIButton) buttons.get(0 + "")).setHighLighted(true);
		}
	}
	public BIButton createBIButton(BIObject inObject) {
		ActiveGroup inGroup = (ActiveGroup) inObject;
		BIDeviceButton newButton = new BIDeviceButton(imageLoader, inGroup);
		newButton.setIcons(inGroup.getIcons());
		return newButton;
	}
}
