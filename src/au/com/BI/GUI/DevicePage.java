/*
 * Created on 30/05/2006
 *
 * 
 * Copyright Building Intelligence 2006
 */
package au.com.BI.GUI;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.util.Vector;

import au.com.BI.Connection.ServerHandler;
import au.com.BI.DataModel.ActiveControl;
import au.com.BI.DataModel.ActiveGroup;
import au.com.BI.DataModel.BIObject;
import au.com.BI.Serial.SerialHandler;
import au.com.BI.Util.ImageLoader;
/**
 * @author David
 *
 * 
 * 
 */
public class DevicePage extends Page implements Runnable{
	private ActiveGroup group;
	private BISlider slider = null;
	private boolean interactive = false;
	private Thread myThread;
	private int tempValue;
	private int lastValue;
	private boolean wheelButtonOn = false;
	public void run(){
		try {
			while (true) {
				if(lastValue != tempValue){
					slider.setValue(tempValue);
					((BISliderButton) buttons.get(highlightedButton + "")).setValue(tempValue);
					serverHandle.sendToServer(((BISliderButton) buttons.get(highlightedButton + "")).createMessage());
					lastValue = tempValue;
				}				
				myThread.sleep(500);
			}
		} catch (Exception e) {
			//e.printStackTrace();
		}
	}
	public void stop(){
		myThread = null;
	}
	/**
	 * @param inImageLoader
	 * @param inServerHandler
	 */
	public DevicePage(
		ImageLoader inImageLoader,
		ServerHandler inServerHandler,SerialHandler serialHandle,
		Vector PageInfo,
		ActiveGroup inGroup) {
		super(inImageLoader, inServerHandler,serialHandle, PageInfo);
		int rows = PageInfo.size() / 3;
		if ((PageInfo.size() % 3) != 0) {
			rows = rows + 1;
		}
		pagePositions = rows;
		currentPosition = 0;
		group = inGroup;
		initComponents();
		setButtonsOn();
		// TODO Auto-generated constructor stub
	}
	public void setButtonsOn(){
		serialHandle.sendSerialMessage("B1Blue");
		serialHandle.sendSerialMessage("B2Blue");
		serialHandle.sendSerialMessage("B3Blue");
		serialHandle.sendSerialMessage("B4Blue");
		serialHandle.sendSerialMessage("wheelOn");
		serialHandle.sendSerialMessage("wheelButtonOff");
		wheelButtonOn = false;
	}
	public void setWheelButtonOn(){
		serialHandle.sendSerialMessage("wheelButtonYellow");
		wheelButtonOn = true;
	}
	public void setButtonsOff(){
		serialHandle.sendSerialMessage("B1Yellow");
		serialHandle.sendSerialMessage("B2Off");
		serialHandle.sendSerialMessage("B3Off");
		serialHandle.sendSerialMessage("B4Yellow");
		serialHandle.sendSerialMessage("wheelOn");
		serialHandle.sendSerialMessage("wheelButtonOff");
		wheelButtonOn = false;
	}
	public void initComponents() {
		int buttonCount = PageInfo.size();
		for (int index = 0; index < PageInfo.size(); index++) {
			buttons.put(index + "", createBIButton(((ActiveControl) PageInfo.get(index))));
			((BIButton) buttons.get(index + "")).setSize(240, 66);
		}
		int min = Math.min(PageInfo.size(), 3);
		for (int Index = 0; Index < min; Index++) {
			setButtonPosition(((BIButton) buttons.get(Index + "")), ((Index * 3) + 1));
			add(((BIButton) buttons.get(Index + "")));
		}
		((BIButton) buttons.get(0 + "")).setHighLighted(true);
	}
	public BIButton createBIButton(BIObject inObject) {
		ActiveControl inControl = (ActiveControl) inObject;
		BIButton newButton;
		if (inControl.getType().equals("simple")) {
			newButton = new BISimpleButton(imageLoader);
			BISimpleButton simpleButton = (BISimpleButton) newButton;
			Vector newVector = new Vector();
			newVector.add(inControl.getKey());
			simpleButton.setCommand(inControl.getCommand());
			simpleButton.setExtra(inControl.getExtra());
			simpleButton.setExtra2(inControl.getExtra2());
			simpleButton.setExtra3(inControl.getExtra3());
			simpleButton.setExtra4(inControl.getExtra4());
			simpleButton.setExtra5(inControl.getExtra5());
			simpleButton.setIcon(group.getIcons());
			serverHandle.registerComponent(simpleButton, newVector);
		} else if (inControl.getType().equals("toggle")) {
			newButton = new BIToggleButton(imageLoader);
			BIToggleButton toggleButton = (BIToggleButton) newButton;
			Vector newVector = new Vector();
			newVector.add(inControl.getKey());
			toggleButton.setName(inControl.getName());
			toggleButton.setCommand(inControl.getCommand());
			toggleButton.setExtras(inControl.getExtras());
			toggleButton.setIcons(group.getIcons());
			serverHandle.registerComponent(toggleButton, newVector);
		} else if (inControl.getType().equals("slider")) {
			newButton = new BISliderButton(imageLoader);
			BISliderButton sliderButton = (BISliderButton) newButton;
			Vector newVector = new Vector();
			newVector.add(inControl.getKey());
			sliderButton.setName(inControl.getName());
			sliderButton.setExtras(inControl.getExtras());
			sliderButton.setIcons(group.getIcons());
			serverHandle.registerComponent(sliderButton, newVector);
			sliderButton.setValue(sliderButton.getValue());
			sliderButton.setInteractive(inControl.getInteractive());
		} else {
			newButton = null;
		}
		return newButton;
	}
	public void navUp() {
		if (pagePositions > 0) {
			if (currentPosition != 0) {
				this.removeAll();
				
				currentPosition = currentPosition - 1;
				int vectorPosition = currentPosition * 3;
				
				int buttonCount = Math.min(PageInfo.size() - vectorPosition, 3);
				for (int Index = 0; Index < buttonCount; Index++) {
					setButtonPosition(
						((BIButton) buttons.get((Index + vectorPosition) + "")),
						((Index*3) + vectorPosition + 1));
					add(((BIButton) buttons.get("" + (Index + vectorPosition))));
				}
				repaint();
			}
		}
	}
	public void navDown() {
		if (pagePositions > 0) {
			if (currentPosition != pagePositions) {
				this.removeAll();
				
				currentPosition = currentPosition + 1;
				int vectorPosition = currentPosition * 3;
				
				int buttonCount = Math.min(PageInfo.size() - vectorPosition, 3);
				for (int Index = 0; Index < buttonCount; Index++) {
					setButtonPosition(
						((BIButton) buttons.get((Index + vectorPosition) + "")),
						((Index*3) + 1));
					add(((BIButton) buttons.get("" + (Index + vectorPosition))));
				}
				repaint();
			}
		}
	}
	public void upButton(){
		if(slider == null){
			((MainWindowBG)this.getParent()).upPage();
		}	
	}
	public void downButton(){
		if(slider == null){
			((MainWindowBG)this.getParent()).downPage();
		}
	}
	public void cancel() {
		if(slider != null){
			removeSlider();
		} else{
			((MainWindowBG)this.getParent()).goHome();
		}	
	}
	public void select() {
		if(slider != null){
			((BISliderButton) buttons.get(highlightedButton + "")).setValue(slider.getValue());
			serverHandle.sendToServer(((BISliderButton) buttons.get(highlightedButton + "")).createMessage());
			removeSlider();
		} else{
			((BIButton) buttons.get(highlightedButton + "")).doAction();
		}
	}
	public void click(){
		if(slider != null){
			((BISliderButton) buttons.get(highlightedButton + "")).setValue(slider.getValue());
			serverHandle.sendToServer(((BISliderButton) buttons.get(highlightedButton + "")).createMessage());
			removeSlider();
		}
	}
	public void addSlider(){
		if(slider == null){
			setButtonsOff();
			((BISliderButton) buttons.get(highlightedButton + "")).setActive(true);
			slider = new BISlider(imageLoader,((BISliderButton) buttons.get(highlightedButton + "")));
			slider.setBounds(194, 0, 38, 240);
			this.add(slider,0);
			interactive = ((BISliderButton) buttons.get(highlightedButton + "")).getInteractive();
			if (interactive){
				if (myThread == null) {
					myThread = new Thread(this, "ConnectionHandler");
				}
				myThread.start();
			}
			for (int index = 0; index < PageInfo.size(); index++) {
				BIButton tempButton = ((BIButton) buttons.get(index + ""));
				if(index != highlightedButton){
					tempButton.setDisabled(true);					
				} 
			}
			repaint();
		}
	}
	public int getButtonPosition(){
		return highlightedButton%3;
	}
	public void removeSlider(){
		if(slider != null){
			setButtonsOn();
			((BISliderButton) buttons.get(highlightedButton + "")).setActive(false);
			stop();
			this.remove(slider);
			slider = null;
			for (int index = 0; index < PageInfo.size(); index++) {
				BIButton tempButton = ((BIButton) buttons.get(index + ""));
				tempButton.setDisabled(false);				
			}
			repaint();
		}
	}
	public void setSliderLevel(int inValue){
		if(slider != null){
			if(!interactive){
				slider.setValue(inValue);
			} else{
				tempValue = inValue;
				lastValue = inValue;
				slider.setValue(inValue);
			}
		}
	}
	public void encChange(int value) {
		if(slider != null){
			if(!wheelButtonOn){
				setWheelButtonOn();
			}
			if(!interactive){
				slider.changeValue(value);
			} else{
				slider.changeValue(value);
				tempValue = value+tempValue;
				if(tempValue>=100){
					tempValue = 100;
				} else if(tempValue<=0){
					tempValue = 0;
				}
			}
			
		} else{
		selected = selected + value;
		if (selected > 15) {
			if (highlightedButton + 1 < PageInfo.size()) {
				if (highlightedButton + 1 >= (currentPosition * 3) + 3) {
					((BIButton) buttons.get(highlightedButton + "")).setHighLighted(false);
					highlightedButton++;
					((BIButton) buttons.get(highlightedButton + "")).setHighLighted(true);
					navDown();
				} else {
					((BIButton) buttons.get(highlightedButton + "")).setHighLighted(false);
					highlightedButton++;
					((BIButton) buttons.get(highlightedButton + "")).setHighLighted(true);
				}
			}
			selected = 0;
		} else if (selected < -15) {
			if (highlightedButton > 0) {
				if (highlightedButton - 1 < (currentPosition * 3)) {
					((BIButton) buttons.get(highlightedButton + "")).setHighLighted(false);
					highlightedButton--;
					((BIButton) buttons.get(highlightedButton + "")).setHighLighted(true);
					navUp();
				} else {
					((BIButton) buttons.get(highlightedButton + "")).setHighLighted(false);
					highlightedButton--;
					((BIButton) buttons.get(highlightedButton + "")).setHighLighted(true);
				}
			}
			selected = 0;
		}
		}
	}
	public void paintBuffer(Graphics g) {
		//in classes extended from this one, add something to paint here!
		//always remember, g is the offscreen graphic
		if(slider != null){
			g.setColor(new java.awt.Color(82, 104, 141));
			g.fillRect(0, 0, 240, 320);
			Graphics2D g2d =(Graphics2D)g;
			g2d.setComposite(makeComposite((float) 0.4));
			g2d.setColor(new Color(82, 104, 141));
			g2d.fillRect(0,0,this.getWidth()-66,this.getHeight());
		}
		super.paintBuffer(g);				
	}
	public boolean sliderActive(){
		if(slider == null){
			return false;
		} else{
			return true;
		}
	}
}
