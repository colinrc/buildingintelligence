/*
 * Created on Jun 10, 2004
 *
 */
package au.com.BI.HAL;

import java.util.logging.Level;
import java.util.*;
import java.util.logging.Logger;

import au.com.BI.Comms.*;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;
import au.com.BI.Audio.*;

/**
 * @author colinc
 *
 *
 */
public class PollDevice extends Thread {
	protected Logger logger;
	protected volatile boolean running;
	protected CommDevice comms;
	protected long pollValue;
	protected ConfigHelper configHelper;
	protected CommandQueue commandQueue;
	protected String ETX;
	protected int unresponsiveCounter = 0;
	protected boolean halConnectionRestored = false;
	protected boolean firstRun = true;
	public boolean pausing = false;
	protected int waitExtra = 0;
	protected int deviceNumber = -1;
	protected HashMap <String,StateOfZone>halState = null;
	
	public PollDevice() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		this.setName("HAL poll handler");
	}
	
	
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

	public void clearItems () {
		running = false;
	}

	protected void setConfigHelper (ConfigHelper configHelper) {
		this.configHelper = configHelper;
	}
	
	public void incrementResponseCounter (int causeDevice) {
        this.unresponsiveCounter ++;
        if (this.unresponsiveCounter % 3 == 0) {
            logger.log (Level.WARNING,"HAL is not responding, reconnecting.");
            throw new CommsFail ("HAL is not responding");
        }
	    
	}
	
	public void pause () {
		waitExtra = 10000;
	}

	
	
	public void run ()  {
		running = true;
		boolean commandSent = false;
		
			while (running) {
			    commandSent = false;
			    synchronized (this) {
			        while (pausing) {
			            try {
			                wait();
			            } catch (Exception e) {
			                
			            }
			        }
			    }
				synchronized (comms) {
					    if (comms.sentQueueContainsCommand (CommDevice.HalStartup)) {
					        incrementResponseCounter(CommDevice.HalStartup);
					        // sendStartupCommand();
					        // THink it should not retry until 3 increment has been finalised
					        logger.log (Level.WARNING,"HAL polling has begun when the startup has not yet been processed.");
					        commandSent = true;
					    } else {
					        if (comms.sentQueueContainsCommand (CommDevice.HalState)) { 
					            incrementResponseCounter(CommDevice.HalState);
					            commandSent = true;
					        }
					        else {
					            if (this.unresponsiveCounter > 3) this.halConnectionRestored = true;
					            this.unresponsiveCounter = 0;
						        //logger.log (Level.FINEST,"Sending HAL state commands.");
						    }
					    }
				    }
				    if (!commandSent) {
				            comms.removeAllCommands (CommDevice.HalState);
							for (DeviceType activeInput: configHelper.getAllControlledDeviceObjects()){
								try {
									Audio device  = (Audio)activeInput;
			
									CommsCommand stateCommsCommand = new CommsCommand();
									stateCommsCommand.setKey(device.getKey());
									stateCommsCommand.setCommand("NO " + device.getKey() + ETX);
									logger.log (Level.FINEST,"Sending HAL poll for zone " + device.getName());
									stateCommsCommand.setExtraInfo("HAL poll");
									stateCommsCommand.setActionType(CommDevice.HalState);
									stateCommsCommand.setActionCode(device.getKey());
									stateCommsCommand.setKeepForHandshake(true);
			
									comms.addCommandToQueue (stateCommsCommand);
									synchronized (halState){
										StateOfZone zoneState = 	halState.get (device.getKey());
										if (zoneState == null) zoneState = new StateOfZone();
										zoneState.setIgnoreNextPower(false);
										halState.put (device.getKey(),zoneState);
									}
								} catch (ClassCastException ex){
									logger.log(Level.FINE,"Non audio device has been configured for HAL");
								}
						    }
					    }
				    }
				try {
					Thread.sleep (pollValue + waitExtra);
				} catch (InterruptedException ie) {}
				waitExtra = 0;
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
	 * @return Returns the ETX.
	 */
	public String getETX() {
		return ETX;
	}
	/**
	 * @param stx The sTX to set.
	 */
	public void setETX(String etx) {
		this.ETX=etx;
	}

    /**
     * @return Returns the firstRun.
     */
    public boolean isFirstRun() {
        return firstRun;
    }
    /**
     * @param firstRun The firstRun to set.
     */
    public void setFirstRun(boolean firstRun) {
        this.firstRun = firstRun;
    }


	public CommandQueue getCommandQueue() {
		return commandQueue;
	}


	public void setCommandQueue(CommandQueue commandQueue) {
		this.commandQueue = commandQueue;
	}


	public int getDeviceNumber() {
		return deviceNumber;
	}


	public void setDeviceNumber(int deviceNumber) {
		this.deviceNumber = deviceNumber;
	}


	public HashMap <String,StateOfZone>getHalState() {
		return halState;
	}


	public void setHalState(HashMap <String,StateOfZone>state) {
		this.halState = state;
	}
}
