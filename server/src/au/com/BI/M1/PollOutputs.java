package au.com.BI.M1;

import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Command.Command;
import au.com.BI.Command.CommandQueue;
import au.com.BI.Comms.CommDevice;
import au.com.BI.Comms.CommsFail;
import au.com.BI.M1.Commands.ControlOutputStatusRequest;

public class PollOutputs extends Thread {

	protected Logger logger;

	protected boolean running;

	protected CommDevice comms;

	protected long pollValue = 60000;

	protected CommandQueue commandQueue = null;

	protected int deviceNumber = -1;

	public PollOutputs() {
		super();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		this.setName("M1 output poll");
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

				if (comms != null) {
					ControlOutputStatusRequest statusRequest = new ControlOutputStatusRequest();
					synchronized (comms) {
						comms.sendString(statusRequest.buildM1String() + "\r\n");
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
			command.setCommand("Attach");
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

}
