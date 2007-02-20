/**
 * 
 */
package au.com.BI.CBUS;

import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Logger;

import au.com.BI.Command.CommandQueue;
import au.com.BI.Comms.CommDevice;


/**
 * @author colin
 *
 */
public class SliderPulse extends Thread {


	public int completeDimTime = 0; // Time for ramp from 0 to 100 to top
	public int dimIntervalTime = 500; // interval in miliseconds between each message
	protected Logger logger;
	protected boolean running;
	protected CommDevice comms;
	protected CommandQueue commandQueue = null;
	protected int deviceNumber = -1;
	
	
	public ConcurrentHashMap <String,Integer>  increasingActions;
	public ConcurrentHashMap <String,Integer> decreasingActions;
	
	public SliderPulse () {
		super();
		increasingActions = new ConcurrentHashMap <String,Integer>();
		decreasingActions = new ConcurrentHashMap <String,Integer>();

		logger = Logger.getLogger(this.getClass().getPackage().getName());
		this.setName("CBUS slider thread");
	}
	
	public void clearActions () {
		increasingActions.clear();
		decreasingActions.clear();
	}
	
	public void addToIncreasingQueue (String item, int startValue){
		decreasingActions.remove(item);
		increasingActions.put (item,startValue);
	}
	
	public void addToDecreasingQueue (String item, int startValue){
		increasingActions.remove(item);
		decreasingActions.put (item,startValue);
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
	public CommandQueue getCommandQueue() {
		return commandQueue;
	}


	public void setCommandQueue(CommandQueue commandQueue) {
		this.commandQueue = commandQueue;
	}


	public int getDeviceNumber() {
		return deviceNumber;
	}

	public void clearItems () {
		running = false;
		this.increasingActions.clear();
		this.decreasingActions.clear();
	}
	
	public void setDeviceNumber(int deviceNumber) {
		this.deviceNumber = deviceNumber;
	}
	
	
	public void run() {
			
	}

}



