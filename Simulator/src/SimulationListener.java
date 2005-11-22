import java.io.*;

public class SimulationListener extends Thread {

	private boolean running = true;
	private BufferedReader in = null;
	protected SimulateDevice sim;
	
	public SimulationListener (SimulateDevice sim) {
		this.sim = sim;
	}
	
	public void run () {
		String str;
		while (running) {
			if (in != null) {
				try {
					synchronized (in){
						while (in.ready() && ((str = in.readLine()) != null )){
							if (!str.trim().equals(""))
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
	
	public void setIn (BufferedReader newIn) {
		if (in != null) {
			synchronized (in) {
				try {
					in.close();
					in = null;
				} catch (IOException ex) {}
			}
		}
		this.in = newIn;
		running = true;
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
