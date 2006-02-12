package au.com.BI.simulator.sims;


import java.util.*;

import static au.com.BI.simulator.conf.Control.*;
import au.com.BI.simulator.conf.Control;
import au.com.BI.simulator.gui.GUIPanel;
import au.com.BI.simulator.gui.GUI;


public class SimulateComfort extends SimulateDevice {
   
  
   /////////////////////////////////////////////////////////////////
   // The main procedure

   public SimulateComfort (Helper helper, GUI gui) {
	   super (helper,gui);
	   this.setName("Comfort Simulator");
	   this.setPort(5002);
		simType = SimTypes.COMFORT;
   }
   	   
	
	public void doStartup () {
		this.sendString(" LU01\n");
	}
 
	   public String getDeviceName() {
		   return "Comfort";
	   }
	   /*
	   public void sendString (String toSend) {
           gui.appendToChatBox("OUT." + getName()+ "." + toSend);
           super.sendString(toSend);
	   }
	   */
		public String buildCustomString (String actionCommand){
			return "\03" + actionCommand + "\n";
		}
		
	public void parseString (String rawIn) {
		if (rawIn.length() < 2) return;
		String in = rawIn.substring(1);
		boolean commandFound = false;
		gui.appendToChatBox ("IN.Comfort",in,"\n");
		if (in.charAt(1) == '?') {
			if (in.charAt(0) == 'I') {
				String theKey = in.substring(2);
				this.sendString (" I?"+theKey+"00\n");
			}
			if (in.charAt(0) == 'a') {
				this.sendString (" AL00\n");
			}
			if (in.charAt(0) == 'C') {
				String theKey = in.substring(2);
				this.sendString (" C?"+theKey+"00\n");
			}
			if (in.charAt(0) == 'M') {
				this.sendString (" M?0001\n");
			}
			commandFound = true;
		}
		if (!commandFound && in.startsWith("DA")) {
			String actionCode = in.substring(2,4);
			if (actionCode.endsWith("6E")) {
				this.sendString(" RA00\n" );
			}
			commandFound = true;
		}
		if (!commandFound && in.startsWith("LI")) {
			this.sendString(" LU01\n");
			commandFound = true;
		}
		if (!commandFound && in.startsWith("I!") || in.startsWith("O!")) {
			String theKey = in.substring(2,4);
			String theCode = in.substring(4,6);
			Iterator eachCon = this.controls.iterator();
			while (eachCon.hasNext()) {
				GUIPanel control = (GUIPanel)eachCon.next();
				if (control.getKey().equals(theKey)) {
					if (theCode.equals("00"))
						gui.changeIcon(control,false);
					else
						gui.changeIcon(control,true);						
				}
			}
		}
	}
	
	public String buildSliderString (Control control,int val) {
		return "";
	}
	
	public String buildOnString (Control control) {
		String toSend = "";
		if (control.getSimSubType() == SimSubTypes.INPUT){
			toSend= "\03IP"+control.getKey()+"01"+ "\n";
		}
		if (control.getSimSubType() == SimSubTypes.OUTPUT){
			toSend= "\03OP"+control.getKey()+"01"+ "\n";
		}
		return toSend;
	}

	
	public String buildOffString (Control control) {
		String toSend = "";
		if (control.getSimSubType() == SimSubTypes.INPUT){
			toSend= "\03IP"+control.getKey()+"00"+"\n";
		}
		if (control.getSimSubType() == SimSubTypes.OUTPUT){
			toSend= "\03OP"+control.getKey()+"00"+"\n";
		}	
		return toSend;
	}

}
