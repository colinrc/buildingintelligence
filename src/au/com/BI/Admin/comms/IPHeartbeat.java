package au.com.BI.Admin.comms;

import au.com.BI.Admin.Home.Admin;
import java.io.*;
import java.util.logging.*;
/**
 * @author colinc
 *
 * To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Generation - Code and Comments
 */
public class IPHeartbeat extends Thread {
	protected boolean handleEvents = false;
	protected OutputStream os = null;
	protected Logger logger;
	protected Admin eLife;
	protected static int MONITOR = 1;
	protected static int ELIFE = 2;
	protected int mode;
	/**
	 * 
	 */
	public IPHeartbeat(OutputStream os, Admin eLife, int mode ) {
		super();
		this.setName("Heartbeat");
		logger = Logger.getLogger("Log");
		this.os = os;
		this.eLife = eLife;
		this.mode = mode;
	}

	public boolean getHandleEvents () {
		return handleEvents;
	}
	
	public void setHandleEvents (boolean handleEvents) {
		this.handleEvents = handleEvents;
	}

	/**
	 * Main run method for the class
	 */
	public void run () {
		handleEvents = true;

		while (handleEvents)
		{

			if (os != null ) {
				try {
					synchronized (this.os){
						os.write("<HEARTBEAT />\n".getBytes());
						os.write((byte)0);
						os.flush();
					}
				} catch (IOException e1) {
				    logger.log (Level.FINEST,"Connection failed to the IP device");
				    synchronized (eLife) {
				    		if (mode == MONITOR) {
				    			eLife.disconnectAdmin();
				    		} else {
				    			eLife.disconnect_eLife();
				    		}
				    			
				    		handleEvents = false;
				    }
				}
			}
			else {
				handleEvents = false;
			}
			if (handleEvents) {
				try {
					sleep(15000);
				} catch (InterruptedException e) {
				}
			}
		}
	}
}
