package au.com.BI.simulator.gui;


import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import au.com.BI.simulator.Simulator;
import au.com.BI.simulator.sims.Helper;


public class ButtonPressed implements ActionListener {
			String toSend = "";
			String groupCom = "";		
			String key = "";
			Helper helper;
			Simulator simulator;
			GUI gui;
			ControlType control;
			int buttonNumber;

		       public void actionPerformed(ActionEvent e) {

		    	   	if (buttonNumber == ControlType.CUSTOM) {
		    	   		toSend = control.getSim().buildCustomString(e.getActionCommand());
		    	   	}else {
		             if (buttonNumber == ControlType.OFF) {
		             	gui.setLight(false,control);
		             	toSend = control.getSim().buildOffString(control);
			             if (control.hasSlider) {
			            	 	control.setUpdatingSlider(true);
			            	 	control.getSlider().setValue(0);
			            	 	control.setUpdatingSlider(false);
			             }
		             } else {
		            	 	gui.setLight(true,control);
		             	toSend = control.getSim().buildOnString(control);
		             }
		    	   	}
		         simulator.sendString(this.control.getGroupType(),toSend);
		         gui.appendToChatBox("OUT",control.toString()+ "." + toSend,"");
		       }
			   
			ButtonPressed (int buttonNumber, Helper helper, Simulator simulator, GUI gui,ControlType control) {
				this.control = control;
				this.helper = helper;
				this.simulator = simulator;
				this.gui = gui;
				this.buttonNumber = buttonNumber;

				if (buttonNumber == ControlType.ON)
					toSend = control.getSim().buildOnString(control);
				else
					toSend = control.getSim().buildOffString(control);
				
			}
}