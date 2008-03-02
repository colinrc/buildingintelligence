package au.com.BI.M1;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Command.Command;
import au.com.BI.Command.CommandQueue;
import au.com.BI.Comms.CommDevice;
import au.com.BI.Comms.CommsCommand;
import au.com.BI.Comms.CommsFail;
import au.com.BI.Device.DeviceType;
import au.com.BI.M1.Commands.Group;
import au.com.BI.M1.Commands.RequestTemperature;
import au.com.BI.Sensors.SensorFascade;

public class PollTemperatureSensors extends Thread {

	protected Logger logger;

	protected volatile boolean running;

	protected CommDevice comms;

	protected long pollValue = 60000;

	protected CommandQueue commandQueue = null;

	protected int deviceNumber = -1;

	protected List<SensorFascade> temperatureSensors = null;

	public PollTemperatureSensors() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		this.setName("M1 temperature poll");
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

				synchronized (temperatureSensors) {

					// how to only request if there is a change in the
					// temperature?
					for (SensorFascade device: temperatureSensors){
						String outputM1Command = buildTemperatureString(device);
						CommsCommand m1Command = new CommsCommand();
						m1Command.setKey(device.getKey());
						m1Command.setKeepForHandshake(false);
						m1Command.setCommand(outputM1Command);
						m1Command.setActionType(DeviceType.SENSOR);
						m1Command.setActionCode(device.getKey());
						m1Command.setExtraInfo(((SensorFascade) (device))
								.getOutputKey());
						if (comms != null) {
							synchronized (comms) {
								comms.addCommandToQueue(m1Command);
							}
							logger
									.log(Level.FINEST,
											"Queueing m1 temperature probe "
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

	public String buildTemperatureString(DeviceType device) {
		String returnString = "";
		RequestTemperature requestTemperature = new RequestTemperature();
		SensorFascade sensor = (SensorFascade) device;
		requestTemperature.setGroup(Group.getByValue(sensor.getGroup()));
		requestTemperature.setDevice(sensor.getKey());
		returnString = requestTemperature.buildM1String() + "\r\n";
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

	public List <SensorFascade>getTemperatureSensors() {
		return temperatureSensors;
	}

	public void setTemperatureSensors(List<SensorFascade> temperatureSensors) {
		this.temperatureSensors = temperatureSensors;
	}
}
