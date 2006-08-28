/**
 * 
 */
package au.com.BI.Maintainance;

import org.quartz.Job;
import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import java.util.logging.Level;
import java.util.logging.Logger;
import au.com.BI.Macro.MacroHandler;

/**
 * @author colin
 *
 */
public class DailyTask implements Job {

	protected Logger logger = null;
	
	public DailyTask ( ){
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
    public void execute(JobExecutionContext context)
	throws JobExecutionException
	{
	      JobDataMap dataMap = context.getJobDetail().getJobDataMap();
	      MacroHandler  macroHandler = (MacroHandler)dataMap.get("MACRO");
	      macroHandler.cleanCalendarFile();
	      logger.log (Level.FINE,"Maintenance completed");
	}
}
