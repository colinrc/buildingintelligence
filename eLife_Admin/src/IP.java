/*
 * Created on Dec 28, 2003
 *
*/
import java.io.*;
import java.util.logging.*;
import java.lang.reflect.InvocationTargetException;
import java.net.*;
import javax.swing.*;

/**
 * @author Colin Canfield
 * @version 1.0
 * @updated 18-Jan-2004 08:54:55 PM
 * Implements a multithreaded serial listener.
 * Serial events are received on a seperate thread.
 * Command line seperated strings are placed on the queue.
 * The main controller can be notified to process this.
 */
public class IP 
{

	protected Socket monitorSocket;
	protected Socket debugSocket;
	protected boolean monitorPortOpen = false;
	protected boolean debugPortOpen = false;
	protected OutputStream adminOs;
	protected InputStream adminIs;	
	protected OutputStream debugOs;
	protected InputStream debugIs;	
	protected DebugListener debugListener;
	protected AdminListener adminListener;
	protected String logDir;
	protected InetAddress ipAddress;
	protected int monitorPort;
	protected int debugPort;
	protected Logger logger;
	private eLife_Admin eLife;
	protected ConnectionManager manager;
	protected IPHeartbeat debugHeartbeat;
	protected IPHeartbeat adminHeartbeat;
	
	public IP (eLife_Admin eLife, ConnectionManager manager)  {
		this.eLife = eLife;
		logger = Logger.getLogger("Log");
		this.manager = manager;
	}
		
	
	public void sendMonitorMessage (String message) throws IOException {

		if (debugOs != null ) {
			synchronized (debugOs) {
				debugOs.write(message.getBytes());
				debugOs.write ((byte)0);
				debugOs.flush();
			}
		}
	}
	
	
	public void sendAdminMessage (String message) throws IOException {
		if (adminOs != null) {
			synchronized (adminOs) {
					adminOs.write(message.getBytes());
					adminOs.write((byte)0);
					adminOs.flush();
				}
			}
	}
	
	private class SetDebugPane implements Runnable {
		private LogPanel logPanel;
		private DebugListener debugListener;
		
		public SetDebugPane (DebugListener debugListener,LogPanel logPanel) {
			this.logPanel = logPanel;
			this.debugListener = debugListener;
		}
		
		public void run () {
			debugListener.seteLife(eLife);
		}
	}
	
	
	/**
	 * 
	 * @param ipAddressTxt The IP address
	 * @param port The ip monitorPort
	 * @throws au.com.BI.comms.ConnectionFail
	 */
	public boolean connectDebug (String ipAddressTxt, int debugPort )
		throws ConnectionFail 
		{
			try
			{
				this.ipAddress = InetAddress.getByName (ipAddressTxt);
				this.debugPort = debugPort; 
				SocketAddress sockaddr = new InetSocketAddress(ipAddress, debugPort);

				debugSocket = new Socket ();
				int timeoutMs = 0;   // wait forever for new data
				synchronized (debugSocket) {
					debugSocket.connect(sockaddr, timeoutMs);
					if (debugSocket.isConnected() && !debugSocket.isClosed()) {
						logger.log (Level.INFO,"Obtained debug connection");
						debugOs = debugSocket.getOutputStream();
						debugIs = debugSocket.getInputStream();
						
						debugSocket.setKeepAlive(true);
						debugListener = new DebugListener();
						debugListener.setManager (manager);
						debugListener.setInputStream (debugIs);
						debugPortOpen = true;
	
						LogPanel logViewer = eLife.getLogViewer();
						if (logViewer != null) {
							SetDebugPane setDebugPane = new SetDebugPane (debugListener,logViewer);
							try {
								SwingUtilities.invokeAndWait(setDebugPane);
								if (debugHeartbeat != null) {
									debugHeartbeat.setHandleEvents(false);
								}
								debugHeartbeat = new IPHeartbeat(debugOs,eLife,IPHeartbeat.ELIFE);
								debugHeartbeat.start();
	
								debugListener.start();
								debugListener.setHandleEvents(true);	
	
								return true;
							} catch (InterruptedException e1) {
								logger.log (Level.WARNING,"InterruptedException " + e1.getMessage());
							} catch (InvocationTargetException e1) {
								logger.log (Level.WARNING,"InvocationTargetException " + e1.getMessage());
							}
	
						}else {
							logger.log (Level.WARNING,"No log viewer is present to display debug logs");
						}
					} else {
						return false;
					}
				}
		    } catch (UnknownHostException e) {
	    			throw new ConnectionFail ("Could not find system " + e.getMessage());
	    		} catch (SocketTimeoutException e) {
		    		throw new ConnectionFail ("Could not connect " + e.getMessage());
		    } catch (IOException e) {	
		    		throw new ConnectionFail (e.getMessage());
		    } catch (NumberFormatException e) {
		    		throw new ConnectionFail ("IP port adminIs not a valid number " + e.getMessage());
			    	 	
		    }
		    return false;
		}	
	
	/**
	 * 
	 * @param ipAddressTxt The IP address
	 * @param port The ip monitorPort
	 * @throws au.com.BI.comms.ConnectionFail
	 */
	public boolean connectAdmin (String ipAddressTxt, int monitorPort )
		throws ConnectionFail 
		{
			try
			{
				this.ipAddress = InetAddress.getByName (ipAddressTxt);
				this.monitorPort = monitorPort; 
				SocketAddress sockaddr = new InetSocketAddress(ipAddress, monitorPort);

				monitorSocket = new Socket ();
				int timeoutMs = 0;   // wait forever for new data
				monitorSocket.connect(sockaddr, timeoutMs);
				if (monitorSocket.isConnected() &&!monitorSocket.isClosed()){
					logger.log (Level.FINEST,"Obtained admin connection");
					adminOs = monitorSocket.getOutputStream();
					adminIs = monitorSocket.getInputStream();
					adminListener = new AdminListener();
					adminListener.setManager (manager);
					adminListener.seteLife(eLife);
					adminListener.setInputStream(adminIs);
					adminListener.setLogDir(logDir);
					adminListener.setOutputStream(adminOs);
					adminListener.setHandleEvents(true);
					monitorSocket.setKeepAlive(true);
					monitorPortOpen=true;
					if (adminHeartbeat != null) {
						adminHeartbeat.setHandleEvents(false);
					}
					adminHeartbeat = new IPHeartbeat(adminOs,eLife,IPHeartbeat.MONITOR);
					adminHeartbeat.start();
					adminListener.start();
					return true;
				} else { 
					return false;
				}
		    } catch (UnknownHostException e) {
	    			throw new ConnectionFail ("Could not find system " + e.getMessage());
	    		} catch (SocketTimeoutException e) {
		    		throw new ConnectionFail ("Could not connect " + e.getMessage());
		    } catch (IOException e) {
		    		throw new ConnectionFail (e.getMessage());
		    } catch (NumberFormatException e) {
		    		throw new ConnectionFail ("IP port adminIs not a valid number " + e.getMessage());
			    	 	
		    }
		}

	public  boolean isAdminConnected () {
		return monitorPortOpen;
	}
	
	public  boolean isDebugConnected () {
		if (debugSocket != null) {
			synchronized (debugSocket) {
				return (debugSocket.isConnected() & !debugSocket.isClosed());
			}
		}
		else 
			return false;
		//return debugPortOpen;
	}

	public void closeAdmin () throws ConnectionFail 
	{
		if (adminHeartbeat != null){
			adminHeartbeat.setHandleEvents(false);
		}

		monitorPortOpen = false;
		if (adminListener != null) {
			adminListener.setHandleEvents(false);
		}
		if (monitorSocket != null) {
			try {
			// close the i/o streams.
			    if (adminOs != null) {
			    	synchronized (adminOs) {
			    		adminOs.close();
			    	}
			    }
			} catch (IOException e) {
				throw new ConnectionFail ("Failure closing monitor port",e);
			}

			try {
				// close the i/o streams.
				    if (adminIs != null) {
				    	synchronized (adminIs) {
				    		adminIs.close();
				    	}
				    }
				} catch (IOException e) {
					throw new ConnectionFail ("Failure closing monitor port",e);
				}
			
			try {
				if (!monitorSocket.isClosed()) {
					monitorSocket.close();
				}
			} catch (IOException e1) {
			}
			try {
				Thread.sleep(2000); // give the OS time to close down the socket properly
			} catch (InterruptedException e2) {
			}

		}
	}
	
	public void closeDebug (boolean updateListener) throws ConnectionFail 
	{
		if (debugHeartbeat != null){
			debugHeartbeat.setHandleEvents(false);
		}
	    if (updateListener) {
		    	if (debugListener != null ) {
				    synchronized (debugListener){
						if (debugListener != null) {
							debugListener.setHandleEvents(false);
						}
				    }
		    	}
	    }
	    if (debugSocket != null) {
	    		synchronized (debugSocket) {
				debugPortOpen = false;
				try {
				// close the i/o streams.
		    		if (debugOs != null) {
		    			synchronized (debugOs) {
		    				debugOs.close();
		    			}
				    }
				} catch (IOException e) {
					throw new ConnectionFail ("Failure closing debug port",e);
				}
	
				try {
					// close the i/o streams.
					if (debugIs != null) { 
						synchronized (debugIs) {
							debugIs.close();
					    }
					}
	
				} catch (IOException e) {
						throw new ConnectionFail ("Failure closing debug port",e);
				}
				try {
					if (debugSocket.isConnected()) {
						debugSocket.close();
					}
				} catch (IOException e1) {
				}
				try {
					Thread.sleep(2000); // give the OS time to close down the socket properly
				} catch (InterruptedException e2) {
				}
	    		}

		}
	}
	
	public void closeDebug () throws ConnectionFail 
	{
		closeDebug (true);
	}

	public void sendString (String message)
		throws CommsFail 
	{
		try {
			if (monitorPortOpen) {
				synchronized (adminOs){
					adminOs.write((message).getBytes());
					adminOs.flush();
				}
			}
		} catch (InterruptedIOException e) {
		    throw new CommsFail ("Timeout in IP connection: ",e);
		} catch (IOException e) {
			throw new CommsFail ("Failure sending the information: ",e);
		}
	}

	public void sendString (byte[] message)
	throws CommsFail 
	{
		try {
			if (monitorPortOpen) {
				synchronized (adminOs){
					adminOs.write(message);
					adminOs.flush();
				}
			}
		} catch (IOException e) {
			throw new CommsFail ("Failure sending the information: ",e);
		}
	}
	/**
	 * @return Returns the debugIs.
	 */
	public InputStream getDebugIs() {
		return debugIs;
	}
	/**
	 * @param debugIs The debugIs to set.
	 */
	public void setDebugIs(InputStream debugIs) {
		this.debugIs = debugIs;
	}
	/**
	 * @return Returns the debugOs.
	 */
	public OutputStream getDebugOs() {
		return debugOs;
	}
	/**
	 * @param debugOs The debugOs to set.
	 */
	public void setDebugOs(OutputStream debugOs) {
		this.debugOs = debugOs;
	}


	public String getLogDir() {
		return logDir;
	}


	public void setLogDir(String logDir) {
		this.logDir = logDir;
		if (adminListener != null) {
			adminListener.setLogDir(logDir);
		}
	}
}	
	
