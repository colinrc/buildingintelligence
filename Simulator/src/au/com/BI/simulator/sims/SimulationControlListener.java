/*
 * Created on Dec 28, 2003
 *
*/
package au.com.BI.simulator.sims;

import java.io.*;
import java.util.logging.*;

import java.util.*;
import java.net.*;


/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 * This thread listens for clients and establishes connections as they occur
 */
public class SimulationControlListener extends Thread  
{
	
	protected ServerSocket iPPort;
	
	protected LinkedList adminControllers;
	protected int portNumber;
	protected String Address;
	protected InetAddress iPAddress;
	protected Logger logger;
	protected boolean running;
	protected Level defaultDebugLevel;
	protected SimulationListener simulationListener = null;
	protected SimulationListener currentSimulationListener = null;
	protected SimulateDevice sim = null;
	protected Socket currentSocket = null;
	
	public SimulationControlListener ( int portNumber, String address, Level defaultDebugLevel,
			SimulateDevice sim) 
	{
		
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		this.defaultDebugLevel = defaultDebugLevel;
		this.setName("Control Listener " + sim.getDeviceName());
		this.sim = sim;
		try {
			logger.info("Listening for clients on port " + portNumber + " IP " + address);
			this.portNumber = portNumber;
			this.iPAddress = InetAddress.getByName (address);
		}	catch (IOException ex){
			logger.log (Level.WARNING,"Could not start listening to port " + portNumber);
		}
	}
	
	
	/**
	* Main thread. 
	* Sits in a continuous loop creating FlashClientHandler objects as required to 
	* to handle each admin client
	*/

	public void run ()
	{
		logger = Logger.getLogger(this.getClass().getPackage().getName());

		logger.info("Openning port " + portNumber);
		running = true;
		
		try {
				//iPPort = new ServerSocket (portNumber,0,iPAddress);
				iPPort = new ServerSocket (portNumber);
				iPPort.setSoTimeout(60000);
				while (running) {

					//Block until I get a connection then go
					try {
	
						Socket simulationConnection = iPPort.accept();
						addTheHandler (simulationConnection);

					} catch (SocketTimeoutException te) {
					     if (currentSimulationListener != null) {
					  		currentSimulationListener.setRunning(false);
					  	}
					}catch (IOException io){
						logger.log(Level.INFO, "Could not add client handler " +io.getMessage());
					}
				}
			} catch (IOException ex) {
				logger.log (Level.WARNING,"Admin handler unable to startup due to network problems " +ex.getMessage());
			}
	}

	public void addTheHandler (Socket simulationConnection) throws SocketTimeoutException,IOException{
		try {
			simulationConnection.setKeepAlive(true);
		    logger.info("Simulation connection received,closing existing connections");
		    if (currentSimulationListener != null) {
		        currentSimulationListener.setRunning(false);
		        if (currentSocket != null) currentSocket.close();
		    }
		    currentSocket = simulationConnection;
		    sim.newConnection (simulationConnection);
			SimulationListener simulationListener = new SimulationListener (sim,simulationConnection);
			currentSimulationListener = simulationListener;

			simulationListener.start();
		} catch (java.net.SocketException ex) {
			logger.log (Level.WARNING,"Could not bind socket to simulation listener " + ex.getMessage());
		}
		

	}
	
	
	public void stopRunning () {
		running = false;

		try {
		    if (iPPort != null) iPPort.close();
		} catch (IOException io) { }
	}

	
}
