package au.com.BI.simulator.sims;
import java.io.*;
import java.net.*;

public class SimulationListener extends Thread {

	private boolean running = true;
	private BufferedReader in = null;
	protected SimulateDevice sim;
	
	public SimulationListener (SimulateDevice sim,Socket simulationConnection) {
		this.sim = sim;
		try {
			in = new BufferedReader(new 
					InputStreamReader(simulationConnection.getInputStream()));
		} catch ( IOException ex){
			in = null;
		}
	}
	
	public void run () {
		String str;
		while (running && sim != null) {
			if (in != null) {
				try {
					synchronized (in){
						while (in.ready() && ((str = in.readLine()) != null )){
							if (str!= null && sim != null && !str.trim().equals(""))
								sim.parseString (str);
						}
					}
				} catch (IOException ex) {
					synchronized (in){
						in = null;
					}
					sim.disconnect();
				}
			} else {

			}
			try {
				Thread.sleep(500);
			} catch (InterruptedException e) {
			}
		}
		
	}

	public boolean isRunning() {
		return running;
	}

	public void setRunning(boolean running) {
		this.running = running;
		if (in != null) {
			try {
				in.close();
			} catch (IOException ex){}
		}
	}
}
