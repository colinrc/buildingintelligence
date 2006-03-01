/*
 * Created on Apr 13, 2004
 *
 * To change the template for this generated file go to
 * Window - Preferences - Java - Code Generation - Code and Comments
 */
package au.com.BI.Comms;
import java.io.*;
import java.util.List;
import java.util.logging.*;

import au.com.BI.Command.Command;
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
	protected boolean pausing = false;
	String heartbeatString = "\n";
	protected List commandQueue;
	protected int deviceNumber = -1;
	protected String modelName = "";
	/**
	 * 
	 */
	public IPHeartbeat() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		this.setName("IP Heartbeat");
	}

	public void setModelName (String name) {
		this.setName("IP Heartbeat - " + name);
		this.modelName = name;
	}
	
	public boolean getHandleEvents () {
		return handleEvents;
	}
	
	public void setHandleEvents (boolean handleEvents) {
		this.handleEvents = handleEvents;
	}
	
	public void pause (boolean pausing) {
		if (pausing) {
			this.pausing = true;
		} else {
			this.pausing = false;
		}

	}
	
	public void setOutputStream (OutputStream os){
		this.os = os;
	}
	/**
	 * Main run method for the class
	 */
	public void run () {
		handleEvents = true;

		while (handleEvents)
		{
			if (pausing) {
				try {
					while (pausing) sleep(1000);
				} catch (InterruptedException e) {
					pausing = false;
				}
			} else {
				if (os != null ) {
					try {
						synchronized (this.os){
							os.write(heartbeatString.getBytes());
							os.flush();
						}
					} catch (IOException e1) {
					    logger.log (Level.WARNING,"Connection failed, " + modelName + " - reconnecting");
						handleEvents = false;
						Command command = new Command();
						command.setCommand ("Attatch");
						command.setKey("SYSTEM");
						command.setExtraInfo (Integer.toString(deviceNumber));
						synchronized (commandQueue) {
							commandQueue.add(command);
							commandQueue.notifyAll();
						}
					}
					try {
						Thread.sleep(15000);
					} catch (InterruptedException e) {
	
					} 
				}
				else {
					handleEvents = false;
				}
			}
		}
	}

	public String getHeartbeatString() {
		return heartbeatString;
	}

	public void setHeartbeatString(String heartbeatString) {
		this.heartbeatString = heartbeatString;
	}
	public List getCommandQueue() {
		return commandQueue;
	}


	public void setCommandQueue(List commandQueue) {
		this.commandQueue = commandQueue;
	}


	public int getDeviceNumber() {
		return deviceNumber;
	}


	public void setDeviceNumber(int deviceNumber) {
		this.deviceNumber = deviceNumber;
	}
}
