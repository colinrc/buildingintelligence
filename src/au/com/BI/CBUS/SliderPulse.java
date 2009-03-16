/**
 * 
 */
package au.com.BI.CBUS;

import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.Command.Cache;
import au.com.BI.Command.CommandQueue;
import au.com.BI.Comms.CommDevice;


/**
 * @author colin
 *
 */
public class SliderPulse extends Thread {


	public int completeDimTime = 5; // Time for ramp from 0 to 100 to top
	public final int dimIntervalTime = 500; // interval in miliseconds between each message
	protected Logger logger;
	protected volatile boolean running = true;
	protected CommDevice comms;
	protected CommandQueue commandQueue = null;
	protected int deviceNumber = -1;
	private int incrementStep = 100;
	protected Model cBUSModel  = null;
	protected Cache cache = null;
	
	public ConcurrentHashMap <String,Integer>  increasingActions;
	public ConcurrentHashMap <String,Integer> decreasingActions;
	
	public SliderPulse () {
		super();
		increasingActions = new ConcurrentHashMap <String,Integer>();
		decreasingActions = new ConcurrentHashMap <String,Integer>();
		setDelayInterval (completeDimTime);
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		this.setName("CBUS slider thread");
	}
	
	public void clearActions () {
		increasingActions.clear();
		decreasingActions.clear();
	}
	
	public void setDelayInterval (int completeDimTime){
		incrementStep = (int) ((double)dimIntervalTime / ((double)completeDimTime * 1000.0 ) * 100.0);
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
	
	public void removeFromQueues (String key){
		this.increasingActions.remove(key);
		this.decreasingActions.remove(key);
		 logger.log(Level.FINEST,"Removing from queues key " + key );
	}
	
	public void run() {
		int currentVal;
		Integer tmpVal;
		running = true;
		
			while (running){
				
				for (String key: this.increasingActions.keySet() ){
					tmpVal = increasingActions.get(key);
					 if (tmpVal == null) continue;
					 currentVal = tmpVal.intValue();
					 currentVal += incrementStep;
					 if (currentVal >= 100 ) {
						 increasingActions.remove(key);
						 sendToFlash (key, "on" , 100);
					 }else {
						 increasingActions.put(key, currentVal);
						 logger.log(Level.FINE,"Recording increase in level for key " + key + " to value "+ currentVal);
						 sendToFlash (key, "on" , currentVal);					 
					 }
				}
				
				
				for (String key: this.decreasingActions.keySet() ){
					 tmpVal = decreasingActions.get(key);
					 if (tmpVal == null) continue;
					 currentVal = tmpVal.intValue();
					 currentVal -= incrementStep;
					 if (currentVal <= 0 ) {
						 decreasingActions.remove(key);
						 sendToFlash (key, "on" , 0);
					 } else {
						 decreasingActions.put(key, currentVal);
						 logger.log(Level.FINE,"Recording increase in level for key " + key + " to value "+ currentVal);
						 sendToFlash (key, "on" , currentVal);	
					 }

				}
					
				try {
					sleep (dimIntervalTime);
				} catch (InterruptedException e) {
				}
			}
	}

	public void sendToFlash (String displayName, String command, Integer value){
		CBUSCommand cbusCommand = new CBUSCommand();
		cbusCommand.setCommand (command);
		cbusCommand.setDisplayName(displayName);
		cbusCommand.setExtraInfo(Integer.toString(value));
		cbusCommand.setKey ("CLIENT_SEND");
		cbusCommand.setTargetDeviceID(-1);
		cache.setCachedCommand(displayName, cbusCommand);
		commandQueue.add(cbusCommand);	
	}
	
	public Model getCBUSModel() {
		return cBUSModel;
	}

	public void setCBUSModel(Model model) {
		cBUSModel = model;
	}

	public Cache getCache() {
		return cache;
	}

	public void setCache(Cache cache) {
		this.cache = cache;
	}

}



