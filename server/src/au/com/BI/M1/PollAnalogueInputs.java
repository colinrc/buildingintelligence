package au.com.BI.M1;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Analog.Analog;
import au.com.BI.Command.Command;
import au.com.BI.Command.CommandQueue;
import au.com.BI.Comms.CommDevice;
import au.com.BI.Comms.CommsCommand;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Device.DeviceType;
import au.com.BI.M1.Commands.RequestZoneVoltage;

public class PollAnalogueInputs extends Thread {
	protected Logger logger;

	protected volatile boolean running;

	protected CommDevice comms;

	protected long pollValue = 60000;

	protected CommandQueue commandQueue = null;

	protected int deviceNumber = -1;

	protected List <Analog>analogueInputs = null;

	public PollAnalogueInputs() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		this.setName("M1 analogue inputs poll");
	}

	/**
	 * @return Returns the pollValue.
	 */
	public long getPollValue() {
		return pollValue;
	}

	/**
	 * @param pollValue
	 *            The pollValue to set.
	 */
	public void setPollValue(long pollValue) {
		this.pollValue = pollValue;
	}

	public void clearItems() {
		running = false;
	}

	public void run() {
		running = true;
		try {
			while (running) {
				/*
				 * synchronized (comms){
				 * comms.acknowlegeCommand(DeviceType.TEMPERATURE); }
				 */

				synchronized (analogueInputs) {

					// how to only request if there is a change in the
					// temperature?
					for (Analog device:analogueInputs){
						String outputM1Command = buildAnalogueInputString(device);
						CommsCommand m1Command = new CommsCommand();
						m1Command.setKey(device.getKey());
						m1Command.setKeepForHandshake(false);
						m1Command.setCommand(outputM1Command);
						m1Command.setActionType(DeviceType.ANALOG);
						m1Command.setActionCode(device.getKey());
						m1Command.setExtraInfo(((Analog) (device))
								.getOutputKey());
						if (comms != null) {
							synchronized (comms) {
								comms.addCommandToQueue(m1Command);
							}
							logger
									.log(Level.FINEST,
											"Queueing m1 voltage request "
													+ " for "
													+ (String) m1Command
															.getExtraInfo());
						}
					}
				}
				try {
					Thread.sleep(pollValue);
				} catch (InterruptedException ie) {
				}
			}
		} catch (CommsFail e1) {
			running = false;
			logger.log(Level.WARNING, "Communication failed polling m1 "
					+ e1.getMessage());
			Command command = new Command();
			command.setCommand("Attatch");
			command.setKey("SYSTEM");
			command.setExtraInfo(Integer.toString(deviceNumber));
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
	 * @param running
	 *            The running to set.
	 */
	public void setRunning(boolean running) {
		this.running = running;
	}

	public String buildAnalogueInputString(DeviceType device) {
		String returnString = "";
		RequestZoneVoltage requestZoneVoltage = new RequestZoneVoltage();
//		Analog analog = (Analog) device;
		requestZoneVoltage.setZone(device.getKey());
		returnString = requestZoneVoltage.buildM1String() + "\r\n";
		return (returnString);
	}

	/**
	 * @param comms
	 *            The comms to set.
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

	public List<Analog>getAnalogueInputs() {
		return analogueInputs;
	}

	public void setAnalogueInputs(List <Analog>temperatureSensors) {
		this.analogueInputs = temperatureSensors;
	}
}
