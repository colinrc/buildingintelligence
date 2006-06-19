/**
 * 
 */
package au.com.BI.Comms;

import java.util.List;

import au.com.BI.Command.Command;

/**
 * @author Colin Canfield
 *
 */
public class CommsGroup extends ThreadGroup  {

	protected List commandQueue = null;
	protected int modelNumber = 0;
	
	/**
	 * @param The name for the thread group
	 */
	public CommsGroup(String arg0) {
		super(arg0);
	}
	
	public List getCommandQueue() {
		return commandQueue;
	}
	
	public void setCommandQueue(List commandQueue) {
		this.commandQueue = commandQueue;
	}

	public void uncaughtException(Thread t, Throwable e) {
		if (!(e instanceof AssertionError)){
			Command reAttatchCommand = new Command("SYSTEM","Attatch",null,Integer.toString(modelNumber));
			
			synchronized (commandQueue){
				commandQueue.add(reAttatchCommand);
				commandQueue.notifyAll();
			}
		} else {
			super.uncaughtException(t,e);
		}
	}

	public int getModelNumber() {
		return modelNumber;
	}

	public void setModelNumber(int modelNumber) {
		this.modelNumber = modelNumber;
	}
}
