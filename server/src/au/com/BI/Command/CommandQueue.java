/**
 * 
 */
package au.com.BI.Command;

import java.util.concurrent.ConcurrentLinkedQueue;

/**
 * @author colin
 *
 */

public class CommandQueue   {
	private ConcurrentLinkedQueue <CommandInterface>queue = null;
	
	public CommandQueue () {
		queue = new ConcurrentLinkedQueue<CommandInterface>();
	}
	
	public void add (CommandInterface command){
		synchronized (queue){
			queue.add(command);
		}
	}
	
	public boolean isEmpty (){
		synchronized (queue){
			return queue.isEmpty();
		}
	}
	
	public CommandInterface remove (){
		synchronized (queue){
			if (queue.isEmpty())
				return null;
			else
				return queue.remove();
		}
	}
	
}
