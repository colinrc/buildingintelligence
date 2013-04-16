/*
 * Created on Jan 9, 2005
 *
 */
import java.io.*;
import java.util.logging.*;


public class ConnectionManager extends Thread {
	private String IPaddress;
	private IP ip;
	private int monitorPort;
	private int logPort;
	private boolean tryToConnect = true;
	private eLife_Admin eLife;
	private Logger logger;
	private boolean updatingParams = false;

	
	public ConnectionManager (eLife_Admin eLife) {
		this.setName("Connection Manager");

		this.eLife = eLife;
		logger = Logger.getLogger("Log");
		ip = new IP(eLife,this);
		eLife.setIP (ip);
	}
	
	public void connect (String IPaddress, int monitorPort, int logPort) {
		logger.info("Openning debug IP " + IPaddress + " port " + logPort);
		logger.info("Openning monitor IP " + IPaddress + " port " + monitorPort);
		
		updatingParams = true;
		if (ip.isMonitorConnected()) {
			try {
				ip.closeMonitor();
			} catch (ConnectionFail ex) {}
		}
		if (ip.isDebugConnected()) {
			try {
				ip.closeDebug();
			} catch (ConnectionFail ex) {}
		}
		
		this.IPaddress = IPaddress;
		this.monitorPort = monitorPort;
		this.logPort = logPort;
		updatingParams = false;
	}
	
	public void disconnectMonitor () {
		if (ip != null){
			//synchronized (ip){
				try {
						ip.closeDebug();
				} catch (ConnectionFail ex) {}
			//}
		}
	}

	public void disconnectAdmin () {
		if (ip != null) {
			//synchronized (ip){
				try {
						ip.closeMonitor();
				} catch (ConnectionFail ex) {}
			//}
		}

	}


	public void run () {

		
		while (tryToConnect) {
			if (!updatingParams) {
				//synchronized (ip){
					if (!ip.isMonitorConnected()) {
						try {
							if (ip.connectMonitor(IPaddress,monitorPort) ) {
								synchronized (eLife) {
									eLife.setAdminConnectionStatus(true);
									eLife.doAdminConnectionStartup();
								}
							}
						} catch (ConnectionFail ex) {}
					}
					if (!ip.isDebugConnected()) {
						try {
							if (ip.connectDebug(IPaddress,logPort) ) {
								synchronized (eLife) {
									eLife.setELifeConnectionStatus(true);
									eLife.doELifeConnectionStartup();
								}
							}
						} catch (ConnectionFail ex) {
							eLife.setELifeConnectionStatus(false);
						}
					}
				//}
			}
			try {
				if (tryToConnect) Thread.sleep(5000);
			} catch (InterruptedException e) {
			}
		}
	}
	
	public void sendMonitorMessage (String message) throws IOException {
		ip.sendDebugMessage (message);
	}
	
	/**
	 * @return Returns the tryToConnect.
	 */
	public boolean isTryToConnect() {
		return tryToConnect;
	}
	/**
	 * @param tryToConnect The tryToConnect to set.
	 */
	public void setTryToConnect(boolean tryToConnect) {
		this.tryToConnect = tryToConnect;
	}
	/**
	 * @return Returns the updatingParams.
	 */
	public boolean isUpdatingParams() {
		return updatingParams;
	}
	/**
	 * @param updatingParams The updatingParams to set.
	 */
	public void setUpdatingParams(boolean updatingParams) {
		this.updatingParams = updatingParams;
	}
}
