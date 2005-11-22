import java.util.*;
import java.io.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

import java.net.*;

public class SimulateUnknown extends SimulateDevice {
   
   private final static String defaultPort = "5000";
   public static int port = 5000;
  

   public ControlType groupType;
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
	   
		public String buildSliderString (ControlType control,int val) {
			return "";
		}
		
		public String buildOnString (ControlType control)
		{
			return "";
		}
		
		public String buildOffString (ControlType control){
			return "";
		}
}
