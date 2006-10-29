package au.com.BI.Admin.comms;
/*
 * Created on Jan 9, 2005
 *
 */
import au.com.BI.Admin.Home.Admin;
import java.io.*;
import java.util.logging.*;


public class ConnectionManager extends Thread {
	private String IPaddress;
	private IP ip;
	private int adminPort;
	private int logPort;
	private boolean tryToConnect = true;
	private Admin eLife;
	private Logger logger;
	private boolean updatingParams = false;

	
	public ConnectionManager (Admin eLife) {
		this.setName("Connection Manager");

		this.eLife = eLife;
		logger = Logger.getLogger("Log");
		ip = new IP(eLife,this);
		eLife.setIP (ip);
	}
	
	public void connect (String IPaddress, int adminPort, int logPort) {
		logger.info("Openning debug IP " + IPaddress + " port " + logPort);
		logger.info("Openning admin IP " + IPaddress + " port " + adminPort);
		
		updatingParams = true;
		if (ip.isAdminConnected()) {
			try {
				ip.closeAdmin();
			} catch (ConnectionFail ex) {}
		}
		if (ip.isDebugConnected()) {
			try {
				ip.closeDebug();
			} catch (ConnectionFail ex) {}
		}
		
		this.IPaddress = IPaddress;
		this.adminPort = adminPort;
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
						ip.closeAdmin();
				} catch (ConnectionFail ex) {}
			//}
		}

	}


	public void run () {

		
		while (tryToConnect) {
			if (!updatingParams) {
				//synchronized (ip){
					if (!ip.isAdminConnected()) {
						try {
							if (ip.connectAdmin(IPaddress,adminPort) ) {
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
		ip.sendMonitorMessage (message);
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
