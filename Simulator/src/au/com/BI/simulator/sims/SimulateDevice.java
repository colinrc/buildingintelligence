package au.com.BI.simulator.sims;

import au.com.BI.simulator.conf.*;
import au.com.BI.simulator.conf.Control.SimTypes;

import java.util.*;
import java.io.*;

import java.net.*;

import au.com.BI.simulator.gui.GUIPanel;
import au.com.BI.simulator.gui.GUI;

public abstract class SimulateDevice extends Thread {
   
   public int port = 5001;
  
   public int connectionStatus = Helper.BEGIN_CONNECT;
   
   Config config;
   
   public final static String END_CHAT_SESSION =
      new Character((char)0).toString(); // Indicates the end of a session


   public StringBuffer toSend = new StringBuffer("");  
   protected Helper helper;
   public SimTypes simType = SimTypes.UNKNOWN;
   
   // TCP Components
   public ServerSocket hostServer = null;
   public Socket socket = null;

   public BufferedReader in = null;
   public PrintWriter out = null;
   
   public String groupTypeStr = "";
   public GUI gui;
   
   public Vector<GUIPanel> gUIPanels;
   public Vector<Control> controls;
     
   protected SimulationListener simListener;
   
   /////////////////////////////////////////////////////////////////
   // The main procedure
   public SimulateDevice (Helper helper, GUI gui) {
	  this.gui = gui;
	  this.helper = helper;
	  controls = new Vector<Control>();

	config = helper.getConfig();
	gUIPanels = new Vector<GUIPanel>();		
   } 
   
   public String getDeviceName() {
	   return "UNKNOWN";
   }
   
   public void newConnection (Socket socket) throws IOException {
	   out = new PrintWriter(socket.getOutputStream(), true);

       this.setConnectionStatus(Helper.CONNECTED);
       changeStatusTS(Helper.CONNECTED, true);
   }
   

	public String buildCustomString (String actionCommand,Control control){
		return actionCommand;
	}
	
	public void disconnect () {
		this.simListener.setRunning(false);
		changeStatusTS(Helper.BEGIN_CONNECT, false);
	}

	public abstract String buildOnString (Control control);
	public abstract String buildOffString (Control control);
	public abstract String buildSliderString (Control control,int val);
	
	public void changeStatusTS (int status, boolean noError){
		for (GUIPanel gUIPanel : gUIPanels) {
			gUIPanel.changeStatus(status);			
		}

		gui.changeStatusTS (status,noError);
	}
	
	public void doStartup () {

	}
	
	public void parseString (String in) {
		gui.appendToChatBox ("IN",in);
	}
 
   /////////////////////////////////////////////////////////////////
   // Add text to send-buffer
   public  void sendString(String s) {
	   if (out != null){
	         synchronized (out){
	 	  		out.print(s); out.flush();
	 	  	}
	   }
   }

   /////////////////////////////////////////////////////////////////
   // Cleanup for disconnect
   protected  void cleanUp() {
      try {
         if (hostServer != null) {
            hostServer.close();
            hostServer = null;
         }
      }
      catch (IOException e) { hostServer = null; }

      try {
         if (socket != null) {
            socket.close();
            socket = null;
         }
      }
      catch (IOException e) { socket = null; }

      try {
         if (in != null) {
            in.close();
            in = null;
         }
      }
      catch (IOException e) { in = null; }

	      if (out != null) {
	  	  	synchronized (out){
	  	  		out.close();
	  	  	}
	         out = null;
	      }


      // Make sure that the button/text field states are consistent
      // with the internal states
	  gui.setStatus (gui.statusString);
   }

public void setConnectionDetails(int connectionStatus) {
}

public int getConnectionStatus() {
	return connectionStatus;
}


public void setConnectionStatus(int connectionStatus) {
	this.connectionStatus = connectionStatus;
	this.setConnectionDetails(connectionStatus);
}


public int getPort() {
	return port;
}


public void setPort(int port) {
	this.port = port;
}

public void addControl (Control control){
	controls.add(control);
}

public void addGUIPanel (GUIPanel gUIPanel){
	gUIPanels.add(gUIPanel);
}

public Vector<GUIPanel> getGUIPanels() {
	return gUIPanels;
}

public Vector<Control> getControls() {
	return controls;
}


}
