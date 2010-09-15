/*
 * Created on Jun 10, 2004
 *
 */
package au.com.BI.CBUS;

import au.com.BI.Util.Utility;
import java.util.logging.Level;
import java.util.*;
import java.util.logging.Logger;

import au.com.BI.Comms.*;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;
import au.com.BI.Sensors.*;

/**
 * @author colinc
 * Polls the clipsal 5031TS temperature sensor
 * Setup to only poll at a maximimum of once
 * every 20 seconds
 */
public class PollTemperatures extends Thread {
	protected Logger logger;
	protected volatile boolean running;
	protected CommDevice comms;
	protected long pollValue = 60000;
	protected CommandQueue commandQueue = null;
	protected int deviceNumber = -1;
	protected List <SensorFascade>temperatureSensors = null;

	public PollTemperatures() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		this.setName("CBUS temperature poll");
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
		if (pollValue > 20 )
			this.pollValue = pollValue;
		else
			this.pollValue = 20;
	}

	public void clearItems () {
		running = false;
	}


	public void run ()  {
		running = true;
		try {
			while (running) {
				/*
			    synchronized (comms){
			    	comms.acknowlegeCommand(DeviceType.TEMPERATURE);
			    }*/

				synchronized (temperatureSensors) {
					for (SensorFascade device: temperatureSensors) {

						String outputCbusCommand = buildTempString (device);
						CommsCommand cbusCommsCommand = new CommsCommand();
						cbusCommsCommand.setKey (device.getKey());
						cbusCommsCommand.setKeepForHandshake(false);
						cbusCommsCommand.setCommand(outputCbusCommand);
						cbusCommsCommand.setActionType(DeviceType.TEMPERATURE);
						cbusCommsCommand.setActionCode(device.getKey());
						cbusCommsCommand.setExtraInfo (((SensorFascade)(device)).getOutputKey());
						if (comms != null){
							synchronized (comms) {
								comms.addCommandToQueue (cbusCommsCommand);
							} 
							logger.log (Level.FINEST,"Queueing cbus temperature probe "  + " for " + (String)cbusCommsCommand.getExtraInfo());
						}
					}
				}
				try {
					Thread.sleep (pollValue );
				} catch (InterruptedException ie) {}
			}
		} catch (CommsFail e1) {
			running = false;
			logger.log(Level.WARNING, "Communication failed polling CBUS " + e1.getMessage());
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

	public String buildTempString(DeviceType device) {
		String retCode = "\\" + "06";
		retCode += Utility.padString (device.getKey(),2);
		retCode += "002A0E02";
		
		byte remainder = (byte)(((byte)6 + Byte.parseByte(device.getKey(),16) + 0x2A + 0x0E + 0x02) % 256);
		byte twosComp = (byte)-remainder;

		String hexCheck = Integer.toHexString(twosComp);
		if (hexCheck.length() == 1) hexCheck = "0" + hexCheck;
		if (hexCheck.length() > 2) hexCheck = hexCheck.substring(hexCheck.length() - 2);

		return retCode + hexCheck + '\r';
	}


	/**
	 * @param comms The comms to set.
	 */
	public void setComms(CommDevice comms) {
		this.comms = comms;
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


	public List <SensorFascade>getTemperatureSensors() {
		return temperatureSensors;
	}


	public void setTemperatureSensors(List <SensorFascade> temperatureSensors) {
		this.temperatureSensors = temperatureSensors;
	}

}
