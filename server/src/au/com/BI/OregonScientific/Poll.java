/*
 * Created on Dec 14, 2004
 */
package au.com.BI.OregonScientific;
import java.util.logging.*;

import au.com.BI.Command.*;
import au.com.BI.Comms.*;


/**
 * @author colinc
 */
public class Poll  extends Thread {
	/**
	 * 
	 */
	protected Logger logger;
	protected volatile boolean running;
	protected CommDevice comms;
	protected long pollValue;
	protected String pollString =  "";
	protected CommandQueue commandQueue;
	protected int deviceNumber = -1;
	
	/**
	 * @return Returns the pollValue.
	 */
	public long getPollValue() {
		return pollValue;
	}
	/**
	 * @param pollValue The pollValue to set.
	 */
	public void setPollValue(long pollValue) {
		this.pollValue = pollValue;
	}
	public Poll() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		this.setName("Raw interface poll handler");
	}
	
	
	public void run () {
		running  = true;
		try {
			while (running){
					if (!pollString.equals ("")) {
						CommsCommand analogueCommand = new CommsCommand("",pollString ,null,"Raw Command");
						analogueCommand.setActionType(CommDevice.RawPoll);
						analogueCommand.setActionCode("RAW_POLL");
						synchronized (comms) {
							comms.addCommandToQueue(analogueCommand);
						}
					try {
						Thread.sleep (pollValue);
					} catch (InterruptedException ie) {}
					}
			}
		} catch (CommsFail e1) {
			running = false;
			logger.log(Level.WARNING, "Communication failed with raw device " + e1.getMessage());
			Command command = new Command();
			command.setCommand ("Attatch");
			command.setKey("SYSTEM");
			command.setExtraInfo (Integer.toString(deviceNumber));
			commandQueue.add(command);
		}
		
	}
	/**
	 * @return Returns the running.
	 */
	public boolean isRunning() {
		return running;
	}
	/**
	 * @param running The running to set.
	 */
	public void setRunning(boolean running) {
		this.running = running;
	}

	/**
	 * @param comms The comms to set.
	 */
	public void setComms(CommDevice comms) {
		this.comms = comms;
	}

	/**
	 * @return Returns the pollString.
	 */
	public String getPollString() {
		return pollString;
	}
	/**
	 * @param pollString The pollString to set.
	 */
	public void setPollString(String pollString) {
		this.pollString = pollString;
	}


	public int getDeviceNumber() {
		return deviceNumber;
	}


	public void setDeviceNumber(int deviceNumber) {
		this.deviceNumber = deviceNumber;
	}
}
