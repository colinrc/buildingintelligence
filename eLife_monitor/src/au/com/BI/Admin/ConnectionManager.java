/*
 * Created on Feb 4, 2005
 *

 */
package au.com.BI.Admin;


import java.io.*;
import java.net.InetAddress;
import java.net.SocketAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketTimeoutException;
import java.util.logging.Level;
import java.util.logging.Logger;



public class ConnectionManager extends Thread {

	private Logger logger;
	boolean running;
	protected int portNumber;
	protected String Address;
	protected InetAddress iPAddress;
	protected SocketAddress oldSocket;
	protected ServerSocket iPPort;
	protected eLife_monitor eLife;
	protected OutputStream out;
	protected IPHeartbeat heartbeat;

	public ConnectionManager (int portNumber,eLife_monitor eLife) {
		this.portNumber = portNumber;
		this.eLife = eLife;
	}
	
	public void run() {
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
		
							Socket adminConnection = iPPort.accept();
							logger.log (Level.INFO,"Received connection from " + adminConnection.getRemoteSocketAddress().toString());
							adminConnection.setTcpNoDelay(true);
							adminConnection.setReuseAddress(false);
							if (eLife.isConnected()) {
								/*
								out = adminConnection.getOutputStream();
								InetAddress theAddress  = adminConnection.getInetAddress();								
								if (theAddress != null) {
									String wholeMessage;
									if (oldSocket != null ) {
							    			wholeMessage = "<ALREADY_IN_USE><![CDATA[Monitor is now controlled by " + oldSocket.toString() + " ]]></ALREADY_IN_USE>\n";
									} else {
						    				wholeMessage = "<ALREADY_IN_USE><![CDATA[Monitor was in use ]]></ALREADY_IN_USE>\n";										
									}
							    		try {
							    			synchronized (out){
									    		out.write (wholeMessage.getBytes());
									    		out.write(0);
									    		out.flush();
							    			}
							    			out.close();
								    	} catch (IOException io){};
								}
								*/
								stopHeartbeat();
								eLife.disconnect();
							}
							oldSocket = adminConnection.getRemoteSocketAddress();
							out = adminConnection.getOutputStream();
							heartbeat = new IPHeartbeat(out,eLife);
							heartbeat.start();
							eLife.connect (adminConnection);
						} catch (SocketTimeoutException te) {

						}
					}
				}catch (IOException io){
					logger.log(Level.SEVERE, "Could not add client handler " +io.getMessage());
				}
			}

	/**
	 * @return Returns the running.
	 */
	public boolean isRunning() {
		return running;
	}
	
	public void stopHeartbeat () {
		if (heartbeat != null) {
			heartbeat.setHandleEvents(false);
		}
	}
	/**
	 * @param running The running to set.
	 */
	public void setRunning(boolean running) {
		this.running = running;
	}
}
