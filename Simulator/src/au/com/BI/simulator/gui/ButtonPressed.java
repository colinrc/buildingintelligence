package au.com.BI.simulator.gui;


import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import au.com.BI.simulator.sims.Simulator;
import au.com.BI.simulator.sims.Helper;
import au.com.BI.simulator.conf.Control;
import static au.com.BI.simulator.conf.Control.*;

public class ButtonPressed implements ActionListener {
			String toSend = "";
			String groupCom = "";		
			String key = "";
			Helper helper;
			Simulator simulator;
			GUI gui;
			GUIPanel gUIPanel;
			Control control;
			ControlStates buttonState;

		       public void actionPerformed(ActionEvent e) {

		    	   	if (buttonState == ControlStates.CUSTOM) {
		    	   		toSend = gUIPanel.getSim().buildCustomString(e.getActionCommand(),control);
		    	   	}else {
		             if (buttonState == ControlStates.OFF) {
			             	toSend = gUIPanel.getSim().buildOffString(control);
				             if (control.isHasSlider()) {
				            	 	control.setUpdatingSlider(true);
					             	gui.setLight(false,gUIPanel);
				            	 	gUIPanel.getSlider().setValue(0);
				            	 	control.setUpdatingSlider(false);
				             }
		             } 
		             if (buttonState == ControlStates.ON) {
		            	 	gui.setLight(true,gUIPanel);	
		            	 	toSend = gUIPanel.getSim().buildOnString(control);
		             }
		    	   	}
		         simulator.sendString(this.control.getSimType(),toSend);
		         gui.appendToChatBox("OUT",control.getSimType()+ "." + toSend);
		       }
			   
			ButtonPressed (ControlStates buttonState, Helper helper, Simulator simulator, GUI gui,GUIPanel gUIPanel,Control control) {
				this.gUIPanel = gUIPanel;
				this.helper = helper;
				this.simulator = simulator;
				this.gui = gui;
				this.buttonState = buttonState;
				this.control = control;

				if (buttonState == ControlStates.ON)
					toSend = gUIPanel.getSim().buildOnString(control);
				
				if (buttonState == ControlStates.OFF)
					toSend = gUIPanel.getSim().buildOffString(control);				
			}
}