import java.util.*;
import java.io.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

import java.net.*;

public class SimulateM1 extends SimulateDevice {
   
   public String groupTypeStr = "M1";
   protected M1Helper m1Helper;
   /////////////////////////////////////////////////////////////////
   // The main procedure

   public SimulateM1 (Helper helper, GUI gui) {
	   super (helper,gui);
	   this.setName("M1 Simulator");
	   this.setPort(5006);
	   m1Helper = new M1Helper ();
   }
   	   
	
	public void doStartup () {
	}
 
	   public String getDeviceName() {
		   return "M1";
	   }
	   /*
	   public void sendString (String toSend) {
           gui.appendToChatBox("OUT." + getName()+ "." + toSend);
           super.sendString(toSend);
	   }
	   */
		public String buildCustomString (String actionCommand){
			return "\n";
		}
		
	public void parseString (String in) {
		boolean commandFound = false;
		gui.appendToChatBox ("IN.M1",in,"\n");
		String cmd = in.substring(2,4);

		if (!commandFound && cmd.equals ("cf") ) {
			String theKey = in.substring(4,7);
			Iterator eachCon = this.controls.iterator();
			while (eachCon.hasNext()) {
				ControlType control = (ControlType)eachCon.next();
				if (control.getKey().equals(theKey)) {
						gui.changeIcon(control,false);
				}
			}
			commandFound = true;
		}
		if (!commandFound && cmd.equals ("cn") ) {
			String theKey = in.substring(4,7);
			Iterator eachCon = this.controls.iterator();
			while (eachCon.hasNext()) {
				ControlType control = (ControlType)eachCon.next();
				if (control.getKey().equals(theKey)) {
						gui.changeIcon(control,true);
				}
			}
			commandFound = true;
		}

	}
	
	public String buildSliderString (ControlType control,int val) {
		return "";
	}
	
	public String buildOnString (ControlType control) {
		String toSend = "";
		if (control.getSubGroupType() == ControlType.M1_INPUT){
			toSend= "\03IP"+control.getKey()+"01"+ "\r\n";
		}
		if (control.getSubGroupType() == ControlType.M1_OUTPUT){
			toSend= m1Helper.buildCompleteM1String("CC"+Utility.padString(control.getKey(),3)+"100")+"\r\n";
		}
		return toSend;
	}

	
	public String buildOffString (ControlType control) {
		String toSend = "";
		if (control.getSubGroupType() == ControlType.M1_INPUT){
			toSend= m1Helper.buildCompleteM1String("CC"+Utility.padString(control.getKey(),3)+"00")+"\r\n";
		}
		if (control.getSubGroupType() == ControlType.M1_OUTPUT){
			toSend= m1Helper.buildCompleteM1String("CC"+Utility.padString(control.getKey(),3)+"000")+"\r\n";
		}	
		return toSend;
	}

}
