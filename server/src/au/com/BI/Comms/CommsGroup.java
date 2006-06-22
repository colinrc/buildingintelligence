/**
 * 
 */
package au.com.BI.Comms;


import au.com.BI.Command.Command;
import au.com.BI.Command.CommandQueue;

/**
 * @author Colin Canfield
 *
 */
public class CommsGroup extends ThreadGroup  {

	protected CommandQueue commandQueue = null;
	protected int modelNumber = 0;
	
	/**
	 * @param The name for the thread group
	 */
	public CommsGroup(String arg0) {
		super(arg0);
	}
	
	public CommandQueue getCommandQueue() {
		return commandQueue;
	}
	
	public void setCommandQueue(CommandQueue commandQueue) {
		this.commandQueue = commandQueue;
	}

	public void uncaughtException(Thread t, Throwable e) {
		if (!(e instanceof AssertionError)){
			Command reAttatchCommand = new Command("SYSTEM","Attatch",null,Integer.toString(modelNumber));
			
			commandQueue.add(reAttatchCommand);
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
