package au.com.BI.simulator.sims;


import java.util.*;
import java.io.*;
import java.net.*;
import java.util.logging.*;
import au.com.BI.simulator.gui.*;
import au.com.BI.simulator.conf.*;
import static au.com.BI.simulator.conf.Control.*;

public class Simulator {
   
   public static int port = 5000;
  
   public GUI gui;
   public int connectionStatus = Helper.DISCONNECTED;
   
   Config config;
   
   public final static String END_CHAT_SESSION =
      new Character((char)0).toString(); // Indicates the end of a session


   public static StringBuffer toSend = new StringBuffer("");  
   private Helper helper;

   // TCP Components
   public static ServerSocket hostServer = null;
   public static Socket socket = null;

   public static BufferedReader in = null;
   public static PrintWriter out = null;
   
   public SimTypes groupType = SimTypes.UNKNOWN;
   private HashMap<SimTypes,SimulateDevice> simulationDevices = null;
   
	SimulateUnknown textCon = null;
	SimulateComfort comfortCon = null;
	SimulateRaw rawCon = null;
	SimulateCBUS cbusCon = null;
	SimulateGC100 gc100Con = null;	
	SimulateM1 m1Con = null;
	   SimulationControlListener textListener = null;
	   SimulationControlListener comfortListener = null;
	   SimulationControlListener rawListener = null;
	   SimulationControlListener cbusListener = null;
	   SimulationControlListener gc100Listener =  null;
	   SimulationControlListener m1Listener =  null;
	
   /////////////////////////////////////////////////////////////////
   // The main procedure
   public Simulator () {
		  
	  	helper = new Helper();
   }
   
   
   public boolean loadConfig(String filename) {
		config = new Config();
		try {
			config.readConfig (filename);
		} catch (ConfigError e) {
			System.out.println ("Could not load configuration file " + e.getMessage());
			return false;
		}
		helper.setConfig(config);
		return true;
   }

   public void start() {
	      Vector<Control> controls = new Vector<Control>(10);

	simulationDevices = new HashMap<SimTypes,SimulateDevice>();

	
	gui = new GUI(helper,this);
	
	textCon = new SimulateUnknown (helper, gui);
	//textCon.start();
	textListener = new SimulationControlListener (textCon.getPort(),"",Level.INFO,textCon);
	textListener.start();
	simulationDevices.put(SimTypes.UNKNOWN,textCon);

	comfortCon = new SimulateComfort (helper, gui);
	//comfortCon.start();
	comfortListener = new SimulationControlListener (comfortCon.getPort(),"",Level.INFO,comfortCon);
	comfortListener.start();
	simulationDevices.put(SimTypes.COMFORT,comfortCon);

	rawCon = new SimulateRaw (helper, gui);
	//rawCon.start();
	rawListener = new SimulationControlListener (rawCon.getPort(),"",Level.INFO,rawCon);
	rawListener.start();
	simulationDevices.put(SimTypes.RAW,rawCon);

	cbusCon = new SimulateCBUS (helper, gui);
	//cbusCon.start();
	cbusListener = new SimulationControlListener (cbusCon.getPort(),"",Level.INFO,cbusCon);
	cbusListener.start();
	simulationDevices.put(SimTypes.CBUS,cbusCon);
	
	gc100Con = new SimulateGC100 (helper, gui);
	//gc100Con.start();
	gc100Listener = new SimulationControlListener (gc100Con.getPort(),"",Level.INFO,gc100Con);
	gc100Listener.start();
	simulationDevices.put(SimTypes.GC100,gc100Con);

	m1Con = new SimulateM1 (helper, gui);
	//m1Con.start();
	m1Listener = new SimulationControlListener (m1Con.getPort(),"",Level.INFO,m1Con);
	m1Listener.start();
	simulationDevices.put(SimTypes.M1,m1Con);

	for (Control control: config.getControls()){
		
		SimulateDevice sim = simulationDevices.get(control.getSimType());
		if (sim == null) {
			System.out.println("Could not find simulation handler for group type : " + control.getSimType());
			continue;
		}

	    GUIPanel gUIPanel = new GUIPanel(sim,control);
	        
	    switch (control.getSimType()) {
	    		case CBUS:
	    			cbusCon.addControl (control);
	    			break;
	    			
	    		case COMFORT:
	    			comfortCon.addControl (control);
	    			break;

	    		case M1:
	    			m1Con.addControl (control);
	    			break;
	    			
	    		case RAW:
	    			rawCon.addControl (control);
	    			break;
	    }
	    controls.add(control);
		gui.addGUIPanel(gUIPanel);
	}
	gui.redraw();

//	gui.changeStatusNTS(Helper.NULL, true, new ControlType ("UNKNOWN"));
		
   }	   
 
   public void disconnectAll () {
	  Iterator eachSim = this.simulationDevices.keySet().iterator();
	  while (eachSim.hasNext()){
		  String eachkey = (String)eachSim.next();
		  SimulateDevice sim = (SimulateDevice)simulationDevices.get(eachkey);
		  
		  sim.disconnect();
	  }
   }
   
   /////////////////////////////////////////////////////////////////

   public void sendString (String s) {
	   sendString (SimTypes.UNKNOWN,s);
   }
   // Add text to send-buffer
   public  void sendString(SimTypes simType, String s) {
	    switch (simType) {
		case CBUS:
			cbusCon.sendString (s);
			break;
			
		case COMFORT:
			comfortCon.sendString (s);
			break;
			
		case M1:
			m1Con.sendString (s);
			break;
						
		case RAW:
			rawCon.sendString (s);
			break;

		case UNKNOWN:
			textCon.sendString (s);
			break;
	    }

   }
   
   public SimulateDevice getSimulateDevice (SimTypes simType) {
	   SimulateDevice simulate = null;
	   try {
		   return simulationDevices.get(simType);
	   } catch (NullPointerException ex){
		   System.out.print("Group " + groupType.toString() + " not found");
		   return null;
	   }
   }

   public void setConnectionStatus (int connectionStatus) {
	   for (SimulateDevice sim : simulationDevices.values()) {
		   sim.setConnectionStatus(connectionStatus);
	   }
   }
   
   public void setConnectionStatus (int connectionStatus,SimTypes simType) {
	   SimulateDevice simulate = this.getSimulateDevice (simType);
	   if (simulate != null) simulate.setConnectionStatus(connectionStatus);
   }

   public static void main(String args[]) {
	   boolean configLoaded = false;
	   Simulator simulator = new Simulator();
	   if (args.length > 0) {
		   configLoaded = simulator.loadConfig(args[0]);
	   } else {
		   configLoaded = simulator.loadConfig("./conf/default.xml");
	   }
	   if (configLoaded) simulator.start();
   }

}