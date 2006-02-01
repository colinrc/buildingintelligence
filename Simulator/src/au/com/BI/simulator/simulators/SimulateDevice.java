package au.com.BI.simulator.sims;

import au.com.BI.simulator.conf.*;
import java.util.*;
import java.io.*;

import java.net.*;

import au.com.BI.simulator.gui.ControlType;
import au.com.BI.simulator.gui.GUI;

public abstract class SimulateDevice extends Thread {
   
   public int port = 5001;
  
   public int connectionStatus = Helper.BEGIN_CONNECT;
   
   Config config;
   
   public final static String END_CHAT_SESSION =
      new Character((char)0).toString(); // Indicates the end of a session


   public StringBuffer toSend = new StringBuffer("");  
   protected Helper helper;

   // TCP Components
   public ServerSocket hostServer = null;
   public Socket socket = null;

   public BufferedReader in = null;
   public PrintWriter out = null;
   
   public String groupTypeStr = "";
   public GUI gui;
   
   public Vector controls;
   
   protected SimulationListener simListener;
   
   /////////////////////////////////////////////////////////////////
   // The main procedure
   public SimulateDevice (Helper helper, GUI gui) {
	  this.gui = gui;
	  this.helper = helper;


	config = helper.getConfig();
	controls = new Vector();		
   } 
   
   public String getDeviceName() {
	   return "UNKNOWN";
   }
   
   public void run() {
	
      while (true) {
         try { // Poll every ~10 ms
            Thread.sleep(200);
         }
         catch (InterruptedException e) {}

         switch (connectionStatus) {
         case Helper.BEGIN_CONNECT:
            try {
               // Try to set up a server if host
                  hostServer = new ServerSocket(getPort());
                  socket = hostServer.accept();

               in = new BufferedReader(new 
                  InputStreamReader(socket.getInputStream()));
               out = new PrintWriter(socket.getOutputStream(), true);
               
        	   simListener = new SimulationListener (this);
        	   simListener.start();
        	   simListener.setName( getDeviceName() + " Listener");
        	   
               simListener.setIn (in);
               this.setConnectionStatus(Helper.CONNECTED);
               changeStatusTS(Helper.CONNECTED, true);
			   doStartup ();
            }
            // If error, clean up and output an error message
            catch (IOException e) {
               cleanUp();
               changeStatusTS(Helper.DISCONNECTED, false);
            }
            break;

         case Helper.CONNECTED:
              // Send data
              if (toSend.length() != 0) {
            	  	synchronized (out){
            	  		out.print(toSend); out.flush();
            	  	}
                 toSend.setLength(0);
                 //changeStatusTS(Helper.NULL, true);
             } 

            break;

         case Helper.DISCONNECTING:
		    if (out != null) {
	      	  	synchronized (out){
		            out.print(END_CHAT_SESSION); 
		            out.flush();
		        	 }
	    	  	}

            // Clean up (close all streams/sockets)
            cleanUp();
            changeStatusTS(Helper.DISCONNECTED, true);
            break;

		 default: break; // do nothing
         }
      }
   }
	public String buildCustomString (String actionCommand){
		return "";
	}
	
	public void disconnect () {
		this.simListener.setRunning(false);
		changeStatusTS(Helper.BEGIN_CONNECT, false);
	}

	public abstract String buildOnString (ControlType control);
	public abstract String buildOffString (ControlType control);
	public abstract String buildSliderString (ControlType control,int val);
	
	public void changeStatusTS (int status, boolean noError){
		Iterator eachControl = controls.iterator();
		while (eachControl.hasNext()){
			((ControlType)eachControl.next()).changeStatus(status);
		}
		gui.changeStatusTS (status,noError);
	}
	
	public void doStartup () {

	}
	
	public void parseString (String in) {
		gui.appendToChatBox ("IN",in,"\n");
	}
 
   /////////////////////////////////////////////////////////////////
   // Add text to send-buffer
   public  void sendString(String s) {
      synchronized (toSend) {
         toSend.append(s + "\n");
         //toSend.append(s);
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

public Vector getControls () {
	return controls;
}

public void addControl (ControlType control) {
	controls.add(control);
}


public int getPort() {
	return port;
}


public void setPort(int port) {
	this.port = port;
}

}
