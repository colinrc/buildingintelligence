package au.com.BI.simulator.sims;


import java.util.*;

import au.com.BI.simulator.conf.Control.SimTypes;
import au.com.BI.simulator.conf.Control;
import au.com.BI.simulator.gui.GUIPanel;
import au.com.BI.simulator.gui.GUI;

public class SimulateRaw extends SimulateDevice {
   
   /////////////////////////////////////////////////////////////////
   // The main procedure

   public SimulateRaw (Helper helper, GUI gui) {
	   super (helper,gui);
	   this.setName("RAW Simulator");
	   this.setPort(5003);
		simType = SimTypes.RAW;
   }
	
   public String getDeviceName() {
	   return "Raw";
   }
   

	public void parseString (String in) {
		gui.appendToChatBox ("IN.Raw",in);
		String theKey = in.trim();
		for (GUIPanel control:this.gUIPanels){
			if (control.getOnString().equals(theKey))
				gui.changeIcon(control,true);
			if (control.getOffString().equals(theKey))
				gui.changeIcon(control,false);
		}
	}
	
	public String buildSliderString (Control control,int val) {
		String toSend = control.getKeyOn();
		toSend += String.valueOf(val) + "\n";
		return toSend;
	}
	
	public String buildOnString (Control control) {
		return control.getKeyOn() + "\n";
	}

	public String buildOffString (Control control) {
		return control.getKeyOff() + "\n";
	}
}

