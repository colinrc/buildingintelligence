package au.com.BI.simulator.gui;


import javax.swing.event.*;
import javax.swing.*;

import au.com.BI.simulator.sims.Helper;
import au.com.BI.simulator.sims.SimulateDevice;
import au.com.BI.simulator.sims.Simulator;


public class SliderChanged implements ChangeListener {
			String toSend = "";
			String groupCom = "";		
			String key = "";
			Helper helper;
			protected SimulateDevice sim;
			Simulator simulator;
			GUI gui;
			int groupNumber;
			protected ControlType control;

		       public void stateChanged(ChangeEvent e) {
		    	   	JSlider source = (JSlider)e.getSource();
		    	   	
		    	    if (!source.getValueIsAdjusting() && !control.isUpdatingSlider()) {
			    	    	int val = (int)source.getValue();

					gui.setLight(true,control);
					toSend = control.getSim().buildSliderString(control,val);
		             gui.appendToChatBox("OUT",control.toString() + "." + toSend,"");
		             // Send the string
		             simulator.sendString(this.control.getGroupType(),toSend);
		    	    }
		       }
			   
			SliderChanged (Helper helper, Simulator simulator, GUI gui,ControlType control) {
				this.helper = helper;
				this.simulator = simulator;
				this.gui = gui;
				this.control = control;
			}
			

			
}