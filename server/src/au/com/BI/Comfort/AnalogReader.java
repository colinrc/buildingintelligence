/*
 * Created on May 20, 2004
 */
package au.com.BI.Comfort;
import java.util.logging.*;

import au.com.BI.Analog.*;

import java.util.*;
import au.com.BI.Comms.*;


/**
 * @author colinc
 */
public class AnalogReader  extends Thread {
	/**
	 * 
	 */
	protected Logger logger;
	protected List <Analog>analogueQueue;
	protected boolean running;
	protected String STX;
	protected String ETX;
	protected CommDevice comms;
	protected long pollValue;
	
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
	public AnalogReader() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		analogueQueue = Collections.synchronizedList(new LinkedList<Analog>());
		this.setName( "Comfort analog value handler");
	}
	
	public void addAnalogueInput (Analog analogue) {
		synchronized (analogueQueue) {
			analogueQueue.add(analogue);
		}
	}
	
	public void clearItems () {
		running = false;
		synchronized (analogueQueue) {
			analogueQueue.clear();
		}
	}


	
	public void run () {
		if (analogueQueue.isEmpty()) {
			logger.log (Level.FINEST,"No analague items found");
			return;
		}

		running  = true;
		
		while (running){
			Iterator analogueItems = analogueQueue.iterator();
			while (analogueItems.hasNext()){
				Analog analogue = (Analog)analogueItems.next();
				try {
					CommsCommand analogueCommand = new CommsCommand("",STX+"DA59"+analogue.getKey() + ETX,null,"Analogue Command");
					analogueCommand.setActionType(CommDevice.AnalogueQuery);
					analogueCommand.setActionCode("ANALOGUE_QUERY");
					analogueCommand.setDisplayName(analogue.getOutputKey());
					analogueCommand.setSrcCommand(analogue);
					running = false;
					synchronized (comms) {
						comms.addCommandToQueue(analogueCommand);
					}
				} catch (CommsFail e) {
						logger.log (Level.WARNING, "Communication failed reading Comfort analogue "+e.getMessage());
						running = false;
				}
			}
			try {
				Thread.sleep (pollValue);
			} catch (InterruptedException ie) {}
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
	 * @return Returns the sTX.
	 */
	public String getSTX() {
		return STX;
	}
	/**
	 * @param stx The sTX to set.
	 */
	public void setSTX(String stx) {
		STX = stx;
	}
	/**
	 * @param comms The comms to set.
	 */
	public void setComms(CommDevice comms) {
		this.comms = comms;
	}
	/**
	 * @return Returns the eTX.
	 */
	public String getETX() {
		return ETX;
	}
	/**
	 * @param etx The eTX to set.
	 */
	public void setETX(String etx) {
		ETX = etx;
	}
}
