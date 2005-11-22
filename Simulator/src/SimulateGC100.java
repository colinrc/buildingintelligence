import java.util.*;
import java.io.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

import java.net.*;

public class SimulateGC100 extends SimulateDevice {
   
   public String groupTypeStr = "Comfort";
   
   /////////////////////////////////////////////////////////////////
   // The main procedure

   public SimulateGC100 (Helper helper, GUI gui) {
	   super (helper,gui);
	   this.setName("GC100 Simulator");
	   this.setPort(5005);
   }
   	   
	
	public void doStartup () {
	}
 
	   public String getDeviceName() {
		   return "GC100";
	   }

		
	public void parseString (String rawIn) {
		boolean commandFound = false;
		if (rawIn.length() < 2) return;
		if (rawIn.startsWith("getversion")){
			this.sendString ("version,1,2.0.7.071503-1-06\n");
			commandFound = true;
		}
		if (!commandFound && rawIn.startsWith("sendir")){
			commandFound = true;
			String bits [] = rawIn.split(",");
			String outStr = "completeir," + bits[1]+"," + bits[2];
			gui.appendToChatBox ("OUT.GC100",outStr,"\n");
			this.sendString (outStr+"\n");
			
			commandFound = true;
		}
	}
	
	public String buildSliderString (ControlType control,int val) {
		return "";
	}
	
	public String buildOnString (ControlType control) {
		String toSend = "";
		return toSend;
	}

	
	public String buildOffString (ControlType control) {
		String toSend = "";
		return toSend;
	}

}
