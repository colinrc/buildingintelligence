import java.util.*;
import java.io.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

import java.net.*;

public class SimulateCBUS extends SimulateDevice {

   public String groupTypeStr = "CBUS";
   
   /////////////////////////////////////////////////////////////////
   // The main procedure

   public SimulateCBUS (Helper helper, GUI gui) {
	   super (helper,gui);
	   this.setName("CBUS Simulator");
	   this.setPort(5004);
   }
   
	public void doStartup () {
		this.sendString("~~~\n");

	}
	
   public String getDeviceName() {
		   return "CBUS";
   }
   
	public String buildOnString (ControlType control) {
			//on
			String toSend= "0500380079"+control.getKey();
			toSend = helper.addCBUSChecksum(toSend) + "\n";
			return toSend;
	}
	
	public String buildOffString (ControlType control) {
		String toSend= "0500380001"+control.getKey();
		toSend = helper.addCBUSChecksum(toSend) + "\n";
		return toSend;
	}
	
	public String buildSliderString (ControlType control,int val) {
		String strVal = Integer.toHexString(val);
		if (strVal.length() == 1)  strVal = "0" + strVal;
		String toSend= "0500380002"+control.getKey()+strVal;
		toSend = helper.addCBUSChecksum(toSend) + "\n";
		return toSend;
	}
	
	public void parseString (String in) {
		gui.appendToChatBox ("IN.CBUS.",in,"\n");
		if (in.startsWith("~~~") || in.startsWith ("A3")) return;
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
				ControlType control = findControl (theKey);
				gui.changeIcon(control,true);
			}
			if (command.equals("01")) {
				commandFound = true;
				ControlType control = findControl (theKey);
				gui.changeIcon(control,false);
				if (control.hasSlider){
					control.setUpdatingSlider(true);
					gui.changeLevel(control,0);
					control.setUpdatingSlider(false);
				}
			}
			if (!commandFound) {
				ControlType control = findControl (theKey);
				if (control != null){
					gui.changeIcon(control,true);
					if (control.isHasSlider()) {
						String theLevel = in.substring(11,13);
						try {
							int intLevel  = Integer.parseInt(theLevel,16);
							control.setUpdatingSlider(true);
							gui.changeLevel (control,intLevel);
							control.setUpdatingSlider(false);
						} catch (NumberFormatException ex) {
							System.out.println ("CBUS string from server was malformed");
						}
					}
				}
			}
		} catch (IndexOutOfBoundsException ex){}
	}
 
	public ControlType findControl (String theKey){
		Iterator eachCon = this.controls.iterator();
		while (eachCon.hasNext()) {
			ControlType control = (ControlType)eachCon.next();
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
