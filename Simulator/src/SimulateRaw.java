import java.util.*;
import java.io.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

import java.net.*;

public class SimulateRaw extends SimulateDevice {
   

   public String groupTypeStr = "Raw";
   
   /////////////////////////////////////////////////////////////////
   // The main procedure

   public SimulateRaw (Helper helper, GUI gui) {
	   super (helper,gui);
	   this.setName("RAW Simulator");
	   this.setPort(5003);
   }
	
   public String getDeviceName() {
	   return "Raw";
   }
   

	public void parseString (String in) {
		gui.appendToChatBox ("IN.Raw",in,"\n");
		String theKey = in.trim();
		Iterator eachCon = this.controls.iterator();
		while (eachCon.hasNext()) {
			ControlType control = (ControlType)eachCon.next();
			if (control.getOnString().equals(theKey))
				gui.changeIcon(control,true);
			if (control.getOffString().equals(theKey))
				gui.changeIcon(control,false);
		}
	}
	
	public String buildSliderString (ControlType control,int val) {
		String toSend = control.getOnString();
		toSend += String.valueOf(val) + "\n";
		return toSend;
	}
	
	public String buildOnString (ControlType control) {
		return control.getOnString() + "\n";
	}

	public String buildOffString (ControlType control) {
		return control.getOffString() + "\n";
	}
}

