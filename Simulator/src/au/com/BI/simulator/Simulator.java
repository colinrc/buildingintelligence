package au.com.BI.simulator;


import java.util.*;
import java.io.*;
import java.net.*;
import au.com.BI.simulator.gui.ControlType;
import au.com.BI.simulator.gui.GUI;
import au.com.BI.simulator.sims.Helper;
import au.com.BI.simulator.sims.SimulateCBUS;
import au.com.BI.simulator.sims.SimulateComfort;
import au.com.BI.simulator.sims.SimulateDevice;
import au.com.BI.simulator.sims.SimulateGC100;
import au.com.BI.simulator.sims.SimulateM1;
import au.com.BI.simulator.sims.SimulateRaw;
import au.com.BI.simulator.sims.SimulateUnknown;
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
	      Vector controls = new Vector(10);

	simulationDevices = new HashMap<SimTypes,SimulateDevice>();

	
	gui = new GUI(helper,this);
	
	textCon = new SimulateUnknown (helper, gui);
	textCon.start();
	simulationDevices.put(SimTypes.UNKNOWN,textCon);

	comfortCon = new SimulateComfort (helper, gui);
	comfortCon.start();
	simulationDevices.put(SimTypes.COMFORT,comfortCon);

	rawCon = new SimulateRaw (helper, gui);
	rawCon.start();
	simulationDevices.put(SimTypes.RAW,rawCon);

	cbusCon = new SimulateCBUS (helper, gui);
	cbusCon.start();
	simulationDevices.put(SimTypes.CBUS,cbusCon);
	
	gc100Con = new SimulateGC100 (helper, gui);
	gc100Con.start();
	simulationDevices.put(SimTypes.GC100,gc100Con);

	m1Con = new SimulateM1 (helper, gui);
	m1Con.start();
	simulationDevices.put(SimTypes.M1,m1Con);

	
	for (Control control: config.getControls()) {
		SimulateDevice sim = simulationDevices.get(control.getSimType());
		if (sim == null) {
			System.out.println("Could not find simulation handler for group " + i + " type : " + groupType);
			continue;
		}

		ControlType control = new ControlType(sim);
	    control.setGroupType(groupType,subGroupType);
		String groupName = helper.getPropValue("GroupName."+i);
		if (groupName.equals("")) continue;
	    control.setTitle(groupName);
	    control.setKey(helper.getPropValue("GroupKey."+i));
	    control.setKeyOn(helper.getPropValue("GroupString."+i+".ON"));	    
	    control.setKeyOff(helper.getPropValue("GroupString."+i+".OFF"));	
	    String isSlider = helper.getPropValue("GroupIsSlider."+i);
	    if (isSlider.equals("Y"))
	    		control.setHasSlider(true);
	    else
	    		control.setHasSlider(false);
	    
	    switch (control.getSimType()) {
	    		case SimTypes.CBUS:
	    			cbusCon.addControl (control);
	    			break;
	    			
	    		case ControlType.COMFORT:
	    			comfortCon.addControl (control);
	    			break;

	    		case ControlType.M1:
	    			m1Con.addControl (control);
	    			break;
	    			
	    		case ControlType.RAW:
	    			rawCon.addControl (control);
	    			break;
	    }
	    controls.add(control);

	}
	gui.addControls(controls);
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
	   sendString (ControlType.UNKNOWN,s);
   }
   // Add text to send-buffer
   public  void sendString(int groupType, String s) {
	    switch (groupType) {
		case ControlType.CBUS:
			cbusCon.sendString (s);
			break;
			
		case ControlType.COMFORT:
			comfortCon.sendString (s);
			break;
			
		case ControlType.M1:
			m1Con.sendString (s);
			break;
						
		case ControlType.RAW:
			rawCon.sendString (s);
			break;

		case ControlType.UNKNOWN:
			textCon.sendString (s);
			break;
	    }

   }
   
   public SimulateDevice getSimulateDevice (ControlType groupType) {
	   SimulateDevice simulate = null;
	   try {
		   simulate = (SimulateDevice)this.simulationDevices.get(groupType.toString());
	   } catch (ClassCastException ex) {
		   System.out.print("Group type " + groupType.toString() + " not initialised correctly");
		   return null;
	   } catch (NullPointerException ex){
		   System.out.print("Group " + groupType.toString() + " not found");
		   return null;
	   }
	   return simulate;
   }

   public void setConnectionStatus (int connectionStatus) {
	    Iterator eachSim = this.simulationDevices.keySet().iterator();
	   while (eachSim.hasNext()) {
		   String simKey = (String)eachSim.next();
		   SimulateDevice sim = (SimulateDevice)simulationDevices.get(simKey);
		   if (sim != null) sim.setConnectionStatus(connectionStatus);		   
	   }	
	   
	   //this.textCon.setConnectionStatus(connectionStatus);
   }
   
   public void setConnectionStatus (int connectionStatus,ControlType groupType) {
	   SimulateDevice simulate = this.getSimulateDevice (groupType);
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