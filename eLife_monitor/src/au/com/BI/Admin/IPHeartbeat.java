package au.com.BI.Admin;
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
	protected eLife_monitor eLife;
	/**
	 * 
	 */
	public IPHeartbeat(OutputStream os, eLife_monitor eLife ) {
		super();
		logger = Logger.getLogger("Log");
		this.os = os;
		this.eLife = eLife;
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
				    logger.log (Level.FINEST,"Connection failed");
				    synchronized (eLife) {
			    			eLife.disconnect();
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
