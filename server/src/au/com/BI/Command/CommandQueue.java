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
		queue.add(command);
	}
	
	public boolean isEmpty (){
		return queue.isEmpty();
	}
	
	public CommandInterface remove (){
		if (queue.isEmpty())
			return null;
		else
			return queue.remove();
	}
	
}
