package au.com.BI.simulator.sims;


import java.awt.*;

import au.com.BI.simulator.gui.GUIPanel;
import au.com.BI.simulator.gui.GUI;
import au.com.BI.simulator.conf.Control;

public class SimulateUnknown extends SimulateDevice {
   
   public static int port = 5000;
  

   public GUIPanel groupType;
   public String groupTypeStr = "";
   
   /////////////////////////////////////////////////////////////////
   // The main procedure

   public SimulateUnknown (Helper helper, GUI gui) {
	   super (helper,gui);
	   this.setName("Text box handler");
   }  
	
	public void parseString (String in) {
		gui.appendToChatBox ("IN",in,"\n");
	}

	   /////////////////////////////////////////////////////////////////
	   // Checks the current state and sets the enables/disables
	   // accordingly
	   public void setConnectionDetails(int connectionStatus) {
		   if (gui == null) return;
	      switch (connectionStatus) {
	      case Helper.DISCONNECTED:
			  gui.setAllStatus (true,false,true,false,Color.red);
			  gui.setChatLine("");
	         break;

	      case Helper.DISCONNECTING:
			  gui.setAllStatus (false,false,false,false,Color.orange);
	         break;

	      case Helper.CONNECTED:
			 gui.setAllStatus (false,true,false,true,Color.green);
	         break;

	      case Helper.BEGIN_CONNECT:
			  gui.setAllStatus (false,false,false,false,Color.orange);
	         break;
	      }
	   }
	   
		public String buildSliderString (Control control,int val) {
			return "";
		}
		
		public String buildOnString (Control control)
		{
			return "";
		}
		
		public String buildOffString (Control control){
			return "";
		}
}
