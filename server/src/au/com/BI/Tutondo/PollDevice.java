/*
 * Created on Jun 10, 2004
 *
 */
package au.com.BI.Tutondo;

import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Audio.Audio;
import au.com.BI.Comms.*;
import au.com.BI.Config.ConfigHelper;
/**
 * @author colinc
 *
 *
 */
public class PollDevice extends Thread {
	protected Logger logger;
	protected List <Audio>audioDeviceQueue;
	protected volatile boolean running;
	protected CommDevice comms;
	protected long pollValue;
	protected TutondoHelper tutondoHelper;
	protected ConfigHelper configHelper;
	protected boolean protocol = false; // false is protocol A
	
	
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

	public PollDevice() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		tutondoHelper = new TutondoHelper();
		audioDeviceQueue = Collections.synchronizedList(new LinkedList<Audio>());
		this.setName("Tutondo poll handler");
	}
	
	public void addAudioDevice (Audio audioDevice) {
		synchronized (audioDeviceQueue) {
			audioDeviceQueue.add(audioDevice);
		}
	}
	
	public void clearItems () {
		running = false;
		synchronized (audioDeviceQueue) {
			audioDeviceQueue.clear();
		}
	}

	protected void setConfigHelper (ConfigHelper configHelper) {
		this.configHelper = configHelper;
	}
	
	public void run ()  {
		byte[] startupCommand = new byte[6];
		running = true;
		while (running) {
			CommsCommand lastCommandSent;
			

			    lastCommandSent = comms.getLastCommandSent(); 
				if (!comms.isCommandSentQueueEmpty() && 
				        lastCommandSent != null) {
					synchronized (comms) {
						if  (lastCommandSent.getActionType() == CommDevice.TutondoState || 
							        lastCommandSent.getActionType() == CommDevice.TutondoPrograms ||
							        lastCommandSent.getActionType() == CommDevice.TutondoVolume){
							 logger.log (Level.WARNING,"Tutondo is not responding, please check cabling. Outstanding commands: " + comms.getSizeOfSentQueue());
						     comms.acknowledgeCommand(CommDevice.TutondoState, true);
						     comms.acknowledgeCommand(CommDevice.TutondoPrograms, true);
						     comms.acknowledgeCommand(CommDevice.TutondoVolume, true);
						}
					}
				}
				else {
					int count = 0;

					for (Audio nextDevice:audioDeviceQueue){
						String zoneKey = (nextDevice).getKey();
						String zoneName = (nextDevice).getOutputKey();

						startupCommand = tutondoHelper.buildTutondoCommand(50, 0, zoneKey, protocol);
						CommsCommand startupCommsCommand = new CommsCommand();
						startupCommsCommand.setKey (zoneKey);
						startupCommsCommand.setActionCode(zoneKey);
						startupCommsCommand.setKeepForHandshake(true);
						startupCommsCommand.setCommandBytes(startupCommand);
						startupCommsCommand.setExtraInfo (zoneName);
						startupCommsCommand.setActionType(CommDevice.TutondoState);
						try { 
							synchronized (comms){
								comms.addCommandToQueue (startupCommsCommand);
								if (protocol) comms.sendNextCommand ();
							}
						} catch (CommsFail e1) {
							logger.log(Level.WARNING, "Communication failed polling Tutondo " + e1.getMessage());
						} 

						startupCommand = tutondoHelper.buildTutondoCommand(51, 0, zoneKey, protocol);
						CommsCommand volumeCommand = new CommsCommand();
						volumeCommand.setKey (zoneKey);
						volumeCommand.setActionCode(zoneKey);
						volumeCommand.setKeepForHandshake(true);
						volumeCommand.setCommandBytes(startupCommand);
						volumeCommand.setExtraInfo (zoneName);
						volumeCommand.setActionType(CommDevice.TutondoVolume);
						try { 
							synchronized (comms){
								comms.addCommandToQueue (volumeCommand);
								if (protocol) comms.sendNextCommand ();
							}
						} catch (CommsFail e1) {
							logger.log(Level.WARNING, "Communication failed polling Tutondo " + e1.getMessage());
						} 
						
						startupCommand = tutondoHelper.buildTutondoCommand(52, 0, zoneKey, protocol);
						CommsCommand programCommsCommand = new CommsCommand();
						programCommsCommand.setKey (zoneKey);
						programCommsCommand.setActionCode(zoneKey);
						programCommsCommand.setCommandBytes(startupCommand);
						programCommsCommand.setKeepForHandshake(true);
						programCommsCommand.setExtraInfo (zoneName);
						programCommsCommand.setActionType(CommDevice.TutondoPrograms);
						try {
							synchronized (comms){							
								comms.addCommandToQueue (programCommsCommand);
								if (protocol) comms.sendNextCommand ();
							}
						} catch (CommsFail e1) {
							logger.log(Level.WARNING, "Communication failed polling Tutondo " + e1.getMessage());
						}
						if (count %3 == 0) {
							try {
								Thread.sleep (10); // give the GC100 time to clear itself
							} catch (InterruptedException ie) {}

						}
						count ++;
						
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
	public char getSTX() {
		return tutondoHelper.getSTX();
	}
	/**
	 * @param stx The sTX to set.
	 */
	public void setSTX(char stx) {
		tutondoHelper.setSTX(stx);
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
	public char getETX() {
		return tutondoHelper.getETX();
	}
	/**
	 * @param stx The sTX to set.
	 */
	public void setETX(char etx) {
		tutondoHelper.setETX(etx);
	}
	public boolean isProtocol() {
		return protocol;
	}
	public void setProtocol(boolean protocol) {
		this.protocol = protocol;
	}
}
