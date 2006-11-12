package au.com.BI.simulator.sims;


import java.util.*;

import au.com.BI.simulator.gui.GUIPanel;
import au.com.BI.simulator.gui.GUI;
import au.com.BI.simulator.conf.Control;
import static au.com.BI.simulator.conf.Control.*;

public class SimulateCBUS extends SimulateDevice {

   /////////////////////////////////////////////////////////////////
   // The main procedure

   public SimulateCBUS (Helper helper, GUI gui) {
	   super (helper,gui);
	   this.setName("CBUS Simulator");
	   this.setPort(5004);
		simType = SimTypes.CBUS;
   }
   
	public void doStartup () {
		this.sendString("~~~\n");

	}
	
   public String getDeviceName() {
		   return "CBUS";
   }
   
	public String buildOnString (Control control) {
			//on
			String toSend= "0500380079"+control.getKey();
			toSend = helper.addCBUSChecksum(toSend) + "\n";
			return toSend;
	}
	
	public String buildOffString (Control control) {
		String toSend= "0500380001"+control.getKey();
		toSend = helper.addCBUSChecksum(toSend) + "\n";
		return toSend;
	}
	
	public String buildSliderString (Control control,int val) {
		String strVal = Integer.toHexString(val);
		if (strVal.length() == 1)  strVal = "0" + strVal;
		String toSend= "0500380002"+control.getKey()+strVal;
		toSend = helper.addCBUSChecksum(toSend) + "\n";
		return toSend;
	}
	
	public void parseString (String in) {
		gui.appendToChatBox ("IN.CBUS.",in);
		if (in.startsWith("~~~") || in.startsWith ("A3")) {
			synchronized (out){
				out.println("~~~\n");
			}
			return;
		}
		char lastChar = in.charAt(in.length()-1);

		synchronized (out){
			out.println(lastChar+".");
		}
		try {
			String command = in.substring(7,9);
			String theKey = "";
			theKey = in.substring(9,11);
			boolean commandFound = false;
			if (command.equals ("79")) {
				commandFound = true;
				GUIPanel control = findControl (theKey);
				gui.changeIcon(control,true);
				if (control.isHasSlider()){
					gui.changeLevel(control,254);
				}
			}
			if (command.equals("01")) {
				commandFound = true;
				GUIPanel control = findControl (theKey);
				if (control.isHasSlider()){
					gui.changeLevel(control,0);
				}
				gui.changeIcon(control,false);
			}
			if (!commandFound) {
				GUIPanel control = findControl (theKey);
				if (control != null){
					if (control.isHasSlider()) {
						String theLevel = in.substring(11,13);
						try {
							int intLevel  = Integer.parseInt(theLevel,16);
							if (intLevel == 0) intLevel = 255;
							control.setUpdatingSlider(true);
							gui.changeLevel (control,intLevel);
							control.setUpdatingSlider(false);
						} catch (NumberFormatException ex) {
							System.out.println ("CBUS string from server was malformed");
						}
					}
					gui.changeIcon(control,true);
				}
			}
		} catch (IndexOutOfBoundsException ex){}
	}
 
	public GUIPanel findControl (String theKey){
		for (GUIPanel control: gUIPanels){
			if (control.getKey().equals(theKey)) {
				return control;
			}			
		}
		return null;
	}
	
   public void setOn (String theKey){
	   
   }
   
   public void setOff (String theKey){
	   
   }
   
   public void setLevel (String theKey, int theLevel){
	   
   }
}
