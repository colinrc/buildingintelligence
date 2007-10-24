/**
 * 
 */
package au.com.BI.Maintainance;

import org.quartz.Job;
import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import au.com.BI.Command.Command;
import au.com.BI.Command.CommandQueue;

import java.util.Calendar;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * @author colin
 *
 */
public class RegularTask implements Job {

	protected Logger logger = null;
	
	public RegularTask ( ){
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
    public void execute(JobExecutionContext context)
	throws JobExecutionException
	{
	      JobDataMap dataMap = context.getJobDetail().getJobDataMap();
	      CommandQueue commandQueue = (CommandQueue)dataMap.get("COMMANDS");
	      if (commandQueue == null) {
	    	  logger.log (Level.WARNING,"The regular event trigger was not properly set up");
	    	  return;
	      }
	      Command regularCommand = new Command ();
	      regularCommand.setCommand("fire");
	      regularCommand.setDisplayName("TRIGGER");
	      Date timeSched = context.getScheduledFireTime();
	      int mins = timeSched.getMinutes();
	      regularCommand.setExtraInfo(Integer.toString(mins));
	      commandQueue.add(regularCommand);
	      
	}
}
